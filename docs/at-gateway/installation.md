# 🚀 AT Gateway Installation

AT Gateway runs anywhere you can attach a serial AT modem: directly on a Linux host, in a Docker container with the device passed through, or from a Go source build. The default command is `serve` and the HTTP API listens on `127.0.0.1:3000`.

## 📋 Prerequisites

- A serial AT-command modem (for example, a SIM800L-class module or an AT-capable USB dongle) with a SIM card, antenna, and a power supply that survives GSM transmit bursts (~2 A).
- Serial device permissions for the user running the gateway (typically membership in `dialout` on Linux).
- **Go 1.25+** only if building from source; Docker only if using the container image.

!!! tip "Hardware first"
    Wiring, port selection, udev rules, and complete hardware examples are in the [example setups in the AT Gateway repository](https://github.com/android-sms-gateway/at-gateway/blob/master/docs/example-setups.md). Probe the modem with `AT` before starting the gateway.

## 📦 Pre-built binary

Download the latest release binary from [GitHub Releases](https://github.com/android-sms-gateway/at-gateway/releases/latest), then build and run:

```bash title="Build and start AT Gateway"
make deps
make build
AUTH__BASIC__PASSWORD=change-me ./bin/at-gateway
```

Replace `change-me` with a strong password. When the password is unset, the gateway generates one on first boot and stores it in `data/storage.json`.

## 🐳 Docker

Pass the modem into the container and persist the data directory:

```bash title="Run AT Gateway in Docker"
docker run -d --name at-gateway \
  --device /dev/ttyUSB0 \
  --group-add "$(stat -c '%g' /dev/ttyUSB0)" \
  -v /path/to/at-gateway-data:/app/data \
  -e MODEM__PORT=/dev/ttyUSB0 \
  -e HTTP__ADDRESS=0.0.0.0:3000 \
  -e AUTH__BASIC__PASSWORD=change-me-to-a-strong-password \
  -p 127.0.0.1:3000:3000 \
  ghcr.io/android-sms-gateway/at-gateway:latest
```

- `--device` passes the serial node through; `--group-add` grants the container user access to a node usually owned by `root:dialout` with mode `660`.
- `/app/data` holds the SQLite database, the device identity, and the generated auth password. Create it with `chown 1000:1000 /path/to/at-gateway-data` and keep it on persistent storage.
- `-p 127.0.0.1:3000:3000` keeps the API on localhost. Publish `0.0.0.0:3000` only when other hosts must reach it, ideally behind a reverse proxy or firewall.

!!! warning "Keep the password out of the volume"
    A password supplied through `AUTH__BASIC__PASSWORD` is not stored in `/app/data` — keep it in your environment or secret manager. Only the auto-generated password is persisted there.

## 🔨 Build from source

```bash title="Build from source"
git clone https://github.com/android-sms-gateway/at-gateway.git
cd at-gateway
make deps
make build
./bin/at-gateway
```

## ✅ Verify the installation

```bash title="Health probe"
curl http://127.0.0.1:3000/health
```

Open `http://127.0.0.1:3000/api/v1/docs` for the interactive Swagger UI at the gateway's local base URL. If startup fails, check `AT+CPIN?` on the modem — the gateway gates readiness on the SIM reporting `READY`.

!!! note "API reference"
    Endpoints and request formats are shared with every SMSGate mode; only the base URL and available capabilities differ. See [Integration API](../integration/api.md) for the common contract.

## 📚 See Also

- [Overview](./index.md) — how AT Gateway compares with the Android app.
- [Example Setups (repository)](https://github.com/android-sms-gateway/at-gateway/blob/master/docs/example-setups.md) — wiring schemes and modem options.
- [Configuration](./configuration.md) — every setting, including the modem port.
