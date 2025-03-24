import 'package:cloud_firestore/cloud_firestore.dart';

class DailyCalories {
  String? id;
  DateTime date;
  int consumed;
  int burned;

  DailyCalories({
    this.id,
    required this.date,
    required this.consumed,
    required this.burned,
  });

  factory DailyCalories.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return DailyCalories(
      id: doc.id, // YYYY-MM-DD
      date: (data['date'] as Timestamp).toDate(),
      consumed: data['consumed'],
      burned: data['burned'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'consumed': consumed,
      'burned': burned,
    };
  }
}
