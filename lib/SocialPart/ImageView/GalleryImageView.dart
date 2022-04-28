import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryImageView extends StatefulWidget {
  List imagesUrl;
  String imageType;
  GalleryImageView(this.imagesUrl, this.imageType);
  @override
  _GalleryImageViewState createState() =>
      _GalleryImageViewState(this.imagesUrl, this.imageType);
}

class _GalleryImageViewState extends State<GalleryImageView> {
  List imagesUrl;
  String imageType;
  _GalleryImageViewState(this.imagesUrl, this.imageType);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: this.imageType == "NetworkImage"
              ? NetworkImage(widget.imagesUrl[index])
              : AssetImage(widget.imagesUrl[index]),
          initialScale: PhotoViewComputedScale.contained * 0.8,
          heroAttributes: PhotoViewHeroAttributes(tag: index + 1),
        );
      },
      itemCount: imagesUrl.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      //  backgroundDecoration: widget.backgroundDecoration,
      //  pageController: widget.pageController,
      //  onPageChanged: onPageChanged,
    ));
  }
}
