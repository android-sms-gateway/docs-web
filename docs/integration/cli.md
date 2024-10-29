# CLI Tool

The SMS Gateway for Android™ offers its own Command Line Interface (CLI), allowing you to integrate it into your processes without writing any code - simply execute CLI commands!

## Installation

The recommended way to install the CLI is by downloading the latest version from [GitHub](https://github.com/android-sms-gateway/cli/releases/latest) for your platform. After downloading, place the executable in a directory within your system's `PATH`.

For example, on Linux or macOS:

```bash
mv /path/to/downloaded/smsgate /usr/local/bin/smsgate
chmod +x /usr/local/bin/smsgate
```

## Configuration

The CLI can be configured using environment variables or command-line flags. You can also use a `.env` file in the working directory to set these variables.

### Available options

| Option             | Env Var        | Description      | Default value                          |
| ------------------ | -------------- | ---------------- | -------------------------------------- |
| `--endpoint`, `-e` | `ASG_ENDPOINT` | The endpoint URL | `https://api.sms-gate.app/3rdparty/v1` |
| `--username`, `-u` | `ASG_USERNAME` | Your username    | **required**                           |
| `--password`, `-p` | `ASG_PASSWORD` | Your password    | **required**                           |
| `--format`, `-f`   | n/a            | Output format    | `text`                                 |

### Output formats

The CLI supports three output formats:

- `text` - human-readable format
- `json` - formatted JSON output
- `raw` - same as `json` but without formatting

Please note that when the exit code is not `0`, the error description is printed to stderr without any formatting.

## Commands

The CLI supports the following commands:

- `send` - send a message with single or multiple recipients
- `status` - get the status of a sent message by message ID

### Send a message

Syntax:
```bash
smsgate send [options] 'Message content'
```

| Option                      | Description                                                                                | Default value | Example                 |
| --------------------------- | ------------------------------------------------------------------------------------------ | ------------- | ----------------------- |
| `--id`                      | Message ID, will be generated if not provided                                              | empty         | `zXDYfTmTVf3iMd16zzdBj` |
| `--phone`, `--phones`, `-p` | Phone number, can be used multiple times or with comma-separated values                    | **required**  | `+19162255887`          |
| `--sim`                     | SIM card slot number, if empty, the default SIM card will be used                          | empty         | `2`                     |
| `--ttl`                     | Time-to-live (TTL), if empty, the message will not expire<br>Conflicts with `--validUntil` | empty         | `1h30m`                 |
| `--validUntil`              | Valid until, if empty, the message will not expire<br>Conflicts with `--ttl`               | empty         | `2024-12-31T23:59:59Z`  |

### Get the status of a sent message

Syntax:
```bash
smsgate status 'Message ID'
```

## Usage examples

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

## Exit codes

The CLI uses exit codes to indicate the outcome of operations:

- `0`: success
- `1`: invalid options or arguments
- `2`: server request error
- `3`: output formatting error

## Links

- [CLI Tool Repository](https://github.com/android-sms-gateway/cli)
