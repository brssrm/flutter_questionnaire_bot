import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dialog.dart';
import 'chatscreen.dart' as screen;
import 'package:firebase/firebase.dart' as fb;
import 'dart:html' as html;
import 'package:encrypt/encrypt.dart' as encrypt;




class UploadButton extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;

  UploadButton(this.context,this.controller, this.message);

  @override
  UploadButtonState createState() => UploadButtonState();
}


class UploadButtonState extends State<UploadButton> {

  String currentLabel = "";
  // Group Value for Radio Button.
  int currentId;
  //List<MultipleChoiceItem> nList = difficultyItems;
  List<String> nList;
  String uploadNotification = "";
  fb.UploadTaskSnapshot _task;
  fb.UploadTask _taskActual;

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal:10, vertical: 10),
            child: Text(uploadNotification,
                style: Theme.of(context).textTheme.display4 )),
        Container(
            margin: EdgeInsets.symmetric(horizontal:10),
            alignment: Alignment.centerRight,
            child: RaisedButton(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
              child: new Text("Upload", style: Theme.of(context).textTheme.display2.apply(color: Colors.white)),
              color: (_task==null || (_task.state == fb.TaskState.CANCELED || _task.state == fb.TaskState.ERROR ) )  ? Theme.of(context).primaryColor : Colors.grey[400],
              padding: const EdgeInsets.all(16.0),
              onPressed: () async {
                if(_task==null || (_task.state == fb.TaskState.CANCELED || _task.state == fb.TaskState.ERROR) ) {
                  _taskActual = await myUploadTask( widget.message.data['uploadFolder']);
                  _task = _taskActual.snapshot;
                  //setState(() {uploadNotification = "Uploading your session data.";});

                  screen.enterUserMessage("Upload", codeM: widget.message.code);

                  String nextPair = getNextPair(widget.message);

                  if (nextPair != null) {
                    widget.controller.add(nextPair);
                  }

                  /*
                  _taskActual.onStateChanged.listen((event) {
                    if(event.state == fb.TaskState.SUCCESS){
                      screen.insertSystemMessage(
                          "Your session data is uploaded.", codeM: widget.message.code);
                      String nextPair = getNextPair(widget.message);

                      if (nextPair != null) {
                        widget.controller.add(nextPair);
                      }
                    }
                  });

                   */

                }
              },
            ))
      ],
    );

  }
}

Future<fb.UploadTask> myUploadTask(String folderName) async{

  String participantID = "";
  if(html.window.localStorage.containsKey('participantID') ){
    participantID = html.window.localStorage['participantID'];
  }
  String fileName = "${participantID}_${DateTime.now().millisecondsSinceEpoch}";
  var message = html.window.localStorage['chatHistory'].replaceAll('\|', '\n');
  var encryptedMessage = encryptMessage(message);
  //storageRef.putString(message, 'base64');

  fb.UploadTask _uploadTask = fb
      .storage()
      .refFromURL(screen.defaultStorageBucket)
      .child('$folderName/$fileName.txt')
      .putString(message);

  return _uploadTask;
}

String encryptMessage(String message){
  //final key = encrypt.Key.fromUtf8('874DC068A65CFA8003120C4AF45BBE82');
  final key = encrypt.Key.fromBase16('536089142e6e677fd7447195f7c69a3c5ce7df833a27569a2f6c747e3e076676');
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

  final encrypted = encrypter.encrypt(message, iv: iv);
  return encrypted.base64;
}

void tryEncryption(){
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';

  final key = encrypt.Key.fromBase16('536089142e6e677fd7447195f7c69a3c5ce7df833a27569a2f6c747e3e076676');


  final iv = encrypt.IV.fromLength(16);
  //fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

  //encrypt.Encrypted already = encrypt.Encrypted.from64();

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  //print(encrypted.base64);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);



  //final decrypted = encrypter.decrypt(encrypted, iv: iv);

  //print(decrypted);
  //print(encrypted.base64);

}