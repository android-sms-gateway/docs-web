# 📧 Email to SMS Bridge

## 📋 General

### Is there a public Email to SMS server hosted by SMSGate?

Yes. A public SMTP server is available at **`smtp.sms-gate.app:587`** (plain) and **`smtp.sms-gate.app:465`** (TLS). You can connect using your SMSGate credentials — no additional setup or registration required. See the [Email to SMS Bridge service page](../services/email-to-sms.md) for details.

!!! info "Test Mode"
    The public Email to SMS server is currently in test mode. It runs a shared instance with default configuration.

### Does the public server support TLS?

Yes. Connect to port **465** for SMTPS with TLS. The certificate is issued via Let's Encrypt, so standard TLS trust applies — no custom CA needed.

### What email format should I use?

Send emails to `{phone}@smtp.sms-gate.app` where `{phone}` is the recipient's phone number in international format (e.g., `+1234567890`). The email body becomes the SMS message content. The subject line is ignored.

### When should I use SMTP vs the REST API?

Use **SMTP** when:

- You have existing email-based notification systems (monitoring tools, booking platforms, CRMs)
- You want to add SMS delivery without API code changes
- Your system can send email but can't make HTTP API calls

Use the **[REST API](../integration/api.md)** when:

- You are building a new integration from scratch
- You need advanced features (MMS, data SMS, message scheduling, delivery receipts)
- You want direct control over message parameters

### What's the difference between SMTP and SMPP?

- **SMTP** is for email-based systems — any tool that can send email can use it. No protocol knowledge needed.
- **[SMPP](./smpp-server.md)** is a telecom industry protocol for high-throughput SMS messaging, used by SMS aggregators and carrier-grade platforms.

### Is the Email to SMS Bridge part of the main SMSGate project?

The bridge is a **separate standalone service** ([GitHub Repository](https://github.com/android-sms-gateway/email-to-sms)) that communicates with the SMSGate via its REST API. It does not share a database and can be deployed independently.

## 🔧 Troubleshooting

### I can't connect to the SMTP server

Check the following:

1. **Port**: Use port 587 for plain SMTP or 465 for TLS
2. **Firewall**: Ensure outbound port 587 (or 465) is open
3. **Hostname**: Verify you're connecting to `smtp.sms-gate.app`
4. **TLS**: On port 465, SSL/TLS is required from the first handshake. STARTTLS is not supported.

### Authentication fails

- Verify your SMSGate **username** and **password** are correct
- Ensure your SMSGate account is active and has at least one connected device
- Use `AUTH PLAIN` — the bridge does not support `AUTH LOGIN` or `AUTH CRAM-MD5`
- For TLS port 465, authentication happens after the TLS handshake

### My email was accepted but no SMS was delivered

- The bridge returns a 250 response as soon as the SMSGate API accepts the message
- Check that the recipient phone number is in international format (e.g., `+1234567890`)
- Verify your Android device is online and connected to the SMSGate
- Check the [Prometheus metrics](../services/email-to-sms.md#monitoring) on a self-hosted instance to see failure counts

### Message body is empty

The bridge requires a non-empty email body. If your system sends emails with only a subject line and no body, the message will be rejected with SMTP code 550.

## ⚙️ Technical

### What email parts are included in the SMS?

Only the plain text body of the email is used. HTML content, attachments, and the subject line are ignored.

### Is there rate limiting on the public server?

The public instance has shared rate limits. If you need guaranteed throughput, [self-host the bridge](../services/email-to-sms.md#deployment) on your own infrastructure.

### Can I run multiple Email to SMS Bridge instances?

Yes. Each instance is stateless and connects to the same SMSGate API. You can run multiple instances behind a load balancer for high availability.

### Does the bridge support message delivery receipts?

No. The bridge returns SMTP code 250 as soon as the SMSGate API accepts the message. For delivery receipt tracking, use the [REST API](../integration/api.md) directly.

### What happens if the SMSGate API is down?

The bridge returns SMTP code 451 (timeout) or 550 (server error) to the sending client. The client's email system is responsible for retrying.

## 📚 See Also

- [Email to SMS Bridge Documentation](../services/email-to-sms.md)
- [SMTP Integration Guide](../integration/smtp.md)
- [SMSGate API Reference](../integration/api.md)
