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
      id: doc.id,
      date:
          (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      consumed: data['consumed'],
      burned: data['burned'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      'year': date.year,
      'month': date.month,
      'day': date.day,
      'consumed': consumed,
      'burned': burned,
    };
  }
}
