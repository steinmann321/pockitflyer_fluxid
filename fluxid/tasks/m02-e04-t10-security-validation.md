---
id: m02-e04-t10
epic: m02-e04
title: Security Validation for M02 Authentication and Profile Management
status: pending
priority: high
tdd_phase: red
---

# Task: Security Validation for M02 Authentication and Profile Management

## Objective
Validate that all M02 authentication and profile management features meet security requirements and protect against common vulnerabilities (OWASP Top 10). Tests cover authentication security, authorization, input validation, token security, and data protection using real Django backend and real iOS app with no mocks.

## Acceptance Criteria
- [ ] Security test script: `scripts/validate_m02_security.py`
- [ ] Authentication security validations:
  - Password storage: Passwords hashed using Django's password hashers (PBKDF2, bcrypt, or Argon2)
  - Password never logged or exposed in error messages
  - No password in URL parameters or HTTP headers (only in request body)
  - Password strength enforcement (min 8 chars, uppercase, lowercase, number)
  - No email enumeration vulnerability (same error for wrong password and non-existent email)
  - JWT tokens signed with secret key (HMAC-SHA256)
  - Token expiration enforced (7 days, configurable)
  - Token invalidation on logout (cleared from client storage)
- [ ] Authorization security validations:
  - Profile editing: Only profile owner can edit (enforced by backend)
  - Privacy settings: Only user can modify own settings (enforced by backend)
  - Anonymous users cannot edit profiles (enforced by frontend and backend)
  - API endpoints require authentication where appropriate (profile update, settings update)
  - Token validation on all authenticated endpoints (invalid token → 401 Unauthorized)
- [ ] Input validation security validations:
  - Email input sanitized (no XSS, no SQL injection)
  - Display name input sanitized (no XSS, no HTML injection)
  - Bio input sanitized (no XSS, no script injection)
  - File upload validation (image format, file size, MIME type)
  - File upload sanitization (no executable uploads, no path traversal)
  - All user input validated on both frontend and backend (defense in depth)
- [ ] Token security validations:
  - Token stored in iOS Keychain (not UserDefaults or file system)
  - Token transmitted over HTTPS only (enforced in production)
  - Token signature verified on backend (reject tampered tokens)
  - Token expiration checked on backend (reject expired tokens)
  - Token payload doesn't contain sensitive data (only user_id, email, exp)
  - No token in URL parameters or logs
- [ ] Data protection validations:
  - Passwords never stored in plain text (always hashed)
  - JWT secret key not hardcoded (loaded from environment variable or Django settings)
  - No sensitive data logged (passwords, tokens, personal info redacted)
  - Profile pictures stored securely (file permissions, no directory traversal)
  - Database credentials not exposed in error messages
- [ ] OWASP Top 10 vulnerability checks:
  1. **A01:2021 – Broken Access Control**: Authorization checks on all sensitive endpoints ✅
  2. **A02:2021 – Cryptographic Failures**: Passwords hashed, tokens signed, HTTPS enforced ✅
  3. **A03:2021 – Injection**: SQL injection, XSS, command injection prevented ✅
  4. **A04:2021 – Insecure Design**: Secure authentication design (JWT, password hashing) ✅
  5. **A05:2021 – Security Misconfiguration**: No DEBUG=True in production, secure defaults ✅
  6. **A06:2021 – Vulnerable Components**: Django and dependencies up-to-date ✅
  7. **A07:2021 – Identification and Authentication Failures**: Token expiration, logout, password strength ✅
  8. **A08:2021 – Software and Data Integrity Failures**: JWT signature verification ✅
  9. **A09:2021 – Security Logging and Monitoring Failures**: Authentication failures logged ✅
  10. **A10:2021 – Server-Side Request Forgery (SSRF)**: Not applicable (no user-provided URLs) N/A
- [ ] Penetration testing scenarios:
  - Attempt to edit other user's profile (should fail with 403 Forbidden)
  - Attempt to use expired token (should fail with 401 Unauthorized)
  - Attempt to use tampered token (should fail with 401 Unauthorized)
  - Attempt SQL injection in email field (should be sanitized, no SQL execution)
  - Attempt XSS in display name field (should be sanitized, no script execution)
  - Attempt to upload executable file as profile picture (should fail with validation error)
  - Attempt to enumerate emails (should return same error for valid and invalid emails)
- [ ] Security report generated:
  - All security checks: PASS/FAIL status
  - Vulnerability assessment: Any security issues found?
  - OWASP Top 10 compliance: Which vulnerabilities mitigated?
  - Recommendations: Security improvements for future milestones
