# Healthcheck

The app provides a healthcheck endpoint at `/health` that you can use to check the status of the app. The response of the healthcheck differs for Local and Cloud/Private modes. Additionally, you can receive health information via the `system:ping` webhook.

In all modes, a response code of `200` indicates normal app operation.

The health information includes:

* **releaseId**: A unique identifier for the app release.
* **version**: The app version.
* **status**: The overall app status.
    * **pass**: The app is running normally.
    * **warn**: The app is running with some issues.
    * **fail**: The app is not running normally.
* **checks**: A list of health checks performed by the app.
    * **description**: A description of the health check.
    * **observedUnit**: The unit of the observed value.
    * **observedValue**: The value observed by the health check.
    * **status**: The status of the health check.

## Local Mode

In Local mode, the healthcheck endpoint provides information about the device and the application.

Example response:

```json
{
  "checks": {
    "messages:failed": {
      "description": "Failed messages for last hour",
      "observedUnit": "messages",
      "observedValue": 0,
      "status": "pass"
    },
    "connection:status": {
      "description": "Internet connection status",
      "observedUnit": "Yes/No",
      "observedValue": 1,
      "status": "pass"
    },
    "connection:transport": {
      "description": "Network transport type",
      "observedUnit": "flags",
      "observedValue": 4,
      "status": "pass"
    },
    "connection:cellular": {
      "description": "Cellular network type",
      "observedUnit": "index",
      "observedValue": 0,
      "status": "pass"
    },
    "battery:level": {
      "description": "Battery level in percent",
      "observedUnit": "percent",
      "observedValue": 94,
      "status": "pass"
    },
    "battery:charging": {
      "description": "Is the phone charging?",
      "observedUnit": "flags",
      "observedValue": 4,
      "status": "pass"
    }
  },
  "releaseId": 1,
  "status": "pass",
  "version": "1.0.0"
}
```

### Available health checks

* **messages:failed**: The number of failed messages for the last hour. `warn` when there is at least one failed message and `fail` when all messages during the last hour have failed.
* **connection:status**: The status of the internet connection. `fail` when the Internet connection is not available.
* **connection:transport**: The transport type of the network connection. When the device is connected to multiple networks, only a single value is provided:
    * 0: None
    * 1: Unknown
    * 2: Cellular
    * 4: WiFi
    * 8: Ethernet
* **connection:cellular**: The cellular network type. Availible only it `connection:transport` has flag `2: Cellular`, otherwise `0: None`.
    * 0: None
    * 1: Unknown
    * 2: Mobile2G
    * 3: Mobile3G
    * 4: Mobile4G
    * 5: Mobile5G
* **battery:level**: The battery level in percent. `warn` when less than 25% and `fail` when less than 10%.
* **battery:charging**: The status of charging as bit flags. For example, if the device is charging via USB, the value will be `1 + 4 = 5`.
    * 0: Not charging
    * 1: Charging
    * 2: AC charger connected
    * 4: USB charger connected

## Cloud Mode

The health endpoint in cloud mode provides information about the server, not devices.

If you need to receive device health information in Cloud or Private modes, you can use the `system:ping` webhook.

Example response:

```json
{
  "status": "pass",
  "version": "v1.17.0",
  "releaseId": 932,
  "checks": {
    "db:ping": {
      "description": "Failed sequential pings count",
      "observedValue": 0,
      "status": "pass"
    }
  }
}
```

The only provided health check is `db:ping`. It checks the database connectivity and counts failed sequential pings.

## Webhooks

In any mode, you can utilize the `system:ping` webhook to receive health information about the devices. The webhook payload will be the same as the device's healthcheck response.

Example payload:

```json
{
  "deviceId": "ffffffffceb0b1db00000192672f2204",
  "event": "system:ping",
  "id": "mjDoocQLCsOIDra_GthuI",
  "payload": {
    "health": {
      "checks": {
        "messages:failed": {
          "description": "Failed messages for last hour",
          "observedUnit": "messages",
          "observedValue": 0,
          "status": "pass"
        },
        "connection:status": {
          "description": "Internet connection status",
          "observedUnit": "Yes/No",
          "observedValue": 1,
          "status": "pass"
        },
        "connection:transport": {
          "description": "Network transport type",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        },
        "connection:cellular": {
          "description": "Cellular network type",
          "observedUnit": "index",
          "observedValue": 0,
          "status": "pass"
        },
        "battery:level": {
          "description": "Battery level in percent",
          "observedUnit": "percent",
          "observedValue": 94,
          "status": "pass"
        },
        "battery:charging": {
          "description": "Is the phone charging?",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        }
      },
      "releaseId": 1,
      "status": "pass",
      "version": "1.0.0"
    }
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

The webhook allows you to monitor the health of your devices in real-time, providing valuable information about message delivery, connectivity, and battery status.

## Links

- [Webhooks Guide](./webhooks.md)
