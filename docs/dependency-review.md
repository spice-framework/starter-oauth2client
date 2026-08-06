# Dependency review: x/oauth2

- Decision: approved for the standalone
  `github.com/spice-framework/starter-oauth2client` module.
- Version: `golang.org/x/oauth2` v0.36.0.
- Upstream: <https://go.googlesource.com/oauth2>.
- License: BSD-3-Clause; retained in the vendored module license.
- Maintenance: maintained by the Go project and already present through the
  approved OIDC dependency; this slice makes it a direct dependency.
- Security: Spice requires HTTPS for token and resource requests, rejects token
  redirects and resource redirects by default, uses an explicit authentication
  style, bounds provider parameters and responses, accepts only Bearer tokens,
  and emits safe non-unwrapping token errors. The complete graph remains subject
  to gosec and govulncheck.
- Cancellation: a caller-owned application-lifetime context controls token
  acquisition; individual resource requests retain their own contexts.
- Observability: separately caller-owned token and resource HTTP transports are
  the instrumentation seams.
  Spice errors never contain tokens, credentials, provider bodies, or token
  endpoint URLs.
- Configuration: credentials and scopes are explicit constructor inputs.
  There is no environment lookup, global client, discovery, or network I/O
  during construction.

Primary references:

- <https://pkg.go.dev/golang.org/x/oauth2/clientcredentials>
- <https://www.rfc-editor.org/rfc/rfc6749#section-4.4>

## Build-only dependency: Spice development release renderer

- Decision: approved only as the repository-authorized release-parity tool.
- Version: `github.com/spice-framework/development`
  `v0.0.0-20260806034648-1856466df09d`.
- Tool: `github.com/spice-framework/development/cmd/spice-dev` through the
  standard Go `tool` directive; invocations always use the full package path.
- License: Apache-2.0, with its notice retained in `vendor`.
- Runtime scope: none. Product packages do not import the development module,
  and released applications acquire no runtime dependency on it.
- Dependency graph: the tool participates in normal Go minimal-version
  selection. That build-time coupling is accepted and visible in `go.mod`,
  `go.sum`, and `vendor/modules.txt`; no parallel tool registry is introduced.
- Integrity and network behavior: the exact pseudo-version is pinned and
  checksummed. Release parity runs with `GOWORK=off`, `GOPROXY=off`,
  `GOTOOLCHAIN=local`, and `GOFLAGS=-mod=vendor`, so it cannot select an ambient
  checkout, upgrade itself, or download dependencies.
- Security: the trusted native tool reads the exact committed Git graph and
  writes only to caller-supplied temporary output directories. The rehearsal
  emits no signatures or signing material.
- Maintenance: the retained local builder and production signing workflow stay
  in place. A dual-builder gate detects central renderer regressions before any
  future authority migration.
