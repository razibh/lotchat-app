import 'package:flutter/material.dart';

class StringUtils {
  // Check if string is null or empty
  static bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  // Check if string is null or blank
  static bool isNullOrBlank(String? str) {
    return str == null || str.trim().isEmpty;
  }

  // Capitalize first letter
  static String capitalize(String str) {
    if (isNullOrEmpty(str)) return str ?? '';
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  // Capitalize each word
  static String titleCase(String str) {
    if (isNullOrEmpty(str)) return str ?? '';
    return str.split(' ').map(capitalize).join(' ');
  }

  // Convert to camelCase
  static String toCamelCase(String str) {
    if (isNullOrEmpty(str)) return str ?? '';
    final List<String> words = str.split(RegExp(r'[_\s-]'));
    return words.first.toLowerCase() +
        words.skip(1).map(capitalize).join();
  }

  // Convert to snake_case
  static String toSnakeCase(String str) {
    if (isNullOrEmpty(str)) return str ?? '';
    return str.replaceAllMapped(
      RegExp('(?<=[a-z])[A-Z]|(?<=[A-Z])[A-Z](?=[a-z])'),
      (Match match) => '_${match.group(0)!.toLowerCase()}',
    ).toLowerCase();
  }

  // Convert to kebab-case
  static String toKebabCase(String str) {
    return toSnakeCase(str).replaceAll('_', '-');
  }

  // Convert to PascalCase
  static String toPascalCase(String str) {
    if (isNullOrEmpty(str)) return str ?? '';
    final List<String> words = str.split(RegExp(r'[_\s-]'));
    return words.map(capitalize).join();
  }

  // Truncate with ellipsis
  static String truncate(String str, int length) {
    if (isNullOrEmpty(str)) return str ?? '';
    if (str.length <= length) return str;
    return '${str.substring(0, length - 3)}...';
  }

  // Check if email
  static bool isEmail(String str) {
    final RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegExp.hasMatch(str);
  }

  // Check if phone number
  static bool isPhoneNumber(String str) {
    final RegExp phoneRegExp = RegExp(
      r'^\+?[\d\s-]{10,}$',
    );
    return phoneRegExp.hasMatch(str);
  }

  // Check if URL
  static bool isUrl(String str) {
    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegExp.hasMatch(str);
  }

  // Check if contains only letters
  static bool isAlpha(String str) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  // Check if contains only numbers
  static bool isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  // Check if contains only alphanumeric
  static bool isAlphanumeric(String str) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(str);
  }

  // Extract numbers from string
  static List<int> extractNumbers(String str) {
    final Iterable<RegExpMatch> matches = RegExp(r'\d+').allMatches(str);
    return matches.map((RegExpMatch m) => int.parse(m.group(0)!)).toList();
  }

  // Extract emails from string
  static List<String> extractEmails(String str) {
    final Iterable<RegExpMatch> matches = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').allMatches(str);
    return matches.map((RegExpMatch m) => m.group(0)!).toList();
  }

  // Extract URLs from string
  static List<String> extractUrls(String str) {
    final Iterable<RegExpMatch> matches = RegExp(
      r'(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?',
    ).allMatches(str);
    return matches.map((RegExpMatch m) => m.group(0)!).toList();
  }

  // Mask string (e.g., credit card)
  static String mask(String str, {int visibleCount = 4, String maskChar = '*'}) {
    if (str.length <= visibleCount) return str;
    return str.substring(str.length - visibleCount).padLeft(str.length, maskChar);
  }

  // Reverse string
  static String reverse(String str) {
    return str.split('').reversed.join();
  }

  // Count occurrences
  static int countOccurrences(String str, String substring) {
    return substring.allMatches(str).length;
  }

  // Remove all whitespace
  static String removeWhitespace(String str) {
    return str.replaceAll(RegExp(r'\s+'), '');
  }

  // Remove all special characters
  static String removeSpecialChars(String str) {
    return str.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  // Get initials
  static String getInitials(String str, {int count = 2}) {
    if (isNullOrEmpty(str)) return '';
    final List<String> words = str.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return words.take(count).map((String w) => w[0].toUpperCase()).join();
  }

  // Get first N words
  static String firstWords(String str, int count) {
    if (isNullOrEmpty(str)) return '';
    final List<String> words = str.split(RegExp(r'\s+'));
    if (words.length <= count) return str;
    return words.take(count).join(' ');
  }

  // Get last N words
  static String lastWords(String str, int count) {
    if (isNullOrEmpty(str)) return '';
    final List<String> words = str.split(RegExp(r'\s+'));
    if (words.length <= count) return str;
    return words.skip(words.length - count).join(' ');
  }

  // Check if contains any of
  static bool containsAny(String str, List<String> values) {
    return values.any((String value) => str.contains(value));
  }

  // Check if contains all
  static bool containsAll(String str, List<String> values) {
    return values.every((String value) => str.contains(value));
  }

  // Split and trim
  static List<String> splitAndTrim(String str, Pattern pattern) {
    return str.split(pattern).map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList();
  }

  // Get common prefix
  static String commonPrefix(String str1, String str2) {
    final int minLength = str1.length < str2.length ? str1.length : str2.length;
    for (var i = 0; i < minLength; i++) {
      if (str1[i] != str2[i]) {
        return str1.substring(0, i);
      }
    }
    return str1.substring(0, minLength);
  }

  // Get common suffix
  static String commonSuffix(String str1, String str2) {
    return reverse(commonPrefix(reverse(str1), reverse(str2)));
  }

  // Levenshtein distance
  static int levenshteinDistance(String str1, String str2) {
    if (str1 == str2) return 0;
    if (str1.isEmpty) return str2.length;
    if (str2.isEmpty) return str1.length;

    final List<List<int>> matrix = List.generate(
      str1.length + 1,
      (int i) => List.generate(str2.length + 1, (int j) => 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final int cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = <int>[
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((int a, int b) => a < b ? a : b);
      }
    }

    return matrix[str1.length][str2.length];
  }

  // Similarity ratio (0-1)
  static double similarityRatio(String str1, String str2) {
    final int distance = levenshteinDistance(str1, str2);
    final int maxLength = str1.length > str2.length ? str1.length : str2.length;
    if (maxLength == 0) return 1;
    return 1.0 - distance / maxLength;
  }
}