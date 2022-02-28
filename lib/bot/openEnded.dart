import 'package:flutter/material.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;

class OpenEnded extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  OpenEnded(this.context,this.controller, this.message);

  @override
  OpenEndedState createState() => OpenEndedState();
}


class OpenEndedState extends State<OpenEnded> {

  String currentValue= "";

  // Group Value for Radio Button.
  //List<MultipleChoiceItem> nList = difficultyItems;


  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal:10),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
                child: new Text("Write", style: Theme.of(context).textTheme.display2.apply(color: Colors.white)),
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(8.0),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Please give feedback."),
                        content: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new TextField(
                                key: PageStorageKey('textfield'),
                                decoration: InputDecoration(
                                  //helperText: 'Use the keyboard or the speech entry of your device',
                                ),
                                onChanged: (text) {currentValue = text;},
                                autofocus: true,
                                keyboardType: TextInputType.multiline,
                                style: Theme.of(context).textTheme.body2,
                                maxLines: 10,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Row(children: <Widget>[Icon(Icons.clear, color: Theme.of(context).primaryColor), Text('Cancel', style: Theme.of(context).textTheme.display2)]),
                            //Icon(Icons.cancel),
                            //child: Text('Cancel', style: Theme.of(context).textTheme.display2),
                            onPressed: () {
                              Navigator.of(context).pop(null);
                            },
                          ),
                          FlatButton(
                            child: Row(children: <Widget>[Icon(Icons.check, color: Theme.of(context).primaryColor), Text('Enter', style: Theme.of(context).textTheme.display2)]),
                            //child: Text('Enter', style: Theme.of(context).textTheme.display2),
                            onPressed: () {
                              Navigator.of(context).pop();
                              screen.enterUserMessage(currentValue,codeM: widget.message.code);
                              if (widget.message.codeN != null) {
                                widget.controller.add(widget.message.codeN);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Text("  "),
              RaisedButton(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
                child: new Text("Skip", style: Theme.of(context).textTheme.display2.apply(color: Colors.white)),
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(8.0),
                onPressed: () {
                  String nextPair = getNextPair(widget.message);
                  if (nextPair != null) {
                    widget.controller.add(nextPair);
                  }
                },
              )
    ]));


  }
}