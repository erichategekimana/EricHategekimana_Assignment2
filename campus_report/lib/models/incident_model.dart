import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'Facilities', 'Water', 'Electricity', 'Safety', 'Sanitation'
  final String location; // e.g., 'Block B — Room 204'
  final String status; // 'Submitted', 'In Progress', 'Resolved'
  final String? imageUrl;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous; // Product Thinking rubric: privacy protection for sensitive reports
  final String? staffNote; // Resolution or progress note added by authorized staff
  final DateTime createdAt;
  final DateTime? inProgressAt; // Powers the middle node of the Status Timeline
  final DateTime? resolvedAt; // Powers the final node of the Status Timeline

  const IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.status = 'Submitted',
    this.imageUrl,
    required this.reporterId,
    required this.reporterName,
    this.isAnonymous = false,
    this.staffNote,
    required this.createdAt,
    this.inProgressAt,
    this.resolvedAt,
  });

  /// Returns a privacy-safe reporter name for display
  String get displayReporterName =>
      isAnonymous ? 'Anonymous Student' : reporterName;

  /// Standard categories matching the Sample UI
  static const List<String> categories = [
    'Facilities',
    'Water',
    'Electricity',
    'Safety',
    'Sanitation',
  ];

  /// Standard campus locations for the dropdown
  static const List<String> locations = [
    'Block A — Commons',
    'Block B — Room 204',
    'Block B — Lecture Hall',
    'Student Residence',
    'Cafeteria',
    'Library & Pod Area',
    'Main Courtyard',
  ];

  /// Standard statuses matching the Sample UI Status Timeline
  static const List<String> statuses = [
    'Submitted',
    'In Progress',
    'Resolved',
  ];

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return IncidentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Facilities',
      location: data['location'] ?? '',
      status: data['status'] ?? 'Submitted',
      imageUrl: data['imageUrl'],
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? 'Student',
      isAnonymous: data['isAnonymous'] ?? false,
      staffNote: data['staffNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      inProgressAt: (data['inProgressAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'imageUrl': imageUrl,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'isAnonymous': isAnonymous,
      'staffNote': staffNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'inProgressAt':
          inProgressAt != null ? Timestamp.fromDate(inProgressAt!) : null,
      'resolvedAt':
          resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  IncidentModel copyWith({
    String? title,
    String? description,
    String? category,
    String? location,
    String? status,
    String? imageUrl,
    bool? isAnonymous,
    String? staffNote,
    DateTime? inProgressAt,
    DateTime? resolvedAt,
  }) {
    return IncidentModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      reporterId: reporterId,
      reporterName: reporterName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      staffNote: staffNote ?? this.staffNote,
      createdAt: createdAt,
      inProgressAt: inProgressAt ?? this.inProgressAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}