import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _openAIModel = 'gpt-3.5-turbo-16k';

Future<String> handleChatCompletion(String command, String baseData) async {
  String result = command;
  print('Handling chat competion...');
  print('command = $command');
  print('base data = $baseData');
  await Future.delayed(Duration(seconds: 3));

  // Set the key
  OpenAI.apiKey = dotenv.get('OPENAI_KEY', fallback: 'NOKEYEXIST');

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
