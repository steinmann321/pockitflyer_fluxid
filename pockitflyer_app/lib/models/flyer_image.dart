class FlyerImage {
  FlyerImage({
    required this.url,
    required this.order,
  });

  factory FlyerImage.fromJson(Map<String, dynamic> json) {
    return FlyerImage(
      url: json['url'] as String,
      order: json['order'] as int,
    );
  }

  final String url;
  final int order;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyerImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          order == other.order;

  @override
  int get hashCode => Object.hash(url, order);
}
