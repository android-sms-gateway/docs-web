# 📟 AT Gateway

AT Gateway is an **alternative gateway device** to the Android app in the SMSGate ecosystem. It turns a serial AT-command modem (SIM800L class and similar) into a standalone SMS gateway that serves the shared SMSGate API locally, with webhooks, health checks, and Prometheus telemetry — no Android phone or cloud account required.

!!! info "Where it fits"
    The Android app is the default gateway device for SMSGate's Local, Cloud, and Private server modes. AT Gateway is an **alternative gateway device** that speaks the same SMSGate API from a different base URL. Applications that use a configurable base URL can switch between modes transparently — what changes is the URL and the capabilities of the device behind it.

## 🤔 When to use AT Gateway

- You need a gateway but have no Android device available.
- You want dedicated, always-on hardware — a modem on a Raspberry Pi, mini PC, NAS, or any Linux host with a serial port.
- Your deployment is local or private-network only, with no cloud dependency.
- You already have 2G/3G/4G AT-command modems or USB dongles and want to reuse them.

!!! warning "SMS only"
    AT Gateway handles **SMS and DATA_SMS**. MMS is never received over AT commands, so MMS features available in the Android app do not apply here.

## ⚖️ Android app vs AT Gateway

| Aspect             | Android app                                                | AT Gateway                                                    |
| ------------------ | ---------------------------------------------------------- | ------------------------------------------------------------- |
| Gateway device     | Android 5.0+ phone or tablet                               | Serial AT modem (SIM800L class, 3G/4G AT dongles)             |
| API                | SMSGate API — see [Integration API](../integration/api.md) | Same SMSGate API at a local base URL, with modem capabilities |
| Server dependency  | Cloud/Private modes route through a SMSGate server         | None — the gateway is self-contained                          |
| Message types      | SMS, MMS, and binary Data SMS                              | SMS and DATA_SMS; no MMS over AT                              |
| SIM / device scope | Multi-SIM and multi-device support                         | One modem with a stable local device identity                 |
| Typical deployment | App on a phone; server chosen in setup                     | Docker, binary, or source build on a host with a serial port  |

Both options are part of the SMSGate ecosystem and offer REST integration, webhooks, and health endpoints — the difference is the hardware that terminates the SMS link and who hosts the API.

## ⭐ Features

- **Modem bring-up** — `AT`, `ATE0`, `AT+CMEE=1`, `AT+CMGF=0` (PDU), `AT+CNMI=2,1,0,1,0`, gated on `AT+CPIN?` reporting READY, with reconnect handling and a periodic `AT+CMGL=4` retained-entry sweep.
- **Outgoing SMS** — persistent FIFO queue (`202 Accepted` plus `Location`), automatic GSM-7/UCS-2 concatenation, E.164 validation, `scheduleAt`/`validUntil` scheduling, and cancellation.
- **Incoming SMS** — `+CMTI` → `AT+CMGR` → inbox → `AT+CMGD`, with multi-part reassembly, deduplication, inbox listing, and webhook replay.
- **Webhooks** — registry API, HMAC-SHA256 signing, and a persistent queue with exponential retry. Events: `sms:sent`, `sms:delivered`, `sms:failed`, `sms:cancelled`, `sms:received`, `sms:data-received`, `app:started`, `system:ping`.
- **Operations** — Prometheus `/metrics`, signal-quality polling, health endpoints, and a Settings API for the ping interval and webhook retry count.

!!! note "Basic auth"
    Every `/api/v1` route requires HTTP Basic credentials (user `sms` by default). Set a strong password before exposing the API beyond localhost.

## 🔗 API compatibility

AT Gateway uses the **same SMSGate API** as the other modes — the request and response formats are shared. Only the base URL and the capabilities of the gateway device differ:

| Mode                   | API base URL                              | Capability notes              |
| ---------------------- | ----------------------------------------- | ----------------------------- |
| Public Cloud           | `https://api.sms-gate.app/3rdparty/v1`    | Managed cloud server          |
| Private Server         | `https://your-domain.com/api/3rdparty/v1` | Self-hosted server            |
| Local Server (Android) | `http://<device_ip>:8080`                 | Local network only            |
| AT Gateway             | `http://<host>:3000/api/v1`               | SMS and DATA_SMS only; no MMS |

!!! tip "Transparent switching"
    The API contract is shared, so clients only need to change the base URL when switching modes. See [Integration API](../integration/api.md) for the common reference.

## 🧭 Next steps

- [Hardware & Example Setups](./hardware.md) — wiring schemes and modem options.
- [Installation](./installation.md) — run the gateway as a binary, in Docker, or from source.
- [Configuration](./configuration.md) — serial port, auth, database, inbox, webhooks, and ping settings.
- [Integration API](../integration/api.md) — the shared API used by every mode.

## 📚 See Also

- [Getting Started](../getting-started/index.md) — the Android-app-based Local, Cloud, and Private server modes.
- [Installation](../installation.md) — installing the Android app, the default gateway device.
- [Webhooks](../features/webhooks.md) — webhook concepts used across the ecosystem.
