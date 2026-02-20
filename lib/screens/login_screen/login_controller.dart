import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:untitled/common/api_service/notification_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/managers/firebase_notification_manager.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/screens/block_by_admin_screen/block_by_admin_screen.dart';
import 'package:untitled/screens/interests_screen/interests_screen.dart';
import 'package:untitled/screens/login_screen/sign_in_with_email_screen.dart';
import 'package:untitled/screens/phone_verify_screen/phone_verify_screen.dart';
import 'package:untitled/screens/profile_picture_screen/profile_picture_screen.dart';
import 'package:untitled/screens/tabbar/tabbar_screen.dart';
import 'package:untitled/screens/username_screen/username_screen.dart';
import 'package:untitled/utilities/const.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class LoginController extends BaseController {
  void emailLogin() {
    Get.bottomSheet(SignInWithEmailScreen(
      onSubmit: (fullName, identity) {
        registerUser(
            identity: identity, loginType: LoginType.email, fullName: fullName);
      },
    ), isScrollControlled: true, ignoreSafeArea: false);
  }

  void googleLogin() {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    googleSignIn.signIn().then((googleSignInAccount) {
      print('Email : ${googleSignInAccount?.email}');
      if (googleSignInAccount != null) {
        registerUser(
            fullName: googleSignInAccount.displayName,
            identity: googleSignInAccount.email,
            loginType: LoginType.google);
      }
    });
  }

  void appleLogin() async {
    try {
      AuthorizationCredentialAppleID value =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ]);
      registerUser(
          fullName: '${value.givenName ?? 'John'} ${value.familyName ?? 'Deo'}',
          identity: value.userIdentifier ?? '',
          loginType: LoginType.apple);
    } on SignInWithAppleException catch (exception) {
      log("Something wrong ${exception.toString()}");
    }
  }

  void registerUser(
      {String? fullName,
      required String identity,
      required LoginType loginType}) {
    startLoading();
    FirebaseNotificationManager.shared.getNotificationToken((token) {
      UserService.shared.registration(
          name: fullName,
          identity: identity,
          deviceToken: token,
          loginType: loginType,
          completion: (p0) {
            SessionManager.shared.setLogin(true);

            Widget w = InterestScreen();
            var user = p0.data;
            var phone = user?.phone ?? user?.id ?? 0;

            Purchases.logIn('${user?.id ?? 0}');
            if (user?.isPushNotifications == 1) {
              FirebaseNotificationManager.shared
                  .subscribeToTopic(notificationTopic);
              NotificationService.shared.subscribeToAllMyRoom();
            }
            if (user?.isBlock == 1) {
              w = const BlockedByAdminScreen();
            } else if (user?.interestIds == null) {
              w = InterestScreen();
            } else if (user?.username == null) {
              w = const UserNameScreen();
            } else if (user?.profile == null) {
              w = const ProfilePictureScreen();
            } else if (user?.is_phone_verify == 0) {
              w = PhoneVerifyScreen(user: user);
            } else {
              onUserLogin(phone, user?.fullName, user?.profile ?? null);
              w = TabBarScreen();
            }

            Get.offAll(() => w);
            stopLoading();
          });
    });
  }
}

enum LoginType {
  google(0),
  apple(1),
  email(2);

  const LoginType(this.value);

  final int value;
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
