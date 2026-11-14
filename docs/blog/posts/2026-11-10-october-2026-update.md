---
title: "October 2026 Update: Richer Message Status, Webhook Signature Helpers, and MMS in the Dashboard"
date: 2026-11-10
categories:
  - Features
  - API
description: "A roundup of the October 2026 SMSGate releases: createdAt and scheduleAt in message status responses, official webhook signature-verification helpers in the Go and Rust SDKs, MMS composition in the web dashboard, stricter SMTP authentication in the email-to-sms bridge, and explicit device unregister in the Android app."
author: SMSGate Team LLM / Xiaomi MiMo-V2.6-Flash
---

# 🗓️ October 2026 Update: Richer Message Status, Webhook Signature Helpers, and MMS in the Dashboard

October was a busy month across the SMSGate ecosystem — seven server releases (v1.49.0 → v1.52.1), seven Android app releases (v1.77.1 → v1.78.1), and a wave of SDK and dashboard updates. Here is what changed for you.

<!-- more -->

## 📊 Message Status Now Carries `createdAt` and `scheduleAt`

Message status responses now include **`createdAt`** — the message creation timestamp — on every status read, and scheduled messages return their actual **`scheduleAt`** instead of an empty value. If you poll status or reconcile message state in a consumer, you no longer need to track creation time yourself.

All five official SDKs (Go, TypeScript, PHP, Python, Rust) gained `createdAt` in their message-state types during the month.

See [Status Tracking](../../features/status-tracking.md) for the full field reference and [Scheduled Messages](../../features/sending-messages.md#scheduled-messages) for scheduling semantics.

## 🪝 Webhook Signature Verification in the SDKs

Verifying signed webhooks no longer requires hand-rolled HMAC code in Go and Rust:

- **Go** (client-go v1.17.0): `smsgateway.VerifyWebhookSignature` verifies the `X-Signature`/`X-Timestamp` pair, and `smsgateway.VerifyWebhookSignatureWithin` additionally checks timestamp freshness when `maxAge` is positive. The freshness window limits replay exposure — a request replayed within the window can still verify, so deduplicate events when repeated processing matters.
- **Rust** (client-rs): `webhook::verify_signature` verifies with constant-time comparison and an optional maximum age for the timestamp.

TypeScript, PHP, and Python users can keep using the copy-paste examples in the webhook guide. The [SDK feature matrix](../../integration/client-libraries.md) now lists signature verification per language, and the [Payload Signing](../../features/webhooks.md#payload-signing) section points at both helpers.

## ✉️ MMS Composition in the Web Dashboard

The [Web Dashboard](../../services/web-dashboard.md) gained two visible upgrades:

- **Compose MMS** (v0.6.0): switch the composer between SMS and MMS, add an optional subject, and attach files with a preview before sending.
- **Device encryption keys** (v0.6.1): the devices table shows an **E2E** badge for devices with a public key, plus their key version when available. The badge indicates key availability — messages composed in the dashboard are not end-to-end encrypted.

## 📧 Stricter SMTP Authentication in the Email-to-SMS Bridge

Since October 26, the [Email to SMS Bridge](../../services/email-to-sms.md) ties authentication to TLS: when `SMTP__TLS_CERT` and `SMTP__TLS_KEY` are configured, STARTTLS is advertised and `AUTH PLAIN` is only accepted after the connection is upgraded. The certificate and key must be configured together — the bridge refuses to start if only one of the pair is set. Without TLS configured, cleartext `AUTH PLAIN` remains available for trusted or local networks.

## 🗑️ Explicit Device Unregister

The Android app (v1.78.0) lets you remove a cloud registration from the device itself: **Settings → Cloud Server → Credentials → Unregister device** clears the registration and stops the cloud session. Sign up or sign in again whenever you need the cloud server — see [Unregistering a Device](../../features/multi-device.md#unregistering-a-device) for the exact semantics.

## ✨ Also in This Release Cycle

- **Telegram Bridge** launched (v0.0.1/v0.0.2): a self-hosted relay that forwards signed SMSGate webhooks into a Telegram chat — see the [service documentation](../../services/telegram-bridge.md).

## 📖 Further Reading

- [Status Tracking](../../features/status-tracking.md) — message lifecycle and status fields
- [Webhooks](../../features/webhooks.md) — events, payload signing, and queue diagnostics
- [Client Libraries](../../integration/client-libraries.md) — install and feature matrix for all five SDKs
- [Web Dashboard](../../services/web-dashboard.md) — browser-based management UI
