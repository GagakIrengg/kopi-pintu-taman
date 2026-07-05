import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hasil dialog custom menu: nama + harga.
class CustomMenuResult {
  final String name;
  final int price;
  CustomMenuResult(this.name, this.price);
}

/// Dialog tambah item custom (mendadak) langsung dari POS.
/// Hanya nama + harga (sesuai keputusan). Qty diatur lewat cart biasa.
class CustomMenuDialog extends StatefulWidget {
  const CustomMenuDialog({super.key});

  @override
  State<CustomMenuDialog> createState() => _CustomMenuDialogState();
}

class _CustomMenuDialogState extends State<CustomMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CustomMenuResult(
        _nameCtrl.text.trim(),
        int.parse(_priceCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Custom Menu'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Untuk pesanan mendadak yang belum ada di menu. '
                  'Item ini tidak masuk perhitungan rekomendasi.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  hintText: 'mis. Mi Goreng Double Nyemek',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) {
                    return 'Harga harus angka > 0';
                  }
                  return null;
                },
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
          child: const Text('Tambah ke Pesanan'),
        ),
      ],
    );
  }
}
