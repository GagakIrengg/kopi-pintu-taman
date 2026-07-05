import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';

class PaymentResult {
  final PaymentMethod method;
  final int? cashReceived;
  PaymentResult(this.method, this.cashReceived);
}

Future<PaymentResult?> showPaymentDialog(
    BuildContext context, int total) async {
  return showDialog<PaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PaymentDialog(total: total),
  );
}

class _PaymentDialog extends StatefulWidget {
  final int total;
  const _PaymentDialog({required this.total});
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  PaymentMethod _method = PaymentMethod.cash;
  final _cashCtrl = TextEditingController();

  int get _cash =>
      int.tryParse(_cashCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _quick(int v) {
    _cashCtrl.text = v.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final change = _cash - widget.total;
    final canConfirm = _method == PaymentMethod.qris ||
        (_method == PaymentMethod.cash && _cash >= widget.total);

    return AlertDialog(
      title: const Text('Pembayaran'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: AppColors.textMuted)),
                  Text(formatRupiah(widget.total),
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.coffee700)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _MethodTile(
                  icon: Icons.payments,
                  label: 'Cash',
                  selected: _method == PaymentMethod.cash,
                  onTap: () => setState(() => _method = PaymentMethod.cash),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MethodTile(
                  icon: Icons.qr_code_2,
                  label: 'QRIS',
                  selected: _method == PaymentMethod.qris,
                  onTap: () => setState(() => _method = PaymentMethod.qris),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            if (_method == PaymentMethod.cash) ...[
              TextField(
                controller: _cashCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Uang diterima',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final v in [20000, 50000, 100000])
                  OutlinedButton(
                    onPressed: () => _quick(v),
                    child: Text(formatRupiah(v)),
                  ),
                OutlinedButton(
                  onPressed: () => _quick(widget.total),
                  child: const Text('Pas'),
                ),
              ]),
              const SizedBox(height: 10),
              if (_cash > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? AppColors.success.withOpacity(0.08)
                        : AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(change >= 0 ? 'Kembalian' : 'Kurang',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text(formatRupiah(change.abs()),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: change >= 0
                                  ? AppColors.success
                                  : AppColors.danger)),
                    ],
                  ),
                ),
            ] else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cream100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(children: [
                    Icon(Icons.qr_code_2,
                        size: 80, color: AppColors.coffee700),
                    SizedBox(height: 8),
                    Text('Tunjukkan QRIS ke customer'),
                  ]),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: canConfirm
              ? () => Navigator.pop(
                  context,
                  PaymentResult(
                      _method, _method == PaymentMethod.cash ? _cash : null))
              : null,
          child: const Text('Konfirmasi'),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.coffee700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.coffee700 : AppColors.border),
        ),
        child: Column(children: [
          Icon(icon,
              size: 28,
              color: selected ? Colors.white : AppColors.coffee700),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
