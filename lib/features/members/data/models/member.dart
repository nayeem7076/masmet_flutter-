class Member {
  final String id;
  String name;
  String email;
  String phone;
  double paidAmount;
  bool active;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.paidAmount = 0,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'paidAmount': paidAmount,
        'active': active,
      };
  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'],
        name: json['name'],
        email: (json['email'] ?? '').toString(),
        phone: json['phone'],
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        active: json['active'] ?? true,
      );
}
