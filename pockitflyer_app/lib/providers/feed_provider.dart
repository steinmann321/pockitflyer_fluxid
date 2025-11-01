import 'package:flutter/foundation.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/location.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';
import 'package:pockitflyer_app/services/location_service.dart';

enum FeedStatus {
  initial,
  loading,
  loaded,
  error,
  empty,
  loadingMore,
}

class FeedProvider extends ChangeNotifier {
  FeedProvider({
    required FeedApiClient feedApiClient,
    required LocationService locationService,
  })  : _feedApiClient = feedApiClient,
        _locationService = locationService;

  final FeedApiClient _feedApiClient;
  final LocationService _locationService;

  FeedStatus _status = FeedStatus.initial;
  List<Flyer> _flyers = [];
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  FeedStatus get status => _status;
  List<Flyer> get flyers => List.unmodifiable(_flyers);
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadFeed() async {
    if (_status == FeedStatus.loading) return;

    _status = FeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await _locationService.getLocation();
      final response = await _feedApiClient.getFeed(
        lat: location.latitude,
        lng: location.longitude,
        page: 1,
      );

      _flyers = response.results;
      _currentPage = 1;
      _hasMore = response.next != null;

      if (_flyers.isEmpty) {
        _status = FeedStatus.empty;
      } else {
        _status = FeedStatus.loaded;
      }
    } catch (e) {
      _status = FeedStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    await loadFeed();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _status == FeedStatus.loadingMore) return;

    _status = FeedStatus.loadingMore;
    notifyListeners();

    try {
      final location = await _locationService.getLocation();
      final response = await _feedApiClient.getFeed(
        lat: location.latitude,
        lng: location.longitude,
        page: _currentPage + 1,
      );

      _flyers.addAll(response.results);
      _currentPage++;
      _hasMore = response.next != null;
      _status = FeedStatus.loaded;
    } catch (e) {
      _status = FeedStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}
