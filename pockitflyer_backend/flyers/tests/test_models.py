from datetime import timedelta
from decimal import Decimal
from io import BytesIO

import pytest
from django.core.exceptions import ValidationError
from django.core.files.uploadedfile import SimpleUploadedFile
from django.db import connection
from django.utils import timezone
from PIL import Image

from flyers.models import Flyer, FlyerImage
from users.models import User


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


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerModel:
    def test_create_flyer_with_required_fields(self, user):
        """Test creating a flyer with all required fields"""
        flyer = Flyer.objects.create(
            title="Test Flyer",
            description="Test description",
            creator=user,
            location_address="123 Test St, Test City",
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.title == "Test Flyer"
        assert flyer.description == "Test description"
        assert flyer.creator == user
        assert flyer.location_address == "123 Test St, Test City"
        assert flyer.latitude == Decimal("47.123456")
        assert flyer.longitude == Decimal("8.123456")
        assert flyer.created_at is not None
        assert flyer.updated_at is not None

    def test_flyer_str_representation(self, user):
        """Test flyer string representation"""
        flyer = Flyer.objects.create(
            title="Test Flyer",
            description="Test description",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert str(flyer) == "Test Flyer"

    def test_flyer_title_max_length(self, user):
        """Test that flyer title respects max length of 200 chars"""
        title = "A" * 201

        flyer = Flyer(
            title=title,
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_flyer_description_max_length(self, user):
        """Test that flyer description respects max length of 2000 chars"""
        description = "A" * 2001

        flyer = Flyer(
            title="Test",
            description=description,
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_flyer_address_max_length(self, user):
        """Test that location address respects max length of 500 chars"""
        address = "A" * 501

        flyer = Flyer(
            title="Test",
            description="Test description",
            creator=user,
            location_address=address,
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_flyer_updated_at_auto_updates(self, user):
        """Test that updated_at timestamp auto-updates on save"""
        flyer = Flyer.objects.create(
            title="Test Flyer",
            description="Test description",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("47.123456"),
            longitude=Decimal("8.123456"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        original_updated_at = flyer.updated_at

        # Small delay to ensure timestamp difference
        import time
        time.sleep(0.01)

        flyer.title = "Updated Flyer"
        flyer.save()

        assert flyer.updated_at > original_updated_at


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerCoordinateValidation:
    def test_latitude_within_valid_range(self, user):
        """Test latitude accepts values between -90 and 90"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.latitude == Decimal("45.0")

    def test_latitude_min_boundary(self, user):
        """Test latitude accepts minimum value of -90"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("-90.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.latitude == Decimal("-90.0")

    def test_latitude_max_boundary(self, user):
        """Test latitude accepts maximum value of 90"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("90.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.latitude == Decimal("90.0")

    def test_latitude_below_min_raises_error(self, user):
        """Test latitude below -90 raises validation error"""
        flyer = Flyer(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("-90.1"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_latitude_above_max_raises_error(self, user):
        """Test latitude above 90 raises validation error"""
        flyer = Flyer(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("90.1"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_longitude_within_valid_range(self, user):
        """Test longitude accepts values between -180 and 180"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.longitude == Decimal("8.0")

    def test_longitude_min_boundary(self, user):
        """Test longitude accepts minimum value of -180"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("-180.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.longitude == Decimal("-180.0")

    def test_longitude_max_boundary(self, user):
        """Test longitude accepts maximum value of 180"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("180.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        assert flyer.longitude == Decimal("180.0")

    def test_longitude_below_min_raises_error(self, user):
        """Test longitude below -180 raises validation error"""
        flyer = Flyer(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("-180.1"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()

    def test_longitude_above_max_raises_error(self, user):
        """Test longitude above 180 raises validation error"""
        flyer = Flyer(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("180.1"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError):
            flyer.full_clean()


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerValidityPeriod:
    def test_is_valid_when_current_time_within_period(self, user):
        """Test is_valid returns True when current time is within validity period"""
        now = timezone.now()
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=now - timedelta(hours=1),
            valid_until=now + timedelta(hours=1)
        )

        assert flyer.is_valid is True

    def test_is_valid_false_before_valid_from(self, user):
        """Test is_valid returns False when current time is before valid_from"""
        now = timezone.now()
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=now + timedelta(hours=1),
            valid_until=now + timedelta(hours=2)
        )

        assert flyer.is_valid is False

    def test_is_valid_false_after_valid_until(self, user):
        """Test is_valid returns False when current time is after valid_until"""
        now = timezone.now()
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=now - timedelta(hours=2),
            valid_until=now - timedelta(hours=1)
        )

        assert flyer.is_valid is False

    def test_is_valid_true_at_exact_valid_from_time(self, user):
        """Test is_valid returns True at exact valid_from time"""
        now = timezone.now()
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=now,
            valid_until=now + timedelta(hours=1)
        )

        assert flyer.is_valid is True

    def test_is_valid_false_at_exact_valid_until_time(self, user):
        """Test is_valid returns False at exact valid_until time"""
        now = timezone.now()
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=now - timedelta(hours=1),
            valid_until=now
        )

        assert flyer.is_valid is False


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerImageModel:
    def test_create_flyer_image(self, user, sample_image):
        """Test creating a flyer image"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        flyer_image = FlyerImage.objects.create(
            flyer=flyer,
            image=sample_image,
            order=1
        )

        assert flyer_image.flyer == flyer
        assert flyer_image.order == 1
        assert flyer_image.created_at is not None

    def test_flyer_image_str_representation(self, user, sample_image):
        """Test flyer image string representation"""
        flyer = Flyer.objects.create(
            title="Test Flyer",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        flyer_image = FlyerImage.objects.create(
            flyer=flyer,
            image=sample_image,
            order=1
        )

        assert str(flyer_image) == "Test Flyer - Image 1"

    def test_multiple_images_for_one_flyer(self, user, sample_image):
        """Test creating multiple images for a single flyer"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        # Create multiple images
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

        assert flyer.images.count() == 3


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerImageCountValidation:
    def test_flyer_requires_at_least_one_image(self, user):
        """Test that a flyer must have at least one image"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        with pytest.raises(ValidationError) as exc_info:
            flyer.clean()

        assert "at least one image" in str(exc_info.value).lower()

    def test_flyer_accepts_one_image(self, user, sample_image):
        """Test that a flyer can have exactly one image"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        FlyerImage.objects.create(
            flyer=flyer,
            image=sample_image,
            order=1
        )

        # Should not raise an error
        flyer.clean()

    def test_flyer_accepts_five_images(self, user):
        """Test that a flyer can have up to 5 images"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        for i in range(1, 6):
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

        # Should not raise an error
        flyer.clean()

    def test_flyer_rejects_more_than_five_images(self, user):
        """Test that a flyer cannot have more than 5 images"""
        flyer = Flyer.objects.create(
            title="Test",
            description="Test",
            creator=user,
            location_address="123 Test St",
            latitude=Decimal("45.0"),
            longitude=Decimal("8.0"),
            valid_from=timezone.now(),
            valid_until=timezone.now() + timedelta(days=7)
        )

        for i in range(1, 7):
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

        with pytest.raises(ValidationError) as exc_info:
            flyer.clean()

        assert "maximum of 5 images" in str(exc_info.value).lower()


@pytest.mark.django_db
@pytest.mark.tdd_green
class TestFlyerIndexes:
    def test_creator_index_exists(self):
        """Test that creator field has a database index"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]

        # Check if there's an index on creator
        assert any('creator' in fields for fields in index_fields)

    def test_location_index_exists(self):
        """Test that latitude and longitude have database indexes"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]

        # Check if there's an index covering latitude and longitude
        assert any('latitude' in fields and 'longitude' in fields for fields in index_fields)

    def test_validity_period_index_exists(self):
        """Test that valid_from and valid_until have database indexes"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]

        # Check if there's an index covering validity period
        assert any('valid_from' in fields and 'valid_until' in fields for fields in index_fields)

    def test_created_at_index_exists(self):
        """Test that created_at field has a database index"""
        indexes = [index.name for index in Flyer._meta.indexes]
        index_fields = [list(index.fields) for index in Flyer._meta.indexes]

        # Check if there's an index on created_at
        assert any('created_at' in fields for fields in index_fields)
