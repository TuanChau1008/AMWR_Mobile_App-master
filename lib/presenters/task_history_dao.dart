import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import '../models/task_history_dto.dart';

class TaskHistoryDao {
  DatabaseReference taskHistory = FirebaseDatabase.instance.ref().child('/task-histories');

  void saveInfo(String datetime, String task, String location) {

    final Map<dynamic, dynamic> body = new Map<dynamic, dynamic>();
    body.clear();
    body['date_time'] = datetime;
    body['task'] = task;
    body['product_location'] = location;

    //TaskHistory history = TaskHistory(dateTime: datetime, task: task, productLocation: location);
    taskHistory.push().set(body);
  }

  Query getInfoQuery() {
    return taskHistory;
  }
}