import 'package:firebase_database/firebase_database.dart';
import '../models/operation_dto.dart';

class OperationDao {
  final DatabaseReference currentOperation = FirebaseDatabase.instance.ref().child("/current_operation");

  void addNewOperation(Operation operation) {
    currentOperation.child("/data").set(operation.toJson());
  }

  void updateOperation(String currentTask, String taskProgress) {
    currentOperation.child("/data").update({
      "current_task" : currentTask,
      "task_progress" : taskProgress
    });
  }

  Query getInfoQuery() {
    return currentOperation;
  }
}