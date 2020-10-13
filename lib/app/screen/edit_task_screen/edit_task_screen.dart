import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskEntity task;

  EditTaskScreen({this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState(task: task);
}

class _EditTaskScreenState
    extends BaseLayoutState<EditTaskScreen, TaskBloc, TaskState> {
  ThemeData get themeData => Theme.of(context);

  HomeScreenBloc get homeBloc => BlocProvider.of<HomeScreenBloc>(context);

  @override
  TaskBloc get bloc => homeBloc?.taskBloc;

  DateTime get selectedDate => homeBloc?.state?.selectedDate;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  final TaskEntity task;

  _EditTaskScreenState({this.task});

  bool get done =>
      bloc?.state?.completedTasks?.firstWhere(
          (element) => element?.id == task?.id,
          orElse: () => null) !=
      null;
  @override
  void initState() {
    _taskNameController.text = task?.task ?? '';
    _detailController.text = task?.detail ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget buildAppBar(BuildContext context) {
    return AppBar(
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_outlined,
          color: Colors.white,
        ),
      ),
      title: Center(
        child: Text(
          'Edit task',
          style: themeData.textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
      actions: [
        BlocBuilder(
            cubit: bloc,
            builder: (context, TaskState state) {
              return (done == false)
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
                      child: InkWell(
                        onTap: () {
                          bloc?.updateTask(
                            item: TaskEntity(
                              id: task.id,
                              task: (_taskNameController?.text
                                          ?.trim()
                                          ?.isNotEmpty ==
                                      true)
                                  ? _taskNameController?.text?.trim()
                                  : task?.task,
                              detail: (_detailController?.text
                                          ?.trim()
                                          ?.isNotEmpty ==
                                      true)
                                  ? _detailController?.text?.trim()
                                  : task?.detail,
                              date: (selectedDate != null)
                                  ? DateFormat('dd-MM-yyyy')
                                      .format(selectedDate)
                                  : task?.date,
                              done: done,
                              listName: bloc?.state?.listTaskToMove,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
                      child: InkWell(
                        onTap: () {
                          final _item = task..done = !task.done;
                          bloc?.updateTask(item: _item);
                        },
                        child: const Icon(
                          Icons.undo_outlined,
                          color: Colors.white,
                        ),
                      ),
                    );
            }),
        Container(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
          child: InkWell(
            onTap: () {
              bloc?.deleteTask(item: task);
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: [
          InkWell(
            onTap: () {
              if (done == false) {
                _changeListBottomSheet(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(15.0, 20.0, 20.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (state?.listTaskToMove?.isNotEmpty == true)
                        ? state?.listTaskToMove
                        : task?.listName,
                    style: themeData.textTheme.bodyText2.copyWith(
                      color: (done == false)
                          ? themeData.primaryColor
                          : themeData.disabledColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: (done == false)
                          ? themeData.primaryColor
                          : themeData.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: _taskNameController,
            style: themeData.textTheme.headline6.copyWith(
              decoration: (done == true)
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color:
                  (done == true) ? Colors.black.withOpacity(0.5) : Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: 15.0,
                bottom: 5.0,
                top: 5.0,
                right: 15.0,
              ),
            ),
            enabled: !done,
            maxLines: 2,
          ),
          TextField(
            controller: _detailController,
            style: themeData.textTheme.subtitle1.copyWith(
              color:
                  (done == true) ? Colors.black.withOpacity(0.5) : Colors.black,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 10.0,
                ),
                child: Icon(
                  Icons.notes_outlined,
                  color: (done == false)
                      ? themeData.primaryColor
                      : themeData.disabledColor,
                ),
              ),
              hintText: 'Add detail',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 15.0,
                bottom: 5.0,
                top: 13.0,
                right: 15.0,
              ),
            ),
            enabled: !done,
            maxLines: 2,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: Icon(
                    Icons.event_available_outlined,
                    color: (done == false)
                        ? themeData.primaryColor
                        : themeData.disabledColor,
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (done == false) {
                      _selectDate(context);
                    }
                  },
                  child: BlocBuilder(
                    cubit: homeBloc,
                    builder: (context, HomeScreenState state) {
                      return ((task?.date == null ||
                                  task?.date?.isEmpty == true) &&
                              selectedDate == null)
                          ? Container(
                              child: Text(
                                'Add date',
                                style: themeData.textTheme.subtitle2.copyWith(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: themeData.dividerColor)),
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 10.0, 20.0, 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (selectedDate != null)
                                        ? DateFormat.yMMMMd('en_US')
                                            .format(selectedDate)
                                        : task?.date,
                                    style: TextStyle(
                                      color: (done == true)
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 5.0),
                                    child: InkWell(
                                      onTap: () {
                                        homeBloc?.reset();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 20.0,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      homeBloc?.pickDate(selectedDate: picked);
    }
  }

  void _changeListBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                  child: Text(
                    'Move task to',
                    style: themeData.textTheme.bodyText2.copyWith(
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...bloc?.state?.listTasks?.map(_buildListNameItem)?.toList()
              ],
            ),
          );
        });
  }

  Widget _buildListNameItem(String listName) {
    final active = state?.listTaskToMove == listName;
    return InkWell(
      onTap: () {
        bloc?.moveTaskTo(listName: listName);
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listName,
              style: themeData.textTheme.subtitle2.copyWith(
                color: (active == true) ? themeData.primaryColor : Colors.black,
              ),
            ),
            if (active == true)
              Icon(
                Icons.check,
                color: themeData.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
