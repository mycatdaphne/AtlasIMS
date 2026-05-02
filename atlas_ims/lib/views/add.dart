import 'package:atlas_ims/data/sqlstorage.dart';
import 'package:flutter/material.dart';
import 'package:atlas_ims/data/schema/entry.dart';
import 'package:atlas_ims/data/imageservice.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class AtlasAdd extends StatefulWidget { 

  const AtlasAdd({super.key, required this.title, required this.db});
  final Sqlstorage db;
  final String title;

  @override
  State<AtlasAdd> createState() => _AtlasAddState();

}

class _AtlasAddState extends State<AtlasAdd> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationIdController = TextEditingController();
  final _imageController = ImageService();

  bool _submitting = false;
  File? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _locationIdController.dispose();
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
    final entry = Entry(
      name :_nameController.text.trim(),
      locationId: int.parse(_locationIdController.text.trim())
      imagePath: ,
    );

    final newId = await widget.db.addEntry(entry);

    bool _submitting = false;

    _nameController.clear();
    _locationIdController.clear();
    _formkey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: Center(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              TextFormField(
                controller: _locationIdController,
                decoration: const InputDecoration(
                  labelText: 'Location Id',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) =>  _submit(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical:14),
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: _submitting ?
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Text('Add Entry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}