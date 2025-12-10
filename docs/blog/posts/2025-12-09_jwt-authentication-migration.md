---
title: "Securing Your SMS Gateway: Migrating from Basic Auth to JWT"
date: 2025-12-10
categories:
  - Security
  - Authentication
  - API
description: "Learn how JWT authentication enhances security, enables fine-grained access control, and improves performance over Basic Authentication in the SMS Gateway API. Complete migration guide with code examples."
author: SMSGate Team LLM / Claude Sonnet 4.5
---
# 🔐 Securing Your SMS Gateway: Migrating from Basic Auth to JWT

Picture this: Your SMS gateway credentials get accidentally committed to a public GitHub repository. With Basic Authentication, every single API request transmits those credentials, creating countless opportunities for interception. One leaked password means immediate exposure of your entire SMS infrastructure. This scenario isn't hypothetical—it happens regularly in production environments, leading to security breaches, and unauthorized access. Modern API security demands a better approach.

Enter JWT (JSON Web Token) authentication—a token-based authentication mechanism that eliminates the need to transmit credentials with every request while providing fine-grained access control through scopes. In this comprehensive guide, we'll explore why JWT authentication is replacing Basic Auth as the primary authentication method for the SMSGate API, walk through the technical implementation, and provide complete code examples for a smooth migration. Whether you're maintaining existing integrations or building new ones, understanding this transition is essential for securing your SMS infrastructure.

<!-- more -->

<center>
  <img src="/assets/blog/jwt-authentication-migration.png" alt="JWT Authentication Migration">
</center>

## 🎯 Why JWT Authentication?

### The Basic Auth Problem

Basic Authentication has served the web well for decades, but it suffers from fundamental limitations in modern API architectures:

1. **Credential Transmission**: Username and password are sent with every single request (base64 encoded, but not encrypted)
2. **All-or-Nothing Access**: No way to limit what actions a credential can perform
3. **No Expiration**: Credentials remain valid indefinitely unless manually changed
4. **Difficult to Revoke**: Revoking access requires password changes across all systems
5. **Security Risk**: Credentials exposed in logs, network traces, or compromised systems grant full access

### JWT Authentication Benefits

JWT authentication addresses these concerns with a modern, secure approach:

| Feature              | Basic Auth                            | JWT Authentication                 |
| -------------------- | ------------------------------------- | ---------------------------------- |
| **Security**         | Medium (credentials in every request) | High (token-based with expiration) |
| **Access Control**   | All-or-nothing                        | Fine-grained via scopes            |
| **Token Management** | None                                  | Revocation, TTL, refresh           |
| **Audit Trail**      | Limited                               | Comprehensive (scopes, expiry)     |
| **Recommended For**  | Legacy systems only                   | All new integrations               |

!!! success "Key Advantages"
    - **Enhanced Security**: Tokens expire automatically, limiting exposure window
    - **Least Privilege**: Request only the permissions you need via scopes
    - **Flexible Revocation**: Invalidate specific tokens without affecting others
    - **Future-Proof**: Industry-standard approach with broad tooling support

## 🔑 Understanding JWT Tokens

### Token Structure

A JWT token consists of three base64-encoded parts separated by dots:

```text
Header.Payload.Signature
```

**Example Token:**
```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMTIzIiwic2NvcGVzIjpbIm1lc3NhZ2VzOnNlbmQiXSwiZXhwIjoxNzMzNzg1MjAwfQ.signature_here
```

**Decoded Payload:**
```json
{
  "sub": "user123",
  "scopes": ["messages:send", "messages:read"],
  "exp": 1733785200,
  "iat": 1733781600
}
```

### JWT Scopes

Scopes implement the principle of least privilege, allowing you to limit what each token can do:

| Scope                                                | Permission           | Use Case             |
| ---------------------------------------------------- | -------------------- | -------------------- |
| `messages:send`                                      | Send SMS messages    | Frontend application |
| `messages:list`, `messages:read`                     | Read message history | Analytics dashboard  |
| `webhooks:list`, `webhooks:write`, `webhooks:delete` | Manage webhooks      | Configuration panel  |

!!! tip "Scope Best Practice"
    Always request the minimum scopes necessary. A token for sending messages doesn't need webhook management permissions.

## 🚀 Getting Started with JWT

### Step 1: Generate Your First Token

To generate a JWT token, make a POST request to the token endpoint using your existing Basic Auth credentials:

