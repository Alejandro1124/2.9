import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://3.85.140.255:5000';

  static Future<void> sendStatus(int status, String userName) async {
    final url = Uri.parse('$baseUrl/status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status, 'name': userName}),
    );
    if (response.statusCode == 200) {
      print("Status enviado exitosamente.");
    } else {
      print("Error al enviar el status: ${response.body}");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDatabaseRecords() async {
    final url = Uri.parse('$baseUrl/status');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("Error al obtener los registros: ${response.body}");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchExtraRecords() async {
    final url = Uri.parse('$baseUrl/extra');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("Error al obtener los registros adicionales: ${response.body}");
      return [];
    }
  }
}
