from decimal import Decimal, InvalidOperation

from django.utils import timezone
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response

from flyers.models import Flyer
from flyers.serializers import FlyerFeedSerializer


class FeedPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 50


class FeedViewSet(viewsets.ViewSet):
    """ViewSet for retrieving smart-ranked flyer feed"""
    pagination_class = FeedPagination

    def list(self, request):
        # Get and validate query parameters
        lat_str = request.query_params.get('lat')
        lng_str = request.query_params.get('lng')

        if not lat_str:
            return Response(
                {'error': 'lat parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not lng_str:
            return Response(
                {'error': 'lng parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Convert and validate latitude/longitude
        try:
            user_lat = Decimal(lat_str)
            user_lng = Decimal(lng_str)
        except (InvalidOperation, ValueError):
            return Response(
                {'error': 'Invalid latitude or longitude format'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Validate range
        if user_lat < -90 or user_lat > 90:
            return Response(
                {'error': 'Latitude must be between -90 and 90'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if user_lng < -180 or user_lng > 180:
            return Response(
                {'error': 'Longitude must be between -180 and 180'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get current time for validity filtering
        now = timezone.now()

        # Filter valid flyers (only those within validity period)
        queryset = Flyer.objects.filter(
            valid_from__lte=now,
            valid_until__gt=now
        ).select_related('creator').prefetch_related('images').order_by('-created_at')

        # Calculate distances and prepare for sorting
        flyers_with_distance = []
        for flyer in queryset:
            # Calculate Haversine distance
            from math import radians, sin, cos, sqrt, atan2

            R = 6371  # Earth's radius in km

            lat1_rad = radians(float(user_lat))
            lat2_rad = radians(float(flyer.latitude))
            delta_lat = radians(float(flyer.latitude) - float(user_lat))
            delta_lon = radians(float(flyer.longitude) - float(user_lng))

            a = sin(delta_lat / 2) ** 2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon / 2) ** 2
            c = 2 * atan2(sqrt(a), sqrt(1 - a))

            distance = R * c

            flyers_with_distance.append((flyer, distance))

        # Sort by created_at DESC (newest first), then by distance ASC (closest first)
        # Group by created_at to apply secondary sorting
        from itertools import groupby
        from operator import itemgetter

        # First sort by created_at DESC
        flyers_with_distance.sort(key=lambda x: x[0].created_at, reverse=True)

        # Then apply stable sort by distance within same created_at groups
        # Group by created_at timestamp (truncated to second for practical purposes)
        sorted_flyers = []
        for created_at, group in groupby(flyers_with_distance, key=lambda x: x[0].created_at.replace(microsecond=0)):
            group_list = list(group)
            # Sort this group by distance
            group_list.sort(key=lambda x: x[1])
            sorted_flyers.extend(group_list)

        # Extract just the flyer objects
        ordered_flyers = [f[0] for f in sorted_flyers]

        # Apply pagination
        paginator = self.pagination_class()
        page = paginator.paginate_queryset(ordered_flyers, request)

        # Serialize with context
        serializer = FlyerFeedSerializer(
            page,
            many=True,
            context={
                'request': request,
                'user_lat': user_lat,
                'user_lng': user_lng
            }
        )

        return paginator.get_paginated_response(serializer.data)
