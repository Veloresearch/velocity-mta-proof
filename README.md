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

The installer downloads the `.mfy` artifact (~2.95 GB) during setup, SHA-256 verified. If
skipped, `velocity.exe` downloads and verifies it on first launch, with resume support for
interrupted downloads. No account or token required.

> **Windows SmartScreen** will warn about an unknown publisher — the build is not code-signed
> yet. Click *More info → Run anyway*.

---

## The headline result

**MTA Adapt matches the exact path — and beats it as context grows.** Measured back-to-back on
the same machine, same model, same text (WikiText-2 raw test sample):

```text
Quality   ppl @1024 positions : EXACT 11.312 = ADAPT 11.312   (0.0% — bit-identical)
          ppl @4096 positions : EXACT 9.028 vs ADAPT 9.101    (+0.8%)

Speed     decode @3.5k context : ADAPT 58.6 tok/s vs EXACT 25.6 tok/s   (2.3x faster)
          decode, short context: ~52–55 tok/s both paths
          per-token attention @32k context: 30x+ below the full-window path
```

Below ~2k context Adapt attends the entire window — it is **literally the exact computation**.
As context grows, it selects the active keys and the cost stays bounded while Exact's grows
linearly. That crossover is the product.

Not a universal claim — a narrow, verifiable one. The benchmark suite ships inside the app:
type `/bench` and it renders these exact charts from **your** hardware. If Adapt loses on your
GPU, the chart will show it.

## Tested configuration

```text
GPU       NVIDIA RTX 3060 Laptop GPU, 6 GB VRAM
Backend   CUDA, GPU-resident Q4 path
Artifact  qwen3.5-4b-adapt-b32.mfy (frozen Qwen-family 4B, 4-bit)
OS        Windows 11 x64
VRAM      ~3 GB total at the default context budget
```

A mid-range consumer laptop GPU, deliberately. If it runs here, it runs on ordinary hardware.
Your numbers will differ with GPU, drivers and thermals — don't quote ours; measure yours.

---

## MTA — Motify Transit Architecture

| Path | Status | Role |
|---|---|---|
| **MTA Exact** | working | full-window reference path — baseline, parity, auditability |
| **MTA Adapt** | working | the product path — active execution over frozen weights, **no retraining** |
| **MTA Native** | future | models designed directly for Velocity's execution stack |

> **Exact proves trust. Adapt ships existing models. Native breaks the ceiling.**

### MTA Exact

The verification path. Use it to answer one question: *does this `.mfy` artifact preserve
expected baseline behavior?* Every optimized mode should be judged against a reference the user
can run — Exact is that reference, one command away (`/mode exact`).

### MTA Adapt

The product path. It runs an existing, frozen model through active execution: an embedded
selector scores the cached context cheaply, exact-rescores the best candidates, and attention
runs over that active set — sink, recent window, and selected keys. The active budget adapts to
the context, so quality holds while the cost stays bounded. No retraining, no calibration; the
selector ships inside the artifact.

Verify it yourself, one command each:

```text
/mode exact  →  /bench ppl
/mode adapt  →  /bench ppl
```

---

## `.mfy` artifacts

A `.mfy` file is a sealed Motify model artifact: model payload, tokenizer metadata, runtime
configuration and the embedded Adapt selector in one portable file. Hugging Face stores it as a
regular binary; Velocity is the runtime that knows how to open and execute it.

```text
qwen3.5-4b-adapt-b32.mfy   (~2.95 GB, self-contained — nothing else to install)
```

---

## The execution map

Velocity shows its execution surface instead of hiding it. `/map on` renders, per layer, live
during generation: which path each layer runs, the measured **active-KV ratio**, context usage,
and prefill/decode speed.

| Term | Meaning in the map |
|---|---|
| **GQA** | Grouped Query Attention — the attention path; bars sized by measured active-KV % |
| **KV** | Key/Value cache — attention memory; grows with context on the Exact path |
| **SSM** | State Space Model — layers with a compact working state instead of a growing window |
| **O(1) state** | a bounded working state that does not grow with conversation length |
| **FFN** | Feed-Forward Network — the dense compute block in each layer |

---

