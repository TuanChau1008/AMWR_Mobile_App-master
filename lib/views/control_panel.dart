import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  VlcPlayerController? _videoPlayerController;

  Timer? timer;
  String command = "";

  DatabaseReference? operateMode;
  DatabaseReference? manualControl;

  @override
  void initState() {
    super.initState();
    operateMode = FirebaseDatabase.instance.ref("/operate-mode");
    manualControl = FirebaseDatabase.instance.ref("/manual-control");
    setState(() {
      _videoPlayerController = VlcPlayerController.network(
        'http://192.168.43.98:81/stream',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    });
    if (operateMode!.path.isNotEmpty) {
      operateMode!.update({
        "mode": "manual_control",
      });
    }
    getDirection();
  }

  @override
  void dispose() {
    super.dispose();
    operateMode!.update({"mode": "exit_mode",});
    _videoPlayerController!.stopRendererScanning();
    _videoPlayerController!.dispose();
  }

  Future<void> getDirection() async {
    await manualControl!.get();
  }

  Future<void> updateDirection(String command) async {
    await manualControl!.update({
      "direction": command,
    });
    if (kDebugMode) {
      print(command);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.35,
            child: VlcPlayer(
              controller: _videoPlayerController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 85.0, horizontal: 0.0),
            child: SizedBox(
              height: size.height,
              child: FirebaseAnimatedList(
                  query: manualControl!,
                  itemBuilder: (context, snapshot, animation, index) {
                    return Material(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Transform.rotate(
                                angle: 90 * pi / 180,
                                child: GestureDetector(
                                  child: InkWell(
                                    splashColor: Colors.orange,
                                    child: Container(
                                      color: Colors.transparent,
                                      child: const Icon(
                                        size: 80,
                                        Icons.subdirectory_arrow_right_sharp,
                                      ),
                                    ),
                                  ),
                                  onLongPressStart: (_) {
                                    setState(() {
                                      command = 'q'; //rotate_left
                                    });
                                  },
                                  onLongPress: () {
                                    timer = Timer.periodic(
                                        const Duration(milliseconds: 50),
                                        (timer) {
                                      updateDirection(command);
                                    });
                                  },
                                  onLongPressEnd: (details) {
                                    command = 's'; //stop_bot
                                    updateDirection(command);
                                    timer?.cancel();
                                  },
                                ),
                              ),
                              GestureDetector(
                                child: const FaIcon(
                                  size: 80,
                                  FontAwesomeIcons.arrowUp,
                                ),
                                onLongPressStart: (_) {
                                  setState(() {
                                    command = 'f'; //move_forward
                                  });
                                },
                                onLongPress: () {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      (timer) {
                                    updateDirection(command);
                                  });
                                },
                                onLongPressEnd: (details) {
                                  command = 's'; //stop_bot
                                  updateDirection(command);
                                  timer?.cancel();
                                },
                              ),
                              Transform.rotate(
                                angle: 90 * pi / 180,
                                child: Transform.scale(
                                  scaleY: -1,
                                  child: GestureDetector(
                                    child: const Icon(
                                      size: 80,
                                      Icons.subdirectory_arrow_right_sharp,
                                    ),
                                    onLongPressStart: (_) {
                                      setState(() {
                                        command = 'e'; //rotate_right
                                      });
                                    },
                                    onLongPress: () {
                                      timer = Timer.periodic(
                                          const Duration(milliseconds: 50),
                                          (timer) {
                                        updateDirection(command);
                                      });
                                    },
                                    onLongPressEnd: (details) {
                                      command = 's'; //stop_bot
                                      updateDirection(command);
                                      timer?.cancel();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: const FaIcon(
                                  size: 80,
                                  FontAwesomeIcons.arrowLeft,
                                ),
                                onLongPressStart: (_) {
                                  setState(() {
                                    command = 'l'; //move_left
                                  });
                                },
                                onLongPress: () {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      (timer) {
                                    updateDirection(command);
                                  });
                                },
                                onLongPressEnd: (details) {
                                  command = 's'; //stop_bot
                                  updateDirection(command);
                                  timer?.cancel();
                                },
                              ),
                              GestureDetector(
                                child: const FaIcon(
                                  size: 80,
                                  FontAwesomeIcons.arrowRight,
                                ),
                                onLongPressStart: (_) {
                                  setState(() {
                                    command = 'r'; //move_right
                                  });
                                },
                                onLongPress: () {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      (timer) {
                                    updateDirection(command);
                                  });
                                },
                                onLongPressEnd: (details) {
                                  command = 's'; //stop_bot
                                  updateDirection(command);
                                  timer?.cancel();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: const FaIcon(
                                  size: 80,
                                  FontAwesomeIcons.arrowDown,
                                ),
                                onLongPressStart: (_) {
                                  setState(() {
                                    command = 'b'; //move_backward
                                  });
                                },
                                onLongPress: () {
                                  timer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      (timer) {
                                    updateDirection(command);
                                  });
                                },
                                onLongPressEnd: (details) {
                                  command = 's'; //stop_bot
                                  updateDirection(command);
                                  timer?.cancel();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
