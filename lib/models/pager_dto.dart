class PagerDto<T> {
  ///same to jQuery DataTables
  //final int draw;
  ///return totalRows
  final int recordsFiltered;
  ///return page rows
  final List<T> rows;

  PagerDto({required this.recordsFiltered, required this.rows});

  ///convert json string to PagerVo model
  ///無法使用 factory constructor 省略第2個參數 !!
  ///@jsonStr
  ///@fromJson static function parameter !!
  factory PagerDto.fromJson(Map<String, dynamic>json, Function fromJson) {
    var jsons = (json['data'] == null) ? [] : json['data'] as List;
    var rows = jsons.map((a) => fromJson(a)).cast<T>().toList(); //has cast<>

    return PagerDto(
      //draw: json['draw'],
      recordsFiltered: json['recordsFiltered'],
      rows: rows,
    );
  }
  
}//class