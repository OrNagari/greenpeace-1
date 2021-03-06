import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greenpeace/evants/add_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:greenpeace/GetID_DB/getid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greenpeace/evants/update_event.dart';

final databaseReference = Firestore.instance;

class mass_event extends StatefulWidget {
  final String sender;
  final String text;
  final String senderId;
  final String topic;
  final DateTime eventDate;
  final String equipment;
  final String type_event;
  final String location;
  final String whatapp;
  mass_event(
      {this.sender,
      this.text,
      this.whatapp,
      this.senderId,
      this.topic,
      this.equipment,
      this.eventDate,
      this.type_event,
      this.location});
  @override
  _mass_eventState createState() => _mass_eventState();
}

class _mass_eventState extends State<mass_event> {
  FirebaseUser currentUser;
  String idevent;
  void launchMap(String address) async {
    String query = Uri.encodeComponent(address);

    String googleUrl = "https://waze.com/ul?q=$query";

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  }

  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
        // call setState to rebuild the view
        this.currentUser = user;
      });
    });
  }

  String _email() {
    if (currentUser != null) {
      return currentUser.email;
    } else {
      return "no current user";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(30),
        child: ListView(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
              ),
              iconSize: 30,
              color: Colors.grey,
              splashColor: Colors.purple,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            new Align(
              child: new Text(
                "מאת " + widget.sender,
                style: new TextStyle(fontSize: 20),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            Divider(thickness: 1, color: Colors.black),
            new Align(
              child: new Text(
                "נושא " + widget.topic,
                style: new TextStyle(fontSize: 20),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            Divider(thickness: 1, color: Colors.black),
            new Align(
              child: new Text(
                widget.topic,
                style: new TextStyle(fontSize: 30),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                widget.text,
                style: new TextStyle(fontSize: 15),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                "רשימת ציוד",
                style: new TextStyle(fontSize: 30),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                widget.equipment.toString(),
                style: new TextStyle(fontSize: 15),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                "תאריך",
                style: new TextStyle(fontSize: 30),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                widget.eventDate.toString(),
                style: new TextStyle(fontSize: 15),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                "סוג האירוע",
                style: new TextStyle(fontSize: 30),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                widget.type_event,
                style: new TextStyle(fontSize: 15),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: FlatButton(
                onPressed: () {
                  _launchURL(widget.whatapp);
                },
                child: new Text(
                  "הצרפות לקבוצת whatapp",
                  style: new TextStyle(fontSize: 30),
                ),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                widget.whatapp,
                style: new TextStyle(fontSize: 15),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: new Text(
                "מיקום",
                style: new TextStyle(fontSize: 30),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            new Align(
              child: FlatButton(
                color: Colors.white,
                textColor: Colors.green,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  launchMap(widget.location);
                },
                child: Text(
                  widget.location,
                  style: TextStyle(fontSize: 20.0),
                ),
              ), //so big text
              alignment: FractionalOffset.topRight,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      onPressed: () async {
                        String idevent =
                            await Getevent(widget.topic);
                            await databaseReference
                            .collection("events")
                            .document(idevent)
                            .delete();
                        Navigator.pop(context);
                      },
                      child:
                          const Text('הסר', style: TextStyle(fontSize: 20)),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEventPage(
                                      sender: widget.sender,
                                      senderId: widget.senderId,
                                    )));
                      },
                      child: const Text('השב', style: TextStyle(fontSize: 20)),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () async {
                        idevent = await Getevent(widget.topic);
                        databaseReference
                            .collection('events')
                            .document(idevent)
                            .updateData({'approve': true});
                        successshowAlertDialog(context, _email(),
                            currentUser.uid, widget.topic, widget.senderId);
                      },
                      child: const Text('אישור',
                          style: TextStyle(fontSize: 20)),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () async {
                        idevent = await Getevent(widget.topic);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => updateEventPage(
                                      sender: widget.sender,
                                      topic: widget.topic,
                                      text: widget.text,
                                      equipment: widget.equipment,
                                      eventDate: widget.eventDate,
                                      senderId: widget.senderId,
                                      location: widget.location,
                                      type_event: widget.type_event,
                                      dataid: idevent,
                                    )));
                      },
                      child: const Text('עריכה',
                          style: TextStyle(fontSize: 20)),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

successshowAlertDialog(BuildContext context, String email, String currentuserId,
    String name_event, String createby) {
  FirebaseUser currentUser;
  // set up the button
  Widget okButton = FlatButton(
    child: Text("אישור"),
    onPressed: () {
      DocumentReference documentReference =
          Firestore.instance.collection("personalMess").document();
      documentReference.setData({
        "text":
            'אושר על ידי המנהלים והוסף ללוח האירועים' + name_event + 'האירוע',
        "sender": email,
        "time": DateTime.now(),
        "url": "",
        "senderID": currentuserId,
      });

      Firestore.instance.collection("users").document(createby).updateData({
        "personalMessId": FieldValue.arrayUnion([documentReference.documentID])
      });

      Navigator.pop(context, true);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("אירוע עודכן בהצלחה"),
    content: Text("נשלח עידכון ליוצר האירוע"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

_launchURL(String url) async {
  url = '$url';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
