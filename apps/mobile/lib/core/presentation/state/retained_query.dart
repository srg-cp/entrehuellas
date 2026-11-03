import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bounded retention of successful presentation state, never permissions.
/// Expiry marks data stale; it does not poll. Re-entry/focus revalidates it.
class RetainedQuery with WidgetsBindingObserver {
  RetainedQuery(
    this.ref, {
    required this.freshFor,
    required this.revalidate,
    this.retainFor = const Duration(minutes: 3),
  }) {
    ref.onCancel(() {
      _observed = false;
      _scheduleRelease();
    });
    ref.onResume(() {
      _observed = true;
      _release?.cancel();
      // A listener can resume while a widget is building.
      scheduleMicrotask(check);
    });
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _disposed = true;
      _release?.cancel();
      _freshness?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
  }

  final Ref ref;
  final Duration freshFor, retainFor;
  final Future<void> Function() revalidate;
  void Function()? _releaseRetention;
  Timer? _release, _freshness;
  bool _fresh = false, _observed = true, _disposed = false;
  Future<void>? _pending;

  void markFresh() {
    if (_disposed) return;
    _releaseRetention ??= ref.keepAlive().close;
    _fresh = true;
    _freshness?.cancel();
    _freshness = Timer(freshFor, () => _fresh = false);
    if (!_observed) _scheduleRelease();
  }

  void _scheduleRelease() {
    _release?.cancel();
    _release = Timer(retainFor, () {
      _releaseRetention?.call();
      _releaseRetention = null;
    });
  }

  void forget() {
    _fresh = false;
    _freshness?.cancel();
    _releaseRetention?.call();
    _releaseRetention = null;
  }

  Future<void> check() async {
    if (_disposed || !_observed || _fresh) return;
    if (_pending != null) return _pending;
    final pending = revalidate();
    _pending = pending;
    try {
      await pending;
    } finally {
      if (identical(_pending, pending)) _pending = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(check());
  }
}
