/// Content identity and visibility, independent of widget rebuilds.
class AutoSpeechGate {
  bool visible = false;
  Object? activeTab;
  Object? _lastKey;
  int _revision = 0;

  void enter() {
    visible = true;
    _lastKey = null;
    _revision++;
  }

  void leave() {
    visible = false;
    _revision++;
  }

  void selectTab(Object tab) {
    if (activeTab == tab) return;
    activeTab = tab;
    _lastKey = null;
    _revision++;
  }

  int? request(Object key, {bool enabled = true, Object? tab}) {
    if (!visible || !enabled || (tab != null && tab != activeTab)) return null;
    final identity = (activeTab, key);
    if (_lastKey == identity) return null;
    _lastKey = identity;
    return ++_revision;
  }

  bool isCurrent(int revision) => visible && _revision == revision;
}
