import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vfslive/controller/camera_controller.dart';
import 'package:vfslive/controller/face_detection_controller.dart';
import 'package:vfslive/model/face_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  CameraManager? _cameraManager;
  CameraController? cameraController;
  FaceDetectorController? _faceDetect;
  bool _isDetecting = false;
  List<FaceModel>? faces;
  String? emotion = '';
  String? eyes = '';
  String? head = '';
  String? noface = '';
  Rect? boundingbox;

  int? eyesopencnt = 0;
  int? eyesclosecnt = 0;
  int? headstcnt = 0;
  int? headleftcnt = 0;
  int? headrightcnt = 0;
  int? smilecnt = 0;
  int? notsmilecnt = 0;
  int? neutralcnt = 0;
  int? brightcnt = 0;
  int? nofacecnt = 0;
  int? framenum = 0;
  static Map? metrics;

  // Whether or not the rectangle is displayed
  bool? isRectangleVisible = false;

  // Holds the position information of the rectangle
  Map<String, double> position = {
    'x': 250,
    'y': 200,
    'w': 400,
    'h': 400,
  };

  HomeController() {
    _cameraManager = CameraManager();
    _faceDetect = FaceDetectorController();
  }

  get vidPath => null;

  // Some logic to get the rectangle values
  void updateRectanglePosition() {
    // setState(() {
    // assign new position
    Rect? bb = boundingbox;
    position = {
      'x': bb?.left as double,
      'y': (bb?.top)! * 3 / 4,
      'w': (bb?.width)! * 3 / 4.5,
      'h': (bb?.height)! * 3 / 3.5,
    };
    isRectangleVisible = true;
    //});
  }

  Future<void> loadCamera() async {
    cameraController = await _cameraManager?.load();
    update();
  }

  Future<void> startImageStream() async {
    CameraDescription camera = cameraController!.description;

    cameraController?.startImageStream((cameraImage) async {
      if (_isDetecting) return;

      _isDetecting = true;

      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

      final InputImageRotation imageRotation =
          InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.Rotation_0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
              InputImageFormat.NV21;

      final planeData = cameraImage.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: inputImageData,
      );

      processImage(inputImage);
    });
  }

  String detectSmile(smileProb) {
    if (smileProb > 0.7) {
      return 'Smiling';
    } else if (smileProb > 0.2) {
      return 'Neutral';
    } else {
      return 'Not Smiling';
    }
  }

  String detectEyes(right, left) {
    if (right > 0.1 && left > 0.1) {
      return 'Eyes opened';
    } else {
      return 'Eyes closed';
    }
  }

  String detectHead(headposeProb) {
    if (headposeProb > 10) {
      return 'Left';
    } else if (headposeProb < -10) {
      return 'Right';
    } else {
      return 'Straight';
    }
  }

  Future<void> processImage(inputImage) async {
    faces = await _faceDetect?.processImage(inputImage);

    if (faces != null && faces!.isNotEmpty) {
      framenum = framenum! + 1;
      FaceModel? face = faces?.first;
      emotion = detectSmile(face?.smile);
      eyes = detectEyes(face?.rightEyeOpen, face?.leftEyeOpen);
      head = detectHead(face?.headposedir);
      boundingbox = face?.boundingBox;

      updateRectanglePosition();

      if (eyes == 'Eyes opened') {
        eyesopencnt = eyesopencnt! + 1;
      } else if (eyes == 'Eyes closed') {
        eyesclosecnt = eyesclosecnt! + 1;
      }

      if (head == 'Straight') {
        headstcnt = headstcnt! + 1;
      } else if (head == 'Left') {
        headleftcnt = headleftcnt! + 1;
      } else if (head == 'Right') {
        headrightcnt = headrightcnt! + 1;
      }

      if (emotion == 'Smiling') {
        smilecnt = smilecnt! + 1;
      } else if (emotion == 'Not Smiling') {
        notsmilecnt = notsmilecnt! + 1;
      } else if (emotion == 'Neutral') {
        neutralcnt = neutralcnt! + 1;
      }
    } else {
      noface = 'No face detected';
      nofacecnt = nofacecnt! + 1;
    }
    _isDetecting = false;
    update();

    metrics = {
      "api_version": "0.1",
      "metrics": {
        "expression": [],
        "head_orientation": 0.0,
        "head_pose": 0.0,
        "head_orientation_v0.2": getEyeJson(),
        "head_pose_v0.2": getHeadJson(),
        "emotion_v0.2": getEmotJson(),
        "brightness": "good",
        "length": "1763059.3333333333",
        "length_silence": "17786",
        "percent_silence": "0.29659151547491996",
        "short_pause_count": "15",
        "short_pause_tot_duration": "2209",
        "med_pause_count": "19",
        "med_pause_tot_duration": "8627",
        "long_pause_count": "5",
        "long_pause_tot_duration": "6950",
        "voiced_ratio": "0.7030333333333333",
        "fwrd_counts": "{'just': 1, 'very': 1}",
        "transcript_length": "123",
        "fwrd_rate": "1.63",
        "transcript_json": "{}",
        "transcript_text": "Hello",
        "word_rate": "123.06562569835992"
      }
    };
  }

  Map<String, dynamic> getEyeJson() =>
      {'total': framenum, 'eyesopen': eyesopencnt, 'eyesclose': eyesclosecnt};

  Map<String, dynamic> getHeadJson() => {
        'total': framenum,
        'headstraight': headstcnt,
        'headleft': headleftcnt,
        'headright': headrightcnt
      };

  Map<String, dynamic> getEmotJson() => {
        'total': framenum,
        'smile': smilecnt,
        'notsmile': notsmilecnt,
        'neutral': neutralcnt,
      };

  String jsonmetrics = jsonEncode(metrics);

// Future<HomeController> postmetrics(String metrics) async {
//   final response = await http.post(
//     Uri.parse('https://jsonplaceholder.typicode.com/albums'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'jsonmetrics': metrics,
//     }),
//   );

//   if (response.statusCode == 201) {
//     // If the server did return a 201 CREATED response,
//     // then parse the JSON.
//     return HomeController.fromJson(jsonDecode(response.body));
//   } else {
//     // If the server did not return a 201 CREATED response,
//     // then throw an exception.
//     throw Exception('Failed to create album.');
//   }
// }
}
