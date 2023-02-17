class Operation {
  String? currentTask;
  String? taskProgress;

  Operation(this.currentTask, this.taskProgress);

  Operation.fromJson(Map<dynamic, dynamic> json) {
    currentTask = json['current_task'];
    taskProgress = json['task_progress'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['current_task'] = currentTask;
    data['task_progress'] = taskProgress;
    return data;
  }
}