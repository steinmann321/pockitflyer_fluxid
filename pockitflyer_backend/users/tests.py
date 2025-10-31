import pytest
from django.core.exceptions import ValidationError
from decimal import Decimal

pytestmark = pytest.mark.django_db


@pytest.mark.tdd_green
def test_user_model_str(user_factory):
    user = user_factory(email="alice@example.com")
    assert str(user) == "alice@example.com"


@pytest.mark.tdd_green
def test_admin_login_page_accessible(client):
    resp = client.get("/admin/login/?next=/admin/")
    assert resp.status_code in (200, 302)


@pytest.mark.tdd_green
def test_api_client_available(api_client):
    resp = api_client.get("/admin/")
    assert resp.status_code in (200, 302)


@pytest.mark.tdd_green
def test_user_model_email_unique(user_factory):
    """Test that email field is unique"""
    from django.db import IntegrityError
    user_factory(email="test@example.com")
    with pytest.raises(IntegrityError):
        user_factory(email="test@example.com")


@pytest.mark.tdd_green
def test_user_username_field_is_email(user_factory):
    """Test that USERNAME_FIELD is set to email"""
    from users.models import User
    assert User.USERNAME_FIELD == "email"


@pytest.mark.tdd_green
def test_user_required_fields_contains_username(user_factory):
    """Test that REQUIRED_FIELDS contains username"""
    from users.models import User
    assert User.REQUIRED_FIELDS == ["username"]


# New tests for enhanced User model (m01-e01-t01)

@pytest.mark.tdd_green
def test_user_has_username_field():
    """Test that User model has username field"""
    from users.models import User
    user = User(email="test@example.com", username="testuser")
    assert hasattr(user, 'username')
    assert user.username == "testuser"


@pytest.mark.tdd_green
def test_user_username_is_required():
    """Test that username field is required"""
    from users.models import User
    user = User(email="test@example.com", password="testpass123")
    with pytest.raises(ValidationError) as exc_info:
        user.full_clean()
    assert 'username' in exc_info.value.error_dict


@pytest.mark.tdd_green
def test_user_username_is_indexed():
    """Test that username field has database index"""
    from users.models import User
    username_field = User._meta.get_field('username')
    assert username_field.db_index is True


@pytest.mark.tdd_green
def test_user_email_is_indexed():
    """Test that email field has database index"""
    from users.models import User
    email_field = User._meta.get_field('email')
    assert email_field.db_index is True


@pytest.mark.tdd_green
def test_user_has_optional_profile_picture():
    """Test that User model has optional profile_picture field"""
    from users.models import User
    user = User(email="test@example.com", username="testuser")
    assert hasattr(user, 'profile_picture')
    assert not user.profile_picture


@pytest.mark.tdd_green
def test_user_has_optional_bio():
    """Test that User model has optional bio field"""
    from users.models import User
    user = User(email="test@example.com", username="testuser")
    assert hasattr(user, 'bio')
    assert user.bio is None or user.bio == ''


@pytest.mark.tdd_green
def test_user_has_latitude_field():
    """Test that User model has latitude field"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", latitude=Decimal('47.3769'))
    assert hasattr(user, 'latitude')
    assert user.latitude == Decimal('47.3769')


@pytest.mark.tdd_green
def test_user_has_longitude_field():
    """Test that User model has longitude field"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", longitude=Decimal('8.5417'))
    assert hasattr(user, 'longitude')
    assert user.longitude == Decimal('8.5417')


@pytest.mark.tdd_green
def test_user_latitude_optional():
    """Test that latitude is optional"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123")
    user.full_clean()
    assert user.latitude is None


@pytest.mark.tdd_green
def test_user_longitude_optional():
    """Test that longitude is optional"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123")
    user.full_clean()
    assert user.longitude is None


@pytest.mark.tdd_green
def test_user_latitude_validates_min_range():
    """Test that latitude validates minimum value (-90)"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", latitude=Decimal('-91'))
    with pytest.raises(ValidationError) as exc_info:
        user.full_clean()
    assert 'latitude' in exc_info.value.error_dict


@pytest.mark.tdd_green
def test_user_latitude_validates_max_range():
    """Test that latitude validates maximum value (90)"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", latitude=Decimal('91'))
    with pytest.raises(ValidationError) as exc_info:
        user.full_clean()
    assert 'latitude' in exc_info.value.error_dict


@pytest.mark.tdd_green
def test_user_longitude_validates_min_range():
    """Test that longitude validates minimum value (-180)"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", longitude=Decimal('-181'))
    with pytest.raises(ValidationError) as exc_info:
        user.full_clean()
    assert 'longitude' in exc_info.value.error_dict


@pytest.mark.tdd_green
def test_user_longitude_validates_max_range():
    """Test that longitude validates maximum value (180)"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", longitude=Decimal('181'))
    with pytest.raises(ValidationError) as exc_info:
        user.full_clean()
    assert 'longitude' in exc_info.value.error_dict


@pytest.mark.tdd_green
def test_user_latitude_accepts_valid_values():
    """Test that latitude accepts valid values in range"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", latitude=Decimal('45.5'))
    user.full_clean()
    assert user.latitude == Decimal('45.5')


@pytest.mark.tdd_green
def test_user_longitude_accepts_valid_values():
    """Test that longitude accepts valid values in range"""
    from users.models import User
    user = User(email="test@example.com", username="testuser", password="testpass123", longitude=Decimal('120.5'))
    user.full_clean()
    assert user.longitude == Decimal('120.5')


@pytest.mark.tdd_green
def test_user_has_created_at_timestamp():
    """Test that User model has created_at timestamp"""
    from users.models import User
    user = User(email="test@example.com", username="testuser")
    assert hasattr(user, 'created_at')


@pytest.mark.tdd_green
def test_user_has_updated_at_timestamp():
    """Test that User model has updated_at timestamp"""
    from users.models import User
    user = User(email="test@example.com", username="testuser")
    assert hasattr(user, 'updated_at')


@pytest.mark.tdd_green
def test_user_created_at_auto_set(user_factory):
    """Test that created_at is automatically set on creation"""
    from datetime import datetime
    user = user_factory(email="test@example.com", username="testuser")
    assert user.created_at is not None
    assert isinstance(user.created_at, datetime)


@pytest.mark.tdd_green
def test_user_updated_at_auto_set(user_factory):
    """Test that updated_at is automatically set on creation"""
    from datetime import datetime
    user = user_factory(email="test@example.com", username="testuser")
    assert user.updated_at is not None
    assert isinstance(user.updated_at, datetime)


@pytest.mark.tdd_green
def test_user_updated_at_changes_on_save(user_factory):
    """Test that updated_at changes when user is saved"""
    import time
    user = user_factory(email="test@example.com", username="testuser")
    original_updated_at = user.updated_at
    time.sleep(0.01)
    user.bio = "Updated bio"
    user.save()
    assert user.updated_at > original_updated_at
