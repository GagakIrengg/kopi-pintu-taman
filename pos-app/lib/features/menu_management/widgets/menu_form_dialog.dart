import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/menu_item.dart';

/// Dialog form untuk tambah / edit menu.
/// Mengembalikan [MenuItem] jika user menekan simpan, atau null jika dibatalkan.
class MenuFormDialog extends StatefulWidget {
  final MenuItem? existing;
  const MenuFormDialog({super.key, this.existing});

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late MenuCategory _category;
  late MenuTemperature _temperature;
  late bool _isAvailable;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl =
        TextEditingController(text: e == null ? '' : e.price.toString());
    _category = e?.category ?? MenuCategory.coffee;
    _temperature = e?.temperature ?? MenuTemperature.none;
    _isAvailable = e?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final price = int.parse(_priceCtrl.text.trim());
    final item = MenuItem(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      price: price,
      category: _category,
      temperature: _temperature,
      isAvailable: _isAvailable,
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Menu' : 'Tambah Menu Baru'),
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
                    labelText: 'Nama Menu',
                    hintText: 'mis. Kopi Pintu Taman',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  textCapitalization: TextCapitalization.words,
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
                      return 'Harga harus berupa angka > 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MenuCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: MenuCategory.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MenuTemperature>(
                  value: _temperature,
                  decoration: const InputDecoration(labelText: 'Penyajian'),
                  items: const [
                    DropdownMenuItem(
                      value: MenuTemperature.none,
                      child: Text('Tidak ada (snack / food)'),
                    ),
                    DropdownMenuItem(
                      value: MenuTemperature.hot,
                      child: Text('Hot saja'),
                    ),
                    DropdownMenuItem(
                      value: MenuTemperature.iced,
                      child: Text('Iced saja'),
                    ),
                    DropdownMenuItem(
                      value: MenuTemperature.both,
                      child: Text('Bisa Hot / Iced'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _temperature = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Tersedia'),
                  subtitle:
                      const Text('Jika dinonaktifkan, menu disembunyikan di POS'),
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                  contentPadding: EdgeInsets.zero,
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
