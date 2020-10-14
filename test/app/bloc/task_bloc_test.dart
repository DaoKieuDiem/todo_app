import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/app/bloc/event/task_event.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/common/utils/database_utils.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_i.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class MockTaskRepository extends MockBloc implements ITaskRepository {
  void main() {
    group('Task bloc', () {
      TaskBloc taskBloc;
      setUp(() {
        DatabaseUtils.initDatabase();
        Hive
          ..registerAdapter(TaskModelAdapter())
          ..openBox(HiveBoxName.tasks);
        taskBloc = TaskBloc();
      });
      blocTest<TaskBloc, TaskState>(
          'should add a task to the list in '
          'response to an AddNewTaskEvent Event',
          build: () => taskBloc,
          act: (TaskBloc taskBloc) async {
            taskBloc.add(
              AddNewTaskEvent(
                item: TaskEntity(
                  id: '0',
                  task: 'dam cuoi ban',
                  listName: 'Default',
                  done: false,
                ),
              ),
            );
          },
          expect: <TaskState>[
            TaskState(
                completedTasks: const [],
                uncompletedTasks: [
                  TaskEntity(
                    id: '0',
                    task: 'dam cuoi ban',
                    listName: 'Default',
                    done: false,
                  ),
                ],
                currentListTasks: 'Default',
                listTasks: const ['Default']),
          ]);
    });
  }
}
