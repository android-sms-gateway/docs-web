---
title: "Enhanced JWT Security: Introducing Refresh Token Support"
date: 2026-03-14
categories:
  - Security
  - Authentication
  - API
description: "Learn about the new refresh token support for JWT authentication in the SMSGate API. Seamless token rotation, improved security, and better user experience for long-running services."
author: SMSGate Team LLM / Healer Alpha
---

# 🔄 Enhanced JWT Security: Introducing Refresh Token Support

We're excited to announce a significant enhancement to our JWT authentication system: **refresh token support**. This new feature enables seamless token rotation, improved security, and a better experience for long-running services that need to maintain access without storing credentials.

<!-- more -->

<center>
  <img src="/assets/blog/jwt-refresh-tokens.png" alt="JWT Refresh Tokens">
</center>

## 🎯 Why Refresh Tokens?

### The Token Expiration Challenge

While short-lived access tokens provide excellent security, they create a challenge for long-running services:

1. **Frequent Re-authentication**: Services must re-authenticate every 15 minutes (default TTL)
2. **Credential Storage**: Storing username/password for re-authentication increases security risk
3. **User Experience**: Applications need to handle token expiration gracefully
4. **Service Continuity**: Background jobs and daemons need uninterrupted access

### Refresh Token Benefits

Refresh tokens solve these challenges by providing a secure mechanism to obtain new token pairs:

| Feature                | Before (No Refresh)  | After (With Refresh)             |
| ---------------------- | -------------------- | -------------------------------- |
| **Token Lifetime**     | Short-lived only     | Short access + Long refresh      |
| **Re-authentication**  | Required frequently  | Rare (only when refresh expires) |
| **Credential Storage** | Required for re-auth | Not needed                       |
| **Security**           | Good                 | Better (token rotation)          |
| **User Experience**    | Interrupted          | Seamless                         |

!!! success "Key Advantages"
    - **Seamless Token Rotation**: Automatically obtain new tokens without user intervention
    - **Enhanced Security**: Refresh tokens are single-use and automatically rotated
    - **Reduced Credential Exposure**: No need to store or transmit credentials frequently
    - **Long-running Service Support**: Perfect for daemons, background jobs, and long-lived applications

## 🔑 Understanding Refresh Tokens

### Token Pair Structure

When you generate a JWT token, you now receive a **token pair**:

```json
{
  "id": "w8pxz0a4Fwa4xgzyCvSeC",
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-03-14T02:00:00Z"
}
```

| Token Type        | Purpose                | TTL                  | Usage                                 |
| ----------------- | ---------------------- | -------------------- | ------------------------------------- |
| **Access Token**  | API authentication     | Short (default: 15m) | Include in `Authorization` header     |
| **Refresh Token** | Obtain new token pairs | Long (default: 720h) | Use at `/auth/token/refresh` endpoint |

### Token Rotation Flow

Each refresh operation generates a **new token pair** and revokes the old one:

```text
┌──────────────────┐
│  Initial Request │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ POST /3rdparty/v1/auth/token        │
│ Authorization: Basic credentials    │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ Response: Token Pair                │
│ - access_token (15m)                │
│ - refresh_token (720h)              │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  Use API with   │
│  access_token   │
└────────┬────────┘
         │
         ▼ (after 15 minutes)
┌─────────────────────────────────────┐
│ POST /3rdparty/v1/auth/token/refresh│
│ Authorization: Bearer refresh_token │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ Response: NEW Token Pair            │
│ - access_token (15m)                │
│ - refresh_token (720h)              │
│ Old tokens revoked automatically    │
└─────────────────────────────────────┘
```

!!! warning "Token Rotation"
    Each refresh operation generates a new token pair and revokes the old one. **Always use the latest refresh token** returned by the API.

## 🚀 Getting Started with Refresh Tokens

### Step 1: Generate a Token Pair

Generate a token pair:

=== "Python"

    ```python
    import requests
    
    # Generate token pair
    response = requests.post(
        "https://api.sms-gate.app/3rdparty/v1/auth/token",
        auth=("username", "password"),
        headers={"Content-Type": "application/json"},
        json={
            "ttl": 3600,
            "scopes": ["messages:send", "messages:read"]
        }
    )
    
    if response.status_code == 201:
        token_data = response.json()
        access_token = token_data["access_token"]
        refresh_token = token_data["refresh_token"]
        expires_at = token_data["expires_at"]
        
        print(f"✓ Token pair generated")
        print(f"Access token expires: {expires_at}")
    ```

