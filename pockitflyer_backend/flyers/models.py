from django.core.exceptions import ValidationError
from django.core.validators import MaxLengthValidator, MaxValueValidator, MinValueValidator
from django.db import models
from django.utils import timezone

from users.models import User


class Flyer(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField(validators=[MaxLengthValidator(2000)])
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='flyers')

    location_address = models.CharField(max_length=500)
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        validators=[MinValueValidator(-90), MaxValueValidator(90)]
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        validators=[MinValueValidator(-180), MaxValueValidator(180)]
    )

    valid_from = models.DateTimeField()
    valid_until = models.DateTimeField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['creator']),
            models.Index(fields=['latitude', 'longitude']),
            models.Index(fields=['valid_from', 'valid_until']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return self.title

    @property
    def is_valid(self):
        """Check if flyer is currently valid based on validity period"""
        now = timezone.now()
        return self.valid_from <= now < self.valid_until

    def clean(self):
        """Validate that flyer has between 1 and 5 images"""
        super().clean()

        # Only validate image count if this is an existing flyer (has been saved)
        if self.pk:
            image_count = self.images.count()
            if image_count < 1:
                raise ValidationError("A flyer must have at least one image.")
            if image_count > 5:
                raise ValidationError("A flyer can have a maximum of 5 images.")


class FlyerImage(models.Model):
    flyer = models.ForeignKey(Flyer, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='flyer_images/')
    order = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.flyer.title} - Image {self.order}"
