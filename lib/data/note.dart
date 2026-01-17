class Note {
  String id;
  String title;
  String message;
  String color;
  bool pinStatus;
  String dateTimeString;
  bool isEncrypted; // Flag to track if this note is encrypted

  Note({
    this.id = '',
    this.title = '',
    this.message = '',
    this.color = 'transparent',
    this.pinStatus = false,
    this.dateTimeString = '',
    this.isEncrypted = false, // Default to false for backward compatibility
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
      'isEncrypted': isEncrypted,
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
      isEncrypted: map['isEncrypted'] ?? false, // Default to false for old notes
    );
  }

  // Copy function to create a new instance with the same values
  Note copy() {
    return Note(
      id: id,
      title: title,
      message: message,
      color: color,
      pinStatus: pinStatus,
      dateTimeString: dateTimeString,
      isEncrypted: isEncrypted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
