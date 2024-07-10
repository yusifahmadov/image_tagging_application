import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_tagging_application/dotenv.dart';

abstract class GenerativeAiService {
  static Future<Map<String, String>?> getTitle(String fileName, List<String> keywords) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: DotEnvironment.env['GEMINI_API_KEY']!,
        safetySettings: safetySettings);

    final prompt = """Paraphrase this file name and make it lengthy and give appropriate category.
    Filename: $fileName
    The length of filename should be between 100-150 characters. Capitalize the only first letter and others should be lowercase.
    If you see any struggles to make a new paraphrased title, then you can use these keywords of the image: $keywords
    
    So give me appropriate category by using paraphrased filename and keywords. 
    Category should be from among them: Animals, Buildings and Architecture, Business, Drinks, The Environment, States of Mind, Food, Graphic Resources, Hobbies and Leisure, Industry, Landscapes, Lifestyle, People, Plants and Flowers, Culture and Religion, Science, Social Issues, Sports, Technology, Transport, Travel.
    The final result should be in json format. 
    EXAMPLE: 
    Given filename: a road in the woods
    Response: {"filename":"A winding path through the autumnal forest.", "category":"Landscapes"}
    """;
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    Map<String, dynamic> parsedResponse =
        jsonDecode(response.text!.replaceAll("```json\n", "").replaceAll("\n```", ""));

    return {parsedResponse["filename"]: parsedResponse["category"]};
  }
}
