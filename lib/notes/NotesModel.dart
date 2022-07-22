import '../BaseModel.dart';

class Note
{
  int id = 0;
  String title = '';
  String content = '';
  String color = 'ffffff';
  String toString() {
    return "{id=$id, title=$title, "
        "content=$content, color=$color}";
  }
}

class NotesModel extends BaseModel
{
  String color = 'ffffff';

  void setColor(String? inColor)
  {
    if (inColor != null) {
      color = inColor;
      notifyListeners();
    }
  }
}

NotesModel notesModel = NotesModel();