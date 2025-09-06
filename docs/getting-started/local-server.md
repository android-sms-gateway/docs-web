# 🚀 Getting Started

## ⚙️ Local Server Mode

<div align="center">
    <img src="/assets/local-server-arch.png" alt="Architecture of the Local Server mode">
</div>

This mode is ideal for sending messages from a local network, enabling direct communication between the device and your app on the same Wi‑Fi or Ethernet network without requiring internet access.

1. Launch the app on your device.
2. Toggle the `Local Server` switch to the "on" position.
3. Tap the status button (labeled `Offline`) at the bottom of the screen to start the server; it will switch to `Online` when running.
4. The `Local Server` section will display your device's local and public IP addresses, as well as the credentials for basic authentication.

    !!! note "Public IP Accessibility"
        The displayed public IP address is only accessible from the internet if your device has a public IP assigned by your ISP and your firewall/router allows connections to the specified port (with port forwarding configured). Many ISPs use Carrier-Grade NAT (CG‑NAT), which prevents direct internet access to devices behind shared addresses. See also: [FAQ — Local Server](../faq/local-server.md).

5. To send a message from within the local network, execute a `curl` command like the following. Be sure to replace `<username>`, `<password>`, and `<device_local_ip>` with the actual values provided in the previous step:

    ```sh title="Send SMS via Local Server API"
    curl -X POST -u <username>:<password> \
        -H "Content-Type: application/json" \
        -d '{ "textMessage": { "text": "Hello, world!"}, "phoneNumbers": ["+79990001234", "+79995556677"] }' \
        http://<device_local_ip>:8080/message
    ```

### 📖 Accessing Swagger UI

To access the **Swagger UI** for API documentation and testing, follow these steps:

1. After starting the local server, open `http://<device_local_ip>:8080/docs` in your browser.
2. Enter your **API credentials**—use the same username and password configured for API authentication.
3. Once authenticated, you'll see the interactive **Swagger UI** for exploring and testing API endpoints.

!!! tip "Benefits of Swagger UI"
    - **Interactive documentation** – test endpoints directly in the browser
    - **Automatic validation** – see formatted responses and error messages
    - **Security** – same authentication as the API
    - **Convenience** – no manual `curl` commands


### ⚙️ Server Configuration

To modify the port, username, or password:

1. Open the app and navigate to the "Settings" tab
2. Locate the "Local Server" section
3. Update the port, username, or password as needed
4. Return to the "Home" tab
5. Stop and restart the server using the button at the bottom of the screen to apply the changes

#### Requirements

* Port number must be between 1024 and 65535
* Username must be at least 3 characters long
* Password must be at least 8 characters long

## 📚 See Also

- [Public Cloud Server Mode](./public-cloud-server.md) for internet-accessible messaging
- [Private Server Mode](./private-server.md) for self-hosted solutions
- [API Integration Guide](../integration/api.md) for detailed API specifications
- [Webhooks Documentation](../features/webhooks.md) for automated workflows
