import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import 'incident_detail_screen.dart';
import 'report_incident_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAllTapped;

  const HomeScreen({super.key, required this.onSeeAllTapped});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();

    final user = authProvider.userProfile;
    final uid = authProvider.firebaseUser?.uid ?? '';
    final firstName = (user?.name ?? 'Student').split(' ').first;
    final recentIncidents = incidentProvider.allIncidents.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Row matching Sample UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $firstName 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1C29),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Help make our campus safer.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1C29),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Report issues and track their resolution.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (authProvider.isStaff)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6347EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'STAFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            const Color(0xFF6347EB).withValues(alpha: 0.15),
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Color(0xFF6347EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Purple Banner Card matching Sample UI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B3EE4), Color(0xFF8167F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6347EB).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'See an issue\non campus?',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Report it and help improve\nour learning environment.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // White pill button "+ Report an Issue"
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportIncidentScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: Color(0xFF6347EB),
                              child: Icon(
                                Icons.add,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Report an Issue',
                                style: TextStyle(
                                  color: Color(0xFF4A32C4),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFF4A32C4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Report Summary Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report Summary',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C29),
                    ),
                  ),
                  TextButton(
                    onPressed: onSeeAllTapped,
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Color(0xFF6347EB)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 4 Summary Cards matching Sample UI
              Row(
                children: [
                  Expanded(
                    child: _SummaryStatCard(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF6347EB),
                      bgColor: const Color(0xFFF1EFFE),
                      count: incidentProvider.getMyReportsCount(uid),
                      label: 'My Reports',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStatCard(
                      icon: Icons.access_time_filled,
                      iconColor: const Color(0xFF3965E3),
                      bgColor: const Color(0xFFEAF0FE),
                      count: incidentProvider.getInProgressCount(),
                      label: 'In Progress',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStatCard(
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF28A766),
                      bgColor: const Color(0xFFE6F8EE),
                      count: incidentProvider.getResolvedCount(),
                      label: 'Resolved',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStatCard(
                      icon: Icons.error,
                      iconColor: const Color(0xFFE5534B),
                      bgColor: const Color(0xFFFDECEB),
                      count: incidentProvider.getSubmittedCount(),
                      label: 'Submitted',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Reports Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Reports',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C29),
                    ),
                  ),
                  TextButton(
                    onPressed: onSeeAllTapped,
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Color(0xFF6347EB)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (incidentProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (recentIncidents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 42,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No campus incidents reported yet.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentIncidents.map(
                  (incident) => IncidentCard(
                    incident: incident,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              IncidentDetailScreen(incidentId: incident.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final int count;
  final String label;

  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C29),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}