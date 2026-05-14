import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static const _storageBucket = 'gs://csci-567-s26.firebasestorage.app';

  ImageService({
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instanceFor(bucket: _storageBucket),
        _auth = auth ?? FirebaseAuth.instance;

  final ImagePicker _picker;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<({String path, String url})> uploadImage(File source) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot upload image: no signed-in user.');
    }
    if (!source.existsSync()) {
      throw StateError('Cannot upload image: selected file no longer exists.');
    }
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Cannot upload image: selected file is empty.');
    }

    final ext = p.extension(source.path).toLowerCase();
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = 'users/$uid/entries/$filename';
    final contentType = switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      _ => 'application/octet-stream',
    };

    final ref = _storage.ref(path);
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    if (snapshot.state != TaskState.success || snapshot.bytesTransferred == 0) {
      throw StateError(
        'Image upload did not complete. '
        'State: ${snapshot.state}, bytes: ${snapshot.bytesTransferred}.',
      );
    }
    final url = await _downloadUrlWithRetry(snapshot.ref);
    return (path: snapshot.ref.fullPath, url: url);
  }

  Future<String> _downloadUrlWithRetry(Reference ref) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found' || attempt == 2) {
          throw FirebaseException(
            plugin: e.plugin,
            code: e.code,
            message: '${e.message} Bucket: ${ref.bucket}, path: ${ref.fullPath}',
          );
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }
    return ref.getDownloadURL();
  }

  Future<void> delImg(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      rethrow;
    }
  }
}
