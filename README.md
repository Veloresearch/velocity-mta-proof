# ⚡ Velocity MTA Proof Build

### Existing models. No retraining. Verified local execution.

**Velocity is not another AI chat app.**

Velocity builds **Motify** — a native execution stack for local AI models based on sealed `.mfy` artifacts and **MTA**, the **Motify Transit Architecture**.

The chat is only the interface.  
The execution stack underneath is the product.

This proof build runs locally through the Velocity runtime.  
For the current public proof, the preferred execution path is **CUDA**.

Tested on:

```text
NVIDIA RTX 3060 Laptop GPU
6GB VRAM
CUDA backend
qwen3.5-4b-adapt-b32.mfy
```

---

## 🚀 Download

**Windows proof build:**

👉 [Download VeloSetup.exe](https://github.com/Veloresearch/velocity-mta-proof/releases/latest)

Model artifact:

👉 [Qwen `.mfy` artifact on Hugging Face](https://huggingface.co/veloresearch/qwen3.5-4b-adapt-b32)

---

## 🧠 What is Velocity?

Velocity is a local AI execution system for `.mfy` model artifacts.

Instead of shipping another wrapper around an existing model, Velocity introduces a full runtime path:

```text
existing model
→ MTA compiler
→ sealed .mfy artifact
→ Velocity runtime
→ CUDA execution path
→ MTA Exact / MTA Adapt
→ local AI execution
```

This is not fine-tuning.  
This is not prompt engineering.  
This is not another hosted API wrapper.

**Velocity is building the execution layer underneath local AI models.**

---

## 🖥️ Preferred Execution Path: CUDA

The current Velocity proof build is designed around the **CUDA execution path**.

CUDA is currently the preferred backend for running this proof because it allows Velocity/Motify to keep the model execution local while using consumer NVIDIA GPU hardware.

Current tested hardware:

```text
GPU: NVIDIA RTX 3060 Laptop GPU
VRAM: 6GB
Backend: CUDA
Runtime: Velocity / Motify
Artifact: qwen3.5-4b-adapt-b32.mfy
```

Observed local behavior on the tested machine:

```text
Prefill: ~63–66 tok/s
Decode:  ~52–55 tok/s
Backend: CUDA / GPU-resident Q4 path
Context: tested with large local context windows
```

Exact numbers may vary depending on GPU, drivers, CUDA version, thermal limits, VRAM availability, and runtime configuration.

Other execution targets may be explored later, but for the current proof:

> **CUDA is the primary and preferred execution path.**

---

## 🧬 MTA — Motify Transit Architecture

**MTA** is the execution architecture inside Motify.

Velocity currently exposes two working MTA proof paths:

- ✅ **MTA Exact** — baseline / parity / verification path
- ⚡ **MTA Adapt** — no-retraining execution path for existing model families
- 🧬 **MTA Native** — future native model path designed directly for Velocity

> **Exact proves trust.**  
> **Adapt ships existing models.**  
> **Native breaks the ceiling.**

---

## ✅ MTA Exact

**MTA Exact** is the verification path.

It is designed for baseline comparison, auditability, and parity checks.

Use MTA Exact when you want to verify:

> Does this `.mfy` artifact preserve expected baseline behavior?

MTA Exact exists to build trust.

It gives developers a reference path before evaluating any optimized or adapted execution mode.

---

## ⚡ MTA Adapt

**MTA Adapt** is the current product path.

It runs existing model families through the Motify execution stack as sealed `.mfy` artifacts **without retraining**.

Use MTA Adapt when you want to test:

> Can this existing model run through Motify’s execution path without losing quality?

Current local proof:

```text
EXACT : ppl 2.373
ADAPT : ppl 2.364
Delta : -0.4% vs Exact
```

This is presented as a quality preservation result on the tested benchmark.

It should not be interpreted as a universal claim that Adapt improves every model in every setting.

The important point is simple:

> **MTA Adapt preserves baseline quality while running through a different execution path.**

---

## 📦 `.mfy` Artifacts

A `.mfy` file is a sealed Motify model artifact.

It packages model payload, tokenizer metadata, runtime configuration, and MTA execution metadata into a portable artifact designed for Velocity.

Current proof artifact:

```text
qwen3.5-4b-adapt-b32.mfy
```

The `.mfy` format is loaded by Velocity and executed through Motify.

Hugging Face stores `.mfy` artifacts as regular binary files.  
Velocity is the runtime that knows how to open and execute them.

---

## 🛠️ Motify Runtime

Motify is the runtime layer behind Velocity.

It manages:

- artifact loading
- tokenizer setup
- chat template setup
- runtime session state
- CUDA backend execution
- MTA path selection
- Exact / Adapt execution
- benchmark reporting
- execution inspection

The goal is to make local model execution inspectable, reproducible, and verifiable.

---

## 🗺️ MTA Execution Map

Velocity exposes the execution surface instead of hiding it.

The runtime can show:

- active MTA path
- context window usage
- layer activity
- KV path
- FFN path
- selected execution mode
- CUDA execution status
- benchmark metrics

This makes the proof inspectable instead of just claimed.

---

## 📊 Proof Screenshots

Add benchmark and runtime screenshots here:

```text
screenshots/context-speedup.png
screenshots/mta-execution-map.png
screenshots/ppl-exact-vs-adapt.png
screenshots/velocity-terminal-chat.png
```

Example Markdown:

```md
![Context Speedup](screenshots/context-speedup.png)

![MTA Execution Map](screenshots/mta-execution-map.png)

![Exact vs Adapt PPL](screenshots/ppl-exact-vs-adapt.png)
```

---

## 🧪 Local Proof Release v0.1

We believe in runnable proof, not screenshots.

The v0.1 proof build lets you:

- run `.mfy` artifacts locally
- use a local terminal chat
- run through the preferred CUDA execution path
- switch between MTA Exact and MTA Adapt
- benchmark Exact vs Adapt
- inspect the MTA execution map
- test adapted model artifacts locally
- verify that MTA Adapt does not require retraining

---

## ⚙️ Quick Start

### 1. Install Velocity

Download and run:

```text
VeloSetup.exe
```

Latest release:

```text
https://github.com/Veloresearch/velocity-mta-proof/releases/latest
```

### 2. Download the `.mfy` artifact

Using Hugging Face CLI:

```bash
hf download veloresearch/qwen3.5-4b-adapt-b32 qwen3.5-4b-adapt-b32.mfy --local-dir ./models
```

Or download it from:

```text
https://huggingface.co/veloresearch/qwen3.5-4b-adapt-b32
```

### 3. Run Velocity

```bash
velocity.exe --model ./models/qwen3.5-4b-adapt-b32.mfy
```

Inside Velocity:

```text
/mode exact
/bench ppl
/mode adapt
/bench ppl
/inspect mta
```

---

## 📊 Current Proof Status

```text
MTA Exact        — working
MTA Adapt        — working
.mfy artifact    — working
Qwen artifact    — working
CUDA backend     — working / preferred
Local chat       — working
PPL benchmark    — working
Execution map    — working
```

Gemma-family MTA proof is also part of the current internal validation path.

MTA Native is the future path for Motify-native models designed directly for Velocity’s execution stack.

---

## 🔥 Why This Matters

Velocity does not compete with Qwen, Gemma, Llama, or other model families.

Velocity builds the execution layer underneath them.

If existing model families can be converted into `.mfy` artifacts, verified through MTA Exact, and executed through MTA Adapt without retraining, then the value is not in one model.

The value is in the artifact standard and runtime.

```text
model → .mfy → Velocity Runtime → CUDA / MTA execution → local AI
```

And the current proof shows this running locally on consumer NVIDIA CUDA hardware.

---

## ❌ What Velocity Is Not

Velocity is not:

- another chat UI
- a prompt wrapper
- a hosted API skin
- a fine-tuning product
- a cloud-only demo
- a claim without a local proof path

Velocity is a local AI execution stack.

---

## 🧬 Roadmap

Current proof:

```text
Exact  → verification and trust
Adapt  → existing models through Motify
CUDA   → preferred current execution path
Native → future Motify-native execution
```

The current public proof focuses on **MTA Exact**, **MTA Adapt**, and the **CUDA execution path**.

MTA Native is the next step: models designed directly for Velocity’s execution stack.

---

## 📜 License

This repository contains a public proof build and packaged binaries for Velocity / Motify.

Velocity, Motify, MTA, the `.mfy` artifact format, runtime technology, compiler technology, execution architecture, and related tooling are proprietary Velocity technologies unless explicitly stated otherwise.

Model artifacts may follow the license of their upstream base models.

This repository does not grant permission to copy, modify, redistribute, reverse engineer, or reuse Velocity proprietary technology.

© 2026 Velocity / Velo Research. All rights reserved.

---

## 🔗 Links

- 🌐 Website: [veloresearch.com](https://veloresearch.com/)
- 📩 Contact: contact@veloresearch.com
- 📦 Artifact: `qwen3.5-4b-adapt-b32.mfy`
- 🖥️ Runtime: `velocity.exe`
- 🧠 Architecture: Motify / MTA
- ⚙️ Preferred backend: CUDA

---

## Don’t trust screenshots.

Run the artifact locally.

```text
Clone it.
Run it.
Verify it.
Break it.
```

---

© 2026 Velocity / Velo Research. All rights reserved.
