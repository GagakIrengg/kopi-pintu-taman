import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/intermediate_product.dart';
import '../../../../data/models/inventory_item.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/recipe_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../widgets/add_intermediate_recipe_dialog.dart';
import '../../widgets/intermediate_form_dialog.dart';

/// Tab "Bahan Olahan": daftar produk antara + kelola resepnya.
class IntermediateTab extends ConsumerWidget {
  const IntermediateTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(intermediatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Bahan setengah jadi yang dipakai banyak menu '
                '(mis. Shot Espresso = 9gr Biji Kopi).',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Bahan Olahan'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: listAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada Bahan Olahan.\n'
                    'Tambah dengan tombol di kanan atas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _IntermediateCard(
                  product: items[i],
                  onEdit: () =>
                      _openForm(context, ref, existing: items[i]),
                  onDelete: () =>
                      _confirmDelete(context, ref, items[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
      {IntermediateProduct? existing}) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<IntermediateProduct>(
      context: context,
      builder: (_) => IntermediateFormDialog(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(recipeRepositoryProvider);
    try {
      if (existing == null) {
        await repo.addIntermediate(result);
      } else {
        await repo.updateIntermediate(result);
      }
      ref.invalidate(intermediatesProvider);
      messenger.showSnackBar(SnackBar(
        content: Text(existing == null
            ? 'Bahan Olahan "${result.name}" ditambahkan.'
            : 'Bahan Olahan "${result.name}" diperbarui.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Gagal: $e (mungkin nama sudah dipakai)'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      IntermediateProduct p) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Bahan Olahan'),
        content: Text(
          'Hapus "${p.name}"? Resepnya juga akan ikut terhapus.\n'
          'Menu yang memakai ini tidak otomatis terupdate, '
          'cek lagi resep menu terkait.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(recipeRepositoryProvider).deleteIntermediate(p.id);
    ref.invalidate(intermediatesProvider);
    messenger.showSnackBar(
        SnackBar(content: Text('"${p.name}" dihapus.')));
  }
}

class _IntermediateCard extends ConsumerWidget {
  final IntermediateProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _IntermediateCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(intermediateRecipeProvider(product.id));
    final invAsync = ref.watch(inventoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${product.name}  ·  per 1 ${product.unit}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit nama/satuan',
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.coffee700),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(),
            recipeAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (rows) {
                final inv = invAsync.valueOrNull ?? <InventoryItem>[];
                String nameOf(String id) => inv
                    .firstWhere(
                      (e) => e.id == id,
                      orElse: () => const InventoryItem(
                        id: '',
                        name: '(bahan terhapus)',
                        unit: '',
                        stock: 0,
                        minStock: 0,
                      ),
                    )
                    .name;
                String unitOf(String id) => inv
                    .firstWhere(
                      (e) => e.id == id,
                      orElse: () => const InventoryItem(
                        id: '',
                        name: '',
                        unit: '',
                        stock: 0,
                        minStock: 0,
                      ),
                    )
                    .unit;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '⚠️ Resep kosong. Tambah bahan mentah di bawah.',
                          style: TextStyle(color: AppColors.warning),
                        ),
                      )
                    else
                      ...rows.map((r) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record,
                                    size: 8,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${nameOf(r.ingredientId)} — '
                                    '${r.quantity.toStringAsFixed(r.quantity.truncateToDouble() == r.quantity ? 0 : 2)} '
                                    '${unitOf(r.ingredientId)}',
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Hapus baris',
                                  icon: const Icon(Icons.close,
                                      size: 18,
                                      color: AppColors.danger),
                                  onPressed: () async {
                                    await ref
                                        .read(recipeRepositoryProvider)
                                        .deleteIntermediateRecipeRow(
                                            r.id);
                                    ref.invalidate(
                                        intermediateRecipeProvider(
                                            product.id));
                                  },
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Bahan'),
                        onPressed: () => _addRow(
                          context,
                          ref,
                          rows.map((e) => e.ingredientId).toSet(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRow(
    BuildContext context,
    WidgetRef ref,
    Set<String> excluded,
  ) async {
    final result = await showDialog<AddIntermediateRecipeResult>(
      context: context,
      builder: (_) => AddIntermediateRecipeDialog(
        intermediate: product,
        excludedIngredientIds: excluded,
      ),
    );
    if (result == null) return;
    await ref.read(recipeRepositoryProvider).upsertIntermediateRecipe(
          IntermediateRecipe(
            id: newRecipeRowId(),
            intermediateId: product.id,
            ingredientId: result.ingredientId,
            quantity: result.quantity,
          ),
        );
    ref.invalidate(intermediateRecipeProvider(product.id));
  }
}
