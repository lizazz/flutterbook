import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'TaskDBWorker.dart';
import 'TasksModel.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget
{
  Widget build(BuildContext inContext)
  {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext inContext, Widget inChild, TasksModel inModel)
            {
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add, color: Colors.white),
                    onPressed: (){
                      tasksModel.entityBeingEdited = Task();
                      tasksModel.setStackIndex(1);
                    },
                  ),
                  body: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      itemCount : tasksModel.entityList.length,
                      itemBuilder: (BuildContext inBuildContext, int inIndex) {
                        Task task = tasksModel.entityList[inIndex];
                        String sDueDate = '';

                        if (task.dueDate != null) {
                          List dateParts = task.dueDate.split(",");
                          DateTime dueDate = DateTime(
                            int.parse(dateParts[0]),
                            int.parse(dateParts[1]),
                            int.parse(dateParts[2])
                          );
                          sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
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
                                    onPressed: (inContext) => _deleteTask(inContext, task),
                                  ),
                                ],
                              ),
                              child : ListTile(
                                leading : Checkbox(
                                  value : task.completed == "true" ? true : false,
                                  onChanged : (inValue) async {
                                    task.completed = inValue.toString();
                                    await TasksDBWorker.db.update(task);
                                    tasksModel.loadData("tasks", TasksDBWorker.db);
                                  }
                                ),
                                  title:Text(
                                    task.description,
                                    style: task.completed == "true" ?
                                      TextStyle(
                                        color: Theme.of(inContext).disabledColor,
                                        decoration: TextDecoration.lineThrough
                                      ) :
                                      TextStyle(
                                        color: Theme.of(inContext).textTheme.headline6?.color
                                      ),
                                  ),
                                  subtitle: task.dueDate == null ? null :
                                    Text(
                                      sDueDate,
                                      style: task.completed == "true" ?
                                        TextStyle(
                                          color: Theme.of(inContext).disabledColor,
                                          decoration: TextDecoration.lineThrough
                                        ) :
                                       TextStyle(
                                           color: Theme.of(inContext).textTheme.headline6?.color
                                       )
                                    ),
                                  onTap: () async {
                                   if (task.completed == "true") { return; }

                                   tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);

                                   if (tasksModel.entityBeingEdited.dueDate == null) {
                                     tasksModel.setChosenDate('');
                                   } else {
                                     tasksModel.setChosenDate(sDueDate);
                                   }

                                   tasksModel.setStackIndex(1);
                                  }
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

  Future _deleteTask (BuildContext inContext, Task inTask)
  {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: const Text(
                "Are you sure you want to delete task?"
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(inAlertContext).pop();
                  },
                  child: const Text("Cancel")
              ),
              TextButton(
                  onPressed: () async {
                    await TasksDBWorker.db.delete(inTask.id);
                    Navigator.of(inAlertContext).pop();
                    tasksModel.loadData("notes", TasksDBWorker.db);
                  },
                  child: const Text("Delete")
              )
            ],
          );
        }
    );
  }
}