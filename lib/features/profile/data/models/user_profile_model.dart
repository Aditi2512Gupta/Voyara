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
}