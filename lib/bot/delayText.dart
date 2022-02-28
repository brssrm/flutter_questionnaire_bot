import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;

class DelayText extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  DelayText(this.context,this.controller, this.message);

  @override
  DelayTextState createState() => DelayTextState();
}


class DelayTextState extends State<DelayText> {

  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed( Duration(seconds: 2), ()
    {
      String nextPair = getNextPair(widget.message);
      if (nextPair != null) {
        widget.controller.add(nextPair);
      }
    });
  }
}