import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/rooms_screen/single_room/single_room_screen.dart';
import 'package:untitled/screens/single_post_screen/single_post_screen.dart';
import 'package:untitled/utilities/params.dart';

class TabBarController extends BaseController {
  int selectedTab = 0;

  @override
  void onInit() {
    super.onInit();
  }

  void selectIndex(int index) {
    selectedTab = index;
    update();
  }

  void handleBranch() {
    Future.delayed(Duration(milliseconds: 200), () {
      FlutterBranchSdk.init().then((value) {
        FlutterBranchSdk.listSession().listen(
          (data) {
            if (data.containsKey("+clicked_branch_link") &&
                data["+clicked_branch_link"] == true) {
              if (data.containsKey(Param.postId)) {
                var postId = data[Param.postId];
                if (postId is String) {
                  Navigate.to(SinglePostScreen(postId: int.parse(postId)));
                } else if (postId is double) {
                  Navigate.to(SinglePostScreen(postId: postId.toInt()));
                }
              } else if (data.containsKey(Param.userId)) {
                var userId = data[Param.userId];
                if (userId is String) {
                  Navigate.to(ProfileScreen(userId: int.parse(userId)));
                } else if (userId is double) {
                  Navigate.to(ProfileScreen(userId: userId.toInt()));
                }
              } else if (data.containsKey(Param.roomId)) {
                var roomId = data[Param.roomId];
                if (roomId is String) {
                  Navigate.to(SingleRoomScreen(roomId: int.parse(roomId)));
                } else if (roomId is double) {
                  Navigate.to(SingleRoomScreen(roomId: roomId.toInt()));
                }
              }
            }
            FlutterBranchSdk.clearPartnerParameters();
          },
          onError: (error) {
            PlatformException platformException = error as PlatformException;
            print(platformException.message);
          },
        );
      });
    });
  }
}
