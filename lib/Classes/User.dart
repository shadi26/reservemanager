class User {
  String defaultLanguage;
  String email;
  String fcmToken;
  String name;
  String phone;
  String sid;
  String type;

  User({
    required this.defaultLanguage,
    required this.email,
    required this.fcmToken,
    required this.name,
    required this.phone,
    required this.sid,
    required this.type,
  });

  // Method to create a User from a Map (e.g., Firebase document)
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      defaultLanguage: data['defaultLanguage'] ?? '',
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      sid: data['sid'] ?? '',
      type: data['type'] ?? '',
    );
  }
}