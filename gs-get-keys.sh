#!/usr/bin/env bash

set -euo pipefail

POSITIONAL_ARGS=()

public_key_dir="$HOME/.ssh"

function usage {
  echo "usage: $0 [-d <path>] <username>"
  echo ""
  echo "Retrieve a user's public keys from GitHub and write them to a directory"
  echo ""
  echo "Options:"
  echo "  -o    Public key directory (default: \"\$HOME/.ssh\")"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      public_key_dir="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

username="${1-}"
if [ -z "$username" ]; then
  usage
fi

mkdir -p "$public_key_dir"

rm -f "$public_key_dir/$username":SHA256:*

keys=$(curl -sL "https://github.com/$username.keys")
while IFS= read -r line; do
    base64url=$(echo "$line" | awk '{print $2}' | base64 -d | openssl sha256 -binary | base64)
    base64url=${base64url//+/-}
    base64url=${base64url//\//_}
    base64url=${base64url//=/}

    out_file="$public_key_dir/$username:SHA256:$base64url"
    echo "$line" > "$out_file"
done <<< "$keys"
