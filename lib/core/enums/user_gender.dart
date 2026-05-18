/// Gender used to filter family-relationship options in the UI.
enum UserGender {
  male,
  female,
  unknown;

  static UserGender? fromApi(dynamic raw) {
    if (raw == null) return null;
    switch (raw.toString().toLowerCase().trim()) {
      case 'male':
      case 'm':
        return UserGender.male;
      case 'female':
      case 'f':
        return UserGender.female;
      default:
        return UserGender.unknown;
    }
  }
}
