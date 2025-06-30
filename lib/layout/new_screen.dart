import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../component/component.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New tasks'),
        ),
        body: BlocListener<MainScreenCubit, TodoStates>(
    listener: (context, state) {
    if (state is InsertDatabaseState) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: const Text('Task added successfully',
        style: TextStyle( fontSize:15, color: Colors.blue)),
      backgroundColor: Colors.grey[400],
    )
    );
    }
    },
    child: BlocBuilder<MainScreenCubit, TodoStates>(
            // rebuild only when DB is loaded or a row is inserted
            buildWhen: (prev, curr) =>
                curr is GetDatabaseSuccessState || curr is InsertDatabaseState,
            builder: (context, state) {
              final tasks = MainScreenCubit.of(context).allTasks;

              if (tasks.isEmpty) {
                return _buildNoTasksMessage();
              }


              return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(left: 25, right: 10),
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                  itemBuilder: (context, i) {
                    final t = tasks[i];
                    return Dismissible(
                      key: ValueKey<int>(t['id']),                    // 1. unique key
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      // 2. delete first, then return true so Dismissible can animate away
                      confirmDismiss: (direction) async {
                        final cubit = MainScreenCubit.of(context);

                        // remove it from SQLite *and* from the in‑memory list
                        await cubit.deleteTask(t['id']);              // ← your method refreshes lists + emits

                        // optional toast
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Task deleted',  style: TextStyle( fontSize:18, color: Colors.blue)),
                            backgroundColor: Colors.grey[400])
                        );

                        return true;                                  // tell Dismissible to finish removal
                      },


                      child: Card(
                          color: Colors.blue[50],
                          elevation: 3,                                        // optional shadow
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                                leading: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.lightBlueAccent,
                                    ),
                                    Text(t['time'],
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t['title']),
                                    const SizedBox(height: 5),
                                    Text(t['date'],
                                        style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        t['status'] == 'archived'
                                            ? Icons.archive
                                            : Icons.archive_outlined,
                                        color: t['status'] == 'archived'
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        final newStatus = t['status'] == 'archived'
                                            ? 'new'
                                            : 'archived';
                                        MainScreenCubit.of(context)
                                            .changeTaskStatus(
                                          id: t['id'],
                                          newStatus: newStatus,
                                        );
                                      },
                                    ),
                                    Checkbox(
                                      value: t['status'] == 'done',
                                      onChanged: (_) {
                                        final newStatus =
                                            t['status'] == 'done' ? 'new' : 'done';
                                        MainScreenCubit.of(context)
                                            .changeTaskStatus(
                                          id: t['id'],
                                          newStatus: newStatus,
                                        );
                                      },
                                    ),
                                  ],
                                )),
                          )),
                    );
                  });
            })
    ));
  }
}

// Widget to display when there are no tasks
Widget _buildNoTasksMessage() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.task_alt, size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          "No tasks available!",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(height: 10),
        Text("Add New Task",style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
      ],
    ),
  );
}
