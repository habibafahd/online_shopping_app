import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String phone;
  final String gender;
  final DateTime birthday;

  UserProfile({
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
  });
}

class UserService {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await usersRef.doc(userId).get();
    if (!doc.exists) {
      return UserProfile(
        email: '',
        phone: '',
        gender: '',
        birthday: DateTime.now(),
      );
    }
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      birthday: (data['birthday'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> updateUserProfile(
    String userId, {
    String? email,
    String? phone,
    DateTime? birthday,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (email != null) updateData['email'] = email;
    if (phone != null) updateData['phone'] = phone;
    if (birthday != null) updateData['birthday'] = Timestamp.fromDate(birthday);
    if (updateData.isNotEmpty) {
      await usersRef.doc(userId).set(updateData, SetOptions(merge: true));
    }
  }
}
