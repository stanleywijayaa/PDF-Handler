import 'dart:convert';
import 'package:http/http.dart' as http;

final nocoURL = 'http://localhost:3000';

class DataLogic {
  Future<List<Map<String, dynamic>>> getCustomers({
    required int templateId,
    required int customerId,
    Map<String, dynamic>? cred,
  }) async {
    final response = await http.post(
      Uri.parse(
        "$nocoURL/data/list?templateId=$templateId&customerId=$customerId",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"cred": cred}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to fetch customers: ${response.body}");
    }
  }

  Future<List<Object>>? getTables({required int uid}) async {
    final response = await http.post(
      Uri.parse('$nocoURL/data/tables'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({uid: uid}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get tables');
    }
    final tables = jsonDecode(response.body);
    return tables;
  }

  Future<List<Object>>? getSchema({
    required String tableName,
    required int uid,
  }) async {
    final response = await http.post(
      Uri.parse('$nocoURL/data/schema'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({uid: uid, tableName: tableName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get schema');
    }
    final schema = jsonDecode(response.body);
    return schema;
  }
}
