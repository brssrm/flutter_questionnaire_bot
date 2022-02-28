import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;

class RadioGroup extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;
  int initValue;

  RadioGroup(this.context,this.controller, this.message);

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}


class RadioGroupWidget extends State<RadioGroup> {

  String currentLabel = "";
  // Group Value for Radio Button.
  int currentId;
  List<String> nList;


  Widget build(BuildContext context) {
    nList = widget.message.choices;

    //currentId = null;
    List<Widget> radioList = List<Widget>.generate(nList.length, (int index) {
      return Column(children: <Widget>[
        Text("${index+1}", style: Theme.of(context).textTheme.display2,),
        Radio<int>(

          value: index,
          //title: Text(index.toString()),
          groupValue:widget.initValue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (int value) {
            setState(() => widget.initValue = value);
          },
        ),


      ]);
    });
    //radioList.add(Text(" "));
    radioList.add(RawMaterialButton(
      //key: PageStorageKey(widget.message.code),
      //label:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,),
      child: Icon(Icons.arrow_forward_ios, color: Colors.white,),    //  new Text("Enter", style: Theme.of(context).textTheme.display2),
      fillColor: widget.initValue == null ? Colors.grey[400] : Theme.of(context).primaryColor,
      shape: new CircleBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(10.0),
      onPressed: () {
        if(widget.initValue != null) {
          screen.enterUserMessage(nList[widget.initValue],codeM: widget.message.code);

          String nextPair = getNextPair(widget.message, answerCode: widget.initValue);
          if (nextPair != null) {
            widget.controller.add(nextPair);
          }
        }
      },
    ));

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Container(
              margin: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),

              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: radioList,

                    ),
                    Text(widget.initValue == null ? "Select" : nList[widget.initValue], style: Theme.of(context).textTheme.body2),

                  ]))]);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentId = null;
  }
}

List<String>  agreementLabels = ["Completely disagree","Disagree","Somewhat disagree","Somewhat agree","Agree","Completely agree"];
List<String>  difficultyLabels = ["Very difficult","Difficult","Neither hard nor easy","Easy","Very easy"];
