class UserProfileModel {
  const UserProfileModel({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.phone,
    required this.joinedOn,
  });

  final String name;
  final String email;
  final String photoUrl;
  final String phone;
  final DateTime joinedOn;

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    DateTime? joinedOn,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      joinedOn: joinedOn ?? this.joinedOn,
    );
  }
}