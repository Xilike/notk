import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';

class ChildProfileService {
  ChildProfileService(this.preferences);
  final SharedPreferences preferences;
  ChildProfile profile =
      const ChildProfile(name: 'بطلي', gender: ChildGender.boy, level: 'KG1');

  Future<void> load() async {
    Map<String, dynamic> data = {};
    try {
      final raw = preferences.getString('childProfile');
      if (raw != null) data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Migrate the existing preferences if the profile is absent or damaged.
    }
    final gender =
        (data['gender'] ?? preferences.getString('childGender')) == 'girl'
            ? ChildGender.girl
            : ChildGender.boy;
    final rawName = data['name'] ?? preferences.getString('childName');
    profile = ChildProfile(
      name: rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : gender == ChildGender.girl
              ? 'بطلتي'
              : 'بطلي',
      gender: gender,
      level: (data['level'] ?? preferences.getString('level')) == 'KG2'
          ? 'KG2'
          : 'KG1',
    );
    await save(profile);
  }

  Future<void> save(ChildProfile value) async {
    profile = value;
    await preferences.setString(
        'childProfile',
        jsonEncode({
          'name': value.name,
          'gender': value.gender.name,
          'level': value.level,
        }));
  }
}
