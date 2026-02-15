# 🛡️ Firebase App Check Security Setup

This guide details the mandatory steps to fully enable Firebase App Check for "Sud Qo'llanma". App Check protects your backend resources (Firestore, Storage, Auth) from abuse by ensuring traffic comes from your genuine app.

## 1. Firebase Console Setup

### A. Enable App Check
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Navigate to **Build** > **App Check**.
3. Click **Get Started**.

### B. Register Apps

#### 📱 Android (Play Integrity)
1. Select your Android app.
2. Choose **Play Integrity**.
3. You need to provide the **SHA-256 fingerprint**.
   - If you are using Google Play App Signing, get the SHA-256 from the **Google Play Console** (Release > Setup > App integrity).
   - If you are testing a release build locally, generate it from your keystore:
     ```bash
     keytool -list -v -keystore your-keystore.jks -alias your-key-alias
     ```
4. Paste the SHA-256 into the Firebase Console.
5. Set the "Token Time to Live (TTL)" (default 1 hour is fine).

#### 🍎 iOS (App Attest)
1. **Apple Developer Account**:
   - Ensure your App ID in the Apple Developer Portal has the **App Attest** capability enabled.
   - Note your **Team ID** (found in Membership details).

2. **Xcode Setup**:
   - Open your project: `ios/Runner.xcworkspace`.
   - Select the **Runner** target.
   - Go to **Signing & Capabilities**.
   - Click **+ Capability** and add **App Attest**.
   - Ensure your **Bundle Identifier** matches what's registered in Firebase.

3. **Firebase Console**:
   - Go to **App Check** > **Apps** > **iOS**.
   - Select **App Attest**.
   - Enter your **Team ID**.
   - (Optional) If using DeviceCheck as a fallback, ensure the Private Key is uploaded.

#### 🌐 Web (reCAPTCHA Enterprise)
1. **GCP Console**:
   - Enable the **reCAPTCHA Enterprise API**.
   - Create a Key:
     - Allow this key to work on your domains (e.g., `localhost`, `your-domain.com`).
     - Choose **Score-based (no challenge)** or **Checkbox**.
   - Copy the **Site Key** (`6LcXt...`).

2. **Firebase Console**:
   - Go to **App Check** > **Apps** > **Web**.
   - Select **reCAPTCHA Enterprise**.
   - Paste your **Site Key**.
   - Set the Token TTL (usually 1 hour).

3. **Code Configuration**:
   - The Site Key is stored in `lib/core/constants/api_constants.dart`.
   - `main.dart` uses `ReCaptchaEnterpriseProvider`.
   - **Localhost Testing**: Ensure `localhost` is added to the allowed domains in your reCAPTCHA Key settings on GCP.

---

## 2. Local Development (Debug Tokens)

To test the app on Emulators or Simulators without getting blocked, you must use **Debug Tokens**.

### Step 1: Run the App
Run your app in debug mode:
```bash
flutter run
```

### Step 2: Retrieve the Token
Check the debug console logs for a message like this:

**Android:**
```text
D/fbase_ap_check(12345): Enter this debug secret into the allow list in the Firebase Console for your project: 12345678-abcd-1234-abcd-1234567890ab
```

**iOS:**
```text
Firebase App Check: "Enter this debug secret into the allow list in the Firebase Console for your project: 12345678-abcd-1234-abcd-1234567890ab"
```

### Step 3: Register Token
1. Go back to **Firebase Console** > **App Check** > **Apps**.
2. Click the **overflow menu (three dots)** on your app.
3. Select **Manage debug tokens**.
4. Click **Add debug token**.
5. Paste the token and give it a name (e.g., "Max's Android Emulator").
6. Click **Save**.

---

## 3. Enforce App Check

**⚠️ WARNING: Do not enable enforcement until:**
1. You have successfully updated the app in the stores.
2. You have verified that legitimate users are not being blocked (check the "Requests" metrics in the console).

Once confirmed:
1. Go to **App Check** > **APIs**.
2. Select **Cloud Firestore** and/or **Cloud Storage**.
3. Click **Enforce**.

Before enforcement, usage will be monitored but not blocked.
