import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // DiagnosticPropertiesBuilder এর জন্য
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoView extends StatelessWidget {
  final RtcEngine engine;
  final int uid;
  final bool isLocal;

  const VideoView({
    required this.engine,
    required this.uid,
    super.key,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    // null safety check
    try {
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
    } catch (e) {
      debugPrint('Error creating video view: $e');
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Video Error',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RtcEngine>('engine', engine));
    properties.add(IntProperty('uid', uid));
    properties.add(DiagnosticsProperty<bool>('isLocal', isLocal));
  }
}

// Optional: Loading state সহ VideoView
class VideoViewWithLoading extends StatelessWidget {
  final RtcEngine engine;
  final int uid;
  final bool isLocal;
  final Widget? placeholder;

  const VideoViewWithLoading({
    required this.engine,
    required this.uid,
    super.key,
    this.isLocal = false,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video View
        VideoView(
          engine: engine,
          uid: uid,
          isLocal: isLocal,
        ),

        // Loading indicator
        Center(
          child: placeholder ??
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

// Audio-only view (when video is off)
class AudioOnlyView extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final bool isSpeaking;
  final bool isMuted;

  const AudioOnlyView({
    required this.userName,
    super.key,
    this.avatarUrl,
    this.isSpeaking = false,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with speaking indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  )
                      : null,
                ),
                if (isSpeaking)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isMuted)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Muted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Video view with controls overlay
class VideoViewWithControls extends StatelessWidget {
  final RtcEngine engine;
  final int uid;
  final bool isLocal;
  final VoidCallback? onMuteToggle;
  final VoidCallback? onCameraToggle;
  final bool isMuted;
  final bool isCameraOn;

  const VideoViewWithControls({
    required this.engine,
    required this.uid,
    required this.isLocal,
    super.key,
    this.onMuteToggle,
    this.onCameraToggle,
    this.isMuted = false,
    this.isCameraOn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video View
        if (isCameraOn)
          VideoView(
            engine: engine,
            uid: uid,
            isLocal: isLocal,
          )
        else
          AudioOnlyView(
            userName: 'User',
            isSpeaking: !isMuted,
            isMuted: isMuted,
          ),

        // Controls overlay (only for local user)
        if (isLocal)
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mute button
                if (onMuteToggle != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isMuted ? Icons.mic_off : Icons.mic,
                        color: isMuted ? Colors.red : Colors.white,
                        size: 16,
                      ),
                      onPressed: onMuteToggle,
                    ),
                  ),

                const SizedBox(width: 4),

                // Camera toggle button
                if (onCameraToggle != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isCameraOn ? Icons.videocam : Icons.videocam_off,
                        color: isCameraOn ? Colors.white : Colors.red,
                        size: 16,
                      ),
                      onPressed: onCameraToggle,
                    ),
                  ),
              ],
            ),
          ),

        // User name label
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isLocal ? 'You' : 'User $uid',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}