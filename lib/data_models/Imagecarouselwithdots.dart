import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:moonbnd/constants.dart';

class ImageCarouselWithDots extends StatefulWidget {
  final List<String> images;

  const ImageCarouselWithDots({super.key, required this.images});

  @override
  _ImageCarouselWithDotsState createState() => _ImageCarouselWithDotsState();
}

class _ImageCarouselWithDotsState extends State<ImageCarouselWithDots> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG PRINT
    print("🖼 ImageCarousel images count: ${widget.images.length}");

    // 🔐 IMPORTANT SAFETY CHECK
    if (widget.images.isEmpty) {
      print("⚠️ Image list is EMPTY — carousel not built");

      return const SizedBox(
        height: 200,
        child: Center(
          child: Text("No images available"),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  print("➡️ Page changed to index: $index");
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = widget.images[index];
                  print("📸 Loading image [$index]: $imageUrl");

                  return _isNetworkImage(imageUrl)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("❌ Image load error: $error");
                            return const Icon(Icons.error);
                          },
                        )
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                        );
                },
              ),
            ),
          ),

          // ✅ SmoothPageIndicator (SAFE NOW)
          Positioned(
            bottom: 10,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.images.length,
              effect: const ScrollingDotsEffect(
                activeDotColor: Colors.white,
                dotColor: kColor1,
                dotHeight: 6,
                dotWidth: 6,
                spacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
