import 'package:flutter/material.dart';
import 'package:flutter_task_manager_app/controllers/task_controller.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:get/get.dart';

class TaskList extends StatelessWidget {
  final TaskController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: controller.tasks.length,
        itemBuilder: (context, index) {
          final task = controller.tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.status),
            onTap: () {
              // Show a dialog or options to change status
              _showStatusChangeDialog(context, task);
            },
          );
        },
      );
    });
  }

  void _showStatusChangeDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Task Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                onTap: () {
                  controller.updateTaskStatus(task.id, 'Pending');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('In Progress'),
                onTap: () {
                  controller.updateTaskStatus(task.id, 'In Progress');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Complete'),
                onTap: () {
                  controller.updateTaskStatus(task.id, 'Complete');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}