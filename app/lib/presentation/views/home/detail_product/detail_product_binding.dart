import 'package:customer_order_app/presentation/views/home/detail_product/detail_product_controller.dart';
import 'package:get/get.dart';

class DetailProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetailProductController());
  }
}

