import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dialog.dart';
import 'package:flutter/services.dart';
import 'dialogDB.dart';
import 'chatscreen.dart' as screen;

class TaskBlock extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;
  int initValue;

  TaskBlock(this.context, this.controller, this.message);

  @override
  TaskBlockWidget createState() => TaskBlockWidget();
}

class TaskBlockWidget extends State<TaskBlock> {
  String currentLabel = "";
  // Group Value for Radio Button.
  int counter;
  List<Task> tasks;
  bool freshBuild = true;

  Widget build(BuildContext context) {
    final taskList = widget.message.data["tasks"];
    tasks = taskList.map<Task>((jsonData) => Task.fromJson(jsonData)).toList();

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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TaskScreen(context, widget.controller, widget.message),
                ));
          },
        ));
  }
}

class TaskScreen extends StatefulWidget {
  StreamController<String> controller;
  BotMessage message;
  BuildContext context;
  int initValue;

  TaskScreen(this.context, this.controller, this.message);

  @override
  TaskScreenState createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  int counter;
  List<Task> tasks;
  bool freshBuild = true;

  //customizable text
  String indicationText = "You so far got __percent of the questions right.";
  String finalText = "The task is over!";
  String finalButtonLabel = "Back to chat";
  String currentIndicationText;
  String indicatorText = " ";
  Color indicatorColor = Colors.white;
  double indicatorOpacity = 0;

