class UniversityModel {
  final String name;
  final String country;
  final List<String> domains;
  final String alphaTwoCode;
  final String stateProvince;
  final List<String> webPages;

  UniversityModel({
    required this.name,
    required this.country,
    required this.domains,
    required this.alphaTwoCode,
    required this.stateProvince,
    required this.webPages,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      domains: List<String>.from(json['domains'] ?? []),
      alphaTwoCode: json['alpha_two_code'] ?? '',
      stateProvince: json['state-province'] ?? '',
      webPages: List<String>.from(json['web_pages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'domains': domains,
      'alpha_two_code': alphaTwoCode,
      'state-province': stateProvince,
      'web_pages': webPages,
    };
  }
}
