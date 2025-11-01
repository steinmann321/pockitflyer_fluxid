from rest_framework import serializers

from flyers.models import Flyer, FlyerImage
from users.models import User


class CreatorSerializer(serializers.ModelSerializer):
    profile_picture = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'profile_picture']

    def get_profile_picture(self, obj):
        if obj.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            return obj.profile_picture.url
        return None


class FlyerImageSerializer(serializers.ModelSerializer):
    url = serializers.SerializerMethodField()

    class Meta:
        model = FlyerImage
        fields = ['url', 'order']

    def get_url(self, obj):
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.image.url)
        return obj.image.url


class FlyerFeedSerializer(serializers.ModelSerializer):
    creator = CreatorSerializer(read_only=True)
    images = FlyerImageSerializer(many=True, read_only=True)
    location = serializers.SerializerMethodField()
    validity = serializers.SerializerMethodField()

    class Meta:
        model = Flyer
        fields = ['id', 'title', 'description', 'creator', 'images', 'location', 'validity']

    def get_location(self, obj):
        # Get user location from context
        user_lat = self.context.get('user_lat')
        user_lng = self.context.get('user_lng')

        # Calculate distance using Haversine formula
        distance_km = None
        if user_lat is not None and user_lng is not None:
            from math import radians, sin, cos, sqrt, atan2

            R = 6371  # Earth's radius in km

            lat1_rad = radians(float(user_lat))
            lat2_rad = radians(float(obj.latitude))
            delta_lat = radians(float(obj.latitude) - float(user_lat))
            delta_lon = radians(float(obj.longitude) - float(user_lng))

            a = sin(delta_lat / 2) ** 2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon / 2) ** 2
            c = 2 * atan2(sqrt(a), sqrt(1 - a))

            distance_km = round(R * c, 2)

        return {
            'address': obj.location_address,
            'lat': float(obj.latitude),
            'lng': float(obj.longitude),
            'distance_km': distance_km
        }

    def get_validity(self, obj):
        return {
            'valid_from': obj.valid_from,
            'valid_until': obj.valid_until,
            'is_valid': obj.is_valid
        }
