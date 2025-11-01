import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FlyerCard extends StatefulWidget {
  const FlyerCard({
    required this.flyer,
    super.key,
  });

  final Flyer flyer;

  @override
  State<FlyerCard> createState() => _FlyerCardState();
}

class _FlyerCardState extends State<FlyerCard> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isVisible = false;

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('flyer_visibility_${widget.flyer.id}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(key: const Key('card_tap_detector'),
        onTap: () {
          // TODO(M01-E03): Navigate to flyer detail screen
        },
        child: Card(
          key: widget.key,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreatorHeader(),
              _buildImageCarousel(),
              _buildCardContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Text(
            widget.flyer.creator.username,
            key: const Key('creator_username'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final profilePictureUrl = widget.flyer.creator.profilePictureUrl;
    final hasProfilePicture = profilePictureUrl != null && profilePictureUrl.isNotEmpty;

    return CircleAvatar(
      key: const Key('creator_avatar'),
      radius: 16,
      backgroundImage: hasProfilePicture ? NetworkImage(profilePictureUrl) : null,
      backgroundColor: hasProfilePicture ? null : _getAvatarColor(),
      child: hasProfilePicture
          ? null
          : Text(
              widget.flyer.creator.username[0].toUpperCase(),
              key: const Key('default_avatar'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  Color _getAvatarColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final index = widget.flyer.creator.username.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Widget _buildImageCarousel() {
    if (widget.flyer.images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_isVisible) {
      return Container(
        key: const Key('image_carousel_placeholder'),
        height: 250,
        width: double.infinity,
        color: Colors.grey[300],
      );
    }

    if (widget.flyer.images.length == 1) {
      return _buildSingleImage();
    }

    return _buildMultiImageCarousel();
  }

  Widget _buildSingleImage() {
    return SizedBox(
      key: const Key('image_carousel'),
      height: 250,
      width: double.infinity,
      child: _buildImageWithLoadingState(widget.flyer.images[0].url),
    );
  }

  Widget _buildMultiImageCarousel() {
    return Stack(
      children: [
        CarouselSlider(key: const Key('image_carousel'),
          options: CarouselOptions(
            height: 250,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: widget.flyer.images
              .map((image) => _buildImageWithLoadingState(image.url))
              .toList(),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1} / ${widget.flyer.images.length}',
              key: const Key('carousel_indicator'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWithLoadingState(String url) {
    return Image.network(
      url,
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          key: const Key('image_loading_shimmer'),
          width: double.infinity,
          height: 250,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          key: const Key('image_error_placeholder'),
          width: double.infinity,
          height: 250,
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.flyer.title,
            key: const Key('flyer_title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildLocationInfo(),
          const SizedBox(height: 8),
          _buildValidityInfo(),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowLink = _shouldShowMoreLink(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.flyer.description,
              key: const Key('flyer_description'),
              maxLines: _isDescriptionExpanded ? null : 4,
              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (shouldShowLink)
              GestureDetector(key: const Key('show_more_link'),
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? 'Show less' : 'Show more',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _shouldShowMoreLink(double maxWidth) {
    final textSpan = TextSpan(
      text: widget.flyer.description,
      style: const TextStyle(fontSize: 14),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 4,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.flyer.locationAddress,
            key: const Key('location_address'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (widget.flyer.distanceKm != null)
          Text(
            _formatDistance(widget.flyer.distanceKm!),
            key: const Key('location_distance'),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  Widget _buildValidityInfo() {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          'Valid until ${dateFormat.format(widget.flyer.validUntil)}',
          key: const Key('validity_text'),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
