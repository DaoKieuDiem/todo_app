import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class TaskState extends BaseBlocState {
  final List<TaskEntity> completedTasks;
  final List<TaskEntity> uncompletedTasks;
  final bool isFetchedData;
  final String currentListTasks;
  final List<String> listTasks;
  final String listTaskToMove;
  final String changeCheckMessage;
  TaskState({
    TaskState state,
    bool isFetchedData,
    List<TaskEntity> completedTasks,
    List<TaskEntity> uncompletedTasks,
    String currentListTasks,
    List<String> listTasks,
    String listTaskToMove,
    String changeCheckMessage,
  })  : completedTasks = completedTasks ?? state?.completedTasks,
        uncompletedTasks = uncompletedTasks ?? state?.uncompletedTasks,
        isFetchedData = isFetchedData ?? state?.isFetchedData,
        currentListTasks = currentListTasks ?? state?.currentListTasks,
        listTasks = listTasks ?? state?.listTasks,
        listTaskToMove = listTaskToMove ?? state?.listTaskToMove,
        changeCheckMessage = changeCheckMessage ?? state?.changeCheckMessage,
        super(timeStamp: DateTime.now().millisecondsSinceEpoch);
}
