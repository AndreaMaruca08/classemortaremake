class LoginResponse {
  String studentCode;
  String firstName;
  String lastName;
  String token;

  LoginResponse({
    required this.studentCode,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      studentCode: json['ident'] ?? "",
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      token: json['token'] ?? "",
    );
  }
}
