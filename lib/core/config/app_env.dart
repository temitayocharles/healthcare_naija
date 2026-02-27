class AppEnv {
  AppEnv._();

  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String openAiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );
  static const String openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  static const bool enableAiTriage = bool.fromEnvironment(
    'ENABLE_AI_TRIAGE',
    defaultValue: false,
  );
}

