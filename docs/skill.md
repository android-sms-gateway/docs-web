---
name: sms-gate-app
description: Send and receive SMS messages with your own Android device
license: Apache-2.0
---
# Android SMS Gateway - Agent Skill Guide

## Introduction

The Android SMS Gateway is a powerful application that transforms an Android device into a fully-featured SMS gateway server. It provides a RESTful API for sending and receiving SMS messages, supporting both text and binary data messages, with advanced features like multi-SIM support, MMS reception, webhook notifications, and robust authentication.

**Key Capabilities:**
- Send SMS messages programmatically via REST API
- Receive incoming SMS/MMS via webhook notifications
- Support for data SMS (binary payloads)
- Multi-SIM card support with selective SIM routing
- Real-time status tracking and delivery reports
- JWT and Basic Authentication
- Rate limiting and message priority controls
- Message encryption support

This guide provides agents with everything needed to integrate SMS functionality into applications, scripts, or services.

---

## Prerequisites

Before you begin, ensure you have:

### Required
- **SMS Gateway App** installed on an Android device (v1.40.0+ recommended)
- **Server Access** - Either:
  - Public Cloud Server mode (api.sms-gate.app)
  - Private Server mode (self-hosted)
  - Local Server mode (local network only)
- **API Credentials** - Username and password from the app's Home tab
- **Webhook Endpoint** (for receiving messages) - HTTPS server with valid SSL certificate
- **Network Connectivity** - Device must have internet access (for Cloud/Private modes) or be on same network as your server (Local mode)

### Optional
- **JWT Authentication** - Available in Cloud/Private modes only
- **Certificate Authority** - For private IP webhook endpoints
- **Multiple SIM Cards** - For multi-SIM functionality

---

## Authentication

The API supports two authentication methods:

### 1. Basic Authentication (Legacy)

Simple username/password sent with each request.

**Format:**
```
Authorization: Basic <base64-encoded-username:password>
```

**Example (cURL):**
```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"phoneNumbers": ["+1234567890"], "textMessage": {"text": "Hello"}}'
```

**Limitations:**
- Credentials sent with every request
- No fine-grained access control
- Not recommended for new integrations

### 2. JWT Bearer Tokens (Recommended)

Modern token-based authentication with scopes and expiration.

**Available in:** Public Cloud and Private Server modes only (NOT available in Local mode)

#### Token Generation

Make a POST request to the token endpoint using Basic Auth:

**Endpoint:**
```
POST /3rdparty/v1/auth/token
```

**Request:**
```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "ttl": 3600,
    "scopes": ["messages:send", "messages:read"]
  }'
```

**Response:**
```json
{
  "id": "w8pxz0a4Fwa4xgzyCvSeC",
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-11-22T08:45:00Z"
}
```

#### Using JWT Tokens

Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

#### JWT Scopes

Scopes define permissions. Use the principle of least privilege:

| Scope | Description |
|-------|-------------|
| `messages:send` | Send SMS messages |
| `messages:read` | Read individual message details |
| `messages:list` | List and view messages |
| `messages:export` | Export inbox messages |
| `devices:list` | List registered devices |
| `devices:delete` | Remove devices |
| `webhooks:list` | List webhook configurations |
| `webhooks:write` | Create/modify webhooks |
| `webhooks:delete` | Remove webhooks |
| `settings:read` | Read system settings |
| `settings:write` | Modify system settings |
| `logs:read` | Read system logs |
| `tokens:manage` | Generate and revoke tokens |
| `all:any` | Full access (use with caution) |

#### Token Management

**Revoke a token:**
```bash
curl -X DELETE "https://api.sms-gate.app/3rdparty/v1/auth/token/{jti}" \
  -H "Authorization: Bearer <your-token>"
```

**Best Practices:**
- Use short TTLs (1-24 hours typically)
- Request only the scopes you need
- Store tokens securely (never in client-side code)
- Implement token refresh before expiration
- Revoke tokens immediately when no longer needed

---

## Sending SMS Messages

### API Endpoint

```
POST /3rdparty/v1/messages
```

### Request Structure

The API supports two message types - **text messages** and **data messages** (binary). Only one type can be sent per request.

#### Text Message

