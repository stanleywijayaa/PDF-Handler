import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/schema.dart';

final nocoURL = 'http://localhost:3000';

class TableModel {
  final String tableName;
  final String title;
  late List<Schema> schema;

  TableModel({required this.tableName, required this.title});

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(tableName: json['name'], title: json['title']);
  }

  Future<void> fetchSchema({required int uid}) async {
    final response = await http.post(
      Uri.parse('$nocoURL/data/schema'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid, 'tableName': tableName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get schema');
    }
    final rawSchema = jsonDecode(response.body);
    if (rawSchema['data'] is! List) {
      throw Exception('Invalid table schema received');
    }
    final schemaList =
        rawSchema['data'].map<Schema>((item) {
          return Schema.fromJson(item as Map<String, dynamic>);
        }).toList();
    schema = schemaList;
  }
}
