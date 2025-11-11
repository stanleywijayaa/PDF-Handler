import 'package:pdf_handler/model/schema.dart';

class TableModel {
  final String tableName;
  final String title;
  late List<Schema> schema;

  TableModel({required this.tableName, required this.title});

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(tableName: json['name'], title: json['title']);
  }
}
