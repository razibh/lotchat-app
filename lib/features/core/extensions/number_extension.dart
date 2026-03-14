import 'package:intl/intl.dart';

extension IntExtension on int {
  // Format number with commas
  String get formatWithCommas {
    final NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(this);
  }

  // Format as K/M/B
  String get formatCompact {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  // Format as currency
  String toCurrency({String symbol = r'$', int decimalDigits = 0}) {
    final NumberFormat formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  // Format as percentage
  String toPercentage({int decimalDigits = 0}) {
    return '$this%';
  }

  // Format as file size
  String get toFileSize {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Format as duration
  String get toDurationString {
    final int hours = this ~/ 3600;
    final int minutes = (this % 3600) ~/ 60;
    final int seconds = this % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Check if even
  bool get isEven => this % 2 == 0;

  // Check if odd
  bool get isOdd => !isEven;

  // Check if prime
  bool get isPrime {
    if (this < 2) return false;
    for (var i = 2; i <= sqrt(this); i++) {
      if (this % i == 0) return false;
    }
    return true;
  }

  // Get factorial
  int get factorial {
    if (this < 0) throw ArgumentError('Factorial not defined for negative numbers');
    if (this <= 1) return 1;
    return this * (this - 1).factorial;
  }

  // Get fibonacci
  int get fibonacci {
    if (this < 0) throw ArgumentError('Fibonacci not defined for negative numbers');
    if (this <= 1) return this;
    return (this - 1).fibonacci + (this - 2).fibonacci;
  }

  // Get roman numeral
  String get toRoman {
    if (this < 1 || this > 3999) {
      throw ArgumentError('Roman numerals only defined for 1-3999');
    }

    final List<int> values = <int>[1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    final List<String> symbols = <String>['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];

    int remaining = this;
    String result = '';

    for (int i = 0; i < values.length; i++) {
      while (remaining >= values[i]) {
        result += symbols[i];
        remaining -= values[i];
      }
    }

    return result;
  }

  // Clamp between min and max
  int clampBetween(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  // Convert to words (English)
  String get toWords {
    if (this == 0) return 'zero';

    final List<String> units = <String>['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
    final List<String> teens = <String>['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
    final List<String> tens = <String>['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

    if (this < 10) return units[this];
    if (this < 20) return teens[this - 10];
    if (this < 100) {
      final int unit = this % 10;
      return tens[this ~/ 10] + (unit > 0 ? '-${units[unit]}' : '');
    }
    if (this < 1000) {
      final int hundred = this ~/ 100;
      final int remainder = this % 100;
      return '${units[hundred]} hundred${remainder > 0 ? ' and ${remainder.toWords}' : ''}';
    }
    if (this < 1000000) {
      final int thousand = this ~/ 1000;
      final int remainder = this % 1000;
      return '${thousand.toWords} thousand${remainder > 0 ? ' ${remainder.toWords}' : ''}';
    }
    return toString();
  }

  // Get ordinal suffix
  String get ordinalSuffix {
    if (this >= 11 && this <= 13) return 'th';
    switch (this % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  // Get ordinal
  String get ordinal => '$this$ordinalSuffix';

  // Convert to binary
  String get toBinary => toRadixString(2);

  // Convert to hexadecimal
  String get toHex => toRadixString(16).toUpperCase();

  // Convert to octal
  String get toOctal => toRadixString(8);

  // Get digits
  List<int> get digits {
    return toString().split('').map(int.parse).toList();
  }

  // Sum of digits
  int get digitSum => digits.reduce((int a, int b) => a + b);

  // Product of digits
  int get digitProduct => digits.reduce((int a, int b) => a * b);

  // Reverse number
  int get reversed => int.parse(toString().split('').reversed.join());

  // Check if palindrome
  bool get isPalindrome => toString() == toString().split('').reversed.join();

  // Convert to time
  Duration get toDuration => Duration(seconds: this);

  // Convert to DateTime (as seconds since epoch)
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this * 1000);
}

extension DoubleExtension on double {
  // Format number with commas
  String formatWithCommas([int decimals = 2]) {
    final NumberFormat formatter = NumberFormat('#,###.##');
    return formatter.format(this);
  }

  // Format as currency
  String toCurrency({String symbol = r'$', int decimalDigits = 2}) {
    final NumberFormat formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  // Format as percentage
  String toPercentage({int decimalDigits = 1}) {
    return '${(this * 100).toStringAsFixed(decimalDigits)}%';
  }

  // Round to decimal places
  double roundTo(int places) {
    final double mod = pow(10, places);
    return (this * mod).roundToDouble() / mod;
  }

  // Ceil to decimal places
  double ceilTo(int places) {
    final double mod = pow(10, places);
    return (this * mod).ceilToDouble() / mod;
  }

  // Floor to decimal places
  double floorTo(int places) {
    final double mod = pow(10, places);
    return (this * mod).floorToDouble() / mod;
  }

  // Clamp between min and max
  double clampBetween(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  // Convert to fraction
  String toFraction([int maxDenominator = 1000]) {
    final double tolerance = 1.0 / (2 * maxDenominator);
    
    int numerator = 1;
    int denominator = 1;
    int bestNumerator = 1;
    int bestDenominator = 1;
    double bestError = (this - numerator / denominator).abs();

    while (denominator <= maxDenominator) {
      final double error = (this - numerator / denominator).abs();
      if (error < bestError) {
        bestError = error;
        bestNumerator = numerator;
        bestDenominator = denominator;
      }
      if (numerator / denominator < this) {
        numerator++;
      } else {
        denominator++;
        numerator = (this * denominator).round();
      }
    }

    if (bestError < tolerance) {
      return '$bestNumerator/$bestDenominator';
    }
    return toStringAsFixed(3);
  }

  // Check if approximately equal
  bool approxEquals(double other, [double epsilon = 1e-10]) {
    return (this - other).abs() < epsilon;
  }

  // Convert to angle (radians to degrees)
  double get toDegrees => this * 180 / pi;

  // Convert to angle (degrees to radians)
  double get toRadians => this * pi / 180;

  // Normalize to range [0, 1]
  double normalize(double min, double max) {
    return (this - min) / (max - min);
  }

  // Denormalize from range [0, 1]
  double denormalize(double min, double max) {
    return min + this * (max - min);
  }

  // Map from one range to another
  double map(double fromMin, double fromMax, double toMin, double toMax) {
    return toMin + (this - fromMin) * (toMax - toMin) / (fromMax - fromMin);
  }

  // Get sign (-1, 0, 1)
  int get sign => this > 0 ? 1 : (this < 0 ? -1 : 0);

  // Get absolute value
  double get abs => this < 0 ? -this : this;

  // Get square root
  double get sqrt => sqrt(this);

  // Get power
  double pow(double exponent) => math.pow(this, exponent).toDouble();
}