=== "JavaScript"

    ```javascript
    const axios = require('axios');
    
    (async () => {
      const response = await axios.post(
        'https://api.sms-gate.app/3rdparty/v1/auth/token',
        {
          ttl: 3600,
          scopes: ['messages:send', 'messages:read']
        },
        {
          auth: { username: 'username', password: 'password' },
          headers: { 'Content-Type': 'application/json' }
        }
      );
    
      const { access_token, refresh_token, expires_at } = response.data;
      console.log('✓ Token pair generated');
      console.log(`Access token expires: ${expires_at}`);
    })();
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

### Step 2: Refresh the Token Pair

When the access token expires, use the refresh token to obtain a new pair:

=== "Python"

    ```python
    import requests
    
    def refresh_token_pair(refresh_token):
        """Refresh token pair using refresh token"""
        response = requests.post(
            "https://api.sms-gate.app/3rdparty/v1/auth/token/refresh",
            headers={"Authorization": f"Bearer {refresh_token}"}
        )
        
        if response.status_code == 200:
            token_data = response.json()
            return {
                "access_token": token_data["access_token"],
                "refresh_token": token_data["refresh_token"],
                "expires_at": token_data["expires_at"]
            }
        else:
            raise Exception(f"Token refresh failed: {response.text}")
    
    # Usage
    new_tokens = refresh_token_pair(old_refresh_token)
    print(f"✓ Token refreshed, expires: {new_tokens['expires_at']}")
    ```

=== "JavaScript"

    ```javascript
    const axios = require('axios');
    
    async function refreshTokenPair(refreshToken) {
        const response = await axios.post(
            'https://api.sms-gate.app/3rdparty/v1/auth/token/refresh',
            {},
            {
                headers: { 'Authorization': `Bearer ${refreshToken}` }
            }
        );
        
        return {
            access_token: response.data.access_token,
            refresh_token: response.data.refresh_token,
            expires_at: response.data.expires_at
        };
    }
    
    // Usage
    const newTokens = await refreshTokenPair(oldRefreshToken);
    console.log(`✓ Token refreshed, expires: ${newTokens.expires_at}`);
    ```

=== "cURL"

    ```bash
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token/refresh" \
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ```

## 💻 Implementation Examples

### Complete Token Manager

Here's a complete implementation for managing JWT tokens with refresh support:

```python
from datetime import datetime, timedelta
import requests

class JWTTokenManager:
    """Manages JWT token lifecycle with refresh token support"""
    
    def __init__(self, token_url, username, password):
        self.token_url = token_url
        self.username = username
        self.password = password
        self.access_token = None
        self.refresh_token = None
        self.expires_at = None
    
    def get_token_pair(self, scopes, ttl=3600):
        """Get a new JWT token pair (access + refresh)"""
        response = requests.post(
            self.token_url,
            auth=(self.username, self.password),
            json={"ttl": ttl, "scopes": scopes}
        )
        
        if response.status_code == 201:
            data = response.json()
            self.access_token = data["access_token"]
            self.refresh_token = data["refresh_token"]
            self.expires_at = datetime.fromisoformat(
                data["expires_at"].replace("Z", "+00:00")
            )
            return self.access_token
        else:
            raise Exception(f"Token generation failed: {response.text}")
    
    def refresh_token_pair(self):
        """Refresh the token pair using the refresh token"""
        if not self.refresh_token:
            raise Exception("No refresh token available")
        
        response = requests.post(
            f"{self.token_url}/refresh",
            headers={"Authorization": f"Bearer {self.refresh_token}"}
        )
        
        if response.status_code == 200:
            data = response.json()
            self.access_token = data["access_token"]
            self.refresh_token = data["refresh_token"]
            self.expires_at = datetime.fromisoformat(
                data["expires_at"].replace("Z", "+00:00")
            )
            return self.access_token
        else:
            # Refresh token expired or invalid, get new token pair
            raise Exception(f"Token refresh failed: {response.text}")
    
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
            if self.refresh_token:
                try:
                    return self.refresh_token_pair()
                except Exception:
                    # Refresh failed, get new token pair
                    pass
            return self.get_token_pair(scopes)
        return self.access_token
```

### Long-Running Service Example

For background services and daemons:

