import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'cluster.dart';

class ImageClusterController {
  final TransformationController transformationController = TransformationController();
  final List<Offset> _markers = [];
  static const double clusterDistance = 40;

  Timer? _throttleTimer;
  void Function()? onTransformChanged;
  void Function(Offset marker)? onMarkerTapped;

  void dispose() {
    transformationController.dispose();
    _throttleTimer?.cancel();
  }

  void addMarker(Offset marker) {
    _markers.add(marker);
  }

  void handleTransformChange() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(milliseconds: 100), () {
      onTransformChanged?.call();
    });
  }

  void handleTap({
    required TapUpDetails details,
    required RenderBox renderBox,
    required void Function(Offset newMarker) onAddMarker,
  }) {
    final localPoint = renderBox.globalToLocal(details.globalPosition);
    final Matrix4 matrix = transformationController.value;

    // 마커 터치 확인
    for (final marker in _markers) {
      final transformed = matrix.transform3(Vector3(marker.dx, marker.dy, 0));
      final markerScreenOffset = Offset(transformed.x, transformed.y);

      if ((markerScreenOffset - localPoint).distance < 20) {
        onMarkerTapped?.call(marker);
        return;
      }
    }

    // 새 마커 추가
    final inverse = Matrix4.inverted(matrix);
    final transformed = inverse.transform3(Vector3(localPoint.dx, localPoint.dy, 0));
    onAddMarker(Offset(transformed.x, transformed.y));
  }

  List<Cluster> computeClusters() {
    final List<Cluster> clusters = [];
    final double currentScale = transformationController.value.getMaxScaleOnAxis();
    final double scaledDistance = clusterDistance / currentScale;

    for (final marker in _markers) {
      bool added = false;
      for (final cluster in clusters) {
        if ((cluster.center - marker).distance < scaledDistance) {
          cluster.add(marker);
          added = true;
          break;
        }
      }
      if (!added) {
        clusters.add(Cluster(marker));
      }
    }
    return clusters;
  }
}