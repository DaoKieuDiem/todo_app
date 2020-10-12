import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/app/screen/edit_task_screen/edit_task_screen.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class AllTaskScreen extends StatefulWidget {
  @override
  _AllTaskScreenState createState() => _AllTaskScreenState();
}

class _AllTaskScreenState
    extends BaseLayoutState<AllTaskScreen, TaskBloc, TaskState> {
  ThemeData get themeData => Theme.of(context);
  List<TaskEntity> get completedTasks => bloc?.state?.completedTasks;
  List<TaskEntity> get uncompletedTasks => bloc?.state?.uncompletedTasks;

  HomeScreenBloc get homeBloc => BlocProvider.of<HomeScreenBloc>(context);

  @override
  TaskBloc get bloc => homeBloc?.taskBloc;
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
              if (completedTasks?.isNotEmpty == true)
                Theme(
                  data: themeData.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    title: Text(
                      'Completed(${completedTasks?.length ?? ''})',
                      style: themeData.textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    children: [
                      ...completedTasks
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 8.0),
                              child: _buildTaskItem(e),
                            ),
                          )
                          .toList()
                    ],
                  ),
                )
            ],
          )
        : buildContentEmpty(context);
  }

  @override
  Widget buildContentEmpty(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: const Image(
            image: AssetImage(ImageAssetUrl.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          bottom: 80.0,
          left: 100.0,
          right: 100.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'A fresh start',
                  style: themeData.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Anything to add?',
                  style: themeData.textTheme.subtitle1.copyWith(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
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
            (item.date?.isNotEmpty == true) ? item?.date : 'No due date',
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
    final _check = completedTasks?.firstWhere(
          (element) => element == item,
          orElse: () => null,
        ) !=
        null;
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        bloc?.deleteTask(item: item);
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                margin: const EdgeInsets.only(right: 10.0),
                color: (_check == true) ? themeData.primaryColor : Colors.red,
                child: Checkbox(
                  value: _check,
                  onChanged: (value) {
                    bloc?.checkDone(item: item);
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    homeBloc?.reset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(task: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.task,
                          style: themeData.textTheme.subtitle1.copyWith(
                              decoration: (_check == true)
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                        if (item?.detail?.isNotEmpty == true)
                          Text(
                            item?.detail,
                            style: themeData.textTheme.subtitle2.copyWith(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
