---
name: test-hygiene-scanner
description: Triage hardcoded dates, AsyncMock misuse, cross-tier truncates, and envelope assertion bugs
user-invocable: true
disable-model-invocation: true
---

# Test Hygiene Scanner

Scan test suite for hygiene violations.

## Categories

1. Hardcoded dates (ISO strings that will rot)
2. AsyncMock misuse on sync methods
3. Cross-tier table truncates with autouse=True
4. Envelope assertion bugs (`assert "detail" in error_data`)
5. Process-global singleton leaks without patching

## Output

File:line citations with severity (WARNING/ERROR) and suggested fix.
