# FAQ - Webhooks

## The `sms:received` webhook is not triggering

If you're experiencing issues with the `sms:received` webhook not triggering, consider the following potential reasons and solutions:

1. **Messages are received as RCS instead of SMS:**
   RCS (Rich Communication Services) messages may not trigger the SMS webhook. To resolve this:
   1. Install Google's Messages app
   2. Set it as the default SMS app
   3. Go to Messages settings > RCS chats and turn it off

2. **Third-party messaging app is blocking SMS events:**
   Some third-party messaging apps may interfere with SMS event broadcasting. To fix this:
   - Use the device's default messaging app, or
   - Set Google's Messages app as the default SMS application

3. **App permissions:**
   - Verify that the app has the necessary permissions to read and process SMS messages

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


## How to use webhooks without internet access?

By default, webhooks require internet access and will wait until it's available to improve deliverability. However, if you're using the app in an isolated environment without internet access, you can disable this requirement. Here's how:

1. Open the app and navigate to the "Settings" tab.
2. Find the "Webhooks" section.
3. Locate the "Require Internet connection" option.
4. Switch off this option to allow webhooks to function without internet access.

Please note that disabling this feature may impact the reliability of webhook delivery if one or more webhook receivers are located outside the device's network.
