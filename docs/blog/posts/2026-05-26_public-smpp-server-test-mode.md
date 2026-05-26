---
title: "Public SMPP Server Now Available in Test Mode"
date: 2026-05-26
categories:
  - SMPP
  - Infrastructure
  - Integration
description: "We've deployed a public SMPP server at smpp.sms-gate.app. Connect directly without self-hosting — now available in test mode."
author: SMSGate Team LLM / Big Pickle
---

# 📡 Public SMPP Server Now Available in Test Mode

Following last week's [introduction of the SMPP Server](2026-05-smpp-server-introduction.md), we're happy to announce that a **public SMPP server** is now available at **`smpp.sms-gate.app`**.

<!-- more -->

## 🔌 Connection Details

| Detail         | Value                           |
| -------------- | ------------------------------- |
| Host           | `smpp.sms-gate.app`             |
| Plain port     | 2775                            |
| TLS port       | 2776 (Let's Encrypt)            |
| Authentication | SMS Gateway username / password |

No installation or self-hosting required — just point your SMPP client to `smpp.sms-gate.app:2775` and authenticate with your existing SMSGate credentials.

## 🧪 Test Mode

The public SMPP server is currently in **test mode**. This means:

- **Shared instance** — all users connect to the same server
- **Default configuration** — no custom tuning per tenant
- **DELIVER_SM forwarding** is still work in progress

We're publishing it early to gather feedback and validate the setup before moving further.

## 🚀 Quick Start

Connect using any SMPP v3.4 compatible client:

=== "go-smpp (github.com/fiorix/go-smpp)"
    ```bash
    sms --addr smpp.sms-gate.app:2776 \
      --tls
      --user your-username \
      --passwd your-password \
      send \
      <from> <to> <message>
    ```

=== "Python (python-smpplib)"
    ```python
    import smpplib

    client = smpplib.client.Client(
        "smpp.sms-gate.app", 2775
    )
    client.connect()
    client.bind_transceiver(
        system_id="your-username",
        password="your-password"
    )

    # Send a message
    client.send_submit_sm(
        source_addr_ton=1,
        source_addr_npi=1,
        source_addr="",
        dest_addr_ton=1,
        dest_addr_npi=1,
        destination_addr="+1234567890",
        short_message="Hello from SMPP!".encode(),
        registered_delivery=1,
    )
    client.unbind()
    client.disconnect()
    ```

## 📚 Documentation

Updated docs are available:

- **[SMPP Server Guide](../../services/smpp-server.md)** — Public server details & self-hosting options
- **[SMPP Protocol Integration](../../integration/smpp.md)** — Protocol details, parameter mapping
- **[SMPP FAQ](../../faq/smpp-server.md)** — Troubleshooting and common questions

## 💬 Feedback

This is an early release — we want to hear from you. Open an issue on the [SMPP Server repository](https://github.com/android-sms-gateway/smpp-server) if you run into problems or have feature requests.
