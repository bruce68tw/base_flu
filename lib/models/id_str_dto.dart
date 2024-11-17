class IdStrDto {
  String id;
  String str;

  IdStrDto({required this.id, this.str=''});

  ///convert json to model, static for be parameter !!
  static IdStrDto fromJson(Map json){
    var id = json['Id'].toString(); //may be int
    return IdStrDto(
      id : id, 
      str : (json['Str'] == null) ? id : json['Str'],
    );
  }

}