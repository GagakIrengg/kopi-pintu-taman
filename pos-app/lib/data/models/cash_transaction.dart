enum CashType {
  in_,
  out,
}

class CashTransaction {
  final String id;
  final DateTime createdAt;
  final int amount;
  final CashType type;
  final String description;

  CashTransaction({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.type,
    required this.description,
  });
}