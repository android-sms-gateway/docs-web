# Integration - CLI Tool 💻

The SMS Gateway for Android™ offers its own Command Line Interface (CLI), allowing you to integrate it into your processes without writing any code - simply execute CLI commands! 🚀

## Installation 📥

=== ":package: Native Installation"
    ```bash title="Linux/macOS"
    curl -LO https://github.com/android-sms-gateway/cli/releases/latest/download/smsgate-linux-amd64
    chmod +x smsgate-linux-amd64
    sudo mv smsgate-linux-amd64 /usr/local/bin/smsgate
    ```

=== ":material-language-go: Go Install"
    ```bash
    go install github.com/android-sms-gateway/cli@latest
    ```
    **Requirements**:

    - Go 1.23+ installed
    - `$GOPATH/bin` in your system PATH
    
    !!! tip "For Developers"
        This method installs the latest development version.  
        Add `export PATH=$PATH:$(go env GOPATH)/bin` to your shell config.

=== ":window: Windows"
    ```powershell
    Invoke-WebRequest https://github.com/android-sms-gateway/cli/releases/latest/download/smsgate-windows-amd64.exe -OutFile smsgate.exe
    Move-Item smsgate.exe "$env:ProgramFiles\SMSGATE\"
    ```

=== "🐳 Docker"
    ```bash
    docker pull ghcr.io/android-sms-gateway/cli:latest
    ```

## Configuration ⚙️

The CLI can be configured using environment variables or command-line flags. You can also use a `.env` file in the working directory to set these variables.

```bash title=".env Example"
ASG_ENDPOINT="https://api.sms-gate.app/3rdparty/v1"
ASG_USERNAME="your_username"
ASG_PASSWORD="your_password"
```

### Options Overview

| Option             | Env Var        | Description                         | Default                                |
| ------------------ | -------------- | ----------------------------------- | -------------------------------------- |
| `-e`, `--endpoint` | `ASG_ENDPOINT` | :globe_with_meridians: API endpoint | `https://api.sms-gate.app/3rdparty/v1` |
| `-u`, `--username` | `ASG_USERNAME` | :bust_in_silhouette: Auth username  | **Required**                           |
| `-p`, `--password` | `ASG_PASSWORD` | :key: Auth password                 | **Required**                           |
| `-f`, `--format`   | -              | :page_facing_up: Output format      | `text`                                 |

### Output formats

The CLI supports three output formats:

- `text` - human-readable format
- `json` - formatted JSON output
- `raw` - same as `json` but without formatting

!!! note
    When the exit code is not `0`, the error description is printed to stderr without any formatting.

## Commands 🛠️

The CLI offers two main groups of commands:

- **Messages**: Commands for sending messages and checking their status.
- **Webhooks**: Commands for managing webhooks, including creating, updating, and deleting them.

### Messages Commands

#### Send a Message 📨

The `send` command allows you to send a message to one or more phone numbers.

**Syntax:**
```bash title="Basic Usage"
smsgate send [options] 'Message content'
```

**Options:**

| Option                      | Description                                                                                                                                           | Default Value | Example                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ----------------------- |
| `--id`                      | A unique message ID. If not provided, one will be automatically generated.                                                                            | empty         | `zXDYfTmTVf3iMd16zzdBj` |
| `--phone`, `--phones`, `-p` | Specifies the recipient's phone number(s). This option can be used multiple times or accepts comma-separated values. Numbers must be in E.164 format. | **required**  | `+19162255887`          |
| `--sim`, `--simNumber`      | The one-based SIM card slot number. If not specified, the device's SIM rotation feature will be used.                                                 | empty         | `2`                     |
| `--ttl`                     | Time-to-live (TTL) for the message. If not provided, the message will not expire.<br>**Conflicts with `--validUntil`.**                               | empty         | `1h30m`                 |
| `--validUntil`              | The expiration date and time for the message. If not provided, the message will not expire.<br>**Conflicts with `--ttl`.**                            | empty         | `2024-12-31T23:59:59Z`  |

---

#### Get the Status of a Message ⏱️

The `status` command retrieves the status of a message using its ID.

**Syntax:**
```bash title="Get Message Status"
smsgate status 'Message ID'
```

---

### Webhooks Commands 🌐

#### Register a Webhook 📝

The `register` command allows you to register a new webhook.

**Syntax:**
```bash
smsgate webhooks register [options] URL
```

**Options:**

| Option          | Description                                                                | Default Value | Example                 |
| --------------- | -------------------------------------------------------------------------- | ------------- | ----------------------- |
| `--id`          | A unique webhook ID. If not provided, one will be automatically generated. | empty         | `zXDYfTmTVf3iMd16zzdBj` |
| `--event`, `-e` | The event name for which the webhook will be triggered.                    | **required**  | `sms:received`          |

---

#### List Webhooks 📜

The `list` command displays all registered webhooks.

**Syntax:**
```bash
smsgate webhooks list
```

---

#### Delete a Webhook 🗑️

The `delete` command removes a webhook by its ID.

**Syntax:**
```bash
smsgate webhooks delete 'Webhook ID'
```

## Usage examples 💡

For security reasons, it is recommended to pass credentials using environment variables or a `.env` file.

```bash
# Send a message
smsgate send --phone '+19162255887' 'Hello, Dr. Turk!'

# Send a message to multiple numbers
smsgate send --phone '+19162255887' --phone '+19162255888' 'Hello, doctors!'
# or
smsgate send --phones '+19162255887,+19162255888' 'Hello, doctors!'

# Get the status of a sent message
smsgate status zXDYfTmTVf3iMd16zzdBj

# Register a webhook for received messages
smsgate webhooks register --event 'sms:received' 'https://example.com/webhook'

# List all registered webhooks
smsgate webhooks list

# Delete a webhook
smsgate webhooks delete 'webhook-id'
```

Credentials can also be passed via CLI options:

```bash
# Pass credentials by options
smsgate send -u <username> -p <password> \
    --phone '+19162255887' 'Hello, Dr. Turk!'
```

If you prefer not to install the CLI tool locally, you can use Docker to run it:

```bash
docker run -it --rm --env-file .env ghcr.io/android-sms-gateway/cli \
    send --phone '+19162255887' 'Hello, Dr. Turk!'
```

## Exit codes 🔚

The CLI uses exit codes to indicate the outcome of operations:

| Code | Description           |
| ---- | --------------------- |
| 0    | ✅ Success             |
| 1    | ❌ Invalid input       |
| 2    | 🌐 Network error       |
| 3    | 📄 Output format error |

---

[:material-github: CLI Repository](https://github.com/android-sms-gateway/cli)
