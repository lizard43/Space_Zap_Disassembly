# Space Zap

**Space Zap** (Midway, 1980) is a byte-exact Z80 arcade ROM reconstruction and reverse-engineering project, with a recovered **indexed-token TERSE-family interpreter** and native Z80 game services.

![Space Zap arcade marquee](images/space-zap-34209-marquee.jpg)

## Introduction and history

In Space Zap, the player operates a four-direction laser installation at the center of the playfield, repelling enemies from above, below, left and right. Midway published the arcade game in **October 1980** on Astrocade-family hardware; its original board uses a Z80 CPU and a dedicated video/pattern system. The game has been associated with **Dave Nutting Associates** and a licensing arrangement with Game-A-Tron. The exact contribution of each organization, and the name of the original arcade programmer, need independent primary-source verification.

The Astrocade home cartridge **Space Fortress** (1981), programmed by Bob Ogdon, is a distinct 4 KB adaptation; it is **not** the arcade program ROM. Its TERSE status has not been established, and its released 4 KB image does not exhibit the arcade interpreter's characteristic `JP (IY)` continuation. Avoid conflating its code and ownership with this reconstruction.

![Space Zap upright](images/space-zap-00993-01-front.jpg)

| Area | Current recovered evidence |
| --- | --- |
| [ROM identity and builds](#rom-organization) | Four official 4 KB MAME ROMs; supplied SHA-1 baseline in both Linux and Windows build scripts |
| [TERSE architecture](#terse-execution-architecture) | Colon entry, 8-bit indexed NEXT, EXIT, LIT16, LIT8, BC/IX/SP/IY ABI; vector table at `$3DEA` |
| [Graphics](#graphics-and-object-data) | Existing labeled sprite records with 2bpp inline plots and object sequencing |
| [Memory map](#memory-map) | Controlled SVG of the 64 KB address space with confirmed ROM boundaries and provisional hardware regions |
| [RE status](#reverse-engineering-status) | Early native primitives labeled; remaining mixed code/data, raw numeric references and thread operands require substantial recovery |

## Project layout

| Path | Contents |
| --- | --- |
| `Space_Zap_Disassembly.asm` | Historical Z80 assembly/disassembly, structured graphic data, initial TERSE labels; 256 typed DW vector slots and ROM-tail data |
| `build.sh` | Linux zmac build, four ROM split, MAME ZIP and SHA-1 verification |
| `build.bat` | Windows zmac build and the same ROM checksum verification |
| `tools/zmac.exe` | Bundled Windows assembler |
| `roms/original/spacezap.zip` | Controlled original arcade ROM archive |
| `roms/0662.01`–`roms/0665.xx` | Individual MAME-named 4 KB ROMs |
| `roms/spacezap.zip` | MAME archive |
| `docs/TERSE-ARCHITECTURE.md` | Detailed TERSE ABI, indexed/direct comparison, 688-byte reference and remaining RE work |
| `docs/Space_Zap_Parts_and_Operating_Manual_(Oct_1980).pdf` | Original hardware service and operating manual |
| `images/spacezap-*.svg` | Controlled and editable TERSE/memory-map diagrams |
| `images/space-zap-*.jpg` | Cabinet, marquee and archival photographs |

## Build

Both build scripts deliberately follow the **Sea Wolf II** flow. They invoke
the original **zmac** assembler against the actual disassembly; they do not
generate ROM bytes from a JavaScript/Python substitute or play an unchanged
reference ZIP in place of modified source.

Linux Mint / Linux:

```sh
./build.sh
```

The script prefers `tools/zmac`, then the explicitly selected `ZMAC`
environment variable, and then `zmac` on PATH. For a specific installed
assembler:

```sh
ZMAC=/path/to/zmac ./build.sh
```

Windows 10/11:

```bat
build.bat
```

The Windows script uses the existing `tools/zmac.exe` and built-in PowerShell
for the four equal-size ROM slices, archive creation and hashing.

The build proceeds in four visible stages:

1. Assemble `Space_Zap_Disassembly.asm` using zmac and produce a combined `zout/Space_Zap_Disassembly.cim` plus listing.
2. Split the assembled program into four 4 KB original socket filenames.
3. Package `roms/spacezap.zip` for MAME.
4. Calculate SHA-1 for every generated ROM; **fail the build** on any mismatch.

The repository's original `build.sh` already used zmac's
`--oo cim,lst` format and the `zout/` output directory. This is
retained instead of inventing a different assembler pipeline.

**Verification status:** The expected ROM hashes have been independently checked
against the supplied arcade ROM archive. The scripts and current assembly
need to be executed on a host with zmac to establish that the **source
actually reproduces** those hashes after this documentation/label pass.
A source-level build claim is not made until that test passes.

### Run in MAME

```sh
mame -rompath roms -verifyroms spacezap
mame -rompath roms -window -skip_gameinfo spacezap
```

## ROM organization

| Socket | CPU range | Bytes | CRC32 | SHA-1 |
| --- | --- | ---: | --- | --- |
| `0662.01` | `$0000–$0FFF` | 4,096 | `a92de312` | `784ac67c75c7c101f97ebfd39b2b3f7bf7fa470a` |
| `0663.xx` | `$1000–$1FFF` | 4,096 | `4836ebf1` | `ad0e8c34a209c827c1336f0250cc61fee667fb03` |
| `0664.xx` | `$2000–$2FFF` | 4,096 | `d8193a80` | `72151e773562da62acd2c1d9638711711cbc13a3` |
| `0665.xx` | `$3000–$3FFF` | 4,096 | `3784228d` | `5aabd720a106158a892368c4920d9cd0f5235e34` |

The four ROMs contain one contiguous 16 KB program. A separately packaged
archive whose inner members are named `spacezap.x1`–`spacezap.x4`
contains identical bytes, but the socket filenames above are MAME's
official ROM names.

## Memory map

![Space Zap Z80 CPU memory map](images/spacezap-memory-map.svg)

This is a 64 KB **working map** in the same visual spirit as the Sea Wolf II
reference. The four ROM address ranges and TERSE startup/stack addresses
are evidence-backed. The hardware mapping outside the ROM is currently
marked provisional where it still needs direct verification against the
Space Zap schematic and MAME's decode.

Major ROM landmarks:

| Address | Function |
| --- | --- |
| `$0008` | TERSE colon entry |
| `$0015` | Cold initialization |
| `$0035` | Indexed-token TERSE NEXT |
| `$0044` | TERSE EXIT |
| `$0050` | 16-bit inline literal |
| `$0059` | 8-bit inline literal |
| `$3CDC` | Initial compiled token stream |
| `$3DEA` | Start of the 256-entry native handler vector table |
| `$3FEF` | `SPACE ZAP` title / `DNA` identification tail |

## TERSE execution architecture

![Space Zap TERSE token execution](images/spacezap-terse-execution.svg)

The game initializes `BC=$3CDC`, `IX=$D800`, `SP=$D780`,
and `IY=$0035`. At `$0035`, the interpreter consumes **one byte from
the BC-addressed stream**; this token indexes a 256-entry ROM table of
native Z80 routine addresses at `$3DEA`. The selected routine executes
and normally returns through `JP (IY)`.

Its `RST $08` colon entry saves the previous BC on IX and makes the
inline address the new token-stream pointer. EXIT restores BC from IX.
The native stack and data operations use SP, while IX supplies a distinct
thread/control stack. This is a coherent **TERSE-family interpreter**,
not merely a few incidental matching Z80 opcodes.

![Indexed-token and direct-threaded TERSE compared](images/spacezap-threading-comparison.svg)

The Coloring Book and Cosmic Raiders prototypes use a related ABI but
fetch **two-byte native addresses** directly through BC rather than
looking up one-byte token IDs. Both systems are Forth-like, but the
correct implementation descriptions are *indexed-token TERSE* for
Space Zap and *direct-threaded TERSE* for the cartridge prototypes.

The saved Space Zap 688-byte signature window is **not** proven to be a
relocated copy of their shared 688-byte cartridge runtime. It covers
different routines and contains a different NEXT mechanism. See
[TERSE architecture and functional comparison](docs/TERSE-ARCHITECTURE.md)
for primitive-by-primitive comparisons, evidence levels and open
compiler/ancestry questions.

## Graphics and object data

The source already includes named object records, 2bpp pixel rows
rendered as inline graphic patterns, animation frame sequences and
shared sprite drawing routines. Representative objects include the
laser bases, alien ship in horizontal and vertical orientations,
space mine growth phases, and attack satellite frames.

That existing typed sprite data should be preserved and extended.
The broader hard-RE task is to replace **actual undifferentiated game
data mis-disassembled as Z80 opcodes** with bounded, byte-exact,
labeled records. Raw DB is not itself a defect when it correctly
represents pixels, byte tables, strings or encoded TERSE operands.

## Reverse-engineering status

This repository began as a largely bare disassembly. The current pass
labels the entry and key TERSE primitives and provides the architectural
baseline and reproducible build scripts. This is **not yet** a
Sea Wolf II-level complete hard RE: reachable native words,
token dictionaries, all branch/inline operands, unused data,
interrupts, sound, RAM ownership and hardware control paths still
need exhaustive recovery and testing. The 256 vector entries are now typed\nin the assembly, while their native-word meanings still require tracing.

The next substantial work belongs in the original Z80 source, with
symbolic calls/data references, meaningful ROM-word names and typed
threads; verify every change against all four original ROM SHA-1 values.
Do not replace the original TERSE compiler/runtime with an
independent language simulation.

## References

- [Sea Wolf II RE repository](https://github.com/astrocadester/SeaWolfII) — project structure, build format and RE documentation style.
- [TERSE signature scanning](https://github.com/lizard43/TERSE/blob/main/TERSE_Signature_Scanning.md) — earlier independent Space Zap positive finding.
- [Space Zap arcade reference](https://www.arcade-museum.com/game_detail.php?game_id=9703) — historical cabinet context.
- Hardware service/parts manual and cabinet imagery are controlled in this repository's `docs/` and `images/`.
