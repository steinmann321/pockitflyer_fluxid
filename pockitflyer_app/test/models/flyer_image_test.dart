import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';

void main() {
  group('FlyerImage Model Tests', () {
    test('creates FlyerImage with all fields', () {
      final image = FlyerImage(
        url: 'https://example.com/image1.jpg',
        order: 0,
      );

      expect(image.url, 'https://example.com/image1.jpg');
      expect(image.order, 0);
    }, tags: ['tdd_green']);

    test('creates FlyerImage from JSON', () {
      final json = {'url': 'https://example.com/img.jpg', 'order': 2};
      final image = FlyerImage.fromJson(json);

      expect(image.url, 'https://example.com/img.jpg');
      expect(image.order, 2);
    }, tags: ['tdd_green']);

    test('converts FlyerImage to JSON', () {
      final image = FlyerImage(url: 'test.jpg', order: 1);
      final json = image.toJson();

      expect(json['url'], 'test.jpg');
      expect(json['order'], 1);
    }, tags: ['tdd_green']);

    test('equality works correctly', () {
      final img1 = FlyerImage(url: 'test.jpg', order: 0);
      final img2 = FlyerImage(url: 'test.jpg', order: 0);
      final img3 = FlyerImage(url: 'other.jpg', order: 0);

      expect(img1 == img2, isTrue);
      expect(img1.hashCode, img2.hashCode);
      expect(img1 == img3, isFalse);
    }, tags: ['tdd_green']);
  });
}
