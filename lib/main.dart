import 'package:flutter/material.dart';
import 'package:webapp/bot/dialog.dart';
import 'monitorScreen.dart';
import 'bot/chatscreen.dart';
import 'package:firebase/firebase.dart' as fb;
import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:http/http.dart' show IOClient;
import 'dart:async';
import 'dart:io';
import 'bot/dialogDB.dart';
import 'bot/uploadButton.dart';

Color mainColor = Color.fromRGBO(0, 26, 77, 1);

/*
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}*/


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        // Define the default brightness and colors.

        //primarySwatch: Colors.blue,
        primaryColor: mainColor,
        accentColor: mainColor,
        canvasColor: Color.fromRGBO(235, 231, 230,1), // Colors.blueGrey[50],

        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          //headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              color: mainColor),
          display2: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              color: mainColor),
          display3: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              color: Colors.grey[600]),
          display4: TextStyle(
              fontSize: 14.0,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              color: mainColor),
          caption: TextStyle(
              fontSize: 12.0,
              height: 1.8,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w800,
              color: Colors.grey[600]),
          body1: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w500, color: mainColor, height: 1.65),
          body2: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w500, color: mainColor, height: 1.65),
          subhead: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              //fontFamily: 'Open Sans',
              color: mainColor), //slider
          display1: TextStyle(
              fontSize: 30,
              color: mainColor,
              fontWeight: FontWeight.w800,
              fontFamily: 'Raleway'),

        ),
      ),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _menuformKey = GlobalKey<FormState>();
  String menuTextFieldValue;

  @override
  void initState(){
    super.initState();
    menuTextFieldValue = "";
    //HttpOverrides.global = new MyHttpOverrides();
    checkProfileId();
  }


  Future<void> checkProfileId() async{
    if(!html.window.localStorage.containsKey('participantID')){
      final _formKey = GlobalKey<FormState>();
      final TextEditingController _controller = new TextEditingController();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => new AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(child: Container(
                    width: 80.0,
                    height: 80.0,
                    margin: EdgeInsets.all(30),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(45)),),
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0, top: 20.0),
                    child: Image.asset(
                      'assets/botLight.png',
                      fit: BoxFit.contain,
                    ),
                  )),
                  Text("Welcome, to our study! Please enter your 24 digit ID to proceed.", style: Theme.of(context).textTheme.body1),
                  TextFormField(
                    maxLength: 24,
                    // The validator receives the text that the user has entered.
                    controller: _controller,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your ID';
                      }else if (value.length !=24 ) {
                        return 'Ensure that there are 24 characters';
                      }
                      return null;
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
                    ],
                    onFieldSubmitted: (value){
                      if (_formKey.currentState.validate()) {
                        html.window.localStorage['participantID'] = _controller.text;
                        Navigator.of(context).pop();
                      }
                    },

                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FlatButton(
                          child: new Text("Paste",  style: Theme.of(context).textTheme.display2.apply(color:Colors.white)),
                          color: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          onPressed: () {
                            setClipboardText(_controller);
                          },
                        ),
                      ),
                      Spacer(),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: FlatButton(
                            child: new Text("Enter",  style: Theme.of(context).textTheme.display2.apply(color:Colors.white)),
                            color: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.all(8.0),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                html.window.localStorage['participantID'] = _controller.text;
                                Navigator.of(context).pop();
                              }
                            },
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
    }

  }

  Future<void> setClipboardText(TextEditingController _controller) async{
    ClipboardData data = await Clipboard.getData('text/plain');
    _controller.text =data.text;
  }

  double minN(a,b){
    if(a>b){
      return b;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {

    /*
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w800)),),
      body: ChatScreen(),
    );
    */

    return Container (
        decoration:  BoxDecoration(color: Colors.grey[50]),
        child: Row(
          children: <Widget>[
        Spacer(flex: 1),
      ConstrainedBox(
          //width:500,
        constraints: BoxConstraints(maxWidth: minN(MediaQuery.of(context).size.width,700), maxHeight: MediaQuery.of(context).size.height),

              child: Scaffold(
              //  appBar: AppBar(title: Text(widget.title, style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w800)), actions: menuButton(context)),
                body: ChatScreen(),
              ),
            ),
            Spacer(flex: 1, ),
            //child: MonitorScreen(),
          ],
        ));


    /*
    return Container (
        decoration:  BoxDecoration(color: Colors.grey[50]),
        child: Row(
          children: <Widget>[
        Spacer(flex: 1),
        SizedBox(
          width:500,
              child: Scaffold(
                //appBar: AppBar(title: Text(widget.title, style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w800)),),
                body: ChatScreen(),
              ),
            ),
            Spacer(flex: 1, ),
            Expanded(
                flex: 10,
              child: Scaffold(
                appBar: AppBar(title: Text("Console view (Recommendation ranking)", style: Theme.of(context).textTheme.display2), backgroundColor: Colors.grey[50],elevation: 00,),
            backgroundColor: Colors.grey[50],
            body:MonitorScreen(),
              )
            ),
            Spacer(flex: 1)
            //child: MonitorScreen(),
          ],
        ));
      */
  }

  List <Widget> menuButton(BuildContext context){
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Open menu',
        onPressed: (){
          showDialog(
            context: context,
            child: new AlertDialog(
              title: const Text('Experiment controls'),
              content: SingleChildScrollView(

                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        Divider(
                          height: 5,
                          thickness: 2,
                          //indent: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                      child: Row(children: <Widget>[
                  Expanded(child: RawMaterialButton(
                      padding: EdgeInsets.all(5.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0)),
                      fillColor: Theme.of(context).primaryColor,
                      child: Text('Upload the session data',style: Theme.of(context)
                          .textTheme
                          .display2
                          .apply(color: Colors.white)),
                      onPressed: () {
                        myUploadTask(firebaseUploadFolderName);
                      }
                  ),
                  )])),
                        Divider(
                          height: 40,
                          thickness: 2,
                          indent: 20,
                          color: Colors.white,
                        ),
                  Text('Reset the session'),
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(10.0),
                      decoration: new BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
          borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                      child:

                  Row(children: <Widget>[
                    Expanded(child:
                    TextField(
                      key: _menuformKey,
                      style: Theme.of(context).textTheme.display2,
                      onChanged: (value){
                        menuTextFieldValue = value;
          },
                    )),
                    RawMaterialButton(
                      padding: EdgeInsets.all(5.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(8.0)),
                        fillColor: Theme.of(context).primaryColor,
                      child: Text('Reset',style: Theme.of(context)
                          .textTheme
                          .display2
                          .apply(color: Colors.white)),
                      onPressed: () {
                        if (menuTextFieldValue.substring(0,6) == 'dialog') {
                          html.window.localStorage['condition'] = menuTextFieldValue + ".json";
                          dbDialog.deleteAll();
                          html.window.location.reload();
                        }
                      }
                    ),
                  ],)),

                        ]
                  ))

            )
          );
        },
      )
    ];
    }
}

Future<bool> _exitApp(BuildContext context) {
  return showDialog(
    context: context,
    child: new AlertDialog(
      title: new Text('Do you want to exit the study?'),
      content: new Text('Your answers will be deleted'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: new Text('No'),
        ),
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: new Text('Yes'),
        ),
      ],
    ),
  ) ??
      false;
}
