# Space Zap — active RE sprint plan

This is a working plan, not a frozen revision or preservation checkpoint. Continue on the active Space Zap PR and update this plan as the work evolves. Use four original ROM SHA-1 comparisons as the normal build correctness check.

## P0 — Native Z80 and TERSE reverse engineering

- [x] Identify indexed NEXT, colon entry, EXIT, LIT8/LIT16 and 256 vector slots.
- [x] Recover the major middle-ROM and startup compiled TERSE programs.
- [x] Recover native token $94 inline 16-bit addition and correct 12 misdecoded inline operands.
- [x] Convert confirmed numeric JP/CALL references to existing Z80 routine labels, including reset-to-TERSE_COLD_START; label reset vector without changing machine instructions.
- [ ] Audit vector-referenced native routines; classify true entry points, shared internal branches, inline data, and code joins. Record meaningful, evidence-backed names.
- [x] Identify the five `$1EA1–$1EDE` native byte/word access routines, original 36-byte record stride, port `$5B` side effects, and resolve 37 symbolic call sites.
- [x] Resolve event record selector path `$034B/$0362`: shared dispatch entry plus record-2 counter increment `$D093`; replace six `$0362` call/jump sites and `$034B` references.
- [x] Audit existing main block headers for meaningful operational effects; prioritize DI at reset and omit padding commentary. Identify native record-count entry at $036E and resolve its callers.
- [ ] Whole-ROM hard RE: resolve remaining numeric JP/CALL/branch targets to existing descriptive labels where the address is proven; recover raw executable Z80 and TERSE code, preserve real DB/DW data, annotate register/stack contracts, and maintain blank-line section formatting. Do not assign semantic names solely from reference frequency.
- [ ] Establish stack effects, inline operands, control stack, RAM and I/O side effects for every actually used token. Update ASM and Forth-style dictionary together.
- [x] Decode the complete `$28AA–$2AE0` 567-byte colon program into 269 TERSE token instructions, including 13 four-target native dispatch tables, typed literal/branch operands, and validated internal branch targets.
- [ ] Continue game-semantic classification of the recovered `$28AA` program and other `$21xx–$2Axx` code/data regions; identify called routines, RAM ownership and side effects from real execution.
- [ ] Reconstruct game control: attract/start, credits, input, firing, object motion, collision, score, sound and interrupts.
- [ ] Complete RAM address ownership and hardware port interaction map.
- [x] Define confirmed video, Magic graphics, pattern-board, audio and interrupt I/O port symbols in ASM and annotate important writes; retain unresolved startup ports as explicitly unknown.
- [ ] Trace graphics and audio call chains into game-state logic, document register/RAM effects at routine boundaries, and eliminate false executable-code interpretations in graphics/sound data.
- [ ] Assemble using original native Z80 sources and pass all four official MAME ROM SHA-1 checks.

- [x] Recover token $3D indexed native dispatch and seven original four-entry jump tables, including colon word at $2866.

- [x] Recover byte-decrement/increment, memory copy, 3-cell rotate, and stack pick native primitives; synchronize dictionary and token vectors.
- [x] Consolidate redundant ROM/RE and primitive-comparison notes into reader-focused technical references; enforce ASM section spacing.

- [x] Audit low ROM native boundaries: correct token $44 (EQUAL at $00EE, **not** byte increment at $00EA); recover NEGATE token $82 and unsigned GE token $C2. Correct dictionary/vector bindings.
- [ ] Cross-check **every** new token/name mapping against the original indexed vector target **and** the exact native entry address before marking semantics complete.

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
