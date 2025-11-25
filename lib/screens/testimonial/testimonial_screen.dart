import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/testimonial_provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/base_screen.dart';

class TestimonialScreen extends BaseScreenWithAppBar {
  final String userid;
  final String userName;

  const TestimonialScreen({
    super.key,
    required this.userid,
    required this.userName,
  }) : super(title: "Give a Testimonial");

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState
    extends BaseScreenWithAppBarState<TestimonialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Future<void> initializeData() async {
    // Initialize any data if needed
  }

  Future<void> _submitTestimonial() async {
    if (!_formKey.currentState!.validate()) return;

    await executeAsync(() async {
      setState(() {
        _isSubmitting = true;
      });

      final testimonialProvider =
          Provider.of<TestimonialProvider>(context, listen: false);
      final success = await testimonialProvider.giveTestimonial(
        widget.userid,
        _messageController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Testimonial submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          goBack();
        }
      } else {
        throw Exception('Failed to submit testimonial');
      }

      return success;
    }, context: 'submitTestimonial', showErrorSnackBar: true);

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // User ID Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: buttonColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Giving testimonial to: ${widget.userName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Testimonial Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Testimonial",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write your testimonial here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a testimonial message';
                    }
                    if (value.trim().length < 10) {
                      return 'Testimonial must be at least 10 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTestimonial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Testimonial',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
