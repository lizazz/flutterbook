import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesModel.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget
{
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry()
  {
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    if (notesModel.entityBeingEdited != null) {
      _titleEditingController.text = notesModel.entityBeingEdited.title;
      _contentEditingController.text = notesModel.entityBeingEdited.content;
    }

      return ScopedModel(
          model: notesModel,
          child: ScopedModelDescendant<NotesModel>(
              builder: (BuildContext inContext, Widget inChild, NotesModel inModel)
              {
                return Scaffold(
                    bottomNavigationBar: Padding(
                      padding :
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  inModel.setStackIndex(0);
                                },
                                child: Text("Cancel")
                            ),
                            Spacer(),
                            TextButton(
                                onPressed: () {_save(inContext, notesModel);},
                                child: Text("Save")
                            )
                          ],
                        )
                    ),
                    body: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Icon(Icons.title),
                            title: TextFormField(
                              decoration: const InputDecoration(hintText: "Title"),
                              controller: _titleEditingController,
                              validator: (String? inValue) {
                                if (inValue == null || inValue.isEmpty) {
                                  return "Please enter a title";
                                }
                                print('ok');
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.content_paste),
                            title: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 8,
                              decoration: const InputDecoration(hintText: "Content"),
                              controller: _contentEditingController,
                              validator: (String? inValue) {
                                if (inValue == null || inValue.isEmpty) {
                                  print("Please enter content");
                                  return "Please enter content";
                                }
print('ok');
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.color_lens),
                            title: Row(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      shape: Border.all(width: 18, color: Colors.red) +
                                        Border.all(width: 6,
                                          color: notesModel.color == "red" ?
                                              Colors.red : Theme.of(inContext).canvasColor
                                        )
                                    ),
                                  ),
                                  onTap: () {
                                    notesModel.entityBeingEdited.color = "red";
                                    notesModel.setColor("red");
                                  },
                                ),
                                Spacer(),
                                GestureDetector(
                                  child: Container(
                                    decoration: ShapeDecoration(
                                        shape: Border.all(width: 18, color: Colors.blue) +
                                            Border.all(width: 6,
                                                color: notesModel.color == "blue" ?
                                                Colors.blue : Theme.of(inContext).canvasColor
                                            )
                                    ),
                                  ),
                                  onTap: () {
                                    notesModel.entityBeingEdited.color = "blue";
                                    notesModel.setColor("blue");
                                  },
                                ),
                                Spacer(),
                                GestureDetector(
                                  child: Container(
                                    decoration: ShapeDecoration(
                                        shape: Border.all(width: 18, color: Colors.green) +
                                            Border.all(width: 6,
                                                color: notesModel.color == "green" ?
                                                Colors.green : Theme.of(inContext).canvasColor
                                            )
                                    ),
                                  ),
                                  onTap: () {
                                    notesModel.entityBeingEdited.color = "green";
                                    notesModel.setColor("green");
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                );
              }
          )
      );
  }

  void _save(BuildContext inContext, NotesModel inModel) async
  {

    if (_formKey.currentState != null && _formKey.currentState?.validate() == false) {
      return;
    }

    if (inModel.entityBeingEdited.id == 0) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id > 0) {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    notesModel.loadData("notes", NotesDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
          content: Text("Note saved"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)
      )
    );
  }
}