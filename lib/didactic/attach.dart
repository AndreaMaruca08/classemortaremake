class Attach{
  String fileName;
  int attachNum;

  Attach({
    required this.fileName,
    required this.attachNum,
  });

  factory Attach.fromJson(Map<String, dynamic> json){
    return Attach(
      fileName: json['fileName'],
      attachNum: json['attachNum'],
    );
  }
  static List<Attach> fromJsonList(Map<String, dynamic> json){
    final attach = json['attachments'] as List<dynamic>? ?? [];
    return attach.map<Attach>((json) => Attach.fromJson(json)).toList();
  }

}