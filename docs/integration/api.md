# Integration - API 📱

The SMSGate provides a robust API that allows you to send SMS messages programmatically from your own applications or services. This enables seamless integration with your existing infrastructure.

## API Specification 📄

You can find the OpenAPI specification for our API at the following link: [OpenAPI Specification](https://capcom6.github.io/android-sms-gateway/). This specification includes detailed information about the available endpoints, request/response structure, and more.

!!! note "Local vs Cloud API Access"
    While both API endpoints use the same authentication method and request format, there are critical differences in accessibility:
    
    - **Local Server API**: Only accessible within your local network (same Wi-Fi/Ethernet)
    - **Cloud API**: Accessible from anywhere on the internet
    
    External services like Google Apps Script, AWS Lambda, or other cloud functions **cannot** directly access Local Server API endpoints due to network constraints.

## Authentication 🔒

The SMSGate API supports two authentication methods:

1. **Basic Authentication** (Legacy): Simple username/password authentication for backward compatibility
2. **JWT Bearer Tokens** (Recommended): Modern, secure authentication with fine-grained access control

!!! tip "Recommendation"
    For new integrations, we strongly recommend using JWT authentication as it provides better security, scalability, and fine-grained access control through scopes. See [Authentication Guide](authentication.md) for detailed information.

### Authentication Comparison

| Feature          | JWT Authentication                 | Basic Authentication                        |
| ---------------- | ---------------------------------- | ------------------------------------------- |
| Security         | High (token-based with expiration) | Medium (credentials sent with each request) |
| Access Control   | Fine-grained (scopes)              | Coarse-grained (all or nothing)             |
| Token Management | Built-in (revocation, TTL)         | None                                        |
| Recommended For  | All new integrations               | Legacy systems only                         |

## See Also 🔗

- [Authentication Guide](authentication.md) - Detailed information about JWT authentication
- [Integration Guide](index.md) - Overview of integration options
- [Client Libraries](client-libraries.md) - Pre-built libraries for various languages
