import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/screens/extra_views/buttons.dart';
import 'package:untitled/screens/extra_views/top_bar.dart';
import 'package:untitled/screens/phone_verify_screen/phone_verify_controller.dart';
import 'package:untitled/utilities/const.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../rooms_you_own/create_room_screen/create_room_screen.dart';

class PhoneVerifyScreen extends StatefulWidget {
  final User? user;

  const PhoneVerifyScreen({Key? key, this.user}) : super(key: key);

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  late PhoneVerifyController controller;
  // late CountryCode selectedCountryCode;

  final countryCodePicker = const FlCountryCodePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.put(PhoneVerifyController());
    controller.selectedCountryCode = const CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
    );
    // controller.textController.text = widget.user?.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: pOnBoarding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const TopBarForOnBoarding(
                        titleStart: 'Verify your',
                        titleEnd: 'Phone',
                        desc: 'Verify your phone number',
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Get.height / 9),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 120,
                              backgroundColor: cLightText.withOpacity(0.03),
                            ),
                            CircleAvatar(
                              radius: 90,
                              backgroundColor: cLightText.withOpacity(0.05),
                            ),
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: cLightText.withOpacity(0.07),
                            ),
                            Icon(
                              Icons.call_end,
                              color: cPrimary,
                              size: 50,
                            )
                          ],
                        ),
                      ),
                      GetBuilder<PhoneVerifyController>(
                        builder: (controller) {
                          bool isAvailable = controller.isUsernameAvailable;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      !controller.isOTPSend
                                          ? LKeys.phone.tr
                                          : "OTP",
                                      style: MyTextStyle.gilroySemiBold(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                !controller.isOTPSend
                                    ? Container(
                                        decoration: const ShapeDecoration(
                                          shape: SmoothRectangleBorder(
                                            borderRadius:
                                                SmoothBorderRadius.all(
                                              SmoothRadius(
                                                cornerRadius: 8,
                                                cornerSmoothing:
                                                    cornerSmoothing,
                                              ),
                                            ),
                                          ),
                                          color: cLightBg,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                final code =
                                                    await countryCodePicker
                                                        .showPicker(
                                                            context: context);
                                                if (code != null) {
                                                  setState(() {
                                                    controller
                                                            .selectedCountryCode =
                                                        code;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 12.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      controller
                                                              .selectedCountryCode
                                                              .dialCode ??
                                                          "+1",
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_drop_down),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    controller.textController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  // FilteringTextInputFormatter.allow(
                                                  //   RegExp(r'[0-9]'),
                                                  // ),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: "Mobile Number",
                                                  hintText:
                                                      "Enter your 10 digits Mobile Number",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : PinFieldAutoFill(
                                        codeLength: 6, // Set OTP length
                                        onCodeChanged: (code) {
                                          if (code?.length == 6) {
                                            // Auto-submit when OTP is filled
                                            print("Completed OTP: $code");
                                            if (code != null &&
                                                code.length == 6) {
                                              controller.validateOtp(code);
                                            }
                                          }
                                        },
                                        onCodeSubmitted: (code) {
                                          if (code.length == 6) {
                                            // Auto-submit when OTP is filled
                                            print("Completed OTP: $code");
                                            controller.validateOtp(code);
                                          }
                                        },
                                      ),
                                const SizedBox(height: 10),
                                Text(controller.otpController.text),
                                controller.textController.text.isNotEmpty
                                    ? Text(
                                        isAvailable
                                            ? "Phone Number Is Available"
                                            : "Phone Number Is Not Available",
                                        style: MyTextStyle.gilroySemiBold(
                                          size: 14,
                                          color: isAvailable ? cGreen : cRed,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CommonButton(
                text: "Send OTP",
                onTap: () {
                  controller.sendOTP();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class PhoneVerifyScreen extends StatelessWidget {
//   const PhoneVerifyScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var controller = UsernameController();
//     return SafeArea(
//       child: Padding(
//         padding: pOnBoarding,
//         child: Column(
//           children: [
//             const TopBarForOnBoarding(
//               titleStart: LKeys.setYour,
//               titleEnd: LKeys.username,
//               desc: LKeys.setUsernameDesc,
//             ),
//             const Spacer(),
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 90,
//                   backgroundColor: cLightText.withOpacity(0.03),
//                 ),
//                 CircleAvatar(
//                   radius: 70,
//                   backgroundColor: cLightText.withOpacity(0.05),
//                 ),
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundColor: cLightText.withOpacity(0.07),
//                 ),
//                 Text(
//                   "@",
//                   style: MyTextStyle.gilroyExtraBold(size: 50, color: cPrimary),
//                 )
//               ],
//             ),
//             const Spacer(),
//             UserNameTextField(controller: controller),
//             const Spacer(),
//             CommonButton(text: LKeys.continue1, onTap: () {})
//           ],
//         ),
//       ),
//     );
//   }
// }

class UserNameTextField extends StatelessWidget {
  final PhoneVerifyController controller;

  const UserNameTextField({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneVerifyController>(
      init: controller,
      builder: (controller) {
        bool isAvailable = controller.isUsernameAvailable;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateRoomHeading(
              title: LKeys.username,
              bracketText:
                  "(${controller.textController.text.length}/${Limits.username})",
            ),
            const SizedBox(
              height: 0,
            ),
            Container(
              decoration: const ShapeDecoration(
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(SmoothRadius(
                          cornerRadius: 8, cornerSmoothing: cornerSmoothing))),
                  color: cLightBg),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    "@",
                    style: MyTextStyle.gilroyRegular(color: cLightText),
                  ),
                  Expanded(
                    child: TextField(
                      maxLength: Limits.username,
                      decoration: InputDecoration(
                          hintText: "abc",
                          hintStyle:
                              MyTextStyle.gilroyRegular(color: cLightText),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(0)),
                      cursorColor: cPrimary,
                      style: MyTextStyle.gilroyRegular(color: cLightText),
                      controller: controller.textController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (controller.textController.text !=
                (SessionManager.shared.getUser()?.username ?? ''))
              Text(
                (controller.textController.text == '')
                    ? LKeys.pleaseEnterUsername.tr
                    : isAvailable
                        ? LKeys.thisUsernameIsAvailable.tr
                        : LKeys.thisUsernameIsNotAvailable.tr,
                style: MyTextStyle.gilroySemiBold(
                    size: 14, color: isAvailable ? cGreen : cRed),
              )
          ],
        );
      },
    );
  }
}
