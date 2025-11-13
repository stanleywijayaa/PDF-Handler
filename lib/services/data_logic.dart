import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/table.dart';

final nodeURL = 'http://localhost:3000';

class DataLogic {
  Future<List<Map<String, dynamic>>> getCustomers({
    required int templateId,
    required int customerId,
    Map<String, dynamic>? cred,
  }) async {
    final response = await http.post(
      Uri.parse(
        "$nodeURL/data/list?templateId=$templateId&customerId=$customerId",
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

  Future<List<TableModel>> getTables({required int uid}) async {
    final response = await http.post(
      Uri.parse('$nodeURL/data/tables'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get tables');
    }
    final rawTables = jsonDecode(response.body);
    if (rawTables['data'] is! List) {
      throw Exception('Invalid table list received');
    }
    final tablesList =
        (rawTables['data'] as List)
            .map((item) => TableModel.fromJson(item as Map<String, dynamic>))
            .toList();
    return tablesList;
  }

  Future<Uint8List?> fillData({
    required int templateId, 
    required int customerId, 
    required Uint8List fileBytes,
    required int dataId,
  }) async {
    final url = Uri.parse('$nodeURL/fillpdf?templateId=$templateId&customerId=$customerId&dataId=$dataId');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'pdf',
        fileBytes,
        filename: 'data.pdf',
      ),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = response.bodyBytes;
      return data;
    } else {
      //print('Error ${response.statusCode}: ${response.body}');
      throw Exception("Failed to fill PDF data");
    }
  }
}
