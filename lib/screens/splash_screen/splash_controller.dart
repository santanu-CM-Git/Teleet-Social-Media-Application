import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/api_service/common_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/screens/block_by_admin_screen/block_by_admin_screen.dart';
import 'package:untitled/screens/interests_screen/interests_screen.dart';
import 'package:untitled/screens/on_boarding_screen/on_boarding_screen.dart';
import 'package:untitled/screens/phone_verify_screen/phone_verify_screen.dart';
import 'package:untitled/screens/profile_picture_screen/profile_picture_screen.dart';
import 'package:untitled/screens/tabbar/tabbar_screen.dart';
import 'package:untitled/screens/username_screen/username_screen.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class SplashController extends BaseController {
  @override
  void onInit() {
    fetchSettings();
    super.onInit();
  }

  void fetchUser(Function() completion) {
    if (SessionManager.shared.getUser()?.id != null) {
      UserService.shared.fetchMyProfile(
        userID: SessionManager.shared.getUser()?.id ?? 0,
        completion: (user) {
          SessionManager.shared.setUser(user);
          completion();
        },
      );
    } else {
      completion();
    }
  }

  void fetchSettings() {
    fetchUser(() {
      CommonService.shared.fetchGlobalSettings((p0) {
        if (p0) {
          Get.offAll(() => gotoView());
        }
      });
    });
  }

  Widget gotoView() {
    if (SessionManager.shared.isLogin()) {
      var user = SessionManager.shared.getUser();
      if (user?.isBlock == 1) {
        return const BlockedByAdminScreen();
      } else if (user?.interestIds == null) {
        return InterestScreen();
      } else if (user?.username == null) {
        return const UserNameScreen();
      } else if (user?.profile == null) {
        return const ProfilePictureScreen();
      } else if (user?.is_phone_verify == 0) {
        return PhoneVerifyScreen(user: user);
      } else {
        onUserLogin(user?.phone, user?.fullName, user?.profile);
        return TabBarScreen();
      }
    }
    return const OnBoardingScreen();
  }
}

void onUserLogin(phone, name, image) {
  /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 2021778181 /*input your AppID*/,
    appSign:
        '331284b8b5c9be50801028b7c82a382eeecf344e12297d358b655ed89495f49d' /*input your AppSign*/,
    userID: phone,
    userName: name,
    plugins: [
      ZegoUIKitSignalingPlugin(),
    ],
    notificationConfig: ZegoCallInvitationNotificationConfig(
      androidNotificationConfig: ZegoCallAndroidNotificationConfig(
        showFullScreen: true,
        fullScreenBackgroundAssetURL: 'assets/images/call.png',
        callChannel: ZegoCallAndroidNotificationChannelConfig(
          channelID: "ZegoUIKit",
          channelName: "Call Notifications",
          sound: "call",
          icon: "call",
        ),
        missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
          channelID: "MissedCall",
          channelName: "Missed Call",
          sound: "missed_call",
          icon: "missed_call",
          vibrate: false,
        ),
      ),
      iOSNotificationConfig: ZegoCallIOSNotificationConfig(
        systemCallingIconName: 'CallKitIcon',
      ),
    ),
    requireConfig: (ZegoCallInvitationData data) {
      final config = (data.invitees.length > 1)
          ? ZegoCallInvitationType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
              : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          : ZegoCallInvitationType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      config.avatarBuilder =
          (context, size, user, extraInfo) => customAvatarBuilder(
                context,
                size,
                user,
                {
                  ...extraInfo,
                  'imageUrl': image, // Dynamic image URL
                },
              );

      /// support minimizing, show minimizing button
      config.topMenuBar.isVisible = true;
      config.pip.enableWhenBackground = true;
      config.topMenuBar.buttons
          .insert(0, ZegoCallMenuBarButtonName.minimizingButton);

      return config;
    },
  );
}

Widget customAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  // Retrieve the dynamic image URL from extraInfo, fallback to robohash if not provided
  final imageUrl =
      extraInfo['imageUrl'] ?? 'https://robohash.org/${user?.id}.png';

  return CachedNetworkImage(
    imageUrl: imageUrl,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) {
      return ZegoAvatar(user: user, avatarSize: size);
    },
  );
}
