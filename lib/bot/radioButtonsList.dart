import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;

class RadioList extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;
  int initValue;

  RadioList(this.context,this.controller, this.message);

  @override
  RadioListWidget createState() => RadioListWidget();
}


class RadioListWidget extends State<RadioList> {

  String currentLabel = "";
  // Group Value for Radio Button.
  int currentId;
  //List<MultipleChoiceItem> nList = difficultyItems;
  List<String> nList;
  String otherText = "";

  Widget build(BuildContext context) {

     nList = widget.message.choices;

      List<Widget> radioList = List<Widget>.generate(nList.length, (int index) {
        return RadioListTile<int>(
          dense: true,

          value: index,
          title: nList[index]=="__Other"?
          TextField(

              style: Theme
                  .of(context)
                  .textTheme
                  .display2,
              decoration: InputDecoration(
                //border: InputBorder.none,
                  hintText: 'Other (please specify)'
              ),
              onChanged: (textVal) {
                setState(() {
                  widget.initValue = index;
                  otherText = textVal;
                });
              })
          : Text( "${nList[index]}",style: Theme.of(context).textTheme.display2,),
          groupValue:widget.initValue,
          onChanged: (int value) {
            setState(() => widget.initValue = value);
          },
        );

      });

     bool checkOther(){
       if(nList[widget.initValue] == "__Other" && otherText==""){
         return false;
       }
       return true;
     }

      radioList.add(RawMaterialButton(
        //label:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,),
        child: Icon(Icons.arrow_forward_ios, color: Colors.white,),    //  new Text("Enter", style: Theme.of(context).textTheme.display2),
        fillColor: widget.initValue == null || !checkOther() ? Colors.grey[400] : Theme.of(context).primaryColor,
        shape: new CircleBorder(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        onPressed: () {
          if(widget.initValue != null && checkOther() ) {
            if(nList[widget.initValue] == "__Other"){
              nList[widget.initValue] = otherText;
            }
            screen.enterUserMessage(nList[widget.initValue], codeM: widget.message.code );

            String nextPair = getNextPair(widget.message,answerCode: widget.initValue);
            if (nextPair != null) {
              widget.controller.add(nextPair);
            }
          }
        },
      ));




      return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget> [
            Container(
                margin: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                width: MediaQuery.of(context).size.width * .8,
                constraints: BoxConstraints(maxWidth: 400),
                child:Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: radioList
                )
            )
          ]
    );


  }
}

class MultipleChoiceItem {
  String label;
  int index;
  MultipleChoiceItem({this.label, this.index});
}

