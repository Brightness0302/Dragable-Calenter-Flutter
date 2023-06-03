import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'date_rect.dart';
import 'week_circle.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  const MyApp({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Selector Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Date Selector Demo'),
        ),
        body: const Center(
          child: DateSelector(),
        ),
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  @override
  const DateSelector({key}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelector();
}

class _DateSelector extends State<DateSelector> {
  DateTime selectedDate = DateTime.now();
  String formattedDate = "";
  String seletedDateLabel = "";
  double rotationAngle = 0;
  Offset lastPos = const Offset(0, 0);
  double deltaLastRotationAngle = 0;
  Timer timer = Timer(const Duration(seconds: 5), () {});

  _DateSelector() {
    timer.cancel();
    selectedDate = DateTime.now();
    formattedDate = DateFormat.yMMMMd().format(selectedDate);
    seletedDateLabel = 'Selected Date is $formattedDate';
  }

  init(DateTime t) {
    setState(() {
      selectedDate = t;
      formattedDate = DateFormat.yMMMMd().format(selectedDate);
      seletedDateLabel = 'Selected Date is $formattedDate';
    });
  }

  setSelectedDate(DateTime t) {
    setState(() {
      selectedDate = t;
    });
  }

  setRotationAngle(double t) {
    setState(() {
      rotationAngle = t;
    });
  }

  setLastPos(Offset t) {
    setState(() {
      lastPos = t;
    });
  }

  setDeltaLastRotationAngle(double t) {
    setState(() {
      deltaLastRotationAngle = t;
    });
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 10);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        // Code to be executed every second
        if (rotationAngle.abs() <= 0.1) {
          rotationAngle = 0;
          timer.cancel();
        } else if (rotationAngle >= pi) {
          DateTime tempDate = selectedDate.add(const Duration(days: -7));
          init(tempDate.subtract(Duration(days: tempDate.weekday % 7)));
          rotationAngle = 0;
          timer.cancel();
        } else if (rotationAngle <= -pi) {
          DateTime tempDate = selectedDate.add(const Duration(days: 7));
          init(tempDate.subtract(Duration(days: tempDate.weekday % 7)));
          rotationAngle = 0;
          timer.cancel();
        } else if (rotationAngle < 0) {
          rotationAngle -= 0.1;
        } else if (rotationAngle > 0) {
          rotationAngle += 0.1;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = (MediaQuery.of(context).size.width - 64.0) / 3;
    Offset centerPos = Offset(containerWidth * 2, containerWidth);
    return Container(
      margin: const EdgeInsets.all(32.0),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            Offset currentPos = details.localPosition;
            double length =
                (currentPos.dx - lastPos.dx) * (currentPos.dx - lastPos.dx) +
                    (currentPos.dy - lastPos.dy) * (currentPos.dy - lastPos.dy);
            if (length > 10.0) {
              double deltaCurrentRotationAngle = atan2(
                  currentPos.dy - centerPos.dy, currentPos.dx - centerPos.dx);
              setRotationAngle(
                  deltaCurrentRotationAngle - deltaLastRotationAngle);
            }
          },
          onPanStart: (DragStartDetails details) {
            lastPos = details.localPosition;
            double tempdeltaLastRotationAngle =
                atan2(lastPos.dy - centerPos.dy, lastPos.dx - centerPos.dx);
            setDeltaLastRotationAngle(tempdeltaLastRotationAngle);
          },
          onPanEnd: (DragEndDetails details) {
            startTimer();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateRect(seletedDateLabel: seletedDateLabel),
              WeekCircle(
                  selectedDate: selectedDate,
                  rotationAngle: rotationAngle,
                  init: init)
            ],
          ),
        ),
      ),
    );
  }
}
