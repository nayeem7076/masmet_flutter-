class NoticeItem {
  final String id;
  String title;
  String text;
  DateTime date;
  String sender;
  bool sendToAll;
  List<String> targetMemberIds;

  NoticeItem({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    this.sender = 'Manager',
    this.sendToAll = true,
    List<String>? targetMemberIds,
  }) : targetMemberIds = targetMemberIds ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        'date': date.toIso8601String(),
        'sender': sender,
        'sendToAll': sendToAll,
        'targetMemberIds': targetMemberIds,
      };

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Notice',
      text: json['text'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      sender: json['sender'] ?? 'Manager',
      sendToAll: json['sendToAll'] ?? true,
      targetMemberIds: List<String>.from(json['targetMemberIds'] ?? []),
    );
  }
}
