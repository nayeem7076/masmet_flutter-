class Member {
  final String id;
  String name;
  String phone;
  double paidAmount;
  bool active;

  Member({required this.id, required this.name, required this.phone, this.paidAmount = 0, this.active = true});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone, 'paidAmount': paidAmount, 'active': active};
  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'], name: json['name'], phone: json['phone'],
    paidAmount: (json['paidAmount'] ?? 0).toDouble(), active: json['active'] ?? true,
  );
}
