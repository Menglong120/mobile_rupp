import 'package:customer_order_app/presentation/views/orderdetail/orderdetail_controller.dart';
import 'package:get/get.dart';

class OrderdetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderdetailController());
  }
}
