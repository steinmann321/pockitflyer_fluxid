---
id: m02-e02-t05
title: Backend Image Upload and Storage
epic: m02-e02
milestone: m02
status: pending
---

# Task: Backend Image Upload and Storage

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements secure image upload handling, validation, storage, and association with flyers. Supports 1-5 images per flyer with file type validation, size limits, secure storage paths, and optional image optimization for performance. Extends the flyer creation endpoint (t04) to handle multipart form data with images.

## Implementation Guide for LLM Agent

### Objective
Create image upload handling in flyer creation endpoint with validation (type, size), secure storage, FlyerImage model association, and optional optimization.

### Steps

1. Configure Django media settings
   - File: `pockitflyer_backend/pockitflyer_backend/settings.py`
   ```python
   # Media files configuration
   MEDIA_URL = '/media/'
   MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

   # Image upload settings
   MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5MB per image
   ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp']
   ```

2. Add Pillow dependency
   - File: `pockitflyer_backend/requirements.txt`
   - Add: `Pillow>=10.0.0`
   - Run: `pip install Pillow`

3. Create image validation utility
   - File: `pockitflyer_backend/flyers/validators.py` (NEW)
   ```python
   from django.core.exceptions import ValidationError
   from django.conf import settings
   from PIL import Image
   import mimetypes

   def validate_image_file(file):
       """Validate image file type and size"""
       # Check file size
       if file.size > settings.MAX_UPLOAD_SIZE:
           raise ValidationError(
               f"Image size exceeds maximum allowed size of {settings.MAX_UPLOAD_SIZE / (1024*1024)}MB"
           )

       # Check file type via MIME
       mime_type = mimetypes.guess_type(file.name)[0]
       if mime_type not in settings.ALLOWED_IMAGE_TYPES:
           raise ValidationError(
               f"Unsupported file type. Allowed types: JPEG, PNG, WebP"
           )

       # Validate it's actually an image (opens with Pillow)
       try:
           img = Image.open(file)
           img.verify()
       except Exception:
           raise ValidationError("Invalid image file")

       return file
   ```

4. Create FlyerImage serializer
   - File: `pockitflyer_backend/flyers/serializers.py` (MODIFY)
   ```python
   class FlyerImageSerializer(serializers.ModelSerializer):
       class Meta:
           model = FlyerImage
           fields = ['id', 'image', 'order', 'uploaded_at']
           read_only_fields = ['id', 'uploaded_at']

       def validate_image(self, value):
           validate_image_file(value)
           return value
   ```

5. Update FlyerSerializer to handle image uploads
   - File: `pockitflyer_backend/flyers/serializers.py` (MODIFY)
   ```python
   class FlyerSerializer(serializers.ModelSerializer):
       images = FlyerImageSerializer(many=True, read_only=True)
       uploaded_images = serializers.ListField(
           child=serializers.ImageField(),
           write_only=True,
           required=False,
           max_length=5  # Max 5 images
       )

       class Meta:
           model = Flyer
           fields = [
               'id', 'creator', 'title', 'info_field_1', 'info_field_2',
               'address', 'latitude', 'longitude', 'categories',
               'publication_date', 'expiration_date', 'images', 'uploaded_images',
               'created_at', 'updated_at'
           ]
           read_only_fields = ['id', 'creator', 'latitude', 'longitude', 'created_at', 'updated_at']

       def validate_uploaded_images(self, value):
           if not value or len(value) == 0:
               raise serializers.ValidationError("At least 1 image is required")
           if len(value) > 5:
               raise serializers.ValidationError("Maximum 5 images allowed")
           return value

       def create(self, validated_data):
           uploaded_images = validated_data.pop('uploaded_images', [])
           flyer = super().create(validated_data)

           # Create FlyerImage instances
           for idx, image_file in enumerate(uploaded_images):
               FlyerImage.objects.create(
                   flyer=flyer,
                   image=image_file,
                   order=idx
               )

           return flyer
   ```

6. Update FlyerViewSet to handle multipart data
   - File: `pockitflyer_backend/flyers/views.py` (MODIFY)
   ```python
   from rest_framework.parsers import MultiPartParser, FormParser, JSONParser

   class FlyerViewSet(viewsets.ModelViewSet):
       queryset = Flyer.objects.all()
       serializer_class = FlyerSerializer
       permission_classes = [IsAuthenticatedOrReadOnly]
       parser_classes = [MultiPartParser, FormParser, JSONParser]

       def create(self, request, *args, **kwargs):
           # Extract images from request.FILES
           images = request.FILES.getlist('images')  # Frontend sends as 'images'

           # Add to request.data
           data = request.data.copy()
           data['uploaded_images'] = images

           serializer = self.get_serializer(data=data)
           serializer.is_valid(raise_exception=True)
           self.perform_create(serializer)

           headers = self.get_success_headers(serializer.data)
           return Response(
               serializer.data,
               status=status.HTTP_201_CREATED,
               headers=headers
           )
   ```

