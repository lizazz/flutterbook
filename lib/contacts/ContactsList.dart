import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'ContactsDBWorker.dart';
import "dart:io";
import "package:path/path.dart";
import '../utils.dart' as utils;
import 'ContactsModel.dart' show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget
{
  @override
  Widget build(BuildContext inContext)
  {
    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext inContext, Widget inChild, ContactsModel inModel) {
            return Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    File avatarFile = File(join(utils.docsDir.path, "avatar"));

                    if (avatarFile.existsSync()) {
                      avatarFile.deleteSync();
                    }

                    contactsModel.entityBeingEdited = Contact();
                    contactsModel.setChosenDate('');
                    contactsModel.setStackIndex(1);
                  },
                ),
                body : ListView.builder(
                  itemCount: contactsModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                    Contact contact = contactsModel.entityList[inIndex];
                    File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                    bool avatarFileExists = avatarFile.existsSync();

                    return Column(
                      children: [
                        Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  label: 'Delete',
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onPressed: (inContext) => _deleteContact(inBuildContext, contact),
                                )
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                backgroundImage: avatarFileExists ?
                                  FileImage(avatarFile) : null,
                                child: avatarFileExists ?
                                null :
                                Text(contact.name.substring(0, 1).toUpperCase())
                              ),
                              title: Text(contact.name),
                              subtitle: contact.phone == null ?
                                  null :
                                  Text(contact.phone),
                              onTap: () async {
                                File avatarFile = File(join(utils.docsDir.path, "avatar"));

                                if (avatarFile.existsSync()) {
                                  avatarFile.deleteSync();
                                }

                                contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);

                                if (contactsModel.entityBeingEdited.birthday == null) {
                                  contactsModel.setChosenDate('');
                                } else {
                                  List dateParts = contactsModel.entityBeingEdited.birthday.split(',');
                                  DateTime birthday = DateTime(
                                    int.parse(dateParts[0]),
                                    int.parse(dateParts[1]),
                                    int.parse(dateParts[2])
                                  );
                                  contactsModel.setChosenDate(
                                    DateFormat.yMMMd("en_US").format(birthday.toLocal())
                                  );
                                }
                                contactsModel.setStackIndex(1);
                              }
                            )
                        )
                      ],
                    );
                  },
                )
            );
          },
        )
    );
  }

  Future _deleteContact(BuildContext inContext, Contact inContact) async
  {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: const Text('Delete Contact'),
            content: Text(
                "Are you sure you want to delete ${inContact.name}?"
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
                    File avatarFile = File(join(utils.docsDir.path, inContact.id.toString()));

                    if (avatarFile.existsSync()) {
                      avatarFile.deleteSync();
                    }

                    await ContactsDBWorker.db.delete(inContact.id);
                    Navigator.of(inAlertContext).pop();
                    Scaffold.of(inContext).showSnackBar(
                      SnackBar(
                          content: Text("Contact deleted"),
                          backgroundColor : Colors.red,
                          duration: Duration(seconds: 2),
                      )
                    );
                    contactsModel.loadData("contacts", ContactsDBWorker.db);
                  },
                  child: const Text("Delete")
              )
            ],
          );
        }
    );
  }
}