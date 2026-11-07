# Space Zap: TERSE runtime and source archaeology
Research checkpoint • 2026-11-07

![Space Zap TERSE execution](../images/spacezap-terse-execution.svg)

## Confirmed execution model

The first 16 KB of Space Zap is a Z80 game program with a full
**indexed-token TERSE-family** interpreter, not a generic native-Z80 game.

| Code/data | Address | Verified interpretation |
| --- | --- | --- |
| Colon entry | `$0008` | Preserve previous BC on IX, POP BC from Z80 RST return address, resume IY |
| Cold startup | `$0015` | Set arcade I/O, IX=`$D800`, SP=`$D780`, BC=`$3CDC`, IY=`$0035` |
| Indexed NEXT | `$0035` | Consume **one byte**, double index, select a two-byte native handler address at `$3DEA` |
| EXIT | `$0044` | Restore prior BC through IX, return to IY |
| LIT16 | `$0050` | Fetch little-endian inline word, push HL |
| LIT8 | `$0059` | Fetch zero-extended inline byte, push HL |
| Token address table | `$3DEA` | 256 × 16-bit addresses, filling `$3DEA–$3FE9` |
| Initial stream | `$3CDC` | Starting token stream pointer |

The startup's `LD IY,$0035` makes the dispatch location unambiguous;
each native primitive normally finishes with `JP (IY)`. The original
signature-scan document reports 65, 52, 13 and 9 `JP (IY)` occurrences by ROM,
for 139 total. That count is supporting evidence, not the basis of
classification: the full register, stack and dispatch machine is present.

```z80
; $0035, Space Zap byte-token NEXT
LD A,(BC)
INC BC
LD DE,$3DEA
LD L,A
LD H,$00
ADD HL,HL
ADD HL,DE
LD E,(HL)
INC HL
LD D,(HL)
EX DE,HL
JP (HL)
```

### Same TERSE architecture, different threaded representations

![Indexed-token versus direct-threaded TERSE](../images/spacezap-threading-comparison.svg)

| Property | Space Zap arcade | Coloring Book / Cosmic Raiders |
| --- | --- | --- |
| Execution format | **8-bit indexed token** | **16-bit native execution address** |
| Token dispatch | ROM table lookup `$3DEA + 2×token` | Native address already in thread |
| NEXT | `$0035` | Cartridge `$2050` |
| Colon entry | `$0008` | Cartridge `$2019` |
| EXIT | `$0044` | Cartridge `$2057` |
| LIT16 | `$0050` | Cartridge `$2063` |
| LIT8 | `$0059` | Cartridge `$206C` |
| Thread IP | BC | BC |
| Control stack | IX | IX |
| Data/native stack | SP | SP |
| Primitive continuation | IY / `JP (IY)` | IY / `JP (IY)` |
| Cost | One byte per word reference, plus 512-byte vector table | Two bytes per word reference, simpler NEXT |
| Classic Forth nomenclature | Indexed-token / token-threaded, **not automatically indirect-threaded Forth** | Direct-threaded |

An important distinction for the historical manuscript: this is not
simply one kernel relocated. The **semantics of the execution cell**
are different. Both use a clearly related TERSE ABI; whether a
single original DNA XC could emit both representations, or the
arcade target had a distinct compiler, remains unproven.

The byte-token representation may be smaller for large programs but
adds one native address-table lookup per executed token. No performance
measurements are asserted here.

## The two 688-byte comparisons

The TERSE repository's `spacezap_terse_signature_688.bin` and
`scanner/data/fingerprints/terse-688-reference-window.bin` are the
**same file content** (identical Git blob SHA
`10096c679de019f864095e647036124dca59f7a9`).
It is the **first 688 bytes of Space Zap** (`$0000–$02AF`), a
convenient reference slice, not an independently discovered 688-byte
module boundary. It contains cold start, colon entry, indexed NEXT
and many primitives.

The separate `TERSE_688_runtime_map.txt` describes a *different*
**688-byte shared cartridge window** in Coloring Book and Cosmic
Raiders at reference `$0050–$02FF` (mapped cartridge `$2050–$22FF`),
whose SHA-1 is `e823880952bcb6ff65cfc89b32781a9ace5`.
That exact range is byte-identical between **those two cartridge
prototypes**, not between them and Space Zap.

Shared functionality is supported at the level of colon entry,
NEXT/EXIT, 16- and 8-bit literals, data/return stack organization,
and native continuations. Byte identity, complete word-for-word
identity and original source ancestry **have not been demonstrated**
for Space Zap versus the cartridges. A future comparison should
normalize relocated native address references, classify the opcode
and control-flow behavior of each primitive, and hash
matched routines, not arbitrary equal-size windows.

