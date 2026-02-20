import 'dart:async';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/screens/tabbar/tabbar_screen.dart';
import 'package:untitled/screens/username_screen/username_controller.dart';

class PhoneVerifyController extends UsernameController {
  TextEditingController textController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool isUsernameAvailable = false;
  Map<String, bool> usernameCache = {}; // Cache for username availability
  Duration debounceDuration = const Duration(milliseconds: 500);
  Timer? _debounceTimer;
  bool isNumberVisible = true;
  bool isOTPSend = false;

  // Initialize selectedCountryCode directly
  CountryCode selectedCountryCode = const CountryCode(
    name: 'United States',
    code: 'US',
    dialCode: '+1',
  );

  @override
  void onInit() {
    super.onInit();
    listenForOtp();
    checkForUsername();
    textController.addListener(() {
      _onUsernameChanged();
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      checkForUsername();
    });
  }

  void checkForUsername({Function(bool)? completion}) {
    String username = selectedCountryCode.dialCode + textController.text;

    // Check if the username contains spaces
    if (username.contains(' ')) {
      isUsernameAvailable = false;
      update();
      if (completion != null) {
        completion(false);
      }
      return;
    }

    if (username.length < 10) {
      isUsernameAvailable = false;
      update();
      if (completion != null) {
        completion(false);
      }
      return;
    }

    // Check cache first
    if (usernameCache.containsKey(username)) {
      isUsernameAvailable = usernameCache[username]!;
      update();
      if (completion != null) {
        completion(isUsernameAvailable);
      }
      return;
    }

    // Check if username is current user's username
    if (username.isNotEmpty &&
        SessionManager.shared.getUser()?.username == username) {
      isUsernameAvailable = true;
      usernameCache[username] = true; // Cache the result
      update();
      if (completion != null) {
        completion(false);
      }
      return;
    }

    // Check if username is in restricted list
    if (SessionManager.shared
            .getSettings()
            ?.restrictedUsernames
            ?.firstWhereOrNull((element) =>
                element.title?.toLowerCase() == username.toLowerCase()) !=
        null) {
      isUsernameAvailable = false;
      usernameCache[username] = false; // Cache the result
      update();
      return;
    }

    // API call to check username availability
    UserService.shared.checkForUserPhone(username, 0, (isAvailable) {
      isUsernameAvailable = isAvailable;
      usernameCache[username] = isAvailable; // Cache the result
      if (completion != null) {
        completion(isAvailable);
      }
      update();
    });
  }

  void validateOtp(String otp) {
    String username = selectedCountryCode.dialCode + textController.text;
    var user_id = SessionManager.shared.getUser()?.id;

    startLoading();
    // API call to check username availability
    UserService.shared.validateOtp(user_id, username, otp, (isAvailable) {
      stopLoading();

      if (!isAvailable) {
        showSnackBar("Invalid OTP", type: SnackBarType.error);
      } else {
        Get.offAll(() => TabBarScreen());
      }

      update();
    });
  }

  void sendOTP() {
    if (!isUsernameAvailable) {
      showSnackBar("Phone number is not available", type: SnackBarType.error);
      return;
    }

    startLoading();
    var user_id = SessionManager.shared.getUser()?.id;
    String username = selectedCountryCode.dialCode + textController.text;

    // API call to check username availability
    UserService.shared.checkForUserPhone(username, user_id, (isAvailable) {
      isUsernameAvailable = isAvailable;
      usernameCache[username] = isAvailable; // Cache the result
      if (!isUsernameAvailable) {
        showSnackBar("Phone number is not available", type: SnackBarType.error);
      } else {
        isOTPSend = true;
      }
      update();
      stopLoading();
    });
  }

  void updateUsername() {
    if (!isUsernameAvailable) {
      showSnackBar("Phone number is not available", type: SnackBarType.error);
      return;
    }

    startLoading();
    checkForUsername(
      completion: (isAvailable) {
        if (!isAvailable) {
          showSnackBar("Phone number is not available",
              type: SnackBarType.error);
        } else {
          // UserService.shared.editProfile(
          //   is_phone_verify: 1,
          //   completion: (success) {
          //     stopLoading();
          //     Get.offAll(() => const ProfilePictureScreen());
          //   },
          // );
        }
        stopLoading();
      },
    );
  }

  // SmsAutoFill integration
  void listenForOtp() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void codeUpdated(String code) {
    print("================> $code");
    otpController.text = code; // Automatically fill the OTP input field
    update();
  }
}
