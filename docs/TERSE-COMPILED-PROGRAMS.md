# Compiled TERSE programs

## Runtime format

Space Zap uses **8-bit indexed TERSE tokens**. Each byte selects a native
execution address from the 256-entry vector table at `$3DEA`.
`RST $08` enters a colon definition; `TERSE_EXIT` restores the
previous BC instruction pointer. Native primitives resume at `JP (IY)`.

| Token | Native XT | Operand | Meaning |
| --- | --- | --- | --- |
| `$06` | `$0044` | None | EXIT |
| `$0E` | `$0059` | 1 byte | LIT8 |
| `$1B` | `$0050` | 2 bytes, little-endian | LIT16 |
| `$03` | `$01FC` | 2-byte absolute thread address | Zero-conditional branch |
| `$46` | `$01F4` | 2-byte absolute thread address | Unconditional branch |

The `DW` directives for branches refer to **TERSE byte-stream labels**,
not Z80 instruction targets.

## P0 indexed native dispatch: token $3D

The native routine at `$023E` consumes an inline table-end/default continuation address and uses the popped 16-bit index to choose a native 16-bit execution address from the following table. Six previously misclassified `$27xx/$28xx` sequences now use explicit `DW` entries. A seventh record at `$2866` is reconstructed as a colon word with LIT16/BYTE_FETCH/INDEXED_DISPATCH/EXIT. Total updated range: **83 ROM bytes**, reconstructed byte for byte before commit.

The seven jump tables each have four entries; `$2866` selects one of four RAM-address-return colon words. Native target addresses are not TERSE token indexes. Identifying the original source-level name and game meaning remains open.

## P0 correction: unequal compare with inline branch

Token `$93` invokes the native compare/branch routine at `$0229`. Its inline operand is the following **16-bit little-endian absolute TERSE thread address**. The instruction compares two stack cells; equality skips the address and consumes both cells, whereas inequality branches and pushes the deeper cell back. This asymmetric stack contract is essential for correctly analyzing the loop/control-flow paths.

Seven sites at `$2B01`, `$2B2E`, `$2B5D`, `$2B8D`, `$2F03`, `$2F15`, and `$2F27` now use `DW` inline branch targets instead of false token records. Source bytes remain unchanged. The original source-level word name has not been recovered.

## P0 correction: native inline-address arithmetic (2026-11-07)

Token `$94` points to the native routine at `$006B`. This routine pops one data-stack cell, reads **two inline bytes from BC**, adds the resulting little-endian word to the popped value modulo 65536, and pushes the result. Its contract is `( n -- n+offset )` with an inline 16-bit displacement. This is not an ordinary zero-operand TERSE primitive.

Twelve occurrences within the decoded `$2B05–$2BE8` game-control streams are corrected from three misleading `DB` token records to `DB $94` followed by `DW $D1A9` or `DW $D1A4`. The original bytes are unchanged. These values appear to be RAM addresses when added to zero, but usage-specific semantics require caller tracing.

There is a second native entry at `$0076` that doubles the popped cell before falling into the shared inline-add code at `$006C`; this entry is not directly listed in the 256-token vector inventory. Do not misidentify it as another directly indexed token without evidence.

## Middle-ROM bytecode and native routines

The original ROM region **`$270D–$2AE0` (980 bytes)** is now expressed as
TERSE token words and original data rather than an anonymous Z80 disassembly.
Its recovered content includes **29 confirmed colon definitions**, **255 token
operations**, and **12 branch operands**. Where a word's original byte
contract remains unresolved, the source retains `DB` values in address-labeled
data records without assigning invented Z80 instructions.

Confirmed roots: `$270E`, `$2713`, `$2718`, `$2730`, `$273B`,
`$2746`, `$2750`, `$275C`, `$280F`, `$2813`, `$2818`,
`$281C`, `$2821`, `$2824`, `$2827`, `$282B`, `$282F`,
`$2833`, `$2837`, `$283B`, `$2841`, `$2848`, `$284F`,
`$2855`, `$2877`, `$2888`, `$288F`, `$2897`, `$28A1`.

The word at `$275C` includes an inline branch address `$3027`, beyond
that word's local bounds; the original address remains encoded directly.
The mixed `$2866` record and `$28AA` onward retain their exact ROM bytes
until their inline operand formats are resolved. The complete replacement
was round-tripped against all **980 original bytes** in that ROM span.

At the low end of the interpreter, `TERSE_COLON_027E` now represents the
original 13 byte-token cells at `$027E–$028B`, following two native
two's-complement register operations. The subsequent native compare/update
routines beginning at `$028C` and `$02DF` are individually labeled
with function headers. They preserve CPU interrupt state while operating
on two-word structures.

The `JR Z` value errors at source lines 6121, 6158 and 6239 arose from
interpreting **compiled data as relative Z80 branch instructions**. Replacing
the enclosing compiled/data region removes that class of false instructions
instead of editing isolated branches.

## Recovered source definitions

The following regions have been decoded into typed `DB` token cells
and `DB`/`DW` inline operands in `Space_Zap_Disassembly.asm`.

