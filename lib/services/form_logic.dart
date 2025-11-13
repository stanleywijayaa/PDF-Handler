import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/field.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf_handler/model/template.dart';

class FormLogic{
  final String templateName;
  final String tableName;
  final List<Field> placedComponents;
  final GlobalKey pdfAreaKey;
  final double pdfWidth;
  final double pdfHeight;

  FormLogic({
    required this.templateName,
    required this.tableName,
    required this.placedComponents,
    required this.pdfAreaKey,
    required this.pdfWidth,
    required this.pdfHeight,
  });

  Future<Map<String, dynamic>?> exportTemplate(BuildContext context) async {
    try {
      //Convert coordinates
      final formFields = convertFieldsToPdfCoords();

      //Construct payload
      final payload = {
        "name": templateName,
        "table_name": tableName,
        "form_fields": formFields,
      };

      //Send to backend
      final response = await http.post(
        Uri.parse("${dotenv.env['NODE_URL']}/createpdf"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      //Handle result
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template exported successfully!")),
        );
        debugPrint("Exported JSON: ${jsonEncode(payload)}");
        final id = response.headers['X-File-ID'];
        final title = response.headers['X-File-title'];
        final tableName = response.headers['X-File-table_name'];
        final fileSize = response.headers['X-File-size'];
        if (id == null|| title == null || tableName == null || fileSize == null ) return null;
        return {
          'id': int.parse(id),
          'title': title,
          'tableName': tableName,
          'fileSize': fileSize
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to export: ${response.body}")),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting: $e")),
      );
    }
  }

  // convert the screen coordinate to  pdf coordinate
  List<Map<String, dynamic>> convertFieldsToPdfCoords() {
    final RenderBox? box =
        pdfAreaKey.currentContext?.findRenderObject() as RenderBox?;

    if (box == null) throw Exception("PDF area not found");

    final Size widgetSize = box.size;
    final double scaleX = pdfWidth / widgetSize.width;
    final double scaleY = pdfHeight / widgetSize.height;

    return placedComponents.map((field) {
      // field should contain label, dataField, and position (x, y)
      final double pdfX = field.x * scaleX;
      final double pdfY = (widgetSize.height - field.y) * scaleY;

      return {
        "field": {
          "name": field.fieldName,
          "pageNum": 0,
          "x": pdfX,
          "y": pdfY,
          "width": field.width,
          "height": field.height,
        },
        "data_field": field.dataField,
      };
    }).toList();
  }
}