# Space Zap — technical debt and outstanding verification

This is the active, actionable technical-debt register for the follow-on RE sprint (PR #2). The previous PR #1 research and source edits are retained in ordinary Git history; no duplicate preservation branch or historical snapshot is required.

## Release gate — PR #1

- **BLOCKER: full ROM build not proven.** PR #1 documents a previously observed image size of 16,381 bytes versus 16,384 expected, and a mismatch in the token-vector pointer at $0038 ($3DE7 generated versus original $3DEA). The PR subsequently recovered additional bytecode regions, but its own latest description still does not report a passing complete build.
- The build must produce 16,384 bytes and four 4096-byte ROMs whose SHA-1 hashes match the official values embedded in `build.sh`. Do not fix layout by blindly padding trailing bytes, replacing original TERSE with fabricated Z80, or generating a JavaScript facsimile.
- If PR #1 is merged before this proof, record it explicitly as a research checkpoint **not** as a verified original-ROM reconstruction. Preferred sequence: verify and repair on PR #1, merge it, then retarget PR #2 to `main`.

## Historical TERSE naming and grammar

- **Unverified historical names:** Existing labels such as FETCH, STORE, ADD, PORT_IN, LIT16, EXIT, and many others are RE-assigned descriptions. Check *each* against original DNA glossary semantics and the native Space Zap stack/operand contract; replace verified matches in the user-facing TERSE dictionary with the original spelling (e.g. @, !, +, INP). Do not equate similar-sounding words without proving behavior.
- **Historical date/identity uncertainty:** DNA's supplied glossary and BNF are dated 1981; Space Zap is a 1980 ROM. A verified standard semantic equivalent is stronger than an invented label but is not alone proof of the lost 1980 spelling.
- **NEXT/return ambiguity:** The original glossary and MISC6 BNF show `CODE ... NEXT`; distinguish this from Space Zap's inner-dispatch NEXT and its colon-return routine currently labeled EXIT. Test actual behavior and seek original DNA source references before asserting spelling.
- **BNF extraction and verification:** MISC6 pages 3–4 include source grammar with scan/transcription ambiguity and potentially incomplete alternatives. Create one useful verified working grammar and note any unresolved constructs; do not establish an unnecessary second archival grammar.
- **Source reconstruction limits:** Recovered one-byte tokens and exact inline operands do not by themselves restore lost variable/function names or guarantee the unique original high-level source. Mark reconstructions as structural until independently corroborated.

## Executable RE and data boundaries

- Unresolved token semantics in the 256-slot execution vector, even where raw vector entries are already inventoried.
- Unresolved game object control-flow edges, native entry boundaries, and IY state-field ownership.
- Mixed display/message area $3096–$327B; classify native instructions, compiled words, strings, sprite/pattern data and tables without changing ROM bytes.
- Native JP/CALL targets and complete data/return-stack contracts; RAM and I/O side effects.
- Reset/attract, service, coin/start, player input, collisions, scoring, sprites, sound, and interrupt scheduling not yet fully traced.

## Hardware and future WB integration

- CPU/game-board bus writes $F0F8, $0FFA, $0FFB, $01FF: trace original schematic addressing and device selects; avoid declaring undocumented aliases.
- P1/P2 wiring, Magic/pattern transfer and sound register semantics, RAM/state ownership.
- Compare Space Zap's indexed byte-token executor with original DNA XC family and WB components; establish original source/compiler lineage only when verified.
- Integrate recovered original runtime and dictionary into WB without substituting synthetic host-side token rewriting or JavaScript emulation for source compilation.

See [SPRINT-PLAN.md](SPRINT-PLAN.md) for ordered execution tasks, and [TERSE-WORD-DICTIONARY.md](TERSE-WORD-DICTIONARY.md) plus [TERSE-TOKEN-VECTORS.md](TERSE-TOKEN-VECTORS.md) for the current evidence.
