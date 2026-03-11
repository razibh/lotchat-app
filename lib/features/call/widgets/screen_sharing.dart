import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class ScreenSharingController {
  final RtcEngine engine;
  bool isSharing = false;
  
  ScreenSharingController({required this.engine});

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
  final RtcEngine engine;
  final int uid;
  final bool isLocal;

  const ScreenShareView({
    Key? key,
    required this.engine,
    required this.uid,
    this.isLocal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class ScreenSharePanel extends StatelessWidget {
  final VoidCallback onStartShare;
  final VoidCallback onStopShare;
  final bool isSharing;

  const ScreenSharePanel({
    Key? key,
    required this.onStartShare,
    required this.onStopShare,
    required this.isSharing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              backgroundColor: Colors.blue.withOpacity(0.1),
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
              backgroundColor: Colors.green.withOpacity(0.1),
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
              backgroundColor: Colors.orange.withOpacity(0.1),
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
}

class ScreenShareIndicator extends StatelessWidget {
  final bool isActive;

  const ScreenShareIndicator({
    Key? key,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
}