## Benchmarks

We believe in runnable proof, not screenshots. `/bench full` measures **your** machine, renders
shareable PNG charts (each stamped with your device name) and writes the raw numbers to
`summary.txt`. Nothing is baked in, Exact is always plotted next to Adapt, and every step prints
its wall time.

Reference results from the tested configuration:

![Full Benchmark Overview](benchmarks/00_full_benchmark.png)

| Chart | |
|---|---|
| [Context cost](benchmarks/01_context_cost.png) | per-token attention cost vs context, Exact and Adapt |
| [Context speedup](benchmarks/02_speedup.png) | the Adapt/Exact attention ratio across windows |
| [Kernel bandwidth](benchmarks/03_kernel_bandwidth.png) | Q4 GEMV throughput vs the *measured* read ceiling of the GPU |
| [Decode throughput](benchmarks/04_decode_throughput.png) | end-to-end tok/s, Exact and Adapt |
| [Perplexity](benchmarks/05_perplexity.png) | quality, Exact vs Adapt, same corpus, same machine |

The perplexity corpus is the opening ~120 KB of the **WikiText-2 (raw) test split** (the same
family as llama.cpp's `wiki.test.raw`), embedded so the number is reproducible offline. It is a
sample of the split — treat it as an Exact-vs-Adapt comparison on standard text, not a
paper-comparable full-WikiText-2 score. `/bench ppl <file>` scores any text you choose.

---

## Quick start

**1. Install** — run [`VeloSetup.exe`](https://github.com/Veloresearch/velocity-mta-proof/releases/latest).
Per-user, no administrator prompt. The model downloads during setup (or on first launch).

**2. Launch** — start **Velocity** from the Start menu (Windows Terminal recommended).

**3. Verify the proof:**

```text
/mode exact      run the reference path
/mode adapt      run active execution
/bench           measure both on your machine (charts + summary.txt)
/map on          watch the per-layer execution map live
```

## Commands

```text
/mode adapt | exact          switch MTA execution path
/backend auto | cuda | cpu   select the compute backend
/ctx | /ctx <tokens>         context budget — VRAM estimate per size, applies live
/think on | off              let the model reason before answering
/map on | off                per-layer MTA execution map
/bench                       benchmark menu: quick | ppl | speed | full (PNG charts)
/bench ppl <file>            score perplexity on your own text file
/stats                       last-turn speed and context stats
/new  /copy  /save <file>    conversation & code-block helpers
/settings  /help  /exit
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

## Known limits

- **Context budget defaults to 8192 tokens** — a deliberate VRAM choice for 6 GB cards, not an
  architecture ceiling. Raise it live with `/ctx 16384` (shows the VRAM estimate first).
- **Windows x64 + NVIDIA CUDA** (GTX 16xx / RTX 20xx or newer) is the tested performance path.
  A native CPU (AVX2) fallback runs the same artifact, slower.
- **Greedy decoding, model as-is** — no sampling tricks, no anti-repeat rewriting on top.
- **One public artifact so far** (Qwen-family 4B). A Gemma-family artifact is in internal
  validation. MTA Native is the roadmap headline.

## Proof status

```text
MTA Exact        working
MTA Adapt        working — bit-identical to Exact below ~2k ctx, active execution above
.mfy artifact    working
CUDA backend     working — preferred path
CPU x86 backend  working — compatibility fallback
HF auto-download working — setup-time and first-launch, SHA-256 verified, resume
Local chat       working
Benchmark suite  working — /bench, reproducible locally
Execution map    working — /map
GPU-vs-CPU check working — /verify (exact, adapt and FFN paths)
```

## Why this matters

Velocity does not compete with Qwen, Gemma or Llama. It builds the execution layer underneath
them. If existing model families can be compiled into `.mfy` artifacts, verified through MTA
Exact, and executed through MTA Adapt without retraining — the value is not in any one model.
It is in the artifact standard and the runtime.

And the proof runs on a 6 GB consumer laptop GPU.

## What Velocity is not

- not another chat UI, prompt wrapper, or hosted API skin
- not a fine-tuning product
- not a cloud demo
- not a claim without a runnable local proof

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
