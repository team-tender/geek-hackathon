import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// 選択された画像ファイルを管理するProvider
final profileImageProvider = StateProvider<File?>((ref) => null);

// プロフィールデータ（名前、自己紹介など）を管理する
class ProfileData {
  final String name;
  final String bio;
  final String location;
  final String hobbies;

  ProfileData({
    required this.name,
    required this.bio,
    required this.location,
    required this.hobbies,
  });

  ProfileData copyWith({
    String? name,
    String? bio,
    String? location,
    String? hobbies,
  }) {
    return ProfileData(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      hobbies: hobbies ?? this.hobbies,
    );
  }
}

// ProfileDataを管理するStateNotifier
class ProfileNotifier extends StateNotifier<ProfileData> {
  ProfileNotifier()
    : super(
        ProfileData(
          name: '未設定',
          bio: '自己紹介を入力してください',
          location: '未設定',
          hobbies: '未設定',
        ),
      );

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updateBio(String newBio) {
    state = state.copyWith(bio: newBio);
  }

  void updateLocation(String newLocation) {
    state = state.copyWith(location: newLocation);
  }

  void updateHobbies(String newHobbies) {
    state = state.copyWith(hobbies: newHobbies);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileData>((
  ref,
) {
  return ProfileNotifier();
});

// 画像選択ロジックをまとめたProvider
final imagePickerProvider = Provider((ref) => ImagePicker());
