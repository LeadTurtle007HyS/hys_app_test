import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'options.dart';



class ImageCropper {
  static const MethodChannel _channel = MethodChannel('epub_viewer');

  static Future<File> cropImage({
     String sourcePath,
    int maxWidth,
    int maxHeight,
    CropAspectRatio aspectRatio,
    List<CropAspectRatioPreset> aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    AndroidUiSettings androidUiSettings,
    IOSUiSettings iosUiSettings,
  }) async {
    assert(await File(sourcePath).exists());
    assert(maxWidth == null || maxWidth > 0);
    assert(maxHeight == null || maxHeight > 0);
    assert(compressQuality >= 0 && compressQuality <= 100);

    final arguments = <String, dynamic>{
      'source_path': sourcePath,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'ratio_x': aspectRatio?.ratioX,
      'ratio_y': aspectRatio?.ratioY,
      'aspect_ratio_presets':
      aspectRatioPresets.map<String>(aspectRatioPresetName).toList(),
      'crop_style': cropStyleName(cropStyle),
      'compress_format': compressFormatName(compressFormat),
      'compress_quality': compressQuality,
    }
      ..addAll(androidUiSettings?.toMap() ?? {})
      ..addAll(iosUiSettings?.toMap() ?? {});

    final String resultPath = await _channel.invokeMethod('cropImage', arguments);
    return resultPath == null ? null : new File(resultPath);
  }
}