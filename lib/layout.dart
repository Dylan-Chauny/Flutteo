import 'package:flutter/material.dart';

class Layout extends StatefulWidget{

  @override
  _LayoutState createState() => new _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: RaisedButton(onPressed: pressed),
    );
  }
    void pressed() {
      setState(() {
        print("OK");
      });
    }
}
