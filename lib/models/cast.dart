class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromMap(Map<String, dynamic> map) {
    return CastMember(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown',
      character: map['character'] ?? '',
      profilePath: map['profile_path'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'character': character,
        'profile_path': profilePath,
      };
}
