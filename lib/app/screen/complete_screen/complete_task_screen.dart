import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/domain/entities/task_entity.dart';
import 'package:todo_app/app/extension/string.dart';

class CompletedTaskScreen extends StatefulWidget {
  @override
  _CompletedTaskScreenState createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState
    extends BaseLayoutState<CompletedTaskScreen, BaseBloc, BaseBlocState> {
  ThemeData get themeData => Theme.of(context);
  @override
  TaskBloc get bloc => BlocProvider.of<HomeScreenBloc>(context).taskBloc;
  List<TaskEntity> get tasks => bloc?.state?.completedTasks;
  @override
  bool get isContentLayout => true;
  @override
  Widget buildContent(BuildContext context) {
    return tasks.isNotEmpty == true
        ? ListView(
            children: [
              ...tasks.map((e) => _buildItem(context, e)).toList(),
            ],
          )
        : buildContentEmpty(context);
  }

  @override
  Widget buildContentEmpty(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'Seem you have not done any task',
          style: themeData.textTheme.headline6,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, TaskEntity item) {
    final _check = tasks.firstWhere(
          (element) => element == item,
          orElse: () => null,
        ) !=
        null;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            color: themeData.primaryColor,
            child: Checkbox(
              value: _check,
              onChanged: (value) {
                bloc.checkDone(item: item);
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.task.inCaps,
                style: themeData.textTheme.subtitle1.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
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
          )
        ],
      ),
    );
  }
}
