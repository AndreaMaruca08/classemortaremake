class StudentCard {
  String ident;
  String userType;
  String miurSchoolCode;
  String firstName;
  String lastName;
  String birthDate;
  String fiscalCode;
  String schoolCode;
  String schoolName;
  String schoolDedication;
  String schoolCity;
  String schoolProv;

  StudentCard({
    required this.ident,
    required this.userType,
    required this.miurSchoolCode,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.fiscalCode,
    required this.schoolCode,
    required this.schoolName,
    required this.schoolDedication,
    required this.schoolCity,
    required this.schoolProv,
  });

  factory StudentCard.fromJson(Map<String, dynamic> json) {
    try {
      return StudentCard(
        ident: json['ident'] ?? "",
        userType: json['usrType'] ?? "",
        miurSchoolCode: json['miurSchoolCode'] ?? "",
        firstName: json['firstName'] ?? "",
        lastName: json['lastName'] ?? "",
        birthDate: json['birthDate'] ?? "",
        fiscalCode: json['fiscalCode'] ?? "",
        schoolCode: json['schCode'] ?? "",
        schoolName: json['schName'] ?? "",
        schoolDedication: json['schDedication'] ?? "",
        schoolCity: json['schCity'] ?? "",
        schoolProv: json['schProv'] ?? "",
      );
    } catch (e) {
      print("ERROR IN StudentCard.fromJson: $e");
      return StudentCard(
        ident: "ERROR",
        userType: "ERROR",
        miurSchoolCode: "ERROR",
        firstName: "ERROR",
        lastName: "ERROR",
        birthDate: "ERROR",
        fiscalCode: "ERROR",
        schoolCode: "ERROR",
        schoolName: "ERROR",
        schoolDedication: "ERROR",
        schoolCity: "ERROR",
        schoolProv: "ERROR",
      );
    }
  }
}
