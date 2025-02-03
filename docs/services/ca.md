# Certificate Authority

The project has its own [Certificate Authority (CA)](https://en.wikipedia.org/wiki/Certificate_authority) to simplify some operations while providing an additional level of security.

Currently, the only certificate type available is a private webhook certificate.

## Private Webhook Certificate

Due to Android OS restrictions and the application's privacy policy, webhook events can only be received through an encrypted HTTPS connection. Since it's not possible to issue certificates for private IP addresses from trusted CAs, it was previously necessary to use self-signed certificates. However, issuing and installing valid self-signed certificates was not easy, and adding them to the global Android storage created a security risk. Therefore, we've created a private CA that issues certificates for private IP addresses.

### How to Use

There are two main ways to use it:

1. (Recommended) Issue certificate with the `smsgate-ca` command:
    1. Download the CLI tools package for your platform from [Releases](https://github.com/android-sms-gateway/cli/releases/latest).
    2. Extract the package.
    3. Run the `./smsgate-ca webhooks <your-ip>` command, where `<your-ip>` is the private IP address of your webhook server.
    4. Install the `server.crt` and `server.key` files to the webhook server.

2. Direct use of the CA's API. Please refer to the [API Documentation](https://ca.sms-gate.app/docs):
    1. Create a Private Key: `openssl genrsa -out server.key 2048`
    2. Create a config file `server.cnf` with the following content, replacing `[SERVER_IP]` with your private IP address:
        ```ini
        [req]
        distinguished_name = req_distinguished_name
        x509_extensions = v3_req
        prompt = no
        [req_distinguished_name]
        CN = [SERVER_IP]
        [v3_req]
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        extendedKeyUsage = serverAuth
        subjectAltName = @alt_names
        [alt_names]
        IP.0 = [SERVER_IP]
        ```
    3. Generate a certificate request: `openssl req -new -key server.key -out server.csr -extensions v3_req -config ./server.cnf`
    4. Make a request to the CA:
        ```sh
        jq -n --arg content "$(cat server.csr)" '{content: $content}' | \
        curl -X POST \
          -H "Content-Type: application/json" \
          -d @- \
          https://ca.sms-gate.app/api/v1/csr
        ```
        You will receive a Request ID in the response.
    5. Check the status of the request:
        ```sh
        curl -X GET \
          -H "Content-Type: application/json" \
          https://ca.sms-gate.app/api/v1/csr/[REQUEST_ID]
        ```
    6. When the request is approved, the certificate content will be provided in the `certificate` field of the response.
    7. Save the certificate content to the file `server.crt`.
    8. Install the `server.crt` and `server.key` (from step 1) files to the webhook server.

**Note** You don't have to install any certificates on the device. The project's Root CA certificate is already included in the app since version `1.31`.

### Limitations

The CA only issues certificates for private IP addresses within the following ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16.

### Notes

Support for user-provided self-signed certificates will be removed in version 2.x of the app. It is strongly recommended to use the project's CA for generating certificates.
