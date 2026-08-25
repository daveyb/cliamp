# Winget manifests

After a GitHub Release exists with `cliamp-windows-amd64.zip` and `cliamp-windows-arm64.zip`, download `checksums.txt` from that release and generate local manifests:

```powershell
.\packaging\winget\generate.ps1 -Version 1.64.0 -ChecksumsPath .\checksums.txt
winget install --manifest packaging/winget/manifests
```

Architectures present in `checksums.txt` are the ones written. A file that only lists `cliamp-windows-arm64.zip` produces an arm64-only manifest. Pass `-Arm64InstallerUrl` or `-Amd64InstallerUrl` to point at a local zip while testing.

Do not invent SHA256 values. The script reads them from `checksums.txt`. Generated files land in `packaging/winget/manifests/` and are gitignored.
