import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/template.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final nodeURL = dotenv.env['NODE_URL'];
final nocoURL = dotenv.env['NOCO_URL'];

class TemplateLogic {
  static Future<List<Template>> fetchTemplate(String nocoApp) async {
    final detailsResponse = await http.post(
      Uri.parse('$nodeURL/templates/all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nocoApp': nocoApp}),
    );
    if (detailsResponse.statusCode != 200) {
      throw Exception('Failed to load templates');
    }
    final data = json.decode(detailsResponse.body);
    List details = data['data'];

    return details.map((detail) {
      return Template.fromJson(detail);
    }).toList();
  }

  Future<Uint8List?> getTemplate({required int templateId}) async {
    final response = await http.get(
      Uri.parse('$nodeURL/templates/getFile?templateId=$templateId'),
    );
    if (response.statusCode == 200) {
      final data = response.bodyBytes;
      return data;
    } else {
      throw Exception("Failed to fetch PDF");
    }
  }
}
