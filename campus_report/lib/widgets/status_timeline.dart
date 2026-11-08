import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';

class StatusTimeline extends StatelessWidget {
  final IncidentModel incident;

  const StatusTimeline({super.key, required this.incident});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmittedDone = true;
    final isInProgressActive =
        incident.status == 'In Progress' || incident.status == 'Resolved';
    final isResolvedActive = incident.status == 'Resolved';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Timeline',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C29),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Submitted
              Expanded(
                child: _buildStep(
                  label: 'Submitted',
                  timeText: _formatDate(incident.createdAt),
                  isCompleted: isInProgressActive,
                  isCurrent: incident.status == 'Submitted' && isSubmittedDone,
                ),
              ),
              _buildConnector(isActive: isInProgressActive),
              // Step 2: In Progress
              Expanded(
                child: _buildStep(
                  label: 'In Progress',
                  timeText: _formatDate(
                    incident.inProgressAt ??
                        (isInProgressActive ? incident.resolvedAt : null),
                  ),
                  isCompleted: isResolvedActive,
                  isCurrent: incident.status == 'In Progress',
                ),
              ),
              _buildConnector(isActive: isResolvedActive),
              // Step 3: Resolved
              Expanded(
                child: _buildStep(
                  label: 'Resolved',
                  timeText: _formatDate(incident.resolvedAt),
                  isCompleted: isResolvedActive,
                  isCurrent: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Container(
      width: 36,
      height: 2,
      margin: const EdgeInsets.only(top: 15),
      color: isActive ? const Color(0xFF6347EB) : Colors.grey.shade300,
    );
  }

  Widget _buildStep({
    required String label,
    required String timeText,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final active = isCompleted || isCurrent;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6347EB) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted
                ? Icons.check
                : (isCurrent ? Icons.sync : Icons.more_horiz),
            size: 16,
            color: active ? Colors.white : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFF6347EB) : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          timeText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}