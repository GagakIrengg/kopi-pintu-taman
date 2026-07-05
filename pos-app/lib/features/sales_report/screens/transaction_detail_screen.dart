import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/repository_providers.dart';
import '../widgets/void_transaction_dialog.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  Future<TransactionRecord?>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = ref
          .read(transactionRepositoryProvider)
          .byId(widget.transactionId);
    });
  }

  Future<void> _doVoid(TransactionRecord tx) async {
    final result = await showDialog<VoidResult>(
      context: context,
      builder: (_) => VoidTransactionDialog(
        invoiceLabel:
            'Invoice #${tx.id.substring(0, 8).toUpperCase()}',
      ),
    );
    if (result == null) return;

    final by = ref.read(authProvider).username ?? 'kasir';
    await ref.read(transactionRepositoryProvider).voidTransaction(
          id: tx.id,
          reason: result.reason,
          note: result.note,
          by: by,
        );

    // Refresh Sales Report supaya angka langsung ter-update.
    ref.invalidate(salesInRangeProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi dibatalkan.')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TransactionRecord?>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData && snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final tx = snap.data;
        if (tx == null) {
          return const Center(child: Text('Transaksi tidak ditemukan'));
        }

        final isVoided = tx.status == TransactionStatus.voided;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                    onPressed: () => context.go('/reports'),
                    icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Invoice #${tx.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!isVoided)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Batalkan Pesanan'),
                    onPressed: () => _doVoid(tx),
                  ),
              ]),
              const SizedBox(height: 12),
              if (isVoided) _voidBanner(tx),
              if (isVoided) const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(children: [
                            const Text(AppConstants.shopName,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const Text(AppConstants.shopAddress,
                                style:
                                    TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Text(formatDateTime(tx.createdAt),
                                style: const TextStyle(
                                    color: AppColors.textMuted)),
                            if (isVoided) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.danger
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'TRANSAKSI DIBATALKAN',
                                  style: TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ]),
                        ),
                        const Divider(height: 24),
                        for (final i in tx.items)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      '${i.quantity}x ${i.menuName}'
                                      '${i.temperature != null ? '  (${i.temperature})' : ''}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: isVoided
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                        color: isVoided
                                            ? AppColors.textMuted
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Text(formatRupiah(i.lineTotal),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: isVoided
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                        color: isVoided
                                            ? AppColors.textMuted
                                            : null,
                                      )),
                                ]),
                                if (i.addonNames.isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 12),
                                    child: Text(
                                        '+ ${i.addonNames.join(', ')}',
                                        style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12)),
                                  ),
                                if ((i.notes ?? '').isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 12),
                                    child: Text(i.notes!,
                                        style: const TextStyle(
                                            fontStyle:
                                                FontStyle.italic,
                                            color: AppColors.textMuted,
                                            fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                        const Divider(height: 24),
                        _r('Total', formatRupiah(tx.total), bold: true),
                        _r(
                            'Metode',
                            tx.paymentMethod == PaymentMethod.cash
                                ? 'Cash'
                                : 'QRIS'),
                        if (tx.paymentMethod == PaymentMethod.cash) ...[
                          _r('Diterima',
                              formatRupiah(tx.cashReceived ?? 0)),
                          _r('Kembalian', formatRupiah(tx.change)),
                        ],
                        if ((tx.customerName ?? '').isNotEmpty)
                          _r('Customer', tx.customerName!),
                        if ((tx.notes ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Notes: ${tx.notes}',
                              style: const TextStyle(
                                  color: AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _voidBanner(TransactionRecord tx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cancel, color: AppColors.danger, size: 20),
              SizedBox(width: 8),
              Text('TRANSAKSI DIBATALKAN',
                  style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          _kv('Alasan', tx.voidReasonEnum?.label ?? '-'),
          _kv('Catatan', tx.voidNote ?? '-'),
          _kv(
              'Dibatalkan',
              tx.voidedAt == null
                  ? '-'
                  : formatDateTime(tx.voidedAt!)),
          _kv('Oleh', tx.voidedBy ?? '-'),
        ],
      ),
    );
  }

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 90,
                child: Text(k,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
      );

  static Widget _r(String l, String r, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.w400)),
            Text(r,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      );
}
