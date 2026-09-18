import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/club_service.dart';
import '../services/event_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ═══════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════
  AppUser? _user;
  List<Club> _myClubs = [];
  List<Club> _allClubs = [];
  List<Event> _events = [];
  int _unreadNotifications = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD DATA FROM API
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get cached user first (fast)
      final cachedUser = await AuthService.getCachedUser();
      if (cachedUser != null && mounted) {
        setState(() => _user = cachedUser);
      }

      // Fetch all data in parallel
      final results = await Future.wait([
        AuthService.getProfile(),
        ClubService.getMyClubs(),
        ClubService.getAllClubs(),
        EventService.getAllEvents(),
        NotificationService.getUnreadCount(),
      ]);

      if (!mounted) return;

      final profileResult = results[0] as Map<String, dynamic>;
      final myClubsResult = results[1] as Map<String, dynamic>;
      final allClubsResult = results[2] as Map<String, dynamic>;
      final eventsResult = results[3] as Map<String, dynamic>;
      final unreadCount = results[4] as int;

      setState(() {
        if (profileResult['success'] == true) {
          _user = profileResult['user'];
        }
        if (myClubsResult['success'] == true) {
          _myClubs = myClubsResult['clubs'] ?? [];
        }
        if (allClubsResult['success'] == true) {
          _allClubs = allClubsResult['clubs'] ?? [];
        }
        if (eventsResult['success'] == true) {
          _events = eventsResult['events'] ?? [];
        }
        _unreadNotifications = unreadCount;
        _isLoading = false;

        // Session expired
        if (profileResult['statusCode'] == 401) {
          _handleSessionExpired();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: $e';
        });
      }
    }
  }

  void _handleSessionExpired() {
    AuthService.logout().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Connect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          // ═══════════════════════════════════════════════════
          // NOTIFICATION BELL WITH BADGE
          // ═══════════════════════════════════════════════════
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Notifications',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  // Refresh count after coming back
                  final count = await NotificationService.getUnreadCount();
                  if (mounted) {
                    setState(() => _unreadNotifications = count);
                  }
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotifications > 9
                            ? '9+'
                            : _unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: Colors.deepPurple,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: 16),
                          _buildCreateClubButton(),
                          const SizedBox(height: 16),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Your Clubs', '/myclubs'),
                          const SizedBox(height: 12),
                          _buildMyClubsSection(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Upcoming Events', '/explore'),
                          const SizedBox(height: 12),
                          _buildEventsSection(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Recommended Clubs', '/explore'),
                          const SizedBox(height: 12),
                          _buildRecommendedClubs(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WELCOME SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildWelcomeSection() {
    final greeting = _getGreeting();
    final name = _user?.fullName ?? _user?.username ?? 'Student';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              _user?.initials ?? '?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_user?.department.isNotEmpty == true)
                  Text(
                    '${_user!.department} • ${_user!.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ═══════════════════════════════════════════════════════════
  // CREATE CLUB BUTTON
  // ═══════════════════════════════════════════════════════════
  Widget _buildCreateClubButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/createclub');
        if (result == true && mounted) {
          _loadData();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade600, Colors.orange.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your Own Club',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Submit a request for admin approval',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS CARDS
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Clubs',
            _myClubs.length.toString(),
            Icons.group,
            Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Events',
            _events.length.toString(),
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Discover',
            _allClubs.length.toString(),
            Icons.explore,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, route),
          child: const Text(
            'See All',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MY CLUBS SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildMyClubsSection() {
    if (_myClubs.isEmpty) {
      return _buildEmptyCard(
        'You haven\'t joined any clubs yet',
        'Tap "Explore" to discover clubs',
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _myClubs.length,
        itemBuilder: (context, index) {
          return _buildMiniClubCard(_myClubs[index]);
        },
      ),
    );
  }

  Widget _buildMiniClubCard(Club club) {
    return GestureDetector(
      onTap: () => _openClubDetails(club),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  club.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              club.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              club.category,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 12, color: Colors.grey),
                const SizedBox(width: 3),
                Text(
                  '${club.memberCount}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EVENTS SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildEventsSection() {
    if (_events.isEmpty) {
      return _buildEmptyCard(
        'No upcoming events',
        'Check back later for new events',
      );
    }

    return Column(
      children: _events.take(3).map((event) => _buildEventCard(event)).toList(),
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        _showSnackBar('Opening ${event.title}...', Colors.deepPurple);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(event.category).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(event.category),
                color: _getCategoryColor(event.category),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        event.date,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        event.formattedTime,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.clubName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (event.isRegistered)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Registered',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RECOMMENDED CLUBS
  // ═══════════════════════════════════════════════════════════
  Widget _buildRecommendedClubs() {
    final recommended = _allClubs.where((c) => !c.isJoined).take(3).toList();

    if (recommended.isEmpty) {
      return _buildEmptyCard(
        'No recommendations',
        'You\'re already part of all clubs!',
      );
    }

    return Column(
      children:
          recommended.map((club) => _buildRecommendedClubCard(club)).toList(),
    );
  }

  Widget _buildRecommendedClubCard(Club club) {
    return GestureDetector(
      onTap: () => _openClubDetails(club),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  club.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    club.description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          club.category,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.people, size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club.memberCount}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _joinClub(club),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(60, 30),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Join',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════
  Future<void> _joinClub(Club club) async {
    final result = await ClubService.joinClub(club.id);

    if (result['success'] == true) {
      _showSnackBar('Joined ${club.name}!', Colors.green);
      _loadData();
    } else {
      _showSnackBar(result['message'] ?? 'Failed to join', Colors.red);
    }
  }

  void _openClubDetails(Club club) {
    Navigator.pushNamed(
      context,
      '/clubdetails',
      arguments: club.id,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
              onPressed: _loadData,
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Technical':
      case 'Workshop':
      case 'Hackathon':
        return Colors.blue;
      case 'Cultural':
      case 'Club Activity':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Academic':
      case 'Event':
        return Colors.orange;
      case 'Arts':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Technical':
        return Icons.code;
      case 'Cultural':
        return Icons.music_note;
      case 'Sports':
        return Icons.sports_basketball;
      case 'Academic':
        return Icons.school;
      case 'Arts':
        return Icons.palette;
      case 'Workshop':
        return Icons.build;
      case 'Hackathon':
        return Icons.computer;
      case 'Club Activity':
        return Icons.celebration;
      case 'Event':
        return Icons.event;
      default:
        return Icons.category;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Clubs'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) {
          // Already on Home
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/explore');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/myclubs');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}