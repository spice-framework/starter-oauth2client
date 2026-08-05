# Support policy

## Supported environment

- Go 1.26.5 on Windows, Linux, and macOS.
- The Spice core minimum and current versions declared in
  `spice-compatibility.json`.
- Standard module and vendored, offline builds.

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
