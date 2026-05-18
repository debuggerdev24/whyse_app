import 'package:flutter/foundation.dart';
import 'package:redstreakapp/core/enums/user_gender.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';

class FamilyProvider extends ChangeNotifier {
  final List<FamilyMember> _familyMembers = [];

  List<FamilyMember> get familyMembers =>
      List.unmodifiable(_familyMembers);

  bool isFamilyMember(String userId) =>
      _familyMembers.any((m) => m.member.id == userId);

  String? relationshipFor(String userId) {
    try {
      return _familyMembers.firstWhere((m) => m.member.id == userId).relationship;
    } catch (_) {
      return null;
    }
  }

  void addFamilyMember({
    required FriendUser member,
    required String relationship,
  }) {
    final existingIndex =
        _familyMembers.indexWhere((m) => m.member.id == member.id);
    if (existingIndex >= 0) {
      _familyMembers[existingIndex] = FamilyMember(
        id: _familyMembers[existingIndex].id,
        member: member,
        relationship: relationship,
      );
    } else {
      _familyMembers.add(
        FamilyMember(
          id: 'family-${member.id}',
          member: member,
          relationship: relationship,
        ),
      );
    }
    notifyListeners();
  }

  void seedDemoMembers() {
    if (_familyMembers.isNotEmpty) return;
    _familyMembers.addAll([
      FamilyMember(
        id: 'family-demo-1',
        relationship: 'Father',
        member: const FriendUser(
          id: 'demo-family-1',
          displayName: 'Robert Rivera',
          username: 'robert',
          gender: UserGender.male,
        ),
      ),
      FamilyMember(
        id: 'family-demo-2',
        relationship: 'Sister',
        member: const FriendUser(
          id: 'demo-family-2',
          displayName: 'Mia Lee',
          username: 'mialee',
          gender: UserGender.female,
        ),
      ),
    ]);
    notifyListeners();
  }

  void clear() {
    _familyMembers.clear();
    notifyListeners();
  }
}
