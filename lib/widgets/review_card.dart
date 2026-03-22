import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isOwn;
  final VoidCallback? onDelete;
  const ReviewCard({super.key, required this.review, this.isOwn = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userNickname,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.appText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(color: context.appTextSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isOwn)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                  onPressed: () => _confirmDelete(context, l),
                  tooltip: l.deleteReview,
                ),
            ],
          ),

          // Star rating
          if (review.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < review.rating!.round() ? Icons.star : Icons.star_outline,
                  color: AppTheme.accent,
                  size: 18,
                );
              }),
            ),
          ],

          // Content
          const SizedBox(height: 8),
          Text(
            review.content,
            style: TextStyle(color: context.appText, fontSize: 14, height: 1.5),
          ),

          // Photo thumbnails
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      review.photoUrls[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (review.userProfileImageUrl != null && review.userProfileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(review.userProfileImageUrl!),
        backgroundColor: AppTheme.primaryLight.withAlpha(51),
      );
    }
    final initial = review.userNickname.isNotEmpty ? review.userNickname[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primary.withAlpha(25),
      child: Text(
        initial,
        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteReview),
        content: Text(l.deleteReviewConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text(l.confirm, style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
