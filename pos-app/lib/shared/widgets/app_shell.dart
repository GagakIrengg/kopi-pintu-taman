import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/inventory_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/low_stock_provider.dart';
import '../../services/connectivity_service.dart';

/// Layout shell dengan collapsible sidebar (rail) untuk tablet landscape.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _expanded = false;

  static const _items = [
    _NavItem('/pos', Icons.point_of_sale_outlined, 'POS'),
    _NavItem('/reports', Icons.receipt_long_outlined, 'Sales Reports'),
    _NavItem('/inventory', Icons.inventory_2_outlined, 'Inventory'),
    _NavItem('/cash', Icons.attach_money, 'Kas'),
    _NavItem('/dashboard', Icons.dashboard, 'Laporan'),
    _NavItem('/settings', Icons.settings_outlined, 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowLowStockDialog();
    });
  }

  Future<void> _maybeShowLowStockDialog() async {
    if (!mounted) return;
    if (ref.read(lowStockDialogShownProvider)) return;

    List<InventoryItem> items;
    final current = ref.read(inventoryProvider);
    if (current.hasValue) {
      items = current.value!;
    } else {
      try {
        items = await ref.read(inventoryProvider.future);
      } catch (_) {
        return;
      }
    }
    if (!mounted) return;

    final low = items
        .where((i) =>
            i.status == StockStatus.low || i.status == StockStatus.out)
        .toList();
    if (low.isEmpty) return;

    ref.read(lowStockDialogShownProvider.notifier).state = true;
    if (!mounted) return;
    _showLowStockDialog(context, low);
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final selected = _items.indexWhere((i) => loc.startsWith(i.path));
    final user = ref.watch(authProvider).username ?? 'Kasir';
    final lowCount = ref.watch(lowStockItemsProvider).length;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(
              expanded: _expanded,
              items: _items,
              selectedIndex: selected < 0 ? 0 : selected,
              badges: {'/inventory': lowCount},
              onToggle: () => setState(() => _expanded = !_expanded),
              onLogout: () {
                ref.read(lowStockDialogShownProvider.notifier).state = false;
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              user: user,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  const _TopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, List<InventoryItem> low) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.warning, size: 36),
        title: const Text('Stok Bahan Perlu Restock'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${low.length} bahan saat ini di bawah atau sama dengan stok minimum:'),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: low.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = low[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        it.status == StockStatus.out
                            ? Icons.cancel
                            : Icons.warning,
                        color: it.status == StockStatus.out
                            ? AppColors.danger
                            : AppColors.warning,
                      ),
                      title: Text(it.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Stok: ${it.stock.toStringAsFixed(0)} ${it.unit} '
                        '(min: ${it.minStock.toStringAsFixed(0)} ${it.unit})',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Nanti Saja'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              GoRouter.of(context).go('/inventory');
            },
            child: const Text('Buka Inventory'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;
  const _NavItem(this.path, this.icon, this.label);
}

class _Sidebar extends StatelessWidget {
  final bool expanded;
  final List<_NavItem> items;
  final int selectedIndex;
  final Map<String, int> badges;
  final VoidCallback onToggle;
  final VoidCallback onLogout;
  final String user;
  const _Sidebar({
    required this.expanded,
    required this.items,
    required this.selectedIndex,
    required this.badges,
    required this.onToggle,
    required this.onLogout,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final width = expanded ? 220.0 : 76.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.coffee700,
                radius: 18,
                child: Icon(Icons.coffee, color: Colors.white, size: 18),
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('KPT POS',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(expanded ? Icons.chevron_left : Icons.chevron_right),
            onPressed: onToggle,
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            _NavTile(
              item: items[i],
              expanded: expanded,
              selected: i == selectedIndex,
              badge: badges[items[i].path] ?? 0,
              onTap: () => GoRouter.of(context).go(items[i].path),
            ),
          const Spacer(),
          const Divider(height: 1),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(user,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
          _NavTile(
            item: const _NavItem('/logout', Icons.logout, 'Logout'),
            expanded: expanded,
            selected: false,
            badge: 0,
            onTap: onLogout,
            danger: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool expanded;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  final bool danger;
  const _NavTile({
    required this.item,
    required this.expanded,
    required this.selected,
    required this.badge,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.danger
        : (selected ? AppColors.coffee700 : AppColors.textMuted);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.cream100 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _IconWithBadge(icon: item.icon, color: color, badge: badge),
            if (expanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.label,
                    style: TextStyle(
                      color: color,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    )),
              ),
              if (badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int badge;
  const _IconWithBadge({
    required this.icon,
    required this.color,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    if (badge <= 0) return Icon(icon, color: color, size: 22);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: color, size: 22),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              badge.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).maybeWhen(
        data: (v) => v, orElse: () => SyncStatus.offline);
    final (label, color, icon) = switch (status) {
      SyncStatus.online => ('Online', AppColors.success, Icons.cloud_done),
      SyncStatus.offline => (
          'Offline',
          AppColors.textMuted,
          Icons.cloud_off
        ),
      SyncStatus.pendingSync => (
          'Pending Sync',
          AppColors.warning,
          Icons.sync
        ),
    };

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text('Cafe Kopi Pintu Taman',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}