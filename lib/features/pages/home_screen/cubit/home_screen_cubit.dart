import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_house_parent/features/pages/home_screen/cubit/home_screen_states.dart';

class HomeScreenCubit extends Cubit<HomeStates>{
  HomeScreenCubit():super(HomeInitialState());

  int selectedIndex=0;
  List<Widget> bodyList=[
  ];
}