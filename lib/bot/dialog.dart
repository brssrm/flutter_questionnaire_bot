import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webapp/bot/dialogDB.dart';
import 'chatscreen.dart' as screen;
import 'radioButtonsNum.dart';
import 'radioButtonslist.dart';
import 'checkButtonlist.dart';
import 'checkButtonDynamic.dart';
import 'textEntry.dart';
import 'multiRank.dart';
import 'openEnded.dart';
import 'uploadButton.dart';
import 'taskBlock.dart';
import 'texts.dart';
import 'delayText.dart';
import 'package:firebase/firebase.dart' as fb;
import 'dart:html' as html;

class BotMessage {
  String text;
  //final Function inputFunction;
  //final Function inputF;
  final String code;
  final String codeN;
  final String type;
  final String label;
  final String inputType;
  final String initVal;
  List<String> choices;
  List<String> choicePaths;
  Map data;

// constructor to get text from textfield
  BotMessage(
      {@required this.code,
      this.text,
      this.type,
      this.codeN,
      this.label,
      this.initVal,
      this.inputType,
      this.choices,
      this.choicePaths,
      this.data});

  factory BotMessage.fromJson(Map<String, dynamic> jsonData) {
    BotMessage _message = BotMessage(
        code: jsonData['code'] as String,
        text: jsonData['text'] as String,
        type: jsonData['type'] as String,
        codeN: jsonData['codeN'] as String,
        label: jsonData['label'] as String,
        initVal: jsonData['initVal'] as String,
        inputType: jsonData['inputType'] as String);

    if (jsonData['choices'] != null) {
      _message.choices = List.from(jsonData['choices']);
    }

    if (jsonData['choicePaths'] != null) {
      _message.choicePaths = List.from(jsonData['choicePaths']);
    }

    if (jsonData['data'] != null) {
      _message.data = Map.from(jsonData['data']);
    }

    return _message;
  }
}

class Option {
  String label;
  String codeN;

  Option(this.label, this.codeN);
}

class NextButton extends StatelessWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  NextButton(this.context, this.controller, this.message);



  @override
  Widget build(BuildContext context) {
    if(message.data != null && message.data['dataFetch']!= null) {
      for (String d in message.data['dataFetch']) {
        if (html.window.localStorage.containsKey(d)) {
          screen.enterUserMessageSilent(html.window.localStorage[d], codeM: d);
        }
      }
    }

    List<Widget> list =
        List.generate(message.choices.length, (index) => buildEntry(index));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, children: list.toList()),
    );
    /*
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget> [
          Container(
              margin: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              width: MediaQuery.of(context).size.width * .8,

              child:Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:  list.toList()
              )
          )
        ]
    );

       */
  }

  Widget buildEntry(int index) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
              side: BorderSide(color: Theme.of(context).primaryColor)),
          child: new Text(message.choices[index],
              style: Theme.of(context)
                  .textTheme
                  .display2
                  .apply(fontSizeFactor: 1)),
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          onPressed: () {
            screen.enterUserMessage(message.choices[index],
                codeM: message.code);
            String nextPair = getNextPair(message, answerCode: index);
            if (nextPair != null) {
              controller.add(nextPair);
            }
          },
        ));
  }
}

Widget linkButton(
    BuildContext context, StreamController<String> controller, message) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0)),
        elevation: 2.0,
        child: new Text(message.label,
            style: Theme.of(context)
                .textTheme
                .display2
                .apply(color: Colors.white)),
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(16.0),
        onPressed: () {
         launch(message.data["link"]);
         screen.enterUserMessage(message.label, codeM: message.code);
         String nextPair = getNextPair(message);
         if (nextPair != null) {
           controller.add(nextPair);
         }
        },
      ));
}

Widget uploadButton(
    BuildContext context, StreamController<String> controller, message) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0)),
        elevation: 2.0,
        child: new Text(message.label,
            style: Theme.of(context)
                .textTheme
                .display2
                .apply(color: Colors.white)),
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(8.0),
        onPressed: () async{
          fb.StorageReference storageRef = fb.storage().ref('pilot1/deneme');
          fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put("sadadasdasda").future;
        },
      ));
}

Widget plainText(
    BuildContext context, StreamController<String> controller, message) {
  return Container();
}

