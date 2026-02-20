import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/interests_screen/interests_controller.dart';
import 'package:untitled/screens/profile_picture_screen/profile_picture_screen.dart';

class UsernameController extends InterestsController {
  TextEditingController textController = TextEditingController();
  bool isUsernameAvailable = false;
  Map<String, bool> usernameCache = {}; // Cache for username availability
  Duration debounceDuration = const Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    checkForUsername();
    textController.addListener(() {
      _onUsernameChanged();
    });
  }

  void _onUsernameChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      checkForUsername();
    });
  }

  void checkForUsername({Function(bool)? completion}) {
    String username = textController.text;

    // Check if the username contains spaces
    if (username.contains(' ')) {
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
    if (username.isNotEmpty && SessionManager.shared.getUser()?.username == username) {
      isUsernameAvailable = true;
      usernameCache[username] = true; // Cache the result
      update();
      if (completion != null) {
        completion(false);
      }
      return;
    }

    // Check if username is in restricted list
    if (SessionManager.shared.getSettings()?.restrictedUsernames?.firstWhereOrNull((element) => element.title?.toLowerCase() == username.toLowerCase()) != null) {
      isUsernameAvailable = false;
      usernameCache[username] = false; // Cache the result
      update();
      return;
    }

    // API call to check username availability
    UserService.shared.checkForUsername(username, (isAvailable) {
      isUsernameAvailable = isAvailable;
      usernameCache[username] = isAvailable; // Cache the result
      if (completion != null) {
        completion(isAvailable);
      }
      update();
    });
  }

  void updateUsername() {
    if (!isUsernameAvailable) {
      showSnackBar(LKeys.thisUsernameIsNotAvailable.tr, type: SnackBarType.error);
      return;
    }

    startLoading();
    checkForUsername(
      completion: (isAvailable) {
        if (!isAvailable) {
          showSnackBar(LKeys.thisUsernameIsNotAvailable.tr, type: SnackBarType.error);
        } else {
          UserService.shared.editProfile(
            username: textController.text,
            completion: (success) {
              stopLoading();
              Get.offAll(() => const ProfilePictureScreen());
            },
          );
        }
      },
    );
  }
}
