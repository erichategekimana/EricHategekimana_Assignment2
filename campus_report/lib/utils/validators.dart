class Validators {
  /// Enforces ALU email domains for the rubric's authentication criteria
  static String? validateAluEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final email = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (!email.endsWith('@alustudent.com') &&
        !email.endsWith('@alueducation.com')) {
      return 'Please use your @alustudent.com or @alueducation.com email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}