- [ ] All security tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Password hashing verification (bcrypt/PBKDF2/Argon2)
- Password strength enforcement (frontend and backend)
- Email enumeration prevention (same error for all login failures)
- JWT token signing and verification
- Token expiration enforcement
- Token storage security (iOS Keychain)
- Authorization enforcement (profile editing, settings updates)
- Input sanitization (email, display name, bio)
- XSS prevention (all user input escaped)
- SQL injection prevention (parameterized queries)
- File upload validation (format, size, MIME type)
- File upload sanitization (no executable uploads)
- HTTPS enforcement (production configuration)
- Secure defaults (Django settings: SECRET_KEY, DEBUG, ALLOWED_HOSTS)

## Files to Modify/Create
- `scripts/validate_m02_security.py` (main security validation script)
- `scripts/security_helpers.py` (helper functions for security tests)
- `pockitflyer_backend/users/tests/test_security.py` (backend security tests)
- `docs/m02_security_report_template.md` (report template)
- `docs/m02_security_report_YYYY-MM-DD.md` (generated report)
- `docs/m02_security_checklist.md` (OWASP Top 10 checklist)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure)
- m02-e04-t02 through t08 (all E2E functional tests must pass first)
- All M02 epics complete (m02-e01, m02-e02, m02-e03)

## Notes
**Critical: SECURITY-FIRST MINDSET**
- Security is not optional (all checks must pass)
- Vulnerabilities must be fixed before production
- Security testing is ongoing (not one-time)
- Threat modeling informs future development

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Security Test Script Structure**:
```python
# scripts/validate_m02_security.py
def validate_m02_security():
    results = []

    # Start backend and seed data
    start_backend()
    seed_test_data()

    # Test password hashing
    results.append(test_password_hashing())

    # Test email enumeration prevention
    results.append(test_email_enumeration())

    # Test JWT token security
    results.append(test_jwt_token_security())

    # Test authorization enforcement
    results.append(test_authorization_enforcement())

    # Test input sanitization
    results.append(test_input_sanitization())

    # Test file upload security
    results.append(test_file_upload_security())

    # Test OWASP Top 10 compliance
    results.append(test_owasp_top_10_compliance())

    # Generate report
    generate_security_report(results)

    return all(r['status'] == 'PASS' for r in results)
```

**Password Hashing Verification**:
```python
# pockitflyer_backend/users/tests/test_security.py
def test_password_hashing():
    user = User.objects.create_user(
        email='test@example.com',
        password='TestPass123!'
    )
    # Verify password is hashed (not plain text)
    assert user.password != 'TestPass123!'
    # Verify password starts with hash algorithm prefix
    assert user.password.startswith('pbkdf2_sha256$') or \
           user.password.startswith('bcrypt$') or \
           user.password.startswith('argon2$')
    # Verify password can be verified
    assert user.check_password('TestPass123!')
    # Verify wrong password fails
    assert not user.check_password('WrongPassword')
```

**Email Enumeration Prevention**:
```python
def test_email_enumeration():
    # Login with valid email, wrong password
    response1 = client.post('/api/auth/login/', {
        'email': 'existing@example.com',
        'password': 'WrongPassword'
    })
    assert response1.status_code == 400
    error1 = response1.json()['error']

    # Login with non-existent email
    response2 = client.post('/api/auth/login/', {
        'email': 'nonexistent@example.com',
        'password': 'AnyPassword'
    })
    assert response2.status_code == 400
    error2 = response2.json()['error']

    # Verify same error message (no email enumeration)
    assert error1 == error2 == 'Invalid email or password'
```

**JWT Token Security Verification**:
```python
def test_jwt_token_security():
    # Generate token for test user
    token = generate_token(user)

    # Verify token is signed correctly
    payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
    assert payload['user_id'] == user.id
    assert payload['email'] == user.email

    # Verify token expiration
    assert 'exp' in payload
    exp_time = datetime.fromtimestamp(payload['exp'])
    assert exp_time > datetime.now()  # Not expired yet

    # Verify tampered token rejected
    tampered_token = token[:-10] + 'TAMPERED12'
    with pytest.raises(jwt.InvalidSignatureError):
        jwt.decode(tampered_token, settings.SECRET_KEY, algorithms=['HS256'])

    # Verify expired token rejected (requires token expiration simulation)
    expired_token = generate_expired_token(user)
    response = client.get('/api/users/profile/', headers={'Authorization': f'Bearer {expired_token}'})
    assert response.status_code == 401
    assert 'expired' in response.json()['error'].lower()
```