7. Create media URL serving for development
   - File: `pockitflyer_backend/pockitflyer_backend/urls.py` (MODIFY)
   ```python
   from django.conf import settings
   from django.conf.urls.static import static

   urlpatterns = [
       # ... existing patterns
   ]

   # Serve media files in development
   if settings.DEBUG:
       urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
   ```

8. Implement optional image optimization
   - File: `pockitflyer_backend/flyers/utils.py` (NEW)
   ```python
   from PIL import Image
   from io import BytesIO
   from django.core.files.uploadedfile import InMemoryUploadedFile
   import sys

   def optimize_image(image_file, max_width=1200, quality=85):
       """Resize and compress image for storage optimization"""
       img = Image.open(image_file)

       # Convert RGBA to RGB if needed
       if img.mode in ('RGBA', 'LA', 'P'):
           background = Image.new('RGB', img.size, (255, 255, 255))
           background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
           img = background

       # Resize if too large
       if img.width > max_width:
           ratio = max_width / img.width
           new_height = int(img.height * ratio)
           img = img.resize((max_width, new_height), Image.Resampling.LANCZOS)

       # Save to BytesIO
       output = BytesIO()
       img.save(output, format='JPEG', quality=quality, optimize=True)
       output.seek(0)

       # Create new InMemoryUploadedFile
       return InMemoryUploadedFile(
           output,
           'ImageField',
           f"{image_file.name.split('.')[0]}.jpg",
           'image/jpeg',
           sys.getsizeof(output),
           None
       )
   ```

9. Integrate optimization in FlyerImage creation (optional)
   - Modify serializer create method to optimize before saving
   ```python
   def create(self, validated_data):
       uploaded_images = validated_data.pop('uploaded_images', [])
       flyer = super().create(validated_data)

       for idx, image_file in enumerate(uploaded_images):
           # Optimize image
           optimized_image = optimize_image(image_file)

           FlyerImage.objects.create(
               flyer=flyer,
               image=optimized_image,
               order=idx
           )

       return flyer
   ```

10. Create image upload tests
    - File: `pockitflyer_backend/flyers/tests/test_image_upload.py` (NEW)
    - Test: Upload single image with valid flyer data returns 201
    - Test: Upload 5 images successfully
    - Test: Upload 0 images returns 400 (at least 1 required)
    - Test: Upload 6 images returns 400 (max 5)
    - Test: Upload >5MB image returns 400
    - Test: Upload unsupported file type (GIF) returns 400
    - Test: Upload invalid image file (corrupted) returns 400
    - Test: Images associated with correct flyer
    - Test: Images ordered correctly (order field)
    - Test: Image URLs accessible via serializer
    - Test: Image files stored in MEDIA_ROOT/flyer_images/
    - Test: Concurrent uploads don't collide (unique filenames)

11. Create image validation tests
    - File: `pockitflyer_backend/flyers/tests/test_validators.py` (NEW)
    - Test: validate_image_file accepts JPEG
    - Test: validate_image_file accepts PNG
    - Test: validate_image_file accepts WebP
    - Test: validate_image_file rejects GIF
    - Test: validate_image_file rejects >5MB file
    - Test: validate_image_file rejects non-image file
    - Test: validate_image_file rejects corrupted image

### Acceptance Criteria
- [ ] Endpoint accepts multipart form data with images [Test: POST with images, verify 201]
- [ ] At least 1 image required [Test: POST without images, verify 400]
- [ ] Maximum 5 images enforced [Test: POST with 6 images, verify 400]
- [ ] JPEG files accepted [Test: upload JPEG, verify 201]
- [ ] PNG files accepted [Test: upload PNG, verify 201]
- [ ] WebP files accepted [Test: upload WebP, verify 201]
- [ ] GIF files rejected [Test: upload GIF, verify 400]
- [ ] Files >5MB rejected [Test: upload 6MB file, verify 400]
- [ ] Corrupted images rejected [Test: upload invalid file, verify 400]
- [ ] Images stored securely in media directory [Test: verify file path]
- [ ] Images associated with correct flyer [Test: query flyer, verify images present]
- [ ] Image order preserved [Test: upload 3 images, verify order 0,1,2]
- [ ] Image URLs returned in API response [Test: verify image URLs in response]
- [ ] Concurrent uploads don't overwrite [Test: upload same filename twice, verify unique paths]
- [ ] Unit tests pass with ≥90% coverage
- [ ] Integration tests pass

