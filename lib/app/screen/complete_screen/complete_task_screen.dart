import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/app/screen/edit_task_screen/edit_task_screen.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class CompletedTaskScreen extends StatefulWidget {
  @override
  _CompletedTaskScreenState createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState
    extends BaseLayoutState<CompletedTaskScreen, BaseBloc, BaseBlocState> {
  ThemeData get themeData => Theme.of(context);
  HomeScreenBloc get homeBloc => BlocProvider.of<HomeScreenBloc>(context);
  @override
  TaskBloc get bloc => homeBloc?.taskBloc;
  List<TaskEntity> get tasks => bloc?.state?.completedTasks;
  @override
  bool get isContentLayout => true;
  @override
  Widget buildContent(BuildContext context) {
    return tasks?.isNotEmpty == true
        ? BlocListener(
            cubit: bloc,
            listener: (context, TaskState state) {
              if (state?.changeCheckMessage?.isNotEmpty == true) {
                Scaffold.of(context, nullOk: true)?.showSnackBar(
                  SnackBar(
                    content: Text(
                      state?.changeCheckMessage,
                      style: themeData.textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                );
                bloc?.reset();
              }
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  child: const Image(
                    image: AssetImage(ImageAssetUrl.backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                ListView(
                  children: [
                    ...tasks
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 0.0),
                            child: _buildItem(context, e),
                          ),
                        )
                        .toList(),
                  ],
                )
              ],
            ),
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
          left: 50.0,
          right: 20.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 85.0),
            child: Text(
              'Seem you have not done any task',
              style: themeData.textTheme.headline6.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, TaskEntity item) {
    final _check = tasks?.firstWhere(
          (element) => element == item,
          orElse: () => null,
        ) !=
        null;
    return Dismissible(
      key: Key(item.toString()),
      onDismissed: (direction) {
        bloc?.deleteTask(item: item);
      },
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
                  child: Theme(
                    data: themeData.copyWith(
                      toggleableActiveColor: Colors.white,
                    ),
                    child: Checkbox(
                      checkColor: themeData.primaryColor,
                      value: _check,
                      onChanged: (value) {
                        bloc?.checkDone(item: item);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.task,
                          style: themeData.textTheme.subtitle1.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
