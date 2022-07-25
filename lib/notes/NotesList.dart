import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'NotesDBWorker.dart';
import 'NotesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget
{
  Widget build(BuildContext inContext)
  {
    return ScopedModel<NotesModel>(
        model: notesModel, 
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext inContext, Widget inChild, NotesModel inModel)
            {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: (){
                    notesModel.entityBeingEdited = Note();
                    notesModel.setColor(null);
                    notesModel.setStackIndex(1);
                  },
                ),
                  body: ListView.builder(
                      itemCount: notesModel.entityList.length,
                      itemBuilder: (BuildContext inBuildContext, int inIndex) {
                        Note note = notesModel.entityList[inIndex];
                        Color color = Colors.white;

                        switch (note.color) {
                          case "red" : color = Colors.red; break;
                          case "green" : color = Colors.green; break;
                          case "blue" : color = Colors.blue; break;
                          case "yellow" : color = Colors.yellow; break;
                          case "grey" : color = Colors.grey; break;
                          case "purple" : color = Colors.purple; break;
                        }

                        return Container(
                            padding : const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child : Slidable(
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    label: 'Delete',
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    onPressed: (inContext) => _deleteNote(inContext, note),
                                  ),
                                ],
                              ),
                              child: Card (
                                elevation: 8,
                                color: color,
                                child: ListTile(
                                  title: Text("${note.title}"),
                                  subtitle: Text("${note.content}"),
                                  onTap: () async {
                                    notesModel.entityBeingEdited =
                                        await NotesDBWorker.db.get(note.id);
                                    notesModel.setColor(notesModel.entityBeingEdited.color);
                                    notesModel.setStackIndex(1);
                                  },
                                ),
                              ),
                            )
                        );
                      }
                  )
              );
            }
        )
    );
  }

  Future _deleteNote (BuildContext inContext, Note inNote)
  {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text('Delete Note'),
            content: Text(
              "Are you sure you want to delete ${inNote.title}?"
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text("Cancel")
              ),
              TextButton(
                  onPressed: () async {
                    await NotesDBWorker.db.delete(inNote.id);
                    Navigator.of(inAlertContext).pop();
                    notesModel.loadData("notes", NotesDBWorker.db);
                  },
                  child: Text("Delete")
              )
            ],
          );
        }
    );
  }
}