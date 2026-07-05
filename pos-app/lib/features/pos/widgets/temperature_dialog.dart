import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/menu_item.dart';

Future<MenuTemperature?> showTemperatureDialog(
    BuildContext context, MenuItem item) {
  return showDialog<MenuTemperature>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(item.name),
      content: const Text('Pilih jenis penyajian'),
      actions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(dialogContext).pop(MenuTemperature.hot),
          icon: const Icon(Icons.local_fire_department,
              color: AppColors.warning),
          label: const Text('Hot'),
        ),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.of(dialogContext).pop(MenuTemperature.iced),
          icon: const Icon(Icons.ac_unit),
          label: const Text('Iced'),
        ),
      ],
    ),
  );
}