class User {
  final String name;
  final String department;

  User({required this.name, required this.department});

  Map<String, dynamic> toJson() {
    return {
      'user_name': name,
      'department': department,
    };
  }
}