# Spice OAuth2 Client Starter

`starter-oauth2client` provides a bounded OAuth 2.0 client-credentials integration
for Spice services. It returns an ordinary `*http.Client`; there is no global
client, discovery service, reflection, or network activity during construction.

## Install

```text
go get github.com/spice-framework/starter-oauth2client@latest
```

The module uses Go 1.26.5. Its machine-readable Spice core boundaries are in
[`spice-compatibility.json`](spice-compatibility.json).

## Use

```go
options := oauth2client.Options{
    ClientID:     config.ClientID,
    ClientSecret: config.ClientSecret,
    TokenURL:     config.TokenURL,
    Scopes:       []string{"inventory.read"},
}

tokenClient := &http.Client{
    Timeout:   5 * time.Second,
    Transport: tracedTokenTransport,
}
resourceClient := &http.Client{
    Timeout:   10 * time.Second,
    Transport: tracedResourceTransport,
}

client, err := oauth2client.NewClient(
    applicationContext,
    options,
    tokenClient,
    resourceClient,
)
```

Both HTTP clients must have positive timeouts. Spice clones them, so later
mutations to the inputs do not silently alter the constructed client. The token
transport is used only for credential acquisition; the resource transport is
used only for application requests and remains the observability seam.

## Security and failure behavior

- Token and resource URLs must use HTTPS. HTTP resource requests fail before a
  token is acquired.
- Token redirects are never followed. Resource redirects fail closed by default;
  a caller-supplied `CheckRedirect` policy is preserved.
- The token response is bounded to 64 KiB by default and at most 1 MiB.
- Only valid Bearer tokens are accepted.
- `TokenError` preserves `context.Canceled` and `context.DeadlineExceeded`
  classification without retaining upstream bodies, URLs, tokens, or credentials.
- The application-lifetime context controls token acquisition. Each resource
  request retains its own context and cancellation.
- Token caching and concurrent refresh coordination are provided by the pinned
  `golang.org/x/oauth2` implementation.

Construction does not read environment variables or files. Load secrets through
the application's explicit configuration system and avoid logging `Options`.

## Provider-specific parameters

`EndpointParameters` supports bounded values such as `audience`. Standard OAuth2
fields (`client_id`, `client_secret`, `grant_type`, and `scope`) cannot be
overridden. `AuthStyleHeader` is the default; select `AuthStyleParameters` only
for providers that explicitly require credentials in the form body.

## Verification

```text
make check
make compatibility
make lint
make release-parity
make security
make verify
make verify-release
```

The final gate checks formatting, modules and vendor reproducibility, vet,
allowlisted linting, NilAway, gosec, govulncheck, shuffled/race tests, coverage,
minimum/current Spice compatibility, and offline vendor execution. Local TLS
fixtures prove token and resource behavior without external services.

Release parity validates the exact `spice-dev` renderer and
`spice-library-release-verify` verifier authorized by `go.mod`, then runs the
renderer and retained repository builder twice each, entirely from `vendor`
with network and workspace resolution disabled. It requires byte-identical,
structurally valid source archives, equivalent SBOM package and dependency
facts, canonical self-consistent checksums, and no rehearsal signatures on Windows and Linux.

See [`docs/dependency-review.md`](docs/dependency-review.md) for the dependency
decision and [`docs/support.md`](docs/support.md) for the support policy.

## Releases

Each version tag is an ordinary Go module release. The repository also builds
an exact-commit source archive, committed-graph SPDX 2.3 SBOM, SHA-256
checksums, and an Ed25519 signature/public key without an external release
build system. Production mode requires a clean checkout, exact tag, and
protected signing key; an explicit unsigned rehearsal is available for local
proof. See [`docs/releasing.md`](docs/releasing.md) for the artifact and trust
contract.
The retained repository builder and signed production workflow remain the
release authority while the centrally rendered unsigned candidate is held to
the dual-builder parity contract.

## License

Apache License 2.0.
