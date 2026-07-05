import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';

Future<void> showReceiptDialog(BuildContext context, TransactionRecord tx) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Icon(Icons.check_circle,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 8),
              const Center(
                  child: Text('Transaksi Berhasil',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16))),
              const Divider(height: 24),
              const Center(
                  child: Text(AppConstants.shopName,
                      style: TextStyle(fontWeight: FontWeight.w700))),
              Center(
                  child: Text(AppConstants.shopAddress,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted))),
              const SizedBox(height: 6),
              Center(
                  child: Text(formatDateTime(tx.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted))),
              Center(
                  child: Text('No: ${tx.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted))),
              const Divider(),
              for (final i in tx.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i.quantity}x ${i.menuName}'
                              '${i.temperature != null ? ' (${i.temperature})' : ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Text(formatRupiah(i.lineTotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (i.addonNames.isNotEmpty)
                        Text('  + ${i.addonNames.join(', ')}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted)),
                      if ((i.notes ?? '').isNotEmpty)
                        Text('  ${i.notes}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textMuted)),
                    ],
                  ),
                ),
              const Divider(),
              _row('Total', formatRupiah(tx.total), bold: true),
              _row('Metode',
                  tx.paymentMethod == PaymentMethod.cash ? 'Cash' : 'QRIS'),
              if (tx.paymentMethod == PaymentMethod.cash) ...[
                _row('Diterima', formatRupiah(tx.cashReceived ?? 0)),
                _row('Kembalian', formatRupiah(tx.change)),
              ],
              if ((tx.customerName ?? '').isNotEmpty)
                _row('Customer', tx.customerName!),
              if ((tx.notes ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Notes: ${tx.notes}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ),
              const SizedBox(height: 12),
              const Center(
                  child: Text('-- Terima Kasih --',
                      style: TextStyle(fontSize: 12))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('Selesai'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _row(String l, String r, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(r,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
