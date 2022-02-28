import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chatmessage.dart';
import 'dialogDB.dart';
import 'dialog.dart';
import 'dart:async';
import '../monitorScreen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:html' as html;
import 'dart:math';
import 'typingIndicator.dart';
import 'uploadButton.dart';

String dialogName = "";
String firebaseUploadFolderName = "explanation_pilot2";
String defaultStorageBucket = 'gs://web-study-f0ab8.appspot.com';
int typingSimulatorSpeed = 90;
String modelBackend = "";

class ChatScreen extends StatefulWidget {

  @override
  State createState() => new ChatScreenState();
}




class ChatScreenState extends State<ChatScreen>{

  final TextEditingController _chatController = new TextEditingController();
  List<Message> _messages = new  List<Message>();
  Widget _inputWidget;
  Widget _typingIndicator;
  bool typingIndicatorVisibility = false;
  bool inputWidgetVisibility = true;
  Stream _stream;
  StreamSubscription _subscription;
  StreamController<String> _dialogEvents = new StreamController<String>();


 void botAction(BotMessage message){

   //if(!message.text.contains("focused")){
   if(message.text.contains("__human")){
     setState(() {
       inputWidgetVisibility = false;
       typingIndicatorVisibility = true;
     });

     int typingDuration = message.text.length~/typingSimulatorSpeed + 1;

     Future.delayed( Duration(seconds: typingDuration), () {
       setState(() {
         inputWidgetVisibility = true;
         typingIndicatorVisibility = false;
         if(message.text.length>-1){
           dbDialog.insertEntry(Message(id: uuid.v1(), isUser: 2, code: message.code, date: DateTime.now().toString(), content: message.text));
         }
         _inputWidget = inputWidget(message,context,_dialogEvents);
       });
     });
   }
   else{
     setState(() {
       if(message.text.length>-1){
         dbDialog.insertEntry(Message(id: uuid.v1(), isUser: 2, code: message.code, date: DateTime.now().toString(), content: message.text));
       }
       _inputWidget = inputWidget(message,context,_dialogEvents);
     });
   }
  }

  Widget getActualInputWidget(){

   for(int i=_messages.length-1; i>=0; i--){
     if(_messages[i].isUser==2){
       BotMessage theMessage = getMessage(_messages[i].code);
       return inputWidget(theMessage,context,_dialogEvents);
     }
   }
   return Container();
  }

  Widget returnTypingIndicator(){
   return Visibility(
       visible: typingIndicatorVisibility,
       child: Align(
           alignment: Alignment.topLeft,

       child:  Container(
         padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
         margin: const EdgeInsets.only(left: 50),
         height: 60,
         width: 100,
         child: new JumpingDots(numberOfDots: 4),
         //Text("typing...",style: Theme.of(context).textTheme.display2,),
         //CircularProgressIndicator(strokeWidth: 5),

       /*Container(
           height: 50.00,
           width: 100,
           decoration: new BoxDecoration(
             image: new DecorationImage(
             image: ExactAssetImage('assets/typing-animation.gif'),
               fit: BoxFit.fitHeight,
           ),
       )
       ),*/

    )))
   ;
  }


