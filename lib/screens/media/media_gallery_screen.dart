import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/media_service.dart';
import '../../models/media.dart';

class MediaGalleryScreen extends StatefulWidget {
  static const String routeName = '/media-gallery';
  final int? eventId;
  final String? type;
  final String? status;
  
  const MediaGalleryScreen({
    super.key,
    this.eventId,
    this.type,
    this.status,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load media on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaService>().loadMedia(
        eventId: widget.eventId,
        type: widget.type,
        status: widget.status,
        refresh: true,
      );
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<MediaService>().loadMoreMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Media Gallery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<MediaService>().refresh(),
          ),
        ],
      ),
      body: Consumer<MediaService>(
        builder: (context, mediaService, child) {
          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('image', 'Images'),
                      const SizedBox(width: 8),
                      _buildFilterChip('video', 'Videos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('document', 'Documents'),
                      const SizedBox(width: 8),
                      _buildFilterChip('approved', 'Approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending'),
                    ],
                  ),
                ),
              ),
              
              // Media grid
              Expanded(
                child: _buildMediaGrid(mediaService),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilter();
      },
      selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6C63FF),
    );
  }
  
  void _applyFilter() {
    String? type;
    String? status;
    
    switch (_selectedFilter) {
      case 'image':
        type = 'image';
        break;
      case 'video':
        type = 'video';
        break;
      case 'document':
        type = 'document';
        break;
      case 'approved':
        status = 'approved';
        break;
      case 'pending':
        status = 'pending';
        break;
    }
    
    context.read<MediaService>().loadMedia(
      eventId: widget.eventId,
      type: type,
      status: status,
      refresh: true,
    );
  }
  
  Widget _buildMediaGrid(MediaService mediaService) {
    if (mediaService.isLoading.value && mediaService.mediaList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }
    
    if (mediaService.error.value != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading media',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mediaService.error.value!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => mediaService.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (mediaService.mediaList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No media found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Upload some media to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => mediaService.refresh(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: mediaService.mediaList.length + (mediaService.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= mediaService.mediaList.length) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            );
          }
          
          final media = mediaService.mediaList[index];
          return _buildMediaCard(media, mediaService);
        },
      ),
    );
  }
  
  Widget _buildMediaCard(MediaModel media, MediaService mediaService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMediaDetail(media, mediaService),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Media thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[200],
                child: media.isImage
                    ? Image.network(
                        media.thumbnailUrl ?? media.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          );
                        },
                      )
                    : media.isVideo
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                media.thumbnailUrl ?? media.url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.video_library,
                                    size: 48,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              const Icon(
                                Icons.play_circle_filled,
                                size: 48,
                                color: Colors.white,
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.description,
                            size: 48,
                            color: Colors.grey,
                          ),
              ),
            ),
            
            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => mediaService.toggleFavorite(media.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mediaService.isFavorited(media.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: mediaService.isFavorited(media.id)
                        ? Colors.red
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            // Status badge
            if (media.status != 'approved')
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: media.status == 'pending' 
                        ? Colors.orange 
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    media.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // Media info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      media.title ?? media.typeDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (media.uploaderName.isNotEmpty)
                      Text(
                        'by ${media.uploaderName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showMediaDetail(MediaModel media, MediaService mediaService) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Media content
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: media.isImage
                    ? Image.network(
                        media.url,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      )
                    : media.isVideo
                        ? const Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 100,
                              color: Colors.white,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.description,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Favorite button
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () => mediaService.toggleFavorite(media.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mediaService.isFavorited(media.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: mediaService.isFavorited(media.id)
                        ? Colors.red
                        : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
