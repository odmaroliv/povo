class Validators {
  // Email validator
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Regular expression for email validation
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(email);
  }

  // Password validator (minimum 6 characters)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Name validator (non-empty)
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  // Phone number validator
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;

    // Regular expression for phone number validation
    const pattern = r'^\+?[0-9]{10,15}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(phone);
  }

  // Date validator in format DD/MM/YYYY
  static bool isValidDate(String date) {
    if (date.isEmpty) return false;

    // Regular expression for date validation (DD/MM/YYYY)
    const pattern = r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)\d\d$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(date)) return false;

    // Additional validation for valid day in month
    final parts = date.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    if (month == 2) {
      // February
      if (isLeapYear(year)) {
        return day <= 29;
      } else {
        return day <= 28;
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November
      return day <= 30;
    }

    return true;
  }

  // Check if a year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Event code validator (alphanumeric, 6 characters)
  static bool isValidEventCode(String code) {
    if (code.isEmpty) return false;

    const pattern = r'^[A-Z0-9]{6}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(code);
  }
}
