import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/status_badge.dart';
import '../student/incident_detail_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  void _showQuickStatusModal(BuildContext context, IncidentModel incident) {
    String selectedStatus = incident.status;
    final noteCtrl = TextEditingController(text: incident.staffNote ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage: ${incident.title}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${incident.location} • Reported by ${incident.displayReporterName}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select New Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: IncidentModel.statuses.map((status) {
                  final isSelected = selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6347EB),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setSheetState(() => selectedStatus = status);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Staff Action / Resolution Note',
                  hintText: 'e.g. Plumber assigned, valve replaced...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final isStaff = context.read<AuthProvider>().isStaff;
                    Navigator.pop(ctx);
                    final success = await context
                        .read<IncidentProvider>()
                        .updateIncidentStatus(
                          incidentId: incident.id,
                          newStatus: selectedStatus,
                          staffNote: noteCtrl.text,
                          isAuthorizedStaff: isStaff,
                        );
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Updated to "$selectedStatus"'),
                          backgroundColor: const Color(0xFF1F8B58),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6347EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Status Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();

    // Hard UI Access Control Guard
    if (!authProvider.isStaff) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied: Authorized Campus Staff Only.'),
        ),
      );
    }

    final incidents = incidentProvider.filteredIncidents;
    final statusFilters = ['All', ...IncidentModel.statuses];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C29),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 22),
            SizedBox(width: 8),
            Text(
              'Staff Operations Portal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Dark Summary Strip for Staff
          Container(
            color: const Color(0xFF1A1C29),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Row(
              children: [
                _StaffMetricTile(
                  label: 'New / Pending',
                  count: incidentProvider.getSubmittedCount(),
                  color: const Color(0xFFFFB74D),
                ),
                const SizedBox(width: 10),
                _StaffMetricTile(
                  label: 'In Progress',
                  count: incidentProvider.getInProgressCount(),
                  color: const Color(0xFF64B5F6),
                ),
                const SizedBox(width: 10),
                _StaffMetricTile(
                  label: 'Resolved',
                  count: incidentProvider.getResolvedCount(),
                  color: const Color(0xFF81C784),
                ),
              ],
            ),
          ),

          // Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
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
                        color:
                            isSelected ? Colors.white : const Color(0xFF1A1C29),
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
          ),

          // Staff Queue List with Quick-Update Action Button
          Expanded(
            child: incidents.isEmpty
                ? Center(
                    child: Text(
                      'No incidents in this queue.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: incidents.length,
                    itemBuilder: (ctx, index) {
                      final inc = incidents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    inc.title,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1C29),
                                    ),
                                  ),
                                ),
                                StatusBadge(status: inc.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${inc.location} • ${inc.category} • By ${inc.displayReporterName}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (inc.staffNote != null &&
                                inc.staffNote!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Note: ${inc.staffNote}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF6347EB),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IncidentDetailScreen(
                                          incidentId: inc.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showQuickStatusModal(context, inc),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6347EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.sync, size: 16),
                                  label: const Text(
                                    'Update Status',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StaffMetricTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StaffMetricTile({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}