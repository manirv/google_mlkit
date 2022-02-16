import 'package:vfslive/model/face_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/cupertino.dart';

class FaceDetectorController {
  FaceDetector? _faceDetector;

  Future<List<FaceModel>?> processImage(inputImage) async {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
      ),
    );

    final faces = await _faceDetector?.processImage(inputImage);
    return extractFaceInfo(faces);
  }

  List<FaceModel>? extractFaceInfo(List<Face>? faces) {
    List<FaceModel>? response = [];
    double? smile;
    double? leftEye;
    double? rightEye;
    double? headpose;
    Rect? rect;

    for (Face face in faces!) {
      rect = face.boundingBox;
      if (face.smilingProbability != null) {
        smile = face.smilingProbability;
      }

      leftEye = face.leftEyeOpenProbability;
      rightEye = face.rightEyeOpenProbability;
      headpose = face.headEulerAngleY;

      final faceModel = FaceModel(
          smile: smile,
          leftEyeOpen: leftEye,
          rightEyeOpen: rightEye,
          headposedir: headpose,
          boundingBox: rect);

      response.add(faceModel);
    }

    return response;
  }
}
