#!/usr/bin/env python3
"""Validate NIGHTHAWK's machine-readable platform target registry."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "platforms" / "targets.json"
ALLOWED_STATUSES = {
    "existing-build-physical-validation-pending",
    "planned",
    "research-only",
    "supported",
    "deprecated",
}


def main() -> int:
    try:
        data = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot read valid JSON from {REGISTRY}: {exc}", file=sys.stderr)
        return 1

    if data.get("schema_version") != 1:
        print("ERROR: schema_version must be 1", file=sys.stderr)
        return 1

    targets = data.get("targets")
    if not isinstance(targets, list) or not targets:
        print("ERROR: targets must be a non-empty list", file=sys.stderr)
        return 1

    seen = set()
    required = {"id", "name", "family", "architecture", "boot_strategy", "status", "notes"}
    for index, target in enumerate(targets, start=1):
        if not isinstance(target, dict):
            print(f"ERROR: target #{index} must be an object", file=sys.stderr)
            return 1
        missing = required - target.keys()
        if missing:
            print(f"ERROR: target #{index} missing: {', '.join(sorted(missing))}", file=sys.stderr)
            return 1
        target_id = target["id"]
        if not isinstance(target_id, str) or not target_id.strip():
            print(f"ERROR: target #{index} has an invalid id", file=sys.stderr)
            return 1
        if target_id in seen:
            print(f"ERROR: duplicate target id: {target_id}", file=sys.stderr)
            return 1
        seen.add(target_id)
        if target["status"] not in ALLOWED_STATUSES:
            print(f"ERROR: {target_id} has unknown status {target['status']!r}", file=sys.stderr)
            return 1
        if target["status"] == "supported" and not target.get("validation_report"):
            print(f"ERROR: supported target {target_id} must link a validation_report", file=sys.stderr)
            return 1

    print(f"OK: validated {len(targets)} NIGHTHAWK platform targets")
    for target in targets:
        print(f"- {target['id']}: {target['status']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
