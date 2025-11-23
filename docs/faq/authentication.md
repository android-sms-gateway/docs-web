# ❌ FAQ - Authentication

## 🔐 What is JWT authentication and how does it work?

JWT (JSON Web Token) authentication is the primary authentication mechanism for the SMSGate API. It provides a secure, scalable way to authenticate API requests without transmitting credentials with each request.

## 🔄 How do I migrate from Basic Auth to JWT?

Migrating from Basic Authentication to JWT provides enhanced security, better performance, and fine-grained access control. Here's how to migrate:

### Step 1: Update Your Code

Replace Basic Auth with JWT Bearer tokens:

=== "Before (Basic Auth)"
   ```python
   response = requests.post(
      "https://api.sms-gate.app/3rdparty/v1/messages",
      auth=("username", "password"),
      json={"phoneNumbers": ["+1234567890"], "textMessage": {"text": "Hello world!"}}
   )
   ```

=== "After (JWT)"
   ```python
   # First, get a token
   token_response = requests.post(
      "https://api.sms-gate.app/3rdparty/v1/auth/token",
      auth=("username", "password"),
      json={"ttl": 3600, "scopes": ["messages:send"]}
   )

   if token_response.status_code == 201:
      token_data = token_response.json()
      access_token = token_data["access_token"]
      
      # Then use the token
      response = requests.post(
         "https://api.sms-gate.app/3rdparty/v1/messages",
         headers={
               "Authorization": f"Bearer {access_token}",
               "Content-Type": "application/json"
         },
         json={"phoneNumbers": ["+1234567890"], "textMessage": {"text": "Hello world!"}}
      )
   ```

### Step 2: Implement Token Management

- **Token Refresh**: Implement automatic token refresh before expiration
- **Error Handling**: Handle 401/403 errors gracefully
- **Secure Storage**: Store tokens securely on the server side

## 🔑 What are JWT scopes and how do I use them?

JWT scopes define the permissions associated with a token, implementing the principle of least privilege. All scopes follow the pattern: `resource:action`

