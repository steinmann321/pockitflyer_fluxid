import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockitflyer_app/providers/feed_provider.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';
import 'package:pockitflyer_app/services/location_service.dart';
import 'package:pockitflyer_app/widgets/flyer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @visibleForTesting
  final ScrollController scrollController = ScrollController();
  static const _scrollThreshold = 0.8;
  static const _appBarTitle = 'Nearby Flyers';
  static const _retryButtonText = 'Retry';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * _scrollThreshold) {
      context.read<FeedProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    try {
      await context.read<FeedProvider>().refresh();
    } catch (e) {
      // Error handled by FeedProvider state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home_screen_scaffold'),
      appBar: AppBar(
        key: const Key('app_bar'),
        title: const Text(_appBarTitle),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          final status = feedProvider.status;

          if (status == FeedStatus.initial || status == FeedStatus.loading) {
            return const Center(
              key: Key('loading_indicator'),
              child: CircularProgressIndicator(),
            );
          }

          if (status == FeedStatus.error && feedProvider.flyers.isEmpty) {
            return _buildErrorState(feedProvider.errorMessage);
          }

          if (status == FeedStatus.empty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            key: const Key('refresh_indicator'),
            onRefresh: _onRefresh,
            child: ListView.builder(
              key: const Key('flyer_list'),
              controller: scrollController,
              itemCount: feedProvider.flyers.length +
                  (feedProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= feedProvider.flyers.length) {
                  return const Padding(
                    key: Key('bottom_loading_indicator'),
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final flyer = feedProvider.flyers[index];
                return FlyerCard(
                  key: Key('flyer_card_${flyer.id}'),
                  flyer: flyer,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      key: const Key('error_state'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load flyers. Check your connection and try again.",
              key: Key('error_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(key: const Key('retry_button'),
              onPressed: () => context.read<FeedProvider>().loadFeed(),
              child: const Text(_retryButtonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const Key('empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No flyers nearby. Pull to refresh or adjust your location.',
              key: Key('empty_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
