import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../cubit/cubit.dart';
import 'package:intl/intl.dart';


class AddTaskBottomSheet extends StatefulWidget {
  final MainScreenCubit cubit;

  AddTaskBottomSheet({required this.cubit});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  void _pickTime(BuildContext ctx) async {
    TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked; //  Assign TimeOfDay directly
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Prevents keyboard overlap
        left: 20,
        right: 20,
        top: 25,
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            /////////////////TITLE
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightBlueAccent),
              child: TextField(

                controller: titleController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  labelText: 'Task Title',

                ),
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus(); // 🔽 hides the keyboard
                },
              ),
            ),
            SizedBox(height: 16),
            /////////////////////TIME
            Container(
              width: double.infinity,
              decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightBlueAccent),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.lightBlueAccent, // Button background color
                      foregroundColor: Colors.white, // Text color
                      // elevation: 5, // Shadow effect
                    ),
                    onPressed: () => _pickTime(context),
                    child: Text("Pick Time"),
                  ),
                  SizedBox(width: 100),
                  Text(selectedTime != null
                      ? selectedTime!
                          .format(context) // ✅ Converts to "HH:mm AM/PM" format
                      : "No Time Selected"),


                  SizedBox(width: 15),
                  const Icon(
                    Icons.punch_clock,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            SizedBox(height: 17),
            ////////////////////DATE//////////////
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightBlueAccent),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.lightBlueAccent, // Button background color
                      foregroundColor: Colors.white, // Text color
                      // elevation: 5, // Shadow effect
                    ),
                    onPressed: () => _pickDate(context),
                    child: Text("Pick Date"),
                  ),
                  SizedBox(width: 100),
                  Text(
                    selectedDate != null
                        ? " ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                        : "Pick Due Date",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 25),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            SizedBox(height: 26),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.lightBlueAccent, // Button background color
                foregroundColor: Colors.white, // Text color
                // elevation: 5, // Shadow effect
              ),
              onPressed: () {

                if (titleController.text.trim().isEmpty ||
                    selectedDate == null ||
                    selectedTime == null) {
                  _showSnack(context, 'Please enter title, date, and time');
                  return;
                }

                // Format date & time
                final dateString =
                    '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}';
                final timeString = selectedTime!.format(context);

                // Insert
                MainScreenCubit.of(context).insertTask(
                  title: titleController.text.trim(),
                  date:  dateString,
                  time:  timeString,
                );

                // Close sheet
                Navigator.pop(context);
              },
              child: const Text('Add Task'),
            ),

          ],
        ),
      ),
    );
  }
}

void _showSnack(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(msg)),
  );
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(height: 10),


        Text("Add New Task"),


      ],
    ),
  );
}