---
id: m04-e02-t03
title: Image and Geocoding Integration for Updates
epic: m04-e02
milestone: m04
status: pending
---

# Task: Image and Geocoding Integration for Updates

## Context
Part of Flyer Editing (m04-e02) in Milestone 4 (Creator Profile & Content Management).

This task integrates image upload/replacement and address geocoding into the flyer update workflow. When users edit a flyer's images, the system must handle uploading new images, deleting removed images, and maintaining storage integrity. When users change the address, the backend must geocode the new address to update latitude/longitude coordinates. This builds on the base update endpoint from m04-e02-t02 and reuses geocoding infrastructure from m03 (flyer creation).

## Implementation Guide for LLM Agent

### Objective
Extend the flyer update endpoint to handle image upload/deletion and address geocoding with proper error handling and storage management.

### Steps

1. Review existing image upload logic from m03
   - Location: Find image upload implementation from flyer creation (m03)
   - Understand existing image storage mechanism (local filesystem, S3, etc.)
   - Identify image validation logic (file size, format, count)
   - Locate image deletion/cleanup utilities (if any)
   - Review existing patterns for handling multiple images per flyer

2. Review existing geocoding service from m03
   - Location: Find geocoding implementation from flyer creation (m03)
   - Understand geocoding API integration (geopy, Google Maps, etc.)
   - Identify error handling patterns (API failures, invalid addresses)
   - Locate circuit breaker or retry logic (as per architecture resilience requirements)
   - Review how coordinates are validated and stored

3. Extend Flyer model for image management (if needed)
   - Location: `pockitflyer_backend/pokitflyer_api/models.py`
   - If images stored as related model (e.g., `FlyerImage`):
     - Ensure ForeignKey relationship to Flyer
     - Include `image` field (ImageField or FileField)
     - Include `order` field for image ordering
     - Add `delete()` override to clean up file on deletion
   - If images stored as JSONField with URLs:
     - Define schema for image list
     - Include image URL and metadata (size, format, upload date)
   - Add image validation to model:
     ```python
     def clean(self):
         super().clean()
         # Validate image count (1-5)
         if self.images.count() < 1:
             raise ValidationError("At least 1 image required")
         if self.images.count() > 5:
             raise ValidationError("Maximum 5 images allowed")
     ```

