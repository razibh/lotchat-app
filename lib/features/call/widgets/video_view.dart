import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoView extends StatelessWidget {
  final RtcEngine engine;
  final int uid;
  final bool isLocal;

  const VideoView({
    Key? key,
    required this.engine,
    required this.uid,
    this.isLocal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLocal) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: uid),
          connection: const RtcConnection(),
        ),
      );
    }
  }
}