Widget inputWidget(BotMessage message, BuildContext context,
    StreamController<String> controller) {
  if (message.inputType == "buttons") {
    return NextButton(context, controller, message);
  }
  if (message.inputType == "none") {
    return plainText(context, controller, message);
  }
  if (message.inputType == "delay") {
    return new DelayText(context, controller, message);
  }
  if (message.inputType == "openEnded") {
    return new OpenEnded(context, controller, message);
  }
  if (message.inputType == "likert") {
    return new RadioGroup(context, controller, message);
  }
  if (message.inputType == "multipleChoice") {
    return new RadioList(context, controller, message);
  }
  if (message.inputType == "checkBoxes") {
    return new CheckList(context, controller, message);
  }
  if (message.inputType == "textEntry" || message.inputType == "numerical" || message.inputType == "textEntry_long") {
    return new TextEntryDialog(context, controller, message);
  }
  if (message.inputType == "link") {
    return linkButton(context, controller, message);
  }
  if (message.inputType == "upload") {
    return UploadButton(context, controller, message);
  }
  if (message.inputType == "multiRank" || message.inputType == "multiRankLikert" ) {
    return new MultiRank(context, controller, message);
  }
  if (message.inputType == "checkDynamic") {
    return new CheckDynamic(context, controller, message);
  }
  if (message.inputType == "taskBlock") {
    return TaskBlock(context, controller, message);
  }
  return Container();
}

BotMessage getMessage(String codeM) {
  BotMessage message = new BotMessage(
      code: "Empty",
      text: "Ok, I have no answers for now.",
      codeN: "",
      inputType: "empty");

  for (BotMessage m in botMessages) {
    if (m.code == codeM) {
      message = m;

      //do any text modification if needed
      if( message.data != null && message.data["placeholder"]!= null) {
        for(String l in message.data["placeholder"]){
          List<String> placeholders = l.split("__");
          print(getList(placeholders[1]));
          List<String> data = getList(placeholders[1]);
          if(placeholders[0]=="recommendation"){

            message.text = message.text.replaceAll("__1",screen.recs[data[0]]);
          }
        }
      }

      break;
    }
  }

  return message;
}

List<BotMessage> botMessages;
List<String> countedList;
List<String> dialogOrder;

String getNextPair(BotMessage _message, {int answerCode = 0}) {

  //check for any choice paths
  if (_message.choicePaths != null) {
    if(_message.data != null && _message.data['binaryCondition'] != null){
      bool condition = true;

      for(String c in  _message.data['binaryCondition']){
        List<String> cList = c.split("__");
        print(cList);
        List<String> elementList = getList(cList[1]);
        if(elementList.length == 0){
          condition = false;
        }
      }

      String next = condition ? _message.choicePaths[0] : _message.choicePaths[1];
      return next;

    }
    else{
      return _message.choicePaths[answerCode];
    }
  }

  //check for any codeN
  else if(_message.codeN!=null){
    return _message.codeN;
  }

  //go by default
  else {
    int order = dialogOrder.indexWhere((pair) => pair == _message.code);
    if (order > -1 && order + 1 < dialogOrder.length) {
      return dialogOrder[order + 1];
    }
  }

  return null;
  //return "Empty";
}

List<String> genderSelection = [
  "Female",
  "Male",
  "Non-binary",
  "Prefer not to disclose"
];
List<String> visualFunction = [
  "Excellent",
  "Good",
  "Fair",
  "Poor",
  "Very Poor",
  "Blind"
]; //Visual Function Questionnaire (VFQ-25)
List<String> manualAbility = [
  "Easy",
  "A little hard",
  "Very hard",
  "Cannot do"
]; // Modified Manual Ability Measurement, MAM-36
List<String> applicationsUsed = [
  "Whatsapp",
  "Facebook",
  "Email",
  "Internet browser",
  "Maps"
];
List<String> agreement = [
  "Completely disagree",
  "Disagree",
  "Somewhat disagree",
  "Somewhat agree",
  "Agree",
  "Completely agree"
];
List<String> tips = [
  "Completely disagree",
  "Disagree",
  "Somewhat disagree",
  "Somewhat agree",
  "Agree",
  "Completely agree"
];