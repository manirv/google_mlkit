import 'package:flutter/cupertino.dart';

class FaceModel {
  double? smile;
  double? rightEyeOpen;
  double? leftEyeOpen;
  double? headposedir;
  Rect? boundingBox;

  FaceModel(
      {this.smile,
      this.rightEyeOpen,
      this.leftEyeOpen,
      this.headposedir,
      this.boundingBox});
}
