# Certificate Authority 🔐

The project operates its own [Certificate Authority (CA)](https://en.wikipedia.org/wiki/Certificate_authority) :material-shield-lock-outline: to simplify secure communications while maintaining high security standards.

!!! info "Security Considerations"
    - 🔒 HTTPS encryption is mandatory for all communications
    - 🌍 Public CA certificates can't validate private IPs
    - ⚠️ User-provided certificate installation creates security risks

## Supported Certificate Types 📜

1. 🌐 **Private Webhook Certificate** - Secure local network webhook endpoints
2. 🖥️ **Private Server Certificate** - Encrypt private server communications

## How to Use 🛠️

### Method Comparison

| Feature         | CLI Method 🖥️               | API Method 🌐                      |
| --------------- | -------------------------- | --------------------------------- |
| Difficulty      | :material-star: Easy       | :material-star-circle: Medium     |
| Customization   | :material-wrench-clock: No | :material-wrench-check: Available |
| Automation      | :material-robot: Full      | :material-hand-back-right: Manual |
| Recommended For | Most users ✅               | CI/CD pipelines 🤖                 |

=== ":material-console-line: CLI Method"

    1. 📥 **Download Tool**  
        Get [`smsgate-ca`](https://github.com/android-sms-gateway/cli/releases/latest) for your OS

    2. 🔧 **Generate Certificate**  
        ```bash title="Generate webhook certificate"
        ./smsgate-ca webhooks --out=server.crt --keyout=server.key 192.168.1.10
        ```
        ```bash title="Generate server certificate"
        ./smsgate-ca private 10.0.0.5 # (1)!
        ```
 
        1. `--out` and `--keyout` are optional with default `server.crt` and `server.key`

    3. 🔐 **Install Certificates**  
        ```bash
        # Nginx example
        ssl_certificate /path/to/server.crt;
        ssl_certificate_key /path/to/server.key;
        ```

=== ":material-api: API Method"

    1. 🔑 **Generate Key Pair**
        ```bash
        openssl genrsa -out server.key 2048
        ```

    2. 📝 **Create Config**
        ```ini title="server.cnf" hl_lines="7 15"
        [req]
        distinguished_name = req_distinguished_name
        x509_extensions = v3_req
        prompt = no
        
        [req_distinguished_name]
        CN = 192.168.1.10  # (1)!
        
        [v3_req]
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        extendedKeyUsage = serverAuth
        subjectAltName = @alt_names
        
        [alt_names]
        IP.0 = 192.168.1.10
        ```

        1. Replace `192.168.1.10` with your private IP

    3. 📋 **Generate CSR**
        ```bash
        openssl req -new -key server.key -out server.csr -extensions v3_req \
          -config ./server.cnf
        ```

    4. 📨 **Submit CSR**
        ```sh
        jq -n --arg content "$(cat server.csr)" '{content: $content}' | \
        curl -X POST \
          -H "Content-Type: application/json" \
          -d @- \
          https://ca.sms-gate.app/api/v1/csr
        ```

        You will receive a Request ID in the response.

    5. 🕒 **Check Status**
        ```bash
        curl https://ca.sms-gate.app/api/v1/csr/REQ_12345 # (1)!
        ```

        1. Replace `REQ_12345` with your Request ID

    6. 📥 **Save Certificate**  
        When the request is approved, the certificate content will be provided in the `certificate` field of the response. Save the certificate content to the file `server.crt`.

    7. 🔐 **Install Certificate**  
        Install the `server.crt` and `server.key` (from step 1) files to the server.

    Full API documentation is available [here](https://ca.sms-gate.app/docs/index.html).

## Limitations ⚠️

The Certificate Authority service has the following limitations:

- 🔐 Only issues certificates for private IP ranges:
    ```text
    10.0.0.0/8
    172.16.0.0/12 
    192.168.0.0/16
    ```
- ⏳ Certificate validity: 1 year
- 📛 Maximum 1 `POST` request per minute

## Migration Notice 🚨

Self-signed certificates will be deprecated after v2.0 release. It is recommended to use the project's CA :material-shield-lock-outline: instead.

Migration checklist:

- [ ] Replace self-signed certs before v2.0 release
- [ ] Update automation scripts to use CLI tool or API
- [ ] Rotate certificates every 1 year

## FAQ ❓

:material-help-circle: **Why don't I need to install CA on devices?**  
The root CA certificate is already embedded in the app (:material-android: 1.31+) 

:material-alert: **Certificate issuance failed?**  
Ensure your IP matches private ranges and hasn't exceeded quota
