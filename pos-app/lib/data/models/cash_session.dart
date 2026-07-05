class CashSession {
  final String id;
  final DateTime openedAt;
  final int openingAmount;
  final String cashier;

  const CashSession({
    required this.id,
    required this.openedAt,
    required this.openingAmount,
    required this.cashier,
  });
}