**Authorization Enforcement Verification**:
```python
def test_authorization_enforcement():
    # User A tries to edit User B's profile (should fail)
    user_a = User.objects.get(email='test_user_001@pockitflyer.test')
    user_b = User.objects.get(email='test_user_002@pockitflyer.test')
    token_a = generate_token(user_a)

    response = client.patch(
        f'/api/users/{user_b.id}/profile/',
        {'display_name': 'Hacked Name'},
        headers={'Authorization': f'Bearer {token_a}'}
    )
    assert response.status_code == 403  # Forbidden
    assert 'permission' in response.json()['error'].lower()

    # Verify User B's profile not changed
    user_b.profile.refresh_from_db()
    assert user_b.profile.display_name != 'Hacked Name'
```

**Input Sanitization Verification**:
```python
def test_input_sanitization():
    # XSS attempt in display name
    user = authenticate_user('test@example.com', 'TestPass123!')
    response = client.patch('/api/users/profile/', {
        'display_name': '<script>alert("XSS")</script>'
    }, headers={'Authorization': f'Bearer {user.token}'})

    # Verify response sanitized (no script tag in response)
    profile = response.json()
    assert '<script>' not in profile['display_name']
    # Verify database sanitized
    user.profile.refresh_from_db()
    assert '<script>' not in user.profile.display_name

    # SQL injection attempt in email (registration)
    response = client.post('/api/auth/register/', {
        'email': "admin@example.com' OR '1'='1",
        'password': 'TestPass123!',
        'display_name': 'Test User'
    })
    # Verify no SQL injection (parameterized queries prevent injection)
    assert response.status_code == 400  # Validation error (invalid email format)
    # Verify no users created with malicious email
    assert not User.objects.filter(email__contains="' OR '1'='1").exists()
```

**File Upload Security Verification**:
```python
def test_file_upload_security():
    user = authenticate_user('test@example.com', 'TestPass123!')

    # Attempt to upload executable file (should fail)
    with open('/tmp/malicious.exe', 'w') as f:
        f.write('MALICIOUS CONTENT')
    response = client.post('/api/users/profile/picture/', {
        'file': open('/tmp/malicious.exe', 'rb')
    }, headers={'Authorization': f'Bearer {user.token}'})
    assert response.status_code == 400
    assert 'format' in response.json()['error'].lower()

    # Attempt to upload oversized file (should fail)
    # (Create 6MB file, exceeds 5MB limit)
    large_file = create_large_image(6 * 1024 * 1024)  # 6MB
    response = client.post('/api/users/profile/picture/', {
        'file': large_file
    }, headers={'Authorization': f'Bearer {user.token}'})
    assert response.status_code == 400
    assert 'size' in response.json()['error'].lower()

    # Upload valid image (should succeed)
    valid_image = create_valid_image(2 * 1024 * 1024)  # 2MB JPEG
    response = client.post('/api/users/profile/picture/', {
        'file': valid_image
    }, headers={'Authorization': f'Bearer {user.token}'})
    assert response.status_code == 200
    # Verify file stored with safe filename (no path traversal)
    profile_picture_url = response.json()['profile_picture_url']
    assert '../' not in profile_picture_url  # No directory traversal
```

**OWASP Top 10 Compliance Checklist**:
```markdown
# M02 OWASP Top 10 Security Checklist

## A01:2021 – Broken Access Control
- [x] Profile editing requires authentication
- [x] Profile editing restricted to profile owner (backend enforcement)
- [x] Privacy settings restricted to user (backend enforcement)
- [x] Anonymous users cannot access authenticated endpoints (401 Unauthorized)
- [x] Authorization header required for authenticated endpoints

## A02:2021 – Cryptographic Failures
- [x] Passwords hashed using Django password hashers (PBKDF2/bcrypt/Argon2)
- [x] JWT tokens signed with secret key (HMAC-SHA256)
- [x] HTTPS enforced in production (Django settings: SECURE_SSL_REDIRECT=True)
- [x] Token stored in iOS Keychain (encrypted storage)

## A03:2021 – Injection
- [x] SQL injection prevented (Django ORM parameterized queries)
- [x] XSS prevented (user input sanitized, escaped in responses)
- [x] Command injection prevented (no shell commands with user input)
- [x] Email validation prevents malicious input

## A04:2021 – Insecure Design
- [x] JWT-based authentication (secure, stateless)
- [x] Password strength requirements enforced
- [x] Token expiration enforced (7 days)
- [x] Logout clears tokens (client-side invalidation)

## A05:2021 – Security Misconfiguration
- [x] DEBUG=False in production
- [x] SECRET_KEY loaded from environment variable (not hardcoded)
- [x] ALLOWED_HOSTS configured correctly
- [x] CORS configured securely (Django CORS headers)
- [x] File upload size limits enforced (5MB max)

## A06:2021 – Vulnerable and Outdated Components
- [x] Django version up-to-date (latest security patches)
- [x] Dependencies up-to-date (pip freeze | safety check)
- [x] No known vulnerabilities in dependencies

## A07:2021 – Identification and Authentication Failures
- [x] Password strength enforced (min 8 chars, complexity)
- [x] No email enumeration (same error for all login failures)
- [x] Token expiration enforced (7 days)
- [x] Token invalidation on logout
- [x] No passwords in logs or error messages

## A08:2021 – Software and Data Integrity Failures
- [x] JWT signature verified on backend (reject tampered tokens)
- [x] Token payload integrity checked (exp, user_id, email)
- [x] No unsigned or unverified tokens accepted

## A09:2021 – Security Logging and Monitoring Failures
- [x] Authentication failures logged (Django logging)
- [x] Token validation failures logged
- [x] Sensitive data redacted from logs (passwords, tokens)

## A10:2021 – Server-Side Request Forgery (SSRF)
- [ ] Not applicable (no user-provided URLs in M02)
```

