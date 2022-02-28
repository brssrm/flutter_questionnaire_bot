import 'package:dio/adapter_browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webapp/bot/dialogDB.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../monitorScreen.dart';

import 'package:http/io_client.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

class TextEntryDialog extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  TextEntryDialog(this.context,this.controller, this.message);

  @override
  TextEntryDialogWidget createState() => TextEntryDialogWidget();
}


class TextEntryDialogWidget extends State<TextEntryDialog> {

  String currentValue= "";
  String errorText;
  String helperText = "";
  int currentCount = 0;
  TextEditingController _controller  = new TextEditingController();
  bool isNew = true;
  bool loading = false;
  int minLimit = 0;

  bool isFalse(){
    if(currentValue == ""){
      return false;
    }
    return true;
  }


  @override
  void initState() {
    super.initState();
    _controller.addListener(onValueChange);
  }

  //void onValueChange() {currentCount = _controller.text.length;}

  void onValueChange() {
    isNew = false;
    currentValue = _controller.text;
    setState(() {
      currentCount = _controller.text.length;
    });
  }


  // Group Value for Radio Button.
  //List<MultipleChoiceItem> nList = difficultyItems;


  Widget build(BuildContext context) {

    if(isNew) {
      if (widget.message.initVal != null) {
        _controller.text = widget.message.initVal;
      }
      else {
        _controller.text = "";
      }
      errorText = null;
    }

    if(widget.message.data != null && widget.message.data['minLength'] != null) {
      minLimit = widget.message.data['minLength'];
    }

    if(widget.message.data != null && widget.message.data['minLengthDynamic'] != null && widget.message.data['minLengthTotal'] != null) {
      minLimit =  widget.message.data['minLengthTotal'] - getCount(widget.message.data['minLengthDynamic']);
      if (minLimit<0){
        minLimit = 0;
      }
    }

    if( widget.message.data != null && widget.message.data['helperText']!= null) {
      helperText =  widget.message.data['helperText'];

      if(helperText.contains("__minLimit")){
        if(minLimit>0){
          helperText =  helperText.replaceAll("__minLimit", "$minLimit");
        }
        else{
          helperText = "";
        }
      }
    }







    topicInquire() async{
      isNew = true;

      setState(() {
        loading = true;
      });


      screen.enterUserMessage(currentValue,codeM: widget.message.code);
      //await topicModel(_controller.text);

      _controller.text = "";

      String nextPair = getNextPair(widget.message);
      loading = false;
      if (nextPair != null) {
        widget.controller.add(nextPair);
      }
    }


    return  Container(
      alignment: Alignment.center,
            width:  MediaQuery.of(context).size.width * (widget.message.inputType == 'numerical' ? .35 : .8),
            margin: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),

            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),

            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
              Text("   "),
              Flexible(
                  child:Padding(
                      padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
                      child: TextFormField(
                          controller: _controller,
                    key: widget.message.inputType == 'numerical' ? PageStorageKey('textfieldNum') : PageStorageKey('textfield'),
                    decoration: InputDecoration(
                      hintText: helperText,
                      counterText: widget.message.inputType == 'textEntry_long' ? _controller.text.length.toString() : null,
                      errorText:  _controller.text.length < minLimit ? errorText : null,
                        //errorText:  widget.message.inputType == 'textEntry_long' && _controller.text.length < minLimit ? errorText : null,
                      suffixIcon: loading ? CircularProgressIndicator() : IconButton(
                          icon:  _controller.text.length < minLimit ? Icon(Icons.send,color: Colors.black45) : Icon(Icons.send),
                          alignment: Alignment.bottomRight,

                          onPressed: () {

                            bool beSubmitted = true;
                            if(_controller.text.length < minLimit ){
                            beSubmitted=false;
                            }

                            if(beSubmitted){
                              if(widget.message.data != null && widget.message.data['countTowards']!= null){
                                addToCount(currentValue.trim().length, widget.message.data['countTowards']);
                              }

                              if(widget.message.data != null && widget.message.data['topicModel']!= null){
                                topicInquire();
                              }
                              else{
                                isNew = true;

                                screen.enterUserMessage(currentValue,codeM: widget.message.code);
                                _controller.text = "";

                                String nextPair = getNextPair(widget.message);

                                if (nextPair != null) {
                                  widget.controller.add(nextPair);
                                }
                              }
                            }
                            else{
                              setState(() {
                              if(minLimit<=2){
                              errorText = 'Please answer before proceeding to the next question.';
                              }
                              else{
                              errorText = 'Please write at least $minLimit characters.';
                              }

                              });
                            }
                      })
                      //counterText: currentCount.toString(),
                    ),
                    //onChanged: (text) {setState(() {currentCount = text.length;});},
                    //minLines : widget.message.inputType == 'textEntry_long' ? 5 : 1,

                    autofocus: true,
                    keyboardType: widget.message.inputType == 'numerical' ? TextInputType.number : TextInputType.multiline,
                    maxLines: widget.message.inputType == 'textEntry_long' ? 5 : 1,
                    inputFormatters: widget.message.inputType == 'numerical' ? [WhitelistingTextInputFormatter(RegExp("[0-9]")),] : [],
                    style: widget.message.inputType == 'numerical' ? Theme.of(context).textTheme.display2 :Theme.of(context).textTheme.body2,

                        validator: (value) {
                          if (widget.message.inputType == 'textEntry_long' && value.length < minLimit ) {
                            return ('Please write at least $minLimit characters.');
                          }
                          return null;
                        },


                  )
              )),
                  Text("   ")
          ]),

    );

  }
}