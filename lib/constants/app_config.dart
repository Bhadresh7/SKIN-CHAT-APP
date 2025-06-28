class AppConfig {
  static late String environment;

  static void setEnvironment(String env) {
    environment = env;
  }

  static bool get isProd => environment == 'prod';
}
