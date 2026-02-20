import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/extra_views/search_bar.dart';
import 'package:untitled/screens/extra_views/top_bar.dart';
import 'package:untitled/screens/post/post_card.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/search_screen/search_controller.dart';
import 'package:untitled/screens/tag_screen/tag_screen.dart';
import 'package:untitled/utilities/const.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = SearchScreenController();
    return Scaffold(
      body: GetBuilder(
          init: controller,
          builder: (context) {
            return Column(
              children: [
                const TopBarForInView(title: LKeys.search),
                MySearchBar(
                  controller: controller.textEditingController,
                  onChange: (text) {
                    controller.onSearchTextChanged();
                  },
                ),
                const SizedBox(height: 15),
                segmentController(controller),
                const SizedBox(height: 15),
                Expanded(
                  child: PageView(
                    controller: controller.controller,
                    onPageChanged: controller.onChangePage,
                    children: [
                      usersView(controller),
                      postsView(controller),
                      hashtagView(controller),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }

  Widget hashtagView(SearchScreenController controller) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: Get.bottomBarHeight),
      itemCount: controller.filterTags.length,
      itemBuilder: (context, index) {
        var tag = controller.filterTags[index];
        return GestureDetector(
          onTap: () {
            Navigate.to(TagScreen(tag: '#${tag.tag ?? ''}'));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
            child: Row(
              children: [
                Container(
                  decoration: ShapeDecoration(
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 2, color: cLightText.withOpacity(0.1)))),
                  padding: EdgeInsets.all(5),
                  child: Image.asset(
                    MyImages.hashtag,
                    height: 30,
                    width: 30,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${tag.tag ?? ''}',
                      style: MyTextStyle.gilroySemiBold(size: 18),
                    ),
                    Text(
                      '${tag.postCount?.toInt().makeToString() ?? '0'} ${LKeys.posts.tr}',
                      style:
                          MyTextStyle.gilroyMedium(color: cLightText, size: 14),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget postsView(SearchScreenController controller) {
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: false,
      controller: controller.postsRefreshController,
      enableTwoLevel: false,
      onLoading: () {
        controller.searchPost();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: controller.posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: controller.posts[index],
            onDeletePost: (postID) {
              controller.posts.removeWhere((element) => element.id == postID);
              controller.update();
            },
            refreshView: () {
              controller.update();
            },
          );
        },
      ),
    );
  }

  Widget usersView(SearchScreenController controller) {
    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: false,
      controller: controller.usersRefreshController,
      enableTwoLevel: false,
      onLoading: () {
        controller.searchUser();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: controller.users.length,
        itemBuilder: (context, index) {
          return ProfileCard(user: controller.users[index]);
        },
      ),
    );
  }

  Widget segmentController(SearchScreenController controller) {
    return CupertinoSlidingSegmentedControl(
      children: {
        0: buildSegment(LKeys.users, 0, controller),
        1: buildSegment(LKeys.posts, 1, controller),
        2: buildSegment(LKeys.hashtags, 2, controller),
      },
      groupValue: controller.selectedPage,
      backgroundColor: cLightText.withOpacity(0.2),
      thumbColor: cBlack,
      padding: const EdgeInsets.all(0),
      onValueChanged: (value) {
        controller.onChangeSegment(value ?? 0);
      },
    );
  }

  Widget buildSegment(
      String text, int index, SearchScreenController controller) {
    return Container(
      alignment: Alignment.center,
      width: (Get.width / 3) - 30,
      child: Text(
        text.toUpperCase(),
        style: MyTextStyle.gilroySemiBold(
                size: 13,
                color: controller.selectedPage == index ? cWhite : cBlack)
            .copyWith(letterSpacing: 2),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final User user;
  final Widget? widget;

  const ProfileCard({Key? key, required this.user, this.widget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigate.to(ProfileScreen(
          userId: user.id ?? 0,
        ));
      },
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                ClipSmoothRect(
                  radius: const SmoothBorderRadius.all(SmoothRadius(
                      cornerRadius: 12, cornerSmoothing: cornerSmoothing)),
                  child: MyCachedImage(
                    imageUrl: user.profile,
                    width: 55,
                    height: 55,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName ?? 'Unknown',
                              style: MyTextStyle.gilroyBold(size: 17),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          VerifyIcon(user: user)
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "@${user.username ?? "unknown"}",
                        style: MyTextStyle.gilroyLight(
                            color: cLightText, size: 15),
                      ),
                    ],
                  ),
                ),
                // const Spacer(),
                widget ?? Container()
              ],
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}
