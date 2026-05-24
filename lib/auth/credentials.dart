class Credentials{
    String code;
    String pass;

    Credentials({
      required this.code,
      required this.pass,
    });

    factory Credentials.fromList(List<String> save){
      if(save.isEmpty) {
        return Credentials(
          code: "",
          pass: "",
        );
      }
      return Credentials(
        code: save[0],
        pass: save[1],
      );

    }

}