import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/intermediate_product.dart';

/// Dialog tambah / edit Bahan Olahan (nama + satuan).
class IntermediateFormDialog extends StatefulWidget {
  final IntermediateProduct? existing;
  const IntermediateFormDialog({super.key, this.existing});

  @override
  State<IntermediateFormDialog> createState() =>
      _IntermediateFormDialogState();
}

class _IntermediateFormDialogState extends State<IntermediateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _unit;

  static const _units = ['shot', 'base', 'ml', 'gr', 'pcs'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _unit = widget.existing?.unit ?? 'shot';
    if (!_units.contains(_unit)) _unit = 'shot';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final item = IntermediateProduct(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      unit: _unit,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Bahan Olahan' : 'Tambah Bahan Olahan'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Bahan Olahan',
                  hintText: 'mis. Shot Espresso, Matcha Base',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  labelText: 'Satuan',
                  helperText: 'Satuan saat dipakai di resep menu',
                ),
                items: _units
                    .map((u) =>
                        DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
