import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/image_service.dart';

class ManagePhotosScreen extends StatefulWidget {
  const ManagePhotosScreen({super.key});

  @override
  State<ManagePhotosScreen> createState() => _ManagePhotosScreenState();
}

class _ManagePhotosScreenState extends State<ManagePhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();
  bool _isLoading = false;

  Future<void> _addPhoto() async {
    final user = context.read<AuthProvider>().user;
    if (user != null && user.photos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 photos allowed')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload
      await _imageService.uploadImage(image.path);
      
      // Refresh
      if (mounted) {
        await context.read<AuthProvider>().checkAuth();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final photos = user?.photos ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Photos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: photos.length + 1,
                itemBuilder: (context, index) {
                  if (index == photos.length) {
                    // Add button
                    return GestureDetector(
                      onTap: _isLoading ? null : _addPhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          color: SoulSyncColors.coral50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SoulSyncColors.coral200, style: BorderStyle.solid),
                        ),
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: SoulSyncColors.coral400),
                                SizedBox(height: 4),
                                Text('Add', style: TextStyle(color: SoulSyncColors.coral500)),
                              ],
                            ),
                      ),
                    );
                  }

                  final photoUrl = photos[index];
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photoUrl, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                          },
                        ),
                      ),
                      // We can't implement delete fully without backend support for it,
                      // but we can at least show the UI.
                      // Positioned(
                      //   top: 4,
                      //   right: 4,
                      //   child: GestureDetector(
                      //     onTap: () => _deletePhoto(photoUrl),
                      //     child: Container(
                      //       padding: const EdgeInsets.all(4),
                      //       decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      //       child: const Icon(Icons.close, size: 16, color: Colors.red),
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tap "Add" to upload more photos to your profile.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
