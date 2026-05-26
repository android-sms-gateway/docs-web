# 📡 SMPP Server

## 📋 General

### Is there a public SMPP server hosted by SMSGate?

Yes. A public SMPP server is available at **`smpp.sms-gate.app:2775`** (plain) and **`smpp.sms-gate.app:2776`** (TLS). You can connect using your SMSGate credentials — no additional setup or registration required. See the [SMPP Server service page](../services/smpp-server.md) for details.

!!! info "Test Mode"
    The public SMPP server is currently in test mode. It runs a shared instance with default configuration.

### Does the public SMPP server support TLS?

Yes. Connect to port **2776** for SMPP over TLS. The certificate is issued via Let's Encrypt, so standard TLS trust applies — no custom CA needed.

### What is SMPP?

SMPP (Short Message Peer-to-Peer) is a telecommunications industry protocol used for exchanging SMS messages between external messaging entities (ESME) and Short Message Service Centers (SMSC). It is widely used by SMS aggregators, messaging platforms, and enterprise communication systems.

### When should I use SMPP vs the REST API?

Use **SMPP** when:

- You have existing SMPP-based infrastructure or SMS aggregator integrations
- You need to work with telecom-grade messaging platforms
- Your organization requires SMPP protocol compliance
- You want standardized session management with bind/unbind lifecycle

Use the **[REST API](../integration/api.md)** when:

- You are building a new integration from scratch
- You need access to all SMSGate features (MMS, data SMS, scheduling, etc.)
- You prefer HTTP-based integrations with JSON payloads
- You want simpler setup without SMPP protocol overhead

### Is the SMPP Server part of the main SMSGate project?

No. The SMPP Server is a **separate standalone service** ([GitHub Repository](https://github.com/android-sms-gateway/smpp-server)) that communicates with the SMSGate via its REST API. It does not share a database and can be deployed independently.

## 🔧 Troubleshooting

### I can't connect to the SMPP Server

Check the following:

1. **Bind address**: By default, the server binds to `127.0.0.1:2775`. For remote access, set `SMPP__BIND_ADDRESS=0.0.0.0:2775`
2. **Firewall**: Ensure port 2775 (or 2776 for TLS) is open and accessible
3. **Docker port mapping**: If using Docker, verify `-p 2775:2775` is set correctly

### Authentication fails on BIND

- Verify your SMSGate **username** and **password** are correct
- Ensure your SMSGate account is active
- Check that the `GATEWAY__API_BASE_URL` points to the correct SMSGate instance
- For Docker deployments, verify network connectivity between the SMPP Server and the Gateway API

### Delivery receipts are not working

- The `GATEWAY__WEBHOOK_BASE_URL` **must** be publicly accessible
- Check that your SMPP Server is reachable from the SMSGate app on the device
- Note: DELIVER_SM forwarding to the ESME client is currently **work in progress**

### TLS/SMPPs connection fails

- Verify both `SMPP__TLS_CERT` and `SMPP__TLS_KEY` are set to valid file paths
- Ensure the certificate and key files are accessible to the SMPP Server process
- The SMPPs listener runs on port **2776**, not 2775
- For Docker, mount the certificate files as volumes: `-v /path/to/certs:/certs:ro`

## ⚙️ Technical

### What TON/NPI values should I use?

The default configuration uses:

| Parameter    | Default Value | Meaning                     |
| ------------ | ------------- | --------------------------- |
| `source_ton` | `0x01`        | International               |
| `source_npi` | `0x01`        | E.164 (ISDN numbering plan) |
| `dest_ton`   | `0x01`        | International               |
| `dest_npi`   | `0x01`        | E.164 (ISDN numbering plan) |

### What SMPP protocol version is supported?

The SMPP Server implements **SMPP v3.4** using the [go-smpp](https://github.com/fiorix/go-smpp) library.

### Can I run multiple SMPP Server instances?

Yes. Each SMPP Server instance is stateless and connects to the same SMSGate API. You can run multiple instances behind a load balancer for high availability.

### Does the SMPP Server support rate limiting?

Rate limiting is **not currently implemented**. If you need rate limiting, configure it at the network level (e.g., reverse proxy, firewall rules) or in your SMPP client.

### What happens on UNBIND?

When a client sends an UNBIND PDU (or disconnects):

1. The session state is transitioned back to Open
2. Any registered webhook for that session is deregistered from the SMS Gateway
3. The connection is closed gracefully

## 📚 See Also

- [SMPP Server Documentation](../services/smpp-server.md)
- [SMPP Protocol Integration](../integration/smpp.md)
- [SMSGate API Reference](../integration/api.md)
