import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:untitled/common/api_service/post_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/cupertino_controller.dart';
import 'package:untitled/models/chat.dart';
import 'package:untitled/models/feeds_model.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/models/search_hashtags_model.dart';
import 'package:untitled/screens/audio_space/models/audio_space_user.dart';

class SearchScreenController extends CupertinoController {
  List<User> users = [];
  List<Feed> posts = [];
  List<SearchTag> tags = [];
  List<SearchTag> filterTags = [];
  List<AudioSpaceUser> selectedUsers = [];
  TextEditingController textEditingController = TextEditingController();
  RefreshController usersRefreshController =
      RefreshController(initialRefresh: true);
  RefreshController postsRefreshController =
      RefreshController(initialRefresh: true);
  RefreshController hashtagRefreshController =
      RefreshController(initialRefresh: true);
  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 500);
  bool isLoading = false;

  @override
  void onReady() {
    super.onReady();
    searchUser();
    searchPost();
    fetchAllHashtags();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      _performSearch();
    });
  }

  void _performSearch() {
    searchUser(shouldErase: true);
    searchPost(shouldErase: true);
    searchHashtags();
  }

  void fetchAllHashtags() {
    PostService.shared.searchHashtags(
      textEditingController.text,
      tags.length,
      (newTags) {
        tags = newTags;
        filterTags = newTags;
        if (newTags.isEmpty) {
          hashtagRefreshController.loadNoData();
        } else {
          hashtagRefreshController.loadComplete();
        }
        update();
      },
    );
  }

  void searchHashtags({bool shouldErase = false}) {
    String searchText = textEditingController.text.toLowerCase();
    if (searchText.isEmpty) {
      filterTags = tags;
    } else {
      filterTags = tags.where((element) {
        return element.tag?.toLowerCase().contains(searchText) ?? false;
      }).toList();
    }
    update();
  }

  void searchPost({bool shouldErase = false}) {
    String searchText = textEditingController.text;
    if (searchText.isEmpty) {
      posts = [];
      postsRefreshController.loadNoData();
      update();
      return;
    }
    if (shouldErase) {
      posts = [];
    }
    isLoading = true;

    PostService.shared.searchPosts(
      searchText,
      posts.length,
      (newPosts) {
        isLoading = false;
        if (shouldErase) {
          posts = newPosts;
        } else {
          posts.addAll(newPosts);
        }
        if (newPosts.isEmpty) {
          postsRefreshController.loadNoData();
        } else {
          postsRefreshController.loadComplete();
        }
        update();
      },
    );
  }

  void searchUser({bool shouldErase = false}) {
    String searchText = textEditingController.text;
    if (shouldErase) {
      users = [];
    }
    isLoading = true;

    UserService.shared.searchProfile(
      searchText,
      users.length,
      (newUsers) {
        isLoading = false;
        if (shouldErase) {
          users = newUsers;
        } else {
          users.addAll(newUsers);
        }
        if (newUsers.isEmpty) {
          usersRefreshController.loadNoData();
        } else {
          usersRefreshController.loadComplete();
        }
        update();
      },
    );
  }

  /// FOR AUDIO SPACE
  bool isUserSelected(User user) {
    return selectedUsers.any((element) => element.id == user.id);
  }

  void addAndRemoveUser(User user) {
    if (isUserSelected(user)) {
      selectedUsers.removeWhere((element) => element.id == user.id);
    } else {
      selectedUsers.add(user.toAudioSpaceUser(AudioSpaceUserType.added));
    }
    update();
  }
}
