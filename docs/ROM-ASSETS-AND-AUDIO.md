# Space Zap ROM assets and audio

## Character font

**`$13C4–$1535`: 37 glyphs × 10 bytes = 370 bytes.** Each glyph is 8 pixels wide and 10 rows tall. A set bit represents a lit pixel.

| Glyphs | Address range | Source labels |
| --- | --- | --- |
| `0–9` | `$13C4–$1427` | `FONT_DIGIT_0` through `FONT_DIGIT_9` |
| Symbol | `$1428–$1431` | `FONT_SYMBOL_AT` |
| `A–Z` | `$1432–$1535` | `FONT_LETTER_A` through `FONT_LETTER_Z` |

Every original font byte is now an explicit `.DB` with its **8-pixel inline graphic plot** in `Space_Zap_Disassembly.asm`. For example, glyph `0`:

```asm
FONT_DIGIT_0:
    DB $3C ; ..####..
    DB $7E ; .######.
    DB $66 ; .##..##.
    DB $66 ; .##..##.
    DB $66 ; .##..##.
    DB $66 ; .##..##.
    DB $66 ; .##..##.
    DB $66 ; .##..##.
    DB $7E ; .######.
    DB $3C ; ..####..
```

## On-screen strings

The following records at `$3097–$327B` have been converted from misleading Z80 instruction listings to **named ROM byte strings**. Source bytes and lengths are unchanged.

| CPU address | ASM label | Original display text |
| --- | --- | --- |
| `$3097` | `TEXT_MIDWAY_COPYRIGHT` | `@ 1980 MIDWAY MFG` |
| `$30A9` | `TEXT_SPACE_TITLE` | `SPACE` |
| `$30AF` | `TEXT_ZAP_TITLE` | `ZAP` |
| `$30ED` | `TEXT_INSERT_COINS` | `INSERT COINS` |
| `$30FA` | `TEXT_ADD_COINS` | `ADD COINS` |
| `$3104` | `TEXT_FOR_TWO_PLAYERS` | `FOR 2 PLAYER` |
| `$3114` | `TEXT_PUSH_ONE_PLAYER` | `PUSH 1 PLAYER TO PLAY` |
| `$312A` | `TEXT_DEPOSIT` | `DEPOSIT` |
| `$3132` | `TEXT_ADDITIONAL_COIN` | `ADDITIONAL COIN` |
| `$3198` | `TEXT_HI_SCORE` | `HI SCORE` |
| `$31A1` | `TEXT_PLAYER_1` | `PLAYER 1` |
| `$31AA` | `TEXT_PLAYER_2` | `PLAYER 2` |
| `$31B3` | `TEXT_CREDITS` | `CREDITS` |
| `$31BB` | `TEXT_BASES` | `BASES` |
| `$31C1` | `TEXT_BONUS_BASE` | `BONUS BASE` |
| `$3233` | `TEXT_NEW_HIGH_SCORE` | ` N E W  H I G H ` |
| `$3244` | `TEXT_GAME_OVER` | ` GAME OVER ` |
| `$324F` | separator byte | `$16` |
| `$3250` | `TEXT_PUSH_ONE_OR_TWO` | `PUSH 1 OR 2 PLAYER FOR` |
| `$3267` | `TEXT_FIRST_PLAYER` | `1ST PLAYER` |
| `$3272` | `TEXT_SECOND_PLAYER` | `2ND PLAYER` |

Title components are separated by an original `$03` byte before `ZAP`. The separator preceding `GAME OVER` is `$0B`; the following separator at `$324F` is `$16`. Display-text records are not terminated or padded by the reconstruction.

## Bitmap sprites and animation frames

The maintained source already has packed **2bpp** object records: hotspot offsets, width, height and pixel rows. Object sets include:

- Alien ship (horizontal and vertical), destruction frames and sequence links.
- Laser base body, turret orientation, firing frames and destruction phases.
- Space mine phases and attack satellite frames.

The sprite decoder reads the record header and passes packed pixels to `MAGIC_DRAW_BITMAP`. Sprite-row comments in the assembly show 2bpp color indexes `0–3`. The 8×10 font above is a separate **1bpp** representation.


## Original cabinet hardware and diagnostics

The [October 1980 Space Zap service manual](Space_Zap_Parts_and_Operating_Manual_(Oct_1980).pdf) is the primary source for cabinet behavior. Its *RAM-ROM Test* pages 4–5 (PDF pages 6–7) specify a service switch on the audio-amplifier assembly, separate screen-RAM, static-RAM and ROM checks, and a modified test on power-up or door slam. An unsuccessful RAM test can prevent normal gameplay.

The ASM now labels the corresponding native screen-RAM test at `$2F67` and the following static-RAM test as `NATIVE_SCREEN_RAM_TEST` and `NATIVE_STATIC_RAM_TEST`. The code writes/checks `$4000–$7FFF` screen memory and `$D000–$D7FF` static RAM, respectively. The screen test writes color-table registers on mismatch; the static test uses `OUT ($5B),$A5` before protected-memory writes. These are **observed code effects**, consistent with the manual's visible error indications. The full ROM diagnostic call chain remains to be traced.

