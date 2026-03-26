# Custom Gateway Setup 🛠️

Please consider the [Private Server](./private-server.md) mode first. It offers additional privacy features and is not significantly different from a self-built solution—with far fewer setup operations required.

!!! note "Please note"
    - Custom builds are not officially supported
    - No troubleshooting assistance provided


## Before You Begin ⚠️

!!! danger "Secure Your Deployment"
    Default configuration exposes public endpoints. You must implement:

    - Firewall rules
    - HTTPS encryption
    - Additional authentication mechanisms if necessary
  
    **Use at your own risk**

## Prerequisites 📋

1. 📱 **Android Development**
    - Android Studio 2023.2+
    - SDK API Level 33

2. 🔥 **Firebase Setup**
    - Google Cloud account
    - FCM-enabled project
    - Service account credentials

3. 🗄️ **Database**
    - MySQL 8.0+ / MariaDB 10.6+
    - 2GB+ storage allocated

4. ☁️ **Server Infrastructure**
    - VPS with public IP
    - Reverse proxy (Nginx/Traefik)
    - Valid SSL certificate

5. ⚙️ **Build Tools**
    - Go 1.24+
    - Docker 24.0+

## Backend Configuration ⚙️

=== ":material-cloud: Public Mode"
    ```yaml title="config.yml"
    gateway:
      mode: public
    fcm:
      credentials_json: |
        {
          "type": "service_account",
          "project_id": "your-project"
        }
    ```
    **Implementation Steps**:

    1. Follow [Private Server Guide](./private-server.md)
    2. Set `gateway.mode: public`
    3. Update FCM credentials

=== ":material-lock: Private Mode"
  ```yaml title="config.yml (gateway section)"
  gateway:
    mode: private
    upstream_url: https://your-main-server.com/api/upstream/v1
  ```
  **Build Commands**:
  ```bash
  make build  # Binary
  make docker-build  # Container
  ```
    
    !!! info "Architecture Requirement"
        Private servers require at least one public server

        Communication flow: Device ↔ Private Server ↔ Public Server ↔ FCM
---

## Android App Customization 📱

1. **Clone Repository**
    ```bash
    git clone https://github.com/capcom6/android-sms-gateway
    cd android-sms-gateway
    ```

2. **Configure Endpoints**  
    Edit `app/src/main/java/me/capcom/smsgateway/modules/gateway/GatewaySettings.kt` by replacing `PUBLIC_URL` with your main server URL (including path):
    ```diff
    - const val PUBLIC_URL = "https://api.sms-gate.app/mobile/v1"
    + const val PUBLIC_URL = "https://your-main-server.com/mobile/v1"
    ```

3. **Set Unique Application ID**  
    Modify `app/build.gradle` by replacing `applicationId` value with your unique application ID:
    ```diff
    - applicationId "me.capcom.smsgateway"
    + applicationId "com.yourcompany.smsgateway"
    ```

4. **Firebase Integration**  
    Follow the [Firebase Android Setup Guide](https://firebase.google.com/docs/android/setup) to get the `google-services.json` file and add it to `app/google-services.json`.

5. **Build & Deploy**  
    ```bash
    ./gradlew assembleRelease
    ```

## Security Checklist 🔐

- [ ] Implement IP whitelisting
- [ ] Configure HTTPS with HSTS
- [ ] Set up rate limiting
- [ ] Enable audit logging
- [ ] Rotate API keys quarterly

## See Also 📚

- [:material-github: GitHub Discussion #71](https://github.com/capcom6/android-sms-gateway/discussions/71)
