import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/common/api_service/post_service.dart';
import 'package:untitled/models/feeds_model.dart';
import 'package:untitled/models/room_model.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/block_user_controller.dart';
import 'package:untitled/screens/tabbar/tabbar_controller.dart';

class FeedScreenController extends BlockUserController {
  // List<Feed> posts = [];
  String scrollID = "${DateTime.now().millisecondsSinceEpoch}scrollID";
  RxList<Feed> posts = <Feed>[].obs;
  List<Room> suggestedRooms = [];
  bool? isFromFeedScreen;
  String profileFeedID = "profileFeedID";
  String feedViewID = "feedViewID";
  ScrollController? scrollController = ScrollController();
  int userId = 0;

  FeedScreenController({this.isFromFeedScreen, this.scrollController}) {
    if (this.scrollController == null) {
      this.scrollController = ScrollController();
    }
  }

  @override
  void onReady() {
    super.onReady();
    update();
    if (isFromFeedScreen == true) {
      fetchFeeds();
    }
    scrollController?.addListener(
      () {
        if (scrollController!.offset == scrollController!.position.maxScrollExtent) {
          if (!isLoading) {
            if ((isFromFeedScreen ?? false) == true) {
              fetchFeeds();
            } else {
              fetchUserPosts(userId);
            }
          }
        }
      },
    );

    // if (isFromFeedScreen == true && posts.isEmpty) {
    //   fetchFeeds();
    // }
  }

  Future<void> fetchFeeds({bool isForRefresh = false}) async {
    isLoading = true;
    if (posts.isEmpty && !isForRefresh) {
      // startLoading();
    }
    await PostService.shared.fetchPosts(
        shouldSendSuggestedRoom: posts.isEmpty,
        start: isForRefresh ? 0 : posts.length,
        completion: (posts, suggestedRooms) {
          if (isForRefresh) {
            this.posts.value = [];
            update();
          }

          Future.delayed(Duration(milliseconds: 5), () {
            if (this.posts.isEmpty && !isForRefresh) {
              Get.find<TabBarController>().handleBranch();
            }
            this.posts.addAll(posts);
            stopLoading();
            isLoading = false;
            this.posts.refresh();
            update();
          });

          if (suggestedRooms.isNotEmpty) {
            this.suggestedRooms = suggestedRooms;
          }

          update();
        });
  }

  void fetchUserPosts(int userID) {
    // isLoading = true;
    userId = userID;
    PostService.shared.fetchUserPosts(userID, posts.length, (posts) {
      // isLoading = false;
      this.posts.addAll(posts);
      update();
    });
  }

  Future<void> refreshPosts() async {
    if (userId != 0) {
      posts.clear();
      await PostService.shared.fetchUserPosts(userId, posts.length, (posts) {
        // isLoading = false;
        this.posts.addAll(posts);
        update();
        update([scrollID]);
      });
    }
  }
}
