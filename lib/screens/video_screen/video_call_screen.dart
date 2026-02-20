import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/common/api_service/common_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/firebase_notification_manager.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GroupVideoCallScreen extends StatefulWidget {
  final String? conversationId; // Add this parameter here
  final bool? forceJoin; // Add this parameter here

  GroupVideoCallScreen({required this.conversationId, required this.forceJoin})
      : super(key: const PageStorageKey('GroupVideoCallScreen'));

  @override
  _GroupVideoCallScreenState createState() => _GroupVideoCallScreenState();
}

class _GroupVideoCallScreenState extends State<GroupVideoCallScreen> {
  // Add a separate localUser placeholder
  final String localUser =
      'https://via.placeholder.com/150'; // Replace with local user's camera feed
  final List<String> participants = [];

  int? selectedIndex;

  final ValueNotifier<int?> _remoteUid = ValueNotifier<int?>(null);
  final ValueNotifier<bool> _localUserJoined = ValueNotifier<bool>(false);
  bool _isInit = false; // Mutable state
  bool _isRoomActive = false; // _isRoomActive state
  String? callingBy = null; // _isRoomActive state
  late final RtcEngine _engine; // RtcEngine instance
  List<int> _remoteUids = [];

  bool _isVideoMuted = false; // Initial state of video
  bool _isAudioMuted = false; // Initial state of video

  // Agora parameters
  final String appId = "8ffd10b48cf244b5bb9ae692329f3caf";
  // final String token =
  //     "0068ffd10b48cf244b5bb9ae692329f3cafIADOq2blmzyNRgXXvmyoEaJ6oK6p/nyq1mURYQAQsbnrGgzbS0IAAAAAIgDZHQAAflssZwQAAQAeJitnAwAeJitnAgAeJitnBAAeJitn";
  late String channel = "demo-321";
  late ChattingController controller;

