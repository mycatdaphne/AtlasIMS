import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _imgFolder = 'atlas_entry_img';
  
  Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<String> storeImgPath(File source) async {
    final strgDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(strgDir.path, _imgFolder));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }

    final ext = p.extension(source.path);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(imgDir.path, filename));
    await source.copy(dest.path);
    return dest.path;
  }

  Future<void> delImg(String path) async {
    final f = File(path);
    if (await f.exists()) { await f.delete(); } 
  }
}


