#!/bin/sh
# Assert system state after applying vm/integration/Rezeptfile with --no-dry-run.
# Exits 1 on the first failing check and prints which check failed.

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; exit 1; }

# --- Group ---
if getent group koch-test-group | grep -q ':9876:'; then
  pass "group koch-test-group exists with GID 9876"
else
  fail "group koch-test-group with GID 9876 not found"
fi

# --- User ---
if getent passwd koch-test-user | grep -q ':9876:9876:'; then
  pass "user koch-test-user exists with UID/GID 9876"
else
  fail "user koch-test-user with UID/GID 9876 not found"
fi

if getent passwd koch-test-user | grep -q '/usr/sbin/nologin'; then
  pass "user koch-test-user has shell /usr/sbin/nologin"
else
  fail "user koch-test-user does not have shell /usr/sbin/nologin"
fi

# --- Package install ---
if dpkg -l wamerican 2>/dev/null | grep -q '^ii'; then
  pass "package wamerican installed"
else
  fail "package wamerican not installed"
fi

# --- Package delete ---
if dpkg -l nano 2>/dev/null | grep -q '^ii'; then
  fail "package nano still installed (should have been purged)"
else
  pass "package nano not installed"
fi

# --- Snap (Ubuntu only) ---
if grep -q Ubuntu /etc/issue; then
  if snap list 2>/dev/null | grep -q '^hello '; then
    pass "snap hello installed"
  else
    fail "snap hello not installed"
  fi
fi

# --- File contents ---
if [ "$(cat /tmp/koch-test/myfile 2>/dev/null)" = "hello integration" ]; then
  pass "file /tmp/koch-test/myfile has correct contents"
else
  fail "file /tmp/koch-test/myfile has wrong or missing contents"
fi

# --- File permissions ---
if [ "$(stat -c %a /tmp/koch-test/myfile 2>/dev/null)" = "640" ]; then
  pass "file /tmp/koch-test/myfile has mode 640"
else
  fail "file /tmp/koch-test/myfile does not have mode 640"
fi

# --- Directory exists ---
if [ -d /tmp/koch-test/mydir ]; then
  pass "directory /tmp/koch-test/mydir exists"
else
  fail "directory /tmp/koch-test/mydir not found"
fi

# --- Directory permissions ---
if [ "$(stat -c %a /tmp/koch-test/mydir 2>/dev/null)" = "750" ]; then
  pass "directory /tmp/koch-test/mydir has mode 750"
else
  fail "directory /tmp/koch-test/mydir does not have mode 750"
fi

# --- Run marker ---
if [ -f /tmp/koch-test/run-was-here ]; then
  pass "run marker /tmp/koch-test/run-was-here created"
else
  fail "run marker /tmp/koch-test/run-was-here not found"
fi

# --- DeleteFile ---
if [ ! -f /tmp/koch-test/to-delete ]; then
  pass "file /tmp/koch-test/to-delete was deleted"
else
  fail "file /tmp/koch-test/to-delete still exists"
fi

# --- DeleteDirectory ---
if [ ! -d /tmp/koch-test/to-delete-dir ]; then
  pass "directory /tmp/koch-test/to-delete-dir was deleted"
else
  fail "directory /tmp/koch-test/to-delete-dir still exists"
fi

# --- Swapfile on disk ---
if [ -f /swapfile-integration-test ]; then
  pass "swapfile /swapfile-integration-test exists"
else
  fail "swapfile /swapfile-integration-test not found"
fi

# --- Swapfile active ---
if swapon --show 2>/dev/null | grep -q '/swapfile-integration-test'; then
  pass "swapfile /swapfile-integration-test is active"
else
  fail "swapfile /swapfile-integration-test is not active"
fi

# --- Swapfile in fstab ---
if grep -q '/swapfile-integration-test' /etc/fstab; then
  pass "swapfile /swapfile-integration-test is in /etc/fstab"
else
  fail "swapfile /swapfile-integration-test not found in /etc/fstab"
fi

# --- Systemd service enabled ---
if systemctl is-enabled --quiet koch-test-dummy.service 2>/dev/null; then
  pass "systemd service koch-test-dummy is enabled"
else
  fail "systemd service koch-test-dummy is not enabled"
fi

# --- Systemd timer file on disk ---
if [ -f /etc/systemd/system/koch-test-timer.timer ]; then
  pass "timer file /etc/systemd/system/koch-test-timer.timer exists"
else
  fail "timer file /etc/systemd/system/koch-test-timer.timer not found"
fi

# --- Systemd timer enabled ---
if systemctl is-enabled --quiet koch-test-timer.timer 2>/dev/null; then
  pass "systemd timer koch-test-timer is enabled"
else
  fail "systemd timer koch-test-timer is not enabled"
fi

echo "All assertions passed."
