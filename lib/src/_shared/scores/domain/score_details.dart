final class ScoreHitCount {
  const ScoreHitCount({required this.kind, this.achieved, this.maximum});

  /// API hit-result identifier; not a classic score value (300/100/50).
  final String kind;
  final int? achieved;
  final int? maximum;
}

final class ScoreMod {
  ScoreMod({required this.acronym, required List<ScoreModSetting> settings})
    : settings = List<ScoreModSetting>.unmodifiable(settings);
  final String acronym;
  final List<ScoreModSetting> settings;
}

final class ScoreModSetting {
  const ScoreModSetting({required this.name, required this.value});
  final String name;
  final ScoreModValue value;
}

sealed class ScoreModValue {
  const ScoreModValue();
}

final class ScoreModNumber extends ScoreModValue {
  const ScoreModNumber(this.value);
  final num value;
}

final class ScoreModBool extends ScoreModValue {
  const ScoreModBool(this.value);
  final bool value;
}

final class ScoreModText extends ScoreModValue {
  const ScoreModText(this.value);
  final String value;
}

final class ScoreModUnsupported extends ScoreModValue {
  const ScoreModUnsupported();
}
