import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../models/operation_dto.dart';
import '../models/task_history_dto.dart';
import '../presenters/operation_dao.dart';
import '../presenters/robot_dao.dart';
import '../presenters/task_history_dao.dart';

final locationList = ['None', '1A', '1B', '2A', '2B'];
final taskList = ['None', 'pickup', 'drop off'];

class Monitor extends StatefulWidget {
  String imageUrl = '';

  Monitor({Key? key, required this.imageUrl}) : super(key: key);
  TaskHistoryDao taskHistoryDao = TaskHistoryDao();
  final robotDao = RobotDao();
  final operationDao = OperationDao();

  @override
  State<Monitor> createState() => MonitorState();
}

class MonitorState extends State<Monitor> {
  final newTask = FirebaseDatabase.instance.ref("/auto-control");
  final operateMode = FirebaseDatabase.instance.ref("/operate-mode");
  final taskProgressIns = FirebaseDatabase.instance.ref("/current_operation/data/task_progress");

  Stream? taskProgressStream;

  VlcPlayerController? _videoPlayerController;

  String currentTime = DateFormat("dd-MM-yyyy, HH:mm").format(DateTime.now());
  String locationValue = locationList.first;
  String taskValue = taskList.first;

  String? currentTask = "...";
  String? taskProgress = "...";
  Timer? timer;
  List<TaskHistory> listHistory = <TaskHistory>[];

  @override
  void initState() {
    super.initState();
    operateMode.update({
      "mode": "auto_control",
    });
    listHistory.clear();

    //listenStream();

    // Initialize current operation with default value ()
    widget.operationDao.updateOperation(currentTask!, taskProgress!);
    setState(() {
      _videoPlayerController = VlcPlayerController.network(
        'http://192.168.43.98:81/stream',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    operateMode.update({
      "mode": "exit_mode",
    });
    // empty task
    emptyTask();
    // Update current operation with default value ()
    widget.operationDao.updateOperation("", "");

    // Stop render video stream
    _videoPlayerController!.stopRendererScanning();
    _videoPlayerController!.dispose();
  }
  
  loadImage() async{
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Image');
    Reference referenceImageToDownload = referenceDirImages.child('map.png');
    widget.imageUrl = await referenceImageToDownload.getDownloadURL();

  }

  bool canSendTask() {
    if (locationValue == "None" || taskValue == "None") {
      return false;
    }
    return true;
  }

  void updateOp(String task, String location) {
    if (task == "pickup") {
      currentTask = "Picking product at: $location";
    }
    if (task == "drop off") {
      currentTask = "Dropping product at: $location";
    }

    taskProgress = "In progress...";

    widget.operationDao.updateOperation(currentTask!, taskProgress!);
  }

  void emptyTask() {
    timer = Timer(const Duration(seconds: 1), () {
      newTask.update({
        "product_location": "",
        "task": "",
      });
    });
  }

  void sendTask() async {
    if (canSendTask()) {
      // Update to auto-control with new task and location
      await newTask.update({
        "product_location": locationValue,
        "task": taskValue,
      });
      // Update current operation
      updateOp(taskValue, locationValue);
      // Update task and product location with empty String
      emptyTask();
    }
  }

  void saveToHistory() {
    currentTime = DateFormat("dd-MM-yyyy, HH:mm").format(DateTime.now());
    TaskHistory taskHistories = TaskHistory(
        dateTime: currentTime,
        task: taskValue,
        productLocation: locationValue);
    listHistory.clear();
    listHistory.add(taskHistories);
    widget.taskHistoryDao.saveInfo(currentTime,taskValue,locationValue);

    String temp = listHistory.last.task.toString();
    print("TASK HISTORY: $temp");
    print("===================");
  }

  // Create list of items in product location
  List<DropdownMenuItem<String>> createPLocationList() {
    return locationList
        .map<DropdownMenuItem<String>>(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ),
        )
        .toList();
  }

  // Create list of items in task
  List<DropdownMenuItem<String>> createTaskList() {
    return taskList
        .map<DropdownMenuItem<String>>(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: const Text('Monitor'),
        backgroundColor: Colors.orange,
        actions: [
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FloatingActionButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(imageUrl: widget.imageUrl));
                  },
                  tooltip: 'Increment',
                  elevation: 0,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.camera_alt),
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.35,
                  // child: VlcPlayer(
                  //   controller: _videoPlayerController!,
                  //   aspectRatio: 16 / 9,
                  //   placeholder: const Center(
                  //       child: CircularProgressIndicator()
                  //   ),
                  // ),
                child: Image.network(widget.imageUrl)
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Task: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: DropdownButton(
                              items: createTaskList(),
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              isExpanded: true,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20.0),
                              value: taskValue,
                              onChanged: (String? newValue) => setState(() {
                                    taskValue = newValue!;
                                  })),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Product location: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: DropdownButton(
                              items: createPLocationList(),
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              isExpanded: true,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20.0),
                              value: locationValue,
                              onChanged: (String? newValue) => setState(() {
                                    locationValue = newValue!;
                                  })),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: FirebaseAnimatedList(
                            physics: NeverScrollableScrollPhysics(),
                            query: widget.operationDao.getInfoQuery(),
                            itemBuilder: (context, snapshot, animation, index) {
                              final json =
                                  snapshot.value as Map<dynamic, dynamic>;
                              final data = Operation.fromJson(json);
                              taskProgress = data.taskProgress.toString();
                              if(taskProgress == "Done"){
                                widget.taskHistoryDao.saveInfo(currentTime,taskValue,locationValue);
                                taskProgress = "";
                                Timer(Duration(seconds: 3), () {
                                  widget.operationDao.updateOperation("", "");
                                });
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        child: const Text(
                                          'Task: ',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        child: Text(
                                          data.currentTask.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        child: const Text(
                                          'Progress: ',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        child: Text(
                                          data.taskProgress.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(5),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.orangeAccent,
                    alignment: Alignment.center,
                    elevation: 16,
                    minimumSize: Size(MediaQuery.of(context).size.width * 1,
                        MediaQuery.of(context).size.height * 0.06)),
                child: const Text('Send Instruction'),
                onPressed: () {
                  sendTask();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () async {
            ImagePicker imagePicker = ImagePicker();
            XFile? file =
                await imagePicker.pickImage(source: ImageSource.gallery);
            if (file == null) return;
            Reference referenceRoot = FirebaseStorage.instance.ref();
            Reference referenceDirImages = referenceRoot.child('Image');
            Reference referenceImageToUpload =
                referenceDirImages.child('map.png');
            try {
              await referenceImageToUpload.putFile(File(file!.path));
              widget.imageUrl = await referenceImageToUpload.getDownloadURL();
            } catch (error) {
              //hee
            }
          },
          tooltip: 'Increment',
          hoverElevation: 50,
          backgroundColor: Colors.orangeAccent,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  String imageUrl = '';

  ImageDialog({super.key, required this.imageUrl});

  VlcPlayerController? _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 300,
        child: //Image.network(imageUrl),
            VlcPlayer(
          controller: VlcPlayerController.network(
            'http://192.168.43.98:81/stream',
            hwAcc: HwAcc.full,
            autoPlay: true,
            options: VlcPlayerOptions(),
          ),
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
