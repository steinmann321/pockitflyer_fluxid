import pytest

pytestmark = pytest.mark.django_db


def test_user_model_str(user_factory):
    user = user_factory(email="alice@example.com")
    assert str(user) == "alice@example.com"


def test_admin_login_page_accessible(client):
    resp = client.get("/admin/login/?next=/admin/")
    assert resp.status_code in (200, 302)


def test_api_client_available(api_client):
    resp = api_client.get("/admin/")
    assert resp.status_code in (200, 302)
