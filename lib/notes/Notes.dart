import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesList.dart';
import 'NotesEntry.dart';
import 'NotesModel.dart' show NotesModel, notesModel;

class Notes extends StatelessWidget
{
  Notes({Key? key}) : super(key: key)
  {
    notesModel.loadData("notes", NotesDBWorker.db);
  }

  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child:
          ScopedModelDescendant<NotesModel>(
            builder: (BuildContext inContext, Widget inChild, NotesModel inModel)
            {
              return IndexedStack(
                index: inModel.stackIndex,
                children: [
                  NotesList(),
                  NotesEntry()
                ],
              );
            }
          )
    );
  }
}