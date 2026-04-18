import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> fetchData() async {
    try {
      final res = await http.get(
        Uri.parse("http://jsonplaceholder.typicode.com/posts"),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return []; // 👈 don't crash
      }
    } catch (e) {
      return []; // 👈 handle no internet
    }
  }
}
