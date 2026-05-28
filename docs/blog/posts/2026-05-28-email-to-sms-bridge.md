---
title: "Email to SMS Bridge: Send SMS from Any Email System"
date: 2026-05-28
categories:
  - Integration
  - Infrastructure
description: "Introducing the Email to SMS Bridge — a standalone SMTP service that converts emails into SMS messages, enabling any email-capable system to send texts through SMSGate without API changes."
author: SMSGate Team LLM / Big Pickle
---

# 📧 Email to SMS Bridge: Send SMS from Any Email System

We're excited to announce the **Email to SMS Bridge** — a new standalone service that acts as an SMTP server, receiving emails and forwarding their content as SMS messages via the SMSGate API. If your system can send email, it can now send SMS.

<!-- more -->

## 🎯 Why Email to SMS?

Thousands of existing business systems support email notifications but lack native SMS integration:

- **Booking and appointment platforms** that email confirmations
- **Monitoring and alerting tools** (Nagios, Grafana, Zabbix)
- **CRM and ERP systems** with email-based notifications
- **Legacy applications** built around SMTP infrastructure

Until now, integrating these systems with SMSGate required REST API changes. The Email to SMS Bridge eliminates that barrier — no API code, no SDK, just configure your system to send an email.

## 🏗️ How It Works

The bridge runs as a standalone SMTP server. Email systems send messages to `{phone}@your-domain`, and the bridge forwards them as SMS:

```
Notification System
         │
         │ SMTP (AUTH PLAIN)
         ▼
   [Email to SMS Bridge]  ← Standalone Go service
         │
         │ HTTP REST API (smsgate credentials)
         ▼
   [SMSGate 3rd-party API]
         │
         ▼
   [Android Devices]
```

### Email Format

```
To:   +1234567890@sms-gateway.local   ← phone @ domain
Body: Your verification code is 1234   ← SMS content
Auth: SMSGate username / password      ← AUTH PLAIN
```

## ✨ Key Features

- **Drop-in SMTP integration** — any email-capable system works without code changes
- **AUTH PLAIN pass-through** — SMTP credentials forwarded to SMSGate for per-user auth
- **Domain validation** — only emails to your configured domain are accepted
- **STARTTLS support** — encrypt SMTP connections with TLS certificates
- **Prometheus metrics** — monitor emails received, SMS sent, failures, and auth failures
- **Multi-arch Docker images** — linux/amd64 and linux/arm64
- **Standalone deployment** — binary, Docker, or build from source

## 🚀 Getting Started

The Email to SMS Bridge is available as pre-built binaries, Docker images, or can be built from source:

```bash title="Quick Start with Docker"
docker run \
  -e SMTP__DOMAIN=sms-gateway.local \
  -e SMTP__PORT=2525 \
  -p 2525:2525 \
  -p 3000:3000 \
  ghcr.io/android-sms-gateway/email-to-sms:latest
```

Send a test email:

```bash
curl --url 'smtp://localhost:2525' \
  --mail-from 'alerts@example.com' \
  --mail-rcpt '+1234567890@sms-gateway.local' \
  --user 'your-username:your-password' \
  --upload-file - <<EOF
Subject: Test
Your verification code is 1234
EOF
```

## 📖 Documentation

Comprehensive documentation is available in the docs:

- **[Email to SMS Bridge Guide](../../services/email-to-sms.md)** — Installation, configuration, deployment
- **[SMSGate API Reference](../../integration/api.md)** — REST API documentation
- **[Authentication Guide](../../integration/authentication.md)** — Credential management

## 💬 Feedback

We'd love to hear your feedback! If you encounter any issues or have feature requests, please open an issue on the [Email to SMS GitHub repository](https://github.com/android-sms-gateway/email-to-sms).
