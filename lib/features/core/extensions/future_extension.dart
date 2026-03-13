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
    return _retry(this, maxRetries, delay, retryIf);
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
    Function? onStart,
    Function? onComplete,
    Function(Object)? onError,
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
    final Object? cached = await load();
    if (cached != null) return cached;

    // Fetch from network
    final Object? data = await fetch();

    // Save to cache
    await save(data);

    return data;
  }

  // Execute with debounce
  static Future<T?> debounce<T>(
    Future<T> Function() action,
    Duration duration,
  ) {
    final Completer<T?> completer = Completer<T?>();
    Timer(duration, () async {
      try {
        final T result = await action();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  // Execute with throttle
  static Future<T?> throttle<T>(
    Future<T> Function() action,
    Duration duration,
  ) {
    final Completer<T?> completer = Completer<T?>();
    Timer.run(() async {
      try {
        final T result = await action();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
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
    final Stopwatch stopwatch = Stopwatch()..start();
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
      final Object? result = await this;
      progress.add(1);
      return result;
    } catch (e) {
      progress.addError(e);
      rethrow;
    } finally {
      progress.close();
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