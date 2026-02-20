import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/utilities/const.dart';

import '../profile_picture_screen/profile_picture_controller.dart';

class EditProfileController extends ProfilePictureController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DetectableTextEditingController bioEditController =
      DetectableTextEditingController(
    detectedStyle:
        MyTextStyle.gilroyRegular(color: cPrimary).copyWith(height: 1.2),
    regExp: detectionRegExp(atSign: false, url: true, hashtag: false)!,
  );
  XFile? backgroundImageFile;

  @override
  void onInit() {
    fetchOldValues();
    bioEditController.addListener(() {
      update(['bio']);
    });
    super.onInit();
  }

  void pickBGImage({ImageSource source = ImageSource.gallery}) async {
    try {
      XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        backgroundImageFile = image;
        update();
      }
    } catch (e) {
      showSnackBar("Invalid Image");
    }
  }

  void fetchOldValues() {
    var user = SessionManager.shared.getUser();
    if (user != null) {
      textController.text = user.username ?? '';
      fullNameController.text = user.fullName ?? '';
      phoneController.text = user.phone ?? '';
      bioEditController.text = user.bio ?? '';
      selectedInterests = user.getInterests();
      checkForUsername();
    }
  }

  void onSubmit() {
    if (!isUsernameAvailable) {
      showSnackBar(LKeys.thisUsernameIsNotAvailable.tr,
          type: SnackBarType.error);
      return;
    }
    startLoading();
    UserService.shared.editProfile(
      profileImage: file,
      bgImage: backgroundImageFile,
      fullName: fullNameController.text,
      phone: phoneController.text,
      username: textController.text,
      bio: bioEditController.text,
      interests: selectedInterests,
      completion: (p0) {
        stopLoading();
        Get.back();
        showSnackBar(LKeys.profileUpdatedSuccessfully.tr,
            type: SnackBarType.success);
      },
    );
  }
}
