import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/inventory_item.dart';
import '../../../../data/models/intermediate_product.dart';
import '../../../../data/models/menu_item.dart';
import '../../../../data/models/menu_recipe.dart';
import '../../../../providers/data_providers.dart';
import '../../../../providers/recipe_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../widgets/add_menu_component_dialog.dart';

/// Tab "Resep Menu" — layout MASTER-DETAIL.
///  - Kiri  : daftar menu dikelompokkan per kategori + search
///  - Kanan : resep menu yang dipilih (langsung muncul, tanpa dropdown)
class MenuRecipeTab extends ConsumerStatefulWidget {
  const MenuRecipeTab({super.key});

  @override
  ConsumerState<MenuRecipeTab> createState() => _MenuRecipeTabState();
}

class _MenuRecipeTabState extends ConsumerState<MenuRecipeTab> {
  MenuItem? _selected;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuItemsProvider);

    return menuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (menus) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== MASTER (kiri) =====
            SizedBox(
              width: 300,
              child: _MenuListPanel(
                menus: menus,
                selected: _selected,
                searchCtrl: _searchCtrl,
                onSearchChanged: () => setState(() {}),
                onSelect: (m) => setState(() => _selected = m),
              ),
            ),
            const VerticalDivider(width: 1),
            // ===== DETAIL (kanan) =====
            Expanded(
              child: _selected == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Pilih menu di daftar kiri\n'
                          'untuk melihat & mengatur resepnya.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : _RecipeDetailPanel(
                      key: ValueKey(_selected!.id),
                      menu: _selected!,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Panel kiri: search + list menu dikelompokkan per kategori.
class _MenuListPanel extends StatelessWidget {
  final List<MenuItem> menus;
  final MenuItem? selected;
  final TextEditingController searchCtrl;
  final VoidCallback onSearchChanged;
  final ValueChanged<MenuItem> onSelect;

  const _MenuListPanel({
    required this.menus,
    required this.selected,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final q = searchCtrl.text.trim().toLowerCase();

    // filter by search
    final filtered = q.isEmpty
        ? menus
        : menus
            .where((m) => m.name.toLowerCase().contains(q))
            .toList();

    // group by category, urutkan sesuai urutan enum MenuCategory
    final grouped = <MenuCategory, List<MenuItem>>{};
    for (final m in filtered) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    final orderedCats = MenuCategory.values
        .where((c) => grouped.containsKey(c))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: searchCtrl,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Menu tidak ditemukan.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView(
                  children: [
                    for (final cat in orderedCats) ...[
                      Container(
                        width: double.infinity,
                        color: AppColors.cream100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Text(
                          cat.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...grouped[cat]!.map((m) {
                        final isSel = selected?.id == m.id;
                        return Material(
                          color: isSel
                              ? AppColors.coffee700
                                  .withValues(alpha: 0.10)
                              : Colors.transparent,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              m.name,
                              style: TextStyle(
                                fontWeight: isSel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSel
                                    ? AppColors.coffee700
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              m.isAddon
                                  ? 'Add-on'
                                  : _tempName(m.temperature),
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: isSel
                                ? const Icon(Icons.chevron_right,
                                    color: AppColors.coffee700)
                                : null,
                            onTap: () => onSelect(m),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  String _tempName(MenuTemperature t) => switch (t) {
        MenuTemperature.hot => 'Hot',
        MenuTemperature.iced => 'Iced',
        MenuTemperature.both => 'Hot / Iced',
        MenuTemperature.none => 'Tanpa suhu',
      };
}

/// Panel kanan: judul menu + editor resep (reuse logic TAHAP 3).
class _RecipeDetailPanel extends StatelessWidget {
  final MenuItem menu;
  const _RecipeDetailPanel({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${menu.isAddon ? 'Add-on · ' : ''}'
                      '${_tempName(menu.temperature)}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _RecipeEditor(menu: menu)),
        ],
      ),
    );
  }

  String _tempName(MenuTemperature t) => switch (t) {
        MenuTemperature.hot => 'Disajikan Hot',
        MenuTemperature.iced => 'Disajikan Iced',
        MenuTemperature.both => 'Bisa Hot / Iced (resep terpisah)',
        MenuTemperature.none => 'Tanpa suhu',
      };
}

/// Editor resep untuk 1 menu. Kalau 'both' -> sub-tab HOT & ICED.
/// (Logika sama persis dengan TAHAP 3, hanya dipindah ke master-detail.)
class _RecipeEditor extends ConsumerWidget {
  final MenuItem menu;
  const _RecipeEditor({required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (menu.temperature == MenuTemperature.both) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cream100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TabBar(
                labelColor: AppColors.coffee700,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.coffee700,
                tabs: [Tab(text: 'HOT'), Tab(text: 'ICED')],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _ComponentList(menu: menu, temp: RecipeTemp.hot),
                  _ComponentList(menu: menu, temp: RecipeTemp.iced),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final temp = switch (menu.temperature) {
      MenuTemperature.hot => RecipeTemp.hot,
      MenuTemperature.iced => RecipeTemp.iced,
      _ => RecipeTemp.all,
    };
    return _ComponentList(menu: menu, temp: temp);
  }
}

/// Daftar komponen resep untuk 1 menu pada 1 temperature.
class _ComponentList extends ConsumerWidget {
  final MenuItem menu;
  final String temp; // 'hot' | 'iced' | 'all'
  const _ComponentList({required this.menu, required this.temp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(menuRecipeProvider(menu.id));
    final invAsync = ref.watch(inventoryProvider);
    final intAsync = ref.watch(intermediatesProvider);

    return recipeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allRows) {
        final rows =
            allRows.where((r) => r.temperature == temp).toList();
        final inv = invAsync.valueOrNull ?? <InventoryItem>[];
        final ints = intAsync.valueOrNull ?? <IntermediateProduct>[];

        String labelOf(MenuRecipe r) {
          if (r.componentType == RecipeComponentType.ingredient) {
            final m = inv.where((e) => e.id == r.componentId);
            return m.isEmpty
                ? '(bahan terhapus)'
                : '${m.first.name} — ${_fmt(r.quantity)} ${m.first.unit}';
          } else {
            final m = ints.where((e) => e.id == r.componentId);
            return m.isEmpty
                ? '(bahan olahan terhapus)'
                : '${m.first.name} — ${_fmt(r.quantity)} ${m.first.unit}';
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Text(
                        '⚠️ Resep belum diisi untuk bagian ini.',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = rows[i];
                        final isInt = r.componentType ==
                            RecipeComponentType.intermediate;
                        return ListTile(
                          leading: Icon(
                            isInt ? Icons.blender : Icons.grass,
                            color: AppColors.coffee700,
                            size: 20,
                          ),
                          title: Text(labelOf(r)),
                          subtitle: Text(
                            isInt ? 'Bahan Olahan' : 'Bahan Mentah',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            onPressed: () async {
                              await ref
                                  .read(recipeRepositoryProvider)
                                  .deleteMenuRecipeRow(r.id);
                              ref.invalidate(
                                  menuRecipeProvider(menu.id));
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Komponen'),
                onPressed: () => _add(context, ref, rows),
              ),
            ),
          ],
        );
      },
    );
  }

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toString();

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    List<MenuRecipe> existing,
  ) async {
    final excluded = existing
        .map((r) => '${r.componentType.name}:${r.componentId}')
        .toSet();
    final tempLabel = switch (temp) {
      RecipeTemp.hot => 'Hot',
      RecipeTemp.iced => 'Iced',
      _ => '-',
    };

    final result = await showDialog<AddMenuComponentResult>(
      context: context,
      builder: (_) => AddMenuComponentDialog(
        menuName: menu.name,
        tempLabel: tempLabel,
        excludedKeys: excluded,
      ),
    );
    if (result == null) return;

    await ref.read(recipeRepositoryProvider).upsertMenuRecipe(
          MenuRecipe(
            id: const Uuid().v4(),
            menuId: menu.id,
            componentType: result.type,
            componentId: result.componentId,
            temperature: temp,
            quantity: result.quantity,
          ),
        );
    ref.invalidate(menuRecipeProvider(menu.id));
  }
}
