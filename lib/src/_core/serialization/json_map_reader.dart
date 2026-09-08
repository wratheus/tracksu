final class JsonMapReader {
  const JsonMapReader(this._json);

  final Map<String, dynamic> _json;

  bool requiredBool(String key) {
    return switch (_json[key]) {
      final bool value => value,
      _ => throw FormatException('$key must be a boolean.'),
    };
  }

  double requiredDouble(String key) {
    return switch (_json[key]) {
      final num value => value.toDouble(),
      _ => throw FormatException('$key must be a number.'),
    };
  }

  double? optionalDouble(String key) {
    return switch (_json[key]) {
      null => null,
      final num value => value.toDouble(),
      _ => throw FormatException('$key must be a number or null.'),
    };
  }

  List<dynamic> requiredList(String key) {
    return switch (_json[key]) {
      final List<dynamic> value => value,
      _ => throw FormatException('$key must be an array.'),
    };
  }

  String? optionalString(String key) => switch (_json[key]) {
    null => null,
    final String value => value,
    _ => throw FormatException('$key must be a string or null.'),
  };

  int requiredInt(String key, {bool positive = false}) {
    return switch (_json[key]) {
      final int value when !positive || value > 0 => value,
      _ => throw FormatException(
        positive
            ? '$key must be a positive integer.'
            : '$key must be an integer.',
      ),
    };
  }

  String requiredString(String key) {
    return switch (_json[key]) {
      final String value when value.isNotEmpty => value,
      _ => throw FormatException('$key must be a non-empty string.'),
    };
  }

  int? optionalInt(String key) {
    return switch (_json[key]) {
      null => null,
      final int value => value,
      _ => throw FormatException('$key must be an integer or null.'),
    };
  }

  Map<String, dynamic>? optionalMap(String key) {
    return switch (_json[key]) {
      null => null,
      final Map<String, dynamic> value => value,
      _ => throw FormatException('$key must be an object or null.'),
    };
  }
}
