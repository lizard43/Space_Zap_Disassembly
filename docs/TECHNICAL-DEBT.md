# Space Zap — technical debt and outstanding verification

This is the active, actionable technical-debt register for the follow-on RE sprint (PR #2). The previous PR #1 research and source edits are retained in ordinary Git history; no duplicate preservation branch or historical snapshot is required.

## Baseline — PR #1 merged

- **Verified baseline:** user reports successful assembly of the complete 16,384-byte image and matching SHA-1 values for all four original 4 KB ROMs. PR #1 was merged to `main` at `0183fadf948425654e08d8f690bfb0a35f37c807`. PR #2 is based on updated `main`.
- Previous source-layout and token-vector-pointer size discrepancies are historical resolved build blockers, not active defects. Preserve their diagnosis in Git history.
- Every subsequent ROM-affecting change must rebuild the complete image and reproduce all four original SHA-1 values. No padding, synthetic code, or JavaScript token-rewriting substitution.
- Remaining debt concerns original terminology, grammar, unidentified word contracts, hardware meaning, and deeper source recovery, not a known failing PR #1 baseline.

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
