import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flip_card/flip_card.dart'; // importを追加
import 'profile_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final imagePicker = ref.read(imagePickerProvider);
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ref.read(profileImageProvider.notifier).state = File(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileImage = ref.watch(profileImageProvider);
    final profileData = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('プロフィールを保存しました')));
              // Focusを外してキーボードを閉じる
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // CardをFlipCardに置き換え
          child: FlipCard(
            front: _buildFrontCard(ref, profileImage, profileData),
            back: _buildBackCard(ref, profileData),
          ),
        ),
      ),
    );
  }

  // カードの表側
  Widget _buildFrontCard(
    WidgetRef ref,
    File? profileImage,
    ProfileData profileData,
  ) {
    final profileNotifier = ref.read(profileProvider.notifier);
    final nameController = TextEditingController(text: profileData.name);
    final bioController = TextEditingController(text: profileData.bio);

    return Card(
      elevation: 8.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // アイコン表示エリア
          InkWell(
            onTap: () => _pickImage(ref),
            child: Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: profileImage != null
                    ? DecorationImage(
                        image: FileImage(profileImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileImage == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
          ),
          // プロフィール情報エリア
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: nameController.text.length),
                    ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => profileNotifier.updateName(value),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: bioController
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: bioController.text.length),
                    ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => profileNotifier.updateBio(value),
                ),
              ],
            ),
          ),
          // 裏返すためのヒント
          Positioned(
            top: 16,
            right: 16,
            child: Icon(Icons.flip, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  // カードの裏側
  Widget _buildBackCard(WidgetRef ref, ProfileData profileData) {
    final profileNotifier = ref.read(profileProvider.notifier);
    final locationController = TextEditingController(
      text: profileData.location,
    );
    final hobbiesController = TextEditingController(text: profileData.hobbies);

    return Card(
      elevation: 8.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '詳細情報',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: locationController
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: locationController.text.length),
                ),
              onChanged: (value) => profileNotifier.updateLocation(value),
              decoration: const InputDecoration(
                labelText: '住んでいる地域',
                icon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: hobbiesController
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: hobbiesController.text.length),
                ),
              onChanged: (value) => profileNotifier.updateHobbies(value),
              decoration: const InputDecoration(
                labelText: '趣味',
                icon: Icon(Icons.favorite),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
