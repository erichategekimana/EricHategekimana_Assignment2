import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an incident image file to Firebase Storage and returns the download URL
  Future<String> uploadIncidentPhoto({
    required File imageFile,
    required String reporterId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'incident_photos/$reporterId/incident_$timestamp.jpg';

    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = await ref.putFile(imageFile, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes an image from Firebase Storage if an incident report is deleted
  Future<void> deleteIncidentPhoto(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Ignore if file was already removed from storage
    }
  }
}