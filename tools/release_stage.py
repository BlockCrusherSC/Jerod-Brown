#!/usr/bin/env python3
"""Stage a GitHub release asset after SHA-256 verification.

This tool intentionally does not execute, install, unpack, persist, or hide
downloaded files. Review the staged package and install it manually.
Works on Windows and Linux with Python 3.10+.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

REPO = "BlockCrusherSC/Jerod-Brown"
API_URL = f"https://api.github.com/repos/{REPO}/releases/latest"
ALLOWED_HOSTS = {
    "github.com",
    "release-assets.githubusercontent.com",
    "objects.githubusercontent.com",
}
USER_AGENT = "Jerod-Brown-SafeUpdater/1.0"


def fetch_json(url: str) -> dict:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": USER_AGENT,
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def current_platform() -> str:
    if sys.platform.startswith("win"):
        return "windows"
    if sys.platform.startswith("linux"):
        return "linux"
    raise SystemExit("Unsupported platform. Use --platform windows or linux.")


def asset_matches(name: str, target: str) -> bool:
    lowered = name.lower()
    # Only choose explicitly named platform packages, never source archives.
    if lowered.endswith((".zip", ".tar.gz", ".tgz", ".deb", ".rpm")):
        if any(token in lowered for token in ("source", "source-code", "checksums")):
            return False
        if target == "windows":
            return any(token in lowered for token in ("windows", "win-x64", "win32", "win64"))
        return any(token in lowered for token in ("linux", "linux-x64", "linux-amd64"))
    return False


def safe_filename(name: str) -> str:
    # Ignore any directory components supplied by remote metadata.
    cleaned = Path(name).name
    if not cleaned or cleaned in {".", ".."} or not re.fullmatch(r"[A-Za-z0-9._+-]+", cleaned):
        raise SystemExit(f"Refusing unsafe asset filename: {name!r}")
    return cleaned


def download_verified(asset: dict, destination: Path) -> None:
    digest = asset.get("digest") or ""
    if not digest.startswith("sha256:"):
        raise SystemExit("Release asset has no SHA-256 digest; refusing download.")
    expected = digest.removeprefix("sha256:").lower()
    if not re.fullmatch(r"[0-9a-f]{64}", expected):
        raise SystemExit("Release asset digest is malformed; refusing download.")

    url = asset.get("browser_download_url", "")
    parsed = urlparse(url)
    if parsed.scheme != "https" or parsed.hostname not in ALLOWED_HOSTS:
        raise SystemExit("Release asset URL is not an approved HTTPS GitHub host.")

    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    temp = destination.with_suffix(destination.suffix + ".part")
    hasher = hashlib.sha256()
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            final_host = urlparse(response.geturl()).hostname
            if final_host not in ALLOWED_HOSTS:
                raise SystemExit("Download redirected to an unapproved host.")
            with temp.open("wb") as output:
                while True:
                    chunk = response.read(1024 * 1024)
                    if not chunk:
                        break
                    hasher.update(chunk)
                    output.write(chunk)
        actual = hasher.hexdigest()
        if actual != expected:
            raise SystemExit(
                f"SHA-256 mismatch. Expected {expected}, got {actual}. "
                "The staged file will be removed."
            )
        os.replace(temp, destination)
    finally:
        if temp.exists():
            temp.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", choices=("windows", "linux"), default=None,
                        help="Target OS; defaults to the current OS.")
    parser.add_argument("--out", type=Path, default=Path("staged-release"),
                        help="Directory where the verified asset is staged.")
    args = parser.parse_args()
    target = args.platform or current_platform()

    print(f"Checking latest release for {REPO}...")
    try:
        release = fetch_json(API_URL)
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Could not retrieve release metadata: {exc}") from exc

    if release.get("draft") or release.get("prerelease"):
        raise SystemExit("Latest release is a draft or prerelease; refusing it.")

    candidates = [
        item for item in release.get("assets", [])
        if item.get("state") == "uploaded" and asset_matches(item.get("name", ""), target)
    ]
    if not candidates:
        raise SystemExit(
            f"No published {target} package found in release {release.get('tag_name')!r}. "
            "Publish an asset with 'windows' or 'linux' in its filename and a GitHub SHA-256 digest."
        )
    if len(candidates) > 1:
        names = ", ".join(item.get("name", "?") for item in candidates)
        raise SystemExit(f"More than one matching asset found; choose one explicitly: {names}")

    asset = candidates[0]
    args.out.mkdir(parents=True, exist_ok=True)
    destination = args.out.resolve() / safe_filename(asset["name"])
    print(f"Release: {release.get('tag_name', '(untagged)')}")
    print(f"Asset:   {asset['name']}")
    download_verified(asset, destination)
    print(f"Verified SHA-256: {asset['digest']}")
    print(f"Staged at: {destination}")
    print("Nothing was executed or installed. Review the package and install it manually.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
