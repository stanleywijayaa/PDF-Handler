import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/field.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/services/user_logic.dart';

class FormLogic{
  final String templateName;
  final String tableName;
  final List<Field> placedComponents;
  final GlobalKey pdfAreaKey;
  final double pdfWidth;
  final double pdfHeight;
  final int UID;
  final Uint8List fileBytes;

  FormLogic({
    required this.templateName,
    required this.tableName,
    required this.placedComponents,
    required this.pdfAreaKey,
    required this.pdfWidth,
    required this.pdfHeight,
    required this.UID,
    required this.fileBytes,
  });

  Future<Map<String, dynamic>?> exportTemplate(BuildContext context) async {
    try {
      //Convert coordinates
      final formFields = convertFieldsToPdfCoords();

      final nocoApp = await UserLogic.getNocoApp(UID);

      //Construct payload
      final form = {
        "name": templateName,
        "table_name": tableName,
        "form_fields": formFields,
      };

      //Send to backend
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://localhost:3000/createpdf"),
      );

      request.fields['form'] = jsonEncode(form);
      if (nocoApp == null) return null;
      request.fields['nocoApp'] = nocoApp;
      request.files.add(http.MultipartFile.fromBytes(
        "pdf",
        fileBytes,
        filename: 'a.pdf',
        contentType: MediaType('application', 'pdf')
      ));

      var response = await request.send();

      final responseData = await http.Response.fromStream(response);

      //Handle result
      if (responseData.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template exported successfully!")),
        );
        debugPrint("Exported JSON: ${jsonEncode(form)}");
        final id = response.headers['x-file-id'];
        final title = response.headers['x-file_title'];
        final tableName = response.headers['x-file_table_name'];
        final fileSize = response.headers['x-file_size'];
        print('$id,$title,$tableName,$fileSize');
        if (id == null|| title == null || tableName == null || fileSize == null ) return null;
        return {
          'id': int.parse(id),
          'title': title,
          'tableName': tableName,
          'fileSize': int.parse(fileSize)
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to export: ${responseData.statusCode} ${responseData.reasonPhrase}")),
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
          "pageNum": field.page,
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