=== "Python"
    ```python
    import requests
    import json
    
    # Your Basic Auth credentials
    USERNAME = "your_username"
    PASSWORD = "your_password"
    
    # Token endpoint
    token_url = "https://api.sms-gate.app/3rdparty/v1/auth/token"
    
    # Token configuration
    token_request = {
        "ttl": 3600,  # Token validity in seconds (1 hour)
        "scopes": ["messages:send", "messages:read"]
    }
    
    response = requests.post(
        token_url,
        auth=(USERNAME, PASSWORD),
        headers={"Content-Type": "application/json"},
        json=token_request
    )
    
    if response.status_code == 201:
        token_data = response.json()
        access_token = token_data["access_token"]
        expires_at = token_data["expires_at"]
        
        print(f"✓ Token generated successfully")
        print(f"Token: {access_token[:50]}...")
        print(f"Expires: {expires_at}")
    else:
        print(f"✗ Error: {response.status_code}")
        print(response.text)
    ```

=== "JavaScript"
    ```javascript
    const axios = require('axios');
    
    // Your Basic Auth credentials
    const USERNAME = 'your_username';
    const PASSWORD = 'your_password';
    
    // Token endpoint
    const tokenUrl = 'https://api.sms-gate.app/3rdparty/v1/auth/token';
    
    // Token configuration
    const tokenRequest = {
      ttl: 3600,  // Token validity in seconds (1 hour)
      scopes: ['messages:send', 'messages:read']
    };
    
    axios.post(tokenUrl, tokenRequest, {
      auth: { username: USERNAME, password: PASSWORD },
      headers: { 'Content-Type': 'application/json' }
    })
    .then(response => {
      const { access_token, expires_at } = response.data;
      console.log('✓ Token generated successfully');
      console.log(`Token: ${access_token.substring(0, 50)}...`);
      console.log(`Expires: ${expires_at}`);
    })
    .catch(error => {
      console.error(`✗ Error: ${error.response?.status}`);
      console.error(error.response?.data);
    });
    ```

=== "cURL"
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
  "id": "nHDAWaPS6zv3itRUpM9ko",
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-12-10T03:03:09Z"
}
```

### Step 2: Use the JWT Token

Once you have a token, include it in the `Authorization` header of your API requests:

=== "Python"
    ```python
    import requests
    
    # Your JWT token
    access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    
    # Send SMS with JWT
    send_url = "https://api.sms-gate.app/3rdparty/v1/messages"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    message_data = {
        "phoneNumbers": ["+1234567890"],
        "textMessage": {"text": "Hello from JWT!"}
    }
    
    response = requests.post(send_url, headers=headers, json=message_data)
    
    if response.status_code == 200:
        print("✓ Message sent successfully")
        print(response.json())
    else:
        print(f"✗ Error: {response.status_code}")
    ```

=== "JavaScript"
    ```javascript
    const axios = require('axios');
    
    // Your JWT token
    const accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
    
    // Send SMS with JWT
    const sendUrl = 'https://api.sms-gate.app/3rdparty/v1/messages';
    const headers = {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    };
    
    const messageData = {
      phoneNumbers: ['+1234567890'],
      textMessage: { text: 'Hello from JWT!' }
    };
    
    axios.post(sendUrl, messageData, { headers })
      .then(response => {
        console.log('✓ Message sent successfully');
        console.log(response.data);
      })
      .catch(error => {
        console.error(`✗ Error: ${error.response?.status}`);
      });
    ```

=== "cURL"
    ```bash
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
      -H "Content-Type: application/json" \
      -d '{
        "phoneNumbers": ["+1234567890"],
        "textMessage": {"text": "Hello from JWT!"}
      }'
    ```

## 🔄 Migration Strategy

### Phase 1: Dual Authentication Support

Both Basic Auth and JWT will be supported during the transition period, allowing for gradual migration:

```python
class SMSGatewayClient:
    """Client supporting both Basic Auth and JWT"""
    
    def __init__(self, base_url, username, password):
        self.base_url = base_url
        self.username = username
        self.password = password
        self.access_token = None
        self.token_expires_at = None
    
    def _get_headers(self, use_jwt=True):
        """Get appropriate headers based on auth method"""
        headers = {"Content-Type": "application/json"}
        
        if use_jwt and self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
        
        return headers
    
    def _get_auth(self, use_jwt=True):
        """Get auth tuple for Basic Auth"""
        if use_jwt:
            return None  # JWT uses header
        return (self.username, self.password)
    
    def send_message(self, phone_numbers, text, use_jwt=True):
        """Send SMS using JWT (default) or Basic Auth"""
        response = requests.post(
            f"{self.base_url}/messages",
            headers=self._get_headers(use_jwt),
            auth=self._get_auth(use_jwt),
            json={
                "phoneNumbers": phone_numbers,
                "textMessage": {"text": text}
            }
        )
        return response
```

### Phase 2: Implement Token Management

Implement proper token lifecycle management:

```python
from datetime import datetime, timedelta
import requests

