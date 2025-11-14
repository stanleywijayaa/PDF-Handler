class Schema {
  final String title;
  final String fieldName;
  final List<Schema>? childSchema;

  Schema({
    required this.title, 
    required this.fieldName,
    this.childSchema,
  });

  factory Schema.fromJson(Map<String, dynamic> json) {
    return Schema(
      fieldName: json['name'],
      title: json['title'],
      childSchema: json['child'] != null
          && json['child']['fields'] != null
          ? (json['child']['fields'] as List)
              .map((child) => Schema.fromJson(child))
              .toList()
          : null,
    );
  }
}
