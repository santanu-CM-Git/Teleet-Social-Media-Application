import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/string_extension.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/extra_views/logo_tag.dart';
import 'package:untitled/screens/login_screen/login_controller.dart';
import 'package:untitled/screens/rooms_you_own/create_room_screen/create_room_screen.dart';
import 'package:untitled/utilities/const.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class SignInWithEmailScreen extends StatefulWidget {
  final Function(String? fullName, String identity) onSubmit;

  const SignInWithEmailScreen({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<SignInWithEmailScreen> createState() => _SignInWithEmailScreenState();
}

class _SignInWithEmailScreenState extends State<SignInWithEmailScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final countryCodePicker = const FlCountryCodePicker();
  CountryCode? selectedCountryCode =
      const CountryCode(name: 'United States', code: 'US', dialCode: '+1');

  EmailSignInType type = EmailSignInType.signIn;
  BaseController baseController = BaseController();
  var height = Get.height / 40;

  @override
  void initState() {
    emailController.addListener(refresh);
    phoneController.addListener(refresh);
    fullNameController.addListener(refresh);
    passwordController.addListener(refresh);
    confirmPasswordController.addListener(refresh);
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ClipSmoothRect(
        radius: const SmoothBorderRadius.only(
            topRight: SmoothRadius(
                cornerRadius: 12, cornerSmoothing: cornerSmoothing),
            topLeft: SmoothRadius(
                cornerRadius: 12, cornerSmoothing: cornerSmoothing)),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      child: const Icon(
                        Icons.close_rounded,
                        color: cBlack,
                        size: 30,
                      ),
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  const Spacer()
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const LogoTag(width: 100),
                    const SizedBox(height: 40),
                    getTitle().toTextTR(MyTextStyle.gilroyBold(size: 23)),
                    const SizedBox(height: 20),
                    view(),
                    const SizedBox(height: 20),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget view() {
    switch (type) {
      case EmailSignInType.signIn:
        return signView();
      case EmailSignInType.signUp:
        return signUpView();
      case EmailSignInType.forgot:
        return forgotView();
    }
  }

  String getTitle() {
    switch (type) {
      case EmailSignInType.signIn:
        return LKeys.signInWithEmail;
      case EmailSignInType.signUp:
        return LKeys.register;
      case EmailSignInType.forgot:
        return LKeys.forgotPassword;
    }
  }

  Widget signView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          MyTextField(controller: emailController, placeHolder: LKeys.email),
          const SizedBox(height: 12),
          SecureTextField(
            controller: passwordController,
            placeHolder: LKeys.password,
          ),
          EmailButton(
              text: LKeys.continue_.tr,
              isDisable: emailController.text.isEmpty ||
                  passwordController.text.isEmpty,
              onTap: () async {
                baseController.startLoading();
                try {
                  final credential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  if (credential.user?.emailVerified == true) {
                    Get.back();
                    widget.onSubmit(
                        fullNameController.text == ""
                            ? null
                            : fullNameController.text,
                        emailController.text);
                  } else {
                    baseController.stopLoading();
                    baseController.showSnackBar(LKeys.pleaseVerifyToSignIn.tr,
                        type: SnackBarType.error);
                  }
                } on FirebaseAuthException catch (e) {
                  baseController.stopLoading();
                  baseController.showSnackBar(e.message ?? '',
                      type: SnackBarType.error);
                } catch (e) {
                  print(e);
                }
              }),
          Row(
            children: [
              LKeys.doNtHaveAnAccount.toTextTR(
                  MyTextStyle.gilroyLight(color: cLightText, size: 14)),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: showSignUp,
                child: LKeys.signUp.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: showForgot,
                child: LKeys.forgotPassword.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget forgotView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          LKeys.forgotPasswordDisc.toTextTR(
            MyTextStyle.gilroyLight(color: cLightText, size: 14),
          ),
          const SizedBox(height: 10),
          MyTextField(controller: emailController, placeHolder: LKeys.email),
          EmailButton(
              text: LKeys.reset.tr,
              isDisable: emailController.text.isEmpty,
              onTap: () async {
                baseController.startLoading();
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text);
                  baseController.stopLoading();
                  baseController.showSnackBar(LKeys.linkSendToReset.tr,
                      type: SnackBarType.success);
                  setState(() {
                    type = EmailSignInType.signIn;
                  });
                } on FirebaseAuthException catch (e) {
                  baseController.stopLoading();
                  baseController.showSnackBar(e.message ?? '',
                      type: SnackBarType.error);
                } catch (e) {
                  print(e);
                  baseController.stopLoading();
                }
              }),
          Row(
            children: [
              LKeys.doNtHaveAnAccount.toTextTR(
                  MyTextStyle.gilroyLight(color: cLightText, size: 14)),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: showSignUp,
                child: LKeys.signUp.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: showForgot,
                child: LKeys.forgotPassword.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget signUpView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          MyTextField(controller: emailController, placeHolder: LKeys.email),
          const SizedBox(height: 12),
          MyTextField(
              controller: fullNameController, placeHolder: LKeys.fullName),
          const SizedBox(height: 12),
          SecureTextField(
            controller: passwordController,
            placeHolder: LKeys.password,
          ),
          const SizedBox(height: 12),
          SecureTextField(
            controller: confirmPasswordController,
            placeHolder: LKeys.confirmPassword,
          ),

          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final code =
                      await countryCodePicker.showPicker(context: context);
                  if (code != null) {
                    setState(() {
                      selectedCountryCode = code;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Text(selectedCountryCode?.dialCode ??
                          "+1"), // Default to +1
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0), // Add spacing between the widgets
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    hintText: "Enter your 10 digits Mobile Number",
                  ),
                ),
              ),
            ],
          ),
          // MyTextField(controller: phoneController, placeHolder: LKeys.phone),
          const SizedBox(height: 12),
          EmailButton(
            text: LKeys.register.tr,
            isDisable: fullNameController.text.isEmpty ||
                emailController.text.isEmpty ||
                phoneController.text.isEmpty ||
                passwordController.text.isEmpty ||
                confirmPasswordController.text.isEmpty,
            onTap: () async {
              if (baseController.isLoading) {
                return;
              }

              if (phoneController.text.length != 10) {
                baseController.showSnackBar("Phone Number must be of 10 digit",
                    type: SnackBarType.error);
                return;
              }

              if (passwordController.text != confirmPasswordController.text) {
                baseController.showSnackBar(LKeys.passwordMismatched.tr,
                    type: SnackBarType.error);
                return;
              }

              baseController.startLoading();

              try {
                UserCredential cred =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );

                await cred.user?.sendEmailVerification();
                UserService.shared.registration(
                  name: fullNameController.text,
                  identity: emailController.text,
                  deviceToken: "deviceToken",
                  loginType: LoginType.email,
                  phone: (selectedCountryCode?.dialCode ?? '+1') +
                      phoneController.text,
                  completion: (p0) {
                    baseController.stopLoading();
                    baseController.showSnackBar(LKeys.verificationLinkSent.tr,
                        type: SnackBarType.success);
                    setState(() {
                      type = EmailSignInType.signIn;
                    });
                  },
                );
              } on FirebaseAuthException catch (e) {
                baseController.stopLoading();
                baseController.showSnackBar(e.message ?? '',
                    type: SnackBarType.error);
              } catch (e) {
                print(e);
              }
            },
          ),
          Row(
            children: [
              LKeys.iHaveAnAccount.toTextTR(
                  MyTextStyle.gilroyLight(color: cLightText, size: 14)),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: showSignIn,
                child: LKeys.signIn.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: showForgot,
                child: LKeys.forgotPassword.toTextTR(
                    MyTextStyle.gilroySemiBold(color: cBlack, size: 14)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void showSignIn() {
    setState(() {
      type = EmailSignInType.signIn;
    });
  }

  void showSignUp() {
    setState(() {
      type = EmailSignInType.signUp;
    });
  }

  void showForgot() {
    setState(() {
      type = EmailSignInType.forgot;
    });
  }
}

class EmailButton extends StatelessWidget {
  final String text;
  final bool isDisable;
  final Function() onTap;

  const EmailButton(
      {Key? key,
      required this.text,
      required this.onTap,
      required this.isDisable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!isDisable) {
            onTap();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDisable ? cLightText.withOpacity(0.4) : cPrimary,
            borderRadius: BorderRadius.circular(12),
            // boxShadow: kMyBoxShadow,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.only(bottom: 15, top: 15),
          alignment: Alignment.center,
          width: double.infinity,
          child: Text(
            text.tr,
            style: MyTextStyle.gilroySemiBold(),
          ),
        ));
  }
}

enum EmailSignInType { signIn, signUp, forgot }

class SecureTextField extends StatefulWidget {
  final String placeHolder;
  final TextEditingController controller;

  const SecureTextField(
      {Key? key, required this.placeHolder, required this.controller})
      : super(key: key);

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool isShowPassword = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyTextField(
          controller: widget.controller,
          placeHolder: widget.placeHolder,
          obscureText: isShowPassword,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 45,
          child: Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isShowPassword = !isShowPassword;
                  });
                },
                child: Icon(
                  isShowPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: cLightText,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
