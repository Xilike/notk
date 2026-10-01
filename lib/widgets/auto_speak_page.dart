import 'dart:async';
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/auto_speech_gate.dart';
import '../services/speech_service.dart';

class EducationalRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    unawaited(SpeechService.stop());
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    unawaited(SpeechService.stop());
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    unawaited(SpeechService.stop());
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

final educationalRouteObserver = EducationalRouteObserver();

/// Entry/return and explicit content changes only; never invoked from build.
mixin AutoSpeakPage<T extends StatefulWidget> on State<T>
    implements RouteAware {
  final _autoGate = AutoSpeechGate();
  ModalRoute<dynamic>? _speechRoute;
  TabController? _speechTabs;
  Object? _observedContent;
  Object get autoSpeechKey;
  bool get canAutoSpeak => true;
  bool get educationalPageVisible => _speechRoute?.isCurrent == true;
  Future<void> speakVisibleContent();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_speechRoute == route) return;
    educationalRouteObserver.unsubscribe(this);
    _speechRoute = route;
    if (route != null) educationalRouteObserver.subscribe(this, route);
  }

  void _schedule() {
    final ticket = _autoGate.request(autoSpeechKey,
        enabled: canAutoSpeak && AppState.instance.autoSpeakEnabled);
    if (ticket == null) return;

    final manualRevision = SpeechService.manualRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_autoGate.isCurrent(ticket) ||
          _speechRoute?.isCurrent != true ||
          !canAutoSpeak ||
          !AppState.instance.autoSpeakEnabled ||
          manualRevision != SpeechService.manualRevision) {
        return;
      }
      unawaited(speakVisibleContent());
    });
  }

  void autoSpeechContentChanged() {
    final identity = (_autoGate.activeTab, autoSpeechKey);
    if (!_autoGate.visible || _observedContent == identity) return;
    _observedContent = identity;
    unawaited(SpeechService.stop());
    _schedule();
  }

  /// Optional tab integration: only the owning page observes settled changes.
  /// Existing educational pages use explicit Previous/Next navigation.
  void watchAutoSpeechTabs(TabController controller) {
    _speechTabs?.removeListener(_tabChanged);
    _speechTabs?.animation?.removeListener(_tabChanged);
    _speechTabs = controller;
    _autoGate.selectTab(controller.index);
    controller.addListener(_tabChanged);
    controller.animation?.addListener(_tabChanged);
  }

  void _tabChanged() {
    final tabs = _speechTabs;
    if (tabs == null ||
        tabs.indexIsChanging ||
        _autoGate.activeTab == tabs.index ||
        ((tabs.animation?.value ?? tabs.index.toDouble()) - tabs.index).abs() >
            0.001) {
      return;
    }
    _autoGate.selectTab(tabs.index);
    autoSpeechContentChanged();
  }

  @override
  void didPush() {
    if (_speechRoute?.isCurrent != true) return;
    _autoGate.enter();
    _observedContent = (_autoGate.activeTab, autoSpeechKey);
    _schedule();
  }

  @override
  void didPopNext() => didPush();
  @override
  void didPushNext() => _autoGate.leave();
  @override
  void didPop() => _autoGate.leave();

  @override
  void dispose() {
    _autoGate.leave();
    educationalRouteObserver.unsubscribe(this);
    _speechTabs?.removeListener(_tabChanged);
    _speechTabs?.animation?.removeListener(_tabChanged);
    // An old route's delayed disposal must not cancel a newer route's speech.
    if (_speechRoute?.isCurrent == true) unawaited(SpeechService.stop());
    super.dispose();
  }
}
