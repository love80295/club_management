import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await NotificationService.getNotifications();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _notifications = result['notifications'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Failed to load notifications';
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MARK AS READ
  // ═══════════════════════════════════════════════════════════
  Future<void> _markAsRead(int index) async {
    final notif = _notifications[index];
    if (notif['is_read'] == true) return;

    // Optimistic update
    setState(() {
      _notifications[index]['is_read'] = true;
    });

    final result = await NotificationService.markAsRead(notif['id']);
    if (result['success'] != true) {
      // Revert on failure
      setState(() {
        _notifications[index]['is_read'] = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MARK ALL AS READ
  // ═══════════════════════════════════════════════════════════
  Future<void> _markAllAsRead() async {
    final result = await NotificationService.markAllAsRead();
    if (result['success'] == true) {
      setState(() {
        for (var n in _notifications) {
          n['is_read'] = true;
        }
      });
      _showSnackBar('All notifications marked as read', Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => n['is_read'] == false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (hasUnread)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: Colors.deepPurple,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(index);
                          },
                        ),
                      ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATION CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildNotificationCard(int index) {
    final notif = _notifications[index];
    final isRead = notif['is_read'] == true;
    final type = notif['type'] ?? 'general';

    return GestureDetector(
      onTap: () => _markAsRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : Colors.deepPurple.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor(type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(type),
                color: _getTypeColor(type),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'] ?? '',
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatTime(notif['created_at']),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (notif['related_club_name'] != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.group,
                          size: 11,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            notif['related_club_name'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  Color _getTypeColor(String type) {
    switch (type) {
      case 'club_approved':
        return Colors.green;
      case 'club_rejected':
        return Colors.red;
      case 'kicked_from_club':
        return Colors.orange;
      case 'club_join_request':
        return Colors.blue;
      case 'event_registered':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'club_approved':
        return Icons.check_circle;
      case 'club_rejected':
        return Icons.cancel;
      case 'kicked_from_club':
        return Icons.exit_to_app;
      case 'club_join_request':
        return Icons.group_add;
      case 'event_registered':
        return Icons.event_available;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY & ERROR STATES
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will see updates here',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}