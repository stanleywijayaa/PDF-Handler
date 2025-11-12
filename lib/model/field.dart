class Field {
  final String fieldName;
  final String dataField;
  double x;
  double y;
  double width;
  double height;

  Field({
    required this.fieldName,
    required this.dataField,
    this.x = 0,
    this.y = 0,
    this.height = 0,
    this.width = 0,
  });

  void move(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void resize(double width, double height) {
    this.width = width;
    this.height = height;
  }

  Field copyWith({double? x, double? y, double? height, double? width, String? fieldName, String? dataField}){
    return Field(fieldName: fieldName ?? this.fieldName, dataField: dataField ?? this.dataField, x: x ?? this.x, y: y ?? this.y, height: height ?? this.height, width: width ?? this.width);
  }
}