```json
{
  "textMessage": {
    "text": "Your OTP is 1234"
  },
  "phoneNumbers": ["+1234567890"],
  "deviceId": "optional-device-id",
  "simNumber": 1,
  "ttl": 3600,
  "priority": 100
}
```

#### Data Message (Binary)

```json
{
  "dataMessage": {
    "data": "SGVsbG8gRGF0YSBXb3JsZCE=",
    "port": 53739
  },
  "phoneNumbers": ["+1234567890"],
  "simNumber": 1,
  "ttl": 3600,
  "priority": 100
}
```

### Query Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `skipPhoneValidation` | boolean | Disable E.164 phone number validation | `false` |
| `deviceActiveWithin` | integer | Only target devices active within last N hours (0 = disabled) | `0` |

### Request Parameters

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `textMessage.text` | string | Conditional* | Text content (max 160 chars, auto-split if longer) | - |
| `dataMessage.data` | string | Conditional* | Base64-encoded binary data (max 140 bytes) | - |
| `dataMessage.port` | integer | Conditional* | Destination port (1-65535) | - |
| `phoneNumbers` | array | Yes | Recipient phone numbers (E.164 format) | - |
| `deviceId` | string | No | Target specific device ID | null |
| `simNumber` | integer | No | SIM card slot number (1-3) | See multi-sim settings |
| `ttl` | integer | No | Message TTL in seconds | never |
| `validUntil` | string | No | Absolute expiration (RFC3339) | never |
| `priority` | integer | No | Send priority (-128 to 127) | 0 |
| `isEncrypted` | boolean | No | Message is encrypted | `false` |

*Exactly one of `textMessage`, `dataMessage`, or deprecated `message` field is required.

### Priority Levels

| Level | Range | Description |
|-------|-------|-------------|
| High | 100-127 | Bypasses rate limits, processed first |
| Normal | 0-99 | Standard processing (default) |
| Low | -128 to -1 | Lower priority, queued after normal |

### Response

**Success (202 Accepted):**
```json
{
  "id": "abc123def456",
  "status": "queued",
  "createdAt": "2025-06-22T10:30:00Z"
}
```

**Error (4xx/5xx):**
```json
{
  "error": "ValidationError",
  "message": "Invalid phone number format",
  "details": {}
}
```

### Code Examples

#### cURL - Text Message
```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages?skipPhoneValidation=true" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "textMessage": {"text": "Your verification code is 1234"},
    "phoneNumbers": ["+1234567890"],
    "ttl": 600,
    "priority": 100
  }'
```

#### cURL - Data Message
```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "dataMessage": {
      "data": "SGVsbG8gRGF0YSBXb3JsZCE=",
      "port": 53739
    },
    "phoneNumbers": ["+1234567890"],
    "ttl": 3600
  }'
```

### Best Practices for Sending Messages

1. **Use Appropriate Priority**
   - High (100+) for time-sensitive messages (OTPs, alerts)
   - Normal (0-99) for routine notifications
   - Low (-128 to -1) for non-urgent bulk traffic

2. **Set TTL Values**
   - Always set `ttl` or `validUntil` to prevent indefinite queuing
   - Typical values: 600s (10 min) for OTPs, 3600s (1 hour) for notifications

3. **Handle Long Messages**
   - Messages >160 chars are auto-split (GSM-7) or >70 chars (Unicode)
   - Each part counts as separate SMS for billing/delivery
   - Consider using data SMS for compact binary data

4. **Batch Sending**
   - Split large batches into smaller groups (e.g., 100 recipients per batch)
   - Add delays between batches to avoid rate limits
   - Use priority ≥100 to bypass rate limits when necessary

5. **Idempotency**
   - Use unique message IDs if your application requires deduplication
   - The API auto-generates IDs if not provided

6. **Device Selection**
   - Use `deviceId` to target specific devices in multi-device setups
   - Use `deviceActiveWithin` to ensure device is online

7. **SIM Selection**
   - Use `simNumber` to route messages through specific SIM cards
   - Configure SIM rotation in app settings if `simNumber` is not specified

---

## Receiving SMS Messages

Receiving SMS messages is accomplished through **webhook notifications**. When an SMS arrives at the device, the app sends an HTTP POST request to your registered webhook endpoint with the message details.

### Webhook Setup

#### Step 1: Prepare Your Server

