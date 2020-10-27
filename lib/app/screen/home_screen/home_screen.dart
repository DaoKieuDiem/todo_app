import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/state/task_state.dart';
import 'package:todo_app/app/extension/string.dart';
import 'package:todo_app/app/screen/all_list_screen/all_task_screen.dart';
import 'package:todo_app/app/screen/complete_screen/complete_task_screen.dart';
import 'package:todo_app/app/screen/incomplete_screen/incomplete_task_screen.dart';
import 'package:todo_app/app/screen/list_tasks_screen/add_list_tasks_screen.dart';
import 'package:todo_app/app/screen/list_tasks_screen/rename_list_tasks_screen.dart';
import 'package:todo_app/common/color_constant.dart';
import 'package:todo_app/common/common_constant.dart';
import 'package:todo_app/common/foundation.dart';
import 'package:todo_app/common/utils/app_utils.dart';
import 'package:todo_app/domain/entities/task_entity.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState
    extends BaseLayoutState<HomeScreen, HomeScreenBloc, HomeScreenState> {
  CupertinoTabController _controller;
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDetailController = TextEditingController();
  final TextEditingController _timeRepeatController =
      TextEditingController(text: '1');
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  DateTime time = DateTime.now();

  int get currentIndex => state?.currentIndex;

  DateTime get selectedStartDate => state?.selectedStartDate;
  DateTime get selectedEndDate => state?.selectedEndDate;
  DateTime _selectedStartDate;
  DateTime _selectedEndDate;
  bool get isExpand => state?.expandDetailField;

  ThemeData get themeData => Theme.of(context);

  String get listName => bloc?.taskBloc?.state?.currentListTasks;

  List<String> get listTasks => bloc?.taskBloc?.state?.listTasks;

  List<TaskEntity> get completedTasks => bloc?.taskBloc?.state?.completedTasks;

  List<TaskEntity> get uncompletedTasks =>
      bloc?.taskBloc?.state?.uncompletedTasks;

  int get totalTasks {
    return (completedTasks?.length ?? 0) + (uncompletedTasks?.length ?? 0);
  }

  List<int> get _daysInMonth {
    List<int> _result;
    for (var i = 1; i < 32; i++) {
      _result.add(i);
    }
    return _result;
  }

  String get startEndDate {
    if (selectedEndDate == null) {
      return '${DateFormat.yMMMMd('en_US').format(selectedStartDate)},'
          '${DateFormat.Hm().format(selectedStartDate)}';
    }
    return '${DateFormat.yMMMMd('en_US').format(selectedStartDate)}'
        '-${DateFormat.yMMMMd('en_US').format(selectedEndDate)}';
  }

  String get repeatString {
    String _result;
    if (state?.timeRepeat == 1) {
      _result = 'Repeat ${AppUtils.parserTypeRepeat(state?.typeRepeat, 1)}ly'
          '${(state?.dayRepeat != null) ? ''
              ' on ${AppUtils.parserDayRepeat(state?.dayRepeat).inCaps}' : ''}';
    } else {
      _result = 'Repeat every '
          '${state?.timeRepeat} ${AppUtils.parserTypeRepeat(
        state?.typeRepeat,
        state?.timeRepeat,
      )}';
    }
    return _result;
  }

  @override
  HomeScreenBloc get bloc => BlocProvider.of<HomeScreenBloc>(context);

  @override
  void dispose() {
    _controller.dispose();
    _taskTitleController.dispose();
    _taskDetailController.dispose();
    _timeRepeatController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CupertinoTabController(initialIndex: 0);
  }

  List<Widget> tabs = [
    AllTaskScreen(),
    CompletedTaskScreen(),
    UncompletedTaskScreen(),
  ];

  @override
  Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      title: BlocBuilder(
        cubit: bloc?.taskBloc,
        builder: (context, TaskState state) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              listName,
              style:
                  themeData.textTheme.headline5.copyWith(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: buildAppBar(context),
          body: BlocBuilder(
            cubit: bloc,
            builder: (context, HomeScreenState state) {
              if (state?.isLoading == true) {
                return buildLoading(context);
              }
              return buildContent(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return isIos
        ? CupertinoTabScaffold(
            resizeToAvoidBottomInset: true,
            controller: _controller,
            tabBar: CupertinoTabBar(
              onTap: (int v) {
                bloc?.getCurrentIndex(currentIndex: _controller.index);
              },
              items: [
                BottomNavigationBarItem(
                  label: '',
                  icon: FlatButton(
                    onPressed: () {
                      _settingModalBottomSheet(context);
                    },
                    child: Icon(
                      Icons.dehaze_outlined,
                      color: (currentIndex == 0)
                          ? themeData.primaryColor
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.all_inclusive_rounded,
                    title: BottomNavigationBarTitle.allTasks,
                    isActive: currentIndex == 1,
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.event_available_outlined,
                    title: BottomNavigationBarTitle.completedTask,
                    isActive: currentIndex == 2,
                  ),
                ),
                _buildBottomMenu(
                  context,
                  MyBottomMenuItem(
                    iconData: Icons.event_note_outlined,
                    title: BottomNavigationBarTitle.uncompletedTask,
                    isActive: currentIndex == 3,
                  ),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: FlatButton(
                    onPressed: () {
                      _commandModalBottomSheet(context);
                    },
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: (currentIndex == 4)
                          ? themeData.primaryColor
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            tabBuilder: (context, index) {
              if (index > 0 && index < 4) {
                return tabs[index - 1];
              }
              return tabs[currentIndex];
            },
          )
        : Scaffold(
            body: changeTab(currentIndex),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (int index) {
                  bloc?.getCurrentIndex(currentIndex: index);
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: SizedBox(
                      width: 80.0,
                      child: FlatButton(
                        onPressed: () {
                          _settingModalBottomSheet(context);
                        },
                        child: Icon(
                          Icons.dehaze_outlined,
                          color: (currentIndex == 0)
                              ? themeData.primaryColor
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.all_inclusive_rounded,
                      title: BottomNavigationBarTitle.allTasks,
                      isActive: currentIndex == 1,
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.event_available_outlined,
                      title: BottomNavigationBarTitle.completedTask,
                      isActive: currentIndex == 2,
                    ),
                  ),
                  _buildBottomMenu(
                    context,
                    MyBottomMenuItem(
                      iconData: Icons.event_note_outlined,
                      title: BottomNavigationBarTitle.uncompletedTask,
                      isActive: currentIndex == 3,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: FlatButton(
                      onPressed: () {
                        _commandModalBottomSheet(context);
                      },
                      child: Icon(
                        Icons.more_vert_outlined,
                        color: (currentIndex == 4)
                            ? themeData.primaryColor
                            : Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget changeTab(int index) {
    return Stack(children: [
      (index > 0 && index < 4) ? tabs[index - 1] : tabs[currentIndex],
      Positioned(
        bottom: 30.0,
        right: 30.0,
        child: FloatingActionButton(
          backgroundColor: themeData.primaryColor,
          onPressed: () {
            bloc?.reset();
            _addNewTaskModalBottomSheet(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    ]);
  }

  BottomNavigationBarItem _buildBottomMenu(
      BuildContext context, MyBottomMenuItem item) {
    return BottomNavigationBarItem(
      icon: Icon(
        item.iconData,
        color: Colors.black.withOpacity(0.5),
      ),
      activeIcon: Icon(
        item.iconData,
        color: themeData.primaryColor,
      ),
      label: item.title,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                title: const Text(
                  AlertContentString.alertTitle,
                ),
                content: const Text(AlertContentString.alertContent),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      AlertContentString.no,
                      style: TextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      AlertContentString.yes,
                      style: TextStyle(
                        color: themeData.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            })) ??
        false;
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return BlocBuilder(
              cubit: bloc?.taskBloc,
              builder: (context, TaskState state) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      _buildSectionUser(context),
                      if (listTasks?.isNotEmpty == true)
                        _buildSectionTaskList(context),
                      _buildBottomSheetItemMenu(Icons.add, 'Create new list'),
                    ],
                  ),
                );
              });
        });
  }

  void _commandModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                if (listName != defaultList)
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RenameListTaskScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      child: Text(
                        'Rename List',
                        style: themeData.textTheme.subtitle1,
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    if (listName != defaultList) {
                      Navigator.pop(context);
                      if (completedTasks?.isEmpty == true &&
                          uncompletedTasks?.isEmpty == true) {
                        bloc?.taskBloc?.deleteList(listName: listName);
                      } else {
                        _showDeleteListAlert();
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0,
                        (listName != defaultList) ? 10.0 : 20.0, 20.0, 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete List',
                          style: themeData.textTheme.subtitle1.copyWith(
                            color: (listName == defaultList)
                                ? Colors.black.withOpacity(0.5)
                                : Colors.black,
                          ),
                        ),
                        if (listName == defaultList)
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'The Default list can not delete',
                              style: themeData.textTheme.subtitle2.copyWith(
                                color: Colors.black.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (completedTasks?.isNotEmpty == true) {
                      Navigator.pop(context);
                      _showDeleteCompleteAlert();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: Text(
                      'Delete all complete tasks',
                      style: themeData.textTheme.subtitle1.copyWith(
                        color: (completedTasks?.isEmpty == true)
                            ? Colors.black.withOpacity(0.5)
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSectionUser(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 18.0,
            child: Image(
              height: 40.0,
              width: 40.0,
              image: AssetImage(ImageAssetUrl.avatarImage),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10.0),
          Text(
            'Diem Dao',
            style: themeData.textTheme.subtitle1,
          )
        ],
      ),
    );
  }

  void _addNewTaskModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return AnimatedPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: BlocBuilder(
              cubit: bloc,
              builder: (context, HomeScreenState state) {
                return Wrap(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                      child: TextField(
                        controller: _taskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'New Task',
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
                        autofocus: true,
                      ),
                    ),
                    if (isExpand == true)
                      Container(
                        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 8.0),
                        child: TextField(
                          controller: _taskDetailController,
                          decoration: const InputDecoration(
                            hintText: 'Add detail',
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
                          autofocus: true,
                        ),
                      ),
                    if (selectedStartDate != null && state?.repeat == false)
                      InkWell(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: FittedBox(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: themeData.dividerColor),
                            ),
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 10.0),
                            child: Row(
                              children: [
                                Text(startEndDate),
                                Container(
                                  margin: const EdgeInsets.only(left: 5.0),
                                  child: InkWell(
                                    onTap: () {
                                      bloc?.reset();
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
                          ),
                        ),
                      ),
                    if (state?.repeat == true)
                      InkWell(
                        onTap: () {
                          _showRepeatBottomSheet(context);
                        },
                        child: BlocBuilder(
                          cubit: bloc,
                          builder: (context, HomeScreenState state) {
                            return FittedBox(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border:
                                      Border.all(color: themeData.dividerColor),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 10.0, 10.0, 10.0),
                                child: Row(
                                  children: [
                                    Text(repeatString),
                                    Container(
                                      margin: const EdgeInsets.only(left: 5.0),
                                      child: InkWell(
                                        onTap: () {
                                          bloc?.reset();
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
                              ),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 30.0, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  bloc?.expandDetailField(isExpand: true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.notes_outlined,
                                    color: themeData.primaryColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.event_available_outlined,
                                    color: themeData.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              bloc?.taskBloc?.addNewTask(
                                item: TaskEntity(
                                  task: _taskTitleController?.text?.trim(),
                                  detail: _taskDetailController?.text?.trim(),
                                  startDate: (selectedStartDate != null)
                                      ? selectedStartDate
                                      : null,
                                  endDate: (selectedEndDate != null)
                                      ? selectedEndDate
                                      : null,
                                  listName: listName,
                                  repeat: (state?.repeat == true)
                                      ? 'Repeat every ${bloc?.state?.timeRepeat} '
                                          '${AppUtils.parserTypeRepeat(
                                          state?.typeRepeat,
                                          state?.timeRepeat,
                                        )} '
                                          ' on${AppUtils.parserDayRepeat(
                                          state?.dayRepeat,
                                        )}'
                                      : null,
                                ),
                              );
                              _taskTitleController?.clear();
                              _taskDetailController?.clear();
                              bloc?.reset();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Save',
                              style: themeData.textTheme.subtitle1.copyWith(
                                color: _taskTitleController?.value?.text
                                            ?.trim()
                                            ?.isNotEmpty ==
                                        true
                                    ? themeData.primaryColor
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    await showModalBottomSheet(
        isScrollControlled: true,
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
                    child: InkWell(
                      onTap: () {
                        _showSetTimeBottomSheet(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kLightWhiteGrey,
                        ),
                        child: Text(
                          (selectedStartDate != null)
                              ? DateFormat.Hm().format(selectedStartDate)
                              : 'Set Time',
                          style: themeData.textTheme.bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
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
                        Navigator.pop(context);
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
                        final _result = DateTime(
                          _selectedStartDate?.year,
                          _selectedStartDate?.month,
                          _selectedStartDate?.day,
                          selectedStartDate?.hour ?? 00,
                          selectedStartDate?.minute ?? 00,
                        );
                        bloc?.pickDate(
                          selectedEndDate: _selectedEndDate,
                          selectedStartDate: _result,
                        );
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

  void _onSelectionChange(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _selectedStartDate = args.value.startDate;
      _selectedEndDate = args.value.endDate;
    } else if (args.value is DateTime) {
      _selectedStartDate = args.value;
      _selectedEndDate = null;
    }
    var _result = DateTime(
      _selectedStartDate?.year,
      _selectedStartDate?.month,
      _selectedStartDate?.day,
      selectedStartDate?.hour ?? 00,
      selectedStartDate?.minute ?? 00,
    );
    bloc?.pickDate(
      selectedStartDate: _result,
      selectedEndDate: _selectedEndDate,
    );
  }

  Widget _buildSectionTaskList(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor,
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          ...listTasks.map((e) => _buildTaskListItem(context, e)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(context, String title) {
    final isActive = listName == title;
    return InkWell(
      onTap: () {
        bloc?.taskBloc?.fetchData(listName: title);
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: (isActive == true)
            ? BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              )
            : const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.fromLTRB(60.0, 20.0, 10.0, 20.0),
        child: Text(
          title,
          style: themeData.textTheme.bodyText2,
        ),
      ),
    );
  }

  Widget _buildBottomSheetItemMenu(IconData icon, String title) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateListTaskScreen(),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: themeData.dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10.0),
            Text(
              title,
              style: themeData.textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteListAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: const Text(
              AlertContentString.deleteListTitle,
            ),
            content: Text(
              '${AlertContentString.deleteListContent} $totalTasks '
              '${(totalTasks == 1) ? 'task' : 'tasks'}',
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AlertContentString.cancel,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  bloc?.taskBloc?.deleteList(listName: listName);
                  Navigator.pop(context);
                },
                child: Text(
                  AlertContentString.delete,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showDeleteCompleteAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: const Text(
              AlertContentString.alertTitle,
            ),
            content: const Text(
              '${AlertContentString.deleteTasksContent} ',
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AlertContentString.cancel,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (completedTasks?.isNotEmpty == true) {
                    bloc?.taskBloc?.deleteAllTask(done: true);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  AlertContentString.delete,
                  style: TextStyle(
                    color: themeData.primaryColor,
                  ),
                ),
              ),
            ],
          );
        });
  }

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
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      padding: const EdgeInsets.only(left: 8.0),
                      decoration: BoxDecoration(
                        color: kLightWhiteGrey,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: state?.typeRepeat,
                          onChanged: (value) {
                            bloc?.chooseTypeRepeat(typeRepeat: value);
                          },
                          items: [
                            DropdownMenuItem(
                              value: TypeRepeat.day,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.day,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.week,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.week,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.month,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.month,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: TypeRepeat.year,
                              child: Text(
                                AppUtils.parserTypeRepeat(
                                  TypeRepeat.year,
                                  int.parse(_timeRepeatController.text.trim()),
                                ),
                              ),
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
                    ...DayRepeat.values.map(_buildDateItem).toList(),
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
                          onPressed: () {
                            _showStartDatePicker(context);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              (selectedStartDate != null)
                                  ? DateFormat.yMMMMd('en_us')
                                      .format(selectedStartDate)
                                  : '${DateFormat.yMMMMd('en_us').format(
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
                  onPressed: () {
                    _showSetTimeBottomSheet(context);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (selectedStartDate != null)
                          ? DateFormat.Hm().format(selectedStartDate)
                          : 'Set Time',
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
                        bloc?.reset();
                        //Navigator.of(context, rootNavigator: false).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: themeData.textTheme.button,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        bloc?.acceptRepeat(
                          timeRepeat: int.parse(
                            _timeRepeatController.text.trim(),
                          ),
                        );
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

  Widget _buildDateItem(DayRepeat content) {
    var _isSelected = state?.dayRepeat == content;
    return Container(
      height: 50.0,
      width: 50.0,
      child: InkWell(
        onTap: () {
          bloc?.chooseDayRepeat(dayRepeat: content);
        },
        child: Card(
          elevation: 1.0,
          color:
              (_isSelected == true) ? themeData.primaryColor : kLightWhiteGrey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          //clipBehavior: Clip.antiAlias,
          child: Center(
            child: Text(
              AppUtils.standForDayRepeat(content),
              style: themeData.textTheme.subtitle2.copyWith(
                color: (_isSelected == true) ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStartDatePicker(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
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
                initialSelectedDate: (_selectedStartDate != null)
                    ? _selectedStartDate
                    : DateTime.now(),
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: _onSelectionChange,
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
                        final _result = DateTime(
                          _selectedStartDate?.year ?? selectedStartDate?.year,
                          _selectedStartDate?.month ?? selectedStartDate?.month,
                          _selectedStartDate?.day ?? selectedStartDate?.day,
                          selectedStartDate?.hour,
                          selectedStartDate.minute,
                        );
                        bloc?.pickDate(
                          selectedStartDate: _result,
                        );
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

  void _showSetTimeBottomSheet(BuildContext context) {
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
              height: MediaQuery.of(context).copyWith().size.height / 4,
              margin: const EdgeInsets.only(top: 20.0),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: time,
                onDateTimeChanged: (DateTime value) {
                  time = value;
                },
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
                    },
                    child: Text(
                      'Cancel',
                      style: themeData.textTheme.button,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final _result = DateTime(
                        selectedStartDate?.year ?? time?.year,
                        selectedStartDate?.month ?? time?.month,
                        selectedStartDate?.day ?? time?.day,
                        time?.hour ?? 00,
                        time?.minute ?? 00,
                      );
                      bloc?.pickDate(
                        selectedStartDate: _result,
                      );
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
      },
    );
  }

  Widget _buildMonthRepeat() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Container(
                  child: DropdownButton(
                    items: [
                      ..._daysInMonth
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('Day $e'),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Container(
                  child: DropdownButton(
                    items: [
                      ..._daysInMonth
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('Day $e'),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                Container(
                  child: DropdownButton(
                    items: [
                      DropdownMenuItem(
                        value: OrdinalNumbers.first,
                        child: Text(
                          AppUtils.parserOrdinalNumbers(OrdinalNumbers.first),
                        ),
                      ),
                      DropdownMenuItem(
                        value: OrdinalNumbers.second,
                        child: Text(
                          AppUtils.parserOrdinalNumbers(OrdinalNumbers.second),
                        ),
                      ),
                      DropdownMenuItem(
                        value: OrdinalNumbers.third,
                        child: Text(
                          AppUtils.parserOrdinalNumbers(OrdinalNumbers.third),
                        ),
                      ),
                      DropdownMenuItem(
                        value: OrdinalNumbers.fourth,
                        child: Text(
                          AppUtils.parserOrdinalNumbers(OrdinalNumbers.fourth),
                        ),
                      ),
                      DropdownMenuItem(
                        value: OrdinalNumbers.last,
                        child: Text(
                          AppUtils.parserOrdinalNumbers(OrdinalNumbers.last),
                        ),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                Container(
                  child: DropdownButton(
                    items: [
                      ..._daysInMonth
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('Day $e'),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyBottomMenuItem {
  IconData iconData;
  String title;
  bool isActive;

  MyBottomMenuItem({
    this.iconData,
    this.title,
    this.isActive,
  });
}
