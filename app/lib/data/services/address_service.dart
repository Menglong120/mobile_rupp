import 'dart:convert';
import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:customer_order_app/data/models/customer_address_model.dart';
import 'package:http/http.dart' as http;

class AddressService {
  static Future<List<CustomerAddress>> getAddressesByCustomer(int customerId) async {
    final url = Uri.parse('$baseUrl/customer-addresses/customer/$customerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CustomerAddress.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addAddress(CustomerAddress address) async {
    final url = Uri.parse('$baseUrl/customer-addresses');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateAddress(CustomerAddress address) async {
    final url = Uri.parse('$baseUrl/customer-addresses/${address.id}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(int addressId) async {
    final url = Uri.parse('$baseUrl/customer-addresses/$addressId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Deleted successfully'};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
