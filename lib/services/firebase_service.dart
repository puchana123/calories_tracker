import 'package:calories_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserDetalis(String username) async {
    try{
      DocumentSnapshot userDoc = await _firestore.collection("userDetails").doc(username).get();

      if(userDoc.exists){
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch(e){
      print("Error fetching user details: $e");
    }
    return null;
  }
}