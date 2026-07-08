# Velocity — MTA Proof Build

### Existing models. No retraining. Verified local execution.

Velocity is not another AI chat app. Velocity builds **Motify** — a native execution stack for
local AI models, based on sealed `.mfy` artifacts and **MTA (Motify Transit Architecture)**.
The chat is only the interface; the execution stack underneath is the product.

This is a **proof build**: everything it claims, it can measure on your machine.

```text
existing model → MTA compiler → sealed .mfy artifact → Velocity runtime
             → CUDA execution path → MTA Exact / MTA Adapt → local AI
```

No Python. No PyTorch. No server. No cloud. One `.exe`.

---

## Download

| | |
|---|---|
| **Windows proof build** | [Download VeloSetup.exe](https://github.com/Veloresearch/velocity-mta-proof/releases/latest) |
| **Model artifact** | [veloresearch/qwen3.5-4b-adapt-b32 on Hugging Face](https://huggingface.co/veloresearch/qwen3.5-4b-adapt-b32) |

The installer can download the `.mfy` artifact (~2.95 GB) during setup, SHA-256 verified.
If skipped, `velocity.exe` downloads and verifies it automatically on first launch, with resume
support for interrupted downloads. No account or token is required.

---

## Tested configuration

Every number in this repository was measured on this machine — a mid-range consumer laptop GPU,
deliberately. If it runs here, it runs on ordinary hardware.

```text
GPU       NVIDIA RTX 3060 Laptop GPU, 6 GB VRAM
Backend   CUDA, GPU-resident Q4 path
Artifact  qwen3.5-4b-adapt-b32.mfy (frozen Qwen-family 4B, 4-bit)
OS        Windows 11 x64
```

Observed local behavior on this configuration:

```text
Prefill   ~63–66 tok/s
Decode    ~52–55 tok/s
VRAM      ~3 GB total at the default context budget
Quality   ppl 2.364 (Adapt) vs 2.373 (Exact) on the fixed benchmark corpus
```

Your numbers will differ with GPU, drivers, thermals, and configuration — which is exactly why
the benchmark suite ships inside the app (`/bench`). Don't quote ours; measure yours.

---

## Known limits (read this before benchmarking)

This is a v0.1 proof build. It is honest about where the edges are:

- **Context budget defaults to 8192 tokens.** This is a deliberate VRAM choice for 6 GB cards,
  not an architecture ceiling — the attention-cost benchmark itself measures up to 32,768 tokens.
  With more VRAM, raise it: `velocity.exe --max-ctx 16384` or `--max-ctx 32768`.
- **Windows x64 + NVIDIA CUDA is the tested performance path.** A native CPU (AVX2) fallback is
  built in and runs the same artifact, but it is a compatibility path, not the speed path.
- **Greedy decoding.** The proof build runs the model deterministically, as-is — no sampling
  tricks, no anti-repeat rewriting layered on top. What the model produces is what you see.
- **One artifact so far in public.** The public proof ships the Qwen-family 4B artifact.
  A Gemma-family artifact is part of the current internal validation path.
- **Perplexity is corpus-relative.** The `/bench` PPL number uses a fixed public-domain text so
  Exact and Adapt are comparable *on the same machine*. It is not a WikiText-2 score and should
  not be compared against papers.

---

## MTA — Motify Transit Architecture

Velocity exposes two working MTA paths today, with a third in development:

| Path | Status | Role |
|---|---|---|
| **MTA Exact** | working | full-window reference path — baseline, parity, auditability |
| **MTA Adapt** | working | the product path — existing models through Motify, **no retraining** |
| **MTA Native** | future | models designed directly for Velocity's execution stack |

> **Exact proves trust. Adapt ships existing models. Native breaks the ceiling.**

### MTA Exact

The verification path. Use it to answer one question: *does this `.mfy` artifact preserve
expected baseline behavior?* Every optimized mode should be judged against a reference the user
can run — Exact is that reference, one command away (`/mode exact`).

### MTA Adapt

The current product path. It runs an existing, frozen model through Motify's adaptive execution —
attending the active context (sink + recent + selected KV) instead of the full window — without
retraining and without giving up the baseline:

```text
EXACT : ppl 2.373
ADAPT : ppl 2.364   (−0.4% vs Exact on the fixed corpus, this machine)
```

This is presented as a **quality-preservation** result on the tested benchmark, not a universal
claim. The point is narrow and verifiable: *Adapt runs a different execution path and the quality
stays at baseline.* Speed is the part that changes — see the benchmark charts below.

---

## `.mfy` artifacts

A `.mfy` file is a sealed Motify model artifact: model payload, tokenizer metadata, runtime
configuration, and MTA execution metadata in one portable file. Hugging Face stores it as a
regular binary; Velocity is the runtime that knows how to open and execute it.

```text
qwen3.5-4b-adapt-b32.mfy   (~2.95 GB, self-contained — nothing else to install)
```

The Adapt selector ships *inside* the artifact — zero calibration, plug and play.

---

## The execution map

Velocity shows its execution surface instead of hiding it. The right-hand panel (`/map on`)
renders, per layer, live during generation:

- which path each layer runs (attention vs state)
- the measured **active-KV ratio** — how much of the context the attention layers actually touch
- context usage, prefill/decode speed, and the selected backend in the header

### Glossary

| Term | Meaning in the map |
|---|---|
| **GQA** | Grouped Query Attention — the attention path. Bars sized by measured active-KV %. |
| **KV** | Key/Value cache — attention memory; grows with context in the Exact path. |
| **SSM** | State Space Model — layers that keep a compact working state instead of a growing window. |
| **O(1) state** | a bounded working state whose size does not grow with conversation length. |
| **FFN** | Feed-Forward Network — the dense compute block in each layer. |

The reason this matters: the goal is not to push more tokens into the model, it is to **control
execution at the runtime layer** — and to let you watch it happen.

---

## Benchmarks

We believe in runnable proof, not screenshots. The suite ships inside the app — type `/bench`
and it measures **your** machine, renders the charts, and writes the raw numbers to
`summary.txt`. Nothing is baked in; the charts show whatever your hardware produced, and Exact
is always plotted next to Adapt.

Reference results from the tested RTX 3060 Laptop configuration:

![Full Benchmark Overview](benchmarks/00_full_benchmark.png)

| Chart | |
|---|---|
| [Context cost](benchmarks/01_context_cost.png) | per-token attention cost vs context, Exact and Adapt |
| [Context speedup](benchmarks/02_speedup.png) | the Adapt/Exact attention ratio across windows |
| [Kernel bandwidth](benchmarks/03_kernel_bandwidth.png) | Q4 GEMV throughput vs the *measured* read ceiling of the GPU |
| [Decode throughput](benchmarks/04_decode_throughput.png) | end-to-end tok/s, Exact and Adapt |
| [Perplexity](benchmarks/05_perplexity.png) | quality, Exact vs Adapt, same corpus, same machine |

Raw numbers: [benchmarks/summary.txt](benchmarks/summary.txt)

---

## Quick start

**1. Install** — run [`VeloSetup.exe`](https://github.com/Veloresearch/velocity-mta-proof/releases/latest).
Per-user install, no administrator prompt. The model downloads during setup (or on first launch).

**2. Launch** — start **Velocity** from the Start menu, or run it from a terminal
(Windows Terminal recommended):

```powershell
velocity.exe
```

Manual model download, if you prefer:

```bash
hf download veloresearch/qwen3.5-4b-adapt-b32 qwen3.5-4b-adapt-b32.mfy --local-dir ./models
```

**3. Verify the proof yourself:**

```text
/mode exact      run the reference path
/mode adapt      run the adaptive path
/bench           measure both on your machine (charts + summary.txt)
/map on          watch the per-layer execution map while it generates
/stats           last-turn speed and context numbers
```

## Commands

Type `/` in the prompt to open the command palette.

```text
/mode adapt | exact          switch MTA execution path
/backend auto | cuda | cpu   select the compute backend
/think on | off              let the model reason before answering
/map on | off                per-layer MTA execution map
/bench                       run the local benchmark suite
/stats                       last-turn speed and context stats
/new                         start a fresh conversation
/copy                        copy the last code block
/save <file>                 save the last code block to a file
/settings                    current runtime settings
/help                        list commands
/exit                        quit
```

`Ctrl+C` stops the current generation without closing the app.

## Startup options

```text
velocity.exe --model <path.mfy>      use a specific artifact
velocity.exe --backend auto|cuda|cpu
velocity.exe --exact                 start in MTA Exact
velocity.exe --max-ctx N             context budget (default 8192; raise with VRAM headroom)
velocity.exe --max-new N             max answer tokens (default 8192)
velocity.exe --think                 enable model reasoning by default
velocity.exe --plain                 no fullscreen UI / colors
velocity.exe --prompt "..."          one-shot answer, then exit
```

---

## Proof status

```text
MTA Exact        working
MTA Adapt        working
.mfy artifact    working
Qwen 4B artifact working
CUDA backend     working — preferred path
CPU x86 backend  working — compatibility fallback
HF auto-download working — setup-time and first-launch, SHA-256 verified
Local chat       working
Benchmark suite  working — /bench, reproducible locally
Execution map    working — /map
```

In internal validation: Gemma-family artifact. Next: MTA Native.

---

## Why this matters

Velocity does not compete with Qwen, Gemma, or Llama. It builds the execution layer underneath
them. If existing model families can be compiled into `.mfy` artifacts, verified through MTA
Exact, and executed through MTA Adapt without retraining — then the value is not in any one
model. It is in the artifact standard and the runtime.

And the proof runs on a 6 GB consumer laptop GPU.

## What Velocity is not

- not another chat UI, prompt wrapper, or hosted API skin
- not a fine-tuning product
- not a cloud demo
- not a claim without a runnable local proof

---

## Privacy

Inference is fully local. The only network access is the one-time model download from
Hugging Face. Conversations stay on your machine.

## License

This repository contains a public proof build and packaged binaries for Velocity / Motify.
Velocity, Motify, MTA, the `.mfy` artifact format, and the runtime/compiler technology are
proprietary Velocity technologies unless explicitly stated otherwise. Model artifacts follow the
license of their upstream base models. This repository does not grant permission to copy, modify,
redistribute, or reverse engineer Velocity proprietary technology.

© 2026 Velocity / Velo Research. All rights reserved.

## Links

- Website: [veloresearch.com](https://veloresearch.com/)
- Contact: contact@veloresearch.com
- Artifact: [veloresearch/qwen3.5-4b-adapt-b32](https://huggingface.co/veloresearch/qwen3.5-4b-adapt-b32)

---

### Don't trust screenshots.

```text
Download it. Run it. Verify it. Break it.
```
