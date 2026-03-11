import 'package:customer_order_app/core/routes/routes_name.dart';
import 'package:customer_order_app/presentation/views/about_us/about_us_binding.dart';
import 'package:customer_order_app/presentation/views/about_us/about_us_view.dart';
import 'package:customer_order_app/presentation/views/account_info/account_info_binding.dart';
import 'package:customer_order_app/presentation/views/account_info/account_info_view.dart';
import 'package:customer_order_app/presentation/views/auth/create_new_ps/create_new_ps_binding.dart';
import 'package:customer_order_app/presentation/views/auth/create_new_ps/create_new_ps_view.dart';
import 'package:customer_order_app/presentation/views/auth/forget_ps/forget_ps_binding.dart';
import 'package:customer_order_app/presentation/views/auth/forget_ps/forget_ps_view.dart';
import 'package:customer_order_app/presentation/views/auth/login/login_binding.dart';
import 'package:customer_order_app/presentation/views/auth/login/login_view.dart';
import 'package:customer_order_app/presentation/views/auth/onbording/onbording_binding.dart';
import 'package:customer_order_app/presentation/views/auth/onbording/onbording_view.dart';
import 'package:customer_order_app/presentation/views/auth/otp_forget_ps/otp_forget_ps_binding.dart';
import 'package:customer_order_app/presentation/views/auth/otp_forget_ps/otp_forget_ps_view.dart';
import 'package:customer_order_app/presentation/views/auth/otp_verify/otp_verify_binding.dart';
import 'package:customer_order_app/presentation/views/auth/otp_verify/otp_verify_view.dart';
import 'package:customer_order_app/presentation/views/auth/setup_account/setup_account_binding.dart';
import 'package:customer_order_app/presentation/views/auth/setup_account/setup_account_view.dart';
import 'package:customer_order_app/presentation/views/auth/signup/signup_binding.dart';
import 'package:customer_order_app/presentation/views/auth/signup/signup_view.dart';
import 'package:customer_order_app/presentation/views/cart/cart_binding.dart';
import 'package:customer_order_app/presentation/views/cart/cart_view.dart';
import 'package:customer_order_app/presentation/views/checkout/checkout_binding.dart';
import 'package:customer_order_app/presentation/views/checkout/checkout_view.dart';
import 'package:customer_order_app/presentation/views/checkout/khqr_view.dart';
import 'package:customer_order_app/presentation/views/home/detail_product/detail_product_binding.dart';
import 'package:customer_order_app/presentation/views/home/detail_product/detail_product_view.dart';
import 'package:customer_order_app/presentation/views/home/home_screen/home_binding.dart';
import 'package:customer_order_app/presentation/views/home/home_screen/home_view.dart';
import 'package:customer_order_app/presentation/views/main_screen/main_screen_binding.dart';
import 'package:customer_order_app/presentation/views/main_screen/main_screen_view.dart';
import 'package:customer_order_app/presentation/views/order_history/order_history_binding.dart';
import 'package:customer_order_app/presentation/views/order_history/order_history_view.dart';
import 'package:customer_order_app/presentation/views/order_success/order_success_view.dart';
import 'package:customer_order_app/presentation/views/orderdetail/orderdetail_binding.dart';
import 'package:customer_order_app/presentation/views/orderdetail/orderdetail_view.dart';
import 'package:customer_order_app/presentation/views/search/search_binding.dart';
import 'package:customer_order_app/presentation/views/search/search_view.dart';
import 'package:customer_order_app/presentation/views/setting/setting_binding.dart';
import 'package:customer_order_app/presentation/views/setting/setting_view.dart';
import 'package:customer_order_app/presentation/views/splash/splash_binding.dart';
import 'package:customer_order_app/presentation/views/splash/splash_view.dart';
import 'package:customer_order_app/presentation/views/wishlist/wishlist_binding.dart';
import 'package:customer_order_app/presentation/controllers/address_binding.dart';
import 'package:customer_order_app/presentation/views/address/add_address_view.dart';
import 'package:customer_order_app/presentation/views/address/address_list_view.dart';
import 'package:customer_order_app/presentation/views/wishlist/wishlist_view.dart';
import 'package:get/route_manager.dart';

class RoutesApp {
  RoutesApp._();

  static final routesAppp = [
    GetPage(
      name: RoutesName.mainScreen,
      page: () => MainScreenView(),
      binding: MainScreenBinding(),
    ),
    GetPage(
      name: RoutesName.homeScreen,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RoutesName.productDetailScreen,
      page: () => DetailProductView(),
      binding: DetailProductBinding(),
    ),
    GetPage(
      name: RoutesName.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: RoutesName.loginScreen,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: RoutesName.registerScreen,
      page: () => SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: RoutesName.otpVerify,
      page: () => OtpVerifyView(),
      binding: OtpVerifyBinding(),
    ),
    GetPage(
      name: RoutesName.setUpAccount,
      page: () => SetupAccountView(),
      binding: SetupAccountBinding(),
    ),
    GetPage(
      name: RoutesName.forgetPS,
      page: () => ForgetPsView(),
      binding: ForgetPsBinding(),
    ),
    GetPage(
      name: RoutesName.newPS,
      page: () => CreateNewPsView(),
      binding: CreateNewPsBinding(),
    ),
    GetPage(
      name: RoutesName.onBording,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: RoutesName.cartScreen,
      page: () => CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: RoutesName.wishlist,
      page: () => WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: RoutesName.otpForgetPsVerify,
      page: () => OtpForgetPsView(),
      binding: OtpForgetPsBinding(),
    ),
    GetPage(
      name: RoutesName.settingsScreen,
      page: () => SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: RoutesName.card,
      page: () => CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: RoutesName.checkoutScreen,
      page: () => CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: RoutesName.orderHistory,
      page: () => OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),
    GetPage(
      name: RoutesName.orderDetail,
      page: () => OrderdetailView(),
      binding: OrderdetailBinding(),
    ),
    GetPage(
      name: RoutesName.orderSuccess,
      page: () => OrderSuccessView(),
      // binding: OrderdetailBinding(),
    ),
    GetPage(
      name: RoutesName.accountInfo,
      page: () => AccountInfoView(),
      binding: AccountInfoBinding(),
    ),
    GetPage(
      name: RoutesName.searchScreen,
      page: () => SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: RoutesName.aboutUs,
      page: () => AboutUsView(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: RoutesName.khqr,
      page: () => const KhqrView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: RoutesName.addAddressScreen,
      page: () => const AddAddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: RoutesName.addressListScreen,
      page: () => const AddressListView(),
      binding: AddressBinding(),
    ),
  ];
}
