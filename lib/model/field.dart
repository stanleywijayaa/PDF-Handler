class Field {
  final String? type;
  final String fieldName;
  final String dataField;
  int page;
  double x;
  double y;
  double width;
  double height;

  Field({
    required this.fieldName,
    required this.dataField,
    this.type,
    this.x = 0,
    this.y = 0,
    this.height = 0,
    this.width = 0,
    this.page = 1
  });

  void move(double x, double y, int? page) {
    this.x = x;
    this.y = y;
    this.page = page ?? this.page;
  }

  void resize(double width, double height) {
    this.width = width;
    this.height = height;
  }

  Field copyWith({
    double? x,
    double? y,
    double? height,
    double? width,
    int? page,
    String? fieldName,
    String? dataField,
  }) {
    return Field(
      fieldName: fieldName ?? this.fieldName,
      dataField: dataField ?? this.dataField,
      page: page ?? this.page,
      x: x ?? this.x,
      y: y ?? this.y,
      height: height ?? this.height,
      width: width ?? this.width,
      type: type,
    );
  }
}
