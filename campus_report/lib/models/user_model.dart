import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'
  final String department; // e.g., 'Software Engineering', 'Computer Science', 'Facilities Management'
  final String campusLocation; // e.g., 'Kigali, Rwanda'
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'student',
    this.department = 'Software Engineering',
    this.campusLocation = 'Kigali, Rwanda',
    required this.createdAt,
  });

  /// Helper getter for role-based access control across the UI and providers
  bool get isStaff => role.toLowerCase() == 'staff';

  /// Convert a Firestore document snapshot into a UserModel instance
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      department: data['department'] ?? 'Software Engineering',
      campusLocation: data['campusLocation'] ?? 'Kigali, Rwanda',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel into a Map for storing in Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'campusLocation': campusLocation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? role,
    String? department,
    String? campusLocation,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      department: department ?? this.department,
      campusLocation: campusLocation ?? this.campusLocation,
      createdAt: createdAt,
    );
  }
}