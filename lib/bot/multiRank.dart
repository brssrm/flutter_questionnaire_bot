import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'dialogDB.dart';
import 'chatscreen.dart' as screen;

class MultiRank extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;
  int initValue;

  MultiRank(this.context,this.controller, this.message);

  @override
  MultiRankWidget createState() => MultiRankWidget();
}


class MultiRankWidget extends State<MultiRank> {

  String currentLabel = "";
  // Group Value for Radio Button.
  int counter;
  String theme;
  List<String> recommendations;
  bool freshBuild = true;


  Widget build(BuildContext context) {
    List<Widget> list;

    if(widget.message.inputType == "multiRank"){
      list = List.generate(widget.message.choices.length, (index) => buildEntry(index));
    }
    if(widget.message.inputType == "multiRankLikert"){
      list = List.generate(widget.message.choices.length, (index) => buildEntryLikert(index));
    list.add(RawMaterialButton(
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
      onPressedButton(widget.initValue);
    }
    },
    ));
    }



    double widthW = MediaQuery.of(context).size.width > 500 ? 460 : MediaQuery.of(context).size.width-40;


    if(widget.message.data != null && widget.message.data['theme'] != null && freshBuild) {
      freshBuild= false;
      theme =  widget.message.data['theme'];

      if(theme.length==2 || theme == "all"){
        recommendations = screen.getRecs( widget.message.data['theme']);

        if(widget.message.data['shuffle'] != null && widget.message.data['shuffle']){
          recommendations.shuffle();
        }

        if(widget.message.data['maxLimit'] != null && widget.message.data['maxLimit'] < recommendations.length){
          recommendations = recommendations.sublist(0,widget.message.data['maxLimit']);
        }

        //print(recommendations);
      }
      else if(theme=="follow"){
        recommendations = getList("usefulList");
      }
      else if(theme=="confidence" || theme == "motivation"){
        recommendations = getList("goalList");
      }
    }

    Widget rankerWidget;

    if(recommendations.length>0){
      rankerWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 24,
                    child: themeHeader(recommendations[counter]),
                    padding: const EdgeInsets.all(2),
                  ),
                  Container(
                    height: 140,
                    child: Text(screen.recs[recommendations[counter]], style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: -1) ),
                    padding: const EdgeInsets.all(16),
                  )

                ]

            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: list.toList()
            ),
            Text(widget.initValue == null ? " " : widget.message.choices[widget.initValue], style: Theme.of(context).textTheme.body2),
          ]);
    }
    else{
      rankerWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Container(
              child: Text("Seems like this list empty, proceed to the next question.", style: Theme.of(context).textTheme.display2.apply(fontSizeDelta: -2)),
              padding: const EdgeInsets.all(16),
            ),
            RawMaterialButton(
              //label:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor,),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(8.0)),
                child: new Text("Proceed",
                    style: Theme.of(context)
                        .textTheme
                        .display2
                        .apply(color: Colors.white)), //  new Text("Enter", style: Theme.of(context).textTheme.display2),
                fillColor: Theme.of(context).primaryColor,
                //

                //margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),

                onPressed: () {
                  String nextPair = getNextPair(widget.message);
                  if (nextPair != null) {
                    widget.controller.add(nextPair);
                  }
                }
            ),


          ]);
    }


    //Widget emptyWidget =


    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Container(
              constraints: BoxConstraints(
                maxWidth: widthW,
              ),
              width: widthW,
              margin: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),

              child:  rankerWidget
          )]);

  }

  Widget themeHeader(String code){
    if(code.substring(0,2)== "sl"){
      return Row(
        children: [
          Text("   "),
          Icon(Icons.king_bed_outlined, color: Theme.of(context).primaryColor),
          Text("  Sleep", style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).primaryColor,fontSizeDelta: 2))
        ],
      );
    }
    if(code.substring(0,2)== "al"){
      return Row(
        children: [
          Text("   "),
          Icon(Icons.wb_incandescent_outlined, color: Theme.of(context).primaryColor),
          Text("  Alertness", style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).primaryColor,fontSizeDelta: 2))
        ],
      );
    }
    if(code.substring(0,2)== "so"){
      return Row(
        children: [
          Text("   "),
          Icon(Icons.people_alt_outlined, color: Theme.of(context).primaryColor),
          Text("  Social", style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).primaryColor,fontSizeDelta: 2))
        ],
      );
    }
    return Container();
  }

  Widget getButtonIcon(index){
    if(theme!= null && (theme.length==2 || theme == "all")) {
      if(index==1){
        return Icon(Icons.star_half, color: Theme.of(context).primaryColor,size:20);
      }
      else if(index==2){
        return Icon(Icons.star, color: Theme.of(context).primaryColor,size:20);
      }
    }
    return Container();
  }

  Widget buildEntry(int index) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),

        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
              side: BorderSide(color: Theme.of(context).primaryColor)
          ),
          child: Row( children: [
            Container(),
            Text(widget.message.choices[index],
                style: Theme.of(context)
                    .textTheme
                    .display2
                    .apply(fontSizeFactor: 1))
          ],),
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          onPressed: () {
            onPressedButton(index);
          },
        ));
  }

  Widget buildEntryLikert(int index) {
    return  Column(children: <Widget>[
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
  }

  void onPressedButton(int index){
    if(theme.length==2 || theme == "all") {
      screen.enterUserMessageSilent("$index", codeM: recommendations[counter]);
    }else if(theme == "follow"){
      screen.enterUserMessageSilent("$index", codeM: "follow_" + recommendations[counter]);
    }
    else if(theme == "motivation" || theme == "confidence"){
      screen.enterUserMessageSilent("$index", codeM: "${theme}_" + recommendations[counter]);
    }
    widget.initValue = null;

    if(widget.message.data != null && widget.message.data['dataLists']!= null) {
      addToList(recommendations[counter],widget.message.data['dataLists'][index]);
    }

    /*
    if(index==2 && (theme.length==2 || theme == "all")){
      addToList(recommendations[counter],"usefulList");
    }
    if(index==1 && (theme.length==2 || theme == "all")){
      addToList(recommendations[counter],"somewhatUsefulList");
    }
    if(index==1 && theme == "follow"){
      addToList(recommendations[counter],"followList");
    }

     */

    setState(() {
      counter++;
    });

    if(counter==recommendations.length){
      screen.insertSystemMessage("You have completed the selection.", codeM: widget.message.code );
      String nextPair = getNextPair(widget.message, answerCode: index);
      if (nextPair != null) {
        counter =0;
        recommendations.clear();
        widget.controller.add(nextPair);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    freshBuild = true;
    counter = 0;
  }
}

