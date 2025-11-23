# Integration - Authentication 🔒

This guide provides a comprehensive overview of authentication in the SMSGate API. JWT authentication is the primary mechanism for securing API access, providing a robust and scalable way to authenticate requests.

## Authentication Overview 🔑

The SMSGate supports multiple authentication methods to accommodate different use cases:

- **Basic Authentication**: Legacy username/password for backward compatibility
- **JWT Bearer Tokens**: Primary authentication mechanism with configurable TTL

JWT authentication is recommended for all new integrations as it provides better security, scalability, and fine-grained access control through scopes.

## JWT Authentication 🔐

JWT authentication uses bearer tokens to authenticate API requests. These tokens contain encoded information about the user, their permissions (scopes), and token metadata.

## Token Generation 🚀

To generate a JWT token, make a POST request to the token endpoint using Basic Authentication.

### Endpoint

```
POST /3rdparty/v1/auth/token
```

### Request

```bash
curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{
    "ttl": 3600,
    "scopes": [
      "messages:send",
      "messages:read",
      "devices:list"
    ]
  }'
```

### Request Parameters

| Parameter | Type    | Required | Description                                               |
| --------- | ------- | -------- | --------------------------------------------------------- |
| `ttl`     | integer | No       | Token time-to-live in seconds (default: server dependent) |
| `scopes`  | array   | Yes      | List of scopes for the token                              |

### Response

```json
{
  "id": "w8pxz0a4Fwa4xgzyCvSeC",
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-11-22T08:45:00Z"
}
```

### Response Fields

| Field          | Type   | Description                               |
| -------------- | ------ | ----------------------------------------- |
| `id`           | string | Token identifier (JTI)                    |
| `token_type`   | string | Token type (always "Bearer")              |
| `access_token` | string | The JWT token                             |
| `expires_at`   | string | ISO 8601 timestamp when the token expires |

## Using JWT Tokens 📝

Once you have a JWT token, include it in the Authorization header of your API requests.

### Authorization Header Format

```
Authorization: Bearer <your-jwt-token>
```

### Example Request

```bash
curl -X GET "https://api.sms-gate.app/3rdparty/v1/messages" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Token Management 🔄

### Revoking Tokens

To revoke a token before it expires, make a DELETE request to the token endpoint.

```
DELETE /3rdparty/v1/auth/token/{jti}
```

```bash
curl -X DELETE "https://api.sms-gate.app/3rdparty/v1/auth/token/w8pxz0a4Fwa4xgzyCvSeC" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Token Best Practices

- **Use short TTLs**: Set appropriate expiration times based on your security requirements
- **Request minimal scopes**: Only request the scopes your application needs
- **Store tokens securely**: Keep tokens in secure storage, not in client-side code
- **Implement token rotation**: Refresh tokens before they expire for long-running applications
- **Revoke unused tokens**: Immediately revoke tokens that are no longer needed

## JWT Scopes 🔍

Scopes define the permissions associated with a JWT token, implementing the principle of least privilege.

### Scope Structure

All scopes follow the pattern: `resource:action`

- **Resource**: The entity being accessed (e.g., `messages`, `devices`)
- **Action**: The operation being performed (e.g., `send`, `read`, `write`)

### Available Scopes

#### Global Scope

| Scope     | Description                                          | Access Level |
| --------- | ---------------------------------------------------- | ------------ |
| `all:any` | Provides full access to all resources and operations | Full Access  |

#### Messages Scopes

| Scope           | Description                                   | Access Level |
| --------------- | --------------------------------------------- | ------------ |
| `messages:send` | Permission to send SMS messages               | Write        |
| `messages:read` | Permission to read individual message details | Read         |
| `messages:list` | Permission to list and view messages          | Read         |

#### Devices Scopes

| Scope            | Description                                    | Access Level |
| ---------------- | ---------------------------------------------- | ------------ |
| `devices:list`   | Permission to list and view registered devices | Read         |
| `devices:delete` | Permission to remove/unregister devices        | Delete       |

#### Webhooks Scopes

| Scope             | Description                                            | Access Level |
| ----------------- | ------------------------------------------------------ | ------------ |
| `webhooks:list`   | Permission to list and view webhook configurations     | Read         |
| `webhooks:write`  | Permission to create and modify webhook configurations | Write        |
| `webhooks:delete` | Permission to remove webhook configurations            | Delete       |

#### Settings Scopes

| Scope            | Description                                   | Access Level |
| ---------------- | --------------------------------------------- | ------------ |
| `settings:read`  | Permission to read system and user settings   | Read         |
| `settings:write` | Permission to modify system and user settings | Write        |

#### Logs Scopes

| Scope       | Description                                    | Access Level |
| ----------- | ---------------------------------------------- | ------------ |
| `logs:read` | Permission to read system and application logs | Read         |

#### Token Management Scopes

| Scope           | Description                                  | Access Level   |
| --------------- | -------------------------------------------- | -------------- |
| `tokens:manage` | Permission to generate and revoke JWT tokens | Administrative |

