#!/usr/bin/env bash
set -euo pipefail

# Clone Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable flutter
export PATH="$PWD/flutter/bin:$PATH"

# Enable web, fetch toolchain and dependencies
flutter config --enable-web
flutter precache --web
flutter pub get

# Build web output
flutter build web --release
