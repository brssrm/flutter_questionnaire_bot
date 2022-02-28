import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;

class CheckList extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  CheckList(this.context,this.controller, this.message);

  @override
  CheckListWidget createState() => CheckListWidget();
}


class CheckListWidget extends State<CheckList> {

  List<String> selectedList = [];
  // Group Value for Radio Button.
  //List<MultipleChoiceItem> nList = difficultyItems;
  List<String> nList;
  List<bool> isSelected;

  String otherText = "";


  Widget build(BuildContext context) {

    nList = widget.message.choices;
    isSelected = List<bool>.generate(nList.length, (int index) {return false;});

    List<Widget> radioList = List<Widget>.generate(nList.length, (int index) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return CheckboxListTile(
              dense: true,
              value: isSelected[index],
              selected: isSelected[index],
              controlAffinity: ListTileControlAffinity.leading,
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
                      otherText = textVal;
                  }
                  )
                  : Text( "${nList[index]}",style: Theme.of(context).textTheme.display2,),
              onChanged: (newValue) {
                setState(() {
                  isSelected[index] = newValue;
                  if(selectedList.contains(nList[index]) && !newValue){
                    selectedList.remove(nList[index]);
                  }
                  else if(!selectedList.contains(nList[index]) && newValue){
                    selectedList.add(nList[index]);
                  }
                });
              },
            );
          });
    });

    radioList.add(Text(""));

    radioList.add(RawMaterialButton(
      //label:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,),
      child: Icon(Icons.arrow_forward_ios, color: Colors.white,),    //  new Text("Enter", style: Theme.of(context).textTheme.display2),
      fillColor: Theme.of(context).primaryColor,
      shape: new CircleBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(10.0),

      onPressed: () {
          int index = selectedList.indexOf("__Other");
          if(index>-1){
            selectedList[index] = otherText;
          }
          screen.enterUserMessage(listToString(selectedList), codeM: widget.message.code );

          String nextPair = getNextPair(widget.message);
          if (nextPair != null) {
            widget.controller.add(nextPair);
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

  String listToString(List<String> selected){
    if(selected.length==1){
      return selected[0];
    }
    else if(selected.length==0){
      return "None of them";
    }
    else{
      return selected.join(', ');
    }
  }
}

class MultipleChoiceItem {
  String label;
  int index;
  MultipleChoiceItem({this.label, this.index});
}