### Files to Create/Modify
- `pockitflyer_backend/pockitflyer_backend/settings.py` - MODIFY: add MEDIA_URL, MEDIA_ROOT, upload settings
- `pockitflyer_backend/requirements.txt` - MODIFY: add Pillow
- `pockitflyer_backend/flyers/validators.py` - NEW: image validation functions
- `pockitflyer_backend/flyers/utils.py` - NEW: image optimization utilities
- `pockitflyer_backend/flyers/serializers.py` - MODIFY: add image upload handling
- `pockitflyer_backend/flyers/views.py` - MODIFY: handle multipart data
- `pockitflyer_backend/pockitflyer_backend/urls.py` - MODIFY: serve media files in development
- `pockitflyer_backend/flyers/tests/test_image_upload.py` - NEW: image upload tests
- `pockitflyer_backend/flyers/tests/test_validators.py` - NEW: validation tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**:
  - Image validation (file type, size, corruption)
  - Image optimization (resize, compression)
  - Serializer validation (count limits)

- **Integration tests** (with test database and temp files):
  - Complete upload flow (POST with images → storage → database)
  - Multiple images per flyer
  - Image-flyer association
  - File storage and URL generation
  - Multipart data parsing

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Django and project conventions
- [ ] All tests marked with appropriate TDD markers
- [ ] Media directory created and configured
- [ ] Image optimization tested (if implemented)
- [ ] Changes committed with `m02-e02-t05` reference
- [ ] Ready for frontend integration (t02 uploads images)

## Dependencies
- Requires: m02-e02-t04 (Flyer model and creation endpoint)
- Requires: m02-e02-t02 (frontend sends image files)
- Blocks: Complete flyer creation flow

## Technical Notes

**Storage Strategy**:
- Development: local filesystem via MEDIA_ROOT
- Production: consider cloud storage (AWS S3, GCS) for scalability
- Use Django's `upload_to` parameter for organized storage paths
- Default: `flyer_images/YYYY/MM/DD/filename.jpg`

**File Naming**:
- Django automatically handles unique filenames (appends hash if collision)
- Example: `image.jpg` → `image_a1b2c3d4.jpg`
- Preserve original extension for client compatibility

**Image Optimization Benefits**:
- Reduces storage costs
- Faster image delivery to clients
- Better mobile performance
- Recommended max width: 1200px (retina-ready)
- Recommended quality: 85 (good balance)

**Multipart Data Handling**:
- Use `MultiPartParser` for file uploads
- Frontend sends: `Content-Type: multipart/form-data`
- Backend receives: `request.FILES` (images) + `request.POST` (metadata)
- Use `getlist()` for multiple files with same field name

**Security Considerations**:
- Validate file type (MIME + Pillow verification)
- Validate file size (prevent DoS via large uploads)
- Store outside web root or with proper access controls
- Don't trust client-provided filenames (use Django's storage)
- Scan for malware in production (optional)

**Performance**:
- Optimize images asynchronously in production (Celery task)
- Generate thumbnails for preview (different sizes)
- Use CDN for image delivery in production
- Consider lazy loading on frontend

**API Request Format**:
```http
POST /api/flyers/
Content-Type: multipart/form-data
Authorization: Bearer <JWT_TOKEN>

--boundary
Content-Disposition: form-data; name="title"
Sample Flyer

--boundary
Content-Disposition: form-data; name="images"; filename="image1.jpg"
Content-Type: image/jpeg

<binary data>

--boundary
Content-Disposition: form-data; name="images"; filename="image2.jpg"
Content-Type: image/jpeg

<binary data>

--boundary
Content-Disposition: form-data; name="categories"
["events", "nightlife"]

--boundary--
```

**API Response Format**:
```json
{
  "id": 1,
  "images": [
    {
      "id": 1,
      "image": "http://localhost:8000/media/flyer_images/2025/01/15/image1_a1b2c3.jpg",
      "order": 0,
      "uploaded_at": "2025-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "image": "http://localhost:8000/media/flyer_images/2025/01/15/image2_d4e5f6.jpg",
      "order": 1,
      "uploaded_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

## References
- Django file uploads: https://docs.djangoproject.com/en/stable/topics/http/file-uploads/
- DRF file upload fields: https://www.django-rest-framework.org/api-guide/fields/#filefield
- Pillow documentation: https://pillow.readthedocs.io/
- Django media files: https://docs.djangoproject.com/en/stable/ref/settings/#media-root
