import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/feedback.dart';
import '../../services/feedback_service.dart';
import '../../widgets/success_notification.dart';

class EventFeedbackScreen extends StatefulWidget {
  static const String routeName = '/event-feedback';
  final EventModel event;
  
  const EventFeedbackScreen({super.key, required this.event});

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  int _overallRating = 0;
  int _organizationRating = 0;
  int _relevanceRating = 0;
  int _coordinationRating = 0;
  int _overallExperienceRating = 0;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingFeedback();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadExistingFeedback() {
    final feedbackService = Provider.of<FeedbackService>(context, listen: false);
    final existingFeedback = feedbackService.getFeedbackForEvent(int.parse(widget.event.id));
    
    if (existingFeedback != null) {
      setState(() {
        _overallRating = existingFeedback.rating;
        _organizationRating = existingFeedback.organizationRating ?? 0;
        _relevanceRating = existingFeedback.relevanceRating ?? 0;
        _coordinationRating = existingFeedback.coordinationRating ?? 0;
        _overallExperienceRating = existingFeedback.overallExperienceRating ?? 0;
        _commentController.text = existingFeedback.comment ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sự kiện'),
        actions: [
          if (_overallRating > 0)
            TextButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              child: _isSubmitting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gửi'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event info
              _buildEventInfo(),
              const SizedBox(height: 24),
              
              // Overall rating
              _buildRatingSection(
                title: 'Đánh giá tổng thể',
                subtitle: 'Bạn đánh giá sự kiện này như thế nào?',
                rating: _overallRating,
                onRatingChanged: (rating) => setState(() => _overallRating = rating),
                required: true,
              ),
              const SizedBox(height: 24),
              
              // Detailed ratings
              _buildDetailedRatings(),
              const SizedBox(height: 24),
              
              // Comment section
              _buildCommentSection(),
              const SizedBox(height: 32),
              
              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.event.imageAsset,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.event.dateText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.event.location ?? 'Địa điểm TBD',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required int rating,
    required ValueChanged<int> onRatingChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: index < rating ? Colors.amber : Colors.grey[400],
                  size: 32,
                ),
              ),
            );
          }),
        ),
        if (rating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getRatingText(rating),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailedRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá chi tiết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildRatingSection(
          title: 'Tổ chức sự kiện',
          subtitle: 'Cách tổ chức và quản lý sự kiện',
          rating: _organizationRating,
          onRatingChanged: (rating) => setState(() => _organizationRating = rating),
        ),
        const SizedBox(height: 20),
        
        _buildRatingSection(
          title: 'Tính phù hợp',
          subtitle: 'Nội dung có phù hợp với bạn không?',
          rating: _relevanceRating,
          onRatingChanged: (rating) => setState(() => _relevanceRating = rating),
        ),
        const SizedBox(height: 20),
        
        _buildRatingSection(
          title: 'Sự phối hợp',
          subtitle: 'Sự phối hợp giữa các bên tổ chức',
          rating: _coordinationRating,
          onRatingChanged: (rating) => setState(() => _coordinationRating = rating),
        ),
        const SizedBox(height: 20),
        
        _buildRatingSection(
          title: 'Trải nghiệm tổng thể',
          subtitle: 'Trải nghiệm tổng thể của bạn',
          rating: _overallExperienceRating,
          onRatingChanged: (rating) => setState(() => _overallExperienceRating = rating),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chia sẻ thêm về trải nghiệm của bạn (tùy chọn)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _commentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Viết bình luận của bạn ở đây...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _overallRating > 0 && !_isSubmitting ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isSubmitting
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Đang gửi...'),
              ],
            )
          : const Text(
              'Gửi đánh giá',
              style: TextStyle(fontSize: 16),
            ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Xuất sắc';
      default: return '';
    }
  }

  Future<void> _submitFeedback() async {
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá tổng thể cho sự kiện'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedbackService = Provider.of<FeedbackService>(context, listen: false);
      final success = await feedbackService.submitFeedback(
        eventId: int.parse(widget.event.id),
        rating: _overallRating,
        comment: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        organizationRating: _organizationRating > 0 ? _organizationRating : null,
        relevanceRating: _relevanceRating > 0 ? _relevanceRating : null,
        coordinationRating: _coordinationRating > 0 ? _coordinationRating : null,
        overallExperienceRating: _overallExperienceRating > 0 ? _overallExperienceRating : null,
      );

      if (success) {
        if (mounted) {
          // Show success notification
          SuccessNotification.show(
            context: context,
            title: '⭐ Đánh giá thành công!',
            message: 'Cảm ơn bạn đã đánh giá sự kiện "${widget.event.title}". Phản hồi của bạn rất có giá trị!',
            onDismiss: () {
              Navigator.of(context).pop();
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedbackService.error.value ?? 'Có lỗi xảy ra khi gửi đánh giá'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
