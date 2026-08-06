# Support policy

## Supported environment

- Go 1.26.5 on Windows, Linux, and macOS.
- The Spice core minimum and current versions declared in
  `spice-compatibility.json`.
- Standard module and vendored, offline builds.
- Release-parity rendering through
  `github.com/spice-framework/development/cmd/spice-dev` at
  `v0.0.0-20260806121906-963bb6676069`, with independent release verification
  authorized through
  `github.com/spice-framework/toolchain/cmd/spice-library-release-verify` at
  `v0.0.0-20260806054457-a83d9b58034c`.

## Compatibility policy

Before 1.0, public APIs may change between minor versions. Patch releases do not
intentionally break source compatibility. Every release tests the oldest
supported Spice core boundary and a reviewed current boundary. Raising the
minimum requires a documented release note and a compatibility manifest update.

## Security reports

Report vulnerabilities through GitHub private vulnerability reporting. Do not
open a public issue containing credentials, tokens, provider responses, or
exploit details. General defects and feature requests may use GitHub Issues.

## Operational ownership

Applications own credential sourcing, transport TLS roots, timeouts, redirect
policy, retry policy, observability, and shutdown context. This starter owns
client-credentials acquisition, token caching, protocol validation, safe errors,
and HTTPS enforcement. It intentionally performs no automatic discovery or
background network activity.

Release artifacts are produced only from an exact tagged commit under the
contract in [`releasing.md`](releasing.md). A compromised or missing signing
secret fails a production release; it never falls back to unsigned output.
The pinned central signer and independent verifier power the protected reusable
production workflow. Windows and Linux CI still compare unsigned central and
retained outputs under vendor-only offline resolution; the retained command is
only a parity oracle. Production remains disabled until a reviewed
`security/release/ed25519-public.pem`, the per-repository
`SPICE_LIBRARY_RELEASE_SIGNING_KEY`, and protected `release-signing` and
`release-publish` environments are configured.
