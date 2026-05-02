class Expense {
  final String id;
  String title;
  double amount;
  String paidByMemberId;
  DateTime date;
  String category;
  List<String> items;

  Expense({required this.id, required this.title, required this.amount, required this.paidByMemberId, required this.date, this.category = 'bazar', this.items = const []});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount, 'paidByMemberId': paidByMemberId, 'date': date.toIso8601String(), 'category': category, 'items': items};
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'], title: json['title'], amount: (json['amount'] ?? 0).toDouble(), paidByMemberId: json['paidByMemberId'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(), category: json['category'] ?? 'bazar', items: List<String>.from(json['items'] ?? []),
  );
}
