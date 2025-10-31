import pytest

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
def test_user_required_fields_empty(user_factory):
    """Test that REQUIRED_FIELDS is empty"""
    from users.models import User
    assert User.REQUIRED_FIELDS == []
