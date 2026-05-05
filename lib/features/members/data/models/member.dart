class Member {
  final String id;
  String name;
  String email;
  String phone;
  double paidAmount;
  bool active;
  DateTime createdAt;
  DateTime? lastPaymentAt;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.paidAmount = 0,
    this.active = true,
    DateTime? createdAt,
    this.lastPaymentAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'paidAmount': paidAmount,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'lastPaymentAt': lastPaymentAt?.toIso8601String(),
      };
  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'],
        name: json['name'],
        email: (json['email'] ?? '').toString(),
        phone: json['phone'],
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        active: json['active'] ?? true,
        createdAt:
            DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        lastPaymentAt: DateTime.tryParse(
          (json['lastPaymentAt'] ?? '').toString(),
        ),
      );
}
