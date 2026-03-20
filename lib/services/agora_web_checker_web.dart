import 'dart:js_interop';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  @JS('AgoraRTC')
  external JSAny? get agoraRtc;
}

@JS('window')
external JSWindow get window;

/// Web implementation of Agora Web SDK check.
bool isAgoraRTCDefined() {
  try {
    return window.agoraRtc != null;
  } catch (e) {
    return false;
  }
}
