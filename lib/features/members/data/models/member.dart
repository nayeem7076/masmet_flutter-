class MemberPayment {
  final double amount;
  final DateTime paidAt;

  const MemberPayment({
    required this.amount,
    required this.paidAt,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'paidAt': paidAt.toIso8601String(),
      };

  factory MemberPayment.fromJson(Map<String, dynamic> json) => MemberPayment(
        amount: (json['amount'] ?? 0).toDouble(),
        paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()) ??
            DateTime.now(),
      );
}

class Member {
  final String id;
  String name;
  String email;
  String phone;
  String? imagePath;
  double paidAmount;
  bool active;
  DateTime createdAt;
  DateTime? lastPaymentAt;
  List<MemberPayment> paymentHistory;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath,
    this.paidAmount = 0,
    this.active = true,
    DateTime? createdAt,
    this.lastPaymentAt,
    List<MemberPayment>? paymentHistory,
  })  : createdAt = createdAt ?? DateTime.now(),
        paymentHistory = paymentHistory ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'imagePath': imagePath,
        'paidAmount': paidAmount,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'lastPaymentAt': lastPaymentAt?.toIso8601String(),
        'paymentHistory': paymentHistory.map((item) => item.toJson()).toList(),
      };
  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'],
        name: json['name'],
        email: (json['email'] ?? '').toString(),
        phone: json['phone'],
        imagePath: (json['imagePath'] ?? '').toString().trim().isEmpty
            ? null
            : (json['imagePath'] as String),
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        active: json['active'] ?? true,
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        lastPaymentAt: DateTime.tryParse(
          (json['lastPaymentAt'] ?? '').toString(),
        ),
        paymentHistory: ((json['paymentHistory'] as List?) ?? const [])
            .whereType<Map>()
            .map((item) => MemberPayment.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
}
