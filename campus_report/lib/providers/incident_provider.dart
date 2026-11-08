import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _incidentService = IncidentService();
  final StorageService _storageService = StorageService();

  List<IncidentModel> _allIncidents = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Search and Filter state (for browsing reports without setState)
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Submitted', 'In Progress', 'Resolved'
  String _selectedCategoryFilter = 'All';

  StreamSubscription<List<IncidentModel>>? _incidentsSubscription;

  IncidentProvider() {
    startListeningToIncidents();
  }

  List<IncidentModel> get allIncidents => _allIncidents;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  /// Subscribe to real-time Firestore updates
  void startListeningToIncidents() {
    _isLoading = true;
    notifyListeners();

    _incidentsSubscription?.cancel();
    _incidentsSubscription = _incidentService.streamAllIncidents().listen(
      (incidents) {
        _allIncidents = incidents;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Could not load incident reports.';
        notifyListeners();
      },
    );
  }

  /// Filtered list of all campus incidents (used in Browse / All Reports & Staff view)
  List<IncidentModel> get filteredIncidents {
    return _applyFilters(_allIncidents);
  }

  /// Filtered list of a specific student's own reports (used in 'My Reports' tab)
  List<IncidentModel> getMyFilteredIncidents(String userId) {
    final myReports =
        _allIncidents.where((inc) => inc.reporterId == userId).toList();
    return _applyFilters(myReports);
  }

  List<IncidentModel> _applyFilters(List<IncidentModel> source) {
    return source.where((incident) {
      final matchesStatus = _selectedStatusFilter == 'All' ||
          incident.status == _selectedStatusFilter;
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          incident.category == _selectedCategoryFilter;
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          incident.title.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query) ||
          incident.category.toLowerCase().contains(query);

      return matchesStatus && matchesCategory && matchesSearch;
    }).toList();
  }

  // --- Summary Card Counters (Matches Sample UI Home Screen) ---
  int getMyReportsCount(String userId) =>
      _allIncidents.where((i) => i.reporterId == userId).length;

  int getInProgressCount() =>
      _allIncidents.where((i) => i.status == 'In Progress').length;

  int getResolvedCount() =>
      _allIncidents.where((i) => i.status == 'Resolved').length;

  int getSubmittedCount() =>
      _allIncidents.where((i) => i.status == 'Submitted').length;

  int getMyStatusCount(String userId, String status) => _allIncidents
      .where((i) => i.reporterId == userId && i.status == status)
      .length;

  /// Lookup a single incident by ID so Details screen reacts to live status changes
  IncidentModel? getIncidentById(String id) {
    try {
      return _allIncidents.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Filter Mutators ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedStatusFilter = 'All';
    _selectedCategoryFilter = 'All';
    notifyListeners();
  }

  // --- CRUD Actions ---

  /// Submit a new incident report (with optional photo upload to Firebase Storage)
  Future<bool> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    required String reporterId,
    required String reporterName,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? uploadedImageUrl;
      if (imageFile != null) {
        uploadedImageUrl = await _storageService.uploadIncidentPhoto(
          imageFile: imageFile,
          reporterId: reporterId,
        );
      }

      final newIncident = IncidentModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location,
        status: 'Submitted',
        imageUrl: uploadedImageUrl,
        reporterId: reporterId,
        reporterName: reporterName,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
      );

      await _incidentService.createIncident(newIncident);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit report. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Staff Only: Update incident status ('Submitted' -> 'In Progress' -> 'Resolved')
  Future<bool> updateIncidentStatus({
    required String incidentId,
    required String newStatus,
    String? staffNote,
    required bool isAuthorizedStaff,
  }) async {
    if (!isAuthorizedStaff) {
      _errorMessage = 'Unauthorized: Only campus staff can update status.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _incidentService.updateIncidentStatus(
        incidentId: incidentId,
        newStatus: newStatus,
        staffNote: staffNote,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Edit incident details (allowed for report owner while status is 'Submitted' or staff)
  Future<bool> updateIncidentDetails({
    required String incidentId,
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _incidentService.updateIncidentDetails(
        incidentId: incidentId,
        title: title,
        description: description,
        category: category,
        location: location,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update report details.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete an incident report and its photo from Firebase Storage
  Future<bool> deleteIncident(IncidentModel incident) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.deleteIncidentPhoto(incident.imageUrl);
      await _incidentService.deleteIncident(incident.id);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete incident report.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _incidentsSubscription?.cancel();
    super.dispose();
  }
}