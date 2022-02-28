import 'package:flutter/material.dart';
import '../main.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String date;
  final int isUser;

  final BoxDecoration botBox = BoxDecoration(
      color: Colors.white, //mainColor.withOpacity(0.15),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          bottomLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0)));

  final BoxDecoration userBox = BoxDecoration(
      color: mainColor.withOpacity(0.15),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(0)));

  //final TextStyle botStyle =  Theme.of(context).textTheme.body2; // TextStyle(fontSize: 18.0, fontFamily: 'Open Sans', color: Colors.white);
// constructor to get text from textfield
  ChatMessage({this.text, this.isUser, this.date});

  @override
  Widget build(BuildContext context) {
    String textDisplay = text;
    bool showSideImage = false;
    String sideImage = "";

    if(isUser==2 && (text.contains("__bot") || text.contains("__human") ) ){
      showSideImage = true;
      if(text.contains("__bot")){
        sideImage = "bot";
        textDisplay = textDisplay.replaceAll("__bot", "");
      }
      else if(text.contains("__human")){
        sideImage = "human";
        textDisplay = textDisplay.replaceAll("__human", "");
      }
      text.trim(); // to trim any spaces
    }

    DateTime theDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    int diff = DateTime(now.year, now.month, now.day).difference(DateTime(theDate.year, theDate.month, theDate.day)).inDays;
    if(isUser==11 || isUser == 3 ||  text.length == 0){
      return Container();
    }
    else if (isUser == 0) {
      return Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
          padding: const EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: Text(text,
              style: Theme.of(context).textTheme.display4),

      );
    } else {
      return Column(children: <Widget>[
        Row(
          children: <Widget>[
            showSideImage == false ? Container() :

            Container(
                width: 40.0,
                height: 40.0,
                margin: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 0),
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage (
                            "assets/" + sideImage +  ".png")
                    )
                )),
            Container(
                constraints: BoxConstraints(
                  maxWidth: min(MediaQuery.of(context).size.width * .8,400.0),
                ),
                margin: isUser == 1
                    ? const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, right: 10.0)
                    : showSideImage? EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0) : EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                decoration: isUser == 1 ? userBox : botBox,
                child: Column(
                      crossAxisAlignment: isUser == 1
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        SelectableText(textDisplay,
                            style: isUser == 1
                                ? Theme.of(context).textTheme.body2
                                : Theme.of(context).textTheme.body2,
                            textAlign:
                                isUser == 1 ? TextAlign.right : TextAlign.left),
                        Text(
                            diff > 0
                                ? DateFormat('dd MMM kk:mm').format(theDate)
                                : DateFormat('kk:mm').format(theDate),
                            style: Theme.of(context).textTheme.caption,
                            textAlign:
                                isUser == 1 ? TextAlign.right : TextAlign.left),
                      ])
            )
          ],
          mainAxisAlignment:
              isUser == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ]);
    }
  }
}

double min(double x,double y){
 if(y<x){
   return y;
 }
 return x;
}
