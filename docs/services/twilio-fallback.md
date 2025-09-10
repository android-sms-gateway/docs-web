# 🚀 Twilio™ Fallback Service

!!! warning
    This service is not affiliated with, endorsed by, or sponsored by Twilio. It is an independent project that utilizes the Twilio API.

## 📖 Overview

The Twilio Fallback Service resolves SMS deliverability challenges for the Twilio API users navigating evolving messaging requirements. It acts as a bridge between Twilio and SMSGate, enabling seamless fallback without requiring any changes to existing Twilio-based software.

## ⚙️ How it Works

The Twilio Fallback Service handles Twilio message failure callbacks and resends failed messages via the SMSGate API. This ensures that critical messages are delivered even if the primary Twilio channel fails.

1.  Your application sends an SMS message via Twilio.
2.  If the message fails to deliver via Twilio, Twilio sends a message status callback to the Twilio Fallback Service.
3.  The Twilio Fallback Service receives the callback, extracts the message details, and resends the message via the SMSGate API.

## 🚀 Getting Started

### ⚙️ Prerequisites

- Linux VPS with a public IP address
- Docker (if using Docker deployment)
- Domain name and SSL certificate ([strongly recommended](https://www.twilio.com/docs/usage/webhooks/webhooks-security#httpstls))
- An SMSGate account
- A Twilio account with message status callbacks configured to point to your Twilio Fallback Service instance

### 📦 Installation

Choose one of the following installation methods:

#### 1. Pre-built Binaries

Download the appropriate binary for your system from the [GitHub Releases page](https://github.com/android-sms-gateway/twilio-fallback/releases/latest).

#### 2. Docker Image

Alternatively, you can use the Docker image hosted on `ghcr.io`:

```sh
docker pull ghcr.io/android-sms-gateway/twilio-fallback:latest
```

## ⚙️ Configuration

1.  Create a `.env` file in the root directory of the project. Copy the contents from `.env.example` and fill in the required values.
2.  Configure your Twilio account to send message status callbacks to the service's endpoint: `[YOUR_SERVICE_URL]/api/twilio`. See the [Twilio documentation](https://www.twilio.com/docs/usage/webhooks/messaging-webhooks#outbound-message-status-callback) for more information on setting up Twilio callbacks.

The following environment variables are available to configure the service:

| Variable               | Description                                  | Default                                |
| ---------------------- | -------------------------------------------- | -------------------------------------- |
| `HTTP__ADDRESS`        | HTTP server address                          | `127.0.0.1:3000`                       |
| `HTTP__PROXY_HEADER`   | HTTP proxy header                            | *empty*                                |
| `HTTP__PROXIES`        | Comma separated list of trusted proxies      | *empty*                                |
| `TWILIO__ACCOUNT_SID`  | Twilio account identifier                    | **required**                           |
| `TWILIO__AUTH_TOKEN`   | Twilio authentication token                  | **required**                           |
| `TWILIO__CALLBACK_URL` | Publicly accessible URL for Twilio callbacks | Dynamic based on `Host` header         |
| `SMSGATE__BASE_URL`    | SMSGate API endpoint                         | `https://api.sms-gate.app/3rdparty/v1` |
| `SMSGATE__USERNAME`    | SMSGate API username                         | **required**                           |
| `SMSGATE__PASSWORD`    | SMSGate API password                         | **required**                           |
| `SMSGATE__TIMEOUT`     | SMSGate API timeout                          | `1s`                                   |

## 🚀 Deployment

### Local Deployment

To run the service locally:

```sh
./twilio-fallback
```

### Docker Deployment

Run the Docker container:

```sh
docker run -p 3000:3000 --env-file .env ghcr.io/android-sms-gateway/twilio-fallback:latest
```

## 📚 See Also

* [SMSGate API](../integration/api.md)
* [Twilio Webhooks](https://www.twilio.com/docs/usage/webhooks/messaging-webhooks#outbound-message-status-callback)
