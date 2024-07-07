import 'package:google_generative_ai/google_generative_ai.dart';

abstract class GenerativeAiService {
  static Future<String?> getTitle(String fileName, List<String> keywords) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: "***REMOVED***",
        safetySettings: safetySettings);

    final prompt =
        """Paraphrase this title and make it lengthy and give me only the paraphrased title. Do not give me other words
    Title: $fileName
    The length should be between 100-150 characters. The first letter will be uppercase and others are lower case. 
    If you see any struggles to make a new paraphrased title, then you can use these keywords of the image: $keywords
    EXAMPLE: 
    Given title: a road in the woods
    Response: A winding path through the autumnal forest
    """;
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text?.trim();
  }
}
