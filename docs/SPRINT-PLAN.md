# Space Zap — active RE sprint plan

Development continues on PR #1. A correct build must match all four original 4 KB ROM SHA-1 values.

## P0 — Finish executable reconstruction

- [ ] Run zmac, verify the 16 KB output and all four ROM SHA-1 values; repair any source discrepancies.
- [ ] Classify the mixed display/message region $3096–$327B and other code/data boundaries; preserve genuine strings, graphics and tables.
- [ ] Resolve remaining native JP/CALL/branch targets using actual code entry boundaries; document stack/register contracts.
- [ ] Trace game-state flow: reset/attract, service, RAM/ROM tests, coin/start, direction/fire, collision, score, graphics and sound.
- [ ] Cross-check every used TERSE token against the actual vector/native entry and fix any incorrect semantic contract.

## P1 — Cabinet hardware and completeness

- [ ] Trace original CPU/game-board I/O decoding for startup bus addresses $F0F8, $0FFA, $0FFB and $01FF. Establish select gates, aliases and functions from schematic nets.
- [ ] Match game-board P1/P2 input connector signals to Z80 port bits; trace service, door slam, coin, fire and movement handling.
- [ ] Finish original Magic/pattern bitmap transfers, graphics objects, sound register/envelope routines, scheduling and RAM/state ownership.
- [ ] Complete RAM/I/O side-effect and interrupt-flow mapping.

## P2 — Readability and final checks

- [x] Keep seven focused technical Markdown references and eliminate redundant working notes.
- [x] Standardize concise ASM routine headers, removing duplicate token/address annotations and RE-history commentary.
- [ ] Final whole-file meaningful-label and inline-comment sweep after code/data recovery.
- [ ] Final zmac build, 16 KB image, four original ROM SHA-1 PASS.

## Current recovered work

Original indexed TERSE runtime and 256-slot vector table; major compiled colon definitions; indexed native dispatch; $28AA–$2AE0 bytecode; native screen/static RAM diagnostics; major graphics, pattern and sound hardware register families. Continued RE targets the executable program and cabinet.

## WB library follow-on — near-final Space Zap runtime and notes

Destination: [DNA TERSE WB](https://github.com/lizard43/dnaTERSE-WB). Add Space Zap (1980) as a first-class library target when recovered P0 runtime semantics and dictionary contracts are sufficiently complete. This is a working software integration, **not a preservation milestone or frozen revision**.

- [ ] Inventory existing original WB byte-token XC/runtime support and compare Space Zap against Extra Bases and Gorf. Reuse original DNA software wherever supported by opcode evidence.
- [ ] Add/document original indexed NEXT, colon/EXIT/literals, Space Zap native dictionary, 256-slot vector table, RAM and I/O bindings, startup and thread encoding.
- [ ] Identify identical primitive bodies versus relocatable or game-specific implementations.
- [ ] Compile a small real TERSE source program via the original/native XC path; reject JavaScript token-rewrite or binary façade as a substitute.
- [ ] Add runtime integration tests and exact original four-ROM SHA-1 checks where rebuilding original source is possible.
- [ ] Distinguish original 1979 XC fragments, original 1982 XC, modern compatible WB work and original Space Zap ROM findings; do not claim which historical compiler produced Space Zap without evidence.
- [ ] Update WB library index and cross-link the Space Zap architecture, dictionary, vector and compiled-program documentation.

## Engineering rules

Original DNA software and languages first. Discuss deviations before changing architecture or adding substitute tooling. Ordinary Git history provides revision tracking; do not create preservation branches, snapshots or duplicate versioned artifacts. Increment the ASM revision for source changes; only report a verified build after four-ROM SHA-1 PASS.
