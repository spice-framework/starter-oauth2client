# Starter OAuth2 Client Implementation Contract

This repository owns the Spice OAuth 2.0 client-credentials starter.

## Invariants

- Work directly on `main` and preserve the filtered product history.
- Require exactly Go 1.26.5.
- Keep construction network-free and dependency injection explicit.
- Require HTTPS for token and resource endpoints.
- Preserve caller-owned contexts, transports, timeouts, redirects, and instrumentation.
- Never expose credentials, tokens, provider bodies, or endpoint URLs in errors.
- Do not add package globals, environment lookup, implicit discovery, or hidden retries.
- Keep the standalone starter manifest and `spice-compatibility.json` current.
- Run focused checks while developing and `make verify` on the exact tree before commit.
- Never weaken a gate to land a change.

Release-parity work must preserve the exact central release-tool versions
authorized by the root `go.mod`, invoke full package paths, and run both central
and retained rehearsals with workspace and network resolution disabled in vendor
mode. The retained repository builder and signed production workflow remain
authoritative until a separately reviewed signing migration; unsigned parity
must never manufacture signatures or key material.

## Compatibility

The product module directly requires the minimum supported Spice core version.
The quality gate tests both that minimum and the explicit current boundary without
rewriting the repository. Consumer cutovers belong in the consuming repositories.
