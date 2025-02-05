import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/minute/minute_bloc.dart';

class MinuteHand extends StatefulWidget {
  const MinuteHand({Key? key}) : super(key: key);

  @override
  _MinuteHandState createState() => _MinuteHandState();
}

class _MinuteHandState extends State<MinuteHand>
    with SingleTickerProviderStateMixin {
  late double wheelSize;
  double degree = 0;
  int _valueChoose = 0;
  late double radius;
  late AnimationController ctrl;
  @override
  void initState() {
    super.initState();
    wheelSize = 300;
    radius = wheelSize / 2;
    ctrl = AnimationController.unbounded(vsync: this);
    degree = 0;
    ctrl.value = degree;
  }

  double degreeToRadians(double degrees) => degrees * (pi / 180);

  double roundToBase(double number, int base) {
    double reminder = number % base;
    double result = number;
    if (reminder < (base / 2)) {
      result = number - reminder;
    } else {
      result = number + (base - reminder);
    }
    return result;
  }

  _panUpdateHandler(DragUpdateDetails d) {
    bool onTop = d.localPosition.dy <= radius;
    bool onLeftSide = d.localPosition.dx <= radius;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    double verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp)
        ? yChange
        : yChange * -1;

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

    double rotationalChange = verticalRotation + horizontalRotation;

    double _value = degree + (rotationalChange / 5);

    setState(() {
      degree = _value > 0 ? _value : 0;
      ctrl.value = degree;
      var a = degree < 360 ? degree.roundToDouble() : degree - 360;
      var degrees = roundToBase(a.roundToDouble(), 10);
      _valueChoose = degrees ~/ 6 == 60 ? 0 : degrees ~/ 6;
      BlocProvider.of<MinuteBloc>(context).add(SetMinute(_valueChoose));
    });
  }

  _panEndHandler(DragEndDetails d) {
    var a = degree < 360 ? degree.roundToDouble() : degree - 360;
    ctrl
        .animateTo(roundToBase(a.roundToDouble(), 10),
            duration: Duration(milliseconds: 551), curve: Curves.easeOutBack)
        .whenComplete(() {
      setState(() {
        degree = roundToBase(a.roundToDouble(), 10);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    GestureDetector draggableMinute = GestureDetector(
      onPanUpdate: _panUpdateHandler,
      onPanEnd: _panEndHandler,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.transparent,
        ),
        child: Align(
          alignment: Alignment(0, 0),
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (ctx, w) {
              return Transform.rotate(
                angle: degreeToRadians(ctrl.value),
                child: Container(
                  width: 6,
                  height: 196,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topCenter,
                          colors: const [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                          ]),
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ),
      ),
    );
    return draggableMinute;
  }
}
