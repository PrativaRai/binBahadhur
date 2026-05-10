import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final dynamic task;
  final String buttonText;
  final VoidCallback onBtnPressed;

  const ScheduleCard({
    super.key,
    required this.task,
    required this.buttonText,
    required this.onBtnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text("${task['area']} - ${task['subArea']}"),
        subtitle: Text("Type: ${task['scheduleType']}"),
        trailing: ElevatedButton(
          onPressed: onBtnPressed,
          child: Text(buttonText),
        ),
      ),
    );
  }
}
