class Order {
  final String id;
  final double total;
  final List<Map<String, dynamic>> items;
  final DateTime date;
  final String userId; // added to link order to a user

  Order({
    required this.id,
    required this.total,
    required this.items,
    required this.date,
    required this.userId,
  });
}
