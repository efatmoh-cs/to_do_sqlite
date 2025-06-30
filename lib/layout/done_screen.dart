import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../component/component.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Done tasks')),
      body: BlocBuilder<MainScreenCubit, TodoStates>(
        // Rebuild whenever the cubit refreshes its lists
        builder: (context, state) {
          final tasks = MainScreenCubit.of(context).doneTasks;

          if (tasks.isEmpty) {
            return const Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No completed tasks!",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),


                  ],
                ),

            );
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
            itemBuilder: (ctx, i) {
              final t = tasks[i];
              return Dismissible(
                key: ValueKey<int>(t['id']), // 1. unique key
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
                  await cubit.deleteTask(
                      t['id']); // ← your method refreshes lists + emits

                  // optional toast
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                        content: Text(
                      'Task deleted',
                            style: TextStyle( fontSize:18, color: Colors.blue)),
                         backgroundColor: Colors.grey[400])


                  );

                  return true; // tell Dismissible to finish removal
                },

                child: Card(
                  color: Colors.blue[50],
                  elevation: 3, // optional shadow
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle,
                          color: Colors.deepPurple),
                      title: Text(t['title'],
                          style: const TextStyle(fontSize: 20)),
                      subtitle: Text('${t['date']} • ${t['time']}',
                          style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
