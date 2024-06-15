import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:memory_eater/gen/assets.gen.dart';
import 'package:memory_eater/json_model.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: IconGame(),
      ),
    );
  }
}

class IconGame extends StatefulWidget {
  const IconGame({super.key});

  @override
  State<IconGame> createState() => _IconGameState();
}

class _IconGameState extends State<IconGame> with TickerProviderStateMixin {
  final int numberOfIcons = 7;
  List<Offset> iconPositions = [];
  List<Image> iconPictures = [
    Assets.images.sonic.image(),
    Assets.images.tails.image(),
    Assets.images.knuckles.image(),
    Assets.images.amy.image(),
    Assets.images.shadow.image(),
    Assets.images.silver.image(),
    Assets.images.blaze.image()
  ];
  List<Offset> iconDirections = [];
  List<bool> iconVisibility = [];
  List<double> iconSpeeds = [];
  double iconSize = 50.0;
  late AnimationController _controller;
  late Size screenSize;

  @override
  void initState() {
    super.initState();
    iconVisibility = List<bool>.filled(numberOfIcons, true);
    _controller = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    )..addListener(_updatePositions);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    if (iconPositions.isEmpty) {
      for (int i = 0; i < numberOfIcons; i++) {
        iconPositions.add(_randomPosition());
        iconDirections.add(_randomDirection());
        iconSpeeds.add(2.0 + Random().nextDouble() * 3);
      }
    }
  }

  Offset _randomPosition() {
    final random = Random();
    final x = random.nextDouble() * (screenSize.width - iconSize);
    final y = random.nextDouble() * (screenSize.height - iconSize);
    return Offset(x, y);
  }

  Offset _randomDirection() {
    final random = Random();
    final dx = random.nextDouble() * 2 - 1;
    final dy = random.nextDouble() * 2 - 1;
    return Offset(dx, dy).normalize();
  }

  void _updatePositions() {
    setState(() {
      for (int i = 0; i < numberOfIcons; i++) {
        if (!iconVisibility[i]) continue;

        final speed = iconSpeeds[i];
        var newPos = iconPositions[i] + iconDirections[i] * speed;

        if (newPos.dx <= 0 || newPos.dx >= screenSize.width - iconSize) {
          iconDirections[i] =
              Offset(-iconDirections[i].dx, iconDirections[i].dy);
          newPos = iconPositions[i] + iconDirections[i] * speed;
        }
        if (newPos.dy <= 0 || newPos.dy >= screenSize.height - iconSize) {
          iconDirections[i] =
              Offset(iconDirections[i].dx, -iconDirections[i].dy);
          newPos = iconPositions[i] + iconDirections[i] * speed;
        }

        iconPositions[i] = newPos;
      }
    });
  }

  void startMemoryIntensiveTask() {
    while (true) {
      Isolate.run(slowlyKill);
    }
  }

  Future<void> slowlyKill() async {
    final String response =
        await rootBundle.loadString('assets/data/long_long_long.json');
    final json = const JsonDecoder().convert(response) as Map<String, dynamic>;
    final objectsList = List.empty(growable: true);
    final jsonData = json["data"] as List<dynamic>;
    for (int i = 0; i <= 40; i++) {
      objectsList.addAll(jsonData);
    }
    objectsList.map(JsonModel.fromJson).toList();
  }

  Future<void> onIconHit(int index) async {
    setState(() {
      iconVisibility[index] = false;
    });
    final String response =
        await rootBundle.loadString('assets/data/long_long_long.json');
    final json = const JsonDecoder().convert(response) as Map<String, dynamic>;
    final objectsList = List.empty(growable: true);
    final jsonData = json["data"] as List<dynamic>;
    for (int i = 0; i <= 30; i++) {
      objectsList.addAll(jsonData);
    }
    objectsList.map(JsonModel.fromJson).toList();

    if (iconVisibility.every((element) => element == false)) {
      startMemoryIntensiveTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (iconVisibility.every((isVisible) => !isVisible)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Congratulations your memory is full now!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Stack(
      children: List.generate(numberOfIcons, (index) {
        if (!iconVisibility[index]) {
          return Container();
        }

        return Positioned(
          left: iconPositions[index].dx,
          top: iconPositions[index].dy,
          child: GestureDetector(
            onTap: () => onIconHit(index),
            child: iconPictures[index],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

extension NormalizeOffset on Offset {
  Offset normalize() {
    final length = sqrt(dx * dx + dy * dy);
    return Offset(dx / length, dy / length);
  }
}
