class Robot {
  int? id;
  String? name;
  String? status;

  Robot(this.id, this.name, this.status);

  Robot.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'] as int;
    name = json['name'] as String;
    status = json['status'] as String;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    return data;
  }
}
