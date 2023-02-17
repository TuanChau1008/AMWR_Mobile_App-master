import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import '../models/robot_dto.dart';
import '../presenters/robot_dao.dart';

class RobotInfo extends StatefulWidget {
  RobotInfo({Key? key}) : super(key: key);

  final robotDao = RobotDao();

  @override
  State<RobotInfo> createState() => _RobotInfoState();
}

class _RobotInfoState extends State<RobotInfo> {

  // void addNewRobot() {
  //   final newRobot = Robot(1, 'AWMR-Robot', 'Online');
  //   widget.robotDao.saveInfo(newRobot);
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Information'),
        backgroundColor: Colors.orange,
        // actions: [
        //   TextButton(onPressed: () {addNewRobot();}, child: Text("Add"))
        // ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1,
          child: FirebaseAnimatedList(
            query: widget.robotDao.getInfoQuery(),
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final data = Robot.fromJson(json);
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 5,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                    ),
                  ),
                  title: Text(data.name.toString()),
                  subtitle: Text('Id: ${data.id.toString()} \n' 'Status: ${data.status.toString()}' ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
