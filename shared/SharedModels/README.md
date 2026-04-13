# SharedModels

Shared Swift domain package for iOS, backend, and Android.

## Goals

- Portable with the official Swift 6.3 Android SDK
- Safe to serialize over HTTP or persist locally
- No platform framework dependencies

## Included model

- `PlayerCharacter`
  - Includes `hearts`, `rupees`, and `attack`
  - Supports shared combat logic via `attacking(_:)`

## Android notes

This package is intentionally pure Swift so it can be cross-compiled with the official Android SDK from Swift.org.

Example Android build:

```sh
swift build --package-path shared/SharedModels --swift-sdk aarch64-unknown-linux-android28 --static-swift-stdlib
```
