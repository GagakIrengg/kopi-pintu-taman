import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item.dart';

Future<List<MenuItem>?> showAddonsDialog(
    BuildContext context, List<MenuItem> addons,
    {List<MenuItem> initial = const []}) {
  final selected = {...initial.map((e) => e.id)};
  return showDialog<List<MenuItem>>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Tambah Add-ons'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final a in addons)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selected.contains(a.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selected.add(a.id);
                      } else {
                        selected.remove(a.id);
                      }
                    });
                  },
                  title: Text(a.name),
                  subtitle: Text(formatRupiah(a.price)),
                )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              addons.where((a) => selected.contains(a.id)).toList(),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}
