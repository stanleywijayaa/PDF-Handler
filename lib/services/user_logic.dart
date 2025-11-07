import 'dart:convert';

import 'package:http/http.dart' as http;

final nodeURL = 'http://127.0.0.1:3000';
final nocoURL = 'https://connect.appnicorn.com';

class UserLogic {
  static Future<String> getNocoApp(int uid) async {
    final response = await http.get(
      Uri.parse('$nodeURL/user/noco_app?uid=$uid'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get user data');
    }

    final user = jsonDecode(response.body);
    return user['data']['nocoApp'];
  }
}
