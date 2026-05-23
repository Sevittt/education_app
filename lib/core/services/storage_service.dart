import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Maps common file extensions to MIME content types.
  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Uploads a file to Firebase Storage and returns the download URL.
  ///
  /// The [folder] parameter specifies the directory in the storage bucket (e.g., 'pdfs', 'images').
  /// A unique file name will be automatically generated.
  Future<String> uploadFile(File file, String folder,
      {String? extension}) async {
    try {
      // Generate a unique file name
      final fileName = '${_uuid.v4()}${extension != null ? '.$extension' : ''}';
      final path = '$folder/$fileName';

      // Create a reference to the location you want to upload to in Firebase
      final ref = _storage.ref().child(path);

      // Set content type metadata so Storage rules can validate file type
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
      );

      // Upload the file with metadata
      final uploadTask = ref.putFile(file, metadata);

      // Wait until the upload is complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file to storage: $e');
    }
  }

  /// Uploads raw file bytes to Firebase Storage and returns the download URL.
  /// Useful for Flutter Web where `dart:io` `File` is not supported.
  Future<String> uploadBytes(Uint8List bytes, String folder,
      {String? extension}) async {
    try {
      final fileName = '${_uuid.v4()}${extension != null ? '.$extension' : ''}';
      final path = '$folder/$fileName';

      final ref = _storage.ref().child(path);

      // Set content type metadata so Storage rules can validate file type
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
      );

      // Upload using putData for raw bytes with metadata
      final uploadTask = ref.putData(bytes, metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload bytes to storage: $e');
    }
  }
}
