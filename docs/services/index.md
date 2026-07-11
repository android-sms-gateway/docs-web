# ⚙️ Services

Standalone companion services that extend the SMSGate beyond its core REST API. Each service runs independently and connects to the SMSGate API to provide additional integration options.

<div class="grid cards" markdown>

- **📧 [Email to SMS Bridge](./email-to-sms.md)**
    Send SMS by emailing `{phone}@smtp.sms-gate.app` — no API integration required. Ideal for monitoring tools, booking platforms, and any email-capable system.

- **🚀 [Twilio Fallback Service](./twilio-fallback.md)**
    Automatic fallback for failed Twilio messages. Resends delivery failures via the SMSGate API with zero changes to existing Twilio-based code.

- **📡 [SMPP Server](./smpp-server.md)**
    SMPP v3.4 protocol bridge for SMS aggregators and telecom-grade platforms. Translates SMPP operations into SMSGate REST API calls.

- **🔐 [Certificate Authority](./ca.md)**
    Project CA for generating SSL certificates for private IPs. Enables HTTPS encryption for private server and webhook endpoints.

</div>

## 📚 See Also

- [Integration Overview](../integration/index.md) — core API and protocol integrations
- [Getting Started](../getting-started/index.md) — deployment modes and initial setup
- [Private Server](../features/private-server.md) — self-hosted infrastructure with certificate requirements
