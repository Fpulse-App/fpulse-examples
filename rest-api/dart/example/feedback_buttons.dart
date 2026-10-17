import 'package:flutter/material.dart';

class FeedbackWidget extends StatefulWidget {
  final FeedbackPulse client;
  final String screenId;

  const FeedbackWidget({
    super.key,
    required this.client,
    required this.screenId,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final _commentController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  Future<void> _submit(String sentiment) async {
    setState(() => _loading = true);

    final result = await widget.client.submit(
      sentiment: sentiment,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
      screenId: widget.screenId,
    );

    setState(() {
      _loading = false;
      _submitted = result.success;
    });

    if (!result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Thank you for your feedback!'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your experience?'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Tell us more (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _submit('positive'),
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Good'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _submit('negative'),
                  icon: const Icon(Icons.thumb_down),
                  label: const Text('Bad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
