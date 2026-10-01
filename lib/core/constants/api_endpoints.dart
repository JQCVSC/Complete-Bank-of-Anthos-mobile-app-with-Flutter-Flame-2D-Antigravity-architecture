class ApiEndpoints {
  // Default ingress or proxy URL for live Bank of Anthos clusters
  static const String defaultBaseUrl = 'http://10.0.2.2:8080'; // Android emulator localhost

  // Endpoints exposed by Bank of Anthos Frontend / Ingress
  static const String login = '/login';
  static const String logout = '/logout';
  static const String signup = '/signup';
  static const String balance = '/balances'; // or /home
  static const String transactions = '/history';
  static const String payment = '/payment';
  static const String deposit = '/deposit';
  static const String contacts = '/contacts';
  static const String readiness = '/ready';
  static const String version = '/version';
  static const String whereami = '/whereami';
}
