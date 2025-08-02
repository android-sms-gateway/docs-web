# Getting Started

## Local Server

<div align="center">
    <img src="/assets/local-server-arch.png" alt="Architecture of the Local Server mode">
</div>

This mode is ideal for sending messages from a local network.

1. Launch the app on your device.
2. Toggle the `Local Server` switch to the "on" position.
3. Tap the `Offline` button located at the bottom of the screen to activate the server.
4. The `Local Server` section will display your device's local and public IP addresses, as well as the credentials for basic authentication. Please note that the public IP address is only accessible if you have a public (also known as "white") IP and your firewall is configured appropriately.
    <div align="center">
        <img src="/assets/local-server.png" alt="Example settings for Local Server mode">
    </div>
5. To send a message from within the local network, execute a `curl` command like the following. Be sure to replace `<username>`, `<password>`, and `<device_local_ip>` with the actual values provided in the previous step:

    ```sh
    curl -X POST -u <username>:<password> \
        -H "Content-Type: application/json" \
        -d '{ "textMessage": { "text": "Hello, world!"}, "phoneNumbers": ["+79990001234", "+79995556677"] }' \
        http://<device_local_ip>:8080/message
    ```

### Accessing Swagger UI

To access the **Swagger UI** for API documentation and testing, follow these steps:

1. After starting the local server, open `http://<device_local_ip>:8080/docs` in your browser.
2. Enter your **API credentials**—use the same username and password configured for API authentication.
3. Once authenticated, you'll see the interactive **Swagger UI** for exploring and testing API endpoints.

!!! tip "Benefits of Swagger UI"
    - **Interactive documentation** – test endpoints directly in the browser
    - **Automatic validation** – see formatted responses and error messages
    - **Security** – same authentication as the API
    - **Convenience** – no manual `curl` commands


### Server Configuration

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