**Security Report Format**:
```markdown
# M02 Security Validation Report

**Date**: 2025-01-15
**Validator**: Security Script + Manual Review
**Overall Status**: ✅ ALL SECURITY CHECKS PASSED

## Security Checks

### Authentication Security
- **Password hashing**: ✅ PASS (PBKDF2-SHA256)
- **Password strength**: ✅ PASS (min 8 chars, complexity enforced)
- **Email enumeration**: ✅ PASS (same error for all failures)
- **JWT token signing**: ✅ PASS (HMAC-SHA256)
- **Token expiration**: ✅ PASS (7 days, enforced)
- **Token invalidation**: ✅ PASS (cleared on logout)

### Authorization Security
- **Profile editing**: ✅ PASS (owner-only, backend enforced)
- **Settings updates**: ✅ PASS (user-only, backend enforced)
- **API authentication**: ✅ PASS (401 for invalid/missing tokens)

### Input Validation
- **Email sanitization**: ✅ PASS (no XSS, no SQL injection)
- **Display name sanitization**: ✅ PASS (XSS prevented)
- **Bio sanitization**: ✅ PASS (XSS prevented)
- **File upload validation**: ✅ PASS (format, size, MIME type checked)

### Token Security
- **Token storage**: ✅ PASS (iOS Keychain, encrypted)
- **Token transmission**: ✅ PASS (HTTPS enforced in production)
- **Token signature verification**: ✅ PASS (tampered tokens rejected)
- **Token expiration checking**: ✅ PASS (expired tokens rejected)

### OWASP Top 10 Compliance
- A01 – Broken Access Control: ✅ MITIGATED
- A02 – Cryptographic Failures: ✅ MITIGATED
- A03 – Injection: ✅ MITIGATED
- A04 – Insecure Design: ✅ MITIGATED
- A05 – Security Misconfiguration: ✅ MITIGATED
- A06 – Vulnerable Components: ✅ MITIGATED
- A07 – Authentication Failures: ✅ MITIGATED
- A08 – Data Integrity Failures: ✅ MITIGATED
- A09 – Logging Failures: ✅ MITIGATED
- A10 – SSRF: N/A (not applicable)

## Penetration Testing Results
- ✅ Cannot edit other user's profile (403 Forbidden)
- ✅ Expired token rejected (401 Unauthorized)
- ✅ Tampered token rejected (401 Unauthorized)
- ✅ SQL injection prevented (parameterized queries)
- ✅ XSS prevented (input sanitized, output escaped)
- ✅ Executable upload rejected (format validation)
- ✅ Email enumeration prevented (same error message)

## Recommendations
1. **Immediate**: No blocking security issues
2. **Short-term**: Implement rate limiting on login endpoint (prevent brute force)
3. **Medium-term**: Add server-side token blacklist (more secure logout)
4. **Long-term**: Implement 2FA (two-factor authentication) for enhanced security

## Conclusion
**M02 SECURITY VALIDATED FOR PRODUCTION**
All OWASP Top 10 vulnerabilities mitigated. No critical security issues found.
```

**Success Indicators**:
- All passwords hashed correctly ✅
- No email enumeration vulnerability ✅
- JWT tokens signed and verified ✅
- Token expiration enforced ✅
- Authorization enforced on all endpoints ✅
- Input sanitization prevents XSS and SQL injection ✅
- File upload validation prevents malicious uploads ✅
- OWASP Top 10 compliance verified ✅
- Security report generated with recommendations ✅
