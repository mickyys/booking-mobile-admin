class AppConfig {
  static const String auth0Domain = String.fromEnvironment('AUTH0_DOMAIN');

  static const String auth0ClientId = String.fromEnvironment('AUTH0_CLIENT_ID');

  static const String auth0Audience = String.fromEnvironment('AUTH0_AUDIENCE');
}
