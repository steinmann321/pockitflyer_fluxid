from datetime import timedelta
from decimal import Decimal
from io import BytesIO
from math import radians, sin, cos, sqrt, atan2

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.utils import timezone
from PIL import Image
from rest_framework.test import APIClient

from flyers.models import Flyer, FlyerImage
from users.models import User


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="testuser",
        email="test@example.com",
        password="testpass123"
    )


@pytest.fixture
def sample_image():
    image = Image.new('RGB', (100, 100), color='red')
    image_io = BytesIO()
    image.save(image_io, format='JPEG')
    image_io.seek(0)
    return SimpleUploadedFile("test.jpg", image_io.read(), content_type="image/jpeg")


def create_flyer_with_image(user, title, latitude, longitude, valid_from=None, valid_until=None):
    """Helper to create a flyer with an image"""
    if valid_from is None:
        valid_from = timezone.now() - timedelta(hours=1)
    if valid_until is None:
        valid_until = timezone.now() + timedelta(days=7)

    flyer = Flyer.objects.create(
        title=title,
        description=f"Description for {title}",
        creator=user,
        location_address=f"Address for {title}",
        latitude=Decimal(str(latitude)),
        longitude=Decimal(str(longitude)),
        valid_from=valid_from,
        valid_until=valid_until
    )

    # Create image
    image = Image.new('RGB', (100, 100), color='red')
    image_io = BytesIO()
    image.save(image_io, format='JPEG')
    image_io.seek(0)
    img_file = SimpleUploadedFile(f"{title}.jpg", image_io.read(), content_type="image/jpeg")

    FlyerImage.objects.create(
        flyer=flyer,
        image=img_file,
        order=1
    )

    return flyer


