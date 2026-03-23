// lib/features/ai_chat/widgets/message_bubble.dart
// Custom chat bubble with source citations and animations

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:edupay_app/core/constants/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String> sources;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.sources = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool animate;

  const MessageBubble({
    super.key,
    required this.message,
    this.animate = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.3 : -0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    if (widget.animate) {
      _animController.forward();
    } else {
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: EdgeInsets.only(
              left: widget.message.isUser ? 60 : 12,
              right: widget.message.isUser ? 12 : 60,
              top: 4,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: widget.message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // ===== Message Bubble =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: widget.message.isUser
                      ? AppTheme.userBubble
                      : AppTheme.aiBubble,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI label
                      if (!widget.message.isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 13,
                                color: AppTheme.accentPurple,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'EduPay AI',
                                style: TextStyle(
                                  color:
                                      AppTheme.accentPurple.withOpacity(0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Message content
                      if (widget.message.isUser)
                        Text(
                          widget.message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      else
                        MarkdownBody(
                          data: widget.message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            listBullet: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            code: TextStyle(
                              backgroundColor:
                                  AppTheme.primaryDark.withOpacity(0.5),
                              color: AppTheme.accentGreen,
                              fontSize: 13,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: const Border(
                                left: BorderSide(
                                  color: AppTheme.accentPurple,
                                  width: 3,
                                ),
                              ),
                              color: AppTheme.primaryDark.withOpacity(0.3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ===== Source Citations =====
                if (!widget.message.isUser && widget.message.sources.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.message.sources.map((source) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentPurple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppTheme.accentPurple.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 11,
                                color:
                                    AppTheme.accentPurple.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                source,
                                style: TextStyle(
                                  color: AppTheme.accentPurple
                                      .withOpacity(0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // ===== Timestamp =====
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(widget.message.timestamp),
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
