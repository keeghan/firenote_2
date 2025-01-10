class Note {
  String id;
  String title;
  String message;
  String color;
  bool pinStatus;
  String dateTimeString;

  Note({
    this.id = '',
    this.title = '',
    this.message = '',
    this.color = 'transparent',
    this.pinStatus = false,
    this.dateTimeString = '',
  });

  // Convert Note to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'color': color,
      'pinStatus': pinStatus,
      'dateTimeString': dateTimeString,
    };
  }

  // Create Note from Map (Firebase)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      color: map['color'] ?? 'transparent',
      pinStatus: map['pinStatus'] ?? false,
      dateTimeString: map['dateTimeString'] ?? '',
    );
  }
}
