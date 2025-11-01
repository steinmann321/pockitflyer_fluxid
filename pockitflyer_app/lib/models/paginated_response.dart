import 'flyer.dart';

class PaginatedFeedResponse {
  PaginatedFeedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory PaginatedFeedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedFeedResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => Flyer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int count;
  final String? next;
  final String? previous;
  final List<Flyer> results;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedFeedResponse &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          next == other.next &&
          previous == other.previous &&
          results.length == other.results.length;

  @override
  int get hashCode =>
      Object.hash(count, next, previous, Object.hashAll(results));
}
