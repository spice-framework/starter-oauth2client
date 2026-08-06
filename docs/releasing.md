# Releasing starter-oauth2client

starter-oauth2client releases are ordinary Go module tags plus a small, independently
verifiable source-artifact set. The protected organization-owned reusable
workflow is the sole production builder. Repository code does not contain a
second signer or release implementation.

## Artifact contract

For `v1.2.3`, the release produces exactly:

| Artifact | Contract |
|---|---|
| `starter-oauth2client_1.2.3_source.tar.gz` | Exact tagged Git commit under one versioned directory |
| `starter-oauth2client_1.2.3_sbom.spdx.json` | SPDX 2.3 packages from the consistent committed `go.mod`, `go.sum`, and `vendor/modules.txt` graph |
| `checksums.txt` | Canonical SHA-256 entries for the source archive and SBOM |
| `checksums.txt.sig` | Raw Ed25519 signature over the exact checksum bytes |
| `checksums.txt.pem` | X.509 SubjectPublicKeyInfo PEM matching the signer |

Archive order, paths, modes, safe relative symlinks, tar/PAX and gzip metadata,
and SPDX creation time derive only from sorted committed Git objects and the
source commit epoch. Gitlinks, unsafe paths, stale module/vendor metadata,
unsupported modes, dirty production checkouts, a mismatched tag, and partial
output fail closed. Artifact construction performs no dependency resolution or
network access and emits no absolute workspace path or current timestamp.

Production uses
`spice-framework/.github/.github/workflows/library-release.yml@9ae80e32f64b29697acd9ebe629468850b4ae9f2`.
Its uncredentialed candidate phase runs the repository verification contract.
The signing phase renders with an immutable trusted tool and one explicitly
mapped repository secret. A separately pinned verifier authenticates all
artifacts before the independently protected publish phase receives them.
Neither phase inherits ambient secrets.

## Deterministic unsigned rehearsal

The root `go.mod` authorizes exact `spice-dev` renderer and
`spice-library-release-verify` tool versions through standard Go `tool`
directives. This command asks the central renderer for one inert plan and
renders it twice:

```text
make release-rehearsal
```

The command runs with `GOWORK=off`, `GOPROXY=off`,
`GOTOOLCHAIN=local`, and `GOFLAGS=-mod=vendor`. Both renders must be
byte-identical and contain only the source archive, SBOM, and checksum file.
Canonical checksums, central renderer provenance, a complete SPDX document, and
the absence of signature or key material are validated. Any extra artifact,
nondeterministic output, malformed checksum, or provenance drift fails closed.

`make verify-release` executes the complete repository verification contract
and then this deterministic rehearsal. The repository-local builder was retired
after the protected, independently verified preview cutover proved the central
path.

## Signing trust

The reviewed repository-specific trust anchor is
[`security/release/ed25519-public.pem`](../security/release/ed25519-public.pem).
Its DER SubjectPublicKeyInfo SHA-256 fingerprint is:

```text
c1ff629a8f503bd90d21fd0e6aec5e072f21ceedda9203d8ad01d755d9f66a54
```

The matching private Ed25519 key exists only as repository Actions secret
`SPICE_LIBRARY_RELEASE_SIGNING_KEY`. The workflow caller maps exactly that
secret. Protected `release-signing` and `release-publish` environments are
separate approval boundaries, and immutable `v*` tag rules prevent moving or
deleting published identities. A missing or mismatched anchor, key,
environment, approval, or tag rule fails the release; there is no unsigned
production fallback.

## Consumer verification

Download all five assets and authenticate the emitted key against the committed
anchor before trusting the adjacent signature:

```text
cmp checksums.txt.pem security/release/ed25519-public.pem
openssl pkeyutl -verify -pubin -inkey security/release/ed25519-public.pem \
  -rawin -in checksums.txt -sigfile checksums.txt.sig
sha256sum -c checksums.txt
```

PowerShell users can compare each checksum with
`Get-FileHash -Algorithm SHA256`. Consumers must also verify that the
annotated tag peels to the expected immutable commit and that the release is
classified as a prerelease whenever the SemVer tag contains a prerelease
identifier.

## Release ceremony

1. Confirm the committed anchor fingerprint, repository signing secret,
   protected environments, and immutable tag rules.
2. Run `make verify-release` once on the exact clean commit to be tagged.
3. Fetch `origin/main` and stop if it moved unexpectedly.
4. Create and push one annotated canonical SemVer tag.
5. Approve signing only after candidate verification and planning succeed.
6. Approve publishing only after signing and independent verification succeed.
7. Download the published assets and independently verify the key, signature,
   checksums, archive, SBOM, tag object, peeled commit, and prerelease status.

GitHub is the distribution mirror; normal consumers still use the standard Go
module graph and do not need the release compiler at runtime.
