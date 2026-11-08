import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'incidents';

  /// CREATE: Save a new incident report to Firestore
  Future<String> createIncident(IncidentModel incident) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(incident.toMap());
    return docRef.id;
  }

  /// READ (Stream): Real-time stream of all campus incidents ordered newest first
  Stream<List<IncidentModel>> streamAllIncidents() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IncidentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// UPDATE (Staff): Update incident status, record timeline timestamps, and save staff note
  Future<void> updateIncidentStatus({
    required String incidentId,
    required String newStatus,
    String? staffNote,
  }) async {
    final Map<String, dynamic> updates = {
      'status': newStatus,
    };

    if (staffNote != null) {
      updates['staffNote'] = staffNote.trim();
    }

    final now = Timestamp.fromDate(DateTime.now());
    if (newStatus == 'In Progress') {
      updates['inProgressAt'] = now;
    } else if (newStatus == 'Resolved') {
      updates['resolvedAt'] = now;
    }

    await _firestore.collection(_collection).doc(incidentId).update(updates);
  }

  /// UPDATE (Student/Owner): Edit title, description, category, or location while 'Submitted'
  Future<void> updateIncidentDetails({
    required String incidentId,
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    await _firestore.collection(_collection).doc(incidentId).update({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,
    });
  }

  /// DELETE: Delete an incident report from Firestore
  Future<void> deleteIncident(String incidentId) async {
    await _firestore.collection(_collection).doc(incidentId).delete();
  }
}