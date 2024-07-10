import 'package:dotenv/dotenv.dart';

abstract class DotEnvironment {
  static late DotEnv env;
  static initialize() async {
    env = DotEnv(includePlatformEnvironment: true)..load();
  }
}
