import 'id_str_dto.dart';

class IdStr2Dto extends IdStrDto {
  //String id;
  //String str;
  String ext;

  IdStr2Dto({required super.id, required super.str, required this.ext});

  ///convert json to model, static for be parameter !!
  static IdStr2Dto fromJson(Map json){
    return IdStr2Dto(
      id : json['Id'],
      str : json['Str'] ?? '',
      ext : json['Ext'] ?? '',
    );
  }

}