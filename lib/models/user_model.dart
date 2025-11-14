class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final int age;
  final String photoUrl;
  final bool disabled;
  final List<String> favorites; // list of movie ids

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.photoUrl,
    this.disabled = false,
    this.favorites = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      disabled: map['disabled'] ?? false,
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'photoUrl': photoUrl,
      'disabled': disabled,
      'favorites': favorites,
    };
  }
}
