import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenpeace/streem_firestore/StruggleStream.dart';
import 'event_model.dart';
import 'package:flutter/material.dart';
import 'event_firestore_service.dart';

class AddEventPage extends StatefulWidget {
  final EventModel note;

  const AddEventPage({Key key, this.note}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _title;
  TextEditingController _description;
  Data data=Data(
    dropdownValue:'',
  );
  DateTime _eventDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note != null ? widget.note.title : "");
    _description = TextEditingController(text:  widget.note != null ? widget.note.description : "");
    _eventDate = DateTime.now();
    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? "Edit Note" : "Add note"),
      ),
      key: _key,
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _title,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter title" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Title",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter description" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TruggleStream(page_call:'add_event',data: this.data),
                ),

              const SizedBox(height: 10.0),
              ListTile(
                title: Text("Date (YYYY-MM-DD)"),
                subtitle: Text("${_eventDate.year} - ${_eventDate.month} - ${_eventDate.day}"),
                onTap: ()async{
                 print(this.data.dropdownValue);
                  DateTime picked = await showDatePicker(context: context, initialDate: _eventDate, firstDate: DateTime(_eventDate.year-5), lastDate: DateTime(_eventDate.year+5));
                  if(picked != null) {
                    setState(() {
                      _eventDate = picked;
                    });
                  }
                },
              ),

              SizedBox(height: 10.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: MaterialButton(
                    onPressed: () async {

                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });
                        if(widget.note != null) {
                          await eventDBS.updateData(widget.note.id,{
                            "title": _title.text,
                            "description": _description.text,
                            "event_date": widget.note.eventDate,
                            "struggle":this.data.dropdownValue,
                          });
                        }else{
                          await eventDBS.createItem(EventModel(
                              title: _title.text,
                              description: _description.text,
                              eventDate: _eventDate,
                              approve: false,
                              struggle: this.data.dropdownValue,
                          ));
                        }
                        Navigator.pop(context);
                        setState(() {
                          processing = false;
                        });
                      }
                    },

                    child: Text(
                      "Save",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }
}
class Data{
  String dropdownValue;
  Data({this.dropdownValue});
}