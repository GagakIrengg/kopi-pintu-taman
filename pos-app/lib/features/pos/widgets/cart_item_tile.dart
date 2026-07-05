import 'package:flutter/material.dart';
import '../../../core/custom_menu.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/menu_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;
  final VoidCallback onEditNotes;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
    required this.onEditNotes,
  });

  @override
  Widget build(BuildContext context) {
    final tempLabel = switch (item.temperature) {
      MenuTemperature.hot => 'Hot',
      MenuTemperature.iced => 'Iced',
      _ => null,
    };
    final isCustom = isCustomMenuId(item.menuItem.id);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cream100.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(item.menuItem.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5)),
                      ),
                      if (isCustom)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.coffee700
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('custom',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.coffee700)),
                        ),
                      if (tempLabel != null)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tempLabel == 'Hot'
                                ? AppColors.warning.withOpacity(0.15)
                                : AppColors.coffee500.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tempLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tempLabel == 'Hot'
                                      ? AppColors.warning
                                      : AppColors.coffee500)),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Text(formatRupiah(item.unitPrice),
                        style: const TextStyle(
                            color: AppColors.coffee700,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger, size: 20),
                tooltip: 'Hapus',
              ),
            ],
          ),
          if (item.addons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Text(
                '+ ${item.addons.map((a) => a.name).join(', ')}',
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textMuted),
              ),
            ),
          if ((item.notes ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Text(item.notes!,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted)),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 0),
                  minimumSize: const Size(0, 28),
                ),
                onPressed: onEditNotes,
                icon: const Icon(Icons.edit_note, size: 16),
                label:
                    const Text('Notes', style: TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              _qtyBtn(Icons.remove, onDec),
              SizedBox(
                width: 28,
                child: Center(
                  child: Text('${item.quantity}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
              _qtyBtn(Icons.add, onInc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16),
        ),
      );
}