import 'dart:math';

extension ListExtension<T> on List<T> {
  // Get random element
  T? get random {
    if (isEmpty) return null;
    return this[Random().nextInt(length)];
  }

  // Get safe element
  T? safeElementAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  // Add if not null
  void addIfNotNull(T? element) {
    if (element != null) add(element);
  }

  // Add all if not null
  void addAllIfNotNull(Iterable<T?> elements) {
    for (final element in elements) {
      if (element != null) add(element);
    }
  }

  // Remove duplicates
  List<T> distinct([bool Function(T a, T b)? equals]) {
    if (equals != null) {
      final result = <T>[];
      for (final element in this) {
        if (!result.any((e) => equals(e, element))) {
          result.add(element);
        }
      }
      return result;
    }
    return toSet().toList();
  }

  // Group by
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  // Split into chunks
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  // Join with last separator
  String joinWithLast({String separator = ', ', String lastSeparator = ' and '}) {
    if (isEmpty) return '';
    if (length == 1) return '${this[0]}';
    if (length == 2) return '${this[0]}$lastSeparator${this[1]}';

    final allButLast = sublist(0, length - 1).join(separator);
    return '$allButLast$lastSeparator${last}';
  }

  // Get first element or null
  T? get firstOrNull => isNotEmpty ? first : null;

  // Get last element or null
  T? get lastOrNull => isNotEmpty ? last : null;

  // Swap elements
  void swap(int index1, int index2) {
    if (index1 == index2) return;
    if (index1 < 0 || index1 >= length) return;
    if (index2 < 0 || index2 >= length) return;
    final temp = this[index1];
    this[index1] = this[index2];
    this[index2] = temp;
  }

  // Move element
  void move(int from, int to) {
    if (from == to) return;
    if (from < 0 || from >= length) return;
    if (to < 0 || to >= length) return;
    final element = removeAt(from);
    insert(to, element);
  }

  // Update element
  void updateWhere(bool Function(T) test, T Function(T) update) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = update(this[i]);
      }
    }
  }

  // Remove where
  int removeWhereAndCount(bool Function(T) test) {
    final before = length;
    removeWhere(test);
    return before - length;
  }

  // Replace element
  void replaceWhere(bool Function(T) test, T newValue) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = newValue;
      }
    }
  }

  // Find index of element
  int? indexOfWhere(bool Function(T) test) {
    final index = indexWhere(test);
    return index != -1 ? index : null;
  }

  // Find last index of element
  int? lastIndexOfWhere(bool Function(T) test) {
    final index = lastIndexWhere(test);
    return index != -1 ? index : null;
  }

  // Get element or default
  T getOrDefault(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return this[index];
  }

  // Check if all elements are unique
  bool get allUnique => length == toSet().length;

  // Get duplicates
  List<T> get duplicates {
    final seen = <T>{};
    final duplicates = <T>{};
    for (final element in this) {
      if (!seen.add(element)) {
        duplicates.add(element);
      }
    }
    return duplicates.toList();
  }

  // Count occurrences
  Map<T, int> get frequencies {
    final map = <T, int>{};
    for (final element in this) {
      map[element] = (map[element] ?? 0) + 1;
    }
    return map;
  }

  // Sort by multiple criteria
  void sortBy(List<Comparable Function(T)> selectors) {
    sort((a, b) {
      for (final selector in selectors) {
        final comparison = selector(a).compareTo(selector(b));
        if (comparison != 0) return comparison;
      }
      return 0;
    });
  }

  // Get min by selector
  T? minBy<R extends Comparable>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) < 0 ? a : b);
  }

  // Get max by selector
  T? maxBy<R extends Comparable>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) > 0 ? a : b);
  }

  // Sum by selector
  num sumBy(num Function(T) selector) {
    return fold(0, (num sum, element) => sum + selector(element));
  }

  // Average by selector
  double averageBy(num Function(T) selector) {
    if (isEmpty) return 0;
    return sumBy(selector) / length;
  }

  // Filter not null
  List<T> filterNotNull() {
    return where((element) => element != null).cast<T>().toList();
  }

  // Paginate
  List<T> paginate(int page, int pageSize) {
    final start = page * pageSize;
    if (start >= length) return [];
    final end = (start + pageSize) > length ? length : start + pageSize;
    return sublist(start, end);
  }

  // Shuffle with seed
  void shuffleWithSeed(int seed) {
    final random = Random(seed);
    for (int i = length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      swap(i, j);
    }
  }
}