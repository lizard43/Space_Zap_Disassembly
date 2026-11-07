# Space Zap — active RE sprint plan

PR #1 established the recovered runtime and initial RE, and was merged into `main` at `0183fadf948425654e08d8f690bfb0a35f37c807` after the user reported a successful build with matching original ROM SHA-1 values. PR #2 now targets `main` and carries the remaining sprint work. Maintain the four-ROM SHA-1 verification gate for subsequent source changes.

## PR #2 — original DNA TERSE vocabulary and source-structure recovery

- [ ] Audit **every recovered primitive** against the DNA September 21, 1981 TERSE Standard Glossary and the actual Space Zap native implementation and stack/inline-operand contracts.
- [x] Replace 24 invented dictionary names with **original DNA TERSE spellings** on matching implementations; keep assembly identifiers syntactically legal. Continue matching remaining primitives as they are recovered.
- [x] Name matching recovered primitives using the original DNA TERSE words, without speculative historical naming caveats. Only actual unidentified behavior or word identity remains unresolved.
- [ ] Investigate remaining unidentified words through vector targets, native control flow, callers and matching DNA sources; provisional naming must not be presented as historical terminology.
- [ ] Transcribe the original TERSE BNF from MISC6 pages 3–4, correct transcription errors against the page images, and verify ambiguous productions against original TERSE behavior. Use one working grammar, grounded in the original source, rather than parallel competing versions.
- [ ] Apply the BNF to identify colon, CODE, control-flow, variable, constant, array and data structures in decoded Space Zap threads; distinguish recovered source structure from exact original source text where names are lost.
- [ ] Resolve remaining return/dispatch identities (`NEXT`, compiled definition return, `;`, current `EXIT`) by their actual native behavior; use DNA word names directly when matched.
- [ ] Preserve exact original byte stream, address layout and compiled operands. Require a complete 16,384-byte zmac build and all four official ROM SHA-1 matches; no padding, synthetic code, or token-rewriting workaround.
- [ ] Carry forward the existing P0/P1/P2 recovery work and track unresolved items in [TECHNICAL-DEBT.md](TECHNICAL-DEBT.md).

## Previously completed on PR #1 — source readability

- [x] Remove redundant ROM ZIP ownership discussion from README.
- [x] Repair orphaned inline-add comment by labeling its native entry; standardize TERSE constant stack contracts.
- [x] Replace mechanical token/address/native-target line comments in compiled TERSE with recovered word names, keeping unknown identities as token numbers.
- [x] Separate five additional executable blocks following `REDRAW_SAVED_OBJECT` and document their object rendering/motion/collision role.
- [x] Resolve established numeric callers to object-coordinate `$07DA`, object-advance `$0852`, and boundary-check `$0978` native entries.
- [ ] Finish remaining object control-flow edges, verify physical addresses of other entry blocks, and document IY state-field ownership before completing their contracts.

## P0 — Finish executable reconstruction

- [x] PR #1 baseline: user reported a successful 16 KB build and all four matching original ROM SHA-1 values.
- [ ] Re-run zmac and all four SHA-1 checks after any new source changes; repair any discrepancies.
- [ ] Classify the mixed display/message region $3096–$327B and other code/data boundaries; preserve genuine strings, graphics and tables.
- [ ] Resolve remaining native JP/CALL/branch targets using actual code entry boundaries; document stack/register contracts.
- [ ] Trace game-state flow: reset/attract, service, RAM/ROM tests, coin/start, direction/fire, collision, score, graphics and sound.
- [ ] Cross-check every used TERSE token against the actual vector/native entry and fix any incorrect semantic contract.

## P1 — Cabinet hardware and completeness

- [ ] Trace original CPU/game-board I/O decoding for startup bus addresses $F0F8, $0FFA, $0FFB and $01FF. Establish select gates, aliases and functions from schematic nets. **Schematic review:** original manual CPU board page 44 and game board page 38 show interface/address wiring; the provided sheets do not yet establish the internal custom-chip register alias truth table. Resolve by tracing chip-select/address nets through game-board circuitry and the Astrocade custom IC register decode, or confirming the four writes with a cabinet bus trace.
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

**Original DNA TERSE vocabulary is authoritative. Match by implementation and stack behavior, use the correct name, and move on.**

**Mandatory bidirectional source/dictionary round trip:** Every recovered word-name or execution-contract change must be propagated consistently among `Space_Zap_Disassembly.asm`, `docs/TERSE-WORD-DICTIONARY.md`, `docs/TERSE-TOKEN-VECTORS.md`, and decoded-program references. The same requirement applies in reverse: source changes must update the dictionary and vector records. Run `node tools/verify-terse-word-alignment.mjs` after nomenclature changes; for every ROM-affecting change, also require `./build.sh` and all four official ROM SHA-1 matches. A documentation-only change is not complete while the source still uses contradictory TERSE word names.

Original DNA software and languages first. Discuss deviations before changing architecture or adding substitute tooling. Ordinary Git history provides revision tracking; do not create preservation branches, snapshots or duplicate versioned artifacts. Increment the ASM revision for source changes; only report a verified build after four-ROM SHA-1 PASS.
