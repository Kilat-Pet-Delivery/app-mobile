class RegisterRequest {
  final String email;
  final String phone;
  final String fullName;
  final String password;

  const RegisterRequest({
    required this.email,
    required this.phone,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'password': password,
        'role': 'owner', // Always owner for this app
      };
}
