import 'package:apphoctienganh/features/auth/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.photoUrl,
    required super.phoneNumber,
    required super.isEmailVerified,
  });

  factory UserProfileModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return UserProfileModel(
      uid: user.id,
      email: user.email,
      displayName:
          metadata['full_name']?.toString() ??
          metadata['name']?.toString() ??
          user.email,
      photoUrl:
          metadata['avatar_url']?.toString() ?? metadata['picture']?.toString(),
      phoneNumber: user.phone,
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      phoneNumber: profile.phoneNumber,
      isEmailVerified: profile.isEmailVerified,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      isEmailVerified: isEmailVerified,
    );
  }
}
