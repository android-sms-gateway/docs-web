# ❓ FAQ - Local Server

## 🌐 Why can't I access the local server from the internet?

The public IP address displayed in the Local Server section is only accessible from the internet if:

1. Your ISP assigns a public ("white") IP address to your device
2. Your router/firewall allows incoming connections to the specified port and has a port-forwarding rule to the device’s local IP

!!! warning "CG-NAT Issue"
    Many ISPs use Carrier-Grade NAT (CG-NAT), which assigns shared addresses and blocks direct internet connections to devices. This is the default for many providers.

### Solutions ⚡

If your public IP address is not accessible from the internet due to CG-NAT or other network restrictions, consider these workarounds:

1. **Obtain Public IP from ISP** 🔧
    Contact your internet service provider and request a public IP address assignment.

2. **Use Tunneling Services** 🔀
    Set up secure tunneling with tools like [ngrok](https://ngrok.com/) or [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/). These run on your device or a computer and expose a public endpoint.

3. **Use Dynamic DNS** 🧭
   If you have a public (but dynamic) IP, configure Dynamic DNS (DDNS) on your router to keep a stable hostname pointed at your device.

4. **Switch to Cloud Server Mode** ☁️
   Use [Cloud Server mode](../getting-started/public-cloud-server.md), which works with any internet connection without requiring public IP configuration.

## 📶 How can I check the online status of the device in Local mode?

You can verify the device's online status with two quick checks:

1. **API health** – open `http://<device_ip>:<port>/health` in a browser or HTTP client. A successful response confirms the Local Server is running.
2. **Network reachability** – run `ping <device_ip>` from your PC. If there is no response, the Wi-Fi connection may have dropped, often due to the phone's Wi-Fi entering a low-power mode.

## 📵 Why does the Local Server disconnect on my Android device?

The Android OS may kill background apps to save battery, causing the Local Server to stop running. This is common on certain devices, especially those from Xiaomi, Samsung, and other manufacturers known for aggressive battery optimization.

To prevent this:

- Keep your device connected to a charger while using the app
- Disable battery optimization directly from the app: in SMS Gate, open **Settings → System** and tap the battery optimization option
- Alternatively, disable battery optimization for SMS Gate in your Android device settings
- Follow specific instructions for your phone model at [dontkillmyapp.com](https://dontkillmyapp.com/)

Additionally, check if the SMS Gate notification icon is still visible in the status bar (a persistent notification is shown while the Local Server is running). If it's missing, the app was likely killed by the OS.

## 🔑 How do I change my password in Local mode?

For Local mode, password management is handled through the [Server Configuration](../getting-started/local-server.md#server-configuration) section.

## 🔐 What authentication methods are supported in Local Server mode?

Local Server mode **only supports Basic Authentication**. JWT authentication is not available in this mode.

!!! tip "Future Support"
    JWT authentication for local server mode is planned for a future release to provide a consistent API across all deployment modes.