### Scope Assignment by Endpoint

#### Messages API

| Endpoint                             | Method | Required Scope    | Description         |
| ------------------------------------ | ------ | ----------------- | ------------------- |
| `/3rdparty/v1/messages`              | GET    | `messages:list`   | List messages       |
| `/3rdparty/v1/messages`              | POST   | `messages:send`   | Send a new message  |
| `/3rdparty/v1/messages/:id`          | GET    | `messages:read`   | Get message details |
| `/3rdparty/v1/messages/inbox/export` | POST   | `messages:export` | Export messages     |

#### Devices API

| Endpoint                   | Method | Required Scope   | Description   |
| -------------------------- | ------ | ---------------- | ------------- |
| `/3rdparty/v1/devices`     | GET    | `devices:list`   | List devices  |
| `/3rdparty/v1/devices/:id` | DELETE | `devices:delete` | Remove device |

#### Webhooks API

| Endpoint                    | Method | Required Scope    | Description    |
| --------------------------- | ------ | ----------------- | -------------- |
| `/3rdparty/v1/webhooks`     | GET    | `webhooks:list`   | List webhooks  |
| `/3rdparty/v1/webhooks`     | POST   | `webhooks:write`  | Create webhook |
| `/3rdparty/v1/webhooks/:id` | DELETE | `webhooks:delete` | Remove webhook |

#### Settings API

| Endpoint                | Method | Required Scope   | Description      |
| ----------------------- | ------ | ---------------- | ---------------- |
| `/3rdparty/v1/settings` | GET    | `settings:read`  | Get settings     |
| `/3rdparty/v1/settings` | PATCH  | `settings:write` | Update settings  |
| `/3rdparty/v1/settings` | PUT    | `settings:write` | Replace settings |

#### Logs API

| Endpoint            | Method | Required Scope | Description |
| ------------------- | ------ | -------------- | ----------- |
| `/3rdparty/v1/logs` | GET    | `logs:read`    | Read logs   |

#### Token Management API

| Endpoint                       | Method | Required Scope  | Description        |
| ------------------------------ | ------ | --------------- | ------------------ |
| `/3rdparty/v1/auth/token`      | POST   | `tokens:manage` | Generate new token |
| `/3rdparty/v1/auth/token/:jti` | DELETE | `tokens:manage` | Revoke token       |

## Code Examples 💻

=== "cURL"

    ```bash title="Generate JWT Token"
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/auth/token" \
      -u "username:password" \
      -H "Content-Type: application/json" \
      -d '{
        "ttl": 3600,
        "scopes": ["messages:send", "messages:read"]
      }'
    ```

    ```bash title="Use JWT Token"
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages" \
      -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
      -H "Content-Type: application/json" \
      -d '{
        "phoneNumbers": ["+1234567890"],
        "textMessage": {
          "text": "Hello from JWT!"
        }
      }'
    ```

=== "Python"

    ```python title="Generate JWT Token"
    import requests
    import json

    # Configuration
    gateway_url = "https://api.sms-gate.app"
    username = "your_username"
    password = "your_password"

    # Generate token
    response = requests.post(
        f"{gateway_url}/3rdparty/v1/auth/token",
        auth=(username, password),
        headers={"Content-Type": "application/json"},
        data=json.dumps({
            "ttl": 3600,
            "scopes": ["messages:send", "messages:read"]
        })
    )

    if response.status_code == 201:
        token_data = response.json()
        access_token = token_data["access_token"]
        print(f"Token generated successfully. Expires at: {token_data['expires_at']}")
    else:
        print(f"Error generating token: {response.status_code} - {response.text}")
    ```

    ```python title="Send SMS with JWT"
    import requests
    import json

    # Configuration
    gateway_url = "https://api.sms-gate.app"
    access_token = "your_jwt_token"

    # Send message
    response = requests.post(
        f"{gateway_url}/3rdparty/v1/messages",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        data=json.dumps({
            "phoneNumbers": ["+1234567890"],
            "textMessage": {"text": "Hello from JWT!"}
        })
    )

    if response.status_code == 202:
        print("Message sent successfully!")
    else:
        print(f"Error sending message: {response.status_code} - {response.text}")
    ```

