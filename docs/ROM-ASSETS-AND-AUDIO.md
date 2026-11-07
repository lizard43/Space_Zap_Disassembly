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
    .DB $3C ; ..####..
    .DB $7E ; .######.
    .DB $66 ; .##..##.
    .DB $66 ; .##..##.
    .DB $66 ; .##..##.
    .DB $66 ; .##..##.
    .DB $66 ; .##..##.
    .DB $66 ; .##..##.
    .DB $7E ; .######.
    .DB $3C ; ..####..
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
    .DB "SPACE ZAP",0
SPACE_ZAP_DEVELOPER:
    .DB "DNA",0
SPACE_ZAP_ROM_DATE:
    .DB $08,$19,$80 ; August 19, 1980
```
