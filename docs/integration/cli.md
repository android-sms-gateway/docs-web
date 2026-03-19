# Integration - CLI Tool 💻

The SMS Gateway for Android™ offers its own Command Line Interface (CLI), allowing you to integrate it into your processes without writing any code - simply execute CLI commands! 🚀

## Installation 📥

The CLI tool can be installed using various methods depending on your operating system and preferences. Choose the installation method that best suits your environment.

=== ":material-linux: Linux (x86_64)"

    ```bash
    curl -LO https://github.com/android-sms-gateway/cli/releases/latest/download/smsgate_Linux_x86_64.tar.gz
    tar -xzf smsgate_Linux_x86_64.tar.gz
    chmod +x smsgate
    sudo mv smsgate /usr/local/bin/smsgate
    ```

=== ":material-apple: macOS (Apple Silicon)"

    ```bash
    curl -LO https://github.com/android-sms-gateway/cli/releases/latest/download/smsgate_Darwin_arm64.tar.gz
    tar -xzf smsgate_Darwin_arm64.tar.gz
    chmod +x smsgate
    sudo mv smsgate /usr/local/bin/smsgate
    ```

=== ":material-microsoft-windows: Windows"

    ```powershell
    Invoke-WebRequest https://github.com/android-sms-gateway/cli/releases/latest/download/smsgate_Windows_x86_64.zip -OutFile smsgate.zip
    Expand-Archive smsgate.zip
    ```

=== ":material-language-go: Go Install"

    ```bash
    go install github.com/android-sms-gateway/cli@latest
    ```

    **Requirements**:
    
    - Go 1.23+ installed
    - `$GOPATH/bin` in your system PATH

    !!! tip "For Developers"
        This method installs the latest development version. Add `export PATH=$PATH:$(go env GOPATH)/bin` to your shell config.

=== ":material-docker: Docker"

    ```bash
    docker pull ghcr.io/android-sms-gateway/cli:latest
    ```

