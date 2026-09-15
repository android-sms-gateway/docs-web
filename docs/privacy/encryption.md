# Encryption 🔒

The application supports end-to-end encryption by encrypting sensitive fields before sending them to the API and decrypting them on the device. This ensures that no one – including us as the service provider, the hosting provider, or any third parties – can access the content and recipients of the messages.

Two encryption modes are supported:

- **Device-paired E2E encryption** (recommended): the device generates an RSA-2048 key pair; third-party clients encrypt messages with the device's public key, and only the device can decrypt them. No passphrase is shared between the sender and the device.
- **Passphrase encryption** (legacy): both sides share a passphrase; messages are encrypted with AES-256-CBC derived from it via PBKDF2.

The device automatically detects the format by its prefix, so both modes can be used in parallel.

!!! important "Encryption Scope"
    Only specific fields should be encrypted:

    - For text messages: `textMessage.text` field
    - For data messages: `dataMessage.data` field
    - All values in the `phoneNumbers` array
    
    Other fields like `id`, `simNumber`, `ttl`, etc. should remain unencrypted.

Please note that using encryption will increase device battery usage.

## Device-Paired E2E Encryption 🔑

End-to-end encryption with device-paired keys removes the need to share a passphrase: the Android device generates an RSA-2048 key pair, keeps the private key on the device, and publishes only the public key to the server. Third-party clients fetch the public key from the device listing and encrypt each message for that device.

### How it works

