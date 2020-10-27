import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';
import 'package:todo_app/app/extension/string.dart';
import 'package:todo_app/common/color_constant.dart';
import 'package:todo_app/common/utils/app_utils.dart';
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

  DateTime get selectedStartDate => homeBloc?.state?.selectedStartDate;
  DateTime get selectedEndDate => homeBloc?.state?.selectedEndDate;
  DateTime _selectedStartDate;
  DateTime _selectedEndDate;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _timeRepeatController =
      TextEditingController(text: '1');

  final TaskEntity task;

  _EditTaskScreenState({this.task});

  bool get done =>
      bloc?.state?.completedTasks?.firstWhere(
          (element) => element?.id == task?.id,
          orElse: () => null) !=
      null;
  String get repeatString {
    String _result;
    if (homeBloc?.state?.timeRepeat == 1) {
      _result =
          'Repeat ${AppUtils.parserTypeRepeat(homeBloc?.state?.typeRepeat, 1)}ly'
          '${(homeBloc?.state?.dayRepeat != null) ? ''
              ' on ${AppUtils.parserDayRepeat(homeBloc?.state?.dayRepeat).inCaps}' : ''}';
    } else {
      _result = 'Repeat every '
          '${homeBloc?.state?.timeRepeat} ${AppUtils.parserTypeRepeat(
        homeBloc?.state?.typeRepeat,
        homeBloc?.state?.timeRepeat,
      )}';
    }
    return _result;
  }

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
    _timeRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_outlined,
          color: Colors.black,
        ),
      ),
      title: Center(
        child: Text(
          'Edit task',
          style: themeData.textTheme.headline5,
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
                            detail:
                                (_detailController?.text?.trim()?.isNotEmpty ==
                                        true)
                                    ? _detailController?.text?.trim()
                                    : task?.detail,
                            startDate: (selectedStartDate != null)
                                ? selectedStartDate
                                : task?.startDate,
                            endDate: (selectedEndDate != null)
                                ? selectedEndDate
                                : task?.endDate,
                            done: done,
                            listName: bloc?.state?.listTaskToMove,
                            repeat: (homeBloc?.state?.repeat == true)
                                ? repeatString
                                : task?.repeat,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
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
                        color: Colors.black,
                      ),
                    ),
                  );
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
          child: InkWell(
            onTap: () {
              bloc?.deleteTask(item: task);
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: themeData.dividerColor,
          height: 1,
        ),
      ),
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
                      return ((task?.startDate == null) &&
                              selectedStartDate == null)
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
                                borderRadius: BorderRadius.circular(30.0),
                                border:
                                    Border.all(color: themeData.dividerColor),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 10.0, 20.0, 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (selectedStartDate != null)
                                        ? ((selectedEndDate == null)
                                            ? DateFormat.yMMMMd('en_US')
                                                .format(selectedStartDate)
                                            : '${DateFormat.yMMMMd('en_US').format(selectedStartDate)}'
                                                '-${DateFormat.yMMMMd('en_US').format(selectedEndDate)}')
                                        : ((task?.endDate == null)
                                            ? DateFormat.yMMMMd('en_US')
                                                .format(task?.startDate)
                                            : '${DateFormat.yMMMMd('en_US').format(task?.startDate)}'
                                                '-${DateFormat.yMMMMd('en_US').format(task?.endDate)}'),
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
          if (task?.repeat != null || homeBloc?.state?.repeat == true)
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10.0, left: 10.0),
                    child: Icon(
                      Icons.repeat_outlined,
                      color: (done == false)
                          ? themeData.primaryColor
                          : themeData.disabledColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (done == false) {
                        _showRepeatBottomSheet(context);
                      }
                    },
                    child: BlocBuilder(
                      cubit: homeBloc,
                      builder: (context, HomeScreenState state) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(color: themeData.dividerColor),
                          ),
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 10.0, 20.0, 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (homeBloc?.state?.repeat == true)
                                    ? repeatString
                                    : task?.repeat,
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
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfDateRangePicker(
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: themeData.textTheme.bodyText1,
                ),
                headerHeight: 80.0,
                initialSelectedDate: now,
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onSelectionChange,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                    child: Icon(
                      Icons.access_time_outlined,
                      color: themeData.disabledColor,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      padding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: themeData.dividerColor,
                      ),
                      child: Text(
                        'Set Time',
                        style: themeData.textTheme.bodyText1,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                      child: Icon(
                        Icons.repeat_outlined,
                        color: themeData.disabledColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _showRepeatBottomSheet(context);
                      },
                      child: Text(
                        'Repeat',
                        style: themeData.textTheme.bodyText1.copyWith(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.bodyText1,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        homeBloc?.pickDate(
                          selectedEndDate: _selectedEndDate,
                          selectedStartDate: _selectedStartDate,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: themeData.textTheme.bodyText1.copyWith(
                          color: themeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _onSelectionChange(DateRangePickerSelectionChangedArgs args) {
    _selectedStartDate = args.value.startDate;
    if (args.value.endDate != null) {
      _selectedEndDate = args.value.endDate;
    } else {
      _selectedEndDate = args.value.startDate;
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

  final _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  void _showRepeatBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'Every',
                        style: themeData.textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: kLightWhiteGrey,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      width: 50.0,
                      child: TextField(
                        controller: _timeRepeatController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: kLightWhiteGrey,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          onChanged: (value) {},
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Day'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('Week'),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('Month'),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text('Year'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ..._days.map(_buildDateItem).toList(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Start',
                      style: themeData.textTheme.subtitle2,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10.0),
                        // padding:
                        //    const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kLightWhiteGrey,
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${DateFormat.yMMMMd('en_us').format(
                                DateTime.now(),
                              )}',
                              style: themeData.textTheme.button.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'First occurrence will be'
                    ' ${DateFormat.yMMMMd('en_us').format(
                      DateTime.now(),
                    )}',
                    style: themeData.textTheme.bodyText2.copyWith(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                // padding:
                //    const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: kLightWhiteGrey,
                ),
                child: TextButton(
                  onPressed: () {},
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Set Time',
                      style: themeData.textTheme.button.copyWith(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.button,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // bloc?.pickDate(
                        //   selectedEndDate: _selectedEndDate,
                        //   selectedStartDate: _selectedStartDate,
                        // );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: themeData.textTheme.button.copyWith(
                          color: themeData.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildDateItem(String content) {
    return Container(
      height: 50.0,
      width: 50.0,
      child: Card(
        elevation: 1.0,
        color: kLightWhiteGrey,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        //clipBehavior: Clip.antiAlias,
        child: Center(
          child: Text(
            content,
            style: themeData.textTheme.subtitle2,
          ),
        ),
      ),
    );
  }
}
