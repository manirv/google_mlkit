import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vfslive/controller/home_controller.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeController = HomeController();
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  var vidPath;

  void _fileInit() async {
    vidPath = join((await getTemporaryDirectory()).path, '${fileName}.mp4');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VFS Live'),
      ),
      body: GetBuilder<HomeController>(
        init: _homeController,
        initState: (_) async {
          await _homeController.loadCamera();
          //await recordVideo();
          await _homeController.startImageStream();
          _fileInit();
          _homeController.cameraController?.stopVideoRecording();
        },
        builder: (_) {
          return Container(
            child: Column(
              children: [
                _.cameraController != null &&
                        _.cameraController!.value.isInitialized
                    ? Stack(children: [
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: Transform(
                              alignment: Alignment.center,
                              child: CameraPreview(_.cameraController!),
                              transform: Matrix4.rotationY(math.pi)),
                        ),
                        Visibility(
                          visible: _recShown,
                          child: Container(
                            margin: EdgeInsets.only(top: 28, left: 300),
                            child: Text('REC',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20)),
                          ),
                        ),
                        Visibility(
                          visible: _recShown,
                          child: Container(
                            margin: EdgeInsets.only(top: 30, left: 340),
                            child: CustomPaint(
                              painter: OpenPainter(),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _timerShown,
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 250),
                            child: Text("$_start",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 100)),
                          ),
                        ),
                        Container(
                          height: 80,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.5),
                          margin: EdgeInsets.only(top: 500),
                          padding: EdgeInsets.all(200),
                        ),
                        // Visibility(
                        //   visible: _nofaceShown,
                        //   child: Container(
                        //     margin: EdgeInsets.only(top: 470),
                        //     alignment: Alignment.center,
                        //     child: Text('${_.noface}',
                        //         style: TextStyle(
                        //           fontSize: 20,
                        //           color: Colors.red,
                        //         )),
                        //   ),
                        // ),
                        Positioned(
                          bottom: 36,
                          left: 0,
                          child: Column(
                            children: <Widget>[
                              if ('${_.eyes}' == 'Eyes opened')
                                Text('Eyes: ${_.eyes}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.greenAccent[400],
                                    )),
                              if ('${_.eyes}' == 'Eyes closed')
                                Text('Eyes: ${_.eyes}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent[400],
                                    )),
                              if ('${_.emotion}' == 'Smiling')
                                Text('Emotion: ${_.emotion}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.greenAccent[400],
                                    )),
                              if ('${_.emotion}' == 'Neutral')
                                Text('Emotion: ${_.emotion}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.orange,
                                    )),
                              if ('${_.emotion}' == 'Not Smiling')
                                Text('Emotion: ${_.emotion}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent[400],
                                    )),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 36,
                          right: 0,
                          child: Column(
                            children: <Widget>[
                              if ('${_.head}' == 'Left')
                                Text('Head Position: ${_.head}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent[400],
                                    )),
                              if ('${_.head}' == 'Right')
                                Text('Head Position: ${_.head}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent[400],
                                    )),
                              if ('${_.head}' == 'Straight')
                                Text('Head Position: ${_.head}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.greenAccent[400],
                                    )),
                              if ('${_.eyes}' == 'Eyes opened')
                                Text('Brightness: Good',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.greenAccent[400],
                                    )),
                              if ('${_.eyes}' == 'Eyes closed')
                                Text('Brightness: Bad',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent[400],
                                    )),
                            ],
                          ),
                        ),
                        if (_homeController.isRectangleVisible!)
                          Positioned(
                            left: _homeController.position['x'],
                            top: _homeController.position['y'],
                            child: InkWell(
                              child: Container(
                                width: _homeController.position['w'],
                                height: _homeController.position['h'],
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ])
                    : Center(child: Text('Camera Loading')),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          //   child:
          Row(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 40, left: 10),
            child: ElevatedButton(
              onPressed: () async {
                // stop recording text
                if (_buttonPressed == true) {
                  _start = 5;
                  timer.cancel();
                  _recShown = false;
                }
                // start recording text
                if (_buttonPressed == false) {
                  _timerShown = false;
                  startTimer();
                  await _homeController.cameraController?.startVideoRecording();
                }
                // if (_start >= 1) {
                //   _clicked == false ? _onTapped() : null;
                // }
                setState(() {
                  if (_buttonPressed == true && _timerShown == false) {
                    _timerShown = false;
                  } else {
                    _timerShown = !_timerShown;
                  }
                  _buttonPressed = !_buttonPressed;
                });
              },
              child: Text(_buttonPressed ? stoprec : startrec),
              style: ElevatedButton.styleFrom(
                  primary: _buttonPressed ? Colors.red : Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60))),
            ),
          ),
          Visibility(
            visible: _buttonPressed,
            child: Container(
              margin: EdgeInsets.only(bottom: 40, left: 40),
              child: ElevatedButton(
                onPressed: null,
                child: Text("Review"),
                style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
              ),
            ),
          ),
          Visibility(
            visible: _buttonPressed,
            child: Container(
              margin: EdgeInsets.only(bottom: 40, left: 45),
              child: ElevatedButton(
                onPressed: null,
                child: Text("Upload"),
                style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
              ),
            ),
          ),
        ],
      ),
      //),
    );
  }

  bool _buttonPressed = false;
  bool _timerShown = false;
  bool _recShown = false;
  bool _clicked = false;
  //bool _nofaceShown = true;
  String startrec = 'Start Recording';
  String stoprec = 'Stop Recording';

  void _onTapped() {
    setState(() {
      _clicked = true;
    });
  }

  Widget? _floatingActionButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 40, right: 110),
      child: ElevatedButton(
        onPressed: () {
          // stop recording text
          if (_buttonPressed == true) {
            _start = 5;
            timer.cancel();
            _recShown = false;
          }
          // start recording text
          if (_buttonPressed == false) {
            _timerShown = false;
            startTimer();
          }
          // if (_start >= 1) {
          //   _clicked == false ? _onTapped() : null;
          // }
          setState(() {
            if (_buttonPressed == true && _timerShown == false) {
              _timerShown = false;
            } else {
              _timerShown = !_timerShown;
            }
            _buttonPressed = !_buttonPressed;
          });
        },
        child: Text(_buttonPressed ? stoprec : startrec),
        style: ElevatedButton.styleFrom(
            primary: _buttonPressed ? Colors.red : Colors.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60))),
      ),
    );
  }

  late Timer timer;
  int _start = 5;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 1) {
          setState(() {
            timer.cancel();
            _timerShown = false;
            _recShown = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  bool _isRecording = false;
  CameraController? cameraController;

  recordVideo() async {
    if (_isRecording) {
      final file = await cameraController?.stopVideoRecording();
      setState(() => _isRecording = false);
      // final route = MaterialPageRoute(
      //   fullscreenDialog: true,
      //   builder: (_) => VideoPage(filePath: file!.path),
      // );
      // Navigator.push(context, route);
    } else {
      await cameraController?.prepareForVideoRecording();
      await cameraController?.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xFFD84315)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(10, 10), 10, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
