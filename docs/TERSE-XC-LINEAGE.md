# Space Zap and the original DNA cross-compiler lineage

**Research revision: 2026-11-07.** This comparison uses **original DNA XC code and surviving archival fragments**. The `astrocade-console` compiler created during our current WB project is **not historical DNA software** and is **excluded** from the historical analysis.

## Conclusion

**Space Zap (1980) contains an 8-bit indexed-token TERSE runtime.** Its dispatcher reads one byte from BC and selects a native handler using a table of 16-bit pointers at `$3DEA`. This is the same broad *byte-token compilation strategy* demonstrated in historical DNA cross-compiler material, most completely in the **original 1982 `FS.XC`**. The surviving **1979 XC fragments** are chronologically more relevant to Space Zap and already contain byte-token compiler definitions, though that archived 1979 XC is incomplete.

**Educated hypothesis:** Space Zap was built with a DNA byte-token TERSE compiler related to the lineage of the preserved 1979 fragments and original 1982 XC. This is an inference about compiler design, **not an identification of the exact Space Zap XC binary**. The 1982 XC cannot literally have compiled a game released in 1980.

![Indexed-token versus direct-threaded runtime comparison](../images/spacezap-threading-comparison.svg)

## Source pedigree: separate original evidence from current WB adaptations

| Evidence | Provenance | Significance |
| --- | --- | --- |
| [Original 1982 `FS.XC` disassembled word listing](https://github.com/lizard43/dnaTERSE-WB/blob/main/research/xc-recovery-2026/fs-xc-1982-words.txt) | Recovered original DNA compiler | Explicit native byte-token allocation, word lookup, table emission and XC finalization |
| [Original 1982 `FS.XC` Z80 source](https://github.com/lizard43/dnaTERSE-WB/blob/main/src/xc-1982/fs-xc-1982.asm) | Disassembled historical compiler binary, not a replacement | Independent original binary evidence for the compiler mechanism |
| [Original 1979 upper-XC fragment audit](https://github.com/lizard43/dnaTERSE-WB/blob/main/docs/GORF-XC-ALLOCATION.md) | Partial original 1979 XC saved in spare disk block | Establishes survival and limits of early compiler artifacts |
| [1979 XC recovered source and provenance](https://github.com/lizard43/dnaTERSE-WB/blob/main/src/xc-1979/README.md) | Original upper source reconstructed alongside **explicit later adaptations** | `bytarray`, `newbyt`, `byt,` mechanisms partially preserved; *not* an intact original complete XC |
| [Extra Bases XC runtime configuration](https://github.com/lizard43/dnaTERSE-WB/blob/main/src/project-tools/extra-bases/runtime.terse) | Modern WB reconstruction of Extra Bases target bindings | Operational comparison to another **historical game ROM using byte tokens**; this configuration file is not claimed original |
| [Space Zap ROM vectors](TERSE-TOKEN-VECTORS.md) | Original Space Zap arcade ROM | Actual 256-slot indexed native-handler table and byte-token NEXT |

## Original 1982 XC: precise mechanisms

The original `MSGPATLD` `FS.XC` image, separately archived and reconstructed in WB, contains the following historical dictionary words. The addresses below are **XC host execution tokens**, not Space Zap ROM addresses.

| Original word | XC address | Behavior observed in the disassembly |
| --- | --- | --- |
| `BYTE-TERSE` | `$82D3` | Increments the `byterse` counter used by byte compilation |
| `bytarray` | `$82F9` | Array storing the native target addresses assigned token IDs |
| `newbyt` | `$8439` | Registers a target execution address and emits its newly assigned one-byte token |
| `byt,` | `$8475` | Finds or creates a byte-token index, or emits a full word when byte mode is disabled |
| `XCEND` | `$8669` | Appends the address vector and patches the target's vector-table location |
| `interpret` | `$8B49` | Resolves target words and compiles them through `xccalc byt,` |

The relevant original XC definitions, expressed as *abbreviated summaries* rather than a purported exact source transcription:

```forth
: newbyt   ( target-XT -- )
  ... bytarray ! ... B, byterse 1+! ;

: byt,     ( target-XT -- )
  byterse @ IF
    ... search bytarray ...
    ... B, OR newbyt ...
  ELSE
    ,
  THEN ;

: XCEND
  byterse @ IF
    ... patch .bytbase. ...
    ... emit 16-bit bytarray entries ...
  THEN
  ... patch .topdef. ... FLUSH ;
```

The **original 1982 compiler supports both byte-indexed and wider emission internally**. This point is proven by the original `byt,` implementation and does **not** rely on the current `astrocade-console` XC. The compiler's ability to emit full words does not establish that the Astrocade home cartridge games used this exact historical compiler.

## What survived from 1979

The archived 1979 Gorf system retains XC-looking **upper-memory fragments** in a saved spare block. Recovered definitions include `bytarray`, `newbyt` and `byt,`. Their alignment and some original byte bodies were verified by native recovery work, but the lower referenced code bodies are missing, and the saved `XCEND` tail is incomplete. The original 1979 saved system is **not an operational complete XC**.

The maintained `src/xc-1979/recovered-core.terse` reproduces the surviving upper definitions; other files in that directory supply 1982-derived or modern host-compatibility adaptations. Treat only independently verified original fragments as original evidence.

Thus the 1979 material provides the key **chronological bridge** to Space Zap's 1980 date. The original 1982 saved XC provides the complete later **mechanistic comparison**. Neither establishes Space Zap's exact build environment.

## Compare the original target ROMs

Space Zap's native NEXT at `$0035`:

```z80
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

One byte in the program stream chooses a two-byte target from the vector table. That table occupies `$3DEA–$3FE9`; the original source now represents it as **256 typed `DW` cells**.

Extra Bases is an independent game-level byte-token example, whereas Coloring Book and Cosmic Raiders illustrate **16-bit native-address direct threading** in their released prototype ROMs. These are historical runtime observations. They are **not evidence of any modern XC's historical use**.

Nine bounded Space Zap/cartridge primitive routines contain **70 matching machine-code bytes**, as documented in [the architecture comparison](TERSE-ARCHITECTURE.md). This strengthens the case for a common native **runtime library** despite differing dispatch encodings. It does not prove the same historical XC compiled both games.

## The two 688-byte windows

- Space Zap's stored 688-byte signature is its **first** `$0000–$02AF` window.
- Coloring Book/Cosmic Raiders share an exact **688-byte** direct-threaded runtime region at `$2050–$22FF`.
- Matching lengths do **not** make the blocks identical or merely relocated. Their NEXT implementations interpret different execution cells.
- The exact matched primitive bodies are meaningful evidence of shared TERSE code; the arbitrary equal-size windows are not.

## Recommended historical conclusion

> The Space Zap ROM preserves a compact, one-byte indexed TERSE interpreter. Surviving partial 1979 DNA XC material contains related byte-token allocation definitions, while the original 1982 FS.XC provides a later complete example of the byte-token compiler and native-handler table mechanism. Space Zap most likely belongs to this historical DNA byte-token XC lineage, although the specific compiler version used to build the 1980 game remains unidentified. Separately, its native primitive routines share substantial exact code with later Astrocade cartridge TERSE kernels.

## Next proof steps

1. Recover the used token program and operand contracts from Space Zap's original ROM, beginning at `$3CDC`.
2. Compare token table ordering, words and instruction bodies with original Extra Bases and other arcade games, accounting for relocation.
3. Search contemporary Space Zap source disks, loader listings or original compiler saves for `BYTE-TERSE`, `bytarray`, `byt,` and `XCEND`.
4. Perform a native zmac build and compare all four original ROM SHA-1 hashes before claiming a fully reconstructed source build.

**Original DNA software first:** The original saved compiler, modern compatible XC recovery, and current console XC are different provenance classes. No modern source can be retroactively treated as a historical compiler artifact.
