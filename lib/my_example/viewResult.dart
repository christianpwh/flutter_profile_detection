import 'dart:io';

import 'package:flutter/material.dart';

class ViewResult extends StatelessWidget {
  String imagePath = "";
  ViewResult({this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RESULT'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          imagePath != "" || imagePath != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Image.file(File(imagePath)),
                )
              : Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Icon(Icons.person),
                ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
          ),
          RaisedButton(
            child: Text("KEMBALI KE HOMEPAGE"),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
