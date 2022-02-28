import 'package:flutter/material.dart';
import 'dart:convert';

final topicText =
ValueNotifier<String>('{"code":"","topics":{}}'); //TODO 1st: ValueNotifier declaration
//ValueNotifier<String>('{"code":"","topics":{"Disconnect the phone or use an answer machine and turn the ringer down.": "0.49432256870003904","Have a short sleep before your first night shift.": "0.530114438532447","If coming off night shifts, have a short sleep and go to bed earlier that night.": "0.5544228162886776","Once you have identified a suitable sleep schedule try to keep to it.": "0.5652230928541616","Sleep in your bedroom and avoid using it for other activities such as watching television, eating and working.": "0.5400856073634657"}}'); //TODO 1st: ValueNotifier declaration


class MonitorScreen extends StatefulWidget {

  @override
  State createState() => new MonitorScreenState();
}

class MonitorScreenState extends State<MonitorScreen>{


  @override
  Widget build(BuildContext context) {

    //"topics":{" Taking care of your body when you are ill (e.g., attending medical appointments) can help you restore your physical health more quickly [66] ":0.12173476,"
    return Container(
        child:  ValueListenableBuilder(
          valueListenable: topicText,
          builder: (context, value, widget) {
            //TODO here you can setState or whatever you need

      List<Recommendation> topics = new List<Recommendation>();
            if(value.length>40) {
              topics = getRecs(value);
            }


            return Container(
              constraints: BoxConstraints(maxWidth: 750),
              margin: EdgeInsets.symmetric(vertical:10),
                padding: EdgeInsets.symmetric(vertical:10),
                child:Center(

                  child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, i){

                  return  Card(
                    elevation: 2,
                      margin: EdgeInsets.all(10),
                      child: ListTile(

                  contentPadding: EdgeInsets.all(10),
                    title: Text(topics[i].text),
                        leading: Text("${topics[i].score.toStringAsFixed(2)}"),
                  ));
                  },

                  )
                )
            );}
        ),
    );
  }

  List<Recommendation> getRecs(String response) {
    List<Recommendation> recs = new  List<Recommendation>();

    Map<String, dynamic> responseJson = jsonDecode('{"code":"","topics":$response}') as Map<String, dynamic>; // for user modeling
    //Map<String, dynamic> responseJson = jsonDecode(response) as Map<String, dynamic>; // for topic modeling

    //print();

    //Map<String, double> topicData = responseJson['topics'] ;

    responseJson['topics'].forEach((key, value) {
      recs.add(new Recommendation(text: key, score: double.parse(value)) );
    });

    recs.sort((a, b) => b.score.compareTo(a.score));

    return recs;
  }

}

class Recommendation {
  final String text;
  final double score;

// constructor to get text from textfield
  Recommendation(
      {@required this.text, this.score});
}

