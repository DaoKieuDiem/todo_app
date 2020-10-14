import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

void main() {
  group('TaskModel', () {
    test('is generated correct from Entity', () {
      final task = TaskEntity(
        id: 'id',
        task: 'task',
        date: DateTime(2020, 10, 10),
        time: 'time',
        done: true,
        listName: 'listName',
      );
      final taskModel = TaskModel.fromEntity(task);
      expect(
        taskModel,
        TaskModel(
          id: 'id',
          task: 'task',
          date: DateTime(2020, 10, 10),
          time: 'time',
          done: true,
          listName: 'listName',
        ),
        skip: true,
      );
    });
  });
}
