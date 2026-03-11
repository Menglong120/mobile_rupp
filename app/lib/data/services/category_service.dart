import 'dart:convert';
import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final url = "$baseUrl/categories";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
