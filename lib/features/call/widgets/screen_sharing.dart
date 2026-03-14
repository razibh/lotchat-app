import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class ScreenSharingController {
  
  ScreenSharingController({required this.engine});
  final RtcEngine engine;
  bool isSharing = false;

  Future<bool> startScreenSharing() async {
    try {
      // Start screen sharing
      await engine.startScreenCapture(
        captureParams: const ScreenCaptureParameters(
          width: 1280,
          height: 720,
          frameRate: 15,
          bitrate: 1000,
        ),
      );
      
      isSharing = true;
      return true;
    } catch (e) {
      print('Error starting screen share: $e');
      return false;
    }
  }

  Future<void> stopScreenSharing() async {
    try {
      await engine.stopScreenCapture();
      isSharing = false;
    } catch (e) {
      print('Error stopping screen share: $e');
    }
  }

  Future<void> toggleScreenSharing() async {
    if (isSharing) {
      await stopScreenSharing();
    } else {
      await startScreenSharing();
    }
  }
}

class ScreenShareView extends StatelessWidget {

  const ScreenShareView({
    required this.engine, required this.uid, super.key,
    this.isLocal = false,
  });
  final RtcEngine engine;
  final int uid;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: isLocal
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: engine,
                canvas: VideoCanvas(uid: uid),
                connection: const RtcConnection(),
              ),
            ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RtcEngine>('engine', engine));
    properties.add(IntProperty('uid', uid));
    properties.add(DiagnosticsProperty<bool>('isLocal', isLocal));
  }
}

class ScreenSharePanel extends StatelessWidget {

  const ScreenSharePanel({
    required this.onStartShare, required this.onStopShare, required this.isSharing, super.key,
  });
  final VoidCallback onStartShare;
  final VoidCallback onStopShare;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          const Text(
            'Screen Sharing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.screen_share, color: Colors.blue),
            ),
            title: const Text('Share Screen'),
            subtitle: const Text('Share your entire screen'),
            trailing: isSharing
                ? ElevatedButton(
                    onPressed: onStopShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Stop'),
                  )
                : ElevatedButton(
                    onPressed: onStartShare,
                    child: const Text('Start'),
                  ),
          ),
          
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.window, color: Colors.green),
            ),
            title: const Text('Share Window'),
            subtitle: const Text('Share a specific window'),
            trailing: isSharing
                ? ElevatedButton(
                    onPressed: onStopShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Stop'),
                  )
                : ElevatedButton(
                    onPressed: onStartShare,
                    child: const Text('Start'),
                  ),
          ),
          
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(Icons.browser, color: Colors.orange),
            ),
            title: const Text('Share Browser Tab'),
            subtitle: const Text('Share a specific browser tab'),
            trailing: isSharing
                ? ElevatedButton(
                    onPressed: onStopShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Stop'),
                  )
                : ElevatedButton(
                    onPressed: onStartShare,
                    child: const Text('Start'),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onStartShare', onStartShare));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onStopShare', onStopShare));
    properties.add(DiagnosticsProperty<bool>('isSharing', isSharing));
  }
}

class ScreenShareIndicator extends StatelessWidget {

  const ScreenShareIndicator({
    required this.isActive, super.key,
  });
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Icon(
            Icons.screen_share,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'Sharing Screen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isActive', isActive));
  }
}