import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SingleImageView extends StatefulWidget {
  String imageUrl;
  String imageType;
  SingleImageView(this.imageUrl, this.imageType);
  @override
  _SingleImageViewState createState() =>
      _SingleImageViewState(this.imageUrl, this.imageType);
}

class _SingleImageViewState extends State<SingleImageView> {
  String imageUrl;
  String imageType;
  _SingleImageViewState(this.imageUrl, this.imageType);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      imageProvider: this.imageType == "NetworkImage"
          ? NetworkImage(widget.imageUrl)
          : AssetImage(widget.imageUrl),
    ));
  }
}
