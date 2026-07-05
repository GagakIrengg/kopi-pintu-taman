import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'tabs/intermediate_tab.dart';
import 'tabs/menu_recipe_tab.dart';

/// Halaman "Resep" dengan 2 tab:
///  - Bahan Olahan  (produk antara, mis. Shot Espresso)
///  - Resep Menu    (komposisi menu/add-on)
class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resep',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const Text(
            'Kelola Bahan Olahan & komposisi resep menu.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cream100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.coffee700,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.coffee700,
              tabs: const [
                Tab(text: 'Bahan Olahan'),
                Tab(text: 'Resep Menu'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                IntermediateTab(),
                MenuRecipeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
