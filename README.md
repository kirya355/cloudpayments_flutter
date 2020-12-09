# cloudpayments_flutter

A Flutter plugin for integrating Cloudpaymanets in Android
and iOS (test) applications.



It is not an official plugin. It uses [SDK-Android](https://github.com/cloudpayments/SDK-Android) on Android and [SDK-IOS](https://github.com/cloudpayments/SDK-iOS)
on iOS.

See the official documentation:
- [Android](https://developers.cloudpayments.ru/#sdk-dlya-android)
- [iOS](https://developers.cloudpayments.ru/#sdk-dlya-ios)

### Supports

- [X] Check the validity of the card's parameters.
- [X] Generate card cryptogram packet.
- [X] Show 3ds dialog.

## Getting Started

### Initializing for Android
To Google Pay add in AndroidManifest.xml, tag <application>
`<meta-data
     android:name="com.google.android.gms.wallet.api.enabled"
     android:value="true" />`

If you want to show 3ds dialog on Android, make MainActivity implements `FlutterFragmentActivity` instead of `FlutterActivity`

`android/app/src/main/.../MainActivity.kt`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {}
```

## Usage

- Check card number validity.

```dart
bool isValid = await CloudpaymentsFlutter.isValidNumber(cardNumber);
```

- Check card expire date.

```dart
bool isValid = await CloudpaymentsFlutter.isValidExpireDate(cardNumber); // MM/yy
```

- Generate card cryptogram packet. You need to get your publicId from your [personal account](https://merchant.cloudpayments.ru/login).

```dart
final cryptogram = await CloudpaymentsFlutter.cardCryptogram(cardNumber, expireDate, cvcCode, publicId);
```

- Showing 3DS form and get results of 3DS auth.

```dart
final result = await CloudpaymentsFlutter.show3ds(acsUrl, transactionId, paReq);
```
