sealed class ProfileUserReference {
  const ProfileUserReference();

  String get apiValue;
}

final class ProfileUserId extends ProfileUserReference {
  ProfileUserId(this.value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'value',
        'A positive user ID is required.',
      );
    }
  }

  final int value;

  @override
  String get apiValue => value.toString();
}

final class ProfileUsername extends ProfileUserReference {
  ProfileUsername(String value) : value = _normalize(value);

  final String value;

  @override
  String get apiValue => '@$value';

  static String _normalize(String value) {
    final String normalizedValue = value.trim();
    final String username = normalizedValue.startsWith('@')
        ? normalizedValue.substring(1)
        : normalizedValue;
    if (username.isEmpty || username.contains('/')) {
      throw ArgumentError.value(
        value,
        'value',
        'A non-empty username without a slash is required.',
      );
    }

    return username;
  }
}
