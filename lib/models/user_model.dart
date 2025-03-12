class UserModel {
  String name;
  String username;
  int age;
  int weight;
  int height;
  int targetCal;

  UserModel({
    required this.name,
    required this.username,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetCal,
  });

  // Convert Firestore data to Dart object
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'],
      username: data['username'],
      age: data['age'],
      weight: data['weight'],
      height: data['height'],
      targetCal: data['targetCal'],
    );
  }
}