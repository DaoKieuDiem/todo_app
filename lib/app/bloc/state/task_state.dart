import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class TaskState extends BaseBlocState {
  final List<TaskEntity> completedTasks;
  final List<TaskEntity> uncompletedTasks;
  final bool isFetchedData;
  TaskState({
    TaskState state,
    bool isFetchedData,
    List<TaskEntity> completedTasks,
    List<TaskEntity> uncompletedTasks,
  })  : completedTasks = completedTasks ?? state?.completedTasks,
        uncompletedTasks = uncompletedTasks ?? state?.uncompletedTasks,
        isFetchedData = isFetchedData ?? state?.isFetchedData,
        super(timeStamp: DateTime.now().millisecondsSinceEpoch);
}
