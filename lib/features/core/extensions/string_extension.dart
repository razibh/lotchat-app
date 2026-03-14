import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  // Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((String word) => word.capitalize).join(' ');
  }

  // Convert to camelCase
  String get camelCase {
    if (isEmpty) return this;
    final List<String> words = split(RegExp(r'[_\s-]'));
    return words.first.toLowerCase() +
        words.skip(1).map((String word) => word.capitalize).join();
  }

  // Convert to snake_case
  String get snakeCase {
    if (isEmpty) return this;
    return replaceAllMapped(
      RegExp('(?<=[a-z])[A-Z]|(?<=[A-Z])[A-Z](?=[a-z])'),
      (Match match) => '_${match.group(0)!.toLowerCase()}',
    ).toLowerCase();
  }

  // Convert to kebab-case
  String get kebabCase {
    return snakeCase.replaceAll('_', '-');
  }

  // Convert to PascalCase
  String get pascalCase {
    if (isEmpty) return this;
    final List<String> words = split(RegExp(r'[_\s-]'));
    return words.map((String word) => word.capitalize).join();
  }

  // Truncate with ellipsis
  String truncate(int length, {String ellipsis = '...'}) {
    if (this.length <= length) return this;
    return substring(0, length - ellipsis.length) + ellipsis;
  }

  // Check if email
  bool get isEmail {
    final RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegExp.hasMatch(this);
  }

  // Check if phone number
  bool get isPhoneNumber {
    final RegExp phoneRegExp = RegExp(
      r'^\+?[\d\s-]{10,}$',
    );
    return phoneRegExp.hasMatch(this);
  }

  // Check if URL
  bool get isUrl {
    final RegExp urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegExp.hasMatch(this);
  }

  // Check if contains only letters
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  // Check if contains only numbers
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  // Check if contains only alphanumeric
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  // Check if strong password
  bool get isStrongPassword {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegExp.hasMatch(this);
  }

  // Extract numbers
  List<int> get extractNumbers {
    final Iterable<RegExpMatch> matches = RegExp(r'\d+').allMatches(this);
    return matches.map((RegExpMatch m) => int.parse(m.group(0)!)).toList();
  }

  // Extract emails
  List<String> get extractEmails {
    final Iterable<RegExpMatch> matches = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').allMatches(this);
    return matches.map((RegExpMatch m) => m.group(0)!).toList();
  }

  // Extract URLs
  List<String> get extractUrls {
    final Iterable<RegExpMatch> matches = RegExp(
      r'(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?',
    ).allMatches(this);
    return matches.map((RegExpMatch m) => m.group(0)!).toList();
  }

  // Mask string
  String mask({int visibleCount = 4, String maskChar = '*'}) {
    if (length <= visibleCount) return this;
    return substring(length - visibleCount).padLeft(length, maskChar);
  }

  // Reverse string
  String get reversed => split('').reversed.join();

  // Count occurrences
  int countOccurrences(String substring) {
    return substring.allMatches(this).length;
  }

  // Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  // Remove all special characters
  String get removeSpecialChars => replaceAll(RegExp(r'[^\w\s]'), '');

  // Get initials (for avatar)
  String get initials {
    if (isEmpty) return '';
    final List<String> words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return words.first[0].toUpperCase() + words.last[0].toUpperCase();
  }

  // Get first N words
  String firstWords(int count) {
    final List<String> words = split(RegExp(r'\s+'));
    if (words.length <= count) return this;
    return '${words.take(count).join(' ')}...';
  }

  // Get last N words
  String lastWords(int count) {
    final List<String> words = split(RegExp(r'\s+'));
    if (words.length <= count) return this;
    return words.skip(words.length - count).join(' ');
  }

  // Convert to slug
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '-');
  }

  // Convert to HTML entities
  String get toHtmlEntities {
    return replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  // Convert from HTML entities
  String get fromHtmlEntities {
    return replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  // Levenshtein distance
  int levenshteinDistance(String other) {
    if (this == other) return 0;
    if (isEmpty) return other.length;
    if (other.isEmpty) return length;

    final List<List<int>> matrix = List<List<int>>.generate(length + 1,
        (int i) => List.generate(other.length + 1, (int j) => 0),);

    for (int i = 0; i <= length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= other.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= length; i++) {
      for (int j = 1; j <= other.length; j++) {
        final int cost = this[i - 1] == other[j - 1] ? 0 : 1;
        matrix[i][j] = <int>[
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((int a, int b) => a < b ? a : b);
      }
    }

    return matrix[length][other.length];
  }

  // Similarity ratio (0-1)
  double similarityRatio(String other) {
    final int distance = levenshteinDistance(other);
    final int maxLength = length > other.length ? length : other.length;
    if (maxLength == 0) return 1;
    return 1.0 - distance / maxLength;
  }

  // Check if contains any of
  bool containsAny(Iterable<String> values) {
    return values.any(contains);
  }

  // Check if contains all
  bool containsAll(Iterable<String> values) {
    return values.every(contains);
  }

  // Split and trim
  List<String> splitAndTrim(Pattern pattern) {
    return split(pattern).map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList();
  }

  // To title case with exceptions
  String toTitleCase({List<String>? exceptions}) {
    final List<String> wordExceptions = exceptions ?? <String>['a', 'an', 'the', 'and', 'but', 'or', 'for', 'nor', 'on', 'at', 'to', 'by', 'with'];

    return split(' ').mapIndexed((int index, String word) {
      if (index == 0 || index == split(' ').length - 1 || !wordExceptions.contains(word.toLowerCase())) {
        return word.capitalize;
      }
      return word.toLowerCase();
    }).join(' ');
  }

  // To sentence case
  String get toSentenceCase {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  // To constant case (UPPER_CASE)
  String get toConstantCase {
    return toUpperCase().replaceAll(RegExp(r'\s+'), '_');
  }

  // Get plural form (simple)
  String get plural {
    if (endsWith('y') && !endsWith(RegExp('[aeiou]y'))) {
      return '${substring(0, length - 1)}ies';
    }
    if (endsWith('s') || endsWith('sh') || endsWith('ch') || endsWith('x') || endsWith('z')) {
      return '${this}es';
    }
    return '${this}s';
  }

  // Get singular form (simple)
  String get singular {
    if (endsWith('ies') && length > 3) {
      return '${substring(0, length - 3)}y';
    }
    if (endsWith('es') && length > 2) {
      if (substring(length - 4, length - 2) == 'sh' ||
          substring(length - 4, length - 2) == 'ch') {
        return substring(0, length - 2);
      }
    }
    if (endsWith('s') && length > 1) {
      return substring(0, length - 1);
    }
    return this;
  }
}

extension ListStringExtension on List<String> {
  // Convert to sentence with commas and 'and'
  String toSentence({String separator = ', ', String lastSeparator = ' and '}) {
    if (isEmpty) return '';
    if (length == 1) return first;
    if (length == 2) return '$first$lastSeparator$last';
    return '${sublist(0, length - 1).join(separator)}$lastSeparator$last';
  }
}

typedef IndexedStringMapper = String Function(int index, String value);

extension IterableStringExtension on Iterable<String> {
  Iterable<String> mapIndexed(IndexedStringMapper mapper) {
    int index = 0;
    return map((String e) => mapper(index++, e));
  }
}