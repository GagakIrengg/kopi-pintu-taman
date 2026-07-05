import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/intermediate_product.dart';
import '../../../data/models/inventory_item.dart';
import '../../../providers/data_providers.dart';

/// Hasil yang dikembalikan dialog: 1 baris resep bahan olahan.
class AddIntermediateRecipeResult {
  final String ingredientId;
  final double quantity;
  AddIntermediateRecipeResult(this.ingredientId, this.quantity);
}

/// Dialog: pilih bahan mentah + takaran, untuk dimasukkan ke resep
/// sebuah Bahan Olahan.
class AddIntermediateRecipeDialog extends ConsumerStatefulWidget {
  final IntermediateProduct intermediate;

  /// id bahan mentah yang sudah ada di resep (supaya tidak dobel).
  final Set<String> excludedIngredientIds;

  const AddIntermediateRecipeDialog({
    super.key,
    required this.intermediate,
    this.excludedIngredientIds = const {},
  });

  @override
  ConsumerState<AddIntermediateRecipeDialog> createState() =>
      _AddIntermediateRecipeDialogState();
}

class _AddIntermediateRecipeDialogState
    extends ConsumerState<AddIntermediateRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  InventoryItem? _selected;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selected == null) return;
    Navigator.of(context).pop(
      AddIntermediateRecipeResult(
        _selected!.id,
        double.parse(_qtyCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invAsync = ref.watch(inventoryProvider);

    return AlertDialog(
      title: Text('Tambah Bahan ke "${widget.intermediate.name}"'),
      content: SizedBox(
        width: 460,
        child: invAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
          data: (allInv) {
            final available = allInv
                .where((i) =>
                    !widget.excludedIngredientIds.contains(i.id))
                .toList();

            if (available.isEmpty) {
              return const Text(
                'Semua bahan mentah sudah ada di resep ini, '
                'atau belum ada bahan di Inventory.',
              );
            }

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<InventoryItem>(
                    initialValue: _selected,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Bahan Mentah',
                    ),
                    items: available
                        .map((i) => DropdownMenuItem(
                              value: i,
                              child: Text('${i.name} (${i.unit})'),
                            ))
                        .toList(),
                    validator: (v) =>
                        v == null ? 'Pilih bahan' : null,
                    onChanged: (v) => setState(() => _selected = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Takaran per 1 '
                          '${widget.intermediate.unit}',
                      suffixText: _selected?.unit ?? '',
                      helperText: _selected == null
                          ? null
                          : 'Berapa ${_selected!.unit} '
                              '${_selected!.name} untuk membuat 1 '
                              '${widget.intermediate.unit} '
                              '${widget.intermediate.name}',
                      helperMaxLines: 3,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.]')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Wajib';
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Harus > 0';
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}

// Helper agar uuid bisa dipakai di pemanggil tanpa import tambahan.
String newRecipeRowId() => const Uuid().v4();
