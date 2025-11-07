import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/template.dart';

final nodeURL = 'http://localhost:3000';
final nocoURL = 'https://connect.appnicorn.com';

class TemplateLogic {
  static Future<List<Template>> fetchTemplate(String nocoApp) async {
    final detailsResponse = await http.post(
      Uri.parse('$nodeURL/templates/all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nocoApp': nocoApp}),
    );
    if (detailsResponse.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = json.decode(detailsResponse.body);
    List details = data['data'];

    final futures = details.map((detail) async {
      final fileResponse = await http.get(
        Uri.parse('$nocoURL${detail['url']}'),
      );
      final file = fileResponse.bodyBytes;
      return Template.fromJson(detail, file);
    });

    final templates = await Future.wait(futures);
    return templates;
  }
}
