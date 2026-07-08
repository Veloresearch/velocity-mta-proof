# Velocity — installer

This folder builds `VelocitySetup.exe`, the Windows installer users download from the
GitHub Releases page.

## What the installer does

1. Installs `velocity.exe` + docs per-user to `%LOCALAPPDATA%\Programs\Velocity`
   (no admin prompt).
2. **Downloads the model during setup**: a wizard page pulls the `.mfy` (~2.95 GB) from
   Hugging Face into `{app}\models` and verifies its SHA-256 (Inno's built-in downloader).
   The user can untick this step ("Download the AI model now"); then it downloads on first launch.
3. Adds Start-menu (and optional desktop) shortcuts.
4. **Fallback**: if the setup-time download is skipped or fails, `velocity.exe` downloads and
   verifies the model on first launch (and resumes an interrupted download next start).

The installer itself is small (a few MB) — the model is **not** bundled, it streams from
Hugging Face.

## Build it

Prereq: [Inno Setup 6](https://jrsoftware.org/isdl.php) —
`winget install --id JRSoftware.InnoSetup -e`

```powershell
# uses the prebuilt Velo-MTA\velocity.exe
powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1

# or rebuild the binary from source first, then package it
powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1 -Build
```

Output: `installer\dist\VelocitySetup.exe`.

## Release checklist

- [ ] **The Hugging Face repo must be PUBLIC.** The download URL is unauthenticated
      (`resolve/main`), so a private repo returns 401 and first-run fails. There is no
      token embedded in the binary (embedding one would leak it) — public is required.
- [ ] The `.mfy` on Hugging Face matches the SHA-256 pinned in **two** places — the binary
      (`HF_MODEL_SHA256` in `crates/velocity/src/main.rs`) and the installer
      (`ModelSHA256` in `velocity.iss`). If you re-upload the model, update **both** and rebuild.
- [ ] `VelocitySetup.exe` attached to the GitHub Release.

## Files

| file                   | purpose                                              |
|------------------------|------------------------------------------------------|
| `velocity.iss`         | Inno Setup script (per-user install, model in `app\models`) |
| `build_installer.ps1`  | stages payload + compiles the `.iss`                 |
| `staging/`             | generated payload (gitignored)                       |
| `dist/`                | generated `VelocitySetup.exe` (gitignored)           |
