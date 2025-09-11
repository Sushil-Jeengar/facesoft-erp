import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final CarouselSliderController _controller = CarouselSliderController();

  // List of asset image paths
  final List<String> imgList = [
    'assets/images/1slide.jpg',
    'assets/images/2slide.jpg',
    'assets/images/3slide.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ), // 16px side spacing
          child: CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false, // Important: no centering effect
              viewportFraction: 1.0, // Full width inside padding
            ),
            items: imgList.map((item) => _buildSlideItem(item)).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSlideItem(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[100],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 40),
              ),
            ),
      ),
    );
  }
}
