import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/repository_providers.dart';

class HeldBillsScreen extends ConsumerWidget {
  const HeldBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final held = ref.watch(heldBillsProvider);
    final menuAsync = ref.watch(menuItemsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hold Bill',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const Text('Transaksi tersimpan sementara untuk dilanjutkan.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 14),
          Expanded(
            child: held.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Belum ada bill yang di-hold',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final tx = list[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.pause_circle_outline,
                                  color: AppColors.warning),
                              const SizedBox(width: 6),
                              Text(
                                  '#${tx.id.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(formatTime(tx.createdAt),
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 12)),
                            ]),
                            const SizedBox(height: 6),
                            if ((tx.customerName ?? '').isNotEmpty)
                              Text('Customer: ${tx.customerName}',
                                  style: const TextStyle(fontSize: 13)),
                            Text('${tx.items.length} item • ${formatRupiah(tx.total)}',
                                style: const TextStyle(
                                    color: AppColors.textMuted)),
                            const Spacer(),
                            Row(children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await ref
                                        .read(transactionRepositoryProvider)
                                        .delete(tx.id);
                                    ref.invalidate(heldBillsProvider);
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: menuAsync.maybeWhen(
                                    data: (menu) => () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .loadFromHeld(tx, menu);
                                      context.go('/pos');
                                    },
                                    orElse: () => null,
                                  ),
                                  child: const Text('Buka'),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
