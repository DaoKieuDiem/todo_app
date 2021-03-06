import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/bloc/task_bloc.dart';

class RenameListTaskScreen extends StatefulWidget {
  @override
  _RenameListTaskScreenState createState() => _RenameListTaskScreenState();
}

class _RenameListTaskScreenState extends BaseLayoutState<RenameListTaskScreen,
    HomeScreenBloc, HomeScreenState> {
  ThemeData get themeData => Theme.of(context);
  @override
  HomeScreenBloc get bloc => BlocProvider.of<HomeScreenBloc>(context);
  TaskBloc get taskBloc => bloc?.taskBloc;
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
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
          Icons.close,
          color: Colors.black,
        ),
      ),
      title: Center(
        child: Text(
          'Rename list',
          style: themeData.textTheme.headline5,
        ),
      ),
      actions: [
        Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
            child: InkWell(
              onTap: () {
                taskBloc?.renameList(
                  prevListName: taskBloc?.state?.currentListTasks,
                  newListName: _controller?.text?.trim(),
                );
                Navigator.pop(context);
                // Future.delayed(const Duration(milliseconds: 2000))
                //     .whenComplete(() => Navigator.pop(context));
              },
              child: Text(
                'Done',
                style: themeData.textTheme.subtitle2,
              ),
            ),
          ),
        )
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
      margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 0.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: themeData.dividerColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: _controller..text = taskBloc?.state?.currentListTasks ?? '',
        decoration: const InputDecoration(
          hintText: 'Enter list title',
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
    );
  }
}