Your webhook endpoint must:
- Accept HTTPS POST requests (HTTP only allowed for `127.0.0.1`)
- Respond with 2xx status within **30 seconds**
- Be publicly accessible (for Cloud/Private modes) or on same network (Local mode)

**Example webhook handler (Python Flask):**
```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def receive_webhook():
    data = request.get_json()
    print(f"Received event: {data['event']}")

    if data['event'] == 'sms:received':
        payload = data['payload']
        print(f"SMS from {payload['phoneNumber']}: {payload['message']}")

        # Process the message...
        # Return 2xx to acknowledge receipt
        return jsonify({'status': 'received'}), 200

    return jsonify({'status': 'ignored'}), 200

if __name__ == '__main__':
    app.run(ssl_context='adhoc')  # Use proper SSL in production
```

#### Step 2: Register Webhook

Use the webhook registration API to add your endpoint:

**Endpoint:**
```
POST /3rdparty/v1/webhooks
```

**Request (Cloud mode example):**
```bash
curl -X POST -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-server.com/webhook",
    "event": "sms:received"
  }' \
  https://api.sms-gate.app/3rdparty/v1/webhooks
```

**For a specific device:**
```bash
curl -X POST -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-server.com/webhook",
    "event": "sms:received",
    "deviceId": "deviceId"
  }' \
  https://api.sms-gate.app/3rdparty/v1/webhooks
```

**Note:** Each webhook is registered for a single event. Register separate webhooks for multiple events.

#### Step 3: Verify Registration

**Via API:**
```bash
curl -X GET -u "username:password" \
  https://api.sms-gate.app/3rdparty/v1/webhooks
```

**Via App:**
1. Open SMS Gateway app
2. Navigate to **Settings** > **Webhooks** > **Registered webhooks**
3. View list of registered webhooks with URL, ID, event type, and source

#### Step 4: Test the Webhook

Trigger the event:
- `sms:received`: Send an SMS to the device
- `sms:data-received`: Send a data SMS to port 53739
- `mms:received`: Send an MMS message
- `sms:sent`/`delivered`/`failed`: Send an SMS from the app
- `system:ping`: Enable ping in **Settings > Ping**

### Webhook Event Types

#### sms:received

Triggered when a text SMS is received.

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:received",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "abc123",
    "message": "Android is always a sweet treat!",
    "phoneNumber": "6505551212",
    "simNumber": 1,
    "receivedAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### sms:data-received

Triggered when a data SMS (binary) is received.

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:data-received",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "abc123",
    "data": "SGVsbG8gRGF0YSBXb3JsZCE=",
    "phoneNumber": "6505551212",
    "simNumber": 1,
    "receivedAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### mms:received

Triggered when an MMS message is received (receive-only, no attachment content).

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "mms:received",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "mms_12345abcde",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "transactionId": "T1234567890ABC",
    "subject": "Photo attachment",
    "size": 125684,
    "contentClass": "IMAGE_BASIC",
    "receivedAt": "2025-08-23T05:15:30.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### sms:sent

Triggered when an outgoing message is successfully sent from the device.

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:sent",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "abc123",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "partsCount": 1,
    "sentAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### sms:delivered

Triggered when delivery confirmation is received from the carrier. **Note:** For multipart messages, this fires once for each part.

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:delivered",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "abc123",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "deliveredAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### sms:failed

Triggered when message sending or delivery fails.

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:failed",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "abc123",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "reason": "RESULT_ERROR_LIMIT_EXCEEDED",
    "failedAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

#### system:ping

Triggered periodically when ping feature is enabled (health check).

**Payload:**
```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "system:ping",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "health": {
      "status": "healthy",
      "timestamp": "2024-06-22T15:46:11.000+07:00"
    }
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

### Webhook Retry Policy

If your server doesn't respond with 2xx within 30 seconds, the app retries with exponential backoff:
- 1st retry: 10 seconds
- 2nd retry: 20 seconds
- 3rd retry: 40 seconds
- Continues doubling (14 retries total ≈ 2 days)

Configure custom retry count in **Settings > Webhooks** on the device.

### Webhook Security - Payload Signing

All webhook requests are signed with HMAC-SHA256 for verification.

**Headers included:**
- `X-Signature` - Hexadecimal HMAC signature
- `X-Timestamp` - Unix timestamp (seconds) used in signature

**Signing key:** Randomly generated on first request, configurable in **Settings > Webhooks > Signing Key**

#### Verification Process

1. Get raw request body **as received** (before JSON parsing)
2. Concatenate with `X-Timestamp` value
3. Compute HMAC-SHA256 using the signing key
4. Compare result with `X-Signature` header

**Example (Python):**
```python
import hmac
import hashlib

