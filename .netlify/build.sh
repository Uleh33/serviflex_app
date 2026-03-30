#!/usr/bin/env bash
set -euo pipefail

# Solo clonar si no existe
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release
