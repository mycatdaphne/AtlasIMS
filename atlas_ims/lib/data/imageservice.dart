import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ImageService {
  ImageService({
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _picker = picker ?? ImagePicker(),
        _storage = storage ?? FirebaseStorage.instance,
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

    final ext = p.extension(source.path).toLowerCase();
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = 'users/$uid/entries/$filename';

    final ref = _storage.ref(path);
    await ref.putFile(source);
    final url = await ref.getDownloadURL();
    return (path: path, url: url);
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