The accompanying `SpaceZap-pinouts.txt` identifies game-board P1 pins 1–5 as player 2 directions/fire and pins 8–12 as player 1 directions/fire. Game-board P2 carries coin 1/2 (pins 1/2), test (3), door slam (4), one/two-player select (5/6), audio (8/9), coin meters (10/12), and video (15/16). These are cabinet connector assignments, **not yet proven Z80 input-port bits**. The source should use semantic bit labels only after tracing the original CPU/game-board decoding.

Original schematics are in the same manual: CPU board on printed pages 42 and 44 (PDF pages 44 and 46), pattern board on printed page 46 (PDF page 48), plus cabinet wiring on printed pages 34–36 (PDF pages 36–38). Do not infer that an unmapped emulator port is meaningless on the original board.

## Recovered Space Zap I/O operations

The ASM defines hardware port constants near the top of the source and uses them at direct `IN`/`OUT` call sites. The same numerical port can have different meanings when read versus written (for example, `$08` selects video mode on write but returns video intercept feedback on read; `$10–$12` are custom I/O input ports on read and sound registers on write).

| Port(s) | Operation |
| --- | --- |
| `$00–$07` | Video color-table outputs (named at directly observed `$00` and `$04` write sites) |
| `$08` | Write video mode; read intercept feedback |
| `$0C` | Magic function-generator controls (shift, expand, XOR/OR etc.) |
| `$0D–$0F` | Interrupt feedback, enable/mode, scanline |
| `$10–$17` | Sound frequency, vibrato and volume registers on write |
| `$19` | Pixel expansion colors |
| `$5B` with high I/O address byte `$A5` | Enable protected RAM writes; `OUT ($5B),A` is not sufficient evidence without inspecting the I/O address high byte |
| `$78–$7E` | Pattern-board source, mode, skip, destination, width, height/start |
| `$F8,$FA,$FB,$FF` | Written during cold start; hardware function not established from the Space Zap machine's currently mapped MAME I/O handlers |

The native source distinguishes **confirmed board register semantics** from unresolved startup addresses. The original cabinet schematics take precedence over MAME for interpreting physical I/O decoding. The `$F8/$FA/$FB/$FF` startup writes need a direct address-decode trace on the game/CPU boards before functional names are assigned.

## Astrocade sound hardware and native routines

Space Zap uses the Astrocade custom I/O sound chip at I/O ports `$10–$17`. Its eight registers are:

| Port | Sound function |
| --- | --- |
| `$10` | Master oscillator frequency |
| `$11` | Tone A frequency |
| `$12` | Tone B frequency |
| `$13` | Tone C frequency |
| `$14` | Vibrato |
| `$15` | Noise/volume control |
| `$16` | Tone A/B volumes |
| `$17` | Noise volume |

The source now identifies these native operations:

| Address | ASM routine | Operation |
| --- | --- | --- |
| `$1FC9` | `AUDIO_CLEAR_SOUND_REGISTERS` | Writes zero to all eight registers `$17–$10` |
| `$2034` | `AUDIO_MASTER_OSCILLATOR_STEP` | Updates a pitch accumulator and writes `$10` |
| `$20B5` | `AUDIO_NOISE_VOLUME_STEP` | Updates the noise envelope and writes `$17` |
| `$213E` | `AUDIO_WRITE_REGISTER_INDEXED` | Converts index B to I/O port `$18-B`, writes data C |

The indexed register writer has five now-symbolic `CALL AUDIO_WRITE_REGISTER_INDEXED` sites in the ASM. The oscillator and noise routines operate on `IY`-relative sound-effect state fields.

The chip supports three tones plus noise, vibrato, and per-channel volume controls. The ROM's effect routines update those hardware parameters; no separate sampled-audio ROM was found among the four 4 KB program sockets.

**Hardware reference:** MAME `src/devices/sound/astrocde.cpp` (Astrocade custom I/O chip register map).

## ROM identification

The final ROM tail at `$3FEF–$3FFF` is represented by `SPACE_ZAP_TITLE`, `SPACE_ZAP_DEVELOPER` and `SPACE_ZAP_ROM_DATE`:

```asm
SPACE_ZAP_TITLE:
    DB "SPACE ZAP",0
SPACE_ZAP_DEVELOPER:
    DB "DNA",0
SPACE_ZAP_ROM_DATE:
    DB $08,$19,$80 ; August 19, 1980
```

## Other original ROM structures

The ROM also contains a typed eight-address RAM dispatch table at `$0336–$0345`; its native dispatcher begins at `$0346`. See the [architecture](TERSE-ARCHITECTURE.md) for the routine inventory and [compiled programs](TERSE-COMPILED-PROGRAMS.md) for the bytecode callers.

**Space Fortress (1981)** is a distinct 4 KB Astrocade cartridge adaptation. The released cartridge has not been established as TERSE; it is not part of this 16 KB Space Zap arcade ROM reconstruction.