class JWTTokenManager:
    """Manages JWT token lifecycle"""
    
    def __init__(self, token_url, username, password):
        self.token_url = token_url
        self.username = username
        self.password = password
        self.access_token = None
        self.expires_at = None
    
    def get_token(self, scopes, ttl=3600):
        """Get a new JWT token"""
        response = requests.post(
            self.token_url,
            auth=(self.username, self.password),
            json={"ttl": ttl, "scopes": scopes}
        )
        
        if response.status_code == 201:
            data = response.json()
            self.access_token = data["access_token"]
            self.expires_at = datetime.fromisoformat(
                data["expires_at"].replace("Z", "+00:00")
            )
            return self.access_token
        else:
            raise Exception(f"Token generation failed: {response.text}")
    
    def is_valid(self):
        """Check if current token is still valid"""
        if not self.access_token or not self.expires_at:
            return False
        
        # Add 60 second buffer before expiration
        return datetime.now(self.expires_at.tzinfo) < (
            self.expires_at - timedelta(seconds=60)
        )
    
    def ensure_valid_token(self, scopes):
        """Ensure we have a valid token, refresh if needed"""
        if not self.is_valid():
            return self.get_token(scopes)
        return self.access_token

# Usage
token_manager = JWTTokenManager(
    "https://api.sms-gate.app/3rdparty/v1/auth/token",
    "username",
    "password"
)

# Always get a valid token
token = token_manager.ensure_valid_token(["messages:send"])
```

### Phase 3: Full JWT Migration

Complete the migration by removing Basic Auth fallbacks:

```python
import requests
from datetime import datetime

class SMSGatewayJWT:
    """JWT-only SMS Gateway client"""
    
    def __init__(self, base_url, username, password):
        self.base_url = base_url
        self.token_manager = JWTTokenManager(
            f"{base_url}/auth/token",
            username,
            password
        )
    
    def _make_request(self, method, endpoint, scopes, **kwargs):
        """Make authenticated request with automatic token refresh"""
        token = self.token_manager.ensure_valid_token(scopes)
        
        headers = kwargs.pop("headers", {})
        headers["Authorization"] = f"Bearer {token}"
        
        response = requests.request(
            method,
            f"{self.base_url}{endpoint}",
            headers=headers,
            **kwargs
        )
        return response
    
    def send_message(self, phone_numbers, text):
        """Send SMS message"""
        return self._make_request(
            "POST",
            "/messages",
            scopes=["messages:send"],
            json={
                "phoneNumbers": phone_numbers,
                "textMessage": {"text": text}
            }
        )
    
    def get_messages(self, limit=50, offset=0):
        """Retrieve message history"""
        return self._make_request(
            "GET",
            "/messages",
            scopes=["messages:read"],
            params={"limit": limit, "offset": offset}
        )
```

## 🛡️ Security Best Practices

### 1. Token Storage

Never store tokens in client-side code or version control:

```python
import os

# ✓ Good: Environment variables
TOKEN_URL = os.getenv("SMS_TOKEN_URL")
USERNAME = os.getenv("SMS_USERNAME")
PASSWORD = os.getenv("SMS_PASSWORD")

# ✗ Bad: Hardcoded credentials
TOKEN_URL = "https://api.sms-gate.app/3rdparty/v1/auth/token"
USERNAME = "my_username"  # Never do this!
PASSWORD = "my_password"  # Never do this!
```

### 2. Minimal Token TTL

Use the shortest practical token lifetime:

```python
# For long-running services
token_manager.get_token(scopes=["messages:send"], ttl=3600)  # 1 hour

# For batch jobs
token_manager.get_token(scopes=["messages:send"], ttl=600)   # 10 minutes

# For one-time operations
token_manager.get_token(scopes=["messages:send"], ttl=300)   # 5 minutes
```

### 3. Scope Limitation

Request only necessary scopes:

```python
# ✓ Good: Minimal scopes
send_token = get_token(scopes=["messages:send"])
read_token = get_token(scopes=["messages:read"])

# ✗ Bad: Excessive permissions
admin_token = get_token(scopes=["all:any"])
```

### 4. Token Revocation

Revoke tokens when no longer needed:

```python
def revoke_token(token, jti):
    """Revoke a JWT token"""
    response = requests.delete(
        f"https://api.sms-gate.app/3rdparty/v1/auth/token/{jti}",
        headers={"Authorization": f"Bearer {token}"}
    )
    return response.status_code == 204
