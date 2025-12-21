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
  late TextEditingController _profilePictureController;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.currentBio);
    _profilePictureController =
        TextEditingController(text: widget.currentProfilePicture ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    _profilePictureController.dispose();
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
        // NOT: Gerçek bir uygulamada burada resmi bir sunucuya yükleyip URL almalısınız
        // Şimdilik sadece local path gösteriyoruz
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fotoğraf seçildi! Gerçek uygulamada bu resmi bir sunucuya yüklemeniz gerekir.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        // Eğer bir image hosting servisi kullanıyorsanız (imgur, cloudinary vs.)
        // burada upload işlemi yapıp dönen URL'i textfield'a set edin:
        // setState(() {
        //   _profilePictureController.text = uploadedUrl;
        // });
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

      await repository.updateProfile(
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        profilePicture: _profilePictureController.text.trim().isEmpty
            ? null
            : _profilePictureController.text.trim(),
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePictureController.text.isNotEmpty
                        ? NetworkImage(_profilePictureController.text)
                        : null,
                    backgroundColor: Colors.teal,
                    onBackgroundImageError: (_, __) {},
                    child: _profilePictureController.text.isEmpty
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Gallery pick button
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Profile picture URL field
            TextField(
              controller: _profilePictureController,
              decoration: const InputDecoration(
                labelText: 'Profil Fotoğrafı URL',
                hintText: 'https://example.com/photo.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 24),

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
                      'Galeri seçimi şu anda gösterim içindir. Gerçek uygulamada seçilen resmi bir image hosting servisine (Cloudinary, ImgBB, vb.) yükleyip dönen URL\'i kullanmalısınız.',
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
