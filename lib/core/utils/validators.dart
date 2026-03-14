class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final RegExp phoneRegExp = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number';
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegExp.hasMatch(value)) {
      return 'Username can only contain letters, numbers and underscore';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final int? amount = int.tryParse(value);
    if (amount == null) {
      return 'Invalid amount';
    }
    
    if (amount < min) {
      return 'Minimum amount is $min';
    }
    
    if (amount > max) {
      return 'Maximum amount is $max';
    }
    
    return null;
  }

  // URL validation
  static bool isValidUrl(String url) {
    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegExp.hasMatch(url);
  }
}