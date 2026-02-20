import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:untitled/common/api_service/story_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/utilities/const.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateStoryController extends BaseController {
  var shouldAddStory = false;

  void createStory({required String fileURL, required double duration, required bool isVideo}) async {
    startLoading();
    int type = UrlTypeHelper.getType(fileURL) == UrlType.VIDEO ? 1 : 0;
    var thumbnailPath = "";
    if (type == 1) {
      thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: fileURL,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.JPEG,
            maxHeight: Limits.imageSize.toInt(),
            maxWidth: Limits.imageSize.toInt(),
            quality: Limits.quality,
          ) ??
          '';
    }
    print(thumbnailPath);
    print(fileURL);
    StoryService.shared.createStory(
        fileURL: fileURL,
        type: type,
        duration: duration,
        thumbnail: thumbnailPath,
        completion: () {
          stopLoading();
          Get.back();
          Get.back();
        });
  }

  void createAnotherStory() {
    shouldAddStory = true;
    update();
  }
}

enum UrlType { IMAGE, VIDEO, UNKNOWN }

class UrlTypeHelper {
  static List<String> _image_types = ['jpg', 'jpeg', 'jfif', 'pjpeg', 'pjp', 'png', 'svg', 'gif', 'apng', 'webp', 'avif'];

  static List<String> _video_types = ["bin", "3g2", "3gp", "aaf", "asf", "avchd", "avi", "drc", "flv", "m2v", "m3u8", "m4p", "m4v", "mkv", "mng", "mov", "mp2", "mp4", "mpe", "mpeg", "mpg", "mpv", "mxf", "nsv", "ogg", "ogv", "qt", "rm", "rmvb", "roq", "svi", "vob", "webm", "wmv", "yuv"];

  static UrlType getType(url) {
    try {
      Uri uri = Uri.parse(url);
      String extension = p.extension(uri.path).toLowerCase();
      if (extension.isEmpty) {
        return UrlType.UNKNOWN;
      }

      extension = extension.split('.').last;
      if (_image_types.contains(extension)) {
        return UrlType.IMAGE;
      } else if (_video_types.contains(extension)) {
        return UrlType.VIDEO;
      }
    } catch (e) {
      return UrlType.UNKNOWN;
    }
    return UrlType.UNKNOWN;
  }
}