  bool isNew = true;
  TextEditingController _controller = new TextEditingController();
  FocusNode myFocusNode = FocusNode();
  int defaultTaskTime = 10;
  int timeLeft;
  bool taskFinished = false;
  List<bool> answersCorrect;
  Timer _timer;
  double timeLeftRatio;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft - 1 > 0) {
        //what to do when there is still time
        setState(() {
          timeLeft--;
          timeLeftRatio = timeLeft.toDouble() / tasks[counter].time.toDouble();
        });
      } else {
        //what to do when the time runs out
        submitAnswer("expiry");
      }
    });
  }

  void submitAnswer(String answer) {
    screen.enterUserMessageSilent(answer,
        codeM: "task_" + tasks[counter].q_number);
    _controller.clear();

    if (counter == tasks.length - 1) {
      _timer.cancel();
      if (answer == tasks[counter].answer) {
        answersCorrect.add(true);
      } else {
        answersCorrect.add(false);
      }
      setState(() {
        taskFinished = true;
        finalText = finalText.replaceAll("__percent", getRatio());
        indicator(answer, tasks[counter].answer);
      });
    } else {
      setState(() {
        if (answer == tasks[counter].answer) {
          answersCorrect.add(true);
        } else {
          answersCorrect.add(false);
        }
        currentIndicationText =
            indicationText.replaceAll("__percent", getRatio());
        indicator(answer, tasks[counter].answer);

        if (counter < tasks.length - 1) {
          counter++;
          timeLeft = tasks[counter].time;
          timeLeftRatio = timeLeft.toDouble() / tasks[counter].time.toDouble();
        }
      });
    }
  }

  void indicator(String answer, String answerCorrect) {
    if (answer == answerCorrect) {
      indicatorText = "Correct answer!";
      indicatorColor = Colors.green;
    } else if (answer == 'expiry') {
      indicatorText = "Time is up!";
      indicatorColor = Colors.red;
    } else {
      indicatorText = "Wrong answer";
      indicatorColor = Colors.red;
    }

    indicatorOpacity = 1;
    Future.delayed( Duration(seconds: 1), () {
      setState(() {
        indicatorOpacity = 0;
      });
    });
  }

  String getRatio() {
    int countCorrect = 0;
    answersCorrect.forEach((a) {
      if (a) {
        countCorrect++;
      }
    });

    double ratio = countCorrect.toDouble() / answersCorrect.length.toDouble();
    return (ratio * 100).toStringAsFixed(0) + "%";
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Container(
        color: Colors.white,
        child: Row(children: <Widget>[
          ConstrainedBox(
            //width:500,

            constraints: BoxConstraints(
                maxWidth: minN(MediaQuery.of(context).size.width, 900),
                maxHeight: MediaQuery.of(context).size.height),

            child: Scaffold(
              //appBar: AppBar(title: Text("Example", style: TextStyle(fontFamily: 'Raleway',fontWeight: FontWeight.w800)),),
              body: AbsorbPointer(
                  child: Opacity(opacity: 0.5, child: screen.ChatScreen())),
            ),
          ),
          Spacer(flex: 1),
          ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: 500, maxHeight: MediaQuery.of(context).size.height),
              child: Scaffold(
                backgroundColor: Colors.white,

                //appBar: AppBar(title: Text("nooo"),),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: taskFinished
                        // final screen
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Container(
                                  height: 50,
                                  child: Text(finalText,
                                      style:
                                          Theme.of(context).textTheme.display2),
                                  margin: const EdgeInsets.only(
                                      top: 90.0,
                                      bottom: 20.0,
                                      left: 30.0,
                                      right: 30.0),
                                ),
                              AnimatedOpacity(
                                  opacity: indicatorOpacity,
                                  duration: const Duration(milliseconds: 500),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Icon(Icons.timer, color: Colors.white),
                                      Text(indicatorText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .apply(
                                              color: indicatorColor,
                                              fontSizeDelta: 2))
                                    ],
                                  )
                              ),
                                Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      elevation: 2.0,
                                      child: new Text(finalButtonLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .display2
                                              .apply(color: Colors.white)),
                                      color: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.all(16.0),
                                      onPressed: () {
                                        screen.insertSystemMessage(finalText,
                                            codeM: widget.message.code);
                                        String nextPair =
                                            getNextPair(widget.message);
                                        if (nextPair != null) {
                                          widget.controller.add(nextPair);
                                          Navigator.pop(context);
                                        }
                                        counter = 0;
                                        tasks.clear();
                                      },
                                    )),
                              ])

                        // actual task screen
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Container(
                                  height: 50,
                                  child: Text(currentIndicationText,
                                      style:
                                          Theme.of(context).textTheme.display2),
                                  margin: const EdgeInsets.only(
                                      top: 90.0,
                                      bottom: 20.0,
                                      left: 30.0,
                                      right: 30.0),
                                ),
                                AnimatedOpacity(
                                  opacity: indicatorOpacity,
                                  duration: const Duration(milliseconds: 500),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Icon(Icons.timer, color: Colors.white),
                                      Text(indicatorText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .apply(
                                                  color: indicatorColor,
                                                  fontSizeDelta: 2))
                                    ],
                                  )
                                ),
                                Container(
                                  height: 50,
                                  child: Text(tasks[counter].question,
                                      style:
                                          Theme.of(context).textTheme.display1),
                                  margin: const EdgeInsets.only(
                                      top: 90.0,
                                      bottom: 20.0,
                                      left: 30.0,
                                      right: 30.0),
                                ),
                                Container(
                                  height: 140,
                                  width: 50,
                                  child: TextField(
                                      autofocus: true,
                                      focusNode: myFocusNode,
                                      controller: _controller,
                                      key: PageStorageKey('textfieldNum'),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter(
                                            RegExp("[0-9]"))
                                      ],
                                      style:
                                          Theme.of(context).textTheme.display1,
                                      onSubmitted: (String value) {
                                        if (value.length > 0) {
                                          submitAnswer(value);
                                        }
                                        //_controller.clear();
                                        //FocusScope.of(context).previousFocus();
                                        myFocusNode.requestFocus();
                                      }),
                                ),
                                Spacer(flex: 1),
                                Container(
                                  child: Text(timeLeft.toString(),
                                      style:
                                          Theme.of(context).textTheme.display1),
                                  padding: const EdgeInsets.all(16),
                                ),
                                LinearProgressIndicator(
                                  minHeight: 20,
                                  backgroundColor: Colors.grey,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Color.lerp(Color(0xffff0000),
                                          Color(0xff00ff00), timeLeftRatio)),
                                  value: timeLeftRatio,
                                ),
                              ]),
                  ),
                ),
              )),
          Spacer(flex: 1),
        ]));
  }

  double minN(a, b) {
    if (a > b) {
      return b;
    }
    return a;
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController();
    final taskList = widget.message.data["tasks"];
    tasks = taskList.map<Task>((jsonData) => Task.fromJson(jsonData)).toList();
    answersCorrect = new List<bool>();
    timeLeftRatio = 1.0;

    //check for the taskTime
    if (widget.message.data != null &&
        widget.message.data['taskTime'] != null) {
      defaultTaskTime = widget.message.data['taskTime'];
    }

    //apply the default taskTime to tasks with no hard-coded time
    tasks.forEach((t) {
      if (t.time == null) {
        t.time = defaultTaskTime;
      }
    });

    //get the indication Text
    if (widget.message.data != null &&
        widget.message.data['indicationText'] != null) {
      indicationText = widget.message.data['indicationText'];
    }

    //reset current indication text
    currentIndicationText = "  ";

    //get the final Text
    if (widget.message.data != null &&
        widget.message.data['finalText'] != null) {
      finalText = widget.message.data['finalText'];
    }

    //get the final button label
    if (widget.message.data != null &&
        widget.message.data['finalButtonLabel'] != null) {
      finalButtonLabel = widget.message.data['finalButtonLabel'];
    }

    indicatorText = " ";
    indicatorColor = Colors.white;
    indicatorOpacity = 0;
    freshBuild = true;
    counter = 0;
    timeLeft = defaultTaskTime;
    taskFinished = false;
    startTimer();
  }
}

class Task {
  final String q_number;
  final String question;
  final String answer;
  int time;

// constructor to get text from textfield
  Task({@required this.q_number, this.question, this.answer});

  factory Task.fromJson(Map<String, dynamic> jsonData) {
    Task _task = Task(
        q_number: jsonData['q_number'] as String,
        question: jsonData['question'] as String,
        answer: jsonData['answer'] as String);

    if (jsonData['time'] != null) {
      _task.time = jsonData['time'];
    }

    return _task;
  }
}