  @override
  Widget build(BuildContext context) {
    //tryEncryption();

    return FutureBuilder<List<Message>>(
      future: _loadAsset(),
      builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
        if (snapshot.hasData) {
          //print(snapshot.data);
          _messages = _generateEntries(snapshot.data);
          _inputWidget = getActualInputWidget();
          _typingIndicator = returnTypingIndicator();
          List<Widget> list = List.generate(_messages.length, (index) => buildEntry(_messages[index]));

          List<String> countedStrings = getCountedStrings(_messages);

          return Container(
              margin: EdgeInsets.only(bottom:5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                //mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  /*
                Container(
                  color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
                    child: Row(children: <Widget>[

                      Expanded(child :Text("${getTotalLength(countedStrings)}/600 characters",style: Theme.of(context).textTheme.display4)),
                      Expanded(child :Text("${countedStrings.length}/8 answers",style: Theme.of(context).textTheme.display4)),
                    ],)),
                  */
                  Flexible( child: ListView(reverse: true, children: list.reversed.toList())),
                  Container(child: Visibility( visible: inputWidgetVisibility,child:_inputWidget)),
                  Container(child:_typingIndicator),
                ],
              ));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  List<String> getCountedStrings(List<Message> _messages){
   List<String> stringList = [];
   //List<String> countedList = getCountedCodes();
   _messages.forEach((element) {
     if(element.isUser == 1 && countedList.contains(element.code) ){
       stringList.add(element.content);
     }
   });
   return stringList;
  }

  int getTotalLength(List<String> _list){
   int lengthT = 0;
   _list.forEach((element) {
     lengthT += element.length;
   });

   return lengthT;
  }

  List<String> getCountedCodes(){
    List<String> stringList = [];
    botMessages.forEach((element) {
      if(element.data != null && element.data['countTowards'] != null && element.data['countTowards'] == true ){
        stringList.add(element.code);
      }
    });
    return stringList;
  }

  Future<void> sayHello() async{
    //final response = await http.get('https://jsonplaceholder.typicode.com/albums/1');
    //if (response.statusCode == 200) {print(response.body);}

    bool isDialogEmpty = await dbDialog.isEmpty();
    if(isDialogEmpty){
      _dialogEvents.add(dialogOrder[0]);
    }
  }

  Future<List<Message>> _loadAsset() async {
    await fetchDialog();
    return await dbDialog.allEntries();
  }

  List<Message> _generateEntries(data) {
    var entries = new List<Message>();
    data.forEach((t) {entries.add(t);});
    return entries;
  }

  Widget buildEntry(Message entry) {
    return ChatMessage(isUser: entry.isUser, text: entry.content, date: entry.date);
  }

  Future<void> assignCondition() async{
    if(!html.window.localStorage.containsKey('condition')){
      Random random = new Random();
      int randomNumber = random.nextInt(100);

      if(randomNumber<50){
        html.window.localStorage['condition'] = "dialogExp1.json";
      }
    else{
      html.window.localStorage['condition'] = "dialogExp2.json";
    }
    }
    html.window.localStorage['screenSize'] = "${MediaQuery.of(context).size.width.toStringAsFixed(0)}x${MediaQuery.of(context).size.height.toStringAsFixed(0)}";
    dialogName = html.window.localStorage['condition'];
  }


  Future<void> fetchDialog() async{

    await assignCondition();

    //final response = await http.get('http://coadaptive.eu/chat/assets/assets/dialog.json');
    var response = await http.get(dialogName);


    if (response.statusCode != 200) {
      response = await http.get(dialogName);
    }

    Map<String, dynamic> dialogData = jsonDecode(response.body) as Map<
        String,
        dynamic>;

    //get the dialog order
    dialogOrder = List.from(dialogData['defaultOrder']);

    //get the typing speed
    if(dialogData.containsKey("typingSimulatorSpeed_CharactersPerSecond")){
      typingSimulatorSpeed = dialogData["typingSimulatorSpeed_CharactersPerSecond"];
    }

    //get the upload folder address
    if(dialogData.containsKey("firebaseUploadFolderName")){
      firebaseUploadFolderName = dialogData["firebaseUploadFolderName"];
    }
    if(dialogData.containsKey("firebaseStorageBucket")){
      defaultStorageBucket = dialogData["firebaseStorageBucket"];
    }




    final pairs = dialogData['pairs'];
    botMessages =
        pairs.map<BotMessage>((jsonData) => BotMessage.fromJson(jsonData)).toList();
    countedList = getCountedCodes();

    //printPairNames(pairs);


    sayHello();
    //_dialogEvents.add(dialogOrder[0]);
  }

  void printPairNames(final pairs){
    String pairNames = "[";
    pairs.forEach((pair) {
      pairNames = pairNames + "\"" + pair["code"] +"\", ";
    });

    pairNames = pairNames + "]";
    print(pairNames);

  }


  @override
  void initState() {
    super.initState();

    //createButtonMessages();
    //dbDialog.deleteAll();

    _stream = _dialogEvents.stream.asBroadcastStream();
    _subscription = _stream.listen((code) {
      BotMessage message = getMessage(code);
      botAction(message);
    }, onError: (error) {
      print("Some Error");
    });

    //sayHello();
    //userModel();

  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

void insertSystemMessage(String message,{String codeM = ""}){
  dbDialog.insertEntry(Message(id: uuid.v1(), isUser: 0, code: codeM, date: DateTime.now().toString(), content: message));
}

void enterUserMessage(String textContent,{String codeM = ""}){


  dbDialog.insertEntry(Message(id: uuid.v1(), isUser: 1, code: codeM, date: DateTime.now().toString(), content: textContent));

  if(modelParams.contains(codeM)){
    updateRecs(codeM);
  }

}

void updateRecs(String codeM) async{
  Map<String,dynamic> params = {
    "code": "questionCode",
    "content": "",
    "participantID": "123456123456123456123456",
    "responseTime": 5897,
    //"gender": "Male",
    //"workHours": 42,
    //"control": "A fair amount",
    //"description_Problems": "I've always been a bad sleeper. Used to wake up lots of times at night and would wake up in the morning feeling tired and not rested. It improved after my early 20's and after I left University. Curiosly, ever since I joined the Police Force and started doing shifts, even though I hate them and feel how prejudicial they are, I've been sleeping better when im off shift.",
    //"satisfaction_General": "Entirely dissatisfied",
    //"satisfaction_Sleep": "Dissatisfied",
    //"satisfaction_SleepEnvironment": "Very suitable",
    //"satisfaction_Diet": "Very suitable",
    //"satisfaction_Exercise": "Very suitable"
  };

  List<Message> allMessages = await dbDialog.allEntries();
  allMessages.forEach((msg) {
    //print(msg.code);
    if(msg.isUser == 1 && modelParams.contains(msg.code)){
      if(msg.code=="workHours"){
        params.addAll({msg.code:int.parse(msg.content)});
      }
      else{
        params.addAll({msg.code:msg.content});
      }

    }
  });



  //new Map<String,dynamic>();

  userModel(params);
}

void userModel(Map<String,dynamic> params) async {
  final http.Response response = await http.post(
    modelBackend, // model backend is the https address
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(params),
  );
  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    //return Album.fromJson(jsonDecode(response.body));
    print(response.body);
    if(response.body.toString().length > 20){
      topicText.value = response.body.toString();
    }

  }
  else if (response.statusCode == 200) {
    print(response.body);
    if(response.body.toString().length > 20){
      topicText.value = response.body.toString();
    }
  }
  else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    print(response.body);
    if(response.body.toString().length > 20){
      topicText.value = response.body.toString();
    }
    //throw Exception('Failed to load album');
  }
}

Future<void> userModel2() async {

  HttpClient client = new HttpClient();

  Map map = {
    "code": "questionCode",
    "content": "",
    "participantID": "123456123456123456123456",
    "responseTime": 5897,
    "gender": "Male",
    "workHours": 42,
    "control": "A fair amount",
    "description_Problems": "I've always been a bad sleeper. Used to wake up lots of times at night and would wake up in the morning feeling tired and not rested. It improved after my early 20's and after I left University. Curiosly, ever since I joined the Police Force and started doing shifts, even though I hate them and feel how prejudicial they are, I've been sleeping better when im off shift.",
    "satisfaction_General": "Entirely dissatisfied",
    "satisfaction_Sleep": "Dissatisfied",
    "satisfaction_SleepEnvironment": "Very suitable",
    "satisfaction_Diet": "Very suitable",
    "satisfaction_Exercise": "Very suitable"
  };

  HttpClientRequest request = await client.postUrl(Uri.parse('https://coadaptive.eu/ca_api.php'));

  request.headers.set('content-type', 'application/json');

  request.add(utf8.encode(json.encode(map)));

  HttpClientResponse response = await request.close();

  String reply = await response.transform(utf8.decoder).join();

  if(reply.length > 20){
    topicText.value = reply;
  }
  print(reply);
}

void enterUserMessageSilent(String textContent,{String codeM = ""}){
  dbDialog.insertSilentEntry(Message(id: uuid.v1(), isUser: 11, code: codeM, date: DateTime.now().toString(), content: textContent));
}
void enterSystemMessageSilent(String textContent,{String codeM = ""}){
  dbDialog.insertSilentEntry(Message(id: uuid.v1(), isUser: 3, code: codeM, date: DateTime.now().toString(), content: textContent));
}

List<String> modelParams = [
  "gender",
  "workHours",
  "control",
  "description_Problems",
  "satisfaction_General",
  "satisfaction_Sleep",
  "satisfaction_SleepEnvironment",
  "satisfaction_Diet",
  "satisfaction_Exercise"
];

/*
Future<void> fetchDialog() async{

  //final response = await http.get('http://coadaptive.eu/chat/assets/assets/dialog.json');
  final response = await http.get('assets/dialog.json');

  //if (response.statusCode == 200) {
  Map<String, dynamic> dialogData = jsonDecode(response.body) as  Map<String, dynamic>;
  dialogOrder = List.from(dialogData['defaultOrder']);
  final pairs = dialogData['pairs'];
  botMessages = pairs.map<BotMessage>((json) => BotMessage.fromJson(json)).toList();

}*/


Map<String, String> recs = {
  'sl01': "Have a short nap before your first night shift.",
  'sl02': "If coming off night shifts, have a short sleep and go to bed earlier that night.",
  'sl03': "Once you have identified a suitable sleep schedule, try to keep to it.",
  'sl04': "Sleep in your bedroom and avoid using it for other activities such as watching television, eating and working.",
  'sl05': "Use heavy curtains, blackout blinds or eye shades to darken the bedroom.",
  'sl06': "Disconnect the phone or use an answer machine and turn the ringer down.",
  'sl07': "Ask your family not to disturb you and to keep the noise down when you are sleeping.",
  'sl08': "If it is too noisy to sleep consider using earplugs, white noise or background music to mask external noises.",
  'sl09': "Adjust the bedroom temperature to a comfortable level; cool conditions improve sleep.",
  'sl10': "To help you fall asleep, avoid the use of alcohol or caffeine before going to bed.",
  'sl11': "Avoid the regular use of sleeping pills and other sedatives to aid sleep if not recommended by a physician. They can lead to dependency and addiction.",
  'sl12': "Go for a short walk, relax with a book, listen to music and/or take a hot bath before going to bed.",
  'sl13': "Avoid vigorous exercise 2-4 hours before sleep as it is stimulating and raises the body temperature.",
  'sl14': "Don’t go to bed feeling hungry: have a light meal or snack but avoid fatty, spicy or heavy meals that are hard to digest.",
  'sl15': "Plan your domestic duties around your shift schedule. Do not complete them at the cost of your rest/sleep.",
  'al01': "To stay alert at work, get up and walk around during breaks.",
  'al02': "To stay alert at work, plan to do more stimulating work at the times you feel most drowsy.",
  'al03': "Keep in contact with co-workers as this may help you and them stay alert.",
  'al04': "Avoid driving for long periods or a long distance after a period of night shifts or long working hours.",
  'al05': "Consider using public transport or sharing a lift with a co-worker and take it in turns to drive.",
  'so01': "Talk to friends and family about shiftwork. If they understand the problems you are facing it will be easier for them to be supportive and considerate.",
  'so02': "Make your family and friends aware of your shift schedule so they can include you when planning social activities.",
  'so03': "Make the most of your time off and plan mealtimes, weekends and evenings together with friends and family.",
  'so04': "Invite others who work similar shifts to join you in social activities."
};

/*
Map<String, String> recs = {
  'sl01': "Have a short nap before your first night shift.",
  'sl02': "If coming off night shifts, have a short sleep and go to bed earlier that night.",
  'sl03': "Once you have identified a suitable sleep schedule, try to keep to it.",
  'sl04': "Sleep in your bedroom and avoid using it for other activities such as watching television, eating and working.",
  'sl05': "Use heavy curtains, blackout blinds or eye shades to darken the bedroom.",
  'sl06': "Disconnect the phone or use an answer machine and turn the ringer down.",
  'sl07': "Ask your family not to disturb you and to keep the noise down when you are sleeping.",
  'sl08': "If it is too noisy to sleep consider using earplugs, white noise or background music to mask external noises.",
  'sl09': "Adjust the bedroom temperature to a comfortable level, cool conditions improve sleep.",
  'sl10': "To help you fall asleep, avoid the use of alcohol or caffeine before going to bed.",
  'sl11': "Avoid the regular use of sleeping pills and other sedatives to aid sleep  if not recommended by a physician. They can lead to dependency and addiction.",
  'sl12': "Go for a short walk, relax with a book, listen to music and/or take a hot bath before going to bed.",
  'sl13': "Avoid vigorous exercise 2-4 hours before sleep as it is stimulating and raises the body temperature.",
  'sl14': "Don’t go to bed feeling hungry: have a light meal or snack before sleeping but avoid fatty, spicy and/or heavy meals, as these are more difficult to digest and can disturb sleep.",
  'sl15': "Plan your domestic duties around your shift schedule and try to ensure that you do not complete them at the cost of rest/sleep.",
  'al01': "Take moderate exercise before starting work which may increase your alertness during the shift.",
  'al02': "Keep the light bright at work to increase your alertness.",
  'al03': "To stay alert at work, get up and walk around during breaks.",
  'al04': "To stay alert at work, plan to do more stimulating work at the times you feel most drowsy.",
  'al05': "Keep in contact with co-workers as this may help both you and them stay alert.",
  'al06': "Avoid driving for long periods or a long distance after a period of night shifts or long working hours.",
  'al07': "Consider using public transport or sharing a lift with a co-worker and take it in turns to drive.",
  'so01': "Talk to friends and family about shiftwork. If they understand the problems you are facing it will be easier for them to be supportive and considerate.",
  'so02': "Make your family and friends aware of your shift schedule so they can include you when planning social activities.",
  'so03': "Make the most of your time off and plan mealtimes, weekends and evenings together with friends and family.",
  'so04': "Invite others who work similar shifts to join you in social activities."
};
 */

List<String> getRecs(String code, {bool shuffle = false, int maxLimit = 9999}){
  List<String> recList = new List<String>();
  recs.forEach((key, value) {
    if(code == "all" || key.substring(0,2)==code){
      recList.add(key);
    }
  });
  if(shuffle){
    recList.shuffle();
  }
  
  if(maxLimit<recList.length){
    recList = recList.sublist(0,maxLimit);
  }
  
  return recList;
}