All available scopes are listed in the [Authentication](../integration/authentication.md#jwt-scopes-) section.

### Using Scopes

When requesting a JWT token, specify which scopes you need:

```json
{
  "ttl": 3600,
  "scopes": [
    "messages:send",
    "messages:read",
    "devices:list"
  ]
}
```

!!! tip "Scope Best Practices"
    - Request only the scopes you need
    - Create multiple tokens with different scopes for different components
    - Use short TTLs for tokens with sensitive scopes
    - Avoid using `all:any` unless absolutely necessary

## ⏰ How long do JWT tokens last and how do I refresh them?

JWT tokens have a configurable time-to-live (TTL). The default TTL is 24 hours (86400 seconds), but you can specify a custom duration when generating a token.

### Token Expiration

```json
{
  "id": "w8pxz0a4Fwa4xgzyCvSeC",
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-11-22T08:45:00Z"
}
```

### Token Refresh Strategy

Since JWT tokens cannot be refreshed (they must be reissued), implement a proactive refresh strategy:

```python
import requests
from datetime import datetime, timedelta

class SMSGatewayClient:
    def __init__(self, gateway_url, username, password):
        self.gateway_url = gateway_url
        self.username = username
        self.password = password
        self.access_token = None
        self.token_expires_at = None
    
    def get_token(self, scopes, ttl=3600):
        """Get a new JWT token"""
        response = requests.post(
            f"{self.gateway_url}/3rdparty/v1/auth/token",
            auth=(self.username, self.password),
            headers={"Content-Type": "application/json"},
            json={"ttl": ttl, "scopes": scopes}
        )
        
        if response.status_code == 201:
            token_data = response.json()
            self.access_token = token_data["access_token"]
            self.token_expires_at = datetime.fromisoformat(
                token_data["expires_at"].replace("Z", "+00:00")
            )
            return self.access_token
        else:
            raise Exception(f"Failed to get token: {response.status_code}")
    
    def ensure_valid_token(self, scopes):
        """Ensure we have a valid token, refresh if needed"""
        if (self.access_token is None or
            self.token_expires_at is None or
            datetime.now() + timedelta(minutes=5) >= self.token_expires_at):
            return self.get_token(scopes)
        return self.access_token
```

!!! tip "Token Management Best Practices"
    - Refresh tokens 5-10 minutes before expiration
    - Implement exponential backoff for failed refresh attempts
    - Store tokens securely (not in client-side code)

## 🛡️ How do I revoke a JWT token?

JWT tokens can be revoked before they expire using the token revocation endpoint. This is useful when a token is compromised or no longer needed.

### Revoking a Token

```bash
curl -X DELETE "https://api.sms-gate.app/3rdparty/v1/auth/token/{jti}" \
  -H "Authorization: Basic username:password"
```

Where `{jti}` is the token ID from the token response.

## 🔐 "Invalid token" JWT Error

The "invalid token" error occurs when the JWT token is malformed, has an incorrect signature, or cannot be validated by the server.

### Common Causes

1. **Malformed Token**: The token structure is incorrect or corrupted
2. **Invalid Signature**: The token signature doesn't match the server's secret
3. **Algorithm Mismatch**: The token was signed with a different algorithm than expected
4. **Encoding Issues**: The token contains invalid characters or formatting

### Troubleshooting Steps

1. **Check Token Format**: Ensure the token has three parts separated by dots (`.`)
   ```
   header.payload.signature
   ```

2. **Verify Token Copy**: Make sure you copied the entire token without extra spaces or line breaks

3. **Validate Token Structure**: Use an online JWT decoder to verify the token structure
   ```bash
   # Check token structure
   echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." | tr '.' '\n'
   ```

## ⏰ "Token expired" JWT Error

The "token expired" error occurs when the JWT token has passed its expiration time. This is a normal part of the JWT lifecycle and requires token refresh.

### Common Causes

1. **Token TTL Expired**: The token has reached its expiration time
2. **Clock Skew**: Time differences between client and server clocks
3. **Long-running Operations**: Operations that take longer than the token TTL

### Troubleshooting Steps

1. **Check Expiration Time**: Parse the token to see when it expires
   ```python
   import jwt
   import datetime
   
   token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   try:
       decoded = jwt.decode(token, options={"verify_signature": False})
       exp_time = datetime.datetime.fromtimestamp(decoded['exp'])
       print(f"Token expires at: {exp_time}")
   except Exception as e:
       print(f"Error decoding token: {e}")
   ```

2. **Implement Token Refresh**: Refresh tokens before they expire
   ```python
   # Refresh token 5 minutes before expiration
   if datetime.now() + timedelta(minutes=5) >= token_expires_at:
       new_token = get_new_token()
   ```

3. **Adjust Token TTL**: Use a longer TTL for long-running operations
   ```json
   {
     "ttl": 7200,  // 2 hours instead of 1 hour
     "scopes": ["messages:send", "messages:read"]
   }
   ```

!!! tip "Best Practices"
    - Implement automatic token refresh
    - Use appropriate TTL values for your use case
    - Handle token expiration gracefully in your code
    - Consider clock skew in your expiration logic

## 🚫 "Token revoked" JWT Error

The "token revoked" error occurs when a JWT token has been manually revoked before its natural expiration time.

### Common Causes

1. **Manual Revocation**: Token was explicitly revoked by an administrator
2. **Security Incident**: Token was revoked due to a security concern

### Troubleshooting Steps

1. **Request New Token**: Generate a new token with the same scopes
   ```bash
   curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
     -u "username:password" \
     -H "Content-Type: application/json" \
     -d '{
       "ttl": 3600,
       "scopes": ["messages:send", "messages:read"]
     }'
   ```

2. **Investigate Revocation Reason**: Contact support to understand why the token was revoked

## 🙅 "Scope required" JWT Error

The "scope required" error occurs when the JWT token doesn't have the necessary scope to access a specific resource or perform a specific action.

### Common Causes

1. **Missing Scope**: The token doesn't include the required scope
2. **Incorrect Scope**: The token has the wrong scope for the requested action
3. **Scope Typos**: The scope name is misspelled or incorrectly formatted
4. **Resource Changes**: The required scope for a resource has changed

### Troubleshooting Steps

1. **Check Token Scopes**: Verify what scopes your token contains
   ```python
   import jwt
   
   token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   try:
       decoded = jwt.decode(token, options={"verify_signature": False})
       print("Token scopes:", decoded.get('scopes', []))
   except Exception as e:
       print(f"Error decoding token: {e}")
   ```

2. **Verify Required Scope**: Check the API documentation for the required scope
   ```
   GET /3rdparty/v1/messages requires: messages:list
   POST /3rdparty/v1/messages requires: messages:send
   ```

3. **Request New Token**: Generate a new token with the correct scopes
   ```json
   {
     "ttl": 3600,
     "scopes": [
       "messages:send",
       "messages:read",
       "devices:list"
     ]
   }
   ```

!!! tip "Scope Best Practices"
    - Request only the scopes you need
    - Use the exact scope names from the documentation
    - Create multiple tokens for different purposes
    - Regularly review and update your scope requirements

## 🔄 "Migration from Basic Auth to JWT" Issues

When migrating from Basic Authentication to JWT, you may encounter various issues. Here are common problems and their solutions.

### Common Issues

1. **Token Generation Errors**: Unable to generate JWT tokens
2. **Permission Errors**: JWT tokens don't have the same permissions as Basic Auth
3. **Code Compatibility**: Existing code doesn't work with JWT authentication

### Troubleshooting Steps

1. **Verify Token Generation**: Ensure you can generate JWT tokens successfully
   ```bash
   curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
     -u "username:password" \
     -H "Content-Type: application/json" \
     -d '{"ttl": 3600, "scopes": ["messages:send"]}'
   ```

2. **Update Code Gradually**: Migrate code incrementally rather than all at once
   ```python
   # Hybrid approach during migration
   def make_request(endpoint, data=None, use_jwt=True):
       if use_jwt and jwt_token:
           headers = {"Authorization": f"Bearer {jwt_token}"}
       else:
           # Fall back to Basic Auth
           headers = {}
           auth = (username, password)
       
       return requests.post(endpoint, headers=headers, auth=auth, json=data)
   ```

3. **Test in Staging**: Test JWT authentication in a staging environment before production

!!! tip "Migration Best Practices"
    - Keep Basic Auth as a fallback during transition
    - Monitor authentication errors during migration

## 🛡️ JWT Security Issues

JWT tokens are generally secure, but improper implementation can lead to security vulnerabilities.

### Common Security Issues

1. **Long TTLs**: Using excessively long token expiration times
2. **Token Leakage**: Tokens being exposed in logs, browser storage, or network traffic
3. **Insufficient Scopes**: Using overly broad scopes like `all:any`

### Troubleshooting Steps

1. **Review Token TTL**: Ensure your token TTL is appropriate for your use case
   ```json
   {
     "ttl": 3600,  // 1 hour - reasonable for most use cases
     "scopes": ["messages:send"]
   }
   ```

2. **Implement Secure Storage**: Ensure tokens are stored securely
   ```python
   # Example of secure token storage
   from cryptography.fernet import Fernet
   
   key = Fernet.generate_key()
   cipher_suite = Fernet(key)
   encrypted_token = cipher_suite.encrypt(jwt_token.encode())
   ```

!!! tip "Security Best Practices"
    - Use the shortest practical TTL for your use case
    - Store tokens securely on the server side
    - Implement proper token revocation
