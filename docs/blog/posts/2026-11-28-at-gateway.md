---
title: "Introducing AT Gateway: A Standalone SMS Gateway for Serial Modems"
date: 2026-11-28
categories:
  - Features
  - Integration
  - IoT
description: "AT Gateway turns a serial AT-command modem into a standalone SMS gateway that serves the shared SMSGate API locally, with no Android device or cloud account required."
author: SMSGate Team LLM / Hy4 flash Free
---

# 📟 Introducing AT Gateway: A Standalone SMS Gateway for Serial Modems

We're excited to announce **AT Gateway**, a new alternative gateway device in the SMSGate ecosystem. It turns a serial AT-command modem (SIM800L class and similar) into a standalone SMS gateway that serves the shared SMSGate API locally, with webhooks, health checks, and Prometheus telemetry. No Android phone or cloud account is required.

<!-- more -->

## 🤔 Why AT Gateway?

The Android app is the default gateway device for SMSGate's Local, Cloud, and Private server modes. That works well when a phone or tablet is available, but not every deployment has one:

- You need a gateway but have no Android device available.
- You want dedicated, always-on hardware: a modem on a Raspberry Pi, mini PC, NAS, or any Linux host with a serial port.
- Your deployment is local or private-network only, with no cloud dependency.
- You already have 2G/3G/4G AT-command modems or USB dongles and want to reuse them.

AT Gateway fills that gap without introducing another API to learn. It speaks the same SMSGate API from a different base URL, so applications with a configurable base URL can switch between modes transparently. Both options are part of the SMSGate ecosystem and offer REST integration, webhooks, and health endpoints; what changes is the hardware that terminates the SMS link and who hosts the API.

## ⚖️ How it compares to the Android app

| Aspect             | Android app                                        | AT Gateway                                                    |
| ------------------ | -------------------------------------------------- | ------------------------------------------------------------- |
| Gateway device     | Android 5.0+ phone or tablet                       | Serial AT modem (SIM800L class, 3G/4G AT dongles)             |
| API                | SMSGate API                                        | Same SMSGate API at a local base URL, with modem capabilities |
| Server dependency  | Cloud/Private modes route through a SMSGate server | None, the gateway is self-contained                           |
| Message types      | SMS, MMS, and binary Data SMS                      | SMS and DATA_SMS                                              |
| SIM / device scope | Multi-SIM and multi-device support                 | One modem with a stable local device identity                 |
| Typical deployment | App on a phone; server chosen in setup             | Docker, binary, or source build on a host with a serial port  |

AT Gateway handles **SMS and DATA_SMS** only. MMS is never received over AT commands, so MMS features available in the Android app do not apply here.

## ⭐ What it does

- **Modem bring-up** - `AT`, `ATE0`, `AT+CMEE=1`, `AT+CMGF=0` (PDU), `AT+CNMI=2,1,0,1,0`, gated on `AT+CPIN?` reporting READY, with reconnect handling and a periodic retained-entry sweep.
- **Outgoing SMS** - persistent FIFO queue (`202 Accepted` plus `Location`), automatic GSM-7/UCS-2 concatenation, E.164 validation, `scheduleAt`/`validUntil` scheduling, and cancellation.
- **Incoming SMS** - `+CMTI` to `AT+CMGR` to inbox to `AT+CMGD`, with multi-part reassembly, deduplication, inbox listing, and webhook replay.
- **Webhooks** - registry API, HMAC-SHA256 signing, and a persistent queue with exponential retry. Events include `sms:sent`, `sms:delivered`, `sms:failed`, `sms:cancelled`, `sms:received`, `sms:data-received`, `app:started`, and `system:ping`.
- **Operations** - Prometheus `/metrics`, signal-quality polling, health endpoints, and a Settings API for the ping interval and webhook retry count.

Every `/api/v1` route requires HTTP Basic credentials (user `sms` by default), so set a strong password before exposing the API beyond localhost.

## 🔧 Hardware and setup overview

Any setup runs the same software on a host with a serial AT-command modem. The hardware examples cover a handmade SIM800C board with a 3.3 V USB-UART bridge, ready-made GSM/UMTS USB modems, a SIM800C on a Raspberry Pi GPIO UART, 4G/LTE USB dongles for networks where 2G is unavailable, and any Linux host with Docker and USB passthrough. All of them end at two settings: `MODEM__PORT` and `MODEM__BAUD_RATE` (default `115200`). A SIM card, an antenna, and a power supply that survives GSM transmit bursts (about 2 A) are required.

Installation options are a pre-built binary, a Docker image (`ghcr.io/android-sms-gateway/at-gateway:latest`), or a Go source build (Go 1.25+). The HTTP API listens on `127.0.0.1:3000` by default, with interactive Swagger docs at `/api/v1/docs` and a health endpoint at `/health` for a quick verification. See the [hardware and example setups](../../at-gateway/hardware.md), [installation](../../at-gateway/installation.md), and [configuration](../../at-gateway/configuration.md) guides for wiring diagrams, device naming, and every setting.

## 🔗 API compatibility

AT Gateway uses the same SMSGate API as the other modes: request and response formats are shared, and only the base URL and the capabilities of the device differ. AT Gateway is served at `http://<host>:3000/api/v1`, compared with `https://api.sms-gate.app/3rdparty/v1` for Public Cloud, `https://your-domain.com/api/3rdparty/v1` for a Private Server, and `http://<device_ip>:8080` for a Local Server on Android. See the [Integration API](../../integration/api.md) for the common contract.

## 📖 Where to learn more

- [AT Gateway overview](../../at-gateway/index.md) - when to use it and how it compares with the Android app
- [Hardware & example setups](../../at-gateway/hardware.md) - wiring schemes and modem options
- [Installation](../../at-gateway/installation.md) - binary, Docker, and source builds
- [Configuration](../../at-gateway/configuration.md) - serial port, auth, database, inbox, webhooks, and ping settings
- [Getting Started](../../getting-started/index.md) - the Android-app-based Local, Cloud, and Private server modes
- [Webhooks](../../features/webhooks.md) - event concepts used across the ecosystem
