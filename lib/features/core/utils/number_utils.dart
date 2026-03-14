import 'dart:math' as math;

class NumberUtils {
  // Format number with commas
  static String formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  // Format as K/M/B
  static String formatCompact(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Format as currency
  static String formatCurrency(num amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format as percentage
  static String formatPercentage(num value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // Check if number is even
  static bool isEven(int number) {
    return number % 2 == 0;
  }

  // Check if number is odd
  static bool isOdd(int number) {
    return !isEven(number);
  }

  // Check if number is prime
  static bool isPrime(int number) {
    if (number < 2) return false;
    for (var i = 2; i <= math.sqrt(number); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  // Get factorial
  static int factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial not defined for negative numbers');
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }

  // Get fibonacci
  static int fibonacci(int n) {
    if (n < 0) throw ArgumentError('Fibonacci not defined for negative numbers');
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }

  // Get greatest common divisor
  static int gcd(int a, int b) {
    while (b != 0) {
      final int temp = b;
      b = a % b;
      a = temp;
    }
    return a.abs();
  }

  // Get least common multiple
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ gcd(a, b);
  }

  // Round to decimal places
  static double roundTo(double value, int places) {
    final num mod = math.pow(10.0, places);
    return (value * mod).roundToDouble() / mod;
  }

  // Ceil to decimal places
  static double ceilTo(double value, int places) {
    final num mod = math.pow(10.0, places);
    return (value * mod).ceilToDouble() / mod;
  }

  // Floor to decimal places
  static double floorTo(double value, int places) {
    final num mod = math.pow(10.0, places);
    return (value * mod).floorToDouble() / mod;
  }

  // Clamp between min and max
  static num clamp(num value, num min, num max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // Map from one range to another
  static double mapRange(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
  }

  // Normalize to 0-1 range
  static double normalize(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  // Denormalize from 0-1 range
  static double denormalize(double value, double min, double max) {
    return min + value * (max - min);
  }

  // Get digits of number
  static List<int> getDigits(int number) {
    return number.toString().split('').map(int.parse).toList();
  }

  // Sum of digits
  static int digitSum(int number) {
    return getDigits(number).reduce((int a, int b) => a + b);
  }

  // Product of digits
  static int digitProduct(int number) {
    return getDigits(number).reduce((int a, int b) => a * b);
  }

  // Reverse number
  static int reverse(int number) {
    return int.parse(number.toString().split('').reversed.join());
  }

  // Check if palindrome
  static bool isPalindrome(int number) {
    return number.toString() == number.toString().split('').reversed.join();
  }

  // Convert to roman numerals
  static String toRoman(int number) {
    if (number < 1 || number > 3999) {
      throw ArgumentError('Roman numerals only defined for 1-3999');
    }

    final List<int> values = <int>[1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    final List<String> symbols = <String>['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];

    int remaining = number;
    String result = '';

    for (int i = 0; i < values.length; i++) {
      while (remaining >= values[i]) {
        result += symbols[i];
        remaining -= values[i];
      }
    }

    return result;
  }

  // Convert to words (English)
  static String toWords(int number) {
    if (number == 0) return 'zero';

    final List<String> units = <String>['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
    final List<String> teens = <String>['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
    final List<String> tens = <String>['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

    if (number < 10) return units[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      final int unit = number % 10;
      return tens[number ~/ 10] + (unit > 0 ? '-${units[unit]}' : '');
    }
    if (number < 1000) {
      final int hundred = number ~/ 100;
      final int remainder = number % 100;
      return '${units[hundred]} hundred${remainder > 0 ? ' and ${toWords(remainder)}' : ''}';
    }
    if (number < 1000000) {
      final int thousand = number ~/ 1000;
      final int remainder = number % 1000;
      return '${toWords(thousand)} thousand${remainder > 0 ? ' ${toWords(remainder)}' : ''}';
    }
    return number.toString();
  }

  // Get ordinal suffix
  static String getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Get ordinal
  static String toOrdinal(int number) {
    return '$number${getOrdinalSuffix(number)}';
  }
}