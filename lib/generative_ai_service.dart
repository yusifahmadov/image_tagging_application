import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_tagging_application/dotenv.dart';

abstract class GenerativeAiService {
  static Future<Map<String, String>?> getTitle(Uint8List bytes) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: DotEnvironment.env['GEMINI_API_KEY']!,
        safetySettings: safetySettings);

    final prompt =
        """Give a title according to the provided image and give an appropriate category.
    The length of the title should be between 100-150 characters. Capitalize the only first letter and others should be lowercase.
    So give me appropriate category by using paraphrased filename and keywords. 
    Category should be from among them: Animals, Buildings and Architecture, Business, Drinks, The Environment, States of Mind, Food, Graphic Resources, Hobbies and Leisure, Industry, Landscapes, Lifestyle, People, Plants and Flowers, Culture and Religion, Science, Social Issues, Sports, Technology, Transport, Travel.
    The final result should be in json format. 
    EXAMPLE: 
    Given filename: a road in the woods
    Response: {"filename":"A winding path through the autumnal forest.", "category":"Landscapes"}
    """;
    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)])
    ];
    final response = await model.generateContent(content);
    Map<String, dynamic> parsedResponse =
        jsonDecode(response.text!.replaceAll("```json\n", "").replaceAll("\n```", ""));

    return {parsedResponse["filename"]: parsedResponse["category"]};
  }
}
