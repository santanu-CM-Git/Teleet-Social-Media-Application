import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/screens/sheets/confirmation_sheet.dart';
import 'package:untitled/utilities/const.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseController extends GetxController {
  static var share = BaseController();
  bool isLoading = false;

  void startLoading() {
    loader();
    isLoading = true;
    update();
  }

  void stopLoading([List<Object>? ids, bool condition = true]) {
    if (isLoading && (Get.isDialogOpen ?? false)) {
      Get.back();
      isLoading = false;
      update();
    }
  }

  loader({double? value}) {
    Get.dialog(Center(
      child: CircularProgressIndicator(
        color: cPrimary,
      ),
    ));
    // showDialog(
    //   context: Get.context!,
    //   // barrierDismissible: true,
    //   barrierDismissible: false,
    //   builder: (context) {
    //     return const Center(
    //       child: CircularProgressIndicator(
    //         color: cPrimary,
    //       ),
    //     );
    //   },
    // );
  }

  void materialSnackBar(String title, {SnackBarType type = SnackBarType.info, String? message, Function()? onCompletion}) {
    var color = type == SnackBarType.success ? cGreen : (type == SnackBarType.error ? cRed : cBlack);
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(
          title.toString(),
          style: MyTextStyle.gilroySemiBold(size: 15, color: color),
        ),
        backgroundColor: cWhite,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.endToStart,
      ),
    );
  }

  void showSnackBar(String title, {SnackBarType type = SnackBarType.info, String? message, Function()? onCompletion}) {
    if (Get.isSnackbarOpen) {
      return;
    }
    var color = type == SnackBarType.success ? cGreen : (type == SnackBarType.error ? cRed : cBlack);
    IconData icon = type == SnackBarType.success ? Icons.check_circle_rounded : (type == SnackBarType.error ? Icons.cancel_rounded : Icons.info_rounded);
    Get.rawSnackbar(
      messageText: Text(
        title.tr,
        style: MyTextStyle.gilroyBold(color: color),
      ),
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 10,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      icon: Icon(
        icon,
        color: color,
        size: 24,
      ),
      backgroundColor: cWhite,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void showConfirmationSheet({required desc, required buttonTitle, required onTap}) {
    Get.bottomSheet(ConfirmationSheet(
      desc: desc,
      buttonTitle: buttonTitle,
      onTap: onTap,
    ));
  }

  void handleURL({required String url}) async {
    var urlString = url;
    if (!urlString.startsWith('http')) {
      urlString = 'https:\\\\' + urlString;
    }
    final Uri uri = Uri.parse(urlString);

    if (!await launchUrl(uri)) {
      print('Could not launch $uri');
    }
  }
}

enum SnackBarType { info, error, success }
