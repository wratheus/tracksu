enum ProfileRuleset {
  osu('osu'),
  taiko('taiko'),
  fruits('fruits'),
  mania('mania');

  const ProfileRuleset(this.apiValue);

  final String apiValue;
}