def verify_signature(secret_key: str, payload: str, timestamp: str, signature: str) -> bool:
    """Verify webhook signature"""
    message = (payload + timestamp).encode()
    expected_signature = hmac.new(
        secret_key.encode(),
        message,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected_signature, signature)

# Flask example
@app.route('/webhook', methods=['POST'])
def webhook():
    secret_key = os.environ['WEBHOOK_SIGNING_KEY']
    payload = request.get_data(as_text=True)
    timestamp = request.headers.get('X-Timestamp')
    signature = request.headers.get('X-Signature')

    if not verify_signature(secret_key, payload, timestamp, signature):
        return 'Invalid signature', 401

    # Process webhook...
    return 'OK', 200
```

**Security Best Practices:**
- Use constant-time comparison to prevent timing attacks
- Validate timestamps (accept only within ±5 minutes) to prevent replay attacks
- Store signing keys securely (environment variables, vaults)
- Always verify signatures before processing

### Multipart Message Behavior

For messages longer than standard limits (160 chars GSM-7 or 70 chars Unicode), the app auto-splits into multiple parts. This affects webhook delivery:

| Event | Behavior |
|-------|----------|
| `sms:received` | Triggered once after all parts are received and assembled |
| `sms:sent` | Triggered once when all parts are sent; `partsCount` indicates number of parts |
| `sms:delivered` | Triggered once **for each individual part** |
| `sms:failed` | Triggered once if any part fails |

**Deduplication tip:** Use `messageId` to group related delivery reports. Consider message fully delivered when you've received confirmations for all expected parts.

---

## Advanced Features

### Data SMS Support

Data SMS enables transmission of binary data payloads (up to 140 bytes) via traditional SMS, without requiring mobile data connectivity.

**Use Cases:**
- IoT device control commands
- Encrypted message delivery
- Silent OTP authentication
- Custom binary protocols

**Receiving Data SMS:**
Webhook event: `sms:data-received` with `data` field containing base64-encoded binary payload.

**Limitations:**
- Max 140 bytes per message (carrier-dependent)
- Delivery reliability varies by carrier
- No attachment content (unlike MMS)

### Multi-SIM Support

For devices with multiple SIM cards, the app provides:

#### SIM Selection for Sending

Specify `simNumber` in your API request (1-based index):

```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "textMessage": {"text": "Hello from SIM 2!"},
    "phoneNumbers": ["+1234567890"],
    "simNumber": 2
  }'
