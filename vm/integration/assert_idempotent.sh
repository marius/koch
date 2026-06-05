#!/bin/sh
# Idempotency oracle: run Koch in dry-run mode (the default) after a successful
# --no-dry-run apply. Koch's maybe() emits "DRY RUN: <cmd>" for every mutation
# it would make, so zero such lines means the system is fully converged.

output=$(koch -f /koch/vm/integration/Rezeptfile 2>&1)
violations=$(printf '%s\n' "$output" | grep '^DRY RUN:')

if [ -n "$violations" ]; then
  echo "IDEMPOTENCY FAILURE: second apply would still make changes:"
  printf '%s\n' "$violations"
  exit 1
fi

echo "PASS: idempotency — second dry-run apply makes no changes."
