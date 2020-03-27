import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ddd/app_service/note_app_service.dart';
import 'package:flutter_ddd/common/exception.dart';
import 'package:flutter_ddd/infrastructure/note/note_factory.dart';

import 'infrastructure/note_repository.dart';

void main() {
  final repository = NoteRepository();

  GetIt.instance.registerSingleton<NoteRepositoryBase>(repository);

  group('Note', () {
    test('registering existing title should fail', () async {
      repository.clear();

      final service = NoteAppService(factory: const NoteFactory());
      await service.saveNote(
        title: 'note title',
        body: 'note body',
        categoryId: 'category id',
      );

      bool isSuccessful = true;

      try {
        await service.saveNote(
          title: 'note title',
          body: 'note body 2',
          categoryId: 'category id 2',
        );
      } catch (e) {
        if (e.runtimeType == NotUniqueException) {
          isSuccessful = false;
        }
      }

      expect(isSuccessful, false);
    });

    test('new note should be registered', () async {
      repository.clear();

      final service = NoteAppService(factory: const NoteFactory());
      await service.saveNote(
        title: 'note title',
        body: 'note body',
        categoryId: 'category id',
      );

      final notes = await service.getNoteList('category id');
      expect(notes.length, 1);
    });

    test('update without change in title should be successful', () async {
      repository.clear();

      final service = NoteAppService(factory: const NoteFactory());
      await service.saveNote(
        title: 'note title',
        body: 'note body',
        categoryId: 'category id',
      );

      final notes = await service.getNoteList('category id');

      bool isSuccessful = true;

      try {
        await service.updateNote(
          id: notes[0].id,
          title: 'note title',
          body: 'note body 2',
          categoryId: 'category id',
        );
      } catch (_) {
        isSuccessful = false;
      }

      expect(isSuccessful, true);
    });

    test('note should be moved to another category', () async {
      repository.clear();

      final service = NoteAppService(factory: const NoteFactory());
      await service.saveNote(
        title: 'note title',
        body: 'note body',
        categoryId: 'category id 1',
      );

      List<NoteSummaryDto> notes = await service.getNoteList('category id 1');
      expect(notes.length, 1);

      await service.updateNote(
        id: notes[0].id,
        title: 'note title',
        body: 'note body',
        categoryId: 'category id 2',
      );

      notes = await service.getNoteList('category id 1');
      expect(notes.length, 0);

      notes = await service.getNoteList('category id 2');
      expect(notes.length, 1);
    });

    test('note should be removed', () async {
      repository.clear();

      final service = NoteAppService(factory: const NoteFactory());
      await service.saveNote(
        title: 'note title',
        body: 'note body',
        categoryId: 'category id',
      );

      final notes = await service.getNoteList('category id');
      await service.removeNote(notes[0].id);

      final note = await service.getNote(notes[0].id);
      expect(note, isNull);
    });
  });
}
