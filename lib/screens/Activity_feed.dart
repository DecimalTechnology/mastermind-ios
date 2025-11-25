import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/screens/Refferal_Screen.dart';
import 'package:master_mind/screens/one_to_one.dart';
import 'package:master_mind/screens/testimonial/testimonial_listing_screen.dart';
import 'package:master_mind/screens/testimonial/testimonialDetails/testimonial_detail_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/testimonial_provider.dart';
import 'package:master_mind/repository/testimonial_repository/testimonial_repository.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed>
    with SingleTickerProviderStateMixin {
  bool isGivenSelected = true;
  bool isFabExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Fetch testimonial data
    final testimonialProvider =
        Provider.of<TestimonialProvider>(context, listen: false);
    testimonialProvider.loadGivenTestimonials();
    testimonialProvider.loadReceivedTestimonials();
  }

  void toggleFab() {
    setState(() {
      isFabExpanded = !isFabExpanded;
      if (isFabExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text("Activity Feed"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (PlatformUtils.isIOS) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const TestimonialListingScreen(),
                  ),
                );
              } else {
                Navigator.pushNamed(context, '/testimonial-listing');
              }
            },
            icon: const Icon(Icons.comment),
            tooltip: 'View Testimonials',
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlatformButton(
                    backgroundColor:
                        isGivenSelected ? buttonColor : Colors.white,
                    foregroundColor:
                        isGivenSelected ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    minWidth: 170,
                    height: 40,
                    onPressed: () {
                      setState(() {
                        isGivenSelected = true;
                      });
                    },
                    child: const Text("Given"),
                  ),
                  const SizedBox(width: 20),
                  PlatformButton(
                    backgroundColor:
                        !isGivenSelected ? buttonColor : Colors.white,
                    foregroundColor:
                        !isGivenSelected ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    minWidth: 170,
                    height: 40,
                    onPressed: () {
                      setState(() {
                        isGivenSelected = false;
                      });
                    },
                    child: const Text("Received"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    isGivenSelected ? _buildGivenList() : _buildReceivedList(),
              ),
            ],
          ),

          // Floating Action Button with Semi-Circular Buttons
          if (isFabExpanded) _buildSemiCircularButtons(),
        ],
      ),
    );
  }

  Widget _buildSemiCircularButtons() {
    List<Map<String, dynamic>> buttons = [
      {"icon": Icons.book, "route": () => RefferalScreen()},
      {"icon": Icons.people, "route": () => OneToOne()},
      {"icon": Icons.star, "route": () => TestimonialListingScreen()},
      {"icon": Icons.favorite, "route": () => OneToOne()},
    ];

    double radius = 80; // Distance from FAB
    double startAngle = -pi; // Adjust for top-left to top-right curve
    double angleGap = 200;

    return Stack(
      alignment: Alignment.center,
      children: List.generate(buttons.length, (index) {
        double angle = startAngle + (index * angleGap);

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeInOut,
          left: MediaQuery.of(context).size.width / 2 +
              cos(angle) * radius * _animation.value -
              25, // Adjust for centering
          bottom: isFabExpanded
              ? (80 + sin(angle) * radius * _animation.value)
              : 80,
          child: _buildIconButton(
            buttons[index]["icon"],
            buttons[index]["route"],
          ),
        );
      }),
    );
  }

  Widget _buildIconButton(IconData icon, Widget Function() routePage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => routePage()),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildGivenList() {
    return Consumer<TestimonialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.givenTestimonials.isEmpty) {
          return const Center(child: Text('No testimonials given.'));
        }
        return ListView.builder(
          itemCount: provider.givenTestimonials.length,
          itemBuilder: (context, index) {
            final testimonial = provider.givenTestimonials[index];
            return _buildTestimonialCard(testimonial, true);
          },
        );
      },
    );
  }

  Widget _buildReceivedList() {
    return Consumer<TestimonialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.receivedTestimonials.isEmpty) {
          return const Center(child: Text('No testimonials received.'));
        }
        return ListView.builder(
          itemCount: provider.receivedTestimonials.length,
          itemBuilder: (context, index) {
            final testimonial = provider.receivedTestimonials[index];
            return _buildTestimonialCard(testimonial, false);
          },
        );
      },
    );
  }

  Widget _buildTestimonialCard(GivenTestimonial testimonial, bool isGiven) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: testimonial.image.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(testimonial.image))
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(testimonial.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message: ${testimonial.message.length > 50 ? testimonial.message.substring(0, 50) + '...' : testimonial.message}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Email: ${testimonial.email}'),
          ],
        ),
        onTap: () {
          // Navigate to testimonial details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TestimonialDetailScreen(testimonial: testimonial),
            ),
          );
        },
      ),
    );
  }
}
