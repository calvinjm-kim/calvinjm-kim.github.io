import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_rich_text/simple_rich_text.dart';

class EditorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  String text =
      r'Now you can change the ~{fontSize:32}size~ of the text. \nInsert a new line.\nChange the ~{backgroundColor:yellow}background color~\nAnd modify more style as: fontFamily, _{decorationColor:blue}decorationColor_, ~{height:3}height~, etc\n\nToo you can open url: _{http:www.google.com;color:blue}go to Google_\nFinaly, you can define textAlign, maxLines and textOverflow';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: 500,
                minHeight: 700,
              ),
              color: Colors.amber,
              child: SimpleRichText(text,
                  logIt: false,
                  maxLines: 20,
                  pre: TextSpan(
                      text: 'PRE', style: TextStyle(color: Colors.purple)),
                  post: TextSpan(
                      text: 'POST', style: TextStyle(color: Colors.purple)),
                  style: TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                  textOverflow: TextOverflow.ellipsis,
                  textScaleFactor: 1.5),
            ),
            ElevatedButton(
              child: const Text('change'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
