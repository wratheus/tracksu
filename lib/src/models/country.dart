class Country {
  String name;
  String code;

  Country({
    required this.name,
    required this.code
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
    name: json['name'],
    code: json['code']
    );
  }
}