import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsList.dart';
import 'AppointmentsEntry.dart';

import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class Appointments extends StatelessWidget
{
  Appointments({Key? key}) : super(key: key)
  {
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child:
        ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel)
            {
              return IndexedStack(
                index: inModel.stackIndex,
                children: [
                  AppointmentsList(),
                  AppointmentsEntry()
                ],
              );
            }
        )
    );
  }
}