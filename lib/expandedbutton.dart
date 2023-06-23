import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExtendedButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExtendedButtonState();
}

class _ExtendedButtonState extends State<ExtendedButton> {
  bool buttonStats = false;

  @override
  initState() {
    super.initState();
  }

  void change() {
    setState(() {
      buttonStats = !buttonStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            getSearchBar(),
            ElevatedButton(
              child: const Text('change'),
              onPressed: () => change(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSearchBar() {
    double barHeight = 140;
    double barWidth = 240;
    double radius = 60;
    Widget contents;
    const duration = Duration(milliseconds: 300);

    if (buttonStats) {
      barWidth = 540;
      barHeight = 140;
      radius = 90;
      contents = Container(
        margin: EdgeInsets.all(10),
        width: 480,
        height: 80,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Image(
                  width: 50,
                  height: 50,
                  image: AssetImage('images/search.png'),
                ),
                onTap: () {
                  change();
                },
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              AnimatedContainer(
                height: 50,
                width: 400,
                child: Center(child: Text('무엇을 만들까요?')),
                duration: duration,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ]),
      );
    } else {
      barHeight = 140;
      barWidth = 140;
      radius = 90;
      contents = Container(
        margin: EdgeInsets.all(10),
        width: 80,
        height: 80,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Image(
                  width: 50,
                  height: 50,
                  image: AssetImage('images/search.png'),
                ),
                onTap: () {
                  change();
                },
              ),
              //const Padding(padding: EdgeInsets.only(left: 5)),
              AnimatedContainer(
                height: 50,
                width: 0,
                duration: duration,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ]),
      );
    }
    return Center(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: AnimatedContainer(
              margin: EdgeInsets.all(30),
              width: barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.7),
                    blurRadius: 5.0,
                    spreadRadius: 0,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              duration: duration,
              child: contents,
            ),
          ),
          //contents,
        ],
      ),
    );
  }
}
