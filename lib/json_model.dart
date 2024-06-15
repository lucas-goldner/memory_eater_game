class JsonModel {
  JsonModel({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  factory JsonModel.fromJson(dynamic json) {
    final Map<String, dynamic> trueJson = json as Map<String, dynamic>;

    return JsonModel(
      name: trueJson['name'],
      email: trueJson['email'],
      phone: trueJson['phone'],
    );
  }
}
