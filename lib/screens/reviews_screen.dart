import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/review_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mountain_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/review_form.dart';

class ReviewsScreen extends StatefulWidget {
  final String mountainId;
  const ReviewsScreen({super.key, required this.mountainId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.mountainId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mountain = context.read<MountainProvider>().getMountainById(widget.mountainId);
    final mountainName = mountain?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('$mountainName ${l.reviews}'),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (provider.reviews.isEmpty) {
            return _buildEmptyState(l);
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => provider.loadReviews(widget.mountainId),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: provider.reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = provider.reviews[index];
                final currentUserId = context.read<AuthProvider>().user?.id;
                final isOwn = currentUserId != null && review.userId == currentUserId;

                return ReviewCard(
                  review: review,
                  isOwn: isOwn,
                  onDelete: () => _deleteReview(review.id, l),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewForm(l),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_outlined),
        label: Text(l.writeReview, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<ReviewProvider>().loadReviews(widget.mountainId),
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    l.noReviewsYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.appTextSub, fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewForm(AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReviewForm(
        onSubmit: (content, rating) async {
          final provider = context.read<ReviewProvider>();
          final success = await provider.createReview(
            widget.mountainId,
            content,
            rating,
            [],
          );
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.reviewSubmitted), backgroundColor: AppTheme.primary),
            );
          }
          return success;
        },
      ),
    );
  }

  Future<void> _deleteReview(String reviewId, AppLocalizations l) async {
    final provider = context.read<ReviewProvider>();
    final success = await provider.deleteReview(reviewId, widget.mountainId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.reviewDeleted), backgroundColor: AppTheme.primary),
      );
    }
  }
}
