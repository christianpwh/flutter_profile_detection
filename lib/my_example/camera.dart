import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:ml_kit_example/my_example/detector_painters.dart';
import 'package:ml_kit_example/my_example/scanner_utils.dart';
import 'package:ml_kit_example/my_example/viewResult.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Camera extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraState();
}

class CameraState extends State<Camera> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  dynamic _scanResults;

  bool _isDetecting = false;

  List<String> staticCommand = [
    'hadapKanan',
    'hadapKiri',
    'miringKanan',
    'miringKiri',
  ];
  List<String> generateListCmd = [];
  List<String> newCommand = [];
  List<bool> commandValid = [];
  List<String> commandLabel = [
    "Hadapkan Wajah Anda ke Arah Kanan",
    "Hadapkan Wajah Anda ke Arah Kiri",
    "Miringkan Kepala ke Arah Kanan",
    "Miringkan Kepala Anda ke Arah Kiri",
  ];
  String commandLabelView = "Tidak Ada Perintah Yang Diberikan";

  bool allValidate = false;
  bool isCountdown = false;
  bool failValidate = false;
  int countdown = 60;

  Color commandLabelColor = Colors.blue;

  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();

  @override
  void initState() {
    super.initState();
    newCommand = generateCommand();
    isCountdown = true;
    starCountdown();
    init();
  }

  List<String> generateCommand() {
    var rng = Random();

    for (int i = 0; i < 3; i++) {
      generateListCmd.add(staticCommand[rng.nextInt(4)]);
      if (generateListCmd.length == 2) {
        checkSecondElement();
      }
      if (generateListCmd.length == 3) {
        checkThirdElement();
      }
    }

    return generateListCmd;
  }

  void checkSecondElement() {
    var rng = Random();
    if (generateListCmd[1] == generateListCmd[0]) {
      generateListCmd[1] = staticCommand[rng.nextInt(3)];
      checkSecondElement();
    } else {}
  }

  void checkThirdElement() {
    var rng = Random();
    if (generateListCmd[2] == generateListCmd[1] ||
        generateListCmd[2] == generateListCmd[0]) {
      generateListCmd[2] = staticCommand[rng.nextInt(3)];
      checkThirdElement();
    } else {}
  }

  void init() async {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print("Error : $err.code\nError Message : $err.message");
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    final availableCamera = await availableCameras();
    final frontCam = availableCamera[1];
    final CameraDescription description =
        await ScannerUtils.getCamera(CameraLensDirection.front);

    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(frontCam, ResolutionPreset.medium);

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print("Camera error ${cameraController.value.errorDescription}");
      }
    });

    try {
      await cameraController.initialize();
      cameraController.startImageStream((image) {
        if (_isDetecting) return;

        _isDetecting = true;

        ScannerUtils.detect(
          image: image,
          detectInImage: _getDetectionMethod(),
          imageRotation: description.sensorOrientation,
        ).then(
          (results) {
            setState(() {
              _scanResults = results;
            });
          },
        ).whenComplete(() => _isDetecting = false);
        scanFace();
      });
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose().then((value) {
      _faceDetector.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 1.2,
                  width: MediaQuery.of(context).size.width,
                  child: _cameraPreview(context),
                ),
                cameraController != null
                    ? Container(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            height: MediaQuery.of(context).size.height / 10,
                            width: MediaQuery.of(context).size.width / 1.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.0),
                                border:
                                    Border.all(color: Colors.blue, width: 1.0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                isCountdown == true
                                    ? Text(
                                        "Waktu Validasi : $countdown detik",
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.redAccent),
                                      )
                                    : Container(),
                                Text(
                                  commandLabelView,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  style: TextStyle(
                                      fontSize: 15.0, color: commandLabelColor),
                                ),
                              ],
                            )),
                      )
                    : Container(),
              ],
            ),
            Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height / 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        color: Colors.redAccent,
                        elevation: 10.0,
                        child: Icon(
                          Icons.arrow_back,
                          size: 75.0,
                          color: Colors.white,
                        ),
                        onPressed: failValidate == true
                            ? () {
                                _onFailPressed(context);
                              }
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        elevation: 10.0,
                        color: Colors.white,
                        child: Icon(
                          Icons.camera,
                          size: 75.0,
                          color: Colors.deepOrangeAccent,
                        ),
                        onPressed: allValidate == true
                            ? () {
                                _onCapturePressed(context);
                              }
                            : null,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void starCountdown() {
    isCountdown = true;
    const oneSec = const Duration(seconds: 1);
    if (countdown > 0) {
      Timer.periodic(oneSec, (Timer timer) {
        if (allValidate) {
          timer.cancel();
        }
        if (countdown > 0) {
          setState(() {
            countdown = countdown - 1;
          });
        } else {
          timer.cancel();
          setState(() {
            countdown = 60;
          });
          if (!allValidate) {
            failFaceValidation();
          }
        }
      });
    } else {}
  }

  void setCommandLabel(String cmd) {
    setState(() {
      if (cmd == 'hadapKanan') {
        commandLabelView = commandLabel[0];
      } else if (cmd == 'hadapKiri') {
        commandLabelView = commandLabel[1];
      } else if (cmd == 'miringKanan') {
        commandLabelView = commandLabel[2];
      } else if (cmd == 'miringKiri') {
        commandLabelView = commandLabel[3];
      }
    });
  }

  bool faceDirectionCheck(String cmd, double rotY, double rotZ) {
    if (cmd == 'hadapKanan') {
      return rightFace(rotY);
    } else if (cmd == 'hadapKiri') {
      return leftFace(rotY);
    } else if (cmd == 'miringKanan') {
      return rightTiltFace(rotZ);
    } else if (cmd == 'miringKiri') {
      return leftTiltFace(rotZ);
    } else {
      return false;
    }
  }

  void scanFace() {
    double rotY;
    double rotZ;
    bool valid = false;

    if (newCommand.isNotEmpty && !failValidate) {
      setCommandLabel(newCommand[0]);
    }

    if (newCommand.isNotEmpty && !failValidate) {
      if (_scanResults != null && _scanResults != []) {
        for (Face face in _scanResults) {
          setCommandLabel(newCommand[0]);
          rotY = face.headEulerAngleY;
          rotZ = face.headEulerAngleZ;
          valid = faceDirectionCheck(newCommand[0], rotY, rotZ);

          if (valid) {
            setState(() {
              newCommand.removeAt(0);
            });
          }
        }
      }
    } else {
      faceLiveValidation();
    }

    // for (Face face in _scanResults) {
    //   rotY = face.headEulerAngleY;
    //   rotZ = face.headEulerAngleZ;
    //   if (rotY < -20) {
    //     print("hadap kanan");
    //   }
    //   if (rotY > 20) {
    //     print("hadap kiri");
    //   }
    //   if (rotZ < -20) {
    //     print('miring kiri');
    //   }
    //   if (rotZ > 20) {
    //     print("miring kanan");
    //   }
    // }
  }

  void faceLiveValidation() {
    if (commandValid.length == 3) {
      if (commandValid[0] == true &&
          commandValid[1] == true &&
          commandValid[2] == true) {
        setState(() {
          cameraController.stopImageStream();
          allValidate = true;
          isCountdown = false;
          commandLabelColor = Colors.greenAccent;
          commandLabelView =
              "Semua Perintah Sudah Tervalidasi Silahkan Ambil Selfie";
        });
      }
    }
  }

  void failFaceValidation() {
    setState(() {
      cameraController.stopImageStream();
      isCountdown = false;
      failValidate = true;
      commandLabelColor = Colors.redAccent;
      commandLabelView =
          "Validasi perintah gagal. Silahkan kembali ke menu utama dan coba kembali";
    });
  }

  bool rightFace(double faceRot) {
    if (faceRot < -20) {
      commandValid.add(true);

      return true;
    } else {
      return false;
    }
  }

  bool leftFace(double faceRot) {
    if (faceRot > 20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  bool rightTiltFace(double faceRot) {
    if (faceRot > 20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  bool leftTiltFace(double faceRot) {
    if (faceRot < -20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  Widget _cameraPreview(context) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Text(
          "LOADING",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w900),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: Stack(
        children: <Widget>[
          CameraPreview(cameraController),
          Container(
            margin: const EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/selfie_ktp_trans.png"),
                    fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }

  void _onCapturePressed(context) async {
    String date = DateTime.now().toString();
    List<String> lDate = date.split(" ");
    String times = lDate.last;
    List<String> lTime = times.split(".");
    String ddmmyy = lDate.first.replaceAll("-", "");
    String time = lTime.first.replaceAll(":", "");

    String filename = "Liveness" + "_" + ddmmyy + time + ".jpg";

    try {
      final path = join((await getExternalStorageDirectory()).path, filename);

      await cameraController.takePicture(path);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ViewResult(
                    imagePath: path,
                  )));
    } catch (e) {
      print(e);
    }
  }

  void _onFailPressed(context) {
    Navigator.of(context).pop();
  }
}
