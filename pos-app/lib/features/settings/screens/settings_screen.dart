import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).username ?? '-';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // ===== Pengelolaan (dipindah dari sidebar) =====
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 4),
            child: Text('Pengelolaan',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.restaurant_menu_outlined),
                  title: const Text('Manajemen Menu'),
                  subtitle: const Text(
                      'Tambah, ubah, hapus daftar menu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/menu-management'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.blender_outlined),
                  title: const Text('Resep'),
                  subtitle: const Text(
                      'Bahan Olahan & komposisi resep menu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/recipe'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Info =====
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 4),
            child: Text('Info',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store_outlined),
                  title: const Text('Toko'),
                  subtitle: const Text(AppConstants.shopName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Kasir'),
                  subtitle: Text(user),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout,
                      color: AppColors.danger),
                  title: const Text('Logout',
                      style: TextStyle(color: AppColors.danger)),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}