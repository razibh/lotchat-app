import 'package:flutter/material.dart';

class AttachmentPicker extends StatelessWidget {

  const AttachmentPicker({
    required this.onPickImage, required this.onPickVideo, required this.onPickFile, required this.onSendLocation, required this.onSendContact, super.key,
  });
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onPickFile;
  final VoidCallback onSendLocation;
  final VoidCallback onSendContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          const Text(
            'Attach',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildItem(
                icon: Icons.photo,
                label: 'Image',
                color: Colors.green,
                onTap: onPickImage,
              ),
              _buildItem(
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.red,
                onTap: onPickVideo,
              ),
              _buildItem(
                icon: Icons.insert_drive_file,
                label: 'File',
                color: Colors.blue,
                onTap: onPickFile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <>[
              _buildItem(
                icon: Icons.location_on,
                label: 'Location',
                color: Colors.orange,
                onTap: onSendLocation,
              ),
              _buildItem(
                icon: Icons.contact_phone,
                label: 'Contact',
                color: Colors.purple,
                onTap: onSendContact,
              ),
              _buildItem(
                icon: Icons.poll,
                label: 'Poll',
                color: Colors.teal,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onPickImage', onPickImage));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onPickVideo', onPickVideo));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onPickFile', onPickFile));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onSendLocation', onSendLocation));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onSendContact', onSendContact));
  }
}