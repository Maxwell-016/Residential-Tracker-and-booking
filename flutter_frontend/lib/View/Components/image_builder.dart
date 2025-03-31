import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageBuilder extends StatelessWidget {
  final List<dynamic> imageUrls;
  final double width;
  final String placeholderAsset;
  const ImageBuilder(
      {super.key,
      required this.imageUrls,
      required this.width,
      required this.placeholderAsset});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 30.0,
      children: _buildImageWidgets(),
    );
  }

  List<Widget> _buildImageWidgets() {
    final widgets = <Widget>[];
    final count = imageUrls.length;

    if (count >= 3) {
      widgets.add(_buildNetworkImage(imageUrls[0], width));
      widgets.add(_buildNetworkImage(imageUrls[1], width));
      widgets.add(_buildNetworkImage(imageUrls[2], width));
    } else if (count == 2) {
      widgets.add(_buildNetworkImage(imageUrls[0], width));
      widgets.add(_buildNetworkImage(imageUrls[1], width));
      //Repeat first image
    } else if (count == 1) {
      widgets.add(_buildNetworkImage(imageUrls[0], width));
    } else {
      widgets.add(_buildAssetImage(placeholderAsset, width));
    }

    return widgets;
  }
}

Widget _buildNetworkImage(String url, double width) {
  return Image.network(
    url,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
    width: width,
    loadingBuilder: (context, child, progress) {
      return progress == null ? child : const CircularProgressIndicator();
    },
    errorBuilder: (context, error, stackTrace) {
      return _buildAssetImage('assets/launch.png', width);
    },
  );
}

// Helper widget for asset images
Widget _buildAssetImage(String placeholderAsset, double width) {
  return Image.asset(
    placeholderAsset,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
    width: width,
  );
}
