import 'package:flutter/material.dart';
import 'image_cluster_controller.dart';

class ClusterImage extends StatefulWidget {
  final ImageProvider image;
  final ImageClusterController controller;
  final Widget? marker;
  final Widget? clusterMarker;
  final Function? onMarkerTapped;
  final double? minClusterDiameter;
  final Color? markerColor;
  final Color? clusterColor;
  final Color? clusterMarkerColor;
  final Color? clusterBorderColor;
  final Color? markerTextColor;
  final Color? clusterTextColor;
  final String markerText;
  final bool clusterSizeShouldIncrement;


  const ClusterImage({
    super.key,
    required this.image,
    required this.controller,
    this.marker,
    this.clusterMarker,
    this.onMarkerTapped,
    this.minClusterDiameter,
    this.markerColor,
    this.clusterColor,
    this.clusterMarkerColor,
    this.clusterBorderColor,
    this.markerTextColor,
    this.clusterTextColor,
    this.markerText = '',
    this.clusterSizeShouldIncrement = false,
  });

  @override
  State<ClusterImage> createState() => _ClusterImageState();
}

class _ClusterImageState extends State<ClusterImage> {
  final GlobalKey _viewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.onTransformChanged = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    widget.controller.onTransformChanged = null;
    super.dispose();
  }

  void _addMarker(Offset offset) {
    setState(() {
      widget.controller.addMarker(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clusters = widget.controller.computeClusters();

    return GestureDetector(
      onTapUp: (details) {
        final renderBox =
            _viewerKey.currentContext!.findRenderObject() as RenderBox;
        widget.controller.handleTap(
          details: details,
          renderBox: renderBox,
          onAddMarker: _addMarker,
        );
      },
      child: InteractiveViewer(
        key: _viewerKey,
        transformationController: widget.controller.transformationController,
        minScale: 1,
        maxScale: 5,
        onInteractionUpdate: (_) => widget.controller.handleTransformChange(),
        child: Stack(
          children: [
            Image(image: widget.image),
            ...clusters.map((cluster) {
              final offset = cluster.center;
              final markerWidget = cluster.markers.length == 1
                  ? _buildMarkerDot()
                  : _buildClusterMarker(cluster.markers.length);
              return Positioned(
                left: offset.dx - 15,
                top: offset.dy - 15,
                child: markerWidget,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerDot() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildClusterMarker(int count) {
    final dynamicSize = 20 + (count * 2).clamp(0, 20);
    return Container(
      width: dynamicSize.toDouble(),
      height: dynamicSize.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
