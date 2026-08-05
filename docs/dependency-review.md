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
