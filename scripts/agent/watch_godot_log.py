"""Continuous Godot log watcher for real-time runtime bug detection."""

import os
import re
import sys
import time

ERROR_PATTERNS = [
    re.compile(r"SCRIPT ERROR:", re.IGNORECASE),
    re.compile(r"USER ERROR:", re.IGNORECASE),
    re.compile(r"\bERROR:\s+", re.IGNORECASE),
    re.compile(r"Out of bounds get index", re.IGNORECASE),
    re.compile(r"Cannot infer the type", re.IGNORECASE),
    re.compile(r"Invalid get index", re.IGNORECASE),
    re.compile(r"Invalid set index", re.IGNORECASE),
    re.compile(r"Invalid call", re.IGNORECASE),
    re.compile(r"Null instance", re.IGNORECASE),
    re.compile(r"Parser Error:", re.IGNORECASE),
    re.compile(r"CrashHandlerException", re.IGNORECASE),
]

IGNORE_PATTERNS = [
    re.compile(r"Nodes with non-equal opposite anchors", re.IGNORECASE),
    re.compile(r"Unicode parsing error", re.IGNORECASE),
    re.compile(r"The parameter .* is never used", re.IGNORECASE),
]


def find_log_path() -> str:
    appdata = os.environ.get("APPDATA", "")
    if not appdata:
        raise RuntimeError("APPDATA environment variable not set")
    base_dir = os.path.join(appdata, "Godot", "app_userdata")
    if not os.path.exists(base_dir):
        raise RuntimeError(f"Godot app_userdata directory not found: {base_dir}")

    candidates = []
    for entry in os.listdir(base_dir):
        full = os.path.join(base_dir, entry)
        if os.path.isdir(full):
            log_file = os.path.join(full, "logs", "godot.log")
            if os.path.exists(log_file):
                candidates.append((os.path.getmtime(log_file), log_file))

    if candidates:
        candidates.sort(key=lambda x: x[0], reverse=True)
        return candidates[0][1]

    raise RuntimeError("Could not find godot.log in Godot app_userdata")


def main() -> None:
    # Ensure stdout handles unicode
    if sys.stdout.encoding != "utf-8":
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    log_path = find_log_path()
    print(f"[*] Monitoring Godot log at: {log_path}", flush=True)

    # Start at current EOF
    current_pos = os.path.getsize(log_path) if os.path.exists(log_path) else 0
    print(f"[*] Initialized at byte offset {current_pos}. Waiting for new runtime errors...", flush=True)

    error_detected = False
    captured_lines = []

    while not error_detected:
        if not os.path.exists(log_path):
            time.sleep(0.5)
            continue

        try:
            file_size = os.path.getsize(log_path)
            # File rotated or truncated (new F5 session)
            if file_size < current_pos:
                print(f"[*] Detected log truncation / new F5 session. Resetting offset from {current_pos} to 0.", flush=True)
                current_pos = 0

            if file_size > current_pos:
                with open(log_path, "r", encoding="utf-8", errors="replace") as f:
                    f.seek(current_pos)
                    lines = f.readlines()
                    current_pos = f.tell()

                for line in lines:
                    line_clean = line.strip()
                    if not line_clean:
                        continue

                    # Check ignore list
                    if any(p.search(line_clean) for p in IGNORE_PATTERNS):
                        continue

                    # Check error patterns
                    if any(p.search(line_clean) for p in ERROR_PATTERNS):
                        print(f"\n[!] RUNTIME BUG DETECTED: {line_clean}\n", flush=True)
                        error_detected = True
                        captured_lines.append(line)
                        break

            time.sleep(0.4)
        except Exception as e:
            time.sleep(0.5)

    # When error is detected, capture the next 1.5 seconds of call stack/backtrace
    print("[*] Capturing full backtrace...", flush=True)
    start_time = time.time()
    while time.time() - start_time < 1.5:
        if os.path.exists(log_path):
            try:
                with open(log_path, "r", encoding="utf-8", errors="replace") as f:
                    f.seek(current_pos)
                    more_lines = f.readlines()
                    current_pos = f.tell()
                    captured_lines.extend(more_lines)
            except Exception:
                pass
        time.sleep(0.2)

    print("=================== GODOT RUNTIME ERROR REPORT ===================")
    for l in captured_lines:
        sys.stdout.write(l)
    print("==================================================================")
    sys.exit(0)


if __name__ == "__main__":
    main()
