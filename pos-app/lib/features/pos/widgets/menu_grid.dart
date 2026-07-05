import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item.dart';

class MenuGrid extends StatelessWidget {
  final List<MenuItem> items;
  final void Function(MenuItem) onTap;

  /// Kalau diisi, kartu "+ Custom Menu" tampil sebagai item pertama grid.
  final VoidCallback? onCustomTap;

  const MenuGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustom = onCustomTap != null;

    if (items.isEmpty && !hasCustom) {
      return const Center(
        child: Text('Tidak ada menu',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return LayoutBuilder(
      builder: (ctx, c) {
        final cross = c.maxWidth ~/ 180;
        // +1 slot di depan untuk kartu custom (kalau ada)
        final total = items.length + (hasCustom ? 1 : 0);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross.clamp(2, 6),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemCount: total,
          itemBuilder: (_, i) {
            if (hasCustom && i == 0) {
              return _CustomCard(onTap: onCustomTap!);
            }
            final item = items[hasCustom ? i - 1 : i];
            return _MenuCard(item: item, onTap: () => onTap(item));
          },
        );
      },
    );
  }
}

class _CustomCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CustomCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coffee700.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.coffee700.withValues(alpha: 0.5),
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline,
                  size: 34, color: AppColors.coffee700),
              SizedBox(height: 8),
              Text(
                'Custom Menu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.coffee700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  const _MenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cream100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_cafe_outlined,
                    color: AppColors.coffee700, size: 22),
              ),
              const Spacer(),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupiah(item.price),
                style: const TextStyle(
                    color: AppColors.coffee700,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}