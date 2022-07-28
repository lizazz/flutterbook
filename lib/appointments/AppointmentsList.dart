import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsModel.dart' show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget
{
  @override
  Widget build(BuildContext inContext)
  {
    EventList<Event> markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      if (appointment.apptDate == null || appointment.apptDate.isEmpty) {
        appointment.apptDate = "1970,01,01";
      }

      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[0]),
          int.parse(dateParts[2])
      );
      markedDateMap.add(apptDate, Event(
        date: apptDate,
        icon: Container(decoration: const BoxDecoration(color: Colors.blue))
      ));
    }

    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
          builder: (inContext, inChild, inModel) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: (){
                  appointmentsModel.entityBeingEdited = Appointment();
                  DateTime now = DateTime.now();
                  appointmentsModel.entityBeingEdited.apptDate = "${now.year},${now.month},${now.day}";
                  appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
                  appointmentsModel.setApptTime('');
                  appointmentsModel.setStackIndex(1);
                },
              ),
                body : Column(
                  children: [
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: CalendarCarousel<Event>(
                            thisMonthDayBorderColor: Colors.grey,
                            daysHaveCircularBorder: false,
                            markedDatesMap: markedDateMap,
                            todayTextStyle: const TextStyle(color: Colors.blue
                            ),
                            onDayPressed: (DateTime inDate, List<Event> inEvents) {
                              _showAppointments(inDate, inContext);
                            },
                          ),
                        )
                    )
                  ],
                )
            );
          },
        )
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async
  {
    showModalBottomSheet(
        context: inContext,
        builder: (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
              model: appointmentsModel,
              child: ScopedModelDescendant<AppointmentsModel>(
                builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
                  return Scaffold(
                    body: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Text(
                                DateFormat.yMMMd("en_US").format(inDate.toLocal()),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(inContext).colorScheme.secondary,
                                    fontSize: 24
                                )
                              ),
                              const Divider(),
                              Expanded(child: ListView.builder(
                                  itemCount: appointmentsModel.entityList.length,
                                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                                    Appointment appointment = appointmentsModel.entityList[inIndex];

                                    if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                      return Container(height: 0);
                                    }

                                    String apptTime = "";

                                    if (appointment.apptTime.isNotEmpty) {
                                      List timeParts = appointment.apptTime.split(",");
                                      TimeOfDay at = TimeOfDay(
                                          hour: int.parse(timeParts[0]),
                                          minute: int.parse(timeParts[1])
                                      );
                                      apptTime = "(${at.format(inContext)})";
                                    }

                                    return Slidable(
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          label: 'Delete',
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                          onPressed: (inContext) => _deleteAppointment(inBuildContext, appointment),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      color: Colors.grey.shade300,
                                      child: ListTile(
                                        title: Text("${appointment.title} $apptTime"),
                                        subtitle: appointment.description == '' ?
                                          null : Text(appointment.description),
                                        onTap : () {
                                          _editAppointment(inContext, appointment);
                                        }
                                     )
                                    )
                                    );
                                  }
                              ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
          );
        }
    );
  }

  _deleteAppointment(BuildContext inBuildContext, Appointment inAppointment)
  {
    return showDialog(
        context: inBuildContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: const Text('Delete Appointment'),
            content: Text(
                "Are you sure you want to delete ${inAppointment.title}?"
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
                    await AppointmentsDBWorker.db.delete(inAppointment.id);
                    Navigator.of(inAlertContext).pop();
                    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
                  },
                  child: const Text("Delete")
              )
            ],
          );
        }
    );
  }

  _editAppointment(BuildContext inContext, Appointment inAppointment) async
  {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(inAppointment.id);

    if (appointmentsModel.entityBeingEdited.apptDate.length == 0) {
      appointmentsModel.setChosenDate('');
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
      );
      appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
    }

    if (appointmentsModel.entityBeingEdited.apptTime.isEmpty) {
      appointmentsModel.setApptTime('');
    } else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }

    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);
  }
}