=== "JavaScript"

    ```javascript title="Generate JWT Token"
    // Configuration
    const gatewayUrl = "https://api.sms-gate.app";
    const username = "your_username";
    const password = "your_password";

    // Generate token
    fetch(`${gatewayUrl}/3rdparty/v1/auth/token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ' + btoa(`${username}:${password}`)
      },
      body: JSON.stringify({
        ttl: 3600,
        scopes: ["messages:send", "messages:read"]
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.access_token) {
        console.log('Token generated successfully. Expires at:', data.expires_at);
      } else {
        console.error('Error generating token:', data);
      }
    })
    .catch(error => console.error('Error:', error));
    ```

    ```javascript title="Send SMS with JWT"
    // Configuration
    const gatewayUrl = "https://api.sms-gate.app";
    const accessToken = "your_jwt_token";

    // Send message
    fetch(`${gatewayUrl}/3rdparty/v1/messages`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        phoneNumbers: ["+1234567890"],
        textMessage: {text: "Hello from JWT!"}
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.id) {
        console.log('Message sent successfully!');
      } else {
        console.error('Error sending message:', data);
      }
    })
    .catch(error => console.error('Error:', error));
    ```

## Migration from Basic Auth to JWT 🔄

### Why Migrate?

- **Enhanced Security**: JWT tokens provide better security than Basic Auth
- **Fine-grained Access Control**: Scopes allow precise permission management

### Migration Steps

1. **Generate JWT Tokens**: Use the token endpoint to create JWT tokens with appropriate scopes
2. **Update Client Code**: Replace Basic Auth with JWT Bearer tokens
3. **Implement Token Management**: Add token refresh and error handling
4. **Test Thoroughly**: Ensure all functionality works with JWT authentication

### Migration Example

=== "Before (Basic Auth)"

    ```python
    # Basic Auth example
    response = requests.post(
        "https://api.sms-gate.app/3rdparty/v1/messages",
        auth=("username", "password"),
        json={
            "phoneNumbers": ["+1234567890"],
            "textMessage": {"text": "Hello world!"}
        }
    )
    ```

=== "After (JWT)"

    ```python
    # JWT authentication example
    # First, get a token
    token_response = requests.post(
        "https://api.sms-gate.app/3rdparty/v1/auth/token",
        auth=("username", "password"),
        json={
            "ttl": 3600,
            "scopes": ["messages:send"]
        }
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
            json={
                "phoneNumbers": ["+1234567890"],
                "textMessage": {"text": "Hello world!"}
            }
        )
    ```

## Error Handling ⚠️

### Error Handling Best Practices

1. **Check Token Expiration**: Implement token refresh before expiration
2. **Handle 401 Errors**: Re-authenticate and get a new token
3. **Handle 403 Errors**: Verify your token has the required scopes
4. **Log Errors**: Record authentication errors for debugging

### Error Handling Example (Python)

```python
import requests
import time
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
            # Parse expiration time
            self.token_expires_at = datetime.fromisoformat(
                token_data["expires_at"].replace("Z", "+00:00")
            )
            return self.access_token
        else:
            raise Exception(f"Failed to get token: {response.status_code} - {response.text}")
    
    def ensure_valid_token(self, scopes):
        """Ensure we have a valid token, refresh if needed"""
        if (self.access_token is None or 
            self.token_expires_at is None or 
            datetime.now() + timedelta(minutes=5) >= self.token_expires_at):
            self.get_token(scopes)
        return self.access_token
    
    def send_message(self, recipient, message):
        """Send a message with automatic token handling"""
        try:
            token = self.ensure_valid_token(["messages:send"])
            
            response = requests.post(
                f"{self.gateway_url}/3rdparty/v1/messages",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                },
                json={"recipient": recipient, "textMessage": {"text": message}}
            )
            
            if response.status_code == 401:
                # Token might be expired or invalid, try once more
                token = self.get_token(["messages:send"])
                response = requests.post(
                    f"{self.gateway_url}/3rdparty/v1/messages",
                    headers={
                        "Authorization": f"Bearer {token}",
                        "Content-Type": "application/json"
                    },
                    json={"recipient": recipient, "textMessage": {"text": message}}
                )
            
            if response.status_code == 202:
                return response.json()
            else:
                raise Exception(f"Failed to send message: {response.status_code} - {response.text}")
        
        except Exception as e:
            print(f"Error sending message: {str(e)}")
            raise

# Usage example
client = SMSGatewayClient("https://api.sms-gate.app", "username", "password")
result = client.send_message("+1234567890", "Hello from JWT!")
print("Message sent:", result)
```

## Security Considerations 🔒

### Token Security

- **Keep Tokens Secret**: Treat JWT tokens like passwords
- **Use HTTPS**: Always transmit tokens over encrypted connections
- **Short Expiration**: Use the shortest practical TTL for your use case
- **Scope Limitation**: Request only the scopes you need
- **Secure Storage**: Store tokens securely on the server side, not in client-side code
- **Revocation**: Implement token revocation for compromised tokens

### Client Security

- **Validate Tokens**: Always validate server responses
- **Error Handling**: Implement proper error handling for authentication failures
- **Token Storage**: Store tokens securely (e.g., HttpOnly cookies, secure server-side storage)
- **CSRF Protection**: Implement CSRF protection for web applications

## See Also 🔗

- [API Reference](api.md) - Complete API endpoint documentation
- [Integration Guide](index.md) - Overview of integration options
- [Client Libraries](client-libraries.md) - Pre-built libraries for various languages
- [Authentication FAQ](../faq/authentication.md) - Frequently Asked Questions about JWT authentication
