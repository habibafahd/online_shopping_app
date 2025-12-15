import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save a birthday for a user
  Future<void> addBirthday({
    required String userId,
    required String birthdayId, // like orderId
    required DateTime date,
  }) async {
    try {
      final birthdayData = {"date": Timestamp.fromDate(date)};

      await _db
          .collection("users") // same collection as orders
          .doc(userId)
          .collection("birthdays") // subcollection similar to orders
          .doc(birthdayId)
          .set(birthdayData);

      print("Birthday saved successfully for $userId!");
    } catch (e) {
      print("Error saving birthday: $e");
    }
  }

  /// Load a birthday for a user
  Future<DateTime?> loadBirthday({
    required String userId,
    required String birthdayId,
  }) async {
    try {
      final doc = await _db
          .collection("users")
          .doc(userId)
          .collection("birthdays")
          .doc(birthdayId)
          .get();

      if (doc.exists && doc.data()?['date'] != null) {
        return (doc.data()!['date'] as Timestamp).toDate();
      }
    } catch (e) {
      print("Error loading birthday: $e");
    }
    return null;
  }
}
