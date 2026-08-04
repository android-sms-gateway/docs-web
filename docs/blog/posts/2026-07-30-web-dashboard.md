---
title: "Web Dashboard: Manage Your SMS Gateway from a Browser"
date: 2026-07-30
categories:
  - Integration
  - Infrastructure
description: "Introducing the SMSGate Web Dashboard — a standalone web application for managing messages, devices, webhooks, API tokens, and settings through a graphical interface at dashboard.sms-gate.app."
author: SMSGate Team LLM / Big Pickle
---

# 📊 Web Dashboard: Manage Your SMS Gateway from a Browser

We're excited to announce the **SMSGate Web Dashboard** — a standalone web application that provides a graphical interface for managing your SMS gateway at [**`https://dashboard.sms-gate.app`**](https://dashboard.sms-gate.app).

<!-- more -->

## 🎯 Why a Web Dashboard?

Until now, managing your SMS gateway meant either using the Android app directly or interacting with the REST API via `curl`, custom scripts, or client libraries. While powerful, these approaches aren't always the most convenient for quick operational tasks.

The Web Dashboard fills that gap — providing a browser-based UI for the most common management tasks without requiring any API knowledge.

## ✨ What You Can Do

### 📈 Dashboard Overview

When you log in, you're greeted with an at-a-glance summary of your gateway: devices online and active, messages sent, pending, and failed — all updating in real time through Server-Sent Events (SSE).

### 💬 Send and Track Messages

Compose an SMS from the browser, choose a target device and SIM, and send. The message list is paginated and filterable by state, device, and date range. Click any message to see its full delivery timeline with per-recipient status.

### 📱 Manage Devices

See all registered devices with their online/offline status at a glance. Remove devices with a single click.

### 🌐 Configure Webhooks

Create webhooks for any supported event — all from a form, no `curl` commands needed.

### 🔑 Generate API Tokens

Create JWT tokens with 15 granular scopes and configurable TTL through a clean UI. Copy to clipboard or revoke by token ID.

### ⚙️ Tweak Device Settings

Adjust message intervals, SIM selection mode, ping intervals, log lifetimes, webhook signing keys, and more — all through a tabbed settings form.

## 🏗️ Architecture

The dashboard is a **Go HTTP server** with an **embedded Svelte 5 single-page application**. It acts as a proxy to the SMSGate API — your credentials are validated against the API, then stored in a cookie-backed server session. No credentials are stored on disk.

For real-time updates, the dashboard registers webhooks on the SMSGate server for your session and translates incoming callbacks into SSE events pushed to your browser.

## 🚀 Getting Started

1. Open **`https://dashboard.sms-gate.app`**
2. Log in with your SMSGate credentials (from the Android app under Cloud Server settings)
3. Start managing your gateway from the browser

No registration, no installation — just your existing credentials.

## 🖥️ Self-Hosting

Running your own Private Server? The dashboard can be deployed alongside it as a Docker container:

```bash title="Run Dashboard Container"
docker run -d --name smsgate-dashboard \
  -p 3000:3000 \
  -e HTTP__ADDRESS=0.0.0.0:3000 \
  -e GATEWAY__URL=https://your-server.com/api/3rdparty/v1 \
  -e GATEWAY__WEBHOOK_URL=https://your-server.com/api/webhooks/callback \
  ghcr.io/android-sms-gateway/web-dashboard:latest
```

Multi-architecture images (`linux/amd64`, `linux/arm64`) are published to GHCR, and pre-built binaries for Linux, macOS, and Windows are on the [Releases page](https://github.com/android-sms-gateway/web-dashboard/releases).

## 🔗 Learn More

- [Web Dashboard Service Documentation](../../services/web-dashboard.md)
- [Web Dashboard Repository](https://github.com/android-sms-gateway/web-dashboard)
- [SMSGate API Reference](../../integration/api.md)
