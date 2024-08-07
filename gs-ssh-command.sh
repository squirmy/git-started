#!/usr/bin/env bash

set -euo pipefail

POSITIONAL_ARGS=()

public_key_dir="$HOME/.ssh"

function usage {
  echo "usage: $0 [-d <path>] <username>"
  echo ""
  echo "Creates an ssh command using identities within a directory"
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

# If there are no keys for this user exit
if ! test -n "$(find "$public_key_dir" -maxdepth 1 -name "$username:SHA256:*" -print -quit)"
then
    >&2 echo "error: no keys found for $username in $public_key_dir"
    exit 1
fi

printf -v identities -- '-i "%s" ' "$public_key_dir/$username":SHA256:*
identities=${identities%" "}
echo "ssh ${identities} -o IdentitiesOnly=yes -F /dev/null"
