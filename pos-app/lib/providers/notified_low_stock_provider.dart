import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Melacak bahan mana yang SUDAH dinotifikasikan sebagai low/out,
/// supaya snackbar after-transaksi hanya muncul SEKALI saat transisi
/// aman -> low/out, bukan setiap transaksi (anti-spam #5).
///
/// State in-memory (hilang saat app restart) — cukup untuk kebutuhan ini.
class NotifiedLowStockNotifier extends StateNotifier<Set<String>> {
  NotifiedLowStockNotifier() : super(<String>{});

  /// Tandai sebuah bahan sudah dinotif (jangan notif lagi sampai di-reset).
  void markNotified(String ingredientId) {
    state = {...state, ingredientId};
  }

  /// Bahan sudah di-restock ke atas threshold -> lupakan, supaya kalau
  /// nanti turun lagi bisa memunculkan notif sekali lagi.
  void clearNotified(String ingredientId) {
    if (!state.contains(ingredientId)) return;
    final next = {...state}..remove(ingredientId);
    state = next;
  }

  bool isAlreadyNotified(String ingredientId) =>
      state.contains(ingredientId);
}

final notifiedLowStockProvider =
    StateNotifierProvider<NotifiedLowStockNotifier, Set<String>>(
  (ref) => NotifiedLowStockNotifier(),
);
