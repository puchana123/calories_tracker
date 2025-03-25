import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String name;
  String email;
  int age;
  int weight;
  int height;
  int targetCal;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.targetCal,
  });

  // Convert Firestore document to Dart object
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // Get UID from Firestore document ID
      name: data['name'],
      email: data['email'],
      age: data['age'],
      weight: data['weight'],
      height: data['height'],
      targetCal: data['targetCal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'targetCal': targetCal,
    };
  }
}
