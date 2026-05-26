---
title: "Introducing SMPP Server: Telecom-Grade SMS Integration for SMSGate"
date: 2026-05-20
categories:
  - Integration
  - SMPP
  - Infrastructure
description: "Learn about the new SMPP Server for SMS Gateway — a standalone SMPP v3.4 service that bridges telecom-grade messaging platforms with Android devices."
author: SMSGate Team LLM / Big Pickle
---

# 📡 Introducing SMPP Server: Telecom-Grade SMS Integration for SMSGate

We're excited to announce the **SMPP Server** — a new standalone service that brings SMPP v3.4 protocol support to the SMSGate ecosystem. This enables SMS aggregators, messaging platforms, and any SMPP-compatible client to send and receive SMS messages through Android devices running the SMS Gateway app.

<!-- more -->

## 🎯 Why SMPP?

SMPP (Short Message Peer-to-Peer) is the telecommunications industry standard for exchanging SMS messages. It has been the backbone of enterprise messaging for decades, used by:

- **SMS aggregators** connecting to multiple carriers
- **Messaging platforms** managing high-volume throughput
- **Enterprise systems** requiring standardized telecom integration
- **Legacy infrastructure** built around SMPP protocol

Until now, integrating with SMSGate required using the REST API. While the REST API is powerful and flexible, many organizations already have SMPP-based systems in place. The SMPP Server bridges this gap.

## 🏗️ How It Works

The SMPP Server acts as a translator between the SMPP protocol and the SMS Gateway REST API:

```
SMS Aggregator (ESME Client)
         │
         │ SMPP v3.4 (port 2775/2776)
         ▼
   [SMPP Server]  ← Standalone Go service
         │
         │ HTTP REST API
         ▼
   [SMS Gateway REST API]
         │
         ▼
   [Android Devices]
```

When an SMPP client connects and authenticates using its SMS Gateway credentials:

1. The SMPP Server validates credentials via the Gateway API (Basic Auth → JWT)
2. For receiver/transceiver sessions, a dynamic webhook is registered for delivery receipts
3. `SUBMIT_SM` PDUs are translated into HTTP API calls to send SMS
4. `QUERY_SM` PDUs check message status through the Gateway API
5. Delivery status updates arrive via webhooks (DELIVER_SM forwarding coming soon)

## ✨ Key Features

- **Full SMPP v3.4 support** — BIND, SUBMIT_SM, QUERY_SM, UNBIND, ENQUIRE_LINK
- **Session management** — Thread-safe state machine with TX/RX/TRX bind types
- **TLS encryption** — SMPPs support on port 2776
- **Dynamic webhooks** — Automatic webhook registration per session for delivery receipts
- **Error mapping** — Comprehensive HTTP-to-SMPP error code translation (36+ codes)
- **Standalone deployment** — No shared database, deploy anywhere with network access to the Gateway API

## 🚀 Getting Started

The SMPP Server is available as pre-built binaries, Docker images, or can be built from source:

```bash title="Quick Start with Docker"
docker run \
  -p 2775:2775 \
  -e SMPP__BIND_ADDRESS=0.0.0.0:2775 \
  -e GATEWAY__API_BASE_URL=https://api.sms-gate.app/3rdparty/v1 \
  -e GATEWAY__WEBHOOK_BASE_URL=https://your-public-url \
  ghcr.io/android-sms-gateway/smpp-server:latest
```

Connect your SMPP client to `localhost:2775` using your SMS Gateway username and password as the `system_id` and `password` in the BIND PDU.

## 📖 Documentation

Comprehensive documentation is available in the docs:

- **[SMPP Server Guide](../../services/smpp-server.md)** — Installation, configuration, deployment
- **[SMPP Protocol Integration](../../integration/smpp.md)** — Protocol details, parameter mapping, error codes
- **[SMPP FAQ](../../faq/smpp-server.md)** — Troubleshooting and technical questions

## 🔮 What's Next

The SMPP Server is actively developed. Here's what's on the roadmap:

- ✅ SMPP v3.4 protocol support
- ✅ TLS/SMPPs support
- ✅ Dynamic webhook registration
- 🔄 DELIVER_SM delivery receipt forwarding (in progress)
- 📋 Prometheus metrics
- 🔧 Rate limiting per client
- 📨 Multi-part SMS concatenation
- 🔤 UCS2/binary message support

## 💬 Feedback

We'd love to hear your feedback! If you encounter any issues or have feature requests, please open an issue on the [SMPP Server GitHub repository](https://github.com/android-sms-gateway/smpp-server).
