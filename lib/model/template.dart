import 'dart:typed_data';

class Template {
  final int id;
  final String title;
  final Uint8List? pdfFile;
  final String tableName;
  final int fileSize;

  Template({
    required this.id,
    required this.title,
    this.pdfFile,
    required this.tableName,
    required this.fileSize,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      title: json['title'],
      tableName: json['table_name'],
      fileSize: json['size'],
    );
  }
}
