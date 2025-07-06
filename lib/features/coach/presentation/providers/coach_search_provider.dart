import 'package:flutter/material.dart';
import '../../data/models/coach_model.dart';
import '../../services/coach_service.dart';

class CoachSearchProvider extends ChangeNotifier {
  final CoachService _coachService;
  
  List<CoachModel> _coaches = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String _searchQuery = '';
  bool _isRecommendationMode = false;
  static const int _limit = 10;

  CoachSearchProvider({CoachService? coachService}) 
      : _coachService = coachService ?? CoachService();

  List<CoachModel> get coaches => _coaches;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isRecommendationMode => _isRecommendationMode;

  Future<void> searchCoaches({String? query, bool refresh = false, bool isRecommendation = false}) async {
    if (refresh) {
      _currentPage = 1;
      _coaches = [];
      _hasMoreData = true;
    }

    if (!_hasMoreData || _isLoading) return;

    _searchQuery = query ?? _searchQuery;
    _isRecommendationMode = isRecommendation;
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = isRecommendation 
        ? await _coachService.getRecommendedCoaches(
            page: _currentPage,
            limit: _limit,
          )
        : await _coachService.getCoaches(
            page: _currentPage,
            limit: _limit,
            search: _searchQuery,
          );

      if (refresh) {
        _coaches = response.coaches;
      } else {
        _coaches.addAll(response.coaches);
      }

      _hasMoreData = _coaches.length < response.total;
      if (_hasMoreData) _currentPage++;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetSearch() {
    _searchQuery = '';
    _currentPage = 1;
    _coaches = [];
    _hasMoreData = true;
    _hasError = false;
    _errorMessage = null;
    _isRecommendationMode = false;
    notifyListeners();
  }
} 