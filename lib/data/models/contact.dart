class Contact {
  final String label;
  final String accountNum;
  final String routingNum;
  final bool isExternal;

  const Contact({
    required this.label,
    required this.accountNum,
    this.routingNum = '123456789',
    this.isExternal = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      label: json['label']?.toString() ?? '',
      accountNum: json['account_num']?.toString() ?? json['accountNum']?.toString() ?? '',
      routingNum: json['routing_num']?.toString() ?? json['routingNum']?.toString() ?? '123456789',
      isExternal: json['is_external'] == true || json['isExternal'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'account_num': accountNum,
      'routing_num': routingNum,
      'is_external': isExternal,
    };
  }

  String get initials {
    if (label.isEmpty) return '?';
    final parts = label.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return label[0].toUpperCase();
  }

  Contact copyWith({
    String? label,
    String? accountNum,
    String? routingNum,
    bool? isExternal,
  }) {
    return Contact(
      label: label ?? this.label,
      accountNum: accountNum ?? this.accountNum,
      routingNum: routingNum ?? this.routingNum,
      isExternal: isExternal ?? this.isExternal,
    );
  }
}
