import 'package:atlas_ims/data/firestore_storage.dart';
import 'package:flutter/material.dart';
import 'package:atlas_ims/data/schema/entry.dart';
import 'package:atlas_ims/data/imageservice.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:atlas_ims/views/widget/location_picker.dart';
import 'package:atlas_ims/views/widget/tag_picker.dart';

class AtlasAdd extends StatefulWidget {
  const AtlasAdd({super.key, required this.title, required this.db});
  final FirestoreStorage db;
  final String title;

  @override
  State<AtlasAdd> createState() => _AtlasAddState();
}

class _AtlasAddState extends State<AtlasAdd> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = ImageService();

  bool _submitting = false;
  File? _pickedImage;
  String? _selectedLocationId;
  Set<String> _selectedTagIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImg(ImageSource source) async {
    try {
      final file = await _imageController.pickImage(source);
      if (file == null) return;
      setState(() => _pickedImage = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formkey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      String? imagePath;
      String? imageUrl;
      if (_pickedImage != null) {
        final result = await _imageController.uploadImage(_pickedImage!);
        imagePath = result.path;
        imageUrl = result.url;
      }

      final entry = Entry(
        name: _nameController.text.trim(),
        locationId: _selectedLocationId,
        imagePath: imagePath,
        imageUrl: imageUrl,
      );

      final newId = await widget.db.addEntry(
        entry,
        tagIds: _selectedTagIds.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${newId.substring(0, 6)}…')),
      );
      _nameController.clear();
      _formkey.currentState!.reset();
      setState(() {
        _pickedImage = null;
        _selectedLocationId = null;
        _selectedTagIds = {};
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name value is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              LocationPicker(
                db: widget.db,
                selectedId: _selectedLocationId,
                onChanged: (next) => setState(() {
                  _selectedLocationId = next;
                }),
              ),
              const SizedBox(height: 16),
              _buildImagePreview(),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Tags',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              TagPicker(
                db: widget.db,
                selectedIds: _selectedTagIds,
                onChanged: (next) => setState(() => _selectedTagIds = next),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        InkWell(
          onTap: _showImageSourceSheet,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _pickedImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
        if (_pickedImage != null)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () => setState(() => _pickedImage = null),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImg(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImg(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
