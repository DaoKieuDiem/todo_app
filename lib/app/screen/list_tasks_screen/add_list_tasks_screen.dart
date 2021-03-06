import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';

class CreateListTaskScreen extends StatefulWidget {
  @override
  _CreateListTaskScreenState createState() => _CreateListTaskScreenState();
}

class _CreateListTaskScreenState extends BaseLayoutState<CreateListTaskScreen,
    HomeScreenBloc, HomeScreenState> {
  ThemeData get themeData => Theme.of(context);
  @override
  HomeScreenBloc get bloc => BlocProvider.of<HomeScreenBloc>(context);
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
          'Create new list',
          style: themeData.textTheme.headline5,
        ),
      ),
      actions: [
        Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
            child: InkWell(
              onTap: () {
                bloc?.taskBloc
                    ?.createListTask(listName: _controller.text.trim());
                bloc?.getCurrentIndex(currentIndex: 1);
                Navigator.pop(context);
              },
              child: Text(
                'Done',
                style: themeData.textTheme.subtitle2,
              ),
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
      margin: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 0.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: themeData.dividerColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: _controller,
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
