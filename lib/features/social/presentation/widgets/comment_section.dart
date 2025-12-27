import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/core/theme/app_colors.dart';
import 'package:todo_social/features/social/data/models/comment_model.dart';
import 'package:todo_social/features/social/data/repositories/comment_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSection extends ConsumerStatefulWidget {
  final int todoId;
  final int initialCommentCount;

  const CommentSection({
    super.key,
    required this.todoId,
    this.initialCommentCount = 0,
  });

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isExpanded = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(apiServiceProvider);
      final repository = CommentRepository(dio);
      final commentsData = await repository.getComments(widget.todoId);

      setState(() {
        _comments = commentsData
            .map((json) => CommentModel.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumlar yüklenemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final dio = ref.read(apiServiceProvider);
      final repository = CommentRepository(dio);
      final commentData = await repository.createComment(
        todoId: widget.todoId,
        text: _commentController.text.trim(),
      );

      final newComment = CommentModel.fromJson(commentData);
      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum eklenemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      final dio = ref.read(apiServiceProvider);
      final repository = CommentRepository(dio);
      await repository.deleteComment(commentId);

      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum silinemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded && _comments.isEmpty) {
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentCount = _comments.isNotEmpty ? _comments.length : widget.initialCommentCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment count toggle
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  commentCount > 0
                      ? '$commentCount yorum'
                      : 'Yorum yap',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded comment section
        if (_isExpanded) ...[
          const Divider(height: 1),

          // Comment input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _submitComment,
                        icon: const Icon(Icons.send),
                        color: AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
              ],
            ),
          ),

          // Comments list
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Henüz yorum yok. İlk yorumu siz yapın!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment);
              },
            ),
        ],
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            backgroundImage: comment.profilePicture != null
                ? NetworkImage(comment.profilePicture!)
                : null,
            child: comment.profilePicture == null
                ? Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt, locale: 'tr'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Delete button (only for own comments)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Sil'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _deleteComment(comment.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
