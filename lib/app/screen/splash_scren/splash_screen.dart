import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc.dart';
import 'package:todo_app/app/base/bloc/base_bloc_state.dart';
import 'package:todo_app/app/base/layout/base_layout.dart';
import 'package:todo_app/app/bloc/home_screen_bloc.dart';
import 'package:todo_app/app/bloc/state/home_screen_state.dart';
import 'package:todo_app/app/screen/home_screen/home_screen.dart';
import 'package:todo_app/common/common_constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState
    extends BaseLayoutState<SplashScreen, BaseBloc, BaseBlocState> {
  @override
  HomeScreenBloc get bloc => BlocProvider.of<HomeScreenBloc>(context);

  bool _timeOut = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).whenComplete(() {
      _timeOut = true;
      _openHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: bloc,
      listener: (context, HomeScreenState state) {
        if (bloc?.taskBloc?.state?.isFetchedData == true) {
          _openHomeScreen();
        }
      },
      child: const SafeArea(
        child: Scaffold(
          body: Center(
            child: Image(
              image: AssetImage(ImageAssetUrl.appIconImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _openHomeScreen() {
    if (_timeOut && bloc?.taskBloc?.state?.isFetchedData == true) {
      _timeOut = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }
}
