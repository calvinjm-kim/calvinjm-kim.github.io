import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

final _openAIModel = 'gpt-3.5-turbo-16k';

Future<String> handleChatCompletion(String command, String baseData) async {
  String result = command;
  print('Handling chat competion...');
  print('command = $command');
  print('base data = $baseData');

  // Set the key
  String message = 'c2stYTJKMDJmOVhTYWc2Qm5HT3RDTTRUM0JsYmtGSkFqZ3hLZEdLeEdCWUxoTVF0Qmdo|Y68dZ3hLZERUM0J';
  String encode = message.substring(0,message.indexOf('|'));
  List<int> decoded = base64.decode(encode);
  String apiK = utf8.decode(decoded);
  //OpenAI.apiKey = dotenv.get('OPENAI_KEY', fallback: 'NOKEYEXIST');
  OpenAI.apiKey = apiK;

  // Call the api
  final OpenAIChatCompletionModel chatResult;
  if (baseData.isEmpty == false) {
    // TODO: Check the base data size (if it is larger, divide and conquer)
    chatResult = await OpenAI.instance.chat.create(
      model: _openAIModel,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: baseData,
          role: OpenAIChatMessageRole.user,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: command,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
  } else {
    chatResult = await OpenAI.instance.chat.create(
      model: _openAIModel,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: command,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
  }

  // Set the result
  result = chatResult.choices[0].message.content;

  return result;
}
