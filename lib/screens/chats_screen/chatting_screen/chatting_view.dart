import 'dart:convert';

import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/common/api_service/common_service.dart';
import 'package:untitled/common/api_service/notification_service.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/common/widgets/menu.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/chat.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/models/room_model.dart';
import 'package:untitled/screens/audio_space/audio_spaces_screen/audio_space_screen/audio_space_screen.dart';
import 'package:untitled/screens/audio_space/create_audio_space_screen/create_audio_space_controller.dart';
import 'package:untitled/screens/chats_screen/chat_room_view/room_menu/room_menu.dart';
import 'package:untitled/screens/chats_screen/chat_view/chat_tag.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_controller.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/image_video_chat_picker.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/post/comment/comment_screen.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/report_screen/report_sheet.dart';
import 'package:untitled/screens/rooms_screen/room_controller.dart';
import 'package:untitled/screens/rooms_screen/room_sheet.dart';
import 'package:untitled/screens/video_screen/call_screen.dart';
import 'package:untitled/screens/video_screen/video_call_screen.dart';
import 'package:untitled/utilities/const.dart';
import 'package:untitled/utilities/firebase_const.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ChattingView extends StatefulWidget {
  final Room? room;
  final User? user;
  final ChatUserRoom? chatUserRoom;

  const ChattingView({Key? key, this.room, this.user, this.chatUserRoom})
      : super(key: key);

  @override
  _ChattingViewState createState() => _ChattingViewState();
}

class _ChattingViewState extends State<ChattingView> {
  final ValueNotifier<int?> _remoteUid = ValueNotifier<int?>(null);
  final ValueNotifier<bool> _localUserJoined = ValueNotifier<bool>(false);
  bool _isInit = false; // Mutable state
  bool _isRoomActive = false; // _isRoomActive state
  late final RtcEngine _engine; // RtcEngine instance
  List<int> _remoteUids = [];

  bool _isVideoMuted = false; // Initial state of video

