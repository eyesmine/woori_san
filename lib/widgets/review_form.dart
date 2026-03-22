import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class ReviewForm extends StatefulWidget {
  final Future<bool> Function(String content, double? rating) onSubmit;
  const ReviewForm({super.key, required this.onSubmit});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _controller = TextEditingController();
  double? _rating;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l.writeReview,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.appText),
          ),
          const SizedBox(height: 16),

          // Star rating selector
          Text(l.rating, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.appTextSub)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final starValue = (i + 1).toDouble();
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    _rating != null && i < _rating!.round() ? Icons.star : Icons.star_outline,
                    color: AppTheme.accent,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Content text field
          TextField(
            controller: _controller,
            maxLength: 500,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: l.reviewHint,
              hintStyle: TextStyle(color: context.appTextSub, fontSize: 14),
              filled: true,
              fillColor: context.appSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting || _controller.text.trim().isEmpty
                  ? null
                  : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l.submitReview),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(_controller.text.trim(), _rating);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.pop(context);
    }
  }
}
