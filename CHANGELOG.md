# Changelog

## v0.1 Proof Build

This build focuses on making Velocity usable as a local terminal chat while keeping the runtime claims measurable.

### Added

- Fullscreen terminal chat with pinned status header and prompt input.
- GPU-resident Q4 model path for `qwen3.5-4b-adapt.mfy`.
- Adapt and Exact execution modes.
- Live thinking preview.
- `/thoughts on` and `/thoughts off` to show or hide thinking.
- `/settings` for runtime settings.
- `/pc` for machine and runtime hardware information.
- `/backend auto|cuda|cpu` for switching between CUDA GPU-resident mode and CPU x86 Q4 mode.
- `/copy` to copy the most recent code block.
- `/continue` for long answers that hit the token budget.
- `Ctrl+C` stops generation without closing the app.
- Bracketed paste support for pasting longer prompts into the input line.
- Larger default answer budget: `--max-new 4096`.
- Live working status before the first token: elapsed seconds, prefill/waiting phase, and `Ctrl+C` stop hint.
- Incomplete-response detection for code/HTML answers, with a visible `/continue` hint instead of silently accepting a cut-off answer.
- Runtime guard for repeated thinking loops so the model stops before burning the full token budget.

### Improved

- Cleaner Velocity terminal layout.
- Stable prompt input area.
- Code blocks are easier to read and copy.
- Command palette now shows all matching commands after `/`.
- Long prefill no longer looks frozen; the prompt dock updates while the model is working.
- README and Quickstart updated for the current runtime behavior.
- Startup options now include `--backend auto`, `--backend cuda`, and `--backend cpu`.

### Setup

- Windows installer (`VelocitySetup.exe`) — per-user install, no admin required.
- First run downloads the model automatically: if no `.mfy` is present, Velocity fetches it
  from Hugging Face (~2.95 GB, one time), verifies its SHA-256, then starts the chat.
  Interrupted downloads resume on the next launch.

### Notes

- Exact mode is the reference path.
- Adapt mode is the current MTA product path.
- CUDA remains the intended performance path; CPU mode is available for x86 fallback/testing.
- Measurements shown in the app are local runtime measurements.
- This package remains proprietary. See `LICENSE.txt`.
