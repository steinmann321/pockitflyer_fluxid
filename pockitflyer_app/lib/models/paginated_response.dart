import 'package:json_annotation/json_annotation.dart';

import 'flyer.dart';

part 'paginated_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PaginatedFeedResponse {
  PaginatedFeedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory PaginatedFeedResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedFeedResponseFromJson(json);

  final int count;
  final String? next;
  final String? previous;
  final List<Flyer> results;

  Map<String, dynamic> toJson() => _$PaginatedFeedResponseToJson(this);

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
