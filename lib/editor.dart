import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:translator/translator.dart';
import 'openai.dart' as openai;

late QuillEditorController _controller;
double _panelSizeLeft = 200;
double _panelSizeRight = 200;
double _panelHeight = 400;

class Editor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.clean,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];
  final _toolbarColor = Colors.grey.shade200;
  final _backgroundColor = Colors.white70;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle = const TextStyle(
      fontSize: 16, color: Colors.black, fontWeight: FontWeight.normal);
  final _hintTextStyle = const TextStyle(
      fontSize: 16, color: Colors.black12, fontWeight: FontWeight.normal);

  final List<ChatMessage> _messages = <ChatMessage>[];

  final TextEditingController _commandInputController = TextEditingController();

  bool _bSelectedText = false;
  bool _bUseMainText = false;
  int _editTextLength = 0;

  FocusNode _focusPrompt = FocusNode();

  @override
  void initState() {
    _controller = QuillEditorController();
    _controller.onTextChanged((text) {
      //debugPrint('listening to $text');
      _editTextLength = text.length;
      if (_bSelectedText) {
        setState(() {
          _bSelectedText = false;
          _bUseMainText = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: getMainLayout(),
      ),
    );
  }

  Widget getMainLayout() {
    // Get the screen size
    double screenWidth = MediaQuery.of(context).size.width;
    _panelHeight = MediaQuery.of(context).size.height - 30;
    _panelSizeLeft = screenWidth/2 + 40;
    _panelSizeRight = screenWidth - _panelSizeLeft;

    // Return the layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _panelSizeLeft,
          child: getLeftView(),
        ),       
        //const VerticalDivider(),
        SizedBox(
          width: _panelSizeRight,
          height: 540,
          child: getRightView(),
        ),
      ],
    );
  }

  Widget getLeftView() {
    return SingleChildScrollView(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ToolBar.scroll(
            controller: _controller,
            direction: Axis.horizontal,
            toolBarColor: _toolbarColor,
            toolBarConfig: _customToolBarList,
            padding: const EdgeInsets.all(8),
            iconSize: 25,
            iconColor: _toolbarIconColor,
            activeIconColor: Colors.blueAccent.shade400,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        SizedBox(
          height: _panelHeight - 40,
          child: QuillHtmlEditor(
            controller: _controller,
            text: "<h1>안녕하세요.</h1>이것은 <b>AI Assistant</b> 예제입니다 😊<br><br>우측 커맨드 창을 통해 이메일 내용을 생성해 보세요.",
            hintText: '(본문을 드래그해서 AI에게 전달할 내용을 선택할 수 있습니다.)',
            isEnabled: true,
            minHeight: 500,
            textStyle: _editorTextStyle,
            hintTextStyle: _hintTextStyle,
            hintTextAlign: TextAlign.start,
            padding: const EdgeInsets.only(left: 10, top: 10),
            hintTextPadding: const EdgeInsets.only(left: 20),
            backgroundColor: _backgroundColor,
            onSelectionChanged: (selection) {
              int length = 0;
              length = selection.length!;
              if (_bUseMainText == false) {
                if (length > 0) {
                  setState(() {
                    _bSelectedText = true;
                    _bUseMainText = false;
                  });
                } else {
                  setState(() {
                    _bSelectedText = false;
                    _bUseMainText = false;
                  });
                }
              } else {
                if (length == 0) {
                  setState(() {
                    _bUseMainText = false;
                  });
                }
              }
            },
          ),
        ),
      ],
    ),
    );
  }

  Widget getRightView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: GestureDetector(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                if (index >= 0 && index < _messages.length) {
                  return _messages[index];
                }
              },
            ),
            onTap: () {
              _controller.unFocus();
              _focusPrompt.unfocus();
            },
          ),
        ),
        const Divider(height: 1.0),
        getCommandInput(),
      ],
    );
  }

  Widget getCommandInput() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: getSelectionButton(),
        ),
        SizedBox(
          width: _panelSizeRight - 80,
          height: 80,
          child: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: TextField(
              controller: _commandInputController,
              focusNode: _focusPrompt,
              decoration: InputDecoration(
                hintText: '무엇을 도와드릴까요?',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(14.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(14.0)),
                ),
                suffixIcon: GestureDetector(
                    child: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    onTap: () {
                      submitPrompt(_commandInputController.text);
                    }),
              ),
              onSubmitted: (value) {
                submitPrompt(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget getSelectionButton() {
    String btnText = '';
    Color btnColor = Colors.lightBlue;
    Color btnTextColor = Colors.white;
    Color btnBorderColor = Colors.transparent;
    if (_bSelectedText) {
      btnText = '부분선택';
      btnColor = Colors.greenAccent;
    } else {
      if (_bUseMainText) {
        btnText = '전체선택';
        btnColor = Colors.blueAccent;
      } else {
        btnText = '미선택';
        btnColor = Colors.transparent;
        btnTextColor = Colors.blueAccent;
        btnBorderColor = Colors.blueAccent;
      }
    }
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
        decoration: BoxDecoration(
          border: Border.all(color: btnBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: btnColor,
        ),
        child: Text(
          btnText,
          style: TextStyle(color: btnTextColor),
        ),
      ),
      onTap: () async {
        if (_bSelectedText == false) {
          if (_bUseMainText) {
            String plainText = await _controller.getPlainText();
            _controller.setSelectionRange(plainText.length, 0);
            setState(() {
              _bUseMainText = false;
            });
          } else {
            if (_editTextLength > 0) {
              String plainText = await _controller.getPlainText();
              _controller.setSelectionRange(0, plainText.length);
              setState(() {
                _bUseMainText = true;
              });
            }
          }
        }
      },
    );
  }

  void submitPrompt(String command) async {
    // Skip empty prompt
    if (command.isEmpty) {
      return;
    }

    // Clear the command
    _commandInputController.clear();
    _focusPrompt.unfocus();

    // Get selected range
    SelectionModel model = await _controller.getSelectionRange();
    int currentIndex = 0;
    int selectionEndIndex = 0;
    currentIndex = model.index!;
    selectionEndIndex = currentIndex + model.length!;

    // Reset the selected range
    _controller.setSelectionRange(selectionEndIndex, 0);

    // Create command message
    ChatMessage msgCommand = ChatMessage(isAnswer: false, text: '');
    String baseData = '';
    if (_bSelectedText) {
      baseData = await _controller.getSelectedText();
      msgCommand = ChatMessage(isAnswer: false, text: '선택영역에 대해 $command');
    } else {
      if (_bUseMainText) {
        baseData = await _controller.getPlainText();
        msgCommand = ChatMessage(isAnswer: false, text: '전체영역에 대해 $command');
      } else {
        msgCommand = ChatMessage(isAnswer: false, text: command);
      }
    }
    setState(() {
      _messages.insert(0, msgCommand);
    });

    // Process the prompt
    String result = await openai.handleChatCompletion(command, baseData);
    ChatMessage msgResult = ChatMessage(isAnswer: true, text: result);
    setState(() {
      _messages.insert(0, msgResult);
    });
  }

  Future<String> translateWithGoogle(String original, String target) async {
    // original: text to translate, target: target language 'ko'
    Translation ts = await original.translate(to: target);
    String translated = ts.toString();
    return translated;
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isAnswer;

  ChatMessage({required this.isAnswer, required this.text});

  @override
  Widget build(BuildContext context) {
    int maxLines = 30;
    double boxSize = _panelSizeRight - 80;
    double boxPadding = 10;
    double boxMarginHeight = 10;
    double boxMarginWidth = 10;
    double boxBorderRadius = 14;
    MainAxisAlignment alignment;
    BorderRadius bRadius;
    Color boxColor;
    if (isAnswer) {
      alignment = MainAxisAlignment.start;
      bRadius = BorderRadius.only(
        topLeft: Radius.circular(boxBorderRadius),
        topRight: Radius.circular(boxBorderRadius),
        bottomRight: Radius.circular(boxBorderRadius),
      );
      boxColor = Colors.lime;
    } else {
      alignment = MainAxisAlignment.end;
      bRadius = BorderRadius.only(
        topLeft: Radius.circular(boxBorderRadius),
        topRight: Radius.circular(boxBorderRadius),
        bottomLeft: Radius.circular(boxBorderRadius),
      );
      boxColor = Colors.orange;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: alignment,
      children: [
        Padding(padding: EdgeInsets.only(left: boxMarginWidth)),
        GestureDetector(
          child: Container(
            constraints: BoxConstraints(maxWidth: boxSize),
            padding: EdgeInsets.all(boxPadding),
            margin: EdgeInsets.all(boxMarginHeight),
            decoration: BoxDecoration(
              borderRadius: bRadius,
              color: boxColor,
            ),
            child: Text(
              text,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ),
          onTap: () {
            if (isAnswer) {
              String converted = text.replaceAll('\n', '<br>');
              _controller.insertText(converted);
            }
          },
        ),
        Padding(padding: EdgeInsets.only(right: boxMarginWidth)),
      ],
    );
  }
}
