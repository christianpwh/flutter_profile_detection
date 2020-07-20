import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOME",
          style: TextStyle(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: RaisedButton(
          child: Text("MULAI VALIDASI"),
          onPressed: () {
            Navigator.of(context).pushNamed('/Camera');
          },
        ),
      ),
    );
  }
}
