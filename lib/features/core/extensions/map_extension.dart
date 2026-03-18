import 'dart:convert';

extension MapExtension<K, V> on Map<K, V> {
  // Get value or default
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  // Get value or null
  V? getOrNull(K key) {
    return this[key];
  }

  // Get required value (throws if not found)
  V required(K key) {
    if (!containsKey(key)) {
      throw ArgumentError('Required key not found: $key');
    }
    return this[key] as V; // 'as V' ব্যবহার করা হয়েছে
  }

  // Get value by type
  T? getAs<T>(K key) {
    final value = this[key];
    if (value is T) return value;
    return null;
  }

  // Merge with another map
  Map<K, V> merge(Map<K, V> other) {
    return {...this, ...other} as Map<K, V>;
  }

  // Merge with another map (mutating)
  void mergeWith(Map<K, V> other) {
    addAll(other);
  }

  // Filter keys
  Map<K, V> filterKeys(bool Function(K) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.key)),
    );
  }

  // Filter values
  Map<K, V> filterValues(bool Function(V) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.value)),
    );
  }

  // Map keys
  Map<RK, V> mapKeys<RK>(RK Function(K, V) transform) {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(
        transform(entry.key, entry.value),
        entry.value,
      )),
    );
  }

  // Map values
  Map<K, RV> mapValues<RV>(RV Function(K, V) transform) {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(
        entry.key,
        transform(entry.key, entry.value),
      )),
    );
  }

  // Map entries
  Map<RK, RV> mapEntries<RK, RV>(
      MapEntry<RK, RV> Function(K, V) transform,
      ) {
    return Map.fromEntries(
      entries.map((entry) => transform(entry.key, entry.value)),
    );
  }

  // Group by key function
  Map<RK, Map<K, V>> groupBy<RK>(RK Function(K, V) keyFunction) {
    final result = <RK, Map<K, V>>{};
    forEach((key, value) {
      final groupKey = keyFunction(key, value);
      if (!result.containsKey(groupKey)) {
        result[groupKey] = {};
      }
      result[groupKey]![key] = value; // Null check added
    });
    return result;
  }

  // Invert map (swap keys and values)
  Map<V, K> invert() {
    return Map.fromEntries(
      entries.map((entry) => MapEntry(entry.value, entry.key)),
    );
  }

  // Get keys as list
  List<K> get keyList => keys.toList();

  // Get values as list
  List<V> get valueList => values.toList();

  // Check if has any keys matching test
  bool anyKey(bool Function(K) test) {
    return keys.any(test);
  }

  // Check if has any values matching test
  bool anyValue(bool Function(V) test) {
    return values.any(test);
  }

  // Get keys matching test
  List<K> keysWhere(bool Function(K) test) {
    return keys.where(test).toList();
  }

  // Get values matching test
  List<V> valuesWhere(bool Function(V) test) {
    return values.where(test).toList();
  }

  // Remove null values
  Map<K, V> removeNulls() {
    removeWhere((_, value) => value == null);
    return this;
  }

  // Remove empty values
  Map<K, V> removeEmpties() {
    removeWhere((_, value) {
      if (value is String) return value.isEmpty;
      if (value is Iterable) return value.isEmpty;
      if (value is Map) return value.isEmpty;
      return false;
    });
    return this;
  }

  // Deep merge
  Map<K, V> deepMerge(Map<K, V> other) {
    final result = <K, V>{};
    for (final key in {...keys, ...other.keys}) {
      final thisValue = this[key];
      final otherValue = other[key];

      if (thisValue is Map && otherValue is Map) {
        // Recursive deep merge for maps
        result[key] = (thisValue as Map).deepMerge(otherValue as Map) as V;
      } else if (thisValue is List && otherValue is List) {
        result[key] = [...thisValue, ...otherValue] as V;
      } else {
        result[key] = (otherValue ?? thisValue) as V; // Type casting added
      }
    }
    return result;
  }

  // Get nested value using path
  dynamic getNested(List<dynamic> path) {
    var current = this as dynamic;
    for (final key in path) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  // Set nested value using path
  void setNested(List<dynamic> path, dynamic value) {
    if (path.isEmpty) return;

    var current = this as dynamic;
    for (int i = 0; i < path.length - 1; i++) {
      final key = path[i];
      if (current[key] == null) {
        current[key] = <dynamic, dynamic>{};
      }
      current = current[key];
    }
    current[path.last] = value;
  }

  // Update values
  void updateWhere(bool Function(K, V) test, V Function(V) update) {
    forEach((key, value) {
      if (test(key, value)) {
        this[key] = update(value);
      }
    });
  }

  // Sort by keys
  Map<K, V> sortedByKeys([int Function(K, K)? compare]) {
    final sortedKeys = keys.toList()..sort(compare);
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, this[key] as V)), // 'as V' added
    );
  }

  // Sort by values
  Map<K, V> sortedByValues([int Function(V, V)? compare]) {
    final entriesList = entries.toList()
      ..sort((a, b) => (compare ?? _defaultCompare)(a.value, b.value));
    return Map.fromEntries(entriesList);
  }

  static int _defaultCompare(dynamic a, dynamic b) =>
      a.toString().compareTo(b.toString());

  // Convert to query string
  String toQueryString() {
    return entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(this);
  }

  // Get difference between two maps
  Map<K, dynamic> difference(Map<K, V> other) {
    final diff = <K, dynamic>{};
    for (final key in {...keys, ...other.keys}) {
      if (!containsKey(key)) {
        diff[key] = {'removed': other[key]};
      } else if (!other.containsKey(key)) {
        diff[key] = {'added': this[key]};
      } else if (this[key] != other[key]) {
        diff[key] = {
          'old': other[key],
          'new': this[key],
        };
      }
    }
    return diff;
  }
}