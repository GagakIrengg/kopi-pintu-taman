import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/repository_providers.dart';
import '../widgets/menu_form_dialog.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() =>
      _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  MenuCategory? _filter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuItemsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manajemen Menu',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text(
                      'Tambah, ubah, dan hapus daftar menu yang dijual.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Menu'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari nama menu...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<MenuCategory?>(
                  initialValue: _filter,
                  isDense: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Semua Kategori')),
                    ...MenuCategory.values.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: menuAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                final filtered = items.where((m) {
                  if (_filter != null && m.category != _filter) return false;
                  final q = _searchCtrl.text.trim().toLowerCase();
                  if (q.isNotEmpty && !m.name.toLowerCase().contains(q)) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada menu yang cocok dengan filter.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return Card(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return _MenuTile(
                        item: item,
                        onEdit: () => _openForm(existing: item),
                        onDelete: () => _confirmDelete(item),
                        onToggleAvail: () => _toggleAvailability(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          menuAsync.maybeWhen(
            data: (items) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Total: ${items.length} menu '
                '(${items.where((m) => m.isAvailable).length} aktif)',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({MenuItem? existing}) async {
    final result = await showDialog<MenuItem>(
      context: context,
      builder: (dialogContext) => MenuFormDialog(existing: existing),
    );
    if (result == null) return;
    if (!mounted) return;

    final repo = ref.read(menuRepositoryProvider);
    try {
      if (existing == null) {
        await repo.add(result);
      } else {
        await repo.update(result);
      }
      ref.invalidate(menuItemsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(existing == null
            ? 'Menu "${result.name}" berhasil ditambahkan.'
            : 'Menu "${result.name}" berhasil diperbarui.'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan: $e'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _confirmDelete(MenuItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text(
          'Yakin ingin menghapus "${item.name}"?\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (!mounted) return;

    await ref.read(menuRepositoryProvider).delete(item.id);
    ref.invalidate(menuItemsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Menu "${item.name}" dihapus.'),
    ));
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    final updated = item.copyWith(isAvailable: !item.isAvailable);
    await ref.read(menuRepositoryProvider).update(updated);
    ref.invalidate(menuItemsProvider);
  }
}

class _MenuTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvail;
  const _MenuTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvail,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (!item.isAvailable)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Nonaktif',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              formatRupiah(item.price),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('• ${item.category.label}',
                style: const TextStyle(color: AppColors.textMuted)),
            Text('• ${_tempLabel(item.temperature)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                )),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: item.isAvailable,
            onChanged: (_) => onToggleAvail(),
          ),
          IconButton(
            tooltip: 'Edit',
            icon:
                const Icon(Icons.edit_outlined, color: AppColors.coffee700),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _tempLabel(MenuTemperature t) => switch (t) {
        MenuTemperature.hot => 'Hot',
        MenuTemperature.iced => 'Iced',
        MenuTemperature.both => 'Hot / Iced',
        MenuTemperature.none => '—',
      };
}
