class LoginData {
  final String email;
  final String password;

  LoginData({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}