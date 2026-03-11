import 'package:customer_order_app/data/models/product_model.dart';
import 'package:get/get.dart';

class SearchsController extends GetxController {
  final allProducts = <ProductModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final argProducts = Get.arguments as List<ProductModel>? ?? [];
    allProducts.assignAll(argProducts);
    filteredProducts.assignAll(argProducts);
  }

  void setSearchText(String value) async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 300));

    if (value.isEmpty) {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(
        allProducts
            .where((p) =>
                p.name.toLowerCase().contains(value.toLowerCase()) ||
                p.description.toLowerCase().contains(value.toLowerCase()))
            .toList(),
      );
    }

    isLoading.value = false;
  }
}
