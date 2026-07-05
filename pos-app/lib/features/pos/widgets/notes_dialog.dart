import 'package:flutter/material.dart';

const _quickNotes = [
  'Less Ice', 'Less Sugar', 'Extra Ice', 'Extra Sugar',
  'No Sugar', 'No Ice', 'Hot tanpa gula',
];

Future<String?> showItemNotesDialog(BuildContext context, String? initial) {
  final ctrl = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Catatan Item'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: ctrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'cth: Less Ice, Less Sugar'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickNotes
                    .map((n) => ActionChip(
                          label: Text(n),
                          onPressed: () {
                            final cur = ctrl.text.trim();
                            ctrl.text = cur.isEmpty ? n : '$cur, $n';
                            setState(() {});
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Hapus')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Simpan')),
        ],
      ),
    ),
  );
}
