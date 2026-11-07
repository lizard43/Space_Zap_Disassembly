# Space Zap: TERSE runtime and source archaeology
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

## Exact primitive-level comparison with cartridge TERSE

Nine bounded original machine-code fragments share 70 exact bytes with the Coloring Book/Cosmic Raiders native primitive family. The source ROM is `0662.01` (SHA-1 `784ac67c75c7c101f97ebfd39b2b3f7bf7fa470a`); the comparison implementation is `lizard43/colbook/src/colbook-terse-runtime.asm`. This is bounded routine identity, not identity of the entire interpreter.

## Word-by-word common code

| Word / runtime operation | Space Zap arcade | Cartridge | Bytes | Arcade machine code | Stack / control behavior |
| --- | --- | --- | ---: | --- | --- |
| COLON ENTRY | `$0008` | `$2019` | 13 | `DD 2B DD 70 00 DD 2B DD 71 00 C1 FD E9` | Save caller BC to IX; take RST return address as child thread |
| EXIT | `$0044` | `$2057` | 12 | `DD 4E 00 DD 23 DD 46 00 DD 23 FD E9` | Restore parent BC from IX; return via IY |
| LIT16 | `$0050` | `$2063` | 9 | `0A 03 6F 0A 03 67 E5 FD E9` | Fetch 16-bit inline little-endian literal |
| LIT8 | `$0059` | `$206C` | 8 | `0A 03 6F 26 00 E5 FD E9` | Fetch 8-bit inline literal, zero extend |
| ZERO | `$007B` | `$2084` | 6 | `21 00 00 E5 FD E9` | Push $0000 |
| ONE | `$0081` | `$208A` | 6 | `21 01 00 E5 FD E9` | Push $0001 |
| DUP | `$0087` | `$2090` | 5 | `E1 E5 E5 FD E9` | Duplicate top stack cell |
| 2DUP | `$008C` | `$2095` | 8 | `E1 D1 D5 E5 D5 E5 FD E9` | Duplicate top two cells |
| DROP | `$0094` | `$209D` | 3 | `E1 FD E9` | Discard top stack cell |

**Total: 70 matching instruction bytes across 9 fragments**. The entries
are not claimed to be one uninterrupted 70-byte match.
Each is a bounded primitive/entry. Some location-dependent words elsewhere
may require relocation normalization; these nine are short routines whose
listed opcodes do not embed machine addresses.

The Space Zap and cartridge addresses differ, while these byte bodies
do not. This provides stronger evidence for common runtime code than
shared use of `JP (IY)` alone.

The original byte-token XC build used for Space Zap remains unidentified. Common native primitives do not imply identical compilation formats. The Space Zap NEXT resolves a one-byte index through the 256-entry address vector, whereas the cartridges read a two-byte execution address directly. See [historical XC lineage](TERSE-XC-LINEAGE.md).

## Native support routines and RAM structures

| ROM address | Original function | Recovered behavior |
| --- | --- | --- |
| `$026A` | `NATIVE_NEGATE_HL` | Two's-complement HL, preserving AF |
| `$0273` | `NATIVE_NEGATE_DE` | Two's-complement DE, preserving AF |
| `$027E` | `TERSE_COLON_027E` | Compiled thirteen-token helper; complete semantics under analysis |
| `$028C` | `NATIVE_ATOMIC_COMPARE_UPDATE` | Interrupt-masked record comparison/update, HL status |
| `$02DF` | `NATIVE_ATOMIC_RECORD_CHECK` | Interrupt-masked two-word record check/update |
| `$0336–$0345` | Eight RAM word addresses | `$D0A1,$D0D7,$D0D9,$D10F,$D111,$D12F,$D131,$D14F` |
| `$0346` | `NATIVE_EVENT_RECORD_DISPATCH_0346` | Native record dispatch using RAM address table |

RAM ownership and I/O side-effect analysis is ongoing; source labels identify confirmed entry boundaries, not necessarily complete application-level semantics.

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
and native continuations. Whole-runtime byte identity, complete word-for-word
identity and original source ancestry **have not been demonstrated**
for Space Zap versus the cartridges. A future comparison should
normalize relocated native address references, classify the opcode
and control-flow behavior of each primitive, and hash
matched routines, not arbitrary equal-size windows.

## Technical references

See the [word dictionary](TERSE-WORD-DICTIONARY.md), [original vector table](TERSE-TOKEN-VECTORS.md), [compiled application programs](TERSE-COMPILED-PROGRAMS.md), [ROM assets and hardware](ROM-ASSETS-AND-AUDIO.md), and [XC lineage](TERSE-XC-LINEAGE.md).
