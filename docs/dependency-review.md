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

## Build-only dependencies: central release tools

- Decision: approved only as repository-authorized release tooling.
- Renderer: `github.com/spice-framework/development/cmd/spice-dev` from
  `github.com/spice-framework/development`
  `v0.0.0-20260806132124-4c308d1b9fda`.
- Independent verifier:
  `github.com/spice-framework/toolchain/cmd/spice-library-release-verify` from
  `github.com/spice-framework/toolchain`
  `v0.0.0-20260806133530-71211498297c`.
- Tool registration: both commands use standard Go `tool` directives and all
  invocations use their full package paths.
- License: Apache-2.0, with its notice retained in `vendor`.
- Runtime scope: none. Product packages import neither tool module, and
  released applications acquire no runtime dependency on them.
- Dependency graph: both tools participate in normal Go minimal-version
  selection. That build-time coupling is accepted and visible in `go.mod`,
  `go.sum`, and `vendor/modules.txt`; no parallel tool registry is introduced.
- Integrity and network behavior: both exact pseudo-versions are pinned and
  checksummed. Release parity runs with `GOWORK=off`, `GOPROXY=off`,
  `GOTOOLCHAIN=local`, and `GOFLAGS=-mod=vendor`, so it cannot select an ambient
  checkout, upgrade itself, or download dependencies.
- Security: the trusted native renderer reads the exact committed Git graph
  and writes only to caller-supplied temporary output directories. The
  verifier independently checks release artifacts without signing them. The
  rehearsal emits no signatures or signing material.
- Maintenance: the pinned central workflow owns production signing. The caller
  maps only repository secret `SPICE_LIBRARY_RELEASE_SIGNING_KEY`; inheritance
  and additional mappings fail repository verification. The protected signing
  and publishing environments remain approval boundaries. The retained local
  builder stays only as a parity oracle until separate removal evidence is
  reviewed.
