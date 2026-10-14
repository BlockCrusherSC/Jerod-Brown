# Jerod-Brown — safe cross-platform rebuild

This branch starts a safer replacement for the existing Windows-only installer. The original repository contains scripts that hide execution, alter system policy, and establish persistence. This rebuild does **not** extend those behaviors.

## Current implementation

- `tools/release_stage.py` works on Windows and Linux with Python 3.10+.
- Queries the latest published GitHub release.
- Selects a package explicitly named for the requested OS.
- Requires GitHub's SHA-256 asset digest and verifies the downloaded bytes.
- Stages the verified package for manual review.

It deliberately does **not** execute downloaded code, unpack archives, install services, create startup persistence, hide files, propagate to other machines, or delete data.

## Usage

Check and stage a Windows package:

```powershell
py -3 tools/release_stage.py --platform windows --out .\staged-release
```

Check and stage a Linux package:

```bash
python3 tools/release_stage.py --platform linux --out ./staged-release
```

On either OS, omit `--platform` to use the current platform.

## Publishing a release

Publish reviewed release assets with filenames that include `windows` or `linux`, for example:

- `jerod-brown-windows-x64.zip`
- `jerod-brown-linux-x64.tar.gz`

GitHub release assets expose SHA-256 digests through the Releases API. The staging tool refuses assets without a valid digest, rejects unexpected download hosts, and does not run what it downloads.

## Next steps

1. Define the legitimate application behavior and configuration format.
2. Build separately packaged Windows and Linux artifacts in CI.
3. Add automated tests and signed provenance/attestation verification.
4. Add visible service management and an explicit uninstall command that only removes registered application-owned paths after confirmation.
5. Keep user data outside the application directory and make its deletion a separate opt-in operation.

Do not deploy the legacy installer from `main` as if it were this safer rebuild; this branch is a separate starting point for review.
