// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:ml_kit_example/my_example/camera.dart';
import 'package:ml_kit_example/my_example/home.dart';
import 'package:ml_kit_example/my_example/viewResult.dart';

import 'package:ml_kit_example/flutterFireVision/camera_preview_scanner.dart';
import 'package:ml_kit_example/flutterFireVision/picture_scanner.dart';
import 'package:ml_kit_example/flutterFireVision/material_barcode_scanner.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        // Home itu ke aplikasi gw kalo _ExampleList itu ke sample aplikasi dari Firebase nya
        '/': (BuildContext context) => Home(),
        '/Camera': (BuildContext context) => Camera(),
        '/Result': (BuildContext context) => ViewResult(),
        // _ExampleList(),
        '/$PictureScanner': (BuildContext context) => PictureScanner(),
        '/$CameraPreviewScanner': (BuildContext context) =>
            CameraPreviewScanner(),
        '/$MaterialBarcodeScanner': (BuildContext context) =>
            const MaterialBarcodeScanner(),
      },
    ),
  );
}

class _ExampleList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExampleListState();
}

class _ExampleListState extends State<_ExampleList> {
  static final List<String> _exampleWidgetNames = <String>[
    '$PictureScanner',
    '$CameraPreviewScanner',
    '$MaterialBarcodeScanner',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example List'),
      ),
      body: ListView.builder(
        itemCount: _exampleWidgetNames.length,
        itemBuilder: (BuildContext context, int index) {
          final String widgetName = _exampleWidgetNames[index];

          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: ListTile(
              title: Text(widgetName),
              onTap: () => Navigator.pushNamed(context, '/$widgetName'),
            ),
          );
        },
      ),
    );
  }
}
