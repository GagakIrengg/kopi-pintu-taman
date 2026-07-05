import 'package:flutter/material.dart';

import '../../../data/models/transaction.dart';

/// Hasil dialog void: preset alasan + catatan (keduanya wajib).
class VoidResult {
  final VoidReason reason;
  final String note;
  VoidResult(this.reason, this.note);
}

/// Dialog batalkan pesanan: pilih preset alasan (WAJIB) + catatan (WAJIB).
/// Mengembalikan VoidResult kalau dikonfirmasi, null kalau batal.
class VoidTransactionDialog extends StatefulWidget {
  final String invoiceLabel;
  const VoidTransactionDialog({super.key, required this.invoiceLabel});

  @override
  State<VoidTransactionDialog> createState() =>
      _VoidTransactionDialogState();
}

class _VoidTransactionDialogState extends State<VoidTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  VoidReason? _reason;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_reason == null) return;
    Navigator.of(context).pop(
      VoidResult(_reason!, _noteCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.cancel_outlined,
          color: Color(0xFFD9534F), size: 32),
      title: const Text('Batalkan Pesanan'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Membatalkan ${widget.invoiceLabel}. '
                'Transaksi tetap tersimpan untuk audit, tapi TIDAK '
                'dihitung di total penjualan. Stok tidak dikembalikan '
                'otomatis (atur manual bila perlu).',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VoidReason>(
                initialValue: _reason,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Alasan pembatalan (wajib)',
                  border: OutlineInputBorder(),
                ),
                items: VoidReason.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                validator: (v) =>
                    v == null ? 'Pilih alasan dulu' : null,
                onChanged: (v) => setState(() => _reason = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (wajib)',
                  hintText:
                      'Jelaskan detail kenapa transaksi dibatalkan...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Catatan wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Catatan terlalu pendek';
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
          child: const Text('Kembali'),
        ),
        FilledButton(
          style:
              FilledButton.styleFrom(backgroundColor: const Color(0xFFD9534F)),
          onPressed: _submit,
          child: const Text('Batalkan Transaksi'),
        ),
      ],
    );
  }
}
