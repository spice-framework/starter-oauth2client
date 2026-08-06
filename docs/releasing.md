# Release contract

starter-oauth2client releases are ordinary Go module tags plus a small, independently
verifiable artifact set. The repository owns the complete build. No external
release build service, mutable workspace snapshot, or network-resolved package
list participates in artifact construction.

For `v1.2.3`, the release builder produces:

| Artifact | Contract |
|---|---|
| `starter-oauth2client_1.2.3_source.tar.gz` | Exact tagged Git commit, under one versioned directory |
| `starter-oauth2client_1.2.3_sbom.spdx.json` | SPDX 2.3 packages from the consistent committed `go.mod`, `go.sum`, and `vendor/modules.txt` graph |
| `checksums.txt` | SHA-256 of the source archive and SBOM, sorted by filename |
| `checksums.txt.sig` | Raw Ed25519 signature of the exact checksum bytes |
| `checksums.txt.pem` | X.509 SubjectPublicKeyInfo PEM for signature verification |

The source archive is reconstructed from the full commit's `git ls-tree`
identity and exact object bytes read through `git cat-file --batch`. It never
uses checkout filters or `git archive`, so `core.autocrlf` and host line-ending
settings cannot alter an artifact. Every tar and gzip timestamp is the source
commit epoch; paths are relative, ownership is zeroed, executable modes and
validated symlinks are preserved, and gzip output is deterministic. Gitlinks
and unsupported modes fail closed. Dirty or untracked workspace files cannot
enter the archive. The SBOM creation time uses the same epoch and contains no
absolute checkout path. Construction fails when committed module selection,
checksums, and vendored versions or replacements disagree; the builder does
not rely on an earlier verifier to detect a stale dependency graph.

## Production ceremony

Production mode fails unless all of these conditions hold:

1. `-version` is canonical, v-prefixed SemVer.
2. the checkout is clean, including untracked files;
3. the named tag resolves exactly to `HEAD`;
4. an Ed25519 private key is supplied;
5. any explicit source epoch equals the `HEAD` commit epoch; and
6. the output directory does not already exist.

The tag workflow runs `make verify-release`, materializes the protected
`STARTER_OAUTH2CLIENT_RELEASE_SIGNING_KEY` secret with owner-only permissions, invokes
the repository command, removes the key even after failure, and publishes only
the newly created `dist` files. The workflow never prints the key. Creating or
rotating that repository secret and pushing a release tag are separate human
release-authority actions; no development task should manufacture either.

## Unsigned dual-builder rehearsal

The library module authorizes an exact central renderer through its `go.mod`
tool directive. `make release-parity` runs that fully qualified tool and the
retained repository builder twice each with `GOWORK=off`, `GOPROXY=off`,
`GOTOOLCHAIN=local`, and `GOFLAGS=-mod=vendor`. It first asks the central tool
for a read-only plan and then renders that plan without resolving an ambient
workspace or downloading a module.

```text
make release-parity
```

Both rehearsals are unsigned, deterministic across two independent outputs,
and archive the exact committed `HEAD` tree. The source archives must be
byte-identical. Parity additionally drains and validates both gzip/PAX streams,
including their checksums and trailers, and requires identical entry order,
paths, modes, types, links, sizes, timestamps, extended records, gzip metadata,
and content hashes. Hidden decompressed bytes, raw trailing bytes, additional
gzip members, oversized inputs, duplicate entries, and paths outside the exact
`starter-oauth2client_VERSION/` root fail closed.

The SPDX documents must be identical except for these explicit provenance
fields:

- document name (`Spice OAuth2 Client starter VERSION` retained and
  `starter-oauth2client VERSION` centrally);
- namespace identity (the central namespace includes `spdx/v1/`); and
- organization and tool creators identifying the actual renderer.

Package facts, dependency relationships, creation time, ordering, SPDX
contract, and every other decoded field must match exactly. Each checksum file
must canonically verify its own archive and SBOM. Extra artifacts, signatures,
malformed checksums, archive drift, or undocumented SBOM drift fail closed.

`make verify-release` runs this dual-builder proof after the complete repository
verification contract. The production tag workflow deliberately continues to
invoke `cmd/starter-oauth2client-release` and publish its signed artifacts until
signing authority is migrated in a separate review.

## Consumer verification

With OpenSSL 3 and GNU-compatible checksum tooling:

```text
sha256sum -c checksums.txt
openssl pkeyutl -verify -pubin -inkey checksums.txt.pem \
  -rawin -in checksums.txt -sigfile checksums.txt.sig
```

Until a separately reviewed Ed25519 public-key fingerprint is pinned in this
repository, GitHub's protected `spice-framework/starter-oauth2client` release channel
and immutable tag are the authenticity anchor. A public key bundled beside its
own signature proves only artifact-set consistency, not independent identity.
Consumers requiring an independent anchor must pin and compare the reviewed
fingerprint before trusting the signature. The project must not describe the
bundled key alone as proof of publisher authenticity.
