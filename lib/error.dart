import 'package:image_tagging_application/dotenv.dart';

abstract class TaggingException {
  static check() async {
    if (DotEnvironment.env['USER_ID'] == null ||
        DotEnvironment.env["SECRET_KEY"] == null ||
        DotEnvironment.env['MIDJOURNEY_PREFIX'] == null ||
        DotEnvironment.env['GEMINI_API_KEY'] == null) {
      throw ArgumentError(
          """Please create a .env file in your root path if not exists and configure .env file like below:
          USER_ID =  your_everypixel_user_id
          SECRET_KEY = your_everypixel_secret_key
          MIDJOURNEY_PREFIX = your_midjourney_prefix
          GEMINI_API_KEY = your_gemini_api_key
    """, '.dotenv ERROR');
    }
  }
}
