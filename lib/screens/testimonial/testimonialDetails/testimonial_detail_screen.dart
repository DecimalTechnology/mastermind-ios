import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:master_mind/repository/testimonial_repository/testimonial_repository.dart';
// Removed unnecessary import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/utils/const.dart';

class TestimonialDetailScreen extends StatefulWidget {
  final GivenTestimonial testimonial;
  const TestimonialDetailScreen({Key? key, required this.testimonial})
      : super(key: key);

  static void show(BuildContext context, GivenTestimonial testimonial) {
    if (PlatformUtils.isIOS) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => TestimonialDetailScreen(testimonial: testimonial),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestimonialDetailScreen(testimonial: testimonial),
        ),
      );
    }
  }

  @override
  State<TestimonialDetailScreen> createState() =>
      _TestimonialDetailScreenState();
}

class _TestimonialDetailScreenState extends State<TestimonialDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testimonial = widget.testimonial;
    return PlatformWidget.scaffold(
      context: context,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPrimaryColor.withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: kPrimaryColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Testimonial Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          Text(
                            'View testimonial information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            _buildTestimonialContent(testimonial),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialContent(GivenTestimonial testimonial) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Section (Top)
          _buildProfileSection(testimonial),
          const SizedBox(height: 24),

          // Author Details (Below Profile)
          _buildAuthorDetails(testimonial),
          const SizedBox(height: 32),

          // Testimonial Content (Below Author Details)
          _buildTestimonialText(testimonial),
        ],
      ),
    );
  }

  Widget _buildProfileSection(GivenTestimonial testimonial) {
    return Stack(
      children: [
        // Main Profile Picture with Red Border
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kPrimaryColor,
              width: 4,
            ),
          ),
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Colors.grey[200],
            backgroundImage: testimonial.image.isNotEmpty
                ? NetworkImage(testimonial.image)
                : null,
            child: testimonial.image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: kPrimaryColor,
                  )
                : null,
          ),
        ),

        // Decorative Red Circle (top-left overlap)
        // Positioned(
        //   top: -8,
        //   left: -8,
        //   child: Container(
        //     width: 32,
        //     height: 32,
        //     decoration: BoxDecoration(
        //       color: kPrimaryColor,
        //       shape: BoxShape.circle,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildAuthorDetails(GivenTestimonial testimonial) {
    return Column(
      children: [
        // Author Name
        Text(
          testimonial.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Author Role/Email
        Text(
          testimonial.email,
          style: TextStyle(
            fontSize: 16,
            color: kPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTestimonialText(GivenTestimonial testimonial) {
    return Stack(
      children: [
        // Main Testimonial Text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          // decoration: BoxDecoration(
          //   color: Colors.grey[50],
          //   borderRadius: BorderRadius.circular(16),
          //   border: Border.all(
          //     color: Colors.grey[200]!,
          //     width: 1,
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opening Quote Icon
              Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  FontAwesomeIcons.quoteLeft,
                  size: 32,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 16),

              // Testimonial Message
              Text(
                testimonial.message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 16),

              // Closing Quote Icon
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  FontAwesomeIcons.quoteRight,
                  size: 32,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),

        // Date Badge (bottom left)
        if (testimonial.createdAt != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  // color: kPrimaryColor.withOpacity(0.1),
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(testimonial.createdAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}
