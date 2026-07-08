# Quickstart

This folder contains the Velo MTA proof application.

## Requirements

- Windows 10/11 x64
- NVIDIA GPU recommended
- CPU x86 mode available
- Windows Terminal recommended

## Folder Layout

```text
Velo-MTA/
  velocity.exe
  models/
    qwen3.5-4b-adapt-b32.mfy   <- downloaded automatically on first run
```

The `.mfy` artifact contains the packaged model data used by Velocity.

## Start Chat

Open Windows Terminal in this folder:

```powershell
.\velocity.exe
```

The app will:

1. **On first run**, if no model is present, download the `.mfy` from Hugging Face
   (~2.95 GB, one time) into `models/` and verify its SHA-256. An interrupted download
   resumes on the next launch. Later runs skip this and use the local file.
2. Load the `.mfy` model.
3. Prepare the GPU-resident matrix.
4. Open the terminal chat.

You can then type normal prompts.

## First Commands To Try

```text
/help
/settings
/pc
/backend
/stats
/bench
/verify
```

Switch execution mode:

```text
/mode adapt
/mode exact
```

Switch backend:

```text
/backend auto
/backend cuda
/backend cpu
```

`auto` uses CUDA when an NVIDIA CUDA device is available. `cpu` runs the native x86 Q4 path and does not use CUDA for that turn.

Thinking controls:

```text
/think on
/think off
/thoughts on
/thoughts off
```

Code workflow:

```text
Write a calculator in one HTML file.
/copy
```

Long answer workflow:

```text
Create a full HTML/CSS/JS landing page for a Porsche detailer.
/continue
```

`Ctrl+C` stops the current generation while keeping the app open.

## Startup Options

```text
velocity.exe --model <path.mfy>
velocity.exe --backend auto
velocity.exe --backend cuda
velocity.exe --backend cpu
velocity.exe --exact
velocity.exe --max-ctx 8192
velocity.exe --max-new 4096
velocity.exe --plain
velocity.exe --prompt "Explain MTA in two paragraphs."
```

## Troubleshooting

**Model not found / download failed**

On first run Velocity downloads the model automatically. If it fails (no connection,
firewall), download `qwen3.5-4b-adapt-b32.mfy` manually and put it inside `models/`,
next to `velocity.exe`, then relaunch. A partial `models/*.mfy.part` file is a resumable
download — leave it and relaunch to continue.

**Terminal looks broken**

Use Windows Terminal. Legacy consoles may not render colors and fullscreen controls correctly.

**Answer stopped early**

The answer reached the token budget. Type:

```text
/continue
```

**Need to paste a long prompt**

Paste normally into the prompt line. Velocity handles pasted text as prompt input.

## License

Copyright (c) 2026 Velo / Motify. All rights reserved.

This proof package is proprietary. See `LICENSE.txt`.

