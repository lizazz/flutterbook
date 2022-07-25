import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TaskDBWorker.dart';
import 'TasksList.dart';
import 'TasksEntry.dart';
import 'TasksModel.dart' show TasksModel, tasksModel;

class Tasks extends StatelessWidget
{
  Tasks({Key? key}) : super(key: key)
  {
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child:
        ScopedModelDescendant<TasksModel>(
            builder: (BuildContext inContext, Widget inChild, TasksModel inModel)
            {
              return IndexedStack(
                index: inModel.stackIndex,
                children: [
                  TasksList(),
                  TasksEntry()
                ],
              );
            }
        )
    );
  }
}