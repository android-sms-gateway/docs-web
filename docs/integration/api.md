# Integration - API 📱

The SMSGate provides a robust API that allows you to send SMS messages programmatically from your own applications or services. This enables seamless integration with your existing infrastructure.

## 🌐 One API across modes

All SMSGate modes use the **same API and request format**. Only the base URL and the capabilities available on the gateway device differ, so switching modes is transparent for clients that configure their base URL.

| Mode                   | API base URL                              | Notes                                                                            |
| ---------------------- | ----------------------------------------- | -------------------------------------------------------------------------------- |
| Public Cloud           | `https://api.sms-gate.app/3rdparty/v1`    | Managed cloud server                                                             |
| Private Server         | `https://your-domain.com/api/3rdparty/v1` | Self-hosted server                                                               |
| Local Server (Android) | `http://<device_ip>:8080`                 | Local network only; see [Local Server](../getting-started/local-server.md)       |
| AT Gateway             | `http://<host>:3000/api/v1`               | Serial AT modem; SMS and DATA_SMS only; see [AT Gateway](../at-gateway/index.md) |

!!! note "Capabilities differ"
    Base URLs and capabilities are mode-specific — for example, AT Gateway does not support MMS. Mode differences belong on the mode's own page; the common contract is documented here.

## API Specification 📄

You can find the OpenAPI specification for our API at the following link: [OpenAPI Specification](https://capcom6.github.io/android-sms-gateway/). This specification includes detailed information about the available endpoints, request/response structure, and more.

!!! tip "End-to-End Encryption"
    The device listing (`GET /3rdparty/v1/devices`) includes `publicKey` (base64 X.509 SPKI DER of the RSA-2048 public key) and `keyVersion` (device-sourced rotation version) for devices with E2E encryption enabled. Send `deviceId` to target a specific device and encrypt messages for it. See the [encryption guide](../privacy/encryption.md) for the wire format, key rotation, and migration details. The API server is the trusted distributor of device keys: on first use, verify the device key fingerprint out of band and pin it (see [Trust model and key verification](../privacy/encryption.md#trust-model-and-key-verification)).

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

!!! note "AT Gateway"
    AT Gateway supports only HTTP Basic Authentication — JWT is not available in that mode. See [AT Gateway](../at-gateway/index.md).

### Authentication Comparison

| Feature          | JWT Authentication                 | Basic Authentication                        |
| ---------------- | ---------------------------------- | ------------------------------------------- |
| Security         | High (token-based with expiration) | Medium (credentials sent with each request) |
| Access Control   | Fine-grained (scopes)              | Coarse-grained (all or nothing)             |
| Token Management | Built-in (revocation, TTL)         | None                                        |
| Recommended For  | All new integrations               | Legacy systems only                         |

## See Also 🔗

- [Authentication Guide](authentication.md) - Detailed information about JWT authentication
- [Web Dashboard](../services/web-dashboard.md) - Graphical management interface
- [Integration Guide](index.md) - Overview of integration options
- [Client Libraries](client-libraries.md) - Pre-built libraries for various languages
