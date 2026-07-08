# Benchmarks

Velocity ships its own benchmark suite — every user can reproduce every number on their own
machine. Nothing here is a marketing figure: the app measures, renders the charts, and writes a
`summary.txt` next to them.

## Run it yourself

Inside the Velocity chat:

```text
/bench full
```

This produces a dated folder `benchmarks/DDMMYYYY-Nbench/` next to `velocity.exe` with:

| file | what it shows |
|---|---|
| `00_full_benchmark.png` | the combined card — headline metrics + all charts |
| `01_context_cost.png` | per-token attention cost vs context length, **Exact and Adapt** |
| `02_speedup.png` | the Adapt/Exact attention ratio across context windows |
| `03_kernel_bandwidth.png` | Q4 GEMV kernel bandwidth vs the *measured* read ceiling of your GPU |
| `04_decode_throughput.png` | end-to-end decode tok/s, Exact and Adapt |
| `05_perplexity.png` | quality: perplexity on a fixed public corpus, Exact vs Adapt |
| `summary.txt` | all raw numbers in plain text |

## Methodology (and its limits)

- **Everything is measured locally, at run time.** There are no baked-in numbers; the charts
  render whatever your machine produced, including results where Adapt does *not* win.
- **Exact is always shown next to Adapt.** Speed without a quality reference is not a benchmark,
  so perplexity and decode charts include both modes on the same axes.
- **Perplexity is scored on a WikiText-2 sample.** The corpus is the opening ~120 KB of the
  **WikiText-2 (raw) test split** (the same family as llama.cpp's `wiki.test.raw`), embedded in
  the binary so the number is reproducible offline; 1024 positions are scored. It is a sample of
  the split, not the full file — treat it as an Exact-vs-Adapt comparison on standard text, not a
  paper-comparable full-WikiText-2 score. `/bench ppl <file>` scores any text file you choose.
- **Every step reports its wall time.** The suite prints `[n/5] … done (x.xs)` per phase and a
  total, so a shared screenshot shows how long the measurement actually took.
- **The bandwidth ceiling is measured, not quoted.** The "read ceiling" reference line is a raw
  device-to-device copy measured on your GPU right before the kernel test — not the datasheet number.
- **Hardware matters.** Numbers scale with your GPU. Publish the device string (it is stamped on
  every chart) alongside any numbers you share.
