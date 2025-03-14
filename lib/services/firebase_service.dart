import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserDetalis(String uid) async {
    print("Fetching user details for UID: $uid");
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("userDetails").doc(uid).get();

      if (userDoc.exists) {
        print("User details found for UID: $uid");
        return UserModel.fromDocument(userDoc);
      } else {
        print("User details not found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> signUp(String email, String password, String name, int age,
      int weight, int height) async {
    print("Signing up with Email: $email, Password: $password");
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      String uid = userCredential.user!.uid;

      // Store additional user details in Firestore
      await _firestore.collection("userDetails").doc(uid).set({
        "email": email.trim(),
        "name": name,
        "age": age,
        "weight": weight,
        "height": height,
        "targetCal": 2000,
      });

      print("User signed up successfully, UID: $uid");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error signing up: ${e.message}");
      throw e;
    } catch (e) {
      print("Error signing up: $e");
      throw e;
    }
  }

  Future<String?> signIn(String email, String password) async {
    print("Attempting to sign in with Email: $email, Password: $password");
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      print("User signed in successfully, UID: ${userCredential.user!.uid}");
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error signing in: ${e.message}");
      throw e;
    } catch (e) {
      print("Error signing in: $e");
      throw e;
    }
  }

  Future<void> signOut() async {
    print("Signing out");
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
      throw e;
    }
  }

  Future<void> updateUserDetails(UserModel user) async {
    print("Updating user details for UID: ${user.uid}");
    try {
      await _firestore.collection("userDetails").doc(user.uid).update({
        "name": user.name,
        "age": user.age,
        "weight": user.weight,
        "height": user.height,
        "targetCal": user.targetCal,
      });
      print("User details updated successfully for UID: ${user.uid}");
    } catch (e) {
      print("Error updating user details: $e");
      throw e;
    }
  }

  Future<DailyCalories?> getDailyCalories(String uid, DateTime date) async {
    print("Fetching daily calories for UID: $uid on Date: $date");
    try {
      // Extract year, month, and day
      int year = date.year;
      int month = date.month;
      int day = date.day;

      QuerySnapshot querySnapshot = await _firestore
          .collection("caloriesTrack")
          .where("uid", isEqualTo: uid)
          .where("year", isEqualTo: year)
          .where("month", isEqualTo: month)
          .where("day", isEqualTo: day)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("Daily calories found for UID: $uid on Date: $date");
        DailyCalories dailyCalories =
            DailyCalories.fromDocument(querySnapshot.docs.first);
        dailyCalories.id = querySnapshot.docs.first.id;
        return dailyCalories;
      } else {
        print("No daily calories found for UID: $uid on Date: $date");
        return null;
      }
    } catch (e) {
      print("Error fetching daily calories: $e");
      return null;
    }
  }

  Future<void> addDailyCalories(String uid, DailyCalories dailyCalories) async {
    print("Update daily calories for UID: $uid on Date: ${dailyCalories.date}");

    try {
      if (dailyCalories.id != null) {
        // If Id exists, update the document
        await _firestore
            .collection("caloriesTrack")
            .doc(dailyCalories.id)
            .update(dailyCalories.toMap());
      } else {
        // If Id doesn't exist, add a new document
        await _firestore.collection("caloriesTrack").add({
              "uid": uid,
            }..addAll(dailyCalories.toMap()));
      }
    } catch (e) {
      print("Error adding daily calories: $e");
      throw e;
    }
  }
}
