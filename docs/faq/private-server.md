# ❓ FAQ - Private Server

## 📱 Why can't the Android app connect to my private server?

If the Android app cannot find or connect to your private server, check the following:

### 1. API URL Format

The API URL **must** include the full path `/api/mobile/v1`. Using just the base URL will not work.

!!! example "Correct URL Format"
    ```text
    https://private.example.com/api/mobile/v1
    ```

!!! danger "Common Mistake"
    The cloud server uses URL rewriting where `api.sms-gate.app` already contains the `api` part. With a private server, you must include `/api` in the path.

### 2. HTTPS Requirement

The Android app **requires HTTPS** for all communications with your private server unless you use an insecure build variant. Using HTTP will result in connection failures.

!!! tip "SSL Certificate Options"
    - Use [Let's Encrypt](https://letsencrypt.org/) for a free, trusted certificate
    - Use our [project CA](../services/ca.md) for private IP addresses
    - Use a tunneling service like [ngrok](https://ngrok.com/) or [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) for testing

### 3. Network Connectivity

Ensure your server is accessible from the device's network:

- Check firewall rules allow incoming connections on your server port
- Verify DNS resolution if using a domain name
- Test connectivity with `curl https://your-server.com/health` from the device network

## 📊 How do I verify my private server is working?

Test your server with a health check:

```bash
curl https://private.example.com/health
```

A successful response returns JSON with server status information.

!!! tip "SSL Verification"
    If using a self-signed certificate, you may need to use `curl -k` or `curl --insecure` for testing, but the Android app requires a valid certificate.

## 📫 How do I send messages from external applications?

To send messages or interact with your private server from external applications, you must use the **`/api/3rdparty/v1`** endpoint.

!!! example "Sending Messages via API"
    ```bash
    curl -X POST "https://private.example.com/api/3rdparty/v1/messages" \
      -u "username:password" \
      -H "Content-Type: application/json" \
      -d '{
        "phoneNumbers": ["+1234567890"],
        "textMessage": {"text": "Hello World"}
      }'
    ```

!!! note "URL Path Difference"
    The cloud server uses `https://api.sms-gate.app/3rdparty/v1/messages` because the domain already contains `api`. With a private server, you need `/api/3rdparty/v1/...`.
