// lib/features/call/models/beauty_filters.dart
class BeautyFilter {

  const BeautyFilter({
    required this.name,
    required this.smoothness,
    required this.brightness,
    required this.sharpness,
    this.preset,
  });
  final String name;
  final double smoothness;
  final double brightness;
  final double sharpness;
  final String? preset;

  static const List<BeautyFilter> filters = <BeautyFilter>[
    BeautyFilter(
      name: 'Natural',
      smoothness: 0.5,
      brightness: 0,
      sharpness: 0.5,
      preset: 'natural',
    ),
    BeautyFilter(
      name: 'Soft',
      smoothness: 0.8,
      brightness: 0.1,
      sharpness: 0.3,
      preset: 'soft',
    ),
    BeautyFilter(
      name: 'Bright',
      smoothness: 0.4,
      brightness: 0.3,
      sharpness: 0.6,
      preset: 'bright',
    ),
    BeautyFilter(
      name: 'Vintage',
      smoothness: 0.6,
      brightness: -0.1,
      sharpness: 0.4,
      preset: 'vintage',
    ),
    BeautyFilter(
      name: 'Glow',
      smoothness: 0.9,
      brightness: 0.2,
      sharpness: 0.2,
      preset: 'glow',
    ),
  ];
}