## ROM region notes

| Address range | Role / status |
| --- | --- |
| `$0000–$0FFF` | ROM X1; startup and TERSE kernel, native routines and other content |
| `$1000–$1FFF` | ROM X2; mixed program/data, not fully typed |
| `$2000–$2FFF` | ROM X3; game objects, sprite records and graphics |
| `$3000–$3FFF` | ROM X4; application data and end-of-ROM token table |
| `$3CDC` | Initial compiled token stream |
| `$3DEA–$3FE9` | 256-entry indexed native handler-vector table |
| `$3FEF` onward | `SPACE ZAP\0DNA\0` and terminal bytes |

![Provisional Space Zap memory map](../images/spacezap-memory-map.svg)

**Map caution:** The four low 4 KB ROM sockets and the TERSE
addresses come directly from the source and ROM. The full
64 KB external address decode, video/magic window semantics,
and high RAM aliases require validation against the Space Zap
CPU board schematic and MAME's specific game map; those areas
are deliberately marked provisional in the figure. Do not
carry provisional address labels into hardware documentation
as proven decode.

## Native source recovery

The original compiled byte-token programs are indexed in
[Compiled TERSE programs](TERSE-COMPILED-PROGRAMS.md), with typed source
labels, inline literal/branch encoding and verified original ROM spans.

The maintained Z80 source now has named and documented TERSE primitives
for literals, stacks, arithmetic, logic, memory, ports, branches and loop
indexes. The indexed 256-entry native vector table is explicit `DW` data;
entries resolving to identified primitive labels are symbolic.

The following complete original-ROM assets are represented as named data
in the assembly:

- 37-glyph, 8×10 pixel font (`$13C4–$1535`), with an inline 1bpp pixel plot
  for each row.
- Screen text records at `$3097–$327B`, including credit/coin prompts,
  both player titles, scoring and game-over messages.
- Original 2bpp bitmap sprite/animation records.
- ROM title, `DNA` identification and `08/19/80` date at `$3FEF–$3FFF`.

The original arcade sound-chip routines include the eight-register reset
at `$1FC9`, oscillator step at `$2034`, noise-envelope step at `$20B5`,
and indexed register writer at `$213E`. These are labeled in source;
their hardware/parameter contracts are in [ROM assets and audio](ROM-ASSETS-AND-AUDIO.md).

### Additional native routine boundaries

The original native arithmetic helpers at `$026A` and `$0273` now
have dedicated labels for two's-complement operations on HL and DE.
The short colon definition at `$027E` is represented as TERSE tokens,
followed by two native interrupt-protected record routines at `$028C`
and `$02DF`.

The 16-byte block at `$0336–$0345` is an eight-entry `DW` table of RAM
addresses (`$D0A1`, `$D0D7`, `$D0D9`, `$D10F`, `$D111`,
`$D12F`, `$D131`, `$D14F`). The native record dispatch immediately
after this table is labeled `NATIVE_EVENT_RECORD_DISPATCH_0346`.

The full `$270D–$2AE0` compiled/data region is now typed in the
assembly and all **980 reconstructed bytes** were compared to the
original ROM. This also eliminates the false Z80 relative branches
that produced repeated zmac v1.3 `Value error` messages.

### Remaining code recovery

- Continue decoding the remaining colon programs in the middle ROM;
  complete the game-semantic naming of reconstructed words and operands.
- Split and label the remaining native game-state, interrupt, input, display,
  scoring and coin handling code into callable routines.
- Replace the rest of the invalid instruction streams with typed tables,
  graphics or TERSE thread bytes.
- Resolve all native-table target semantics and native-word stack contracts.
- Complete the RAM and I/O ownership map.
- Assemble the modified source using native zmac and compare all four
  generated ROM SHA-1 hashes against the original MAME set.

## ROM data and console adaptation notes

The arcade disassembly includes inline 2bpp sprite rows and records for
laser bases, alien ships, mines and attack satellites. The ROM tail stores
`SPACE ZAP` and `DNA` text. The 256 native-address vector slots at
`$3DEA` are represented as typed `DW` entries in the maintained assembly.

**Space Fortress (1981)** is a separate 4 KB Bally Astrocade cartridge
adaptation of Space Zap. Its released ROM lacks the arcade's recognizable
`JP (IY)` continuation signature; the cartridge has not been identified
as a TERSE program. It is not part of this arcade ROM reconstruction.
