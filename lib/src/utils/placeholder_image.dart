import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageNewsWidget extends StatelessWidget {
  final String urlImage;
  final double height;
  final double width;

  const ImageNewsWidget(
      {Key? key, required this.urlImage, this.height = 250, this.width = 200})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(0),
      child: CachedNetworkImage(placeholder: (context, url) => Image.asset('assets/painted_logo.png'),
      imageUrl: urlImage,
      height: height,
      width: width,
      alignment: Alignment.center,
      fit: BoxFit.fill),
    );
  }


}