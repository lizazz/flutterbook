import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsDBWorker.dart';
import '../utils.dart' as utils;
import "dart:io";
import "package:path/path.dart";
import 'ContactsModel.dart' show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget
{
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry()
  {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    if (contactsModel.entityBeingEdited != null) {
      _nameEditingController.text = contactsModel.entityBeingEdited.name;
      _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
      _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext inContext, Widget inChild, ContactsModel inModel)
            {
              File avatarFile = File(join(utils.docsDir.path, "avatar"));

              if (avatarFile.existsSync() == false) {
                if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id != null) {
                  avatarFile = File(join(utils.docsDir.path, inModel.entityBeingEdited.id.toString()));
                }
              }
              return Scaffold(
                bottomNavigationBar: Padding(
                    padding :
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              File avatarFile = File(join(utils.docsDir.path, "avatar"));

                              if (avatarFile.existsSync()) {
                                avatarFile.deleteSync();
                              }

                              FocusScope.of(inContext).requestFocus(FocusNode());
                              inModel.setStackIndex(0);
                            },
                            child: const Text("Cancel")
                        ),
                        Spacer(),
                        TextButton(
                            onPressed: () {_save(inContext, contactsModel);},
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
                        title: avatarFile.existsSync() ?
                          Image.file(avatarFile) :
                          const Text("No avatar image for this contact"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () => _selectAvatar(inContext),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: TextFormField(
                          decoration: const InputDecoration(hintText: "Name"),
                          controller: _nameEditingController,
                          validator: (String? inValue) {
                            if (inValue == null || inValue.isEmpty) {
                              return "Please enter a name";
                            }

                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: "Phone"),
                          controller: _phoneEditingController,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: "Email"),
                          controller: _emailEditingController,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.today),
                        title: const Text("Birthday"),
                        subtitle: Text(
                            contactsModel.chosenDate != '' ? contactsModel.chosenDate : ''
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () async {
                            String chosenDate = await utils.selectDate(
                                inContext, contactsModel, contactsModel.entityBeingEdited.birthday
                            );

                            if (chosenDate != null) {
                              contactsModel.entityBeingEdited.birthday = chosenDate;
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

  void _save(BuildContext inContext, ContactsModel inModel) async
  {
    int id = 0;

    if (_formKey.currentState != null && _formKey.currentState?.validate() == false) {
      return;
    }

    if (inModel.entityBeingEdited.id == 0) {
      id =  await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else if (inModel.entityBeingEdited != null && inModel.entityBeingEdited.id > 0) {
      id = contactsModel.entityBeingEdited.id;
    }

    File avatarFile = File(join(utils.docsDir.path, "avatar"));

    if (avatarFile.existsSync() && id > 0) {
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            content: Text("Contact saved"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2)
        )
    );
  }

  Future _selectAvatar(BuildContext inContext)
  {
    return showDialog(
        context: inContext,
        builder: (BuildContext inDialogContext) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: const Text("Take a picture"),
                    onTap: () async {
                      var cameraImage = await ImagePicker().pickImage(source: ImageSource.camera);

                      if (cameraImage != null) {
                        File(cameraImage.path).copySync(join(utils.docsDir.path, "avatar"));
                        contactsModel.triggerRebuild();
                      }

                      Navigator.of(inDialogContext).pop();
                    },
                  ),
                  GestureDetector(
                    child: const Text("Select from Gallery"),
                    onTap: () async {
                      var galleryImage = await ImagePicker().pickImage(
                        source: ImageSource.gallery
                      );

                      if (galleryImage != null) {
                        File(galleryImage.path).copySync(join(utils.docsDir.path, "avatar"));
                        contactsModel.triggerRebuild();
                      }

                      Navigator.of(inDialogContext).pop();
                    },
                  )
                ],
              ),
            ),
          );
        }
    );
  }
}