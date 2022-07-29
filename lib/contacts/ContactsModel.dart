import '../BaseModel.dart';

class Contact
{
  int id = 0;
  String name = '';
  String phone = '';
  String email = '';
  String birthday = '';
}

class ContactsModel extends BaseModel {
  String apptTime = '';

  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();