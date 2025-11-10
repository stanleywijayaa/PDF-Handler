import 'dart:convert';
import 'package:http/http.dart' as http;

final nocoURL = 'https://connect.appnicorn.com';

class ApiService {
    Future<List<Map<String, dynamic>>> getCustomers({
        required int templateId,
        required int customerId,
        Map<String, dynamic>? cred,
    }) async {
        final response = await http.post(
            Uri.parse("$nocoURL/data/list?templateId=$templateId&customerId=$customerId"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"cred": cred}),
        );

        if (response.statusCode == 200) {
            final List <dynamic> data = jsonDecode(response.body);
            return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
            throw Exception("Failed to fetch customers: ${response.body}");
        }
    }
}