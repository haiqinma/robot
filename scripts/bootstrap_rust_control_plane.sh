#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/rust/control-plane"
CARGO_HOME_DIR="${CARGO_HOME_DIR:-$ROOT_DIR/.tmp/cargo-home}"

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "[info] Rust not found, installing minimal toolchain..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
fi

if [[ ! -f "$APP_DIR/.env" ]]; then
  cp "$APP_DIR/.env.example" "$APP_DIR/.env"
  echo "[info] created $APP_DIR/.env from template"
fi

mkdir -p "$CARGO_HOME_DIR"
cat >"$CARGO_HOME_DIR/config.toml" <<'EOF'
[source.crates-io]
registry = "sparse+https://index.crates.io/"
EOF

cd "$APP_DIR"
CARGO_HOME="$CARGO_HOME_DIR" cargo fetch --locked
CARGO_HOME="$CARGO_HOME_DIR" cargo build --locked

echo "[ok] Rust control plane is built."
echo "[next] edit $APP_DIR/.env and run: bash $ROOT_DIR/scripts/run_control_plane_dev.sh"
