import 'package:pdf_handler/model/field.dart';

class FormModel {
  String? name;
  final String nocoApp;
  final String tableName;
  final List<Field> fields = List.empty(growable: true);

  FormModel({required this.name, required this.nocoApp, required this.tableName});

  void addField(Field field) {
    fields.add(field);
  }

  bool removeField(Field field) {
    final removed = fields.remove(field);
    return removed;
  }
}
