import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';  // DiagnosticPropertiesBuilder এর জন্য

class CallSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> initialSettings;

  const CallSettingsScreen({
    super.key,
    this.initialSettings = const {
      'audioDevice': 'speaker',
      'videoQuality': 'hd',
      'noiseSuppression': true,
      'echoCancellation': true,
      'autoGainControl': true,
      'recordCall': false,
      'virtualBackground': false,
      'backgroundBlur': false,
      'lowLightMode': false,
    },
  });

  @override
  State<CallSettingsScreen> createState() => _CallSettingsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('initialSettings', initialSettings));
  }
}

class _CallSettingsScreenState extends State<CallSettingsScreen> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map.from(widget.initialSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Settings'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          // Audio Settings
          _buildSection(
            title: 'Audio',
            icon: Icons.audio_file,
            children: [
              _buildRadioTile<String>(
                title: 'Audio Output',
                value: _settings['audioDevice'] as String,
                items: const [
                  {'value': 'speaker', 'label': 'Speaker', 'icon': Icons.volume_up},
                  {'value': 'earpiece', 'label': 'Earpiece', 'icon': Icons.phone_in_talk},
                  {'value': 'headphones', 'label': 'Headphones', 'icon': Icons.headset},
                  {'value': 'bluetooth', 'label': 'Bluetooth', 'icon': Icons.bluetooth_audio},
                ],
                onChanged: (String value) => setState(() => _settings['audioDevice'] = value),
              ),
              _buildSwitchTile(
                title: 'Noise Suppression',
                value: _settings['noiseSuppression'] as bool,
                onChanged: (bool value) => setState(() => _settings['noiseSuppression'] = value),
              ),
              _buildSwitchTile(
                title: 'Echo Cancellation',
                value: _settings['echoCancellation'] as bool,
                onChanged: (bool value) => setState(() => _settings['echoCancellation'] = value),
              ),
              _buildSwitchTile(
                title: 'Auto Gain Control',
                value: _settings['autoGainControl'] as bool,
                onChanged: (bool value) => setState(() => _settings['autoGainControl'] = value),
              ),
            ],
          ),

          // Video Settings
          _buildSection(
            title: 'Video',
            icon: Icons.videocam,
            children: [
              _buildRadioTile<String>(
                title: 'Video Quality',
                value: _settings['videoQuality'] as String,
                items: const [
                  {'value': 'low', 'label': 'Low (480p)', 'icon': Icons.hd},
                  {'value': 'sd', 'label': 'SD (720p)', 'icon': Icons.hd},
                  {'value': 'hd', 'label': 'HD (1080p)', 'icon': Icons.hd},
                  {'value': 'fullhd', 'label': 'Full HD (4K)', 'icon': Icons.hd},
                ],
                onChanged: (String value) => setState(() => _settings['videoQuality'] = value),
              ),
              _buildSwitchTile(
                title: 'Low Light Mode',
                value: _settings['lowLightMode'] as bool,
                onChanged: (bool value) => setState(() => _settings['lowLightMode'] = value),
              ),
            ],
          ),

          // Background Settings
          _buildSection(
            title: 'Background',
            icon: Icons.wallpaper,
            children: [
              _buildSwitchTile(
                title: 'Virtual Background',
                value: _settings['virtualBackground'] as bool,
                onChanged: (bool value) => setState(() => _settings['virtualBackground'] = value),
              ),
              _buildSwitchTile(
                title: 'Background Blur',
                value: _settings['backgroundBlur'] as bool,
                onChanged: (bool value) => setState(() => _settings['backgroundBlur'] = value),
              ),
              if (_settings['virtualBackground'] as bool)
                _buildBackgroundSelector(),
            ],
          ),

          // Recording Settings
          _buildSection(
            title: 'Recording',
            icon: Icons.fiber_manual_record,
            children: [
              _buildSwitchTile(
                title: 'Record Call',
                subtitle: 'Save call recording to device',
                value: _settings['recordCall'] as bool,
                onChanged: (bool value) => setState(() => _settings['recordCall'] = value),
              ),
            ],
          ),

          // Advanced Settings
          _buildSection(
            title: 'Advanced',
            icon: Icons.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.network_check),
                title: const Text('Network Stats'),
                subtitle: const Text('View call quality metrics'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showNetworkStats,
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Developer Options'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showDevOptions,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, _settings);
                },
                child: const Text('Save'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _settings);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Apply & Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    String? subtitle,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required List<Map<String, dynamic>> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ...items.map((item) => RadioListTile<T>(
          title: Row(
            children: [
              Icon(item['icon'] as IconData, size: 20),
              const SizedBox(width: 8),
              Text(item['label'] as String),
            ],
          ),
          value: item['value'] as T,
          groupValue: value,
          onChanged: (val) => onChanged(val as T),
          activeColor: Colors.green,
        )).toList(),
      ],
    );
  }

  Widget _buildBackgroundSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Background'),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildBackgroundOption('None', null, false),
                _buildBackgroundOption('Blur', null, true),
                _buildBackgroundOption('Office', 'assets/backgrounds/office.jpg', false),
                _buildBackgroundOption('Beach', 'assets/backgrounds/beach.jpg', false),
                _buildBackgroundOption('Forest', 'assets/backgrounds/forest.jpg', false),
                _buildBackgroundOption('Space', 'assets/backgrounds/space.jpg', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(String label, String? imagePath, bool isBlur) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              image: imagePath != null
                  ? DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: isBlur
                ? Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.blur_on, color: Colors.blue),
              ),
            )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showNetworkStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Network Statistics'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Bitrate'),
              trailing: Text('1.2 Mbps'),
            ),
            ListTile(
              title: Text('Packet Loss'),
              trailing: Text('0.5%'),
            ),
            ListTile(
              title: Text('Latency'),
              trailing: Text('45 ms'),
            ),
            ListTile(
              title: Text('Jitter'),
              trailing: Text('10 ms'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDevOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Developer Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Debug Mode'),
              value: false,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              title: const Text('Show Stats'),
              value: false,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              title: const Text('Force Hardware Decode'),
              value: false,
              onChanged: (bool value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}