For a complete list of supported platforms, please refer to the [GitHub Releases page](https://github.com/android-sms-gateway/cli/releases/latest).

## ⚙️ Configuration

The CLI tool can be configured using command-line flags, environment variables, or a `.env` file in the working directory. This section provides detailed information about configuration options and output formats.

### Environment Variables

You can set configuration variables using a `.env` file:

```bash title=".env Example"
ASG_ENDPOINT="https://api.sms-gate.app/3rdparty/v1"
ASG_USERNAME="your_username"
ASG_PASSWORD="your_password"
```

### Global Options

The following table summarizes the available command-line options:

| Option             | Env Var        | Description      | Default value                          |
| ------------------ | -------------- | ---------------- | -------------------------------------- |
| `--endpoint`, `-e` | `ASG_ENDPOINT` | The endpoint URL | `https://api.sms-gate.app/3rdparty/v1` |
| `--username`, `-u` | `ASG_USERNAME` | Your username    | **required**                           |
| `--password`, `-p` | `ASG_PASSWORD` | Your password    | **required**                           |
| `--format`, `-f`   | n/a            | Output format    | `text`                                 |

### Output Formats

The CLI supports three output formats:

1. `text`: Human-readable text output (default)
2. `json`: Pretty printed JSON-formatted output
3. `raw`: One-line JSON-formatted output

!!! note
    When the exit code is not `0`, the error description is printed to stderr without any formatting.

## 🛠️ Usage

```bash
smsgate [global options] command [command options] [arguments...]
```

### Commands

The CLI offers three main groups of commands:

- **Messages**: Commands for sending messages and checking their status.
- **Webhooks**: Commands for managing webhooks, including creating, updating, and deleting them.
- **Logs**: Commands for retrieving logs for a specific time range.

For a complete list of available commands, you can run `smsgate help` or `smsgate --help` in your terminal.

### Exit Codes

The CLI tool uses exit codes to indicate the outcome of operations.

| Code | Description           |
| ---- | --------------------- |
| 0    | ✅ Success             |
| 1    | ❌ Invalid input       |
| 2    | 🌐 Network error       |
| 3    | 📄 Output format error |

!!! failure
    Exit codes other than 0 indicate errors. Always check the error message output for troubleshooting information.

## 📝 Message Commands

Message commands allow you to send SMS messages and check their status. The following subsections detail each message-related command.

### Send a Message

The `send` command allows you to send a message to one or more phone numbers.

**Syntax:**
```bash title="Basic Usage"
smsgate send [command options] 'Message content'
```

**Options:**

| Option                      | Description                                                                                                                                           | Default Value | Example                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ----------------------- |
| `--id`                      | A unique message ID. If not provided, one will be automatically generated.                                                                            | empty         | `zXDYfTmTVf3iMd16zzdBj` |
| `--device-id`               | Optional device ID for explicit selection. If not provided, a random device will be selected.                                                         | empty         | `oi2i20J8xVP1ct5neqGZt` |
| `--phones`, `--phone`, `-p` | Specifies the recipient's phone number(s). This option can be used multiple times or accepts comma-separated values. Numbers must be in E.164 format. | **required**  | `+12025550123`          |
| `--sim-number`              | The one-based SIM card slot number. If not specified, the device's SIM rotation feature will be used.                                                 | empty         | `2`                     |
| `--delivery-report`         | Enables delivery report for the message.                                                                                                              | `true`        | `true`                  |
| `--priority`                | Sets the priority of the message. Messages with priority >= 100 bypass all limits and delays.                                                         | `0`           | `100`                   |
| `--ttl`                     | Time-to-live (TTL) for the message. If not provided, the message will not expire.<br>**Conflicts with `--valid-until`.**                              | empty         | `1h30m`                 |
| `--valid-until`             | The expiration date and time for the message. If not provided, the message will not expire.<br>**Conflicts with `--ttl`.**                            | empty         | `2024-12-31T23:59:59Z`  |
| `--data`                    | Send data message instead of text (content in base64).                                                                                                | `false`       | `true`                  |
| `--data-port`               | Destination port for data message (1 to 65535).                                                                                                       | `53739`       | `12345`                 |
| `--skip-phone-validation`   | Skip phone number validation.                                                                                                                         | `false`       | `true`                  |
| `--device-active-within`    | Time window in hours for device activity filtering. `0` means no filtering.                                                                           | `0`           | `12`                    |

!!! note "Disabling booleans"
    To disable, use `--delivery-report=false`.

!!! tip
    For sending data messages, ensure the content is properly base64 encoded.  
    Example: `echo -n 'hello world' | base64` → `aGVsbG8gd29ybGQ=`

---

### Get Message Status

The `status` command retrieves the status of a message using its ID.

**Syntax:**
```bash title="Get Message Status"
smsgate status 'Message ID'
```

!!! note
    The status command requires the message ID returned from the `send` command.

## 🔗 Webhook Commands

Webhook commands allow you to manage webhooks for event notifications. The following subsections detail each webhook-related command.

### Register Webhook

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

!!! important
    Ensure your webhook endpoint is accessible from the device and properly secured.

---

### List Webhooks

The `list` command displays all registered webhooks.

**Syntax:**
```bash
smsgate webhooks list
```

!!! tip
    Use this command to audit your webhook configurations regularly.

---

### Delete Webhook

The `delete` command removes a webhook by its ID.

**Syntax:**
```bash
smsgate webhooks delete 'Webhook ID'
```

!!! warning
    Deleting a webhook is irreversible. Ensure you no longer need the webhook before deleting it.

## 📋 Logs Commands

The `logs` command retrieves logs for a specific time range. Dates should be in RFC3339 format (e.g., `2024-01-15T10:30:00Z`).

**Syntax:**
```bash
smsgate logs [options]
```

**Options:**

| Option   | Description                  | Default Value | Example                |
| -------- | ---------------------------- | ------------- | ---------------------- |
| `--from` | Start time for log retrieval | 24 hours ago  | `2024-01-15T00:00:00Z` |
| `--to`   | End time for log retrieval   | Current time  | `2024-01-15T23:59:59Z` |

!!! note
    If no time range is specified, logs for the last 24 hours are retrieved by default.

## 💡 Usage Examples

### Sending Messages

```bash
# Send a message
smsgate send --phones '+12025550123' 'Hello, Dr. Turk!'

# Send a message to multiple numbers
smsgate send --phones '+12025550123' --phones '+12025550124' 'Hello, doctors!'
# or
smsgate send --phones '+12025550123,+12025550124' 'Hello, doctors!'
```

### Getting Message Status

```bash
# Get the status of a sent message
smsgate status zXDYfTmTVf3iMd16zzdBj
```

### Getting Logs

```bash
# Get logs for the last 24 hours (default)
smsgate logs

# Get logs for a specific time range
smsgate logs --from '2024-01-15T00:00:00Z' --to '2024-01-15T23:59:59Z'

# Get logs with custom time range and output format
smsgate --format json logs --from '2024-01-15T10:00:00+07:00' --to '2024-01-15T18:00:00+07:00'
```

### Webhook Management

```bash
# Register a webhook for received messages
smsgate webhooks register --event 'sms:received' 'https://example.com/webhook'

# List all registered webhooks
smsgate webhooks list

# Delete a webhook
smsgate webhooks delete 'webhook-id'
```

### Using Docker

```bash
docker run -it --rm --env-file .env ghcr.io/android-sms-gateway/cli \
  send --phone '+12025550123' 'Hello, Dr. Turk!'
```

!!! tip
    Using Docker is ideal for CI/CD pipelines or environments where you want to avoid local installations.

## 📄 Output Formats

### Text

```text
ID: zXDYfTmTVf3iMd16zzdBj
State: Pending
IsHashed: false
IsEncrypted: false
Recipients:
        +12025550123    Pending
        +12025550124    Pending
```

### JSON

```json
{
  "id": "zXDYfTmTVf3iMd16zzdBj",
  "state": "Pending",
  "isHashed": false,
  "isEncrypted": false,
  "recipients": [
    {
      "phoneNumber": "+12025550123",
      "state": "Pending"
    },
    {
      "phoneNumber": "+12025550124",
      "state": "Pending"
    }
  ],
  "states": {}
}
```

### Raw

```json
{"id":"zXDYfTmTVf3iMd16zzdBj","state":"Pending","isHashed":false,"isEncrypted":false,"recipients":[{"phoneNumber":"+12025550123","state":"Pending"},{"phoneNumber":"+12025550124","state":"Pending"}],"states":{}}
```

## 📚 See Also

For more information about integrating the SMSGate, explore the following resources:

- [:material-github: CLI Repository](https://github.com/android-sms-gateway/cli)
- [:material-api: API Reference](./api.md)
