import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentProvider = context.watch<IncidentProvider>();
    final incidents = incidentProvider.filteredIncidents;

    final statusFilters = ['All', ...IncidentModel.statuses];
    final categoryFilters = ['All', ...IncidentModel.categories];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Campus Reports',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C29),
          ),
        ),
        actions: [
          if (incidentProvider.selectedStatusFilter != 'All' ||
              incidentProvider.selectedCategoryFilter != 'All' ||
              incidentProvider.searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => incidentProvider.resetFilters(),
              child: const Text('Reset'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: incidentProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by title, location, or keyword...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FE),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter Pills
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
                const SizedBox(height: 6),
                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categoryFilters.map((cat) {
                      final isSelected =
                          incidentProvider.selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFF6347EB).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF6347EB),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF6347EB)
                                : Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              incidentProvider.setCategoryFilter(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Filtered Incident List
          Expanded(
            child: incidentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : incidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No matching incident reports found.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: incidents.length,
                        itemBuilder: (ctx, index) {
                          final incident = incidents[index];
                          return IncidentCard(
                            incident: incident,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => IncidentDetailScreen(
                                    incidentId: incident.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}