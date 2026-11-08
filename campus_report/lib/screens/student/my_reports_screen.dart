import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();

    final user = authProvider.userProfile;
    final uid = authProvider.firebaseUser?.uid ?? '';
    final isStaff = authProvider.isStaff;

    // Staff can toggle or view all reports, students see their own submitted reports
    final myIncidents = incidentProvider.getMyFilteredIncidents(uid);
    final statusFilters = ['All', ...IncidentModel.statuses];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C29),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF1A1C29)),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card matching bottom-right Sample UI screen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            const Color(0xFF6347EB).withValues(alpha: 0.15),
                        child: Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6347EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.name ?? 'ALU User',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1C29),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isStaff
                                        ? const Color(0xFF6347EB)
                                        : const Color(0xFFF1EFFE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isStaff ? 'Staff' : 'Student',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isStaff
                                          ? Colors.white
                                          : const Color(0xFF6347EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    user?.department ?? 'Software Engineering',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  user?.campusLocation ?? 'Kigali, Rwanda',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 3 Counters Row matching Sample UI ('Total Reports', 'In Progress', 'Resolved')
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileMiniStat(
                          count: incidentProvider.getMyReportsCount(uid),
                          label: 'Total Reports',
                          bgColor: const Color(0xFFF1EFFE),
                          textColor: const Color(0xFF6347EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileMiniStat(
                          count: incidentProvider.getMyStatusCount(
                            uid,
                            'In Progress',
                          ),
                          label: 'In Progress',
                          bgColor: const Color(0xFFEAF0FE),
                          textColor: const Color(0xFF3965E3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileMiniStat(
                          count: incidentProvider.getMyStatusCount(
                            uid,
                            'Resolved',
                          ),
                          label: 'Resolved',
                          bgColor: const Color(0xFFE6F8EE),
                          textColor: const Color(0xFF1F8B58),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Status Filter Pills ('All', 'Submitted', 'In Progress', 'Resolved')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusFilters.map((status) {
                  final isSelected =
                      incidentProvider.selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6347EB),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1C29),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) =>
                          incidentProvider.setStatusFilter(status),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            if (myIncidents.isEmpty)
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
                      Icons.assignment_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No reports in this category yet.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...myIncidents.map(
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
    );
  }
}

class _ProfileMiniStat extends StatelessWidget {
  final int count;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _ProfileMiniStat({
    required this.count,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
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