from .settings import *  # noqa

# Test settings overrides for faster, isolated tests
DEBUG = False
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]
EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'

# Use in-memory SQLite DB for speed where supported
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

# Disable migrations for faster test DB setup; instead create tables directly
class DisableMigrations:
    def __contains__(self, item):
        return True
    def __getitem__(self, item):
        return None

MIGRATION_MODULES = DisableMigrations()
