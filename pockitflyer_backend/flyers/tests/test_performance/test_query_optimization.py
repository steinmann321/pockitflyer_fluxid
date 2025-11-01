from datetime import timedelta
from decimal import Decimal
from io import BytesIO

import pytest
from django.db import connection
from django.test.utils import override_settings
from django.utils import timezone
from PIL import Image
from django.core.files.uploadedfile import SimpleUploadedFile
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


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestQueryOptimization:
    def test_feed_uses_select_related_for_creator(self, api_client, user):
        """Test that feed query uses select_related to minimize DB queries for creator"""
        # Create 10 flyers
        for i in range(10):
            create_flyer_with_image(user, f"Flyer {i}", 47.0 + i * 0.01, 8.0)

        # Reset query count
        connection.queries_log.clear()

        # Make request with query logging enabled
        with override_settings(DEBUG=True):
            from django.db import reset_queries
            reset_queries()

            response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

            # Count queries that fetch User model (creator)
            user_queries = [
                q for q in connection.queries
                if 'users_user' in q['sql'].lower()
                and 'SELECT' in q['sql'].upper()
            ]

            # With select_related, we should have at most 1 query for users
            # (joined with the main flyer query)
            assert len(user_queries) <= 1, (
                f"Expected at most 1 user query with select_related, got {len(user_queries)}"
            )

        assert response.status_code == 200

    def test_feed_uses_prefetch_related_for_images(self, api_client, user):
        """Test that feed query uses prefetch_related to minimize DB queries for images"""
        # Create 5 flyers with multiple images each
        for i in range(5):
            flyer = Flyer.objects.create(
                title=f"Flyer {i}",
                description="Test",
                creator=user,
                location_address="Test Address",
                latitude=Decimal("47.0"),
                longitude=Decimal("8.0"),
                valid_from=timezone.now() - timedelta(hours=1),
                valid_until=timezone.now() + timedelta(days=7)
            )

            # Add 3 images per flyer
            for j in range(1, 4):
                image = Image.new('RGB', (100, 100), color='red')
                image_io = BytesIO()
                image.save(image_io, format='JPEG')
                image_io.seek(0)
                img_file = SimpleUploadedFile(f"test{i}_{j}.jpg", image_io.read(), content_type="image/jpeg")

                FlyerImage.objects.create(
                    flyer=flyer,
                    image=img_file,
                    order=j
                )

        # Make request with query logging enabled
        with override_settings(DEBUG=True):
            from django.db import reset_queries
            reset_queries()

            response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0'})

            # Count queries that fetch FlyerImage model
            image_queries = [
                q for q in connection.queries
                if 'flyers_flyerimage' in q['sql'].lower()
                and 'SELECT' in q['sql'].upper()
            ]

            # With prefetch_related, we should have at most 1 query for images
            # (separate from the main query but batched)
            assert len(image_queries) <= 1, (
                f"Expected at most 1 image query with prefetch_related, got {len(image_queries)}"
            )

        assert response.status_code == 200
        assert len(response.data['results']) == 5

    def test_feed_total_query_count_is_reasonable(self, api_client, user):
        """Test that feed doesn't have N+1 query problem"""
        # Create 20 flyers
        for i in range(20):
            create_flyer_with_image(user, f"Flyer {i}", 47.0 + i * 0.01, 8.0)

        # Make request with query logging enabled
        with override_settings(DEBUG=True):
            from django.db import reset_queries
            reset_queries()

            response = api_client.get('/api/v1/flyers/feed/', {'lat': '47.0', 'lng': '8.0', 'page_size': '20'})

            total_queries = len(connection.queries)

            # With proper optimization, we should have:
            # 1-2 queries for flyers (with select_related for creator)
            # 1 query for images (prefetch_related)
            # 1 query for pagination count
            # = ~4 queries total (allow some margin)
            assert total_queries < 10, (
                f"Expected < 10 queries with optimization, got {total_queries}. "
                f"This suggests an N+1 query problem."
            )

        assert response.status_code == 200
        assert len(response.data['results']) == 20


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestDatabaseIndexes:
    def test_flyer_creator_index_exists(self):
        """Test that Flyer.creator field has a database index"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]
        assert any('creator' in fields for fields in index_fields)

    def test_flyer_location_compound_index_exists(self):
        """Test that Flyer has compound index on (latitude, longitude)"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]
        assert any(
            'latitude' in fields and 'longitude' in fields
            for fields in index_fields
        )

    def test_flyer_validity_period_compound_index_exists(self):
        """Test that Flyer has compound index on (valid_from, valid_until)"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]
        assert any(
            'valid_from' in fields and 'valid_until' in fields
            for fields in index_fields
        )

    def test_flyer_created_at_index_exists(self):
        """Test that Flyer.created_at field has a database index"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]
        assert any('created_at' in fields for fields in index_fields)

    def test_user_username_index_exists(self):
        """Test that User.username field has a database index"""
        username_field = User._meta.get_field('username')
        assert username_field.db_index is True

    def test_user_email_index_exists(self):
        """Test that User.email field has a database index"""
        email_field = User._meta.get_field('email')
        assert email_field.db_index is True
