import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/screens/audio_space/models/audio_space.dart';
import 'package:untitled/utilities/firebase_const.dart';

class AudioSpacesController extends BaseController {
  List<AudioSpace> spaces = [];
  StreamSubscription? spacesListener;

  @override
  void onInit() {
    fetchSpaces();
    super.onInit();
  }

  void fetchSpaces() {
    spacesListener = FirebaseFirestore.instance
        .collection(FirebaseAudioConst.audioSpaces)
        .withConverter(
          fromFirestore: AudioSpace.fromFireStore,
          toFirestore: (value, options) => value.toFireStore(),
        )
        .snapshots()
        .listen((event) {
      spaces = [];
      event.docs.forEach((element) {
        spaces.add(element.data());
      });
      update();
    });
  }

  @override
  void onClose() {
    spacesListener?.cancel();
    super.onClose();
  }
}
