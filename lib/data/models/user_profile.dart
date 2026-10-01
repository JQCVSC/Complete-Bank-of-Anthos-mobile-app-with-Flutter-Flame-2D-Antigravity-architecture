class UserProfile {
  final String accountId;
  final String username;
  final String displayName;
  final String email;
  final String routingNumber;
  final String? token;

  const UserProfile({
    required this.accountId,
    required this.username,
    required this.displayName,
    required this.email,
    this.routingNumber = '123456789',
    this.token,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserProfile(
      accountId: json['acct']?.toString() ?? json['account_id']?.toString() ?? '1012345678',
      username: json['user']?.toString() ?? json['username']?.toString() ?? '',
      displayName: json['name']?.toString() ?? json['display_name']?.toString() ?? 'Anthos Customer',
      email: json['email']?.toString() ?? '${json['user'] ?? 'user'}@bankofanthos.com',
      routingNumber: json['routing_number']?.toString() ?? '123456789',
      token: token ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'username': username,
      'display_name': displayName,
      'email': email,
      'routing_number': routingNumber,
      'token': token,
    };
  }

  UserProfile copyWith({
    String? accountId,
    String? username,
    String? displayName,
    String? email,
    String? routingNumber,
    String? token,
  }) {
    return UserProfile(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      routingNumber: routingNumber ?? this.routingNumber,
      token: token ?? this.token,
    );
  }
}
