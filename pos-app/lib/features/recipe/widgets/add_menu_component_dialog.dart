import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/menu_recipe.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/recipe_providers.dart';

/// Hasil dialog: 1 komponen resep menu.
class AddMenuComponentResult {
  final RecipeComponentType type;
  final String componentId;
  final double quantity;
  AddMenuComponentResult(this.type, this.componentId, this.quantity);
}

/// Dialog: pilih komponen (Bahan Mentah ATAU Bahan Olahan) + takaran,
/// untuk dimasukkan ke resep sebuah menu pada temperature tertentu.
class AddMenuComponentDialog extends ConsumerStatefulWidget {
  final String menuName;
  final String tempLabel; // 'Hot' / 'Iced' / '-' (untuk info di judul)

  /// Kombinasi "type:id" yang sudah ada di resep (biar tidak dobel).
  final Set<String> excludedKeys;

  const AddMenuComponentDialog({
    super.key,
    required this.menuName,
    required this.tempLabel,
    this.excludedKeys = const {},
  });

  @override
  ConsumerState<AddMenuComponentDialog> createState() =>
      _AddMenuComponentDialogState();
}

class _AddMenuComponentDialogState
    extends ConsumerState<AddMenuComponentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();

  RecipeComponentType _type = RecipeComponentType.ingredient;
  String? _selectedId;
  String _selectedUnit = '';

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  String _key(RecipeComponentType t, String id) => '${t.name}:$id';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedId == null) return;
    Navigator.of(context).pop(
      AddMenuComponentResult(
        _type,
        _selectedId!,
        double.parse(_qtyCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invAsync = ref.watch(inventoryProvider);
    final intAsync = ref.watch(intermediatesProvider);

    return AlertDialog(
      title: Text('Tambah Komponen — ${widget.menuName}'
          '${widget.tempLabel == '-' ? '' : ' (${widget.tempLabel})'}'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pilih jenis komponen
              SegmentedButton<RecipeComponentType>(
                segments: const [
                  ButtonSegment(
                    value: RecipeComponentType.ingredient,
                    label: Text('Bahan Mentah'),
                    icon: Icon(Icons.grass),
                  ),
                  ButtonSegment(
                    value: RecipeComponentType.intermediate,
                    label: Text('Bahan Olahan'),
                    icon: Icon(Icons.blender),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  _selectedId = null;
                  _selectedUnit = '';
                }),
              ),
              const SizedBox(height: 16),

              // Dropdown sesuai jenis
              if (_type == RecipeComponentType.ingredient)
                invAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (all) {
                    final list = all
                        .where((i) => !widget.excludedKeys.contains(
                            _key(RecipeComponentType.ingredient, i.id)))
                        .toList();
                    if (list.isEmpty) {
                      return const Text(
                          'Tidak ada bahan mentah yang tersedia '
                          '(semua sudah dipakai / Inventory kosong).');
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Pilih Bahan Mentah'),
                      items: list
                          .map((i) => DropdownMenuItem(
                                value: i.id,
                                child: Text('${i.name} (${i.unit})'),
                              ))
                          .toList(),
                      validator: (v) => v == null ? 'Pilih bahan' : null,
                      onChanged: (v) => setState(() {
                        _selectedId = v;
                        _selectedUnit = list
                            .firstWhere((e) => e.id == v)
                            .unit;
                      }),
                    );
                  },
                )
              else
                intAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (all) {
                    final list = all
                        .where((i) => !widget.excludedKeys.contains(
                            _key(RecipeComponentType.intermediate, i.id)))
                        .toList();
                    if (list.isEmpty) {
                      return const Text(
                          'Belum ada Bahan Olahan, atau semua sudah '
                          'dipakai. Buat dulu di tab "Bahan Olahan".');
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Pilih Bahan Olahan'),
                      items: list
                          .map((i) => DropdownMenuItem(
                                value: i.id,
                                child: Text('${i.name} (${i.unit})'),
                              ))
                          .toList(),
                      validator: (v) => v == null ? 'Pilih bahan' : null,
                      onChanged: (v) => setState(() {
                        _selectedId = v;
                        _selectedUnit = list
                            .firstWhere((e) => e.id == v)
                            .unit;
                      }),
                    );
                  },
                ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _qtyCtrl,
                decoration: InputDecoration(
                  labelText: 'Takaran per 1 porsi',
                  suffixText: _selectedUnit,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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