```

#### SIM Rotation (Automatic)

When `simNumber` is not specified, configure rotation in the app (**Settings > Messages > SIM Selection**):

- **OS Default** - Delegates to Android's default messaging app
- **Round Robin** - Cycles through SIMs sequentially
- **Random** - Randomly selects a SIM for each message

#### SIM Information in Webhooks

All webhook events include `simNumber` field indicating which SIM was used (null if not applicable).

### MMS Support (Receive-Only)

The app can receive MMS messages and notify via webhooks. **Sending MMS is not supported.**

**Prerequisites:**
- `RECEIVE_MMS` permission granted
- `RECEIVE_SMS` permission
- Carrier MMS support

**Webhook Event:** `mms:received`

**Payload:**
```json
{
  "event": "mms:received",
  "payload": {
    "messageId": "mms_12345abcde",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "transactionId": "T1234567890ABC",
    "subject": "Photo attachment",
    "size": 125684,
    "contentClass": "IMAGE_BASIC",
    "receivedAt": "2025-08-23T05:15:30.000+07:00"
  }
}
```

**Note:** Webhooks provide metadata only, not actual attachment content. Attachments are stored locally on the device.

---

## Error Handling

### Common HTTP Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| 200/201 | Success | - |
| 202 | Accepted | Message queued for delivery |
| 400 | Bad Request | Check request payload, validate parameters |
| 401 | Unauthorized | Invalid credentials or expired token |
| 403 | Forbidden | Insufficient scopes (JWT) or wrong password |
| 404 | Not Found | Endpoint or resource doesn't exist |
| 409 | Conflict | Duplicate message ID or resource conflict |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Retry with exponential backoff |
| 501 | Not Implemented | Feature not available in current mode (e.g., JWT in Local mode) |
| 503 | Service Unavailable | Server temporarily unavailable, retry |

### Common Error Responses

**Validation Error:**
```json
{
  "error": "ValidationError",
  "message": "Invalid phone number format",
  "details": {
    "phoneNumbers": ["Must be valid E.164 format"]
  }
}
```

**Rate Limit Exceeded:**
```json
{
  "error": "RateLimitExceeded",
  "message": "Message rate limit exceeded",
  "retryAfter": 60
}
```

**Authentication Errors:**
- **401 Unauthorized**: Invalid credentials or expired JWT token
  - For Basic Auth: Verify username/password
  - For JWT: Generate new token
- **403 Forbidden**: Insufficient scopes (JWT) or account locked

**Device Not Available:**
```json
{
  "error": "NoActiveDevice",
  "message": "No active device found"
}
```

### Error Handling Best Practices

1. **Implement Retry Logic**
   - Use exponential backoff for 429 and 5xx errors
   - Maximum retries: 3-5 attempts
   - Respect `Retry-After` header if present

2. **Token Refresh (JWT)**
   - Detect 401 errors and generate new token
   - Refresh tokens before expiration (e.g., 5 minutes before)

3. **Validate Inputs**
   - Validate phone numbers (E.164 format) before sending
   - Check message length limits (160 chars GSM-7, 70 chars Unicode)
   - Verify base64 encoding for data messages

4. **Log Errors**
   - Log full error responses for debugging
   - Include request IDs for correlation
   - Track error rates for monitoring

5. **Graceful Degradation**
   - Queue messages locally if API is unavailable
   - Implement fallback mechanisms for critical messages

---

## Security Considerations

### API Security

1. **Use JWT Authentication**
   - Prefer JWT over Basic Auth for new integrations
   - Use short TTLs (1-24 hours)
   - Request minimal scopes

2. **Secure Credential Storage**
   - Never hardcode credentials in source code
   - Use environment variables or secure vaults
   - Rotate passwords and tokens regularly

3. **Enforce HTTPS**
   - Always use HTTPS for API calls
   - Verify SSL certificates (disable verification only for testing)

4. **Scope Limitation**
   - Grant only necessary permissions
   - Use separate tokens for different applications

### Webhook Security

1. **Verify Signatures**
   - Always validate `X-Signature` header
   - Use constant-time comparison
   - Check timestamp to prevent replay attacks (±5 minutes)

2. **Secure Endpoint**
   - Use HTTPS with valid SSL certificate
   - Implement IP whitelisting if possible
   - Add authentication to your webhook endpoint (API keys, etc.)

3. **Rate Limiting**
   - Implement rate limiting on your webhook endpoint
   - Reject malicious payloads early

4. **Input Validation**
   - Validate all webhook data before processing
   - Sanitize phone numbers and message content
   - Handle malformed JSON gracefully

### Data Privacy

1. **Encryption**
   - Use `isEncrypted: true` for sensitive messages
   - Encrypt data before sending (end-to-end encryption)
   - Store decryption keys securely

2. **Data Retention**
   - Set appropriate TTL values for messages
   - Delete processed webhook payloads promptly
   - Comply with data protection regulations (GDPR, etc.)

3. **Logging**
   - Avoid logging sensitive data (phone numbers, message content)
   - Mask PII in logs
   - Secure log storage

---

## Troubleshooting

### No Messages Received

**Checklist:**
- ✅ Webhook URL is correct and accessible
- ✅ Device has internet connectivity (Cloud/Private) or is on same network (Local)
- ✅ SSL certificate is valid (not self-signed unless using CA)
- ✅ Webhook is properly registered (check via API or app)
- ✅ App has RECEIVE_SMS permission
- ✅ Device is powered on and app is running
- ✅ Test with [webhook.site](https://webhook.site) to isolate issues

### Webhook Not Triggering

**Checklist:**
- ✅ Event type matches what you're testing (`sms:received`, etc.)
- ✅ Server responds with 2xx within 30 seconds
- ✅ No firewall blocking incoming requests
- ✅ Check device logs for webhook delivery errors
- ✅ Verify webhook signing key is set (if signature validation fails)

### Signature Validation Failing

**Common causes:**
- Using parsed JSON instead of raw request body
- Timestamp not in UTC Unix seconds format
- Signing key mismatch (check Settings > Webhooks > Signing Key)
- Extra whitespace in signature comparison

**Fix:** Use raw payload before JSON parsing and ensure constant-time comparison.

### Rate Limit Errors (429)

**Causes:**
- Exceeded configured message limits
- Too many requests in short time

**Solutions:**
- Reduce sending rate or batch size
- Use higher priority (≥100) to bypass limits
- Increase limits in app settings (**Settings > Messages > Limits**)
- Implement exponential backoff in your code

### JWT Token Issues

**401 Unauthorized:**
- Token expired → Generate new token
- Invalid token → Regenerate
- Wrong mode → JWT not available in Local mode (use Basic Auth)

**403 Forbidden:**
- Insufficient scopes → Request appropriate scopes
- Token revoked → Generate new token

### Data SMS Not Working

**Checklist:**
- ✅ App version ≥1.40.0
- ✅ Server version ≥1.24.0 (Cloud/Private)
- ✅ Port is within 1-65535 range
- ✅ Data is properly base64-encoded
- ✅ Carrier supports data SMS (contact carrier if uncertain)
- ✅ `SEND_SMS` permission granted

### Multi-SIM Not Working

**Checklist:**
- ✅ Device has multiple SIM cards installed and active
- ✅ App has READ_PHONE_STATE permission
- ✅ `simNumber` is valid (1-3 based on number of SIMs)
- ✅ SIM rotation configured in app settings if not specifying `simNumber`

### Local Mode Webhook Issues

**Common issues:**
- Device and server not on same network/subnet
- Using HTTP instead of HTTPS (only `127.0.0.1` allowed)
- Private IPs require valid SSL or use insecure build variant

**Solutions:**
- Use ADB port forwarding: `adb reverse tcp:9876 tcp:8080`
- Generate trusted certificates using Project CA
- Use ngrok/Cloudflare Tunnel for HTTPS on localhost

### Message Not Sending

**Checklist:**
- ✅ Device is active (check `deviceActiveWithin` parameter)
- ✅ Device has sufficient SMS credit/balance
- ✅ SIM card is properly inserted and active
- ✅ App has SEND_SMS permission
- ✅ Message content is not empty
- ✅ Phone number format is correct (E.164 unless `skipPhoneValidation=true`)
- ✅ Check device logs for sending errors

---

## Additional Resources

- **API Reference**: https://api.sms-gate.app/docs/
- **OpenAPI Spec**: https://api.sms-gate.app/docs/doc.json
- **FAQ**: https://docs.sms-gate.app/faq/
- **Support**: support@sms-gate.app

---

## Quick Reference

### API Base URLs

| Mode | Base URL |
|------|----------|
| Cloud | `https://api.sms-gate.app` |
| Private | Your custom domain |
| Local | `http://<device-local-ip>:8080` |

### Authentication Comparison

| Feature | JWT | Basic Auth |
|---------|-----|------------|
| Security | High | Medium |
| Access Control | Scopes | All-or-nothing |
| Token Management | Yes (TTL, revocation) | No |
| Recommended | ✅ Yes | ⚠️ Legacy only |

### Essential cURL Commands

```bash
# Send SMS (Basic Auth)
curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"phoneNumbers": ["+1234567890"], "textMessage": {"text": "Hello"}}'

# Generate JWT token
curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"ttl": 3600, "scopes": ["messages:send"]}'

# Register webhook
curl -X POST -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://your-server.com/webhook", "event": "sms:received"}' \
  https://api.sms-gate.app/3rdparty/v1/webhooks

# List webhooks
curl -X GET -u "username:password" \
  https://api.sms-gate.app/3rdparty/v1/webhooks

# List devices
curl -X GET -u "username:password" \
  https://api.sms-gate.app/3rdparty/v1/devices
```