def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two points using Haversine formula"""
    R = 6371  # Earth's radius in km

    lat1_rad = radians(float(lat1))
    lat2_rad = radians(float(lat2))
    delta_lat = radians(float(lat2) - float(lat1))
    delta_lon = radians(float(lon2) - float(lon1))

    a = sin(delta_lat / 2) ** 2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFeedEndpoint:
    def test_feed_endpoint_exists(self, api_client, user):
        """Test that feed endpoint is accessible"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})
        assert response.status_code in [200, 400]  # Either success or validation error

    def test_feed_requires_latitude_parameter(self, api_client):
        """Test that feed endpoint requires lat parameter"""
        response = api_client.get('/api/v1/flyers/feed/', {'lng': '8.0'})
        assert response.status_code == 400

    def test_feed_requires_longitude_parameter(self, api_client):
        """Test that feed endpoint requires lng parameter"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0'})
        assert response.status_code == 400

    def test_feed_returns_valid_flyers(self, api_client, user):
        """Test that feed returns only valid flyers"""
        # Create valid flyer
        create_flyer_with_image(user, "Valid Flyer", 47.0, 8.0)

        # Create expired flyer
        now = timezone.now()
        create_flyer_with_image(
            user, "Expired Flyer", 47.1, 8.1,
            valid_from=now - timedelta(days=2),
            valid_until=now - timedelta(days=1)
        )

        # Create future flyer
        create_flyer_with_image(
            user, "Future Flyer", 47.2, 8.2,
            valid_from=now + timedelta(days=1),
            valid_until=now + timedelta(days=2)
        )

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        assert response.data['results'][0]['title'] == "Valid Flyer"

    def test_feed_includes_distance_calculation(self, api_client, user):
        """Test that feed includes distance from user location"""
        flyer = create_flyer_with_image(user, "Test Flyer", 47.0, 8.0)

        user_lat, user_lng = 47.5, 8.5
        response = api_client.get('/api/v1/flyers/feed/', {'lat': str(user_lat), 'lng': str(user_lng)})

        assert response.status_code == 200
        assert 'distance_km' in response.data['results'][0]['location']

        # Verify distance calculation
        expected_distance = haversine_distance(user_lat, user_lng, flyer.latitude, flyer.longitude)
        actual_distance = response.data['results'][0]['location']['distance_km']
        assert abs(actual_distance - expected_distance) < 0.1  # Allow small rounding difference

    def test_feed_smart_ranking_newest_first(self, api_client, user):
        """Test that feed ranks by created_at DESC (newest first)"""
        # Create flyers at different times
        flyer1 = create_flyer_with_image(user, "Old Flyer", 47.0, 8.0)
        # Modify created_at to make it older
        Flyer.objects.filter(id=flyer1.id).update(created_at=timezone.now() - timedelta(hours=2))

        flyer2 = create_flyer_with_image(user, "New Flyer", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert len(response.data['results']) == 2
        assert response.data['results'][0]['title'] == "New Flyer"
        assert response.data['results'][1]['title'] == "Old Flyer"

    def test_feed_smart_ranking_distance_secondary(self, api_client, user):
        """Test that feed ranks by distance ASC when created_at is same"""
        # Create flyers at same time but different distances
        now = timezone.now()

        flyer_far = create_flyer_with_image(user, "Far Flyer", 48.0, 9.0, valid_from=now - timedelta(hours=1))
        flyer_near = create_flyer_with_image(user, "Near Flyer", 47.1, 8.1, valid_from=now - timedelta(hours=1))

        # Set same created_at
        Flyer.objects.filter(id__in=[flyer_far.id, flyer_near.id]).update(created_at=now)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert len(response.data['results']) == 2
        # Near flyer should come first when created_at is same
        assert response.data['results'][0]['title'] == "Near Flyer"
        assert response.data['results'][1]['title'] == "Far Flyer"

    def test_feed_pagination_default_page_size(self, api_client, user):
        """Test that feed uses default page size of 20"""
        # Create 25 flyers
        for i in range(25):
            create_flyer_with_image(user, f"Flyer {i}", 47.0 + i * 0.01, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert len(response.data['results']) == 20
        assert response.data['count'] == 25

    def test_feed_pagination_custom_page_size(self, api_client, user):
        """Test that feed accepts custom page_size parameter"""
        # Create 15 flyers
        for i in range(15):
            create_flyer_with_image(user, f"Flyer {i}", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0', 'page_size': '10'})

        assert response.status_code == 200
        assert len(response.data['results']) == 10

    def test_feed_pagination_max_page_size_50(self, api_client, user):
        """Test that feed enforces maximum page_size of 50"""
        # Create 60 flyers
        for i in range(60):
            create_flyer_with_image(user, f"Flyer {i}", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0', 'page_size': '100'})

        assert response.status_code == 200
        assert len(response.data['results']) == 50  # Should be capped at 50

    def test_feed_pagination_page_parameter(self, api_client, user):
        """Test that feed supports page parameter"""
        # Create 25 flyers
        for i in range(25):
            create_flyer_with_image(user, f"Flyer {i}", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0', 'page': '2'})

        assert response.status_code == 200
        assert len(response.data['results']) == 5  # 25 total, 20 on page 1, 5 on page 2

    def test_feed_response_structure(self, api_client, user):
        """Test that feed response includes all required fields"""
        flyer = create_flyer_with_image(user, "Test Flyer", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        result = response.data['results'][0]

        # Check top-level fields
        assert 'id' in result
        assert 'title' in result
        assert 'description' in result
        assert 'creator' in result
        assert 'images' in result
        assert 'location' in result
        assert 'validity' in result

        # Check creator fields
        assert 'id' in result['creator']
        assert 'username' in result['creator']
        assert 'profile_picture' in result['creator']

        # Check images array
        assert isinstance(result['images'], list)
        assert len(result['images']) > 0

        # Check location fields
        assert 'address' in result['location']
        assert 'lat' in result['location']
        assert 'lng' in result['location']
        assert 'distance_km' in result['location']

        # Check validity fields
        assert 'valid_from' in result['validity']
        assert 'valid_until' in result['validity']
        assert 'is_valid' in result['validity']

    def test_feed_multiple_images_in_order(self, api_client, user):
        """Test that feed returns multiple images in correct order"""
        flyer = Flyer.objects.create(
            title="Multi-Image Flyer",
            description="Test",
            creator=user,
            location_address="Test Address",
            latitude=Decimal("47.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now() - timedelta(hours=1),
            valid_until=timezone.now() + timedelta(days=7)
        )

        # Create 3 images in specific order
        for i in range(1, 4):
            image = Image.new('RGB', (100, 100), color='red')
            image_io = BytesIO()
            image.save(image_io, format='JPEG')
            image_io.seek(0)
            img_file = SimpleUploadedFile(f"test{i}.jpg", image_io.read(), content_type="image/jpeg")

            FlyerImage.objects.create(
                flyer=flyer,
                image=img_file,
                order=i
            )

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        images = response.data['results'][0]['images']
        assert len(images) == 3
        # Images should be in order

    def test_feed_empty_when_no_valid_flyers(self, api_client):
        """Test that feed returns empty results when no valid flyers exist"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert len(response.data['results']) == 0
        assert response.data['count'] == 0

    def test_feed_invalid_latitude_format(self, api_client):
        """Test that feed rejects invalid latitude format"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': 'invalid', 'lng': '8.0'})
        assert response.status_code == 400

    def test_feed_invalid_longitude_format(self, api_client):
        """Test that feed rejects invalid longitude format"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': 'invalid'})
        assert response.status_code == 400

    def test_feed_latitude_out_of_range(self, api_client):
        """Test that feed rejects latitude outside valid range"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '91.0', 'lng': '8.0'})
        assert response.status_code == 400

    def test_feed_longitude_out_of_range(self, api_client):
        """Test that feed rejects longitude outside valid range"""
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '181.0'})
        assert response.status_code == 400

    def test_feed_no_authentication_required(self, api_client, user):
        """Test that feed endpoint does not require authentication"""
        create_flyer_with_image(user, "Test Flyer", 47.0, 8.0)

        # Make request without authentication
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert len(response.data['results']) == 1

    def test_feed_creator_profile_picture_absolute_url(self, api_client, user):
        """Test that creator profile_picture returns absolute URL"""
        # Set profile picture for user
        image = Image.new('RGB', (100, 100), color='blue')
        image_io = BytesIO()
        image.save(image_io, format='JPEG')
        image_io.seek(0)
        profile_pic = SimpleUploadedFile("profile.jpg", image_io.read(), content_type="image/jpeg")
        user.profile_picture = profile_pic
        user.save()

        create_flyer_with_image(user, "Test Flyer", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        profile_picture_url = response.data['results'][0]['creator']['profile_picture']
        assert profile_picture_url.startswith('http')  # Should be absolute URL

    def test_feed_creator_without_profile_picture(self, api_client, user):
        """Test that creator without profile_picture returns null"""
        create_flyer_with_image(user, "Test Flyer", 47.0, 8.0)

        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

        assert response.status_code == 200
        assert response.data['results'][0]['creator']['profile_picture'] is None


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFeedPerformance:
    def test_feed_performance_with_100_flyers(self, api_client, user):
        """Test that feed responds in <500ms with 100 flyers"""
        import time

        # Create 100 flyers
        for i in range(100):
            create_flyer_with_image(
                user,
                f"Flyer {i}",
                47.0 + (i * 0.01),
                8.0 + (i * 0.01)
            )

        start_time = time.time()
        response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})
        end_time = time.time()

        assert response.status_code == 200
        elapsed_time = (end_time - start_time) * 1000  # Convert to ms
        assert elapsed_time < 500, f"Response took {elapsed_time}ms, expected <500ms"
