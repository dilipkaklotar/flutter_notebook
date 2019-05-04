import 'package:flutter/material.dart';
import 'package:flutter_notebook/models/note.dart';
import 'package:flutter_notebook/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  String appBarTitle;

  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();

  String selectedProirity = 'High';

  String appBarTitle;
  Note note;

  DatabaseHelper databaseHelper = DatabaseHelper();

  static var priorities = ['High', 'Low'];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.body1;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          moveToHomeScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    moveToHomeScreen();
                  }),
            ),
            body: Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: DropdownButton(
                            items: priorities.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            style: textStyle,
                            value: updatePriorityAsString(note.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: TextFormField(
                            controller: titleController,
                            style: textStyle,
                            validator: (String value) {
                              if (value.isEmpty) return 'Please enter title';
                            },
                            decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: TextFormField(
                            controller: descriptionController,
                            style: textStyle,
                            validator: (String value) {
                              if (value.isEmpty) return 'Please enter description';
                            },
                            decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: RaisedButton(
                                    color: Colors.purple,
                                    textColor: Colors.white,
                                    child: Text(
                                      'Save',
                                      textScaleFactor: 1.5,
                                    ),
                                    onPressed: () {
                                      debugPrint('Save button Clicked');
                                      if(formKey.currentState.validate()) {
                                        _save();
                                      }
                                    })),
                            Container(padding: EdgeInsets.only(left: 10.0)),
                            Expanded(
                                child: RaisedButton(
                                    color: Colors.purple,
                                    textColor: Colors.white,
                                    child: Text(
                                      'Delete',
                                      textScaleFactor: 1.5,
                                    ),
                                    onPressed: () {
                                      debugPrint('Delete button Clicked');
                                      _delete();
                                    }))
                          ],
                        ),
                      )
                    ],
                  ),
                ))));
  }

  void moveToHomeScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String updatePriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = priorities[0]; // High
        break;
      case 2:
        priority = priorities[1]; // Low
        break;
    }
    return priority;
  }



  void _save() async {
    moveToHomeScreen();

    note.title = titleController.text;
    note.description = descriptionController.text;

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      //update
      result = await databaseHelper.updateNote(note);
    } else {
      // Insert
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      //
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Note note saved');
    }
  }

  void _delete() async {
    moveToHomeScreen();

    if (note.id == null) {
      _showAlertDialog('Status', 'No note was saved');
      return;
    }

    int result = await databaseHelper.deleteNote(note.id);

    if (result != 0) {
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error while deleting note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