| Colon entry | Token operations | Region |
| --- | ---: | --- |
| `$0216` | 6 | Small control primitive |
| `$0220` | 6 | Small control primitive |
| `$025E` | 3 | Three-token helper |
| `$0262` | 3 | Three-token helper |
| `$0266` | 3 | Three-token helper |
| `$1311` | 87 | TERSE initialization program |
| `$1F92` | 29 | Sound/state control program |
| `$26D2–$2709` | 12 × 2 | Twelve `LIT16` address-return words |
| `$2AE2` | 9 | Game-control definition |
| `$2AF6` | 153 | Game-control definition |
| `$2BC0` | 67 | Game-control definition |
| `$2C26` | 28 | Game-control definition |
| `$2C4E` | 75 | Game-control definition |
| `$2CB2` | 74 | Game-control definition |
| `$2D19` | 73 | Game-control definition |
| `$2D7D` | 75 | Game-control definition |
| `$2DE3` | 171 | Game-control definition |
| `$2ED6` | 92 | Game-control definition |
| `$307C` | 16 | Screen/display helper |
| `$3091` | 3 | Screen/display helper |
| `$3CDB` | 156 | Main startup/control program |

### Main entry program

Cold start initializes BC to `$3CDC`, just beyond the
`RST $08` colon-entry opcode at `$3CDB`.

The first execution tokens of the main program are:

| Thread address | Token | Target |
| --- | --- | --- |
| `$3CDC` | `$F1` | Native `$2F67` |
| `$3CDD` | `$F2` | TERSE colon `$1311` |
| `$3CDE` | `$F3` | TERSE colon `$1F92` |
| `$3CDF` | `$F4` | Native `$1F20` |
| `$3CE0` | `$1B` | LIT16 `$D024` |

Nine conditional/unconditional branch operands in the main thread
resolve to named token boundaries:
`$3D02`, `$3D05`, `$3D25`, `$3D62`, `$3D67`, and `$3D6B`.

### Twelve memory-address words

The $26D2–$270C region contains twelve compact colon words, each
`RST $08; LIT16 address; EXIT`. The addresses are:

| Entry | Literal | Entry | Literal |
| --- | --- | --- | --- |
| `$26D2` | `$D299` | `$26D7` | `$D2E5` |
| `$26DC` | `$D331` | `$26E1` | `$D37D` |
| `$26E6` | `$D18D` | `$26EB` | `$D18E` |
| `$26F0` | `$D18F` | `$26F5` | `$D190` |
| `$26FA` | `$D1A1` | `$26FF` | `$D1A2` |
| `$2704` | `$D19F` | `$2709` | `$D1A0` |

Their first 59 bytes are source-typed and checked against the original
ROM. The final EXIT byte at `$270D` is retained with the following
colon-entry boundary.

### Game-control programs

The contiguous high-level program group at
`$2AE2–$2F66` contains ten decoded colon definitions.
All of their byte-token cells, 16-bit literal operands, and
branch destinations are represented by assembly directives.
The source includes an original `$8A` byte at `$2C4D`
between two definitions, preserved as
`TERSE_INTERWORD_2C4D`.

One example of the correct source representation:

```asm
TERSE_COLON_2D7D:
    RST $08
    DB $2A           ; native word selected by vector $2A
    DB $0E           ; LIT8
    DB $0C           ; inline byte operand
    ...
    DB $03           ; zero-conditional branch
    DW TERSE_THREAD_2DDD
```

The original disassembly showed the branch operand bytes
`$DD,$2D` as the Z80 instruction `DEC IXL`. They are
**TERSE thread data**, not a Z80 IX-register operation.

Likewise the original bytes `$28,$7F` at `$2921`
were shown as `JR Z,$29A2`; the maintained source now preserves
these two original bytes explicitly while their encompassing stream
is being recovered.

## Native-source byte checks

These decoded regions were regenerated from the authoritative
four-ROM arcade set. Their reconstructed bytes were compared with
the original source ROM at the original CPU addresses:

| Decoded span | Compared bytes | Details |
| --- | ---: | --- |
| `$1311–$13C3` | 179 | Colon stream and ten-byte font padding |
| `$1F92–$1FC8` | 55 | Sound-control stream and following native setup |
| `$26D2–$270C` | 59 | Twelve compact address-literal definitions |
| `$270D–$2AE0` | 980 | 29 colon words and original data spans |
| `$2AE1–$2D7B` | 667 | Seven colon programs, including interword byte |
| `$2D7C–$2ED4` | 345 | Two more game-control colon programs |
| `$2ED5–$2F66` | 146 | Final decoded game-control colon |
| `$307C–$3096` | 27 | Screen helpers and text-prefix byte |
| `$3CDA–$3DE9` | 272 | Main game/control thread and boundary bytes |

These are byte-range checks of the recovered ROM data.
The full original-source assembly test uses zmac v1.3 and
compares all four generated ROM SHA-1 values in `build.sh`
and `build.bat`.

## Remaining program recovery

Decode further `RST $08` definitions in the middle ROM
(`$21xx–$2Axx`), reconstruct their literal operands and
branch targets, and attach descriptive names based on game-state
and hardware effects. Resolve the native words that compiled
threads call through the remaining vector slots.
