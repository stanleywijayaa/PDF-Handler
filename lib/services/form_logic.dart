import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf_handler/model/form.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final nodeURL = dotenv.env['NODE_URL'];
final nocoURL = dotenv.env['NOCO_URL'];

class FormLogic{
  
}