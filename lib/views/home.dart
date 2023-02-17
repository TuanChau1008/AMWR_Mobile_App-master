import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:amwr_mobile_app/views/robot_info.dart';
import 'package:firebase_database/firebase_database.dart';

import 'control_panel.dart';
import 'task_history.dart';
import 'monitor.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference firebase = FirebaseDatabase.instance.ref();
  String imageUrl = "";
  @override
  void initState() {
    super.initState();
    loadImage();
  }

  @override
  void dispose() {
    super.dispose();
  }
  loadImage() async{
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Image');
    Reference referenceImageToDownload = referenceDirImages.child('map.png');
    imageUrl = await referenceImageToDownload.getDownloadURL();
  }
  @override
  Widget makeDashbooardItem(String title, String img, int index) {
    return Card(
      elevation: 12,
      child: InkWell(
        splashColor: Colors.blueGrey,
        onTap: () {
          if (index == 0) {
            //1.item
            Navigator.push(context,
                MaterialPageRoute(builder: ((context) => ControlPanel()
                )));
          }
          if (index == 1) {
            //2.item
            Navigator.push(
                context, MaterialPageRoute(builder: ((context) => Monitor(imageUrl: imageUrl))));
          }
          if (index == 2) {
            //3.item
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => RobotInfo())));
          }
          if (index == 3) {
            //4.item
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => taskHistory()),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset(
                img,
                height: 60,
                width: 70,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                title + '',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(color: Colors.deepOrange[50]),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 19),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 200,
                            width: 200,
                            child: const Image(
                                image: AssetImage('assets/images/logo_app.png')),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return makeDashbooardItem(
                          "Controller", "assets/images/controlpanel.png", i);
                    } else if (i == 1) {
                      return makeDashbooardItem(
                          "Monitor", "assets/images/camera.png", i);
                    } else if (i == 2) {
                      return makeDashbooardItem(
                          "Infomation", "assets/images/info.png", i);
                    } else {
                      return makeDashbooardItem(
                          "Task History", "assets/images/task_history.png", i);
                    }
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 220,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
