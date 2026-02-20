import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/extra_views/top_bar.dart';
import 'package:untitled/screens/login_screen/login_screen.dart';
import 'package:untitled/utilities/const.dart';
import 'dart:io' as IO;

import '../extra_views/buttons.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: pOnBoarding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   LKeys.textChatDedicated.tr,
              //   style: MyTextStyle.gilroyLight(size: 22),
              // ),
              const SizedBox(
                height: 3,
              ),
              // Text(
              //   LKeys.socialMedia.tr,
              //   style: MyTextStyle.gilroyBold(size: 22),
              // ),
              Text(
                "TELEET",
                style: MyTextStyle.gilroyBold(size: 42),
              ),
              // const Spacer(),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Slogan:",
                                      style: MyTextStyle.gilroyExtraBold(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Your Voice Empowered",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Short Mission Statement:",
                                      style: MyTextStyle.gilroyExtraBold(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Let’s promote free speech with responsibility, sharing our perspectives and understanding the impact of our words in the world.",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "By the way TELEET stand for:",
                                      style: MyTextStyle.gilroyExtraBold(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Teleet is a text-based Expressive Language and Emotion Enhancement Tool on a social media platform, empowering the users’ communications with special features to that enhance the emotional content of the messages, which is part of icon2chat patented technology.",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "This suggests a tool or feature within a social media platform that enhances text-based communication by allowing users to convey emotions and expressiveness more effectively through text messages and sometimes video. ",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "It could involve features such as emojis, stickers, GIFs, or other visual elements that enhance the emotional content of messages. Which are part of icon2chat patented technology. ",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Let’s finish the website and the upload to at least ${IO.Platform.isAndroid ? 'Android' : 'iOS'} today.",
                                      style: MyTextStyle.gilroyLight(
                                          size: 16, color: cLightText),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                        // OnBoardingCard(assetName: MyImages.meeting, title: LKeys.chatRoom, desc: LKeys.chatRoomDesc),
                        // OnBoardingCard(assetName: MyImages.random, title: LKeys.randomRoom, desc: LKeys.randomRoomDesc),
                        // OnBoardingCard(assetName: MyImages.micFill, title: LKeys.audioSpace, desc: LKeys.audioSpaceDesc),
                        // OnBoardingCard(assetName: MyImages.quill, title: LKeys.createChatPost, desc: LKeys.createChatPostDesc),
                      ],
                    ),
                  ),
                ),
              ),

              // const Spacer(),
              CommonButton(
                  text: LKeys.letsStart,
                  onTap: () {
                    // Navigate.to(S)
                    Navigate.to(const LoginScreen());
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class OnBoardingCard extends StatelessWidget {
  final String assetName;
  final String title;
  final String desc;

  const OnBoardingCard(
      {required this.assetName,
      required this.title,
      required this.desc,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cPrimary.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Shadow position
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: cPrimary,
              child: Image.asset(
                assetName,
                height: 30,
                width: 30,
                color: cBlack,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr.toUpperCase(),
                  style: MyTextStyle.gilroyExtraBold(),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  desc.tr,
                  style: MyTextStyle.gilroyLight(size: 16, color: cLightText),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
