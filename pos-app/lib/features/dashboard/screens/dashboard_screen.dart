import 'dart:math' show min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/menu_item.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/data_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // 'today' | 'week' | 'month' | 'custom'
  String _filter = 'week';

  static const _palette = <Color>[
    AppColors.coffee700,
    AppColors.coffee500,
    AppColors.warning,
    AppColors.success,
    Color(0xFFB07C5B),
    Color(0xFF8E6E5A),
    Color(0xFFD9A06B),
    Color(0xFFA0826D),
  ];

  @override
  void initState() {
    super.initState();
    // Set default ke Minggu Ini saat pertama buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter('week');
    });
  }

  void _applyFilter(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateRange range;
    switch (filter) {
      case 'today':
        range = DateRange(
          today,
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 'week':
        final monday =
            today.subtract(Duration(days: today.weekday - 1));
        range = DateRange(
          monday,
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 'month':
        range = DateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      default:
        return; // 'custom' ditangani lewat date picker
    }
    ref.read(salesRangeProvider.notifier).state = range;
    setState(() => _filter = filter);
  }

  Future<void> _pickCustomRange() async {
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
    setState(() => _filter = 'custom');
  }

  Color _barColor(int i) => switch (i) {
        0 => AppColors.coffee700,
        1 => AppColors.coffee500,
        2 => AppColors.warning,
        _ => AppColors.coffee700.withValues(alpha: 0.45),
      };

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(salesRangeProvider);
    final salesAsync = ref.watch(salesInRangeProvider);
    final invAsync = ref.watch(inventoryProvider);
    final menusAsync = ref.watch(menuItemsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + Filter Buttons ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laporan / Dashboard',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    Text(
                      'Ringkasan ${formatDate(range.from)} → ${formatDate(range.to)}',
                      style:
                          const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // ── Filter Buttons ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color:
                      AppColors.coffee700.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterBtn(
                      label: 'Hari Ini',
                      selected: _filter == 'today',
                      onTap: () => _applyFilter('today'),
                    ),
                    _FilterBtn(
                      label: 'Minggu Ini',
                      selected: _filter == 'week',
                      onTap: () => _applyFilter('week'),
                    ),
                    _FilterBtn(
                      label: 'Bulan Ini',
                      selected: _filter == 'month',
                      onTap: () => _applyFilter('month'),
                    ),
                    _FilterBtn(
                      label: 'Pilih Tanggal',
                      icon: Icons.calendar_today,
                      selected: _filter == 'custom',
                      onTap: _pickCustomRange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: salesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              data: (txs) {
                final paid = txs
                    .where(
                        (t) => t.status == TransactionStatus.paid)
                    .toList();
                final voided = txs
                    .where(
                        (t) => t.status == TransactionStatus.voided)
                    .toList();

                final revenue =
                    paid.fold<int>(0, (s, t) => s + t.total);
                final voidValue =
                    voided.fold<int>(0, (s, t) => s + t.total);
                final itemsSold = paid.fold<int>(
                    0,
                    (s, t) => s +
                        t.items.fold<int>(
                            0, (a, i) => a + i.quantity));
                final avg = paid.isEmpty
                    ? 0
                    : (revenue / paid.length).round();

                // Agregasi penjualan per menu
                final Map<String, int> sold = {};
                final Map<String, int> soldRev = {};
                for (final t in paid) {
                  for (final i in t.items) {
                    if (i.menuItemId == 'custom') continue;
                    sold.update(i.menuName,
                        (v) => v + i.quantity,
                        ifAbsent: () => i.quantity);
                    soldRev.update(i.menuName,
                        (v) => v + i.lineTotal,
                        ifAbsent: () => i.lineTotal);
                  }
                }
                final topMenu = sold.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final topSales = topMenu.take(10).toList();

                // Kategori
                final menus =
                    menusAsync.valueOrNull ?? <MenuItem>[];
                final menuById = {for (final m in menus) m.id: m};

                final lowStock =
                    (invAsync.valueOrNull ?? <InventoryItem>[])
                        .where((i) =>
                            i.status == StockStatus.low ||
                            i.status == StockStatus.out)
                        .toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ===== 1. GRAFIK PENJUALAN MENU (TOP) =====
                      _SectionCard(
                        title: 'Grafik Penjualan Menu',
                        child: topSales.isEmpty
                            ? const _Empty(
                                'Belum ada data penjualan')
                            : _MenuBarChart(
                                topSales: topSales,
                                soldRev: soldRev,
                                barColor: _barColor,
                              ),
                      ),
                      const SizedBox(height: 16),

                      // ===== 2. MENU TERLARIS TOP 5 =============
                      _SectionCard(
                        title: 'Menu Terlaris',
                        child: topMenu.isEmpty
                            ? const _Empty(
                                'Belum ada penjualan pada rentang ini')
                            : Column(
                                children: [
                                  for (var i = 0;
                                      i < min(5, topMenu.length);
                                      i++)
                                    ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            AppColors.cream100,
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: AppColors
                                                  .coffee700),
                                        ),
                                      ),
                                      title:
                                          Text(topMenu[i].key),
                                      trailing: Text(
                                        '${topMenu[i].value} terjual',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w700),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),

                      // ===== 3. STAT CARDS ======================
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _Stat(
                              'Revenue',
                              formatRupiah(revenue),
                              Icons.payments_outlined,
                              AppColors.coffee700),
                          _Stat(
                              'Transaksi',
                              '${paid.length}',
                              Icons.receipt_long_outlined,
                              AppColors.success),
                          _Stat(
                              'Item Terjual',
                              '$itemsSold',
                              Icons.shopping_basket_outlined,
                              AppColors.coffee500),
                          _Stat(
                              'Rata-rata/Transaksi',
                              formatRupiah(avg),
                              Icons.trending_up,
                              AppColors.warning),
                          _Stat(
                              'Dibatalkan',
                              '${voided.length} (${formatRupiah(voidValue)})',
                              Icons.cancel_outlined,
                              AppColors.danger),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ===== 4. LINE CHART: PENJUALAN/TANGGAL ==
                      _SectionCard(
                        title: 'Penjualan per Tanggal',
                        child: _SalesLineChart(
                            paid: paid, range: range),
                      ),
                      const SizedBox(height: 16),

                      // ===== 5. DONUT: TOTAL PER KATEGORI ======
                      _SectionCard(
                        title: 'Penjualan per Kategori',
                        child: _CategoryDonutTotal(
                          paid: paid,
                          menuById: menuById,
                          palette: _palette,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== 6. DONUT PER KATEGORI DETAIL ======
                      _CategoryBreakdown(
                        paid: paid,
                        menuById: menuById,
                        palette: _palette,
                      ),
                      const SizedBox(height: 16),

                      // ===== 7. BAHAN PERLU RESTOCK ============
                      _SectionCard(
                        title:
                            'Bahan Perlu Restock (${lowStock.length})',
                        child: lowStock.isEmpty
                            ? const _Empty('Semua stok aman 👍')
                            : Column(
                                children: [
                                  for (final it in lowStock)
                                    ListTile(
                                      dense: true,
                                      leading: Icon(
                                        it.status == StockStatus.out
                                            ? Icons.cancel
                                            : Icons.warning,
                                        color: it.status ==
                                                StockStatus.out
                                            ? AppColors.danger
                                            : AppColors.warning,
                                        size: 20,
                                      ),
                                      title: Text(it.name),
                                      trailing: Text(
                                        '${it.stock.toStringAsFixed(0)} ${it.unit}',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BAR CHART: Menu Terjual (embedded di dashboard)
// ============================================================
class _MenuBarChart extends StatelessWidget {
  final List<MapEntry<String, int>> topSales;
  final Map<String, int> soldRev;
  final Color Function(int) barColor;
  const _MenuBarChart({
    required this.topSales,
    required this.soldRev,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = topSales.first.value.toDouble() * 1.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar Chart
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipColor: (_) =>
                      AppColors.coffee700.withValues(alpha: 0.95),
                  getTooltipItem:
                      (group, groupIndex, rod, rodIndex) {
                    final name = topSales[group.x].key;
                    final qty = rod.toY.toInt();
                    return BarTooltipItem(
                      '$name\n$qty pcs',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= topSales.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: barColor(i)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(
                  show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(topSales.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: topSales[i].value.toDouble(),
                      color: barColor(i),
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 6),
        // Legend table
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SizedBox(width: 28),
              Expanded(
                flex: 3,
                child: Text('Menu',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ),
              SizedBox(
                width: 70,
                child: Text('Terjual',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ),
              SizedBox(
                width: 110,
                child: Text('Revenue',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < topSales.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: barColor(i))),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: barColor(i),
                      borderRadius: BorderRadius.circular(2)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(topSales[i].key,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${topSales[i].value} pcs',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: barColor(i)),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    formatRupiah(soldRev[topSales[i].key] ?? 0),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
// FILTER BUTTON
// ============================================================
class _FilterBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterBtn({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.coffee700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : AppColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: selected
                    ? Colors.white
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LINE CHART: Penjualan per Tanggal
// ============================================================
class _SalesLineChart extends StatelessWidget {
  final List<TransactionRecord> paid;
  final DateRange range;
  const _SalesLineChart({required this.paid, required this.range});

  @override
  Widget build(BuildContext context) {
    final fromDay = DateTime(
        range.from.year, range.from.month, range.from.day);
    final toDay =
        DateTime(range.to.year, range.to.month, range.to.day);
    final days = <DateTime>[];
    for (var d = fromDay;
        !d.isAfter(toDay);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final Map<String, int> byDay = {};
    String keyOf(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    for (final d in days) byDay[keyOf(d)] = 0;
    for (final t in paid) {
      final k = keyOf(t.createdAt);
      if (byDay.containsKey(k)) byDay[k] = (byDay[k] ?? 0) + t.total;
    }

    if (paid.isEmpty || days.isEmpty) {
      return const _Empty('Belum ada penjualan pada rentang ini');
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < days.length; i++) {
      spots.add(
          FlSpot(i.toDouble(), (byDay[keyOf(days[i])] ?? 0).toDouble()));
    }

    final maxY = spots
        .map((s) => s.y)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMaxY = maxY == 0 ? 1000.0 : (maxY * 1.15);
    final xLabelInterval = days.length <= 7
        ? 1.0
        : days.length <= 14
            ? 2.0
            : days.length <= 31
                ? 4.0
                : (days.length / 8).ceilToDouble();

    return SizedBox(
      height: 260,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 12),
        child: LineChart(LineChartData(
          minY: 0,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: xLabelInterval,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox();
                  final d = days[i];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${d.day}/${d.month}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final v = value.toInt();
                  final label = v >= 1000000
                      ? '${(v / 1000000).toStringAsFixed(1)}M'
                      : v >= 1000
                          ? '${(v / 1000).toStringAsFixed(0)}K'
                          : '$v';
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: AppColors.border),
              left: BorderSide(color: AppColors.border),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.coffee800,
              getTooltipItems: (spots) => spots.map((s) {
                final i = s.x.toInt();
                final d = days[i];
                return LineTooltipItem(
                  '${d.day}/${d.month} • ${formatRupiah(s.y.toInt())}',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: AppColors.coffee700,
              barWidth: 2.5,
              dotData: FlDotData(
                show: days.length <= 14,
                getDotPainter: (spot, _, __, ___) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.coffee700,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.coffee700.withValues(alpha: 0.12),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

// ============================================================
// DONUT: Total per Kategori
// ============================================================
class _CategoryDonutTotal extends StatelessWidget {
  final List<TransactionRecord> paid;
  final Map<String, MenuItem> menuById;
  final List<Color> palette;
  const _CategoryDonutTotal(
      {required this.paid,
      required this.menuById,
      required this.palette});

  @override
  Widget build(BuildContext context) {
    final Map<MenuCategory, int> byCat = {};
    for (final t in paid) {
      for (final i in t.items) {
        if (i.menuItemId == 'custom') continue;
        final m = menuById[i.menuItemId];
        if (m == null || m.category == MenuCategory.addon) continue;
        byCat.update(m.category, (v) => v + i.quantity,
            ifAbsent: () => i.quantity);
      }
    }
    if (byCat.isEmpty) {
      return const _Empty(
          'Belum ada penjualan kategori pada rentang ini');
    }
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final color = palette[i % palette.length];
      final percent = total == 0 ? 0.0 : (e.value / total * 100);
      sections.add(PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: percent < 3 ? '' : '${e.value}',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white),
      ));
    }
    return Column(children: [
      SizedBox(
        height: 220,
        child: PieChart(PieChartData(
          sections: sections,
          centerSpaceRadius: 50,
          sectionsSpace: 2,
          startDegreeOffset: -90,
        )),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < entries.length; i++)
            _LegendDot(
              color: palette[i % palette.length],
              label: '${entries[i].key.label} (${entries[i].value})',
            ),
        ],
      ),
    ]);
  }
}

// ============================================================
// BREAKDOWN PER KATEGORI
// ============================================================
class _CategoryBreakdown extends StatelessWidget {
  final List<TransactionRecord> paid;
  final Map<String, MenuItem> menuById;
  final List<Color> palette;
  const _CategoryBreakdown(
      {required this.paid,
      required this.menuById,
      required this.palette});

  @override
  Widget build(BuildContext context) {
    final Map<MenuCategory, Map<String, int>> byCatMenu = {};
    for (final t in paid) {
      for (final i in t.items) {
        if (i.menuItemId == 'custom') continue;
        final m = menuById[i.menuItemId];
        if (m == null || m.category == MenuCategory.addon) continue;
        final perMenu = byCatMenu.putIfAbsent(m.category, () => {});
        perMenu.update(i.menuName, (v) => v + i.quantity,
            ifAbsent: () => i.quantity);
      }
    }
    if (byCatMenu.isEmpty) return const SizedBox.shrink();
    final cats = byCatMenu.keys.toList()
      ..sort((a, b) {
        final ta = byCatMenu[a]!.values.fold<int>(0, (s, v) => s + v);
        final tb = byCatMenu[b]!.values.fold<int>(0, (s, v) => s + v);
        return tb.compareTo(ta);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cat in cats) ...[
          _SectionCard(
            title: '${cat.label}',
            child: _SingleCategoryDonut(
                menuQty: byCatMenu[cat]!, palette: palette),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SingleCategoryDonut extends StatelessWidget {
  final Map<String, int> menuQty;
  final List<Color> palette;
  const _SingleCategoryDonut(
      {required this.menuQty, required this.palette});

  @override
  Widget build(BuildContext context) {
    final entries = menuQty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    if (entries.isEmpty || total == 0) {
      return const _Empty('Belum ada penjualan');
    }
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final color = palette[i % palette.length];
      final percent = (e.value / total * 100);
      sections.add(PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: percent < 5 ? '' : '${e.value}',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white),
      ));
    }
    return Column(children: [
      SizedBox(
        height: 180,
        child: PieChart(PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          startDegreeOffset: -90,
        )),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < entries.length; i++)
            _LegendDot(
              color: palette[i % palette.length],
              label: '${entries[i].key} (${entries[i].value})',
              small: true,
            ),
        ],
      ),
    ]);
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool small;
  const _LegendDot(
      {required this.color, required this.label, this.small = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 8 : 10,
            height: small ? 8 : 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: small ? 11 : 12,
                  color: AppColors.textPrimary)),
        ],
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const Divider(),
              child,
            ],
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(text,
              style: const TextStyle(color: AppColors.textMuted)),
        ),
      );
}