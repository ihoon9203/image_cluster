import 'dart:ui';

class Cluster {
  final List<Offset> markers;

  Cluster(Offset first) : markers = [first];

  void add(Offset marker) => markers.add(marker);

  Offset get center {
    final sum = markers.reduce((a, b) => a + b);
    return sum / markers.length.toDouble();
  }
}