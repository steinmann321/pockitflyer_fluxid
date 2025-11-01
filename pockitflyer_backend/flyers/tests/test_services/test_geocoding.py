"""Tests for geocoding service with circuit breaker."""

import pytest
from unittest.mock import Mock, patch
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
from flyers.services.geocoding import GeocodingService, GeocodingError


@pytest.mark.tdd_green
def test_successful_geocoding():
    """Test successful address geocoding."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        mock_location = Mock()
        mock_location.latitude = 47.3769
        mock_location.longitude = 8.5417
        mock_geocode.return_value = mock_location

        lat, lon = service.geocode("Zurich, Switzerland")

        assert lat == 47.3769
        assert lon == 8.5417
        assert mock_geocode.call_count == 1


@pytest.mark.tdd_green
def test_geocode_various_address_formats():
    """Test geocoding with various address formats."""
    service = GeocodingService()

    test_addresses = [
        "123 Main St, New York, NY 10001",
        "Bahnhofstrasse 1, 8001 Zürich",
        "London, UK",
    ]

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        mock_location = Mock()
        mock_location.latitude = 51.5074
        mock_location.longitude = -0.1278
        mock_geocode.return_value = mock_location

        for address in test_addresses:
            lat, lon = service.geocode(address)
            assert isinstance(lat, float)
            assert isinstance(lon, float)


@pytest.mark.tdd_green
def test_invalid_address_raises_error():
    """Test that invalid address raises GeocodingError."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        mock_geocode.return_value = None

        with pytest.raises(GeocodingError) as exc_info:
            service.geocode("InvalidAddressXYZ123456789")

        assert "Could not geocode address" in str(exc_info.value)


@pytest.mark.tdd_green
def test_timeout_triggers_retry():
    """Test that timeout triggers retry with exponential backoff."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        with patch('time.sleep') as mock_sleep:
            # First two calls timeout, third succeeds
            mock_location = Mock()
            mock_location.latitude = 47.3769
            mock_location.longitude = 8.5417

            mock_geocode.side_effect = [
                GeocoderTimedOut(),
                GeocoderTimedOut(),
                mock_location,
            ]

            lat, lon = service.geocode("Zurich, Switzerland")

            assert lat == 47.3769
            assert lon == 8.5417
            assert mock_geocode.call_count == 3
            # Verify exponential backoff: 1s, 2s
            assert mock_sleep.call_count == 2
            assert mock_sleep.call_args_list[0][0][0] == 1
            assert mock_sleep.call_args_list[1][0][0] == 2


@pytest.mark.tdd_green
def test_all_retries_fail_raises_error():
    """Test that exhausting all retries raises GeocodingError."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        with patch('time.sleep'):
            mock_geocode.side_effect = GeocoderTimedOut()

            with pytest.raises(GeocodingError) as exc_info:
                service.geocode("Zurich, Switzerland")

            assert "Failed after 3 attempts" in str(exc_info.value)
            assert mock_geocode.call_count == 3


@pytest.mark.tdd_green
def test_circuit_breaker_opens_after_failures():
    """Test circuit breaker opens after 3 consecutive failures."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        with patch('time.sleep'):
            mock_geocode.side_effect = GeocoderServiceError()

            # First 3 failures should trigger retries (3 attempts each)
            for _ in range(3):
                with pytest.raises(GeocodingError):
                    service.geocode("Test Address")

            # Circuit should now be open - no geocode call should be made
            with pytest.raises(GeocodingError) as exc_info:
                service.geocode("Test Address")

            assert "Circuit breaker is open" in str(exc_info.value)
            # 3 failures * 3 attempts = 9 calls before circuit opens
            assert mock_geocode.call_count == 9


@pytest.mark.tdd_green
def test_circuit_breaker_half_open_after_cooldown():
    """Test circuit breaker enters half-open state after cooldown."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        with patch('time.sleep'):
            with patch('time.time') as mock_time:
                # Initial time
                mock_time.return_value = 0
                mock_geocode.side_effect = GeocoderServiceError()

                # Trigger circuit breaker to open
                for _ in range(3):
                    with pytest.raises(GeocodingError):
                        service.geocode("Test Address")

                # Verify circuit is open
                with pytest.raises(GeocodingError) as exc_info:
                    service.geocode("Test Address")
                assert "Circuit breaker is open" in str(exc_info.value)

                # Advance time past cooldown (60 seconds)
                mock_time.return_value = 61

                # Reset mock for successful call
                mock_location = Mock()
                mock_location.latitude = 47.3769
                mock_location.longitude = 8.5417
                mock_geocode.side_effect = None
                mock_geocode.return_value = mock_location

                # Should enter half-open and allow request
                lat, lon = service.geocode("Test Address")
                assert lat == 47.3769
                assert lon == 8.5417


@pytest.mark.tdd_green
def test_circuit_breaker_closes_after_successes():
    """Test circuit breaker closes after 2 successful requests in half-open."""
    service = GeocodingService()

    with patch('geopy.geocoders.Nominatim.geocode') as mock_geocode:
        with patch('time.sleep'):
            with patch('time.time') as mock_time:
                mock_time.return_value = 0

                # Open the circuit
                mock_geocode.side_effect = GeocoderServiceError()
                for _ in range(3):
                    with pytest.raises(GeocodingError):
                        service.geocode("Test Address")

                # Advance time past cooldown
                mock_time.return_value = 61

                # Set up successful responses
                mock_location = Mock()
                mock_location.latitude = 47.3769
                mock_location.longitude = 8.5417
                mock_geocode.side_effect = None
                mock_geocode.return_value = mock_location

                # First success in half-open
                service.geocode("Test Address")

                # Second success should close the circuit
                service.geocode("Test Address")

                # Reset time to verify circuit stays closed
                mock_time.return_value = 0

                # Circuit should be closed now, allowing requests
                lat, lon = service.geocode("Test Address")
                assert lat == 47.3769
                assert lon == 8.5417


@pytest.mark.tdd_green
def test_nominatim_user_agent():
    """Test that Nominatim is initialized with correct user agent."""
    with patch('flyers.services.geocoding.Nominatim') as mock_nominatim:
        GeocodingService()
        mock_nominatim.assert_called_once_with(user_agent="PockitFlyer/1.0", timeout=5)


@pytest.mark.tdd_green
def test_geocoding_error_is_exception():
    """Test that GeocodingError is a proper exception."""
    error = GeocodingError("Test error")
    assert isinstance(error, Exception)
    assert str(error) == "Test error"