  // Agora parameters
  final String appId = "8ffd10b48cf244b5bb9ae692329f3caf";
  // final String token =
  //     "0068ffd10b48cf244b5bb9ae692329f3cafIADOq2blmzyNRgXXvmyoEaJ6oK6p/nyq1mURYQAQsbnrGgzbS0IAAAAAIgDZHQAAflssZwQAAQAeJitnAwAeJitnAgAeJitnBAAeJitn";
  late String channel = "demo-321";
  late ChattingController controller;

// *************** working on fitebase start  **********************
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateRoom(bool isActive, String roomId) async {
    DocumentReference roomDoc = _firestore.collection('rooms').doc(roomId);

    // Check if the document exists
    DocumentSnapshot docSnapshot = await roomDoc.get();

    if (docSnapshot.exists) {
      // Update the existing document
      await roomDoc.update({
        'active': isActive,
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
      _isRoomActive = isActive;
      print('Room updated with active = $isActive');
    } else {
      // Create a new document if it doesn't exist
      await roomDoc.set({
        'roomId': roomId,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(), // Creation timestamp
        'updatedAt': FieldValue.serverTimestamp(), // Initial update timestamp
      });
      _isRoomActive = true;
      print('Room created with active = $isActive');
    }
  }

  Future<void> checkRoomStatus(String roomId) async {
    DocumentReference roomDoc = _firestore.collection('rooms').doc(roomId);
    DocumentSnapshot docSnapshot = await roomDoc.get();

    if (docSnapshot.exists) {
      bool isActive = docSnapshot.get('active') ?? false;
      setState(() {
        _isRoomActive = docSnapshot.get('active') ?? false;
      });
      print('Room ID: $roomId, Active status: $isActive');
    } else {
      setState(() {
        _isRoomActive = false;
      });
      print('Room ID: $roomId does not exist.');
    }
  }

// *************** working on fitebase end  **********************

  @override
  void initState() {
    super.initState();
    // Initialize Agora when the widget is created

    controller = ChattingController(
      room: widget.room,
      user: widget.user,
      chatUserRoom: widget.chatUserRoom,
    );

    this.checkRoomStatus(controller.chatUserRoom?.conversationId ?? "");
    setState(() {
      channel = controller.chatUserRoom?.conversationId ?? "";
    });
  }

  Future<void> initAgora(String myToken) async {
    // Get microphone and camera permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RtcEngine instance
    _engine = await createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile to live broadcasting
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Register event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user ${connection.localUid} joined');
          _localUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          _remoteUid.value = remoteUid;
          setState(() {
            _remoteUids.add(remoteUid); // Add remote user to list
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left channel");
          _remoteUid.value = null;
          setState(() {
            _remoteUids.remove(remoteUid); // Remove remote user from list
          });
        },
      ),
    );

    // Enable video module
    await _engine.enableVideo();

    // Enable local video preview
    await _engine.startPreview();

    // Join the channel using a temporary token and channel name
    await _engine.joinChannel(
      token: myToken,
      channelId: channel,
      options: ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: (controller.user?.id ?? 0).toInt(),
    );
  }

  Future<void> _dispose() async {
    // Leave the channel
    await _engine.leaveChannel();

    // Release resources
    await _engine.release();

    debugPrint("Agora engine stopped and resources released.");
    await createOrUpdateRoom(false, channel);
    Get.back(result: controller.room);
    // if (_remoteUids.length == 0) {
    //   Get.back(result: controller.room);
    // }
  }

  void sendPushNotification() async {
    var myUser = SessionManager.shared.getUser() ?? User();
    // print("==> ${jsonEncode(controller.user)}");
    // print(
    //     "==> ${jsonEncode(controller.room?.roomUsers)}");
    if (controller.room != null) {
      controller.room?.roomUsers?.forEach((user) {
        if (user.id == myUser.id) {
          // Skip sending notification to the current user
          return;
        }
        NotificationService.shared.sendToSingleUser(
            token: user.deviceToken ?? '',
            deviceType: user.deviceType,
            title: appName,
            body:
                '${myUser.fullName ?? ''} ${LKeys.hasAddedYouTo.tr} \'${'Start a Call'}\' Please Join',
            screen: 'RoomsScreen',
            roomId: channel);
      });
    } else {
      var clientUser = controller.user;
      if (clientUser != null) {
        NotificationService.shared.sendToSingleUser(
            token: clientUser.deviceToken ?? '',
            deviceType: clientUser.deviceType,
            title: appName,
            body:
                '${myUser.fullName ?? ''} ${LKeys.hasAddedYouTo.tr} \'${'Start a Call'}\' ',
            screen: 'RoomsScreen',
            roomId: channel);
      }
    }
  }

  void startCalling() async {
    CommonService.shared.generateAgoraToken(
        channelName: channel,
        completion: (token) async {
          await initAgora(token);
          sendPushNotification();
        });
  }

  void joinCalling() async {
    CommonService.shared.generateAgoraToken(
        channelName: channel,
        completion: (token) async {
          await _engine.joinChannel(
            token: token,
            channelId: channel,
            options: ChannelMediaOptions(
              autoSubscribeVideo: true,
              autoSubscribeAudio: true,
              publishCameraTrack: true,
              publishMicrophoneTrack: true,
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
            ),
            uid: (controller.user?.id ?? 0).toInt(),
          );
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _dispose();
  }

  // Toggle video on/off
  void _toggleVideo() async {
    setState(() {
      _isVideoMuted = !_isVideoMuted;
    });
    await _engine.muteLocalVideoStream(_isVideoMuted);
  }

  @override
  Widget build(BuildContext context) {
    // Example of status bar modification
    Functions.changStatusBar(StatusBarStyle.white);

    return Scaffold(
      backgroundColor: cWhite,
      body: PopScope(
        canPop: false,
        child: GetBuilder<ChattingController>(
          init: controller,
          builder: (context) {
            return Column(
              children: _isInit == false
                  ? [
                      top(controller),
                      Expanded(
                        child: ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          reverse: true,
                          itemCount: controller.messages.length,
                          padding: const EdgeInsets.all(10),
                          controller: controller.scrollController,
                          itemBuilder: (context, index) {
                            return ChatTag(
                              controller: controller,
                              index: index,
                              message: controller.messages[index],
                              isFromRoom: controller.chatUserRoom?.type == 2,
                            );
                          },
                        ),
                      ),
                      (controller.chatUserRoom?.iAmBlocked ?? false)
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              margin: const EdgeInsets.only(
                                  bottom: 10, right: 10, left: 10),
                              decoration: const ShapeDecoration(
                                color: cLightBg,
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius.all(
                                    SmoothRadius(
                                        cornerRadius: 5,
                                        cornerSmoothing: cornerSmoothing),
                                  ),
                                ),
                              ),
                              child: Text(
                                LKeys.youAreBlocked.tr,
                                style: MyTextStyle.gilroyRegular(
                                    color: cLightText),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                      controller.chatUserRoom?.type == 0
                          ? requestBottom(controller)
                          : bottom(controller),
                    ]
                  : [
                      top(controller),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of videos per row
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: _remoteUids.length,
                          itemBuilder: (context, index) {
                            final uid = _remoteUids[index];
                            return SizedBox(
                              width: 100,
                              height: 150,
                              child: Center(
                                child: AgoraVideoView(
                                  controller: VideoViewController.remote(
                                    rtcEngine: _engine,
                                    canvas: VideoCanvas(uid: uid),
                                    connection:
                                        RtcConnection(channelId: channel),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: Center(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _localUserJoined,
                                builder: (context, localUserJoined, child) {
                                  int userId = (controller.user?.id ?? 0)
                                          .toInt() ??
                                      0; // Ensure you are setting the userId correctly
                                  return localUserJoined
                                      ? AgoraVideoView(
                                          controller: VideoViewController(
                                            rtcEngine: _engine,
                                            canvas: VideoCanvas(
                                                uid:
                                                    0), // Pass dynamic userId here
                                          ),
                                        )
                                      : const CircularProgressIndicator();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
            );
          },
        ),
      ),
    );
  }

  // Stop/Dispose Agora
  Future<void> stopAgora() async {
    if (_engine != null) {
      // Leave the channel
      await _engine!.leaveChannel();
      // Release resources
      await _engine!.release();
      debugPrint("Agora engine stopped and resources released.");
    }
  }

  Widget bottom(ChattingController controller) {
    return Container(
      padding: const EdgeInsets.all(7),
      color: cLightBg,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: ShapeDecoration(
                    color: cLightText.withOpacity(0.15),
                    shape: const SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.all(SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: cornerSmoothing)))),
                padding: const EdgeInsets.only(
                    left: 15, top: 2, right: 2, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: DetectableTextField(
                          controller: controller.messageTextController,
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              hintText: LKeys.writeHere.tr,
                              hintStyle: MyTextStyle.gilroyRegular(
                                  color: cLightText.withOpacity(0.6)),
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                              contentPadding: const EdgeInsets.all(0)),
                          cursorColor: cPrimary,
                          style: MyTextStyle.gilroyRegular(color: cLightText),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: controller.sendMsg, child: const SendBtn())
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  contentButton(
                      iconData: Icons.add_circle_rounded,
                      source: ImageSource.gallery,
                      controller: controller),
                  const SizedBox(width: 5),
                  contentButton(
                      iconData: Icons.camera_alt_rounded,
                      source: ImageSource.camera,
                      controller: controller),
                  const SizedBox(width: 5),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget contentButton(
      {required IconData iconData,
      required ImageSource source,
      required ChattingController controller}) {
    return GestureDetector(
      onTap: () {
        if (controller.chatUserRoom?.iAmBlocked == true) {
          return;
        }
        if (controller.chatUserRoom?.iBlocked == true) {
          controller.unblockUser(controller.user, () {});
          return;
        }
        final imagePicker = ImagePicker();
        Get.bottomSheet(ImageVideoOptionPicker(
          onImageTap: () async {
            XFile? file = await imagePicker.pickImage(source: source);
            print(file?.path);
            if (file != null) {
              Get.back();
              Get.bottomSheet(
                  WriteDescriptionSheet(
                    file: file,
                    controller: controller,
                    type: MessageType.image,
                  ),
                  isScrollControlled: true,
                  ignoreSafeArea: false);
            }
          },
          onVideoTap: () async {
            XFile? file = await imagePicker.pickVideo(source: source);
            print(file?.path);
            if (file != null) {
              Get.back();
              Get.bottomSheet(
                  WriteDescriptionSheet(
                    file: file,
                    controller: controller,
                    type: MessageType.video,
                  ),
                  isScrollControlled: true,
                  ignoreSafeArea: false);
            }
          },
        ));
      },
      child: Icon(
        iconData,
        color: cLightText,
        size: 28,
      ),
    );
  }

  Widget requestBottom(ChattingController controller) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: cLightBg,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Text(
              '${controller.user?.fullName ?? ''} ${LKeys.requestDesc.tr}',
              style: MyTextStyle.gilroyLight(color: cDarkText, size: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChatButton(
                    title: controller.chatUserRoom?.iBlocked ?? false
                        ? LKeys.unBlock.tr
                        : LKeys.block.tr,
                    color: cBlack,
                    onTap: () {
                      if (controller.chatUserRoom?.iBlocked ?? false) {
                        controller.unblockUser(controller.user, () {
                          controller.chatUserRoom?.iBlocked = false;
                        });
                      } else {
                        controller.blockUser(controller.user, () {
                          controller.chatUserRoom?.iBlocked = true;
                        });
                      }
                      controller.update();
                    }),
                ChatButton(
                  title: LKeys.reject,
                  color: cRed,
                  onTap: controller.rejectMessageRequest,
                ),
                ChatButton(
                  title: LKeys.accept,
                  color: cGreen,
                  onTap: controller.acceptMessageRequest,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      String userIDs = "";
      for (int index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        var userID = errorInvitees.elementAt(index);
        userIDs += userID + ' ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = 'User doesn\'t exist or is offline: $userIDs';
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      showToast(
        message,
        position: StyledToastPosition.top,
        context: context,
      );
    } else if (code.isNotEmpty) {
      showToast(
        'code: $code, message:$message',
        position: StyledToastPosition.top,
        context: context,
      );
    }
    // sendPushNotification();
  }

  Widget sendCallButton({
    required bool isVideoCall,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    // Assuming you're not actually using ValueListenableBuilder here
    List<ZegoUIKitUser> invitees = [];
    var myUser = SessionManager.shared.getUser() ?? User();

    if (controller.room != null) {
      controller.room?.roomUsers?.forEach((user) {
        if (user.id != myUser.id) {
          invitees.add(ZegoUIKitUser(
            id: user.phone ?? "0",
            name: user.fullName ?? "Someone",
          ));
        }
      });
    } else if (controller.user != null) {
      var clientUser = controller.user!;
      invitees.add(ZegoUIKitUser(
        id: clientUser.phone ?? "0",
        name: clientUser.fullName ?? "Someone",
      ));
    }

    return ZegoSendCallInvitationButton(
      isVideoCall: isVideoCall,
      invitees: invitees,
      resourceID: "zego_call",
      iconSize: const Size(40, 40),
      buttonSize: const Size(50, 50),
      onPressed: onCallFinished,
    );
  }

  Widget top(ChattingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: cDarkBG,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              child: const Icon(
                Icons.chevron_left_rounded,
                color: cWhite,
                size: 35,
              ),
              onTap: () {
                _dispose();
                stopAgora();
                Get.back(result: controller.room);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (controller.user != null) {
                    Navigate.to(ProfileScreen(
                      userId: controller.user?.id ?? 0,
                    ));
                  } else if (controller.room != null) {
                    Get.bottomSheet(
                        RoomSheet(
                          room: controller.room!,
                          isFromInfo: true,
                          controller: RoomController(controller.room ?? Room()),
                        ),
                        isScrollControlled: true);
                  }
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: MyCachedProfileImage(
                        fullName: controller.chatUserRoom?.title,
                        imageUrl: controller.chatUserRoom?.profileImage,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 100, // Constrain the width to 200 pixels
                                child: Text(
                                  controller.chatUserRoom?.title ?? '',
                                  style: MyTextStyle.gilroyBold(
                                    size: 18,
                                    color: cWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 1),
                              VerifyIcon(user: controller.user)
                            ],
                          ),
                          Row(
                            children: [
                              controller.chatUserRoom?.type == 2
                                  ? Row(
                                      children: [
                                        Text(
                                          controller.room?.totalMember
                                                  ?.makeToString() ??
                                              '',
                                          style: MyTextStyle.gilroyBold(
                                              size: 14, color: cPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    )
                                  : Container(),
                              Text(
                                controller.chatUserRoom?.type == 2
                                    ? LKeys.members.tr
                                    : "@${controller.user?.username ?? ''}",
                                style: MyTextStyle.gilroyLight(
                                    size: 15, color: cPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        // const SizedBox(width: 10),
                        sendCallButton(
                          isVideoCall: false,
                          onCallFinished: onSendCallInvitationFinished,
                        ),
                        sendCallButton(
                          isVideoCall: true,
                          onCallFinished: onSendCallInvitationFinished,
                        ),
                      ],
                    ),
                  ],
                )
                // StreamBuilder<DocumentSnapshot>(
                //     stream: _firestore
                //         .collection('rooms')
                //         .doc(controller.chatUserRoom?.conversationId)
                //         .snapshots(),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.waiting) {
                //         return Center(child: CircularProgressIndicator());
                //       }

                //       final docSnapshot = snapshot.data!;
                //       bool _isRoomActive_new = docSnapshot.exists
                //           ? docSnapshot.get('active') ?? false
                //           : false;

                //       return Row(
                //         mainAxisSize:
                //             MainAxisSize.min, // Make Row as small as possible
                //         children: [
                //           Flexible(
                //             child: Container(
                //               width: 40,
                //               height: 40,
                //               child: FloatingActionButton(
                //                 onPressed: () async {
                //                   if (_isRoomActive_new == false) {
                //                     sendPushNotification();
                //                   }
                //                   Navigate.to(GroupVideoCallScreen(
                //                       conversationId: channel,
                //                       forceJoin: true));
                //                 },
                //                 backgroundColor:
                //                     _isInit == false ? Colors.teal : Colors.red,
                //                 child: _isRoomActive_new == true &&
                //                         _isInit == false
                //                     ? RingingIcon()
                //                     : Icon(
                //                         _isRoomActive_new == false
                //                             ? Icons.call
                //                             : _isInit == false
                //                                 ? Icons.play_circle
                //                                 : Icons.close,
                //                       ),
                //               ),
                //             ),
                //           ),
                //           if (_isInit)
                //             Row(
                //               children: [
                //                 const SizedBox(
                //                     width: 10), // Spacer between buttons
                //                 Container(
                //                   width: 40,
                //                   height: 40,
                //                   child: FloatingActionButton(
                //                     onPressed: _toggleVideo,
                //                     child: Icon(
                //                       _isVideoMuted
                //                           ? Icons.videocam_off
                //                           : Icons.videocam,
                //                       color: Colors.white,
                //                     ),
                //                     backgroundColor: _isVideoMuted
                //                         ? Colors.red
                //                         : Colors.green,
                //                   ),
                //                 )
                //               ],
                //             ),
                //         ],
                //       );
                //     }),
              ],
            ),
            const SizedBox(width: 10),
            controller.chatUserRoom?.type == 2
                ? RoomMenu(controller: controller)
                : Menu(
                    items: [
                      PopupMenuItem(
                        textStyle: MyTextStyle.gilroyMedium(),
                        child: Text(
                          LKeys.report.tr,
                        ),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 1), () {
                            Get.bottomSheet(ReportSheet(user: controller.user),
                                isScrollControlled: true);
                          });
                        },
                      ),
                      PopupMenuItem(
                        textStyle: MyTextStyle.gilroyMedium(),
                        child: Text(controller.chatUserRoom?.iBlocked ?? false
                            ? LKeys.unBlock.tr
                            : LKeys.block.tr),
                        onTap: () {
                          if (controller.chatUserRoom?.iBlocked ?? false) {
                            controller.unblockUser(controller.user, () {
                              controller.chatUserRoom?.iBlocked = false;
                            });
                          } else {
                            controller.blockUser(controller.user, () {
                              controller.chatUserRoom?.iBlocked = true;
                            });
                          }
                          controller.update();
                        },
                      ),
                    ],
                    color: cPrimary,
                  )
          ],
        ),
      ),
    );
  }
}

class RingingIcon extends StatefulWidget {
  @override
  _RingingIconState createState() => _RingingIconState();
}

class _RingingIconState extends State<RingingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200), // Speed of shake
      vsync: this,
    )..repeat(reverse: true); // Repeats the animation

    _animation = Tween<double>(begin: -0.05, end: 0.05) // Angle in radians
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Icon(
            Icons.call,
            color: Colors.white,
            size: 30,
          ),
        );
      },
    );
  }
}
