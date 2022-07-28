import '../BaseModel.dart';

class Appointment
{
  int id = 0;
  String title = '';
  String description = '';
  String apptDate = '';
  String apptTime = '';
  String toString() {
    return "{id=$id, title=$title, description=$description, "
        "apptDate=$apptDate, apptTime=$apptTime}";
  }
}

class AppointmentsModel extends BaseModel {
  String apptTime = '';

  void setApptTime(String inApptTime)
  {
    apptTime = inApptTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();