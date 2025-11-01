import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockitflyer_app/providers/feed_provider.dart';
import 'package:pockitflyer_app/screens/home_screen.dart';
import 'package:pockitflyer_app/services/feed_api_client.dart';
import 'package:pockitflyer_app/services/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FeedProvider(
            feedApiClient: FeedApiClient(),
            locationService: LocationService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PockitFlyer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
