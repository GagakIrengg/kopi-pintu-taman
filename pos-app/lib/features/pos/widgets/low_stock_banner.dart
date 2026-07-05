import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/low_stock_provider.dart';

/// Banner peringatan stok rendah/habis untuk ditampilkan di atas POS screen.
/// Otomatis tersembunyi jika tidak ada bahan low/out (return SizedBox.shrink).
class LowStockBanner extends ConsumerWidget {
  const LowStockBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final low = ref.watch(lowStockItemsProvider);
    if (low.isEmpty) return const SizedBox.shrink();

    final outCount = low.where((i) => i.stock <= 0).length;
    final lowCount = low.length - outCount;

    String message;
    if (outCount > 0 && lowCount > 0) {
      message =
          '$outCount bahan habis, $lowCount lainnya stok rendah. Restock segera.';
    } else if (outCount > 0) {
      message = '$outCount bahan habis. Restock segera.';
    } else {
      message = '$lowCount bahan stoknya rendah. Pertimbangkan restock.';
    }

    return Material(
      color: AppColors.warning.withValues(alpha: 0.12),
      child: InkWell(
        onTap: () => GoRouter.of(context).go('/inventory'),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.warning, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning),
                ),
              ),
              const Text('Buka Inventory →',
                  style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
