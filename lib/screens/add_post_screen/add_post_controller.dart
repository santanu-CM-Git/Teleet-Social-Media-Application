import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/common/api_service/post_service.dart';
import 'package:untitled/common/api_service/sight_engine_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/managers/url_extractor/metadata_extract_base.dart';
import 'package:untitled/common/managers/url_extractor/parsers/base_parser.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/sheets/confirmation_sheet.dart';
import 'package:untitled/utilities/const.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddPostController extends BaseController {
  final String postBtnGetID = "postButGetID";
  final String imageGetID = "imageGetID";
  DetectableTextEditingController textEditingController =
      DetectableTextEditingController(
    detectedStyle: MyTextStyle.outfitLight(size: 18, color: cHashtagColor)
        .copyWith(height: 1.2),
    regExp: detectionRegExp(atSign: false, url: true)!,
  );
  final ImagePicker _picker = ImagePicker();
  PickerStyle type = PickerStyle.image;
  XFile? videoFile;
  List<XFile> imageFileList = [];
  int selectedImageIndex = 0;
  VideoPlayerController? videoPlayerController;

  PlayerController? audioPlayerController;
  String? audioPath;
  List<double> waves = [];

  UrlMetadata? metaData;
  Set<String> closedUrls = {};
  Timer? _debounce;

  @override
  void onReady() {
    textEditingController.addListener(() {
      update([postBtnGetID]);
    });
    super.onReady();
  }

  void pick({required PickerStyle type, required ImageSource source}) async {
    this.type = type;
    Get.back();
    if (type == PickerStyle.image) {
      if (source == ImageSource.camera) {
        final XFile? selectedImage = await _picker.pickImage(
            source: source,
            maxHeight: Limits.imageSize,
            maxWidth: Limits.imageSize,
            imageQuality: Limits.quality);
        if (selectedImage != null) {
          imageFileList.add(selectedImage);
        }
      } else {
        startLoading();
        final List<XFile> selectedImages = await _picker.pickMultiImage(
            maxHeight: Limits.imageSize,
            maxWidth: Limits.imageSize,
            imageQuality: Limits.quality);
        var imageCount = min(
            (SessionManager.shared
                        .getSettings()
                        ?.maxImagesCanBeUploadedInOnePost ??
                    0) -
                imageFileList.length,
            selectedImages.length);
        for (var i = 0; i < imageCount; i++) {
          await SightEngineService.shared.checkImageInSightEngine(
              xFile: selectedImages[i],
              completion: () {
                imageFileList.add(selectedImages[i]);
              });
        }
        stopLoading();
      }
    } else {
      XFile? file = await _picker.pickVideo(source: source);
      if (file != null) {
        startLoading();
        await SightEngineService.shared.checkVideoInSightEngine(
            xFile: file,
            completion: () async {
              videoFile = file;
              videoPlayerController =
                  VideoPlayerController.file(File(videoFile!.path));
              await videoPlayerController?.initialize();
              var limit = (SessionManager.shared
                      .getSettings()
                      ?.minuteLimitInChoosingVideoForPost ??
                  0);
              if ((videoPlayerController?.value.duration.inSeconds ?? 0) >
                  limit * 60) {
                videoPlayerController?.dispose();
                videoPlayerController = null;
                videoFile = null;
                showSnackBar(
                    '${LKeys.weAreOnlyAllow.tr} $limit ${LKeys.minute.tr}',
                    type: SnackBarType.error);
              } else {
                update(['player']);
                videoPlayerController?.addListener(() {
                  update(['player']);
                });
              }
            });
        stopLoading();
      }
    }
    update([imageGetID, postBtnGetID]);
  }

  void uploadPost() async {
    startLoading();

    SightEngineService.shared.chooseTextModeration(
        text: textEditingController.text,
        completion: () async {
          videoPlayerController?.pause();
          var thumbnailPath = "";
          if (videoFile != null) {
            thumbnailPath = await VideoThumbnail.thumbnailFile(
                  video: videoFile!.path,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.JPEG,
                  maxHeight: Limits.imageSize.toInt(),
                  maxWidth: Limits.imageSize.toInt(),
                  // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                  quality: Limits.quality,
                ) ??
                '';
          }
          List<String> tags = [];
          textEditingController.text.split(' ').forEach((element) {
            if (element.startsWith('#')) {
              tags.add(replaceCharAt(element, 0, '').removeAllWhitespace);
            }
          });
          var urlJson = jsonEncode(metaData);

          var contentType = PostType.text;

          if (imageFileList.isNotEmpty) {
            contentType = PostType.image;
          } else if (videoFile != null) {
            contentType = PostType.video;
          } else if (audioPath != null) {
            contentType = PostType.audio;
          }

          PostService.shared.uploadPost(
            contentType: contentType,
            urlPreview: urlJson,
            tags: tags.join(','),
            images: imageFileList,
            video: videoFile,
            audioFile: audioPath == null ? null : XFile(audioPath!),
            thumbnailPath: thumbnailPath,
            desc: textEditingController.text,
            waves: waves,
            onProgress: (bytes, totalBytes) {},
            completion: (post) {
              post.user = SessionManager.shared.getUser();
              stopLoading();
              Get.back(result: post);
              showSnackBar(LKeys.postAddedSuccessfully.tr,
                  type: SnackBarType.success);
            },
          );
        });
  }

  void onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchUrlPreview();
    });
  }

  void fetchUrlPreview() {
    if (metaData == null) {
      List<String> urls = TextPatternDetector.extractDetections(
          textEditingController.text,
          detectionRegExp(atSign: false, url: true)!);
      var urlString = urls.lastOrNull ?? '';
      if (urlString.isEmpty || closedUrls.contains(urlString)) return;
      if (!urlString.startsWith('http')) {
        urlString = 'https://' + urlString;
      }
      extract(urlString).then((value) {
        metaData = value;
        update([imageGetID]);
      });
    }
  }

  void closePreview() {
    List<String> urls = TextPatternDetector.extractDetections(
        textEditingController.text, detectionRegExp(atSign: false, url: true)!);
    // var urlString = urls.firstOrNull ?? '';
    // if (urlString.isNotEmpty) {
    closedUrls.addAll(urls);
    // }
    metaData = null;
    update([imageGetID]);
  }

  void setAudioPlayer(
      String path, PlayerController playerController, List<double> waves) {
    audioPath = path;
    audioPlayerController = playerController;
    this.waves = waves;
    update([imageGetID]);
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  void play() {
    videoPlayerController?.play();
  }

  void pause() {
    videoPlayerController?.pause();
  }

  void playPause() {
    if (videoPlayerController?.value.isPlaying ?? false) {
      pause();
    } else {
      play();
    }
  }

  void onPageChange(int value) {
    selectedImageIndex = value;
    update(['pageView']);
  }

  void onChange(double value) {
    videoPlayerController?.seekTo(Duration(milliseconds: value.toInt()));
  }

  void removeVideo() {
    videoPlayerController?.pause();
    videoPlayerController?.dispose();
    videoFile = null;
    update([imageGetID, postBtnGetID]);
  }

  void removeAudio() {
    Get.bottomSheet(ConfirmationSheet(
        desc: LKeys.doYouWantToRemoveThisRecording,
        buttonTitle: LKeys.yes,
        onTap: () {
          audioPlayerController?.pausePlayer();
          audioPlayerController?.dispose();
          audioPlayerController = null;
          audioPath = null;
          update([imageGetID, postBtnGetID]);
        }));
  }

  void removeImage() {
    imageFileList.removeAt(selectedImageIndex);
    selectedImageIndex = max(
        imageFileList.length == 1
            ? 0
            : (selectedImageIndex == imageFileList.length
                ? selectedImageIndex - 1
                : selectedImageIndex),
        0);
    update([imageGetID, postBtnGetID, "pageView"]);
  }
}

enum PickerStyle { video, image, audio }

enum PostType {
  image(0),
  video(1),
  audio(2),
  text(3);

  final int value;

  const PostType(this.value);
}
