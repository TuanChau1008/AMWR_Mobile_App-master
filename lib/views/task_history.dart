import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../models/task_history_dto.dart';
import '../presenters/task_history_dao.dart';

class taskHistory extends StatefulWidget {
  taskHistory({Key? key}) : super(key: key);

  final history = TaskHistoryDao();

  @override
  State<taskHistory> createState() => _taskHistoryState();
}

class _taskHistoryState extends State<taskHistory> {
  final dataRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task History'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: size.height,
            child: FirebaseAnimatedList(
              query: widget.history.getInfoQuery(),
              itemBuilder: (context, snapshot, animation, index) {
                final json = snapshot.value as Map<dynamic, dynamic>;
                final data = TaskHistory.fromJson(json);
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 5,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                      ),
                    ),
                    title: Text(data.dateTime.toString()),
                    subtitle: Text('Task: ${data.task.toString()} \n' 'Location: ${data.productLocation.toString()}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
