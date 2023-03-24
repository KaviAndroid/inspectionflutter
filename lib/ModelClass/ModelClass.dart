class ModelClass{

  late String dcode;
  late String dname;

  ModelClass(this.dcode, this.dname);

  ModelClass.fromMap(Map map) {
    dcode = map[dcode];
    dname = map[dname];

  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'dcode': dcode,
      'dname': dname,
    };
    return map;
  }

}