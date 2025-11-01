"""Geocoding service with circuit breaker pattern."""

import time
from enum import Enum
from typing import Optional
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError


class GeocodingError(Exception):
    """Exception raised for geocoding failures."""
    pass


class CircuitState(Enum):
    """Circuit breaker states."""
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"


class CircuitBreaker:
    """Circuit breaker implementation for external service calls."""

    def __init__(self, failure_threshold: int = 3, cooldown_period: int = 60, success_threshold: int = 2):
        self.failure_threshold = failure_threshold
        self.cooldown_period = cooldown_period
        self.success_threshold = success_threshold
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time: Optional[float] = None
        self.state = CircuitState.CLOSED

    def call(self, func, *args, **kwargs):
        """Execute function with circuit breaker protection."""
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time >= self.cooldown_period:
                self.state = CircuitState.HALF_OPEN
                self.success_count = 0
            else:
                raise GeocodingError("Circuit breaker is open")

        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e

    def _on_success(self):
        """Handle successful call."""
        self.failure_count = 0
        if self.state == CircuitState.HALF_OPEN:
            self.success_count += 1
            if self.success_count >= self.success_threshold:
                self.state = CircuitState.CLOSED
                self.success_count = 0

    def _on_failure(self):
        """Handle failed call."""
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN


class GeocodingService:
    """Service for geocoding addresses with circuit breaker and retry logic."""

    def __init__(self):
        self.geocoder = Nominatim(user_agent="PockitFlyer/1.0", timeout=5)
        self.circuit_breaker = CircuitBreaker(
            failure_threshold=3,
            cooldown_period=60,
            success_threshold=2
        )
        self.max_retries = 3
        self.base_delay = 1  # seconds

    def geocode(self, address: str) -> tuple[float, float]:
        """
        Geocode an address to coordinates.

        Args:
            address: Address string to geocode

        Returns:
            Tuple of (latitude, longitude)

        Raises:
            GeocodingError: If geocoding fails after all retries
        """
        # Check circuit breaker first
        if self.circuit_breaker.state == CircuitState.OPEN:
            if time.time() - self.circuit_breaker.last_failure_time >= self.circuit_breaker.cooldown_period:
                self.circuit_breaker.state = CircuitState.HALF_OPEN
                self.circuit_breaker.success_count = 0
            else:
                raise GeocodingError("Circuit breaker is open")

        last_exception = None
        for attempt in range(self.max_retries):
            try:
                location = self._geocode_address(address)
                if location is None:
                    raise GeocodingError(f"Could not geocode address: {address}")
                # Success - reset circuit breaker
                self._on_success()
                return location.latitude, location.longitude
            except (GeocoderTimedOut, GeocoderServiceError) as e:
                last_exception = e
                if attempt < self.max_retries - 1:
                    # Exponential backoff
                    delay = self.base_delay * (2 ** attempt)
                    time.sleep(delay)

        # All retries exhausted - count as circuit breaker failure
        self._on_failure()
        raise GeocodingError(
            f"Failed after {self.max_retries} attempts: {str(last_exception)}"
        )

    def _on_success(self):
        """Handle successful geocoding."""
        self.circuit_breaker.failure_count = 0
        if self.circuit_breaker.state == CircuitState.HALF_OPEN:
            self.circuit_breaker.success_count += 1
            if self.circuit_breaker.success_count >= self.circuit_breaker.success_threshold:
                self.circuit_breaker.state = CircuitState.CLOSED
                self.circuit_breaker.success_count = 0

    def _on_failure(self):
        """Handle failed geocoding."""
        self.circuit_breaker.failure_count += 1
        self.circuit_breaker.last_failure_time = time.time()
        if self.circuit_breaker.failure_count >= self.circuit_breaker.failure_threshold:
            self.circuit_breaker.state = CircuitState.OPEN

    def _geocode_address(self, address: str):
        """Internal method to geocode address."""
        return self.geocoder.geocode(address)
