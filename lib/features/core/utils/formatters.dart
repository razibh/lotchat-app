import 'package:intl/intl.dart';

class Formatters {
  // Format number with commas (e.g., 1,000,000)
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Format decimal number (e.g., 1,234.56)
  static String formatDecimal(double number, {int decimals = 2}) {
    final formatter = NumberFormat('#,###.##');
    return formatter.format(number);
  }

  // Format currency (e.g., $1,234.56)
  static String formatCurrency(double amount, {String symbol = r'$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format compact number (e.g., 1.2M, 500K)
  static String formatCompact(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  // Format percentage (e.g., 45.5%)
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // Format phone number (e.g., +1 (555) 123-4567)
  static String formatPhoneNumber(String phone) {
    // Remove all non-digits
    final String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11) {
      return '+${digits[0]} (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    return phone;
  }

  // Format credit card (e.g., 1234 5678 9012 3456)
  static String formatCreditCard(String cardNumber) {
    final String digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final StringBuffer buffer = StringBuffer();
    
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    
    return buffer.toString();
  }

  // Format file size (e.g., 1.5 MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Format duration (e.g., 1:30:45)
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // Format time ago (e.g., 5 minutes ago)
  static String timeAgo(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  // Format date (e.g., Jan 15, 2024)
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format time (e.g., 2:30 PM)
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Format date time (e.g., Jan 15, 2024 2:30 PM)
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  // Format to slug (e.g., Hello World -> hello-world)
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '-');
  }

  // Format to initials (e.g., John Doe -> JD)
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final List<String> words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return words.first[0].toUpperCase() + words.last[0].toUpperCase();
  }

  // Truncate text with ellipsis
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length - 3)}...';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Title case
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }
}