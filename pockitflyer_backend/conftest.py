import pytest
from django.contrib.auth import get_user_model
from model_bakery import baker

@pytest.fixture
def user_factory(db):
    def make_user(**kwargs):
        User = get_user_model()
        user_count = User.objects.count()
        defaults = {
            'email': kwargs.get('email', f"test+{user_count}@example.com"),
            'username': kwargs.get('username', f"user{user_count}"),
        }
        defaults.update(kwargs)
        user = baker.make(User, **defaults)
        return user
    return make_user

@pytest.fixture
def api_client():
    from rest_framework.test import APIClient
    return APIClient()
