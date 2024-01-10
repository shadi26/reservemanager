import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

import 'ReusableMethods.dart';

enum DotPosition { top, bottom }

class MyCarouselWithDots extends StatefulWidget {
  List<dynamic> imageUrls = [];
  bool autoPlayImg = false;
  bool enableEnlargeView = false;
  final DotPosition dotPosition;

  MyCarouselWithDots({
    Key? key,
    required this.imageUrls,
    required this.autoPlayImg,
    required this.enableEnlargeView,
    this.dotPosition = DotPosition.bottom,
  }) : super(key: key);

  @override
  _MyCarouselWithDotsState createState() => _MyCarouselWithDotsState();
}

class _MyCarouselWithDotsState extends State<MyCarouselWithDots> {
  List<CachedNetworkImage> images = [];
  int current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      convertUrlsToImages();
    });
  }


  void convertUrlsToImages() {
    images = widget.imageUrls.map((url) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        placeholder: (context, url) {
          // Display a shimmer loading effect while the image is loading
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
            ),
          );
        },
        errorWidget: (context, url, error) {
          // Display an error placeholder if the image fails to load
          return Icon(Icons.error);
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          items: images.map((image) {
            return GestureDetector(
              onTap: () {
                if (widget.enableEnlargeView) {
                  ReusableMethods.showEnlargeView(context, widget.imageUrls, current);
                }
              },
              child: ClipRRect(
                child: image,
              ),
            );
          }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: widget.autoPlayImg,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                current = index;
              });
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: widget.dotPosition == DotPosition.top ? 0 : null,
          bottom: widget.dotPosition == DotPosition.bottom ? 0 : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images
                .asMap()
                .entries
                .map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current == entry.key
                        ? Theme.of(context).cardColor
                        : Theme.of(context)
                        .primaryColorLight
                        .withOpacity(0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
