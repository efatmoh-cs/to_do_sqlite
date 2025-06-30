import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../component/component.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainScreenCubit, TodoStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = MainScreenCubit.of(context);

        return Scaffold(
          floatingActionButton:  SpeedDial(
            heroTag: "New Task",
            animatedIcon: AnimatedIcons.add_event,
            animatedIconTheme: IconThemeData(color: Colors.white),

        spacing: 10,
        overlayColor: Colors.blueGrey.shade200,
        overlayOpacity: 0.5,
        elevation: 2,
            backgroundColor: Colors.lightBlueAccent,
            // child: Icon(Icons.add, color: Colors.white),
            children: [
              SpeedDialChild(
                child: Icon(Icons.task, color: Colors.blue),
                label: "Add Task",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => AddTaskBottomSheet(cubit: cubit),
                  );
                },

              ),
            ],


          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar:
        Padding(
        padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 10,        // ⬅ leaves room to show the bottom curve
        ),
        child: Material(
        elevation: 7,
        borderRadius: BorderRadius.circular(20),  // 🔄 all corners
        clipBehavior: Clip.antiAlias,
        child:
          BottomNavigationBar(

            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'New'),
              BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Done'),
              BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archived'),
            ],
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeBottomIndex(index);
            },
          ),
        )  ));
      },
    );


  }
}