4. Create image upload handler for updates
   - Location: `pockitflyer_backend/pokitflyer_api/services/image_service.py` (create if doesn't exist)
   - Create `handle_image_updates(flyer, new_images, removed_image_ids)`:
     ```python
     def handle_image_updates(flyer, new_images=None, removed_image_ids=None):
         """
         Handles image additions and deletions for flyer updates.

         Args:
             flyer: Flyer instance being updated
             new_images: List of uploaded image files (from request.FILES)
             removed_image_ids: List of image IDs to delete

         Returns:
             Updated flyer instance

         Raises:
             ValidationError: If image count validation fails
         """
         # Delete removed images
         if removed_image_ids:
             for img_id in removed_image_ids:
                 try:
                     image = flyer.images.get(id=img_id)
                     # Delete file from storage
                     image.image.delete(save=False)
                     # Delete database record
                     image.delete()
                 except FlyerImage.DoesNotExist:
                     pass  # Already deleted or invalid ID

         # Add new images
         if new_images:
             current_count = flyer.images.count()
             if current_count + len(new_images) > 5:
                 raise ValidationError(f"Cannot add {len(new_images)} images. Maximum is 5, currently have {current_count}")

             for idx, img_file in enumerate(new_images):
                 # Validate image (size, format)
                 validate_image_file(img_file)
                 # Create image record
                 FlyerImage.objects.create(
                     flyer=flyer,
                     image=img_file,
                     order=current_count + idx
                 )

         # Validate final image count
         final_count = flyer.images.count()
         if final_count < 1:
             raise ValidationError("At least 1 image required")

         return flyer
     ```
   - Create `validate_image_file(image_file)`:
     ```python
     def validate_image_file(image_file):
         """Validates image file size and format."""
         # Check file size (e.g., max 5MB)
         max_size = 5 * 1024 * 1024  # 5MB
         if image_file.size > max_size:
             raise ValidationError(f"Image size exceeds {max_size / 1024 / 1024}MB limit")

         # Check file format (JPEG, PNG)
         allowed_formats = ['image/jpeg', 'image/png']
         if image_file.content_type not in allowed_formats:
             raise ValidationError(f"Invalid image format. Allowed: JPEG, PNG")
     ```

5. Create geocoding handler for address updates
   - Location: `pockitflyer_backend/pokitflyer_api/services/geocoding_service.py` (reuse from m03 or create)
   - If not exists, create `geocode_address(address)`:
     ```python
     from geopy.geocoders import Nominatim
     from geopy.exc import GeocoderTimedOut, GeocoderServiceError

     def geocode_address(address):
         """
         Geocodes an address to latitude/longitude coordinates.

         Args:
             address: Address string to geocode

         Returns:
             tuple: (latitude, longitude) or (None, None) if geocoding fails

         Raises:
             ValidationError: If address is invalid or geocoding fails critically
         """
         geolocator = Nominatim(user_agent="pockitflyer_app")

         try:
             location = geolocator.geocode(address, timeout=10)
             if location:
                 return (location.latitude, location.longitude)
             else:
                 raise ValidationError(f"Could not geocode address: {address}")
         except GeocoderTimedOut:
             # Retry once
             try:
                 location = geolocator.geocode(address, timeout=10)
                 if location:
                     return (location.latitude, location.longitude)
                 else:
                     raise ValidationError(f"Could not geocode address: {address}")
             except Exception as e:
                 raise ValidationError(f"Geocoding service unavailable: {str(e)}")
         except GeocoderServiceError as e:
             raise ValidationError(f"Geocoding service error: {str(e)}")
     ```
   - Add circuit breaker pattern (if required by architecture):
     - Use `django-circuit-breaker` or implement custom circuit breaker
     - Wrap geocoding call with circuit breaker to prevent cascading failures
     - Fall back gracefully if geocoding service is down

6. Extend FlyerUpdateView to handle images and geocoding
   - Location: `pockitflyer_backend/pokitflyer_api/views.py`
   - Modify `FlyerUpdateView.perform_update()`:
     ```python
     def perform_update(self, serializer):
         # Verify ownership
         if serializer.instance.owner != self.request.user:
             raise PermissionDenied("You can only edit your own flyers")

         # Extract image data from request
         new_images = self.request.FILES.getlist('images')  # List of new image files
         removed_image_ids = self.request.data.get('removed_image_ids', [])  # List of image IDs to delete

         # Handle address change and geocoding
         address_changed = 'address' in serializer.validated_data
         if address_changed:
             new_address = serializer.validated_data['address']
             try:
                 latitude, longitude = geocode_address(new_address)
                 # Update coordinates in serializer data
                 serializer.validated_data['latitude'] = latitude
                 serializer.validated_data['longitude'] = longitude
             except ValidationError as e:
                 # Geocoding failed - decide whether to block save or proceed without coordinates
                 # Per epic notes: "Handle geocoding failures gracefully (don't block save)"
                 # Log error but don't update coordinates
                 logger.warning(f"Geocoding failed for address '{new_address}': {e}")
                 # Optionally: keep old coordinates, or set to None, or raise error

         # Save text field updates
         instance = serializer.save()

         # Handle image updates
         try:
             handle_image_updates(instance, new_images, removed_image_ids)
         except ValidationError as e:
             # Rollback text changes if image update fails
             raise serializers.ValidationError({"images": str(e)})

         # Validate final state
         instance.full_clean()
     ```
   - Handle transaction rollback on partial failures:
     - Wrap in `transaction.atomic()` block
     - If image handling fails, rollback text changes
     - If geocoding fails, decide on fallback behavior (log warning vs. raise error)

7. Update FlyerUpdateSerializer to handle images
   - Location: `pockitflyer_backend/pokitflyer_api/serializers.py`
   - Add image fields to serializer (if using nested serializer):
     ```python
     images = FlyerImageSerializer(many=True, read_only=True)
     ```
   - OR handle images separately in view (not via serializer) if using multipart/form-data
   - Document expected request format:
     ```
     PATCH /api/flyers/{id}/
     Content-Type: multipart/form-data

     {
       "title": "Updated title",
       "description": "Updated description",
       "address": "123 New St, City, Country",
       "images": [<file1>, <file2>],  // New images to add
       "removed_image_ids": [1, 3]    // IDs of images to delete
     }
     ```

8. Add image cleanup on flyer deletion (if not already exists)
   - Location: `pockitflyer_backend/pokitflyer_api/models.py`
   - Override `Flyer.delete()` or use Django signals:
     ```python
     def delete(self, *args, **kwargs):
         # Delete all associated images
         for image in self.images.all():
             image.image.delete(save=False)
             image.delete()
         super().delete(*args, **kwargs)
     ```
   - OR use `post_delete` signal for `FlyerImage` model

9. Create comprehensive test suite
   - Location: `pockitflyer_backend/tests/test_flyer_update_images_geocoding.py`
   - Mark all tests with `@pytest.mark.tdd_red` initially
   - **Image Upload Tests**:
     - Test: add 1 new image to flyer with 4 images → 200 OK, 5 images total [mark `tdd_green` after verification]
     - Test: add 2 new images to flyer with 3 images → 200 OK, 5 images total [mark `tdd_green` after verification]
     - Test: add 1 image when already at 5 → 400 Bad Request, error: "max 5 images" [mark `tdd_green` after verification]
     - Test: add invalid image format (PDF) → 400 Bad Request, error: "invalid format" [mark `tdd_green` after verification]
     - Test: add oversized image (>5MB) → 400 Bad Request, error: "file too large" [mark `tdd_green` after verification]
   - **Image Deletion Tests**:
     - Test: remove 1 image from flyer with 5 images → 200 OK, 4 images remain [mark `tdd_green` after verification]
     - Test: remove 4 images from flyer with 5 images → 200 OK, 1 image remains [mark `tdd_green` after verification]
     - Test: remove last image → 400 Bad Request, error: "at least 1 image required" [mark `tdd_green` after verification]
     - Test: remove non-existent image ID → 200 OK, no error (graceful handling) [mark `tdd_green` after verification]
     - Test: removed images deleted from storage → verify file no longer exists [mark `tdd_green` after verification]
   - **Image Replacement Tests**:
     - Test: remove 2 images and add 2 new images → 200 OK, correct count maintained [mark `tdd_green` after verification]
     - Test: remove 3 images and add 1 new image → 200 OK, net decrease in image count [mark `tdd_green` after verification]
     - Test: remove all images and add 1 new image → 200 OK, 1 image exists [mark `tdd_green` after verification]
   - **Geocoding Tests**:
     - Test: update address with valid address → 200 OK, lat/lng updated [mark `tdd_green` after verification]
     - Test: update address with invalid address → 400 Bad Request OR 200 OK with old coordinates (per implementation) [mark `tdd_green` after verification]
     - Test: geocoding service timeout → 200 OK, old coordinates retained (graceful degradation) [mark `tdd_green` after verification]
     - Test: geocoding service error → 200 OK, old coordinates retained (graceful degradation) [mark `tdd_green` after verification]
     - Test: address unchanged → 200 OK, coordinates unchanged (no geocoding call) [mark `tdd_green` after verification]
   - **Integration Tests**:
     - Test: full update with text + images + address → 200 OK, all changes applied [mark `tdd_green` after verification]
     - Test: update fails after images uploaded → rollback transaction, no orphaned images [mark `tdd_green` after verification]
     - Test: partial image upload failure → rollback all image changes [mark `tdd_green` after verification]
     - Test: concurrent image updates → handle gracefully (last-write-wins or conflict detection) [mark `tdd_green` after verification]
   - **Storage Integrity Tests**:
     - Test: deleted flyer removes all images from storage [mark `tdd_green` after verification]
     - Test: failed update doesn't leave orphaned images in storage [mark `tdd_green` after verification]

10. Run tests and mark with TDD markers
    - Run: `pytest pockitflyer_backend/tests/test_flyer_update_images_geocoding.py -v`
    - For each test:
      - If passing: change marker from `@pytest.mark.tdd_red` to `@pytest.mark.tdd_green`
      - If failing: keep `@pytest.mark.tdd_red`, fix implementation, re-run, then mark `tdd_green`
    - **CRITICAL**: NEVER mark a test `tdd_green` without verifying it actually passes
    - Ensure >90% coverage for image and geocoding services

### Acceptance Criteria
- [ ] New images can be added to flyers (up to 5 total) [Test: add images, verify count and storage]
- [ ] Images can be removed from flyers (minimum 1 remains) [Test: remove images, verify count and file deletion]
- [ ] Image count validation enforced (1-5 images) [Test: 0 images → error, 6 images → error]
- [ ] Image file validation enforced (size, format) [Test: oversized image → error, PDF → error]
- [ ] Removed images deleted from storage [Test: verify file no longer exists after removal]
- [ ] Address changes trigger geocoding [Test: update address → lat/lng updated]
- [ ] Invalid addresses handled gracefully [Test: bad address → error or old coordinates retained]
- [ ] Geocoding failures don't block save [Test: service timeout → save succeeds with old coordinates]
- [ ] Geocoding not called when address unchanged [Test: no geocoding API call if address same]
- [ ] Transaction rollback on partial failure [Test: image validation fails → text changes reverted]
- [ ] No orphaned images in storage [Test: failed updates don't leave files]
- [ ] All tests pass with `tdd_green` markers [Test: `pytest -m tdd_green` shows all passing]
- [ ] Test coverage >90% for image/geocoding services [Test: `pytest --cov` report]

### Files to Create/Modify
- `pockitflyer_backend/pokitflyer_api/models.py` - MODIFY: Add image cleanup on delete, image count validation
- `pockitflyer_backend/pokitflyer_api/services/image_service.py` - NEW: Image upload/deletion handler
- `pockitflyer_backend/pokitflyer_api/services/geocoding_service.py` - NEW/REUSE: Geocoding service (reuse from m03)
- `pockitflyer_backend/pokitflyer_api/views.py` - MODIFY: Extend FlyerUpdateView with image/geocoding logic
- `pockitflyer_backend/pokitflyer_api/serializers.py` - MODIFY: Add image fields to FlyerUpdateSerializer (if needed)
- `pockitflyer_backend/tests/test_flyer_update_images_geocoding.py` - NEW: Comprehensive test suite
- `pockitflyer_backend/requirements.txt` - MODIFY: Ensure `geopy` included (if not already)

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Image validation: file size, format, count
  - Geocoding service: valid address, invalid address, timeout, service error
  - Circuit breaker behavior (if implemented)
  - Edge cases: 0 images, 1 image, 5 images, 6 images
- **Integration tests**:
  - Full update workflow with images and address
  - Transaction rollback on failures
  - Storage cleanup on deletion
  - Concurrent update handling
  - Mock geocoding service for deterministic testing

**Testing pyramid balance**: 30% unit (validation logic), 70% integration (file handling, storage, geocoding)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] All tests marked `tdd_green` (verified passing)
- [ ] Code follows Django/DRF conventions
- [ ] No console errors or warnings
- [ ] Image storage managed correctly (no orphaned files)
- [ ] Geocoding integrated with graceful error handling
- [ ] Transaction handling ensures data integrity
- [ ] Changes committed with reference to m04-e02-t03
- [ ] Epic m04-e02 complete and ready for user testing

## Dependencies
- Requires: m04-e02-t02 (base update endpoint)
- Requires: m03 (existing image upload and geocoding logic to reuse)
- Requires: m02 (authentication for secure file uploads)

## Technical Notes

**Django/DRF File Handling**:
- Use `request.FILES` to access uploaded files
- Use `request.FILES.getlist('images')` for multiple files
- Store files using Django's `FileField` or `ImageField`
- Configure `MEDIA_ROOT` and `MEDIA_URL` in settings

**Image Storage**:
- Default: Django stores files in `MEDIA_ROOT` directory
- Production: Consider using S3 or CDN for scalability
- File naming: Django auto-generates unique filenames to avoid conflicts
- Cleanup: Manually delete files when records deleted (Django doesn't auto-delete)

**Geocoding Resilience**:
- Use circuit breaker to prevent repeated failures
- Implement retry with exponential backoff for transient errors
- Provide fallback behavior (keep old coordinates, log error)
- Don't block save on geocoding failure (per epic notes)

**Transaction Management**:
- Use `transaction.atomic()` to wrap update operations
- Rollback text changes if image update fails
- Ensure database consistency on partial failures

**Testing with Files**:
- Use Django's `SimpleUploadedFile` for test image files
- Mock geocoding API calls to avoid external dependencies
- Clean up test files after each test
- Use temporary storage for test files

**Multipart Form Data**:
- Content-Type must be `multipart/form-data` for file uploads
- DRF automatically parses multipart data
- Access files via `request.FILES`, other data via `request.data`

**Error Handling**:
- Image validation errors: return 400 with specific error message
- Geocoding errors: log warning, don't block save (or return error based on requirements)
- Storage errors: rollback transaction, return 500 with generic error
- File size errors: return 413 Payload Too Large (or 400)

**Security Considerations**:
- Validate file content, not just extension (prevent malicious uploads)
- Limit file sizes to prevent DoS attacks
- Store files outside web root to prevent direct execution
- Use authenticated requests for all image operations

**Performance Optimization**:
- Geocode only when address changes (check `if 'address' in validated_data`)
- Batch image deletions if removing multiple images
- Use async geocoding for non-blocking operations (optional enhancement)

## References
- Django File Uploads: https://docs.djangoproject.com/en/stable/topics/http/file-uploads/
- DRF File Upload Fields: https://www.django-rest-framework.org/api-guide/fields/#filefield
- geopy Documentation: https://geopy.readthedocs.io/
- Django Transactions: https://docs.djangoproject.com/en/stable/topics/db/transactions/
- Project's existing geocoding service (m03)
- Project's existing image upload logic (m03)
