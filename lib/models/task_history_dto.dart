class TaskHistory {
  late final String dateTime;
  late final String task;
  late final String productLocation;

  //TaskHistory( this.dateTime, this.task, this.productLocation);
  TaskHistory({required this.dateTime,required this.task, required this.productLocation});

  factory TaskHistory.fromJson(Map<dynamic, dynamic> json) {
    return TaskHistory(
        dateTime: json['date_time'] as String,
        task: json['task'] as String,
        productLocation: json['product_location'] as String,
    );
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['date_time'] = dateTime;
    data['task'] = task;
    data['product_location'] = productLocation;
    return data;
  }



}