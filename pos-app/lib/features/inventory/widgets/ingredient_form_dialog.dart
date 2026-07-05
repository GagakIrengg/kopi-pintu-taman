import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/inventory_item.dart';

/// Dialog form untuk tambah / edit ingredient (bahan baku).
/// Mengembalikan [InventoryItem] jika user menekan simpan, atau null jika dibatalkan.
class IngredientFormDialog extends StatefulWidget {
  final InventoryItem? existing;
  const IngredientFormDialog({super.key, this.existing});

  @override
  State<IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _minStockCtrl;
  late String _unit;

  static const _units = ['gr', 'ml', 'pcs', 'kg', 'l'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _stockCtrl = TextEditingController(
        text: e == null ? '' : e.stock.toStringAsFixed(0));
    _minStockCtrl = TextEditingController(
        text: e == null ? '' : e.minStock.toStringAsFixed(0));
    _unit = e?.unit ?? 'gr';
    // Pastikan satuan yang lama tetap masuk daftar (mis. user pernah pakai satuan custom)
    if (!_units.contains(_unit)) _unit = 'gr';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final item = InventoryItem(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      unit: _unit,
      stock: double.parse(_stockCtrl.text.trim()),
      minStock: double.parse(_minStockCtrl.text.trim()),
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Bahan' : 'Tambah Bahan Baru'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bahan',
                    hintText: 'mis. Biji Kopi Arabika',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: const InputDecoration(labelText: 'Satuan'),
                  items: _units
                      .map((u) =>
                          DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockCtrl,
                        decoration: InputDecoration(
                          labelText: 'Stok Awal',
                          suffixText: _unit,
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Wajib';
                          final n = double.tryParse(v.trim());
                          if (n == null || n < 0) return 'Harus ≥ 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockCtrl,
                        decoration: InputDecoration(
                          labelText: 'Stok Minimum',
                          suffixText: _unit,
                          helperText: 'Batas peringatan restock',
                          helperMaxLines: 2,
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Wajib';
                          final n = double.tryParse(v.trim());
                          if (n == null || n < 0) return 'Harus ≥ 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah'),
        ),
      ],
    );
  }
}
