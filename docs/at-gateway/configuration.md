# ⚙️ AT Gateway Configuration

AT Gateway reads configuration from an optional YAML file, a `.env` file in the working directory, and process environment variables, in that order — **later sources win**. Nested keys use a double underscore separator: `MODEM__PORT` maps to `modem.port`.

## 🧩 How configuration is loaded

1. **`CONFIG_PATH` YAML file** — optional; must be a process environment variable, not a line inside `.env`.
2. **`.env` in the working directory** — convenient for local installs; keep secrets out of version control.
3. **Process environment variables** — highest precedence; recommended for passwords and signing keys.

!!! tip "Duration format"
    Timings use Go's `time.ParseDuration` form: `30s`, `5m`, `1h`. The day unit is not supported — express days in hours (`168h` for 7 days, `720h` for 30 days).

## 🌐 HTTP, auth, and storage

| Variable                     | Default                                    | Description                                                         |
| ---------------------------- | ------------------------------------------ | ------------------------------------------------------------------- |
| `HTTP__ADDRESS`              | `127.0.0.1:3000`                           | HTTP API listen address                                             |
| `HTTP__PROXY_HEADER`         | `X-Forwarded-For`                          | Trusted proxy header for the client IP                              |
| `HTTP__PROXIES`              | *(empty)*                                  | Trusted proxies as a JSON array, e.g. `["127.0.0.1"]`               |
| `HTTP__OPENAPI__ENABLED`     | `true`                                     | Serve Swagger UI at `/api/v1/docs`                                  |
| `HTTP__OPENAPI__PUBLIC_HOST` | *(empty)*                                  | Host displayed and called by Swagger UI behind a proxy              |
| `HTTP__OPENAPI__PUBLIC_PATH` | *(empty)*                                  | Base path displayed by Swagger UI behind a path prefix              |
| `AUTH__BASIC__USERNAME`      | `sms`                                      | HTTP Basic username for all `/api/v1` routes                        |
| `AUTH__BASIC__PASSWORD`      | *(generated)*                              | HTTP Basic password; generated and persisted on first boot if unset |
| `DATABASE__URL`              | `sqlite://data/gateway.db?_foreign_keys=1` | SQLite store for messages, inbox, webhooks, and settings            |
| `STORAGE__PATH`              | `data/storage.json`                        | Persists the device ID, generated password, and signing key         |
| `DEVICE__NAME`               | *(empty)*                                  | Display name returned by `GET /api/v1/devices`                      |
| `CONFIG_PATH`                | *(empty)*                                  | Optional YAML config file; process environment only                 |

!!! danger "Protect the data directory"
    `DATABASE__URL` and `STORAGE__PATH` must point at persistent, writable storage. The storage file holds the device identity and generated credentials — do not publish it.

## 📟 Modem and message settings

| Variable                       | Default        | Description                                                 |
| ------------------------------ | -------------- | ----------------------------------------------------------- |
| `MODEM__PORT`                  | `/dev/ttyUSB0` | Serial device of the modem                                  |
| `MODEM__BAUD_RATE`             | `115200`       | Serial baud rate                                            |
| `MODEM__INIT_TIMEOUT`          | `30s`          | Upper bound of the boot init sequence                       |
| `MODEM__COMMAND_TIMEOUT`       | `30s`          | Upper bound of a single AT command round-trip               |
| `MODEM__CMGD__RETRY_ATTEMPTS`  | `3`            | Total `AT+CMGD` deletion attempts per read entry            |
| `MODEM__CMGD__RETRY_BACKOFF`   | `2s`           | Base delay for exponential deletion retry backoff           |
| `MODEM__STORE__MEMORY`         | `SM`           | Preferred modem message storage (`+CPMS` mem1)              |
| `MODEM__STORE__SWEEP_INTERVAL` | `60s`          | `AT+CMGL=4` retained-entry sweep; `0` disables it           |
| `MESSAGES__POLL_INTERVAL`      | `1s`           | Outgoing queue poll interval when the queue is empty        |
| `MESSAGES__MAX_SEGMENTS`       | `10`           | Maximum concatenated SMS parts; `0` disables the cap        |
| `MESSAGES__DEFAULT_REGION`     | `RU`           | ISO 3166-1 alpha-2 region used to parse numbers without `+` |

## 📥 Inbox settings

| Variable                    | Default | Description                                                       |
| --------------------------- | ------- | ----------------------------------------------------------------- |
| `INBOX__REASSEMBLY_TIMEOUT` | `5m`    | How long incomplete multi-part groups are kept before eviction    |
| `INBOX__SWEEP_INTERVAL`     | `1s`    | Cadence for evicting incomplete groups and expired dedupe entries |
| `INBOX__RETENTION`          | `720h`  | Age-based retention of stored inbox rows (720h = 30 days)         |
| `INBOX__CLEANUP_INTERVAL`   | `24h`   | Cadence of the retention cleanup pass                             |

!!! note "Two different sweeps"
    `INBOX__SWEEP_INTERVAL` maintains reassembly/dedupe state; `MODEM__STORE__SWEEP_INTERVAL` recovers entries stored in the modem that were never notified. They are independent.

## 🪝 Webhooks and ping

| Variable                                    | Default       | Description                                               |
| ------------------------------------------- | ------------- | --------------------------------------------------------- |
| `WEBHOOKS__RETRY_COUNT`                     | `15`          | Delivery attempts after the initial POST                  |
| `WEBHOOKS__SIGNING_KEY`                     | *(generated)* | HMAC-SHA256 signing key for `X-Signature`                 |
| `WEBHOOKS__QUEUE__BATCH_SIZE`               | `20`          | Queued deliveries processed per queue pass                |
| `WEBHOOKS__QUEUE__REQUEST_TIMEOUT`          | `30s`         | Maximum duration of one delivery request                  |
| `WEBHOOKS__QUEUE__DIAL_TIMEOUT`             | `5s`          | Maximum duration to establish the connection              |
| `WEBHOOKS__QUEUE__RETRY_BASE_DELAY`         | `5s`          | Base delay for exponential retry backoff                  |
| `WEBHOOKS__QUEUE__IDLE_DELAY`               | `5s`          | Delay before polling an empty queue again                 |
| `WEBHOOKS__QUEUE__STUCK_PROCESSING_TIMEOUT` | `5m`          | Time before a claimed delivery is re-queued after a crash |
| `WEBHOOKS__QUEUE__CLEANUP_RETENTION`        | `168h`        | Retention of completed queue rows (168h = 7 days)         |
| `PING__INTERVAL`                            | `60s`         | `system:ping` heartbeat interval; `0` disables the event  |

## 🧷 Settings API precedence

The Settings API stores `ping.interval_seconds`, `webhooks.retry_count`, and `webhooks.signing_key` in SQLite. Stored values override the matching environment variables:

- `ping.interval_seconds` overrides `PING__INTERVAL`.
- `webhooks.retry_count` overrides `WEBHOOKS__RETRY_COUNT`.
- A stored `webhooks.signing_key` overrides `WEBHOOKS__SIGNING_KEY`; the API rejects writing a non-empty key, so key rotation through the API is not available.

!!! warning "Restart required"
    A value written through the Settings API is visible on the next read immediately, but takes effect only after the gateway is restarted.

## 📚 See Also

- [Installation](./installation.md) — environment setup, Docker, and data persistence.
- [Integration API](../integration/api.md) — the shared API contract used by every mode.
- [Full variable reference](https://github.com/android-sms-gateway/at-gateway/blob/master/.env.example) — every variable with format and examples.