1. The Android app generates an RSA-2048 key pair before registration.
2. The private key never leaves the device: it is stored in the Android Keystore.
3. The public key is uploaded to the server during registration or via a device update, together with the key version.
4. Third-party clients list devices, read `publicKey` + `keyVersion`, and encrypt each message with the hybrid scheme below. On first use, verify the key out of band first (see [Trust model and key verification](#trust-model-and-key-verification)).
5. The device decrypts the message with its private key before sending.

### Encryption format

Every encrypted value (message body and each phone number) is a single UTF-8 string with exactly 7 `$`-separated chunks:

```
$rsa-oaep-aes-256-gcm$v=1$k={keyVersion}${base64(encrypted_aes_key)}${base64(iv)}${base64(ciphertext || 16-byte tag)}
```

| Chunk | Content                     | Meaning                                             |
| ----- | --------------------------- | --------------------------------------------------- |
| 0     | (empty)                     | Leading `$`; MUST be present                        |
| 1     | `rsa-oaep-aes-256-gcm`      | Format identifier (constant)                        |
| 2     | `v=1`                       | Format version; only `1` is valid                   |
| 3     | `k={keyVersion}`            | Key version (positive integer, device-sourced)      |
| 4     | base64(encrypted AES key)   | 256-byte RSA-OAEP ciphertext of the 32-byte AES key |
| 5     | base64(iv)                  | 12-byte GCM IV                                      |
| 6     | base64(ciphertext \|\| tag) | AES-GCM ciphertext with the 16-byte tag appended    |

### Algorithms

- **RSA-OAEP** (asymmetric): RSA-2048, `RSA/ECB/OAEPWithSHA-256AndMGF1Padding`, SHA-256 hash, MGF1-SHA-256, empty label. Wraps the fresh 32-byte AES key. Randomized per RFC 8017 (the encrypted AES key differs on every encryption).
- **AES-256-GCM** (symmetric): 32-byte key (never 12 bytes – 12 bytes is the IV length), 12-byte IV, 128-bit tag, empty AAD. Chunk 6 is `ciphertext || tag`.
- **Base64**: standard RFC 4648 alphabet with padding (`=`), no line breaks (NO_WRAP).

### Key management and keyVersion

- The **device is the source of truth** for the key version. The server stores the version as-is; it never auto-assigns or increments it.
- Versions start at `1` and increment on each rotation. Retired key material is kept on the device, so messages encrypted with previous versions stay decryptable until the retention window expires: a key is deleted 7 days after it was retired. The device does not cap the number of retained keys.
- `k={keyVersion}` in chunk 3 MUST embed the value from the device listing (`keyVersion` field) exactly.
- Public keys are stored as base64 (NO_WRAP) of the X.509 SPKI DER encoding of the RSA public key.

### Trust model and key verification

The API server is the sole distributor of device public keys: `publicKey` and `keyVersion` are only available from the device listing (`GET /3rdparty/v1/devices`). Transport between clients and the server is protected by TLS, and E2E encryption ensures the server cannot read message content. The server is trusted for key distribution, however: a compromised or malicious server can substitute an attacker-controlled public key, and messages encrypted to that substituted key are readable by the key's owner. **E2E encryption does not protect against server compromise or a malicious server operator.**

!!! warning "Server is trusted for key distribution"
    E2E encryption protects message content from the server only while the server distributes the genuine public key. A compromised or malicious server can replace `publicKey` with a key it controls, and all messages encrypted to the substituted key are readable by the key's owner.

#### Out-of-band fingerprint verification (TOFU)

Because the server (and anyone who compromises it) can replace the published public key, verify the device key fingerprint out of band on first use:

1. Fetch the device listing and take the target device's `publicKey` value.
2. Compute the fingerprint of that value (algorithm below) and ask the device owner to read the fingerprint from the app: Settings -> Device -> Device Key -> "Key fingerprint" (tap to copy). Compare the two fingerprints character by character.
3. When they match, pin the fingerprint together with `keyVersion`: store both and treat any future change of either value as a security event. Fail closed - do not encrypt to the new key - until the change has been re-verified out of band.
4. The fingerprint changes on every key rotation; this is expected and safe once the new key has been re-verified out of band.

The fingerprint is the SHA-256 hash of the base64-decoded (NO_WRAP) X.509 SPKI DER encoding of `publicKey`, rendered as uppercase hexadecimal in 16 groups of 4 characters separated by `:` (64 characters total):

```text title="Fingerprint format"
A1B2:C3D4:E5F6:7890:ABCD:EF12:3456:7890:1111:2222:3333:4444:5555:6666:7777:8888
```

### Sending E2E-encrypted messages (third-party clients)

1. Fetch the device list via `GET /3rdparty/v1/devices`; each device exposes `publicKey` (nullable) and `keyVersion` (nullable). On first use, verify the key fingerprint out of band (see [Trust model and key verification](#trust-model-and-key-verification)).
2. Set `deviceId` in the message to the target device. This is **required** – the server routes by `deviceId`, and a missing value selects a random device, which would make the message undecryptable.
3. Encrypt `textMessage.text` (or `dataMessage.data` – the base64 payload string) and **every** value in `phoneNumbers` with the format above, using a **fresh 12-byte IV per value** (never share an IV; GCM nonce reuse is catastrophic).
4. Set `isEncrypted` to `true`. The server then skips phone-number validation and message hashing and stores the encrypted values verbatim.

### Delivery status correlation

There is no recipient identifier field: the encrypted phone string itself is the correlation key. When polling delivery status, echo the exact encrypted phone string (the full 7-chunk value) as `phoneNumber` in the recipient state; the server matches it byte-for-byte.

### Data messages

For `dataMessage`, encrypt the `dataMessage.data` string (the base64 payload) with the same scheme. The device decrypts the E2E value back to the base64 string and then decodes it. The `port` field is not encrypted.

### Key rotation

- The device generates a new key pair, uploads `publicKey` + `keyVersion` (the new version) to the server.
- Old private keys are retained so messages encrypted with previous versions remain decryptable; a retired key is deleted 7 days after it was retired.
- After rotation, SDKs must re-fetch the listing: encrypting with a key version that has been rotated out produces a message that remains decryptable only until that key's retention window expires (7 days after retirement).

!!! warning "Retention vs. message lifetime"
    The API allows messages with no expiration, long `ttl`/`validUntil` values, and future `scheduleAt` dates. A message that is still pending when the key it was encrypted to is deleted (7 days after retirement) can no longer be decrypted. Keep the message's lifetime inside the retention window, or re-encrypt it with the current key version from the listing.

## Passphrase Encryption 🔒

1. For text messages: encrypt the `textMessage.text` field
2. For data messages: encrypt the `dataMessage.data` field
3. Encrypt every value in the `phoneNumbers` array
4. Set the `isEncrypted` field to `true`
5. Use the same passphrase on both client and device

## Algorithm ⚙️

1. Select a passphrase that will be used for encryption and specify it on the device
2. Generate a random salt (16 bytes recommended)
3. Create a secret key using PBKDF2 with:
    - SHA1 hash function
    - 256-bit key size
    - Iteration count (see [Iteration Count Recommendations](#iteration-count-recommendations) below)
4. Encrypt the target fields separately using AES-256-CBC
5. Encode encrypted values as Base64
6. Format each encrypted value as:
   `$aes-256-cbc/pbkdf2-sha1$i=<iterations>$<base64 salt>$<base64 encrypted data>`

## Iteration Count Recommendations 🔢

### OWASP Guidelines

According to [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html), the recommended minimum iteration count for PBKDF2-SHA1 is **1,400,000 iterations** as of 2026. This provides stronger security against brute-force attacks by making key derivation more computationally expensive.

### Application Default

**The current default iteration count is 75,000**, which is significantly lower than the OWASP recommendation of 1,400,000 iterations. The iteration ranges suggested in this document are intentionally below OWASP guidelines to maintain device compatibility. This deliberate choice balances security with performance on older devices:

- The application supports devices running **Android 5.0 (API level 21)** and above
- On older devices, even 75,000 iterations can cause decryption to take **several seconds**
- Higher iteration counts would make the user experience unacceptable on these devices

### Security Considerations

While we recommend using the highest iteration count your use case can tolerate, consider these factors:

1. **Device Performance**: Higher iterations increase CPU usage and battery consumption
2. **User Experience**: Decryption time increases linearly with iteration count
3. **Security Needs**: Evaluate the sensitivity of your data and threat model

!!! tip "Recommended Approach"
    - **Compatibility-driven (below OWASP)**: For new deployments on modern devices (Android 10+), consider using **300,000-600,000 iterations**; for broad device compatibility including older devices, **75,000-150,000 iterations** provides reasonable security. Note that these ranges accept increased residual risk of brute-force attacks in exchange for usability on older/lower-powered devices.
    - The iteration count is stored in the encrypted format, allowing different values per message

## Implementation Examples 💻

=== "PHP"
    ```php
    <?php 
    
    class Encryptor {
        protected string $passphrase;
        protected int $iterationCount;
    
        /**
         * Encryptor constructor.
         * @param string $passphrase Passphrase to use for encryption
         * @param int $iterationCount Iteration count
         */
        public function __construct(
            string $passphrase,
            int $iterationCount = 75000
        ) {
            $this->passphrase = $passphrase;
            $this->iterationCount = $iterationCount;
        }
    
        public function Encrypt(string $data): string {
            $salt = $this->generateSalt();
            $secretKey = $this->generateSecretKeyFromPassphrase($this->passphrase, $salt, 32, $this->iterationCount);
    
            return sprintf(
                '$aes-256-cbc/pbkdf2-sha1$i=%d$%s$%s',
                $this->iterationCount,
                base64_encode($salt),
                openssl_encrypt($data, 'aes-256-cbc', $secretKey, 0, $salt)
            );
        }
    
        public function Decrypt(string $data): string {
            list($_, $algo, $paramsStr, $saltBase64, $encryptedBase64) = explode('$', $data);
    
            if ($algo !== 'aes-256-cbc/pbkdf2-sha1') {
                throw new \RuntimeException('Unsupported algorithm');
            }
    
            $params = $this->parseParams($paramsStr);
            if (empty($params['i'])) {
                throw new \RuntimeException('Missing iteration count');
            }
    
            $salt = base64_decode($saltBase64);
            $secretKey = $this->generateSecretKeyFromPassphrase($this->passphrase, $salt, 32, intval($params['i']));
    
            return openssl_decrypt($encryptedBase64, 'aes-256-cbc', $secretKey, 0, $salt);
        }
    
        protected function generateSalt(int $size = 16): string {
            return random_bytes($size);
        }
    
        protected function generateSecretKeyFromPassphrase(
            string $passphrase,
            string $salt,
            int $keyLength = 32,
            int $iterationCount = 75000
        ): string {
            return hash_pbkdf2('sha1', $passphrase, $salt, $iterationCount, $keyLength, true);
        }
    
        /**
         * @return array<string, string>
         */
        protected function parseParams(string $params): array {
            $keyValuePairs = explode(',', $params);
            $result = [];
            foreach ($keyValuePairs as $pair) {
                list($key, $value) = explode('=', $pair, 2);
                $result[$key] = $value;
            }
            return $result;
        }
    }
    ```

    [Source](https://github.com/capcom6/android-sms-gateway-php/blob/master/src/Encryptor.php)

=== "TypeScript"
    Please note, that Bun's implementation of the `crypto` package is not optimized as of 2024, so it is much slower than Node's implementation.
    
    ```typescript
    import crypto from "crypto";
    
    class Encryptor {
        constructor(protected readonly passphrase: string, protected readonly iterations: number = 75_000) {
    
        }
    
        public Decrypt(input: string): string {
            const parts = input.split("$");
            if (parts.length !== 5) {
                throw new Error("Invalid encrypted text");
            }
    
            if (parts[1] !== "aes-256-cbc/pbkdf2-sha1") {
                throw new Error("Unsupported algorithm");
            }
    
            const paramsStr = parts[2];
            const params = this.parseParams(paramsStr);
            if (!params.has("i")) {
                throw new Error("Missing iteration count");
            }
    
            const iterations = parseInt(params.get("i")!);
            const salt = Buffer.from(parts[3], "base64");
            const encryptedText = Buffer.from(parts[4], "base64");
    
            const secretKey = this.generateSecretKeyFromPassphrase(this.passphrase, salt, 32, iterations);
            const decryptedText = this.decryptString(encryptedText, secretKey, salt);
    
            return decryptedText.toString("utf8");
        }
    
        protected parseParams(params: string): Map<string, string> {
            const keyValuePairs = params.split(",");
    
            const result = new Map<string, string>();
            keyValuePairs.forEach(pair => {
                const [key, value] = pair.split("=");
                result.set(key, value);
            });
            return result;
        }
    
        protected decryptString(input: Buffer, secretKey: Buffer, iv: Buffer): Buffer {
            const decipher = crypto
                .createDecipheriv("aes-256-cbc", secretKey, iv);
            return Buffer.concat([decipher.update(input), decipher.final()]);
        }
    
        public Encrypt(input: string): string {
            const salt = this.generateSalt();
            const secretKey = this.generateSecretKeyFromPassphrase(this.passphrase, salt, 32, this.iterations);
            const encryptedText = this.encryptString(Buffer.from(input, "utf8"), secretKey, salt);
            return `$aes-256-cbc/pbkdf2-sha1$i=${this.iterations}$${salt.toString("base64")}$${encryptedText.toString("base64")}`;
        }
    
        protected encryptString(input: Buffer, secretKey: Buffer, iv: Buffer): Buffer {
            const cypher = crypto
                .createCipheriv("aes-256-cbc", secretKey, iv);
    
            return Buffer.concat([cypher.update(input), cypher.final()]);
        }
    
        protected generateSalt(size: number = 16): Buffer {
            return crypto.randomBytes(size);
        }
    
        protected generateSecretKeyFromPassphrase(passphrase: string, salt: Buffer, keyLength: number = 32, iterations: number = 75_000): Buffer {
            return crypto.pbkdf2Sync(passphrase, salt, iterations, keyLength, "sha1");
        }
    }
    ```

=== "Python"
    Based on [pycryptodome](https://pypi.org/project/pycryptodome/)
    
    ```python
    import base64
    
    from Crypto.Cipher import AES
    from Crypto.Hash import SHA1
    from Crypto.Protocol.KDF import PBKDF2
    from Crypto.Random import get_random_bytes
    from Crypto.Util.Padding import pad, unpad
    
    class AESEncryptor:
        def __init__(self, passphrase: str, iterations: int = 75_000):
            self.passphrase = passphrase
            self.iterations = iterations

        def encrypt(self, cleartext: str) -> str:
            saltBytes = self._generate_salt()
            key = self._generate_key(saltBytes, self.iterations)
    
            cipher = AES.new(key, AES.MODE_CBC, iv=saltBytes)
    
            encrypted_bytes = cipher.encrypt(pad(cleartext.encode(), AES.block_size))
    
            salt = base64.b64encode(saltBytes).decode("utf-8")
            encrypted = base64.b64encode(encrypted_bytes).decode("utf-8")
    
            return f"$aes-256-cbc/pbkdf2-sha1$i={self.iterations}${salt}${encrypted}"
    
        def decrypt(self, encrypted: str) -> str:
            chunks = encrypted.split("$")
    
            if len(chunks) < 5:
                raise ValueError("Invalid encryption format")
    
            if chunks[1] != "aes-256-cbc/pbkdf2-sha1":
                raise ValueError("Unsupported algorithm")
    
            params = self._parse_params(chunks[2])
            if "i" not in params:
                raise ValueError("Missing iteration count")
    
            iterations = int(params["i"])
            salt = base64.b64decode(chunks[-2])
            encrypted_bytes = base64.b64decode(chunks[-1])
    
            key = self._generate_key(salt, iterations)
            cipher = AES.new(key, AES.MODE_CBC, iv=salt)
    
            decrypted_bytes = unpad(cipher.decrypt(encrypted_bytes), AES.block_size)
    
            return decrypted_bytes.decode("utf-8")
    
        def _generate_salt(self) -> bytes:
            return get_random_bytes(16)
    
        def _generate_key(self, salt: bytes, iterations: int) -> bytes:
            return PBKDF2(
                self.passphrase,
                salt,
                count=iterations,
                dkLen=32,
                hmac_hash_module=SHA1,
            )
    
        def _parse_params(self, params: str) -> dict[str, str]:
            return {k: v for k, v in [p.split("=") for p in params.split(",")]}
    ```

=== "Rust"
    Based on the [`android-sms-gateway`](https://crates.io/crates/android-sms-gateway) crate (`encryption` feature required)

    ```toml title="Cargo.toml"
    [dependencies]
    android-sms-gateway = { version = "0.1", features = ["encryption"] }
    ```

    ```rust
    use android_sms_gateway::encryption::Encryptor;

    let encryptor = Encryptor::new("my-passphrase");

    let encrypted = encryptor.encrypt("Sensitive message");
    println!("Encrypted: {encrypted}");

    let decrypted = encryptor.decrypt(&encrypted).unwrap();
    println!("Decrypted: {decrypted}");
    ```

    The default iteration count is 75,000. To use a custom value:

    ```rust
    let encryptor = Encryptor::with_iterations("my-passphrase", 300_000);
    ```

## Migrating from Passphrase Encryption 🚚

Passphrase encryption remains fully supported, so existing setups keep working unchanged:

- Existing passphrase-encrypted messages and settings are not affected; the device still decrypts the legacy `$aes-256-cbc/pbkdf2-sha1$` format.
- Old Android app versions and old SDK versions keep using passphrase encryption as before.
- Devices without a `publicKey` are simply not usable for E2E messages.

To start using device-paired E2E:

1. Update the Android app: on registration (or the next device update) it generates an RSA-2048 key pair and uploads the public key automatically. No configuration is needed.
2. Update your code for E2E support.
3. Keep the passphrase set during the transition; you can remove it after all devices have been updated and all pending messages are delivered.

!!! warning "Key versioning"
    `keyVersion` is managed by the device and stored by the server as-is. Never generate or guess key versions client-side – always read `keyVersion` from the device listing.
