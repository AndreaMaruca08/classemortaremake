
class Credentials {
  String code;
  String pass;
  String? firstName;
  String? lastName;

  Credentials({
    required this.code,
    required this.pass,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'pass': pass,
        'firstName': firstName,
        'lastName': lastName,
      };

  factory Credentials.fromJson(Map<String, dynamic> json) => Credentials(
        code: json['code'] ?? '',
        pass: json['pass'] ?? '',
        firstName: json['firstName'],
        lastName: json['lastName'],
      );

  factory Credentials.fromList(List<String> save) {
    if (save.isEmpty) {
      return Credentials(code: "", pass: "");
    }
    return Credentials(
      code: save[0],
      pass: save[1],
    );
  }
}
