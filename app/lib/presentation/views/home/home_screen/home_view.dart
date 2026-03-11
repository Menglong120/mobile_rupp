import 'package:animate_do/animate_do.dart';
import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/data/models/product_model.dart';
import 'package:customer_order_app/presentation/views/home/home_screen/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () {
          return Skeletonizer(
            enabled: controller.isLoading.value,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 16),
                _buildSearchProduct(),
                const SizedBox(height: 20),
                _buildSectionTitle("Category"),
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.listCategori.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        var item = controller.listCategori[index];
                        return _buildCategoriProduct(item);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("New Arrival"),
                const SizedBox(height: 20),
                Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1 / 1.6,
                    ),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = controller.filteredProducts[index];
                      return FadeInUp(
                        duration: Duration(
                          milliseconds: 300 + (index * 100),
                        ),
                        child: _buildGridProduct(product),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchProduct() {
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            RoutesName.searchScreen,
            arguments: Get.find<HomeController>().products.toList(),
          );
        },
        child: AbsorbPointer(
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                child: SvgPicture.asset('assets/icons/Search.svg'),
              ),
              hintText: 'Search products...',
              fillColor: ThemesApp.primaryColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriProduct(Map item) {
    final isSelected = controller.selectedCategoryId.value == item['id'];
    return GestureDetector(
      onTap: () => controller.setCategory(item['id']),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? ThemesApp.secondaryColor : ThemesApp.textHintColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            item['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridProduct(ProductModel product) {
    return Bounceable(
      onTap: () {
        Get.toNamed(
          RoutesName.productDetailScreen,
          arguments: product,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.grey.shade100,
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: Hero(
                      tag: product.id,
                      child: Image.network(
                        product.getImageUrl(),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded || frame != null) {
                            return child;
                          }
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 34,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Obx(() {
                  final isFavorited =
                      controller.isWishlisted(product.id.toString());
                  return Bounceable(
                    onTap: () => controller.toggleWishlist(product),
                    child: Icon(
                      isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorited ? Colors.red : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "\$${product.price}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
