import 'package:flutter/material.dart';

const String appName = "Teleet";
const String baseURL = "https://www.teleet.com/";
const String itemBaseURL = "";
const String apiURL = "${baseURL}api/";
const String termsURL = "${baseURL}termsOfUse";
const String privacyURL = "${baseURL}privacyPolicy";
const String helpURL = "https://www.teleet.com/help";
const String notificationTopic = "teleet";

const String revenuecatAppleApiKey = 'YOUR_IOS_REVENUECAT_API_KEY';
const String revenuecatAndroidApiKey = 'YOUR_ANDROID_REVENUECAT_API_KEY';

const String agoraAppId = 'YOUR_AGORA_APP_ID';
const String agoraCustomerId = 'YOUR_AGORA_CUSTOMER_ID';
const String agoraCustomerSecret = 'YOUR_AGORA_CUSTOMER_SECRET';

const String sightEngineModels = 'nudity';

class Limits {
  static int username = 20;
  static int roomDescCount = 120;
  static int bioCount = 120;
  static int interestCount = 5;
  static int pagination = 20;
  static int storyDuration = 3;

  static double imageSize = 720;
  static int quality = 100;
}

const List<String> storyQuickReplyEmojis = ['😂', '😮', '😍', '😢', '👏', '🔥'];

extension O on String {
  String addBaseURL() {
    return itemBaseURL + this;
  }
}

// Colors
const cPrimary = Color(0xFF0B99CF);
const cPulsing = Color(0xFF9AD6F4);
const cWhite = Colors.white;
const cBlack = Color(0xFF0E0E0E);
const cMainText = Color(0xFF2d2d2d);
const cLightText = Color(0xFF979797);
const cLightIcon = Color(0xFFAEAEAE);
const cDarkText = Color(0xFF585858);
const cLightBg = Color(0xFFF1F1F1);
const cDarkBG = Color(0xFF212121);
const cBG = Color(0xFFF2F2F2);
const cGreen = Color(0xFF2CA757);
const cDarkGreen = Color(0xFF183321);
const cBlueTick = Color(0xFF1D9BF0);
const cRed = Color(0xFFFF6565);

const cAudioSpaceBG = Color(0xFF272727);
const cAudioSpaceDarkBG = Color(0xFF222222);
const cAudioSpaceLightBG = Color(0xFF3B3B3B);
const cAudioSpaceText = Color(0xFFD4D4D4);

const refreshIndicatorColor = cBlack;
const refreshIndicatorBgColor = cPrimary;

const cBlackSheetBG = Color(0xFF1F1F1F);
const cHashtagColor = Color(0xFF25CC5F);

// Corner Radius-Smoothing
const cornerSmoothing = 1.0;
