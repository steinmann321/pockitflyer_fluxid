import pytest
from django.contrib.auth import get_user_model
from model_bakery import baker

@pytest.fixture
def user_factory(db):
    def make_user(**kwargs):
        User = get_user_model()
        defaults = {
            'email': kwargs.get('email', f"test+{User.objects.count()}@example.com"),
        }
        defaults.update(kwargs)
        user = baker.make(User, **defaults)
        return user
    return make_user

@pytest.fixture
def api_client():
    from rest_framework.test import APIClient
    return APIClient()
