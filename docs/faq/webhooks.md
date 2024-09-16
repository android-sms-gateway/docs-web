# FAQ - Webhooks

## How to use webhooks with self-signed certificate?

To use webhooks with a self-signed certificate, follow these steps:

1. Create a `client.cnf` file with the following content:

```ini
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
# C = US
# ST = California
# L = Los Angeles
# O = Internet Corporation for Assigned Names and Numbers
# OU = IT Operations
CN = [SERVER_IP]
[v3_req]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
IP.0 = [SERVER_IP]
```

Replace `[SERVER_IP]` with the IP address of your webhook server.

2. Generate certificates using the following commands:

```shell
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ca.key -out ca.crt -reqexts v3_req -extensions v3_ca

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -extensions v3_req -config ./server.cnf
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt -extensions v3_req -extfile ./server.cnf
```

3. Install the `ca.crt` file on your device as a trusted certificate.
4. Use `server.crt` as the certificate and `server.key` as the private key for your webhook server.
