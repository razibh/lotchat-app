import 'package:flutter/material.dart';

class BeautyFilterPanel extends StatefulWidget {

  const BeautyFilterPanel({
    required this.onFilterChanged, super.key,
    this.initialFilters = const <String, double>{
      'smoothness': 0.5,
      'brightness': 0.5,
      'whiteness': 0.5,
      'thinFace': 0.0,
      'bigEyes': 0.0,
    },
  });
  final Function(Map<String, double>) onFilterChanged;
  final Map<String, double> initialFilters;

  @override
  State<BeautyFilterPanel> createState() => _BeautyFilterPanelState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(Map<String, double>)>.has('onFilterChanged', onFilterChanged));
    properties.add(DiagnosticsProperty<Map<String, double>>('initialFilters', initialFilters));
  }
}

class _BeautyFilterPanelState extends State<BeautyFilterPanel> {
  late Map<String, double> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _updateFilter(String key, double value) {
    setState(() {
      _filters[key] = value;
    });
    widget.onFilterChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              const Text(
                'Beauty Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          
          // Smoothness
          _buildFilterSlider(
            label: 'Smoothness',
            key: 'smoothness',
            icon: Icons.face,
            color: Colors.pink,
          ),
          
          // Brightness
          _buildFilterSlider(
            label: 'Brightness',
            key: 'brightness',
            icon: Icons.brightness_6,
            color: Colors.amber,
          ),
          
          // Whiteness
          _buildFilterSlider(
            label: 'Whiteness',
            key: 'whiteness',
            icon: Icons.wb_sunny,
            color: Colors.blue,
          ),
          
          // Thin Face
          _buildFilterSlider(
            label: 'Thin Face',
            key: 'thinFace',
            icon: Icons.face_retouching_natural,
            color: Colors.purple,
            min: -1,
          ),
          
          // Big Eyes
          _buildFilterSlider(
            label: 'Big Eyes',
            key: 'bigEyes',
            icon: Icons.visibility,
            color: Colors.green,
            min: -1,
          ),
          
          const SizedBox(height: 16),
          
          // Reset Button
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _filters = <String, double>{
                    'smoothness': 0.5,
                    'brightness': 0.5,
                    'whiteness': 0.5,
                    'thinFace': 0.0,
                    'bigEyes': 0.0,
                  };
                });
                widget.onFilterChanged(_filters);
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Default'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSlider({
    required String label,
    required String key,
    required IconData icon,
    required Color color,
    double min = 0.0,
    double max = 1.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: _filters[key]!,
                  min: min,
                  max: max,
                  divisions: 100,
                  activeColor: color,
                  onChanged: (double value) => _updateFilter(key, value),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_filters[key]! * 100).toInt()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Preset Beauty Filters
class BeautyFilterPresets {
  static const Map<String, Map<String, double>> presets = <String, Map<String, double>>{
    'Natural': <String, double>{
      'smoothness': 0.3,
      'brightness': 0.5,
      'whiteness': 0.4,
      'thinFace': 0.0,
      'bigEyes': 0.0,
    },
    'Glowing': <String, double>{
      'smoothness': 0.6,
      'brightness': 0.7,
      'whiteness': 0.6,
      'thinFace': 0.1,
      'bigEyes': 0.1,
    },
    'Vintage': <String, double>{
      'smoothness': 0.4,
      'brightness': 0.4,
      'whiteness': 0.3,
      'thinFace': 0.0,
      'bigEyes': 0.0,
    },
    'Kawaii': <String, double>{
      'smoothness': 0.8,
      'brightness': 0.8,
      'whiteness': 0.8,
      'thinFace': 0.3,
      'bigEyes': 0.4,
    },
  };
}