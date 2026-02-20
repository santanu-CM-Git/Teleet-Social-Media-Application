import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/common/api_service/moderator_service.dart';
import 'package:untitled/common/api_service/post_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/feeds_model.dart';
import 'package:untitled/screens/add_post_screen/add_post_controller.dart';
import 'package:untitled/screens/post/audio_player_sheet.dart';
import 'package:untitled/screens/post/post_liked_users_screen.dart';
import 'package:untitled/screens/post/video_player_sheet.dart';
import 'package:untitled/screens/report_screen/report_sheet.dart';
import 'package:untitled/screens/sheets/confirmation_sheet.dart';
import 'package:untitled/utilities/const.dart';
import 'package:untitled/utilities/params.dart';

class PostController extends BaseController {
  int selectedImageIndex = 0;
  bool isMyPost = false;
  Feed post;
  Function(int postID) onDeletePost;
  Function() refreshView;

  RxInt likeCount = 0.obs;
  RxBool isLiked = false.obs;

  PostController(this.post, this.onDeletePost, this.refreshView) {
    likeCount.value = this.post.likesCount ?? 0;
    isLiked.value = this.post.isLike == 1;
  }

  void openVideoSheet() {
    if (post.type == PostType.video) {
      Get.bottomSheet(VideoPlayerSheet(controller: this),
          isScrollControlled: true);
    }
  }

  void onPageChange(int value) {
    selectedImageIndex = value;
    update(["pageView"]);
  }

  void toggleFav() {
    if (post.isLike == 1) {
      post.likesCount = (post.likesCount ?? 0) - 1;
      likeCount.value = this.post.likesCount ?? 0;
      isLiked.value = false;
      post.isLike = 0;
      update();
      dislikePost();
    } else {
      post.likesCount = (post.likesCount ?? 0) + 1;
      likeCount.value = this.post.likesCount ?? 0;
      isLiked.value = true;
      post.isLike = 1;
      update();
      likePost();
    }

    // update(["fav"]);
  }

  void likeFromDoubleTap() {
    post.likesCount = (post.likesCount ?? 0) + 1;
    likeCount.value = this.post.likesCount ?? 0;
    isLiked.value = true;
    post.isLike = 1;
    update();
    refreshView();
    likePost();
  }

  void likePost() {
    refreshView();
    PostService.shared.likePost(post.id ?? 0, () {});
  }

  void dislikePost() {
    refreshView();
    PostService.shared.dislikePost(post.id ?? 0, () {});
  }

  void deleteOrReport() {
    if (post.userId == SessionManager.shared.getUserID()) {
      deletePost();
    } else {
      reportPost();
    }
  }

  void showWhoLikedThePost() {
    Get.to(() => PostLikedUsersScreen(postId: post.id ?? 0));
  }

  void deletePosyByModerator() {
    Future.delayed(const Duration(milliseconds: 1), () {
      Get.bottomSheet(ConfirmationSheet(
        desc: LKeys.deletePostDesc.tr,
        buttonTitle: LKeys.delete.tr,
        onTap: () {
          startLoading();
          ModeratorService.shared.deletePost(
              postID: post.id ?? 0,
              completion: () {
                stopLoading();
                onDeletePost(post.id ?? 0);
              });
        },
      ));
    });
  }

  void sharePost() {
    BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: post.desc ?? '',
        imageUrl: post.content?.isEmpty == true
            ? ''
            : (post.content?.first.thumbnail != null
                ? post.content?.first.thumbnail?.addBaseURL() ?? ''
                : post.content?.first.content?.addBaseURL() ?? ''),
        // contentDescription: userData?.about ?? '',
        publiclyIndex: true,
        locallyIndex: true);
    BranchLinkProperties lp = BranchLinkProperties();
    lp.addControlParam(Param.postId, '${post.id}');
    if (GetPlatform.isIOS) {
      if (buo.imageUrl != '') {
        FlutterBranchSdk.showShareSheet(
            buo: buo, linkProperties: lp, messageText: '');
      } else {
        rootBundle.load(MyImages.appIcon).then((data) {
          FlutterBranchSdk.shareWithLPLinkMetadata(
              buo: buo,
              linkProperties: lp,
              icon: data.buffer.asUint8List(),
              title: post.desc ?? '');
        });
      }
    } else {
      FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp).then((value) {
        Share.share(value.result ?? '', subject: post.desc ?? '');
      });
    }
  }

  void reportPost() {
    Future.delayed(const Duration(milliseconds: 1), () {
      Get.bottomSheet(
          ReportSheet(
            post: post,
          ),
          isScrollControlled: true,
          ignoreSafeArea: false);
    });
  }

  void deletePost() {
    Future.delayed(const Duration(milliseconds: 1), () {
      Get.bottomSheet(ConfirmationSheet(
        desc: LKeys.deletePostDesc.tr,
        buttonTitle: LKeys.delete.tr,
        onTap: () {
          startLoading();
          PostService.shared.deletePost(
            post.id ?? 0,
            () {
              stopLoading();
              onDeletePost(post.id ?? 0);
            },
          );
        },
      ));
    });
  }

  void openAudioSheet() {
    // (await AudioSession.instance).configure(const AudioSessionConfiguration.speech());

    if (post.type == PostType.audio) {
      Get.bottomSheet(AudioPlayerSheet(controller: this),
              isScrollControlled: true)
          .then((value) {});
    }
  }
}
