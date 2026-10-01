enum ChildGender { boy, girl }

class ChildProfile {
  final String name;
  final ChildGender gender;
  final String level;

  const ChildProfile(
      {required this.name, required this.gender, required this.level});

  ChildProfile copyWith({String? name, ChildGender? gender, String? level}) =>
      ChildProfile(
          name: name ?? this.name,
          gender: gender ?? this.gender,
          level: level ?? this.level);
}
