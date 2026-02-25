import 'package:customer_order_app/data/models/customer_address_model.dart';
import 'package:customer_order_app/data/services/address_service.dart';
import 'package:customer_order_app/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  var addressList = <CustomerAddress>[].obs;
  var isLoading = false.obs;
  var selectedAddress = Rxn<CustomerAddress>();

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final user = Get.find<UserController>().user.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      final addresses = await AddressService.getAddressesByCustomer(user.cid);
      addressList.assignAll(addresses);
      
      if (addressList.isNotEmpty) {
        selectedAddress.value = addressList.firstWhere(
          (a) => a.isDefault,
          orElse: () => addressList.first,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress(String addressLine, double lat, double lng, String? label, bool isDefault) async {
    final user = Get.find<UserController>().user.value;
    if (user == null) return false;

    final newAddress = CustomerAddress(
      customerId: user.cid,
      addressLine: addressLine,
      latitude: lat,
      longitude: lng,
      label: label,
      isDefault: isDefault,
    );

    isLoading.value = true;
    final result = await AddressService.addAddress(newAddress);
    isLoading.value = false;

    if (result['success']) {
      await fetchAddresses();
      return true;
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to add address');
      return false;
    }
  }

  void selectAddress(CustomerAddress address) {
    selectedAddress.value = address;
  }

  Future<void> deleteAddress(int addressId) async {
    isLoading.value = true;
    final result = await AddressService.deleteAddress(addressId);
    isLoading.value = false;

    if (result['success']) {
      await fetchAddresses();
      Get.snackbar('Success', 'Address deleted successfully');
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to delete address');
    }
  }
}
