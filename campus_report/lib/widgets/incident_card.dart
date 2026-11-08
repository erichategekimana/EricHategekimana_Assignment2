import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Water':
        return Icons.water_drop_outlined;
      case 'Electricity':
        return Icons.bolt_outlined;
      case 'Safety':
        return Icons.shield_outlined;
      case 'Sanitation':
        return Icons.delete_outline;
      case 'Facilities':
      default:
        return Icons.domain_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail image or category icon placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: incident.imageUrl != null && incident.imageUrl!.isNotEmpty
                    ? Image.network(
                        incident.imageUrl!,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackBox(),
                      )
                    : _buildFallbackBox(),
              ),
              const SizedBox(width: 14),
              // Title, Location, Relative Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C29),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatRelativeTime(incident.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Pill + Chevron
              StatusBadge(status: incident.status),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBox() {
    return Container(
      width: 68,
      height: 68,
      color: const Color(0xFF6347EB).withValues(alpha: 0.1),
      child: Icon(
        _categoryIcon(incident.category),
        color: const Color(0xFF6347EB),
        size: 30,
      ),
    );
  }
}