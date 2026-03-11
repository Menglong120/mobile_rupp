import 'package:customer_order_app/data/models/order_model.dart';
import 'package:customer_order_app/data/services/order_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class OrderHistoryController extends GetxController {
  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;
  

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<UserController>().user.value;
    if (user != null) {
      fetchOrders(user.cid);
    } else {
      Get.snackbar(
        'Unauthorized',
        'Please login to view your order historry',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> fetchOrders(int customerId) async {
    isLoading.value = true;
    final data = await OrderService.getOrderHistory(customerId);
    orders.value = List<OrderModel>.from(
      data.reversed.map((e) => OrderModel.fromJson(e)),
    );
    isLoading.value = false;
  }
}
