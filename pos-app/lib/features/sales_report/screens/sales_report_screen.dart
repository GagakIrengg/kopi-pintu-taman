import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/data_providers.dart';

/// Sales Report — fokus Riwayat Transaksi.
/// Grafik penjualan menu sudah dipindah ke Dashboard/Laporan.
class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range      = ref.watch(salesRangeProvider);
    final salesAsync = ref.watch(salesInRangeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sales Report',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    Text('Riwayat transaksi & ringkasan penjualan.',
                        style:
                            TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.today, size: 16),
                label: const Text('Hari Ini'),
                onPressed: () {
                  final now = DateTime.now();
                  ref.read(salesRangeProvider.notifier).state =
                      DateRange(
                    DateTime(now.year, now.month, now.day),
                    DateTime(
                        now.year, now.month, now.day, 23, 59, 59),
                  );
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                    '${formatDate(range.from)}  →  ${formatDate(range.to)}'),
                onPressed: () => _pickRange(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: salesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (txs) {
                final paid = txs
                    .where(
                        (t) => t.status == TransactionStatus.paid)
                    .toList();
                final voided = txs
                    .where(
                        (t) => t.status == TransactionStatus.voided)
                    .toList();

                final total =
                    paid.fold<int>(0, (s, t) => s + t.total);
                final cash = paid
                    .where((t) =>
                        t.paymentMethod == PaymentMethod.cash)
                    .fold<int>(0, (s, t) => s + t.total);
                final qris = paid
                    .where((t) =>
                        t.paymentMethod == PaymentMethod.qris)
                    .fold<int>(0, (s, t) => s + t.total);
                final voidValue =
                    voided.fold<int>(0, (s, t) => s + t.total);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stat Cards ──────────────────────────────
                    Row(children: [
                      _StatCard(
                          icon: Icons.payments_outlined,
                          label: 'Total Revenue',
                          value: formatRupiah(total),
                          color: AppColors.coffee700),
                      _StatCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Transaksi',
                          value: '${paid.length}',
                          color: AppColors.success),
                      _StatCard(
                          icon:
                              Icons.account_balance_wallet_outlined,
                          label: 'Cash',
                          value: formatRupiah(cash),
                          color: AppColors.warning),
                      _StatCard(
                          icon: Icons.qr_code_2,
                          label: 'QRIS',
                          value: formatRupiah(qris),
                          color: AppColors.coffee500),
                      _StatCard(
                          icon: Icons.cancel_outlined,
                          label: 'Dibatalkan',
                          value:
                              '${voided.length}  (${formatRupiah(voidValue)})',
                          color: AppColors.danger),
                    ]),
                    const SizedBox(height: 16),

                    // ── Riwayat Transaksi ───────────────────────
                    Expanded(
                      child: Card(
                        child: txs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada transaksi pada rentang ini',
                                  style: TextStyle(
                                      color: AppColors.textMuted),
                                ),
                              )
                            : ListView.separated(
                                itemCount: txs.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final t = txs[i];
                                  final isVoided = t.status ==
                                      TransactionStatus.voided;
                                  final shortId =
                                      '#${t.id.substring(0, min(6, t.id.length)).toUpperCase()}';
                                  return ListTile(
                                    title: Row(children: [
                                      Flexible(
                                        child: Text(
                                          '$shortId • ${formatRupiah(t.total)}',
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
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
                                      if (isVoided) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger
                                                .withValues(
                                                    alpha: 0.12),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(20),
                                          ),
                                          child: const Text(
                                            'DIBATALKAN',
                                            style: TextStyle(
                                              color: AppColors.danger,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ]),
                                    subtitle: Text(
                                      isVoided
                                          ? '${formatDateTime(t.createdAt)} • ${t.voidReasonEnum?.label ?? 'Dibatalkan'}'
                                          : '${formatDateTime(t.createdAt)} • ${t.paymentMethod?.name.toUpperCase() ?? '-'} • ${t.items.length} item',
                                    ),
                                    trailing:
                                        const Icon(Icons.chevron_right),
                                    onTap: () => context
                                        .go('/reports/${t.id}'),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final r = ref.read(salesRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: r.from, end: r.to),
    );
    if (picked == null) return;
    ref.read(salesRangeProvider.notifier).state = DateRange(
      DateTime(picked.start.year, picked.start.month,
          picked.start.day),
      DateTime(picked.end.year, picked.end.month, picked.end.day,
          23, 59, 59),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );
}