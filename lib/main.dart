import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

const textColor = Colors.white;
const primary = Colors.blueGrey;
final primaryContainer = Colors.blueGrey[600];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.blueGrey[600],
      ),
      home: const HomePage(),
    );
  }
}

const title = Hero(
  tag: 'title',
  child: Text(
    "Countdown",
    style: TextStyle(
      fontSize: 20,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal,
    ),
  ),
);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int seconds = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: seconds.toString(),
              onChanged: (value) {
                setState(() {
                  seconds = int.tryParse(value) ?? 0;
                });
              },
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                label: Text(
                  "seconds",
                  style: TextStyle(color: textColor),
                ),
                floatingLabelAlignment: FloatingLabelAlignment.center,
              ),
              style: const TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
              child: title,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: () async {
                final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                const initializationSettingsMacOS = MacOSInitializationSettings(
                  requestAlertPermission: true,
                  requestBadgePermission: true,
                  requestSoundPermission: true,
                );
                await flutterLocalNotificationsPlugin.initialize(
                  const InitializationSettings(macOS: initializationSettingsMacOS),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CountdownPage(seconds: seconds)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownPage extends StatefulWidget {
  const CountdownPage({
    Key? key,
    required this.seconds,
  }) : super(key: key);

  final int seconds;

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  late int remaining;
  Timer? timer;

  void notification() {
    const iosSpecifics = IOSNotificationDetails();
    const platformSpecifics = NotificationDetails(iOS: iosSpecifics);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(0, 'Time\'s up!', '', platformSpecifics);
  }

  @override
  void initState() {
    super.initState();
    remaining = widget.seconds;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remaining--;
      });
      if (remaining <= 0) {
        timer.cancel();
        notification();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    const aTick = pi / 30;
    final size = MediaQuery.of(context).size.shortestSide * 0.8;
    final seconds = remaining % 60;
    final minutes = remaining / 60;

    return Scaffold(
      appBar: AppBar(title: title),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // 表框
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: textColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(size)),
                ),
              ),

              // 表盘
              for (var i = 0; i < 30; i++)
                Transform.rotate(
                  angle: aTick * i,
                  child: Container(
                    width: 2,
                    height: size * 0.9,
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide.none,
                        horizontal: BorderSide(
                          color: textColor,
                          width: i % 5 == 0 ? 10 : 4,
                        ),
                      ),
                    ),
                  ),
                ),

              // 分针
              Transform.rotate(
                angle: aTick * minutes,
                child: Container(
                  width: 6,
                  height: size * 0.6,
                  alignment: Alignment.topCenter,
                  child: Container(height: size * 0.3, color: Colors.red[300]),
                ),
              ),

              // 秒针
              Transform.rotate(
                angle: aTick * seconds,
                child: Container(
                  width: 2,
                  height: size * 0.8,
                  alignment: Alignment.topCenter,
                  child: Container(height: size * .4, color: textColor),
                ),
              ),

              // 中心点
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "${minutes.floor()}'${seconds.toString().padLeft(2, '0')}\"",
              style: const TextStyle(color: textColor, fontSize: 40),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              child: const Text("Restart"),
              onPressed: () {
                setState(() {
                  remaining = widget.seconds;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