```python
import time
import requests
from datetime import datetime, timedelta

class SMSServiceDaemon:
    """Long-running SMS service with automatic token refresh"""
    
    def __init__(self, gateway_url, username, password):
        self.gateway_url = gateway_url
        self.token_manager = JWTTokenManager(
            f"{gateway_url}/3rdparty/v1/auth/token",
            username,
            password
        )
        self.scopes = ["messages:send", "messages:read"]
    
    def send_message(self, recipient, text):
        """Send a message with automatic token handling"""
        token = self.token_manager.ensure_valid_token(self.scopes)
        
        response = requests.post(
            f"{self.gateway_url}/3rdparty/v1/messages",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            json={
                "phoneNumbers": [recipient],
                "textMessage": {"text": text}
            }
        )
        
        if response.status_code == 202:
            return response.json()
        else:
            raise Exception(f"Failed to send message: {response.text}")

    def process_message_queue(self):
        """Fetch and process queued messages (implement your queue integration here)."""
        pass

    def run(self):
        """Main service loop"""
        while True:
            # Process messages from queue
            self.process_message_queue()
            time.sleep(60)

# Run the daemon
daemon = SMSServiceDaemon(
    "https://api.sms-gate.app",
    "username",
    "password"
)
daemon.run()
```

## 🔐 Security Best Practices

### 1. Store Refresh Tokens Securely

Refresh tokens have longer TTLs and should be stored securely:

```python
# ✓ Good: Encrypted storage
from cryptography.fernet import Fernet

key = Fernet.generate_key()
cipher = Fernet(key)
encrypted_refresh_token = cipher.encrypt(refresh_token.encode())

# ✗ Bad: Plain text storage
refresh_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # Never do this!
```

### 2. Handle Refresh Failures Gracefully

Implement fallback to re-authentication when refresh fails:

```python
try:
    token = token_manager.refresh_token_pair()
except Exception:
    # Refresh failed, re-authenticate
    token = token_manager.get_token_pair(scopes)
```

### 3. Monitor Token Usage

Track token refresh patterns to detect anomalies:

```python
import logging

logging.info(f"Token refreshed at {datetime.now()}")
logging.info(f"Refresh token JTI: {refresh_token_jti}")
```

## 🔄 Migration from Non-Refresh Tokens

If you're already using JWT tokens without refresh support, migration is simple. Refresh tokens are now automatically included in all token responses.

### Step 1: Store Refresh Token

Capture and store the refresh token from the response:

```python
token_data = response.json()
access_token = token_data["access_token"]
refresh_token = token_data["refresh_token"]  # NEW: Store this
```

### Step 2: Implement Refresh Logic

Add refresh token handling to your token manager:

```python
def ensure_valid_token(self, scopes):
    if not self.is_valid():
        if self.refresh_token:  # NEW: Try refresh first
            try:
                return self.refresh_token_pair()
            except Exception:
                pass
        return self.get_token_pair(scopes)
    return self.access_token
```

## 🐛 Troubleshooting

### "No refresh token available"

**Cause**: Refresh token wasn't stored or was lost.

**Solution**: Regenerate token pair and ensure you store the refresh token from the response.

### "Token refresh failed"

**Cause**: Refresh token expired or was revoked.

**Solution**: Re-authenticate to get a new token pair.

```python
try:
    token = token_manager.refresh_token_pair()
except Exception:
    # Refresh failed, re-authenticate
    token = token_manager.get_token_pair(scopes)
```

### "Invalid refresh token"

**Cause**: Refresh token was already used (token rotation) or malformed.

**Solution**: Always use the latest refresh token returned by the API.

## 🎉 Conclusion

Refresh token support represents a significant enhancement to our JWT authentication system, providing:

- **Seamless token rotation** for long-running services
- **Enhanced security** through automatic token rotation
- **Better user experience** with uninterrupted access
- **Reduced credential exposure** by eliminating frequent re-authentication

Start using refresh tokens today! Simply generate a token pair as you normally would, and the refresh token will be automatically included in the response. Your long-running services will thank you!

Ready to get started? Check out our [Authentication Guide](../../integration/authentication.md) for complete API documentation.

## 🔗 Related Resources

- [Authentication Guide](../../integration/authentication.md) - Complete JWT documentation
- [Authentication FAQ](../../faq/authentication.md) - Common questions and answers
- [API Reference](../../integration/api.md) - Full API documentation
- [Previous Post: JWT Migration Guide](./2025-12-09_jwt-authentication-migration.md) - Migrating from Basic Auth to JWT

## 📚 Related Posts

- [Securing Your SMS Gateway: Migrating from Basic Auth to JWT](./2025-12-09_jwt-authentication-migration.md)
- [Mastering Message Retrieval: A Developer's Guide to GET /messages API](./2025-08-07_get-messages-api-guide.md)
- [Targeting Messages to Specific Devices](./2025-07-20_targeting-messages-to-specific-devices.md)
