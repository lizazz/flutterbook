import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsDBWorker.dart';
import '../utils.dart' as utils;
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget
{
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry()
  {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel)
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
                            child: const Text("Cancel")
                        ),
                        Spacer(),
                        TextButton(
                            onPressed: () {_save(inContext, appointmentsModel);},
                            child: const Text("Save")
                        )
                      ],
                    )
                ),
                body: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.title),
                        title: TextFormField(
                          decoration: const InputDecoration(hintText: "Title"),
                          controller: _titleEditingController,
                          validator: (String? inValue) {
                            if (inValue == null || inValue.isEmpty) {
                              return "Please enter a title";
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.today),
                        title: const Text("Appointment's Date"),
                        subtitle: Text(
                            appointmentsModel.chosenDate != '' ? appointmentsModel.chosenDate : ''
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            String chosenDate = await utils.selectDate(
                                inContext, appointmentsModel, appointmentsModel.entityBeingEdited.apptDate
                            );

                            if (chosenDate != '') {
                              appointmentsModel.entityBeingEdited.apptDate = chosenDate;
                            } else {
                              appointmentsModel.entityBeingEdited.apptDate = DateTime.now();
                            }
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.description),
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
                        leading: const Icon(Icons.alarm),
                        title: const Text("Time"),
                        subtitle: Text(appointmentsModel.apptTime.isEmpty ?
                          '' :
                          appointmentsModel.apptTime
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () => _selectTime(inContext),
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

  void _save(BuildContext inContext, AppointmentsModel inModel) async
  {

    if (_formKey.currentState != null && _formKey.currentState?.validate() == false) {
      return;
    }

    if (inModel.entityBeingEdited.id == 0) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id > 0) {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("notes", AppointmentsDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            content: Text("Note saved"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2)
        )
    );
  }

  Future _selectTime(BuildContext inContext) async
  {
    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime.isNotEmpty) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1])
      );
    }

    TimeOfDay? picked = await showTimePicker(
        context: inContext,
        initialTime: initialTime
    );

    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }
}