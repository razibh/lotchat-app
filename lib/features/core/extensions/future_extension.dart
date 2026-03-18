import 'dart:async';

extension FutureExtension<T> on Future<T> {
  // Execute with timeout
  Future<T> withTimeout(Duration duration, {T? defaultValue}) {
    return timeout(
      duration,
      onTimeout: () {
        if (defaultValue != null) return defaultValue as FutureOr<T>;
        throw TimeoutException('Operation timed out');
      },
    );
  }

  // Retry on failure
  Future<T> retry({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Object)? retryIf,
  }) {
    // Future এর জন্য retry করার সঠিক পদ্ধতি
    return _retry(() => this, maxRetries, delay, retryIf);
  }

  static Future<T> _retry<T>(
      Future<T> Function() fn,
      int maxRetries,
      Duration delay,
      bool Function(Object)? retryIf,
      ) async {
    int attempts = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries || (retryIf != null && !retryIf(e))) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
  }

  // Execute with loading indicator
  Future<T> withLoading({
    void Function()? onStart,
    void Function()? onComplete,
    void Function(Object)? onError,
  }) async {
    onStart?.call();
    try {
      return await this;
    } catch (e) {
      onError?.call(e);
      rethrow;
    } finally {
      onComplete?.call();
    }
  }

  // Execute with caching
  Future<T> withCache({
    required Future<T> Function() fetch,
    required Future<void> Function(T) save,
    required Future<T?> Function() load,
    Duration? expiry,
  }) async {
    // Try to load from cache
    final cached = await load();
    if (cached != null) return cached;

    // Fetch from network
    final data = await fetch();

    // Save to cache
    await save(data);

    return data;
  }

  // Convert to stream
  Stream<T> toStream() {
    return Stream.fromFuture(this);
  }

  // Execute with fallback
  Future<T> withFallback(T fallback) {
    return catchError((_) => fallback);
  }

  // Execute with logging
  Future<T> withLogging(String operation) {
    final stopwatch = Stopwatch()..start();
    print('▶️ Starting: $operation');
    return then((value) {
      stopwatch.stop();
      print('✅ Completed: $operation (${stopwatch.elapsedMilliseconds}ms)');
      return value;
    }).catchError((error) {
      stopwatch.stop();
      print('❌ Failed: $operation (${stopwatch.elapsedMilliseconds}ms) - $error');
      throw error;
    });
  }

  // Execute with progress tracking
  Future<T> withProgress(StreamController<double> progress) async {
    progress.add(0);
    try {
      final result = await this;
      progress.add(1);
      return result;
    } catch (e) {
      progress.addError(e);
      rethrow;
    } finally {
      await progress.close();
    }
  }

  // Execute with delay
  Future<T> withDelay(Duration duration) {
    return Future.delayed(duration, () => this);
  }

  // Execute with timeout and retry
  Future<T> robust({
    Duration timeout = const Duration(seconds: 30),
    int retries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) {
    return withTimeout(timeout).retry(maxRetries: retries, delay: retryDelay);
  }
}

// ================ Static utility methods ================

// Debounce - একটানা কল থামানোর জন্য
Future<T?> debounce<T>(
    Future<T> Function() action,
    Duration duration,
    ) {
  final completer = Completer<T?>();
  Timer(duration, () async {
    try {
      final result = await action();
      completer.complete(result);
    } catch (e) {
      completer.completeError(e);
    }
  });
  return completer.future;
}

// Throttle - নির্দিষ্ট সময় পরপর কল করার জন্য
Future<T?> throttle<T>(
    Future<T> Function() action,
    Duration duration,
    ) {
  final completer = Completer<T?>();
  Timer.run(() async {
    try {
      final result = await action();
      completer.complete(result);
    } catch (e) {
      completer.completeError(e);
    }
  });
  return completer.future;
}

// Parallel execution
Future<List<T>> parallel<T>(
    List<Future<T>> futures, {
      bool stopOnError = false,
    }) async {
  if (stopOnError) {
    return Future.wait(futures);
  } else {
    final results = <T>[];
    for (var future in futures) {
      try {
        results.add(await future);
      } catch (e) {
        // Skip errors
      }
    }
    return results;
  }
}

// Sequential execution
Future<List<T>> sequential<T>(
    List<Future<T> Function()> actions,
    ) async {
  final results = <T>[];
  for (var action in actions) {
    results.add(await action());
  }
  return results;
}

// Retry utility
Future<T> retry<T>(
    Future<T> Function() fn, {
      int maxRetries = 3,
      Duration delay = const Duration(seconds: 1),
      bool Function(Object)? retryIf,
    }) async {
  int attempts = 0;
  while (true) {
    try {
      return await fn();
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries || (retryIf != null && !retryIf(e))) {
        rethrow;
      }
      await Future.delayed(delay * attempts);
    }
  }
}