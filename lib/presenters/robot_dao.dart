import 'package:firebase_database/firebase_database.dart';
import '../models/robot_dto.dart';

class RobotDao {
  final DatabaseReference robotInfo = FirebaseDatabase.instance.ref().child('/robot-info');

  void saveInfo(Robot robot) {
    robotInfo.push().set(robot.toJson());
  }

  Query getInfoQuery() {
    return robotInfo;
  }
}