  Future<void> checkRoomStatus(String roomId) async {
    DocumentReference roomDoc = _firestore.collection('rooms').doc(roomId);
    DocumentSnapshot docSnapshot = await roomDoc.get();

    if (docSnapshot.exists) {
      bool isActive = docSnapshot.get('active') ?? false;
      setState(() {
        _isRoomActive = docSnapshot.get('active') ?? false;
        callingBy = docSnapshot.get("callingBy");
      });
      print('Room ID: $roomId, Active status: $isActive');
    } else {
      setState(() {
        _isRoomActive = false;
      });
      print('Room ID: $roomId does not exist.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize Agora when the widget is created
    this.checkRoomStatus(widget.conversationId ?? "");
    var channelInit = widget.conversationId ?? "";

    setState(() {
      channel = channelInit;
    });

    if (widget.forceJoin == true) {
      createOrUpdateRoom(true, channelInit);
      startCalling();
      setState(() {
        _isInit = true;
      });
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateRoom(bool isActive, String roomId) async {
    DocumentReference roomDoc = _firestore.collection('rooms').doc(roomId);

    // Check if the document exists
    DocumentSnapshot docSnapshot = await roomDoc.get();

    var myUser = SessionManager.shared.getUser() ?? null;

    if (docSnapshot.exists) {
      // Update the existing document
      await roomDoc.update({
        'active': isActive,
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
        "callingBy": myUser != null ? myUser.fullName : ""
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
        "callingBy": myUser != null ? myUser.fullName : ""
      });
      _isRoomActive = true;
      print('Room created with active = $isActive');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String getFirstName(String fullName) {
    // Split the full name by space and return the first part
    return fullName.split(' ').first;
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
        onUserMuteAudio: (connection, remoteUid, muted) => {
          UserService.shared.fetchProfile(remoteUid, (user) {
            showToast(muted
                ? "${getFirstName(user.fullName ?? 'User')}'s audio is off"
                : "${getFirstName(user.fullName ?? 'User')}'s audio is on");
          })
        },
        onUserMuteVideo: (connection, remoteUid, muted) => {
          UserService.shared.fetchProfile(remoteUid, (user) {
            showToast(muted
                ? "${getFirstName(user.fullName ?? 'User')}'s video is off"
                : "${getFirstName(user.fullName ?? 'User')}'s video is on");
          })
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user ${connection.localUid} joined');
          _localUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          UserService.shared.fetchProfile(remoteUid, (user) {
            showToast("${getFirstName(user.fullName ?? 'User')}'s joined");
          });

          _remoteUid.value = remoteUid;
          setState(() {
            _remoteUids.add(remoteUid); // Add remote user to list
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          debugPrint("User $remoteUid left");
          UserService.shared.fetchProfile(remoteUid, (user) {
            showToast("${getFirstName(user.fullName ?? 'User')}'s left");
          });
          _remoteUid.value = null;
          setState(() {
            _remoteUids.remove(remoteUid); // Remove remote user from list
          });
          // Check if there are no more remote users in the channel
          if (_remoteUids.isEmpty) {
            await createOrUpdateRoom(false, channel);
            dispose();
            Navigator.pop(context);
          }
        },
      ),
    );

    var uuid = SessionManager.shared.getUser()?.id ?? 0;

    // print("===================? ${uuid}");

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
      uid: (uuid).toInt(),
    );
  }

  Future<void> _dispose() async {
    if (_remoteUids.length == 0) {
      // Leave the channel
      await createOrUpdateRoom(false, channel);
    }

    await _engine.leaveChannel();

    // Release resources
    await _engine.release();

    debugPrint("Agora engine stopped and resources released.");
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseNotificationManager.shared.stopSound();
    _dispose();
  }

  // Toggle video on/off
  void _toggleVideo() async {
    setState(() {
      _isVideoMuted = !_isVideoMuted;
    });
    await _engine.muteLocalVideoStream(_isVideoMuted);
  }

  void _toggleAudio() async {
    setState(() {
      _isAudioMuted = !_isAudioMuted;
    });
    await _engine.muteLocalAudioStream(_isAudioMuted);
  }

  void startCalling() async {
    FirebaseNotificationManager.shared.stopSound();

    CommonService.shared.generateAgoraToken(
        channelName: channel,
        completion: (token) async {
          FirebaseNotificationManager.shared.stopSound();
          await initAgora(token);
        });
  }

  // Stop/Dispose Agora
  Future<void> stopAgora() async {
    FirebaseNotificationManager.shared.stopSound();
    if (_engine != null) {
      // Leave the channel
      await _engine!.leaveChannel();
      // Release resources
      await _engine!.release();
      debugPrint("Agora engine stopped and resources released.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access conversationId from widget.conversationId
    final String? conversationId = widget.conversationId;

    print("Conversation ID: $conversationId");

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: _isInit == true
              ? [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of videos per row
                      childAspectRatio: 3 / 4,
                      mainAxisSpacing: 10, // Vertical spacing between items
                      crossAxisSpacing: 10, // Horizontal spacing between items
                    ),
                    itemCount: _remoteUids.length +
                        1, // Adjust count to include local video box
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Display the local video view at the first index
                        return Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Padding around each item
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _localUserJoined,
                              builder: (context, localUserJoined, child) {
                                return localUserJoined
                                    ? AgoraVideoView(
                                        controller: VideoViewController(
                                          rtcEngine: _engine,
                                          canvas: VideoCanvas(
                                              uid: 0), // Use local user ID
                                        ),
                                      )
                                    : Center(
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 4,
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        );
                      }

                      // For other items, display remote video views
                      final uid = _remoteUids[
                          index - 1]; // Adjust index for remote UIDs
                      return Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Padding around each item
                        child: SizedBox(
                          width: 100,
                          height: 150,
                          child: Center(
                            child: AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: _engine,
                                canvas: VideoCanvas(uid: uid),
                                connection:
                                    RtcConnection(channelId: conversationId),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildCallControls(context),
                ]
              : [
                  // Background image for caller
                  Positioned.fill(
                    child: Image.asset(MyImages.logoBlack,
                        height: (100) * 0.1975683891, width: 100),
                  ),
                  // Dark overlay to improve contrast
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  // Caller information and controls
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Caller info at the top
                        Column(
                          children: [
                            Text(
                              'Calling…',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 10),
                            CircleAvatar(
                              radius:
                                  50, // Set the radius to define the size of the CircleAvatar
                              // backgroundImage: AssetImage(MyImages.logo),
                              child: Image.asset(
                                MyImages.logoBlack,
                                height: 100 *
                                    0.1975683891, // Set the height of the image
                                width: 100, // Set the width of the image
                                fit: BoxFit
                                    .cover, // Optionally set BoxFit to ensure the image covers the CircleAvatar
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              callingBy ??
                                  'New Incoming Calls', // Replace with caller's name
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                        // Call control buttons at the bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Mute button
                              StreamBuilder<DocumentSnapshot>(
                                  stream: _firestore
                                      .collection('rooms')
                                      .doc(channel)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final docSnapshot = snapshot.data!;
                                    bool _isRoomActive_new =
                                        docSnapshot.get('active') ?? false;

                                    return Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // Make Row as small as possible
                                      children: [
                                        Column(
                                          children: [
                                            FloatingActionButton(
                                              heroTag: 'mute_button',
                                              backgroundColor: Colors.green,
                                              onPressed: () async {
                                                FirebaseNotificationManager
                                                    .shared
                                                    .stopSound();
                                                // Handle the button action for joining/leaving the call
                                                if (_isRoomActive_new ==
                                                    false) {
                                                  await createOrUpdateRoom(
                                                      true, channel);
                                                } else {
                                                  if (_isInit == true) {
                                                    await createOrUpdateRoom(
                                                        false, channel);
                                                    await _dispose();
                                                  } else {
                                                    await createOrUpdateRoom(
                                                        true, channel);
                                                  }
                                                }
                                                if (_isInit == false) {
                                                  startCalling();
                                                  setState(() {
                                                    _isInit = true;
                                                  });
                                                } else {
                                                  stopAgora();
                                                  setState(() {
                                                    _isInit = false;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                Icons.call_end,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Receive',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 150),
                                        Column(
                                          children: [
                                            FloatingActionButton(
                                              heroTag: 'end_call_button',
                                              backgroundColor: Colors.red,
                                              onPressed: () {
                                                // End call action
                                                dispose();
                                                Navigator.pop(context);
                                              },
                                              child: Icon(
                                                Icons.call_end,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Reject',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(int participantCount) {
    if (participantCount <= 2) return 1;
    if (participantCount <= 4) return 2;
    if (participantCount <= 6) return 3;
    return 4;
  }

  Widget _buildCallControls(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildControlButton(
                _isAudioMuted ? Icons.mic_off : Icons.mic, 'Mute', Colors.white,
                () {
              _toggleAudio();
            }),
            _buildControlButton(
                _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                'Camera',
                Colors.white, () {
              _toggleVideo();
            }),
            _buildControlButton(Icons.call_end, 'End', Colors.red, () {
              stopAgora();
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, Color color,
      [VoidCallback? onPressed]) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color,
          onPressed: onPressed ?? () {},
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
