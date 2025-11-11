class Schema {
  final String title;
  final String fieldName;

  Schema({required this.title, required this.fieldName});

  factory Schema.fromJson(Map<String, dynamic> json) {
    return Schema(fieldName: json['name'], title: json['title']);
  }
}
