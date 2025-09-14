import 'package:flutter/foundation.dart';
import '../models/media.dart';
import 'api_service.dart';

class MediaService extends ChangeNotifier {
  static MediaService? _instance;
  static MediaService get instance => _instance ??= MediaService._();
  
  MediaService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<List<MediaModel>> _mediaList = ValueNotifier<List<MediaModel>>([]);
  final ValueNotifier<Map<int, bool>> _favorites = ValueNotifier<Map<int, bool>>({});
  
  List<MediaModel> get mediaList => _mediaList.value;
  Map<int, bool> get favorites => _favorites.value;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  
  // Filters
  int? _currentEventId;
  String? _currentType;
  String? _currentStatus;
  
  int? get currentEventId => _currentEventId;
  String? get currentType => _currentType;
  String? get currentStatus => _currentStatus;
  
  // Load media with optional filters
  Future<void> loadMedia({
    int? eventId,
    String? type,
    String? status,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _mediaList.value = [];
      }
      
      if (!_hasMorePages && !refresh) return;
      
      isLoading.value = true;
      error.value = null;
      
      // Update current filters
      _currentEventId = eventId;
      _currentType = type;
      _currentStatus = status;
      
      final response = await _apiService.getMediaList(
        eventId: eventId,
        type: type,
        status: status,
        page: _currentPage,
      );
      
      if (response['data'] != null) {
        final List<dynamic> mediaData = response['data'];
        final List<MediaModel> newMedia = mediaData
            .map((json) => MediaModel.fromJson(json))
            .toList();
        
        if (refresh) {
          _mediaList.value = newMedia;
        } else {
          _mediaList.value = [..._mediaList.value, ...newMedia];
        }
        
        // Update pagination info
        _currentPage = response['current_page'] ?? _currentPage + 1;
        _hasMorePages = response['next_page_url'] != null;
        
        // Update favorites
        _updateFavoritesFromMedia(newMedia);
      } else {
        error.value = response['message'] ?? 'Failed to load media';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load more media (pagination)
  Future<void> loadMoreMedia() async {
    if (!_hasMorePages || isLoading.value) return;
    
    _currentPage++;
    await loadMedia(
      eventId: _currentEventId,
      type: _currentType,
      status: _currentStatus,
    );
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(int mediaId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.toggleMediaFavorite(mediaId);
      
      if (response['favorited'] != null) {
        final isFavorited = response['favorited'] as bool;
        
        // Update local favorites
        final currentFavorites = Map<int, bool>.from(_favorites.value);
        currentFavorites[mediaId] = isFavorited;
        _favorites.value = currentFavorites;
        
        // Update media list
        final updatedMediaList = _mediaList.value.map((media) {
          if (media.id == mediaId) {
            return media.copyWith(isFavorited: isFavorited);
          }
          return media;
        }).toList();
        _mediaList.value = updatedMediaList;
        
        notifyListeners();
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to toggle favorite';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Check if media is favorited
  bool isFavorited(int mediaId) {
    return _favorites.value[mediaId] ?? false;
  }
  
  // Get media by ID
  MediaModel? getMediaById(int id) {
    try {
      return _mediaList.value.firstWhere((media) => media.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get media by event ID
  List<MediaModel> getMediaByEventId(int eventId) {
    return _mediaList.value.where((media) => media.eventId == eventId).toList();
  }
  
  // Get media by type
  List<MediaModel> getMediaByType(String type) {
    return _mediaList.value.where((media) => media.type == type).toList();
  }
  
  // Get favorited media
  List<MediaModel> getFavoritedMedia() {
    return _mediaList.value.where((media) => isFavorited(media.id)).toList();
  }
  
  // Update favorites from media list
  void _updateFavoritesFromMedia(List<MediaModel> mediaList) {
    final currentFavorites = Map<int, bool>.from(_favorites.value);
    
    for (final media in mediaList) {
      if (media.isFavorited != null) {
        currentFavorites[media.id] = media.isFavorited!;
      }
    }
    
    _favorites.value = currentFavorites;
  }
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Clear all data
  void clearAll() {
    _mediaList.value = [];
    _favorites.value = {};
    _currentPage = 1;
    _hasMorePages = true;
    _currentEventId = null;
    _currentType = null;
    _currentStatus = null;
    error.value = null;
    notifyListeners();
  }
  
  // Refresh current filters
  Future<void> refresh() async {
    await loadMedia(
      eventId: _currentEventId,
      type: _currentType,
      status: _currentStatus,
      refresh: true,
    );
  }
}
