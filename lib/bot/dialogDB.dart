import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'dart:convert';


var uuid = Uuid();

class Message {
  String id;
  int isUser;
  String code;
  String date;
  String content;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isUser': isUser,
      'code': code,
      'date': date,
      'content': content,
    };
  }

  Map toJson() {
    return {
      'id': id,
      'isUser': isUser,
      'code': code,
      'date': date,
      'content': content,
    };
  }


  Message.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    isUser = map['isUser'];
    code = map['code'];
    date = map['date'];
    content = map['content'];
  }


  Message(
      {
        this.id,
        this.isUser,
        this.code,
        this.date,
        this.content
      });
}


DataDialog dbDialog = new DataDialog();


class DataDialog {
  List<Message> _messages;

  DataDialog(){
    _messages = new List<Message>();
    if( html.window.localStorage.containsKey('chatHistory')){
      List<String> savedMessages = html.window.localStorage['chatHistory'].split('|');

      savedMessages.forEach((str) {
        try {
          Message m =  Message.fromMap(jsonDecode(str));
          _messages.add(m);
        } on FormatException catch (e) {
          print('The provided string is not valid JSON');
        }
      });
    }
  }


  Future<void> insertEntry(Message entry) async {
    // Get a reference to the database.
    _messages.add(entry);

    if(html.window.localStorage.containsKey('chatHistory')){
      html.window.localStorage['chatHistory'] = html.window.localStorage['chatHistory'] + '|' + jsonEncode(entry.toMap());
    }
    else{
      html.window.localStorage['chatHistory'] = jsonEncode(entry.toMap());
    }
  }

  Future<void> insertSilentEntry(Message entry) async {
    // Get a reference to the database.

    if(html.window.localStorage.containsKey('chatHistory')){
      html.window.localStorage['chatHistory'] = html.window.localStorage['chatHistory'] + '|' + jsonEncode(entry.toMap());
    }
    else{
      html.window.localStorage['chatHistory'] = jsonEncode(entry.toMap());
    }
  }


  Future<Message> getEntry(String id) async {
    // Get a reference to the database.
    return _messages[0];
  }

  String messagesString() {
    String messageString = "";

    _messages.forEach((message){
      messageString = messageString + '|' + jsonEncode(message.toMap);
    });

    return  messageString;
  }


  Future<bool> isEmpty() async {
    // Get a reference to the database.

    return (_messages.length == 0 );
  }


  Future<List<Message>> allEntries() async {
    // Get a reference to the database.
    return _messages;
  }

  Future<void> deleteEntry(String id) async {
    // Get a reference to the database.

  }

  Future<void> deleteAll() async {
    html.window.localStorage.remove("chatHistory");
    _messages.clear();
  }
}

List<String> getList(String key) {
  // Get a reference to the database.

  if(html.window.localStorage.containsKey(key)){
    String stringList = html.window.localStorage[key];
    return stringList.split('|');
  }
  return new List<String>();
}

Future<void> addToList(String entry, String listName) async {
  // Get a reference to the database.

  if(html.window.localStorage.containsKey(listName) && !hasItem(entry,listName)){
    html.window.localStorage[listName] = html.window.localStorage[listName] + '|' + entry;
  }
  else{
    html.window.localStorage[listName] = entry;
  }
}

bool hasItem(String entry, String listName){
  if(html.window.localStorage.containsKey(listName)){
    List<String> theList= html.window.localStorage[listName].split('|');
    if(theList.contains("entry")){
      return true;
    }
  }
  return false;
}

int getCount(String key) {
  if(html.window.localStorage.containsKey(key)){
    return int.parse(html.window.localStorage[key]);
  }
  return -1;
}

Future<void> addToCount(int count, String key) {
  if(html.window.localStorage.containsKey(key)){
    html.window.localStorage[key] = (int.parse(html.window.localStorage[key]) + count).toString();
  }
  else{
    html.window.localStorage[key] = count.toString();
  }
}


List<String> getDifference(List<String> x, List<String> y) {
  List<String> output = [];

  for(final e in x){
    bool found = false;
    for(final f in y) {
      if(e == f) {
        found = true;
        break;
      }
    }
    if(!found){
      output.add(e);
    }
  }
  return output;
}

