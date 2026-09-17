# Integration - Client Libraries 📚

We offer client libraries in various programming languages to assist with integration. These libraries simplify the process of interacting with our API, allowing you to focus on building your application.

<div class="grid cards" markdown>

- **📦 Go**  
    Install the package via go get: `go get github.com/android-sms-gateway/client-go`  
    [:material-github: GitHub Repo](https://github.com/android-sms-gateway/client-go)

- **🖥️ JavaScript / TypeScript**  
    Install the package via npm: `npm install android-sms-gateway` or bun: `bun add android-sms-gateway`  
    [:material-github: GitHub Repo](https://github.com/android-sms-gateway/client-ts)

- **📝 PHP**  
    Install the package via composer: `composer require capcom6/android-sms-gateway`  
    [:material-github: GitHub Repo](https://github.com/android-sms-gateway/client-php)    

- **🐍 Python**  
    Install the package via pip: `pip install android-sms-gateway`  
    [:material-github: GitHub Repo](https://github.com/android-sms-gateway/client-py)

- **🦀 Rust**  
    Add to `Cargo.toml`: `android-sms-gateway = "0.1"`  
    [:material-github: GitHub Repo](https://github.com/android-sms-gateway/client-rs)
    
</div>

## Feature Support Matrix 📊

The following table shows which capabilities are available in each SDK. All SDKs support the core messaging API (send, status, cancel).

| Feature              | Go                 | TypeScript         | PHP                | Python             | Rust               |
| -------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| Send SMS             | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Send MMS             | :white_check_mark: | —                  | —                  | —                  | :white_check_mark: |
| Message Status       | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Message Cancellation | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| List Messages        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | —                  |
| List Devices         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | —                  |
| Inbox Refresh        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Batch Webhooks       | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Webhook Event Types  | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |

!!! note "Feature Availability"
    Features marked with — are not yet implemented in that SDK. Check each SDK's README for detailed usage and examples. New features are added across all SDKs incrementally.
