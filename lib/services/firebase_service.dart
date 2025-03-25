import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to format date as "YYYY-MM-DD"
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Get user details
  Future<UserModel?> getUser(String userId) async {
    // print("Fetching user details for UID: $userId");
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(userId).get();

      if (doc.exists) {
        // print("User details found for UID: $userId");
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      // print("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> signUp(String email, String password, String name, int age,
      int weight, int height) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      String userId = userCredential.user!.uid;

      UserModel user = UserModel(
        uid: userId,
        name: name,
        email: email,
        age: age,
        weight: weight,
        height: height,
        targetCal: 2000,
      );

      await _firestore.collection('users').doc(userId).set(user.toMap());

      // print("User signed up successfully, UID: $userId");
    } catch (e) {
      // print("Error signing up: $e");
      rethrow;
    }
  }

  Future<String?> signIn(String email, String password) async {
    // print("Attempting to sign in with Email: $email, Password: $password");
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      // print("User signed in successfully, UID: ${userCredential.user!.uid}");
      return userCredential.user!.uid;
    } on FirebaseAuthException {
      // print("Firebase Auth Error signing in: ${e.message}");
      rethrow;
    } catch (e) {
      // print("Error signing in: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    // print("Signing out");
    try {
      await _auth.signOut();
      // print("User signed out successfully");
    } catch (e) {
      // print("Error signing out: $e");
      rethrow;
    }
  }

  Future<void> updateUserDetails(UserModel user) async {
    // print("Updating user details for UID: ${user.uid}");
    try {
      await _firestore.collection("users").doc(user.uid).update(user.toMap());
      // print("User details updated successfully for UID: ${user.uid}");
    } catch (e) {
      // print("Error updating user details: $e");
      rethrow;
    }
  }

  // Get daily calories for a specific user and date
  Future<DailyCalories?> getDailyCalories(String userId, DateTime date) async {
    // print("Fetching daily calories for UID: $userId on Date: $date");
    try {
      String docId = _formatDate(date);
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('caloriesTrack')
          .doc(docId)
          .get();
      if (doc.exists) {
        return DailyCalories.fromDocument(doc);
      }
      return null;
    } catch (e) {
      // print("Error fetching daily calories: $e");
      rethrow;
    }
  }

  // Add daily calories if it doesn’t exist for the day
  Future<DailyCalories> addDailyCalories(
      String userId, DailyCalories dailyCalories) async {
    // print(
    // "Adding daily calories for UID: $userId on Date: ${dailyCalories.date}");

    try {
      String docId = _formatDate(dailyCalories.date);
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('caloriesTrack')
          .doc(docId);
      // Check if it exists
      DocumentSnapshot existingDoc = await docRef.get();
      if (existingDoc.exists) {
        return DailyCalories.fromDocument(existingDoc);
      }
      // Add new document with date-based ID
      await docRef.set(dailyCalories.toMap());
      dailyCalories.id = docId;
      return dailyCalories;
    } catch (e) {
      // print("Error adding daily calories: $e");
      rethrow;
    }
  }

  // Update existing daily calories
  Future<DailyCalories> updateDailyCalories(
      String userId, DailyCalories dailyCalories) async {
    // print("Updating daily calories for UID: ${dailyCalories.id}");
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('caloriesTrack')
          .doc(dailyCalories.id)
          .set(dailyCalories.toMap(), SetOptions(merge: true));
      return dailyCalories;
    } catch (e) {
      // print("Error updating daily calories: $e");
      rethrow;
    }
  }

  // Fetch weekly calories for a user
  Future<List<DailyCalories>> getWeeklyCalories({
    required String userId,
    required DateTime startOfWeek,
    required DateTime endOfWeek,
  }) async {
    // print("Fetching weekly calories for UID: $userId");
    try {
      // Check and reset weekly data
      await resetWeeklyData(userId);

      QuerySnapshot query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('caloriesTrack')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .get();

      return query.docs.map((doc) => DailyCalories.fromDocument(doc)).toList();
    } catch (e) {
      // print("Error fetching weekly calories: $e");
      return [];
    }
  }

  // Reset Weekly Data
  Future<void> resetWeeklyData(String userId) async {
    // print("Resetting weekly data for UID: $userId");

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime startOfCurrentWeek =
        today.subtract(Duration(days: (today.weekday - 1) % 7));

    if (today.weekday == 1) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection("users")
            .doc(userId)
            .collection("caloriesTrack")
            .where("date", isLessThan: startOfCurrentWeek.toIso8601String())
            .get();

        WriteBatch batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        // print("Deleted previous week's data successfully for UID: $userId from $startOfLastWeek to $endOfLastWeek");
      } catch (e) {
        // print("Error deleting previous week's data: $e");
      }
    }
  }
}
