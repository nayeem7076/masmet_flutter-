class MealEntry {
  final String id;
  String memberId;
  DateTime date;
  double breakfast;
  double lunch;
  double dinner;

  MealEntry({required this.id, required this.memberId, required this.date, this.breakfast = 0, this.lunch = 0, this.dinner = 0});
  double get total => breakfast + lunch + dinner;

  Map<String, dynamic> toJson() => {'id': id, 'memberId': memberId, 'date': date.toIso8601String(), 'breakfast': breakfast, 'lunch': lunch, 'dinner': dinner};
  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'], memberId: json['memberId'], date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    breakfast: (json['breakfast'] ?? 0).toDouble(), lunch: (json['lunch'] ?? 0).toDouble(), dinner: (json['dinner'] ?? 0).toDouble(),
  );
}