```

## 🎯 Common Use Cases

### 1. Frontend Application

Generate short-lived tokens with limited scopes:

```javascript
// Token for sending messages only (1 hour)
const frontendToken = await generateToken({
  scopes: ['messages:send'],
  ttl: 3600
});
```

### 2. Analytics Dashboard

Read-only access to message history:

```python
# Token for analytics (24 hours)
analytics_token = generate_token(
    scopes=["messages:list", "messages:read"],
    ttl=86400
)
```

### 3. Admin Tools

Full access with moderate expiration:

```python
# Token for administration (4 hours)
admin_token = generate_token(
    scopes=["messages:list", "messages:read", "devices:list", "devices:delete", "webhooks:list", "webhooks:write", "webhooks:delete"],
    ttl=14400
)
```

### 4. Automated Jobs

Minimal permissions for batch operations:

```python
# Token for nightly report generation (1 hour)
batch_token = generate_token(
    scopes=["messages:list"],
    ttl=3600
)
```

## ⚠️ Troubleshooting

### Invalid Token Error

**Problem**: Getting 401 "invalid token" errors

**Solutions**:
1. Verify token hasn't expired
2. Check authorization header format (should start with "Bearer ")
3. Ensure token was generated successfully
4. Verify server time synchronization

```python
# Debug token validation
from datetime import datetime
import jwt

try:
    # Decode without verification to inspect
    decoded = jwt.decode(token, options={"verify_signature": False})
    exp = datetime.fromtimestamp(decoded['exp'])
    
    if datetime.now() > exp:
        print("✗ Token expired")
    else:
        print(f"✓ Token valid until {exp}")
except Exception as e:
    print(f"✗ Invalid token format: {e}")
```

### Insufficient Permissions

**Problem**: Getting 403 "forbidden" errors

**Solution**: Verify token has required scopes

```python
# Check token scopes
decoded = jwt.decode(token, options={"verify_signature": False})
scopes = decoded.get('scopes', [])

required_scope = "messages:send"
if required_scope in scopes:
    print(f"✓ Token has {required_scope}")
else:
    print(f"✗ Token missing {required_scope}")
    print(f"Available scopes: {scopes}")
```

## 🎓 Migration Checklist

Use this checklist for a smooth transition:

- [ ] **Week 1: Preparation**
    - [ ] Review JWT documentation
    - [ ] Test token generation in development
    - [ ] Identify all services using Basic Auth
    - [ ] Plan scope requirements per service

- [ ] **Week 2: Implementation**
    - [ ] Implement token management class
    - [ ] Add JWT support to existing clients
    - [ ] Create dual-auth fallback mechanism
    - [ ] Set up monitoring for auth errors

- [ ] **Week 3: Testing**
    - [ ] Test in staging environment
    - [ ] Verify all scopes work correctly
    - [ ] Load test JWT performance
    - [ ] Document token refresh flows

- [ ] **Week 4: Deployment**
    - [ ] Deploy JWT support to production
    - [ ] Monitor error rates
    - [ ] Gradually shift traffic to JWT
    - [ ] Keep Basic Auth as fallback

- [ ] **Week 5+: Cleanup**
    - [ ] Verify 100% JWT usage
    - [ ] Remove Basic Auth code
    - [ ] Update all documentation
    - [ ] Archive Basic Auth credentials

## 🎉 Conclusion

JWT authentication represents a significant security and performance upgrade over Basic Authentication. By implementing token-based authentication with fine-grained scopes, you gain:

- **Enhanced security** through time-limited, revocable tokens
- **Fine-grained access control** with scopes
- **Improved auditability** and monitoring
- **Industry-standard** approach with broad tooling support

The migration process is straightforward with the dual-authentication support during transition. Start by generating your first JWT token today, test it alongside Basic Auth, and gradually migrate your services. The security and performance benefits are well worth the effort.

Ready to get started? Check out our [Authentication Guide](../../integration/authentication.md) for complete API documentation, or explore our [client libraries](../../integration/client-libraries.md) with built-in JWT support.

Have questions about JWT migration? Join the discussion on [GitHub](https://github.com/capcom6/android-sms-gateway/discussions) and share your experience with the community!

## 🔗 Related Resources

- [Authentication Guide](../../integration/authentication.md) - Complete JWT documentation
- [Authentication FAQ](../../faq/authentication.md) - Common questions and answers
- [API Reference](../../integration/api.md) - Full API documentation
- [Client Libraries](../../integration/client-libraries.md) - Pre-built JWT integration

## 📚 Related Posts

- [Mastering Message Retrieval: A Developer's Guide to GET /messages API](./2025-08-07_get-messages-api-guide.md)
- [Targeting Messages to Specific Devices](./2025-07-20_targeting-messages-to-specific-devices.md)
- [Beyond Plain Text: Unlocking the Hidden Power of Data SMS](./2025-07-12_beyond-plain-text-unlocking-data-sms.md)