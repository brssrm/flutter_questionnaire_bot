import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dialog.dart';
import 'dialogDB.dart';
import 'chatscreen.dart' as screen;

class CheckDynamic extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  CheckDynamic(this.context,this.controller, this.message);

  @override
  CheckDynamicWidget createState() => CheckDynamicWidget();
}


class CheckDynamicWidget extends State<CheckDynamic> {

  List<String> selectedList;
  // Group Value for Radio Button.
  //List<MultipleChoiceItem> nList = difficultyItems;
  List<String> nList;
  List<bool> isSelected;
  int maxLimit;
  String titleText = "";

  Widget themeHeader(String code){
    if(code.substring(0,2)== "sl"){
      return Icon(Icons.king_bed_outlined, color: Theme.of(context).primaryColor);
    }
    if(code.substring(0,2)== "al"){
      return Icon(Icons.wb_incandescent_outlined, color: Theme.of(context).primaryColor);
    }
    if(code.substring(0,2)== "so"){
      return Icon(Icons.people_alt_outlined, color: Theme.of(context).primaryColor);
    }
    return Container();
  }

  Widget build(BuildContext context) {

    nList = [];
    selectedList = [];
    maxLimit = 99;

    if( widget.message.data != null && widget.message.data['inputDataListsPlus']!= null) {
      for(String l in widget.message.data["inputDataListsPlus"]){
          nList = nList + getList(l);
      }
    }
    else{
      nList = getList("usefulList");
    }

    //print(nList);


    isSelected = List<bool>.generate(nList.length, (int index) {return false;});

    if( widget.message.data != null && widget.message.data['maxLimit']!= null) {
      maxLimit =  widget.message.data['maxLimit'];
    }

    if( widget.message.data != null && widget.message.data['titleText']!= null) {
      titleText =  widget.message.data['titleText'];
    }

    List<Widget> radioList = List<Widget>.generate(nList.length, (int index) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Divider(color: Theme.of(context).primaryColor, thickness: 0.5,indent: 10,endIndent: 10,),
                CheckboxListTile(
                  dense: true,
                  //contentPadding: EdgeInsets.all(8.0),

                  value: isSelected[index],
                  selected: isSelected[index],
                  //controlAffinity: ListTileControlAffinity.leading,
                  title: Text( "${screen.recs[nList[index]]}",style: Theme.of(context).textTheme.body2,softWrap: true,),
                  secondary:themeHeader(nList[index]),
                  onChanged: (newValue) {
                    //print(selectedList.length);
                    if( selectedList.contains(nList[index]) || selectedList.length < maxLimit){
                      setState(() {
                        isSelected[index] = newValue;
                        if(selectedList.contains(nList[index]) && !newValue){
                          selectedList.remove(nList[index]);
                        }
                        else if(!selectedList.contains(nList[index]) && newValue){
                          selectedList.add(nList[index]);
                        }
                      });
                    } },
                )
              ],
            );
          });
    });


    radioList.add(Text(nList.length == 0 ? "Looks like you have not found anything useful. Proceed to the next question." : "",style: Theme.of(context)
        .textTheme
        .body1));

    radioList.add(Container(
      padding: const EdgeInsets.all(10.0),
        child:RawMaterialButton(
      //label:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0)),
        child: new Text(nList.length == 0 ? "Proceed" : "Submit",
            style: Theme.of(context)
                .textTheme
                .display2
                .apply(color: Colors.white)), //  new Text("Enter", style: Theme.of(context).textTheme.display2),
      fillColor: Theme.of(context).primaryColor,
      //

      //margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(10.0),

      onPressed: () {
        Navigator.of(context).pop();
        screen.insertSystemMessage("You have completed the selection.", codeM: widget.message.code );

        if( widget.message.data != null && widget.message.data['dataLists']!= null) {

          //add the selected ones to the list
          for (String s in selectedList) {
            addToList(s,widget.message.data['dataLists'][1]);
          }

          //add the notSelected ones to the list
          List<String> unselectedList = nList;
          unselectedList.removeWhere((e) => selectedList.contains(e));
          for (String s in unselectedList) {
            addToList(s,widget.message.data['dataLists'][0]);
          }
        }

        screen.enterUserMessageSilent(listToString(selectedList), codeM: widget.message.code );

        selectedList.forEach((element) {
          addToList(element,"goalList");
        });

        String nextPair = getNextPair(widget.message);
        if (nextPair != null) {
          widget.controller.add(nextPair);
        }
      },
    )));



    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
              side: BorderSide(color: Theme.of(context).primaryColor)),
          elevation: 2.0,
          child: new Text(widget.message.label,
              style: Theme.of(context)
                  .textTheme
                  .display2
                  .apply(color: Colors.white)),
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(16.0),

          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(titleText),
                  scrollable: true,
                  contentPadding: EdgeInsets.symmetric(vertical:5,horizontal:5),
                  content: SingleChildScrollView(

                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: radioList
                ))

                );
              },
            );
          },
        ));

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

