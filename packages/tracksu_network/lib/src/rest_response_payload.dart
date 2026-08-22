import 'dart:convert';

final class RestResponsePayload {
  RestResponsePayload(this._bodyText);

  final String _bodyText;
  late final Object? _value = jsonDecode(_bodyText);

  Object? get value => _value;

  Map<String, dynamic> asMap() {
    return switch (_value) {
      final Map<String, dynamic> value => value,
      _ => throw const FormatException(
        'The response payload must be a JSON object.',
      ),
    };
  }

  List<dynamic> asList() {
    return switch (_value) {
      final List<dynamic> value => value,
      _ => throw const FormatException(
        'The response payload must be a JSON array.',
      ),
    };
  }

  String asString() {
    return switch (_value) {
      final String value => value,
      _ => throw const FormatException(
        'The response payload must be a JSON string.',
      ),
    };
  }

  bool asBool() {
    return switch (_value) {
      final bool value => value,
      _ => throw const FormatException(
        'The response payload must be a JSON boolean.',
      ),
    };
  }

  num asNumber() {
    return switch (_value) {
      final num value => value,
      _ => throw const FormatException(
        'The response payload must be a JSON number.',
      ),
    };
  }
}
