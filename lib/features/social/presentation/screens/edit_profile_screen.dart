import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/features/user/data/repositories/user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String currentBio;
  final String? currentProfilePicture;

  const EditProfileScreen({
    super.key,
    this.currentBio = '',
    this.currentProfilePicture,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _bioController;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _selectedImageBase64;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBase64 = base64Image;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf seçildi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(apiServiceProvider);
      final repository = UserRepository(dio);

      // Send base64 image if selected, otherwise keep current or null
      String? profilePictureData;
      if (_selectedImageBase64 != null) {
        profilePictureData = 'data:image/jpeg;base64,$_selectedImageBase64';
      }

      await repository.updateProfile(
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        profilePicture: profilePictureData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check),
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture preview
            Center(
              child: Column(
                children: [
                  // Show selected image or current profile picture or placeholder
                  _selectedImageFile != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_selectedImageFile!),
                          backgroundColor: Colors.teal,
                        )
                      : widget.currentProfilePicture != null &&
                              widget.currentProfilePicture!.isNotEmpty
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(widget.currentProfilePicture!),
                              backgroundColor: Colors.teal,
                              onBackgroundImageError: (_, __) {},
                            )
                          : const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.person,
                                  size: 60, color: Colors.white),
                            ),
                  const SizedBox(height: 16),
                  // Gallery pick button
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: Text(_selectedImageFile != null
                        ? 'Farklı Fotoğraf Seç'
                        : 'Galeriden Fotoğraf Seç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  if (_selectedImageFile != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImageFile = null;
                          _selectedImageBase64 = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Seçimi İptal Et',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bio field
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Kendiniz hakkında bir şeyler yazın...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              maxLines: 4,
              maxLength: 500,
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seçtiğiniz fotoğraf otomatik olarak yüklenecektir. Yüksek çözünürlüklü fotoğraflar yükleme süresini artırabilir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
