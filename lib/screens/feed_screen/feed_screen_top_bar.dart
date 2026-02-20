import 'package:flutter/material.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/screens/audio_space/audio_spaces_screen/audio_spaces_screen.dart';
import 'package:untitled/screens/extra_views/logo_tag.dart';
import 'package:untitled/screens/notification_screen/notification_screen.dart';
import 'package:untitled/screens/search_screen/search_screen.dart';
import 'package:untitled/utilities/const.dart';

class FeedScreenTopBar extends StatelessWidget {
  const FeedScreenTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double imageSize = 25;
    return Container(
      color: cBG,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigate.to(const NotificationScreen());
              },
              child: Image.asset(
                MyImages.bell,
                width: imageSize,
                height: imageSize,
              ),
            ),
            Opacity(
              opacity: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset(
                  MyImages.audioRoom,
                  width: imageSize,
                  height: imageSize,
                ),
              ),
            ),
            Spacer(),
            const LogoTag(),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigate.to(const AudioSpacesScreen());
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset(
                  MyImages.audioRoom,
                  width: imageSize,
                  height: imageSize,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigate.to(const SearchScreen());
              },
              child: Image.asset(
                MyImages.search,
                width: imageSize,
                height: imageSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
