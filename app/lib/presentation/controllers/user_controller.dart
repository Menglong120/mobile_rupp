import 'package:customer_order_app/data/models/user_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  Rxn<UserModel> user = Rxn<UserModel>();

  void setUser(UserModel userData) {
    user.value = userData;
  }

  void setUserFromJson(Map<String, dynamic> json) {
    user.value = UserModel.fromJson(json);
  }

  void clearUser() {
    user.value = null;
  }
}
