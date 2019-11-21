import 'package:flutter/material.dart';
import 'package:flutter_ddd/application/note_app_service.dart';

export 'package:flutter_ddd/application/dto/note_summary_dto.dart';

class NoteModel with ChangeNotifier {
  final NoteAppService _app;
  final String _categoryId;

  NoteModel({@required NoteAppService app, @required String categoryId})
      : _app = app,
        _categoryId = categoryId {
    _updateList();
  }

  List<NoteSummaryDto> _list;

  List<NoteSummaryDto> get list =>
      _list == null ? null : List.unmodifiable(_list);

  Future<void> registerNote({
    @required String title,
    @required String body,
    @required String categoryId,
  }) async {
    await _app.registerNote(
      title: title,
      body: body,
      categoryId: categoryId,
    );
    _updateList();
  }

  Future<void> updateNote({
    @required String id,
    @required String title,
    @required String body,
    @required String categoryId,
  }) async {
    await _app.updateNote(
      id: id,
      title: title,
      body: body,
      categoryId: categoryId,
    );
    _updateList();
  }

  Future<void> removeNote(String id) async {
    await _app.removeNote(id);
    _updateList();
  }

  Future<NoteDto> getNote(String id) async {
    return await _app.getNote(id);
  }

  void _updateList() {
    _app.getNoteList(_categoryId).then((list) {
      _list = list;
      notifyListeners();
    });
  }
}
