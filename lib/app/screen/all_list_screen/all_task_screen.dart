import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/app/extension/string.dart';

class AllTaskScreen extends StatefulWidget {
  @override
  _AllTaskScreenState createState() => _AllTaskScreenState();
}

class _AllTaskScreenState
    extends BaseLayoutState<AllTaskScreen, TaskBloc, TaskState> {
  ThemeData get themeData => Theme.of(context);
  List<TaskEntity> get completedTasks => bloc?.state?.completedTasks;
  List<TaskEntity> get uncompletedTasks => bloc?.state?.uncompletedTasks;
  @override
  TaskBloc get bloc => BlocProvider.of<HomeScreenBloc>(context).taskBloc;
  @override
  bool get isContentLayout => true;
  @override
  Widget buildContent(BuildContext context) {
    return (completedTasks?.isNotEmpty == true ||
            uncompletedTasks?.isNotEmpty == true)
        ? ListView(
            children: [
              if (uncompletedTasks?.isNotEmpty == true)
                ...uncompletedTasks.map(_buildUncompleteTasks).toList(),
              if (completedTasks.isNotEmpty == true)
                Theme(
                  data: themeData.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    title: Text(
                      'Completed(${completedTasks.length})',
                      style: themeData.textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    children: [...completedTasks.map(_buildTaskItem).toList()],
                  ),
                )
            ],
          )
        : buildContentEmpty(context);
  }

  Widget _buildUncompleteTasks(TaskEntity item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 8.0),
      child: Column(
        key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (item.date.isNotEmpty == true) ? item.date : 'No due date',
            style: themeData.textTheme.headline6.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildTaskItem(item)
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskEntity item) {
    final _check = completedTasks.firstWhere(
          (element) => element == item,
          orElse: () => null,
        ) !=
        null;
    return Dismissible(
      key: Key(item.toString()),
      onDismissed: (direction) {
        bloc.deleteTask(item: item);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              margin: const EdgeInsets.only(right: 10.0),
              color: (_check == true) ? themeData.primaryColor : Colors.red,
              child: Checkbox(
                value: _check,
                onChanged: (value) {
                  bloc.checkDone(item: item);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.task.inCaps,
                    style: themeData.textTheme.subtitle1.copyWith(
                        decoration: (_check == true)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.detail.isNotEmpty == true)
                    Text(
                      item.detail.inCaps,
                      style: themeData.textTheme.subtitle2.copyWith(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}