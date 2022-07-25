import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TaskDBWorker.dart';
import '../utils.dart' as utils;
import 'TasksModel.dart' show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget
{
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry()
  {
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    if (tasksModel.entityBeingEdited != null) {
      _descriptionEditingController.text = tasksModel.entityBeingEdited.description;
    }

    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext inContext, Widget inChild, TasksModel inModel)
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
                            onPressed: () {_save(inContext, tasksModel);},
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
                        leading: Icon(Icons.description),
                        title: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: const InputDecoration(hintText: "Description"),
                          controller: _descriptionEditingController,
                          validator: (String? inValue) {
                            if (inValue == null || inValue.isEmpty) {
                              return "Please enter a description";
                            }

                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.today),
                        title: Text("Due Date"),
                        subtitle: Text(
                           tasksModel.chosenDate != '' ? tasksModel.chosenDate : ''
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            String chosenDate = await utils.selectDate(
                              inContext, tasksModel, tasksModel.entityBeingEdited.dueDate
                            );

                            if (chosenDate != null) {
                              tasksModel.entityBeingEdited.dueDate = chosenDate;
                            }
                          },
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

  void _save(BuildContext inContext, TasksModel inModel) async
  {
    if (_formKey.currentState != null && _formKey.currentState?.validate() == false) {
      return;
    }

    if (inModel.entityBeingEdited.id == 0) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id > 0) {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            content: Text("Task saved"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2)
        )
    );
  }
}