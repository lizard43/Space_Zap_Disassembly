# Space Zap TERSE word dictionary

A programmer's dictionary of **recovered** TERSE execution words in the original 1980 Space Zap ROM. This is organized like a Forth dictionary: word name, purpose, stack effect, example, execution token and native implementation. Examples illustrate each word's stack operation.

**Notation:** `( before -- after )` describes the data stack, bottom-to-top (topmost at right). `R:` denotes the IX control stack. Cells are 16-bit unless noted. Tokens are one byte; `LIT8`, `LIT16`, and branches consume extra inline data. Native routines resume through `JP (IY)` unless they transfer control elsewhere.

See [architecture](TERSE-ARCHITECTURE.md), [complete indexed-token vector inventory](TERSE-TOKEN-VECTORS.md), and [compiled TERSE programs](TERSE-COMPILED-PROGRAMS.md).

## DNA TERSE vocabulary

Recovered words use the **original DNA TERSE names** when the native implementation matches the DNA Standard Glossary. `@`, `B@`, `!`, `B!`, `+`, `-`, `1+`, `1-`, `0`, `1`, `ZERO`, `AND`, `OR`, `I`, `INP`, `OUTP`, `ROT`, `PICK`, `MINUS`, and the other matched words below are their TERSE names. Keep Z80 assembly labels valid for zmac without substituting those labels for TERSE vocabulary. Names are unresolved **only when their implementation or word identity remains undetermined**. The `0` word pushes zero; `ZERO` clears a memory word.

## Quick reference

**Word** is the original TERSE vocabulary entry; **Description** gives its meaning; **Stack effect** shows values before and after execution (top of stack at right). Select a word for its token, native ROM address, example and implementation.

| Word | Description | Stack effect |
| :--- | :--- | :--- |
| [`EXIT`](#exit) | Return from a colon definition | `( R: caller-ip -- )` |
| [`LIT`](#lit-16-bit-inline-literal) | Push inline 16-bit literal | `( -- n )` |
| [`LIT8`](#lit8) | Push inline unsigned byte | `( -- u )` |
| [`0`](#token-0b) | Push zero | `( -- 0 )` |
| [`1`](#token-09) | Push one | `( -- 1 )` |
| [`DUP`](#dup) | Duplicate top stack value | `( n -- n n )` |
| [`2DUP`](#2dup) | Duplicate top two stack values | `( a b -- a b a b )` |
| [`DROP`](#drop) | Discard top stack value | `( n -- )` |
| [`SWAP`](#swap) | Exchange top two stack values | `( a b -- b a )` |
| [`@`](#token-0c) | Fetch 16-bit word from memory | `( addr -- n )` |
| [`B@`](#token-25) | Fetch byte from memory | `( addr -- u )` |
| [`!`](#token-10) | Store 16-bit word in memory | `( n addr -- )` |
| [`B!`](#token-08) | Store byte in memory | `( n addr -- )` |
| [`ZERO`](#zero) | Clear 16-bit memory word | `( addr -- )` |
| [`+`](#token-0f) | Add two values | `( a b -- a+b )` |
| [`-`](#token-3f) | Subtract two values | `( a b -- a-b )` |
| [`1-`](#token-15) | Subtract one | `( n -- n-1 )` |
| [`1+`](#token-14) | Add one | `( n -- n+1 )` |
| [`ARITH_SHIFT_RIGHT`](#arith_shift_right) | Arithmetic shift right one bit | `( signed-n -- signed-n>>1 )` |
| [`AND`](#and) | Bitwise AND | `( a b -- a&b )` |
| [`OR`](#or) | Bitwise OR | `( a b -- a|b )` |
| [`I`](#i) | Read current loop index | `( -- index )` |
| [`OUTP`](#outp) | Write byte to I/O port | `( value port -- )` |
| [`INP`](#inp) | Read byte from I/O port | `( port -- byte )` |
| [`1-B!`](#token-43) | Decrement memory byte | `( addr -- )` |
| [`=`](#token-44) | Compare for equality | `( a b -- flag )` |
| [`BMOVE`](#bmove) | Copy bytes in memory | `( src dest count -- )` |
| [`ROT`](#rot) | Rotate top three stack values | `( a b c -- b c a )` |
| [`PICK`](#pick) | Copy indexed stack value | `( index -- value )` |
| [`MINUS`](#minus) | Negate signed value | `( n -- -n )` |
| [`U>=`](#token-c2) | Unsigned greater-than-or-equal comparison | `( a b -- flag )` |
| [`INDEXED_DISPATCH`](#indexed_dispatch) | Select native handler by index | `( index -- )` |
| [`COMPARE_BRANCH_NE`](#compare_branch_ne) | Compare and branch when unequal | `( a b -- )` equal; `( a b -- a )` unequal |
| [`ADD_INLINE16`](#add_inline16) | Add inline 16-bit offset | `( n -- n+offset )` |
| [`BRANCH_ABSOLUTE`](#branch_absolute) | Jump to inline thread address | `( -- )` |
| [`ZERO_BRANCH`](#zero_branch) | Branch if value is zero | `( flag -- )` |

## Recovered words

<a id="token-43"></a>

### 1-B! — token $43

**Token:** `$43` · **Native:** `$00E6` · **Stack:** `( addr -- )`

Decrement the byte stored at addr, wrapping modulo 256.

**Native Z80:**

```z80
    POP HL
    DEC (HL)
    JP (IY)
```

<a id="token-44"></a>

### = — token $44

**Token:** `$44` · **Native:** `$00EE` · **Stack:** `( a b -- flag )`

Compare the top two 16-bit cells by subtraction. Push 1 if equal; otherwise push 0. The native branch at `$00F6` skips the `INC HL` instruction on inequality and enters the shared push/continuation tail at `$00FA`.

```z80
    POP DE
    POP HL
    XOR A
    SBC HL,DE
    LD HL,$0000
    JP NZ,$00FA
    INC HL
    PUSH HL
    JP (IY)
```

### MINUS

**Token:** `$82` · **Native:** `$00CD` · **Stack:** `( n -- -n )`

Pop a cell and compute `0-n` modulo 65536 through the existing subtraction body at `$00C7`.

```z80
    POP DE
    LD HL,$0000
    JP $00C7
```

<a id="token-c2"></a>

### U>= — token $C2

**Token:** `$C2` · **Native:** `$00FD` · **Stack:** `( a b -- flag )`

Return 1 if unsigned `a>=b`, otherwise 0. The `SBC HL,DE` carry flag identifies `a<b`.

```z80
    POP DE
    POP HL
    XOR A
    SBC HL,DE
    LD HL,$0000
    JP C,$0109
    INC HL
    PUSH HL
    JP (IY)
```

### 1+B! (native helper, not indexed token $44)

**Native entry:** `$00EA` · **Stack:** `( addr -- )`.

Increment the byte at the given address modulo 256. The previously published token binding was incorrect: token `$44` selects `$00EE` (EQUAL), four bytes after this helper.


### BMOVE

**Token:** `$16` · **Native:** `$015F` · **Stack:** `( src dest count -- )`

Copy count bytes from src to dest using Z80 LDIR; zero count skips the copy.

**Native Z80:**

```z80
    EXX
    POP BC
    POP DE
    POP HL
    LD A,B
    OR C
    JP Z,$016A
    LDIR
    EXX
    JP (IY)
```

### ROT

**Token:** `$13` · **Native:** `$01E3` · **Stack:** `( a b c -- b c a )`

Rotate the three top stack cells with the deepest moved to the top.

**Native Z80:**

```z80
    POP DE
    POP HL
    EX (SP),HL
    PUSH DE
    PUSH HL
    JP (IY)
```

### PICK

**Token:** `$45` · **Native:** `$01EA` · **Stack:** `( index -- value )`

Fetch a 1-based indexed cell from the remaining data stack, leaving the indexed value on top.

**Native Z80:**

```z80
    POP HL
    DEC HL
    ADD HL,HL
    ADD HL,SP
    LD E,(HL)
    INC HL
    LD D,(HL)
    PUSH DE
    JP (IY)
```


### INDEXED_DISPATCH

**Token:** `$3D` · **Native:** `$023E` · **Stack:** `( index -- )`.

Reads an inline little-endian 16-bit end/default continuation address, then pops a zero-based index. The table starts immediately after the end-address operand and consists of 16-bit native execution addresses. Native code doubles the index, adds it to the table start, and compares the indexed pointer to the end address. If the table pointer is before the end, it loads the 16-bit target and executes `JP (HL)`; otherwise it resumes NEXT with BC set to the end address. These are native execution addresses, not one-byte TERSE tokens.

Seven recovered dispatch sites have four entries each: `$2779`, `$27C7`, `$27D8`, `$27E4`, `$285A`, `$2866`, and `$287C`.

Example: the recovered colon word at `$2866` reads RAM byte `$D198` and uses it as an index for four native words at `$2709`, `$26FA`, `$26FF`, `$2704`, otherwise continuing at EXIT (`$2876`). The original historical word spelling is unknown.

```asm
TERSE_COLON_2866:
    RST $08
    DB $1B
    DW $D198
    DB $25
    DB $3D
    DW $2876
    DW $2709,$26FA,$26FF,$2704
    DB $06
```

### COMPARE_BRANCH_NE

**Native:** `$0229` · **Token:** `$93`

**Stack effects:** equal: `( a b -- )`; unequal: `( a b -- a )`.

Pop top cell b to HL, then a to DE. Compare b against a. If equal, consume the following two bytes by advancing BC and continue; if unequal, read the following little-endian 16-bit address into BC, push a back onto the data stack and branch there. The branch target is an inline operand, **not** two independent TERSE tokens.

**Confirmed uses:** seven branch sites in the decoded game-control definitions at `$2B01`, `$2B2E`, `$2B5D`, `$2B8D`, `$2F03`, `$2F15` and `$2F27`. The unequal-path preserved value makes this more specialized than a conventional Forth comparison or simple 0BRANCH; no original source-level word spelling is claimed.

**Original native implementation (with original branch addresses):**

```z80
    POP HL
    POP DE
    OR A
    SBC HL,DE
    JP NZ,$0235
    INC BC
    INC BC
    JP (IY)
    ; $0235: unequal
    LD A,(BC)
    LD L,A
    INC BC
    LD A,(BC)
    LD B,A
    LD C,L
    PUSH DE
    JP (IY)
```

### ADD_INLINE16

**Native:** `$006B` · **Token:** `$94` · **Stack:** `( n -- n+offset )`

Pop one 16-bit stack cell, read the next two bytes from the active BC thread as a little-endian 16-bit displacement, add that displacement to the cell modulo 65536, and push the result. BC advances by two bytes. The inline displacement is **not** two subsequent TERSE tokens.

**Example:** `0 ADD_INLINE16 $D1A9` leaves `$D1A9` on the data stack.

**Original native implementation** (`TERSE_ADD_INLINE16`):

```z80
    POP HL
    LD A,(BC)
    INC BC
    LD E,A
    LD A,(BC)
    INC BC
    LD D,A
    ADD HL,DE
    PUSH HL
    JP (IY)
```

**Confirmed uses:** twelve inline-operand instances in the decoded `$2B05–$2BE8` programs use values `$D1A9` or `$D1A4`. Earlier source incorrectly treated the operand bytes (`$A9/$A4`, `$D1`) as independent tokens. The 16-bit addition is wrapping and has the same result for signed or unsigned interpretation of the displacement.

### EXIT

**Native:** `$0044` · **Token:** `$06` · **Stack:** `( R: caller-ip -- )`

Return from a colon definition, restoring the caller's threaded instruction pointer.

**Example:** `Finish a colon word and resume its caller.`

**Original native implementation** (`TERSE_EXIT`):

```z80
    LD C,(IX+$00)
    INC IX
    LD B,(IX+$00)
    INC IX
    JP (IY)
```

### LIT (16-bit inline literal)

**Native:** `$0050` · **Token:** `$1B` · **Stack:** `( -- n )`

Push the little-endian 16-bit word following this token.

**Example:** `LIT16 $D180  ( -- $D180 )`

**Original native implementation** (`TERSE_LIT16`):

```z80
    LD A,(BC)
    INC BC
    LD L,A
    LD A,(BC)
    INC BC
    LD H,A
    PUSH HL
    JP (IY)
```

### LIT8

**Native:** `$0059` · **Token:** `$0E` · **Stack:** `( -- u )`

Push the unsigned byte following this token, zero-extended.

**Example:** `LIT8 $0C  ( -- 12 )`

**Original native implementation** (`TERSE_LIT8`):

```z80
    LD A,(BC)
    INC BC
    LD L,A
    LD H,$00
    PUSH HL
    JP (IY)
```

<a id="token-0b"></a>

### 0 — token $0B

**Native:** `$007B` · **Token:** `$0B` · **Stack:** `( -- 0 )`

Push the 16-bit constant zero.

**Example:** `0  ( -- 0 )`

**Original native implementation** (`TERSE_ZERO`):

```z80
    LD HL,$0000
    PUSH HL
    JP (IY)
```

<a id="token-09"></a>

### 1 — token $09

**Native:** `$0081` · **Token:** `$09` · **Stack:** `( -- 1 )`

Push the 16-bit constant one.

**Example:** `1  ( -- 1 )`

**Original native implementation** (`TERSE_ONE`):

```z80
    LD HL,$0001
    PUSH HL
    JP (IY)
```

### DUP

**Native:** `$0087` · **Token:** `$0D` · **Stack:** `( n -- n n )`

Duplicate the top data-stack cell.

**Example:** `$0005 DUP  ( -- $0005 $0005 )`

**Original native implementation** (`TERSE_DUP`):

```z80
    POP HL
    PUSH HL
    PUSH HL
    JP (IY)
```

### 2DUP

**Native:** `$008C` · **Token:** `$01` · **Stack:** `( a b -- a b a b )`

Duplicate the top two cells in order.

**Example:** `$0002 $0003 2DUP`

**Original native implementation** (`TERSE_2DUP`):

```z80
    POP HL
    POP DE
    PUSH DE
    PUSH HL
    PUSH DE
    PUSH HL
    JP (IY)
```

### DROP

**Native:** `$0094` · **Token:** `$05` · **Stack:** `( n -- )`

Discard the top data-stack cell.

**Example:** `$0005 DROP  ( -- )`

**Original native implementation** (`TERSE_DROP`):

```z80
    POP HL
    JP (IY)
```

### SWAP

**Native:** `$0097` · **Token:** `$04` · **Stack:** `( a b -- b a )`

Exchange the top two data-stack cells.

**Example:** `$0002 $0003 SWAP  ( -- $0003 $0002 )`

**Original native implementation** (`TERSE_SWAP`):

```z80
    POP HL
    POP DE
    PUSH HL
    PUSH DE
    JP (IY)
```

<a id="token-0c"></a>

### @ — token $0C

**Native:** `$009D` · **Token:** `$0C` · **Stack:** `( addr -- n )`

Read a little-endian 16-bit word from memory.

**Example:** `$D180 @  ( -- word at $D180 )`

**Original native implementation** (`TERSE_FETCH`):

```z80
    POP HL
    LD E,(HL)
    INC HL
    LD D,(HL)
    PUSH DE
    JP (IY)
```

<a id="token-25"></a>

### B@ — token $25

**Native:** `$00A4` · **Token:** `$25` · **Stack:** `( addr -- u )`

Read a single memory byte and zero-extend it.

**Example:** `$D180 B@`

**Original native implementation** (`TERSE_BYTE_FETCH`):

```z80
    POP HL
    LD E,(HL)
    LD D,$00
    PUSH DE
    JP (IY)
```

<a id="token-10"></a>

### ! — token $10

**Native:** `$00AB` · **Token:** `$10` · **Stack:** `( n addr -- )`

Write a little-endian 16-bit word to memory.

**Example:** `$1234 $D180 !`

**Original native implementation** (`TERSE_STORE`):

```z80
    POP HL
    POP DE
    LD (HL),E
    INC HL
    LD (HL),D
    JP (IY)
```

<a id="token-08"></a>

### B! — token $08

**Native:** `$00B2` · **Token:** `$08` · **Stack:** `( n addr -- )`

Write the low eight bits of n to memory.

**Example:** `$003F $D180 B!`

**Original native implementation** (`TERSE_BYTE_STORE`):

```z80
    POP HL
    POP DE
    LD (HL),E
    JP (IY)
```

### ZERO

**Native:** `$00B7` · **Token:** `$1C` · **Stack:** `( addr -- )`

Clear the addressed two-byte word.

**Example:** `$D180 ZERO`

**Original native implementation** (`TERSE_ZERO_WORD_AT_ADDRESS`):

```z80
    POP HL
    LD (HL),$00
    INC HL
    LD (HL),$00
    JP (IY)
```

<a id="token-0f"></a>

### + — token $0F

**Native:** `$00BF` · **Token:** `$0F` · **Stack:** `( a b -- a+b )`

Add two 16-bit stack cells with wraparound.

**Example:** `2 3 +  ( -- 5 )`

**Original native implementation** (`TERSE_ADD`):

```z80
    POP DE
    POP HL
    ADD HL,DE
    PUSH HL
    JP (IY)
```

<a id="token-3f"></a>

### - — token $3F

**Native:** `$00C5` · **Token:** `$3F` · **Stack:** `( a b -- a-b )`

Subtract the top cell from the next cell.

**Example:** `8 3 -  ( -- 5 )`

**Original native implementation** (`TERSE_SUBTRACT`):

```z80
    POP DE
    POP HL
    XOR A
    SBC HL,DE
    PUSH HL
    JP (IY)
```

<a id="token-15"></a>

### 1- — token $15

**Native:** `$00D4` · **Token:** `$15` · **Stack:** `( n -- n-1 )`

Decrement a 16-bit cell.

**Example:** `5 1-  ( -- 4 )`

**Original native implementation** (`TERSE_DECREMENT`):

```z80
    POP HL
    DEC HL
    PUSH HL
    JP (IY)
```

<a id="token-14"></a>

### 1+ — token $14

**Native:** `$00D9` · **Token:** `$14` · **Stack:** `( n -- n+1 )`

Increment a 16-bit cell.

**Example:** `5 1+  ( -- 6 )`

**Original native implementation** (`TERSE_INCREMENT`):

```z80
    POP HL
    INC HL
    PUSH HL
    JP (IY)
```

### ARITH_SHIFT_RIGHT

**Native:** `$00DE` · **Token:** `$3A` · **Stack:** `( signed-n -- signed-n>>1 )`

Arithmetic shift of a signed 16-bit cell; sign bit is retained.

**Example:** `$FFFE ARITH_SHIFT_RIGHT  ( -- $FFFF )`

**Original native implementation** (`TERSE_ARITH_SHIFT_RIGHT`):

```z80
    POP HL
    SRA H
    RR L
    PUSH HL
    JP (IY)
```

### AND

**Native:** `$0149` · **Token:** `$4C` · **Stack:** `( a b -- a&b )`

Bitwise AND of two 16-bit cells.

**Example:** `$00F0 $00AA AND  ( -- $00A0 )`

**Original native implementation** (`TERSE_BITWISE_AND`):

```z80
    POP DE
    POP HL
    LD A,L
    AND E
    LD L,A
    LD A,H
    AND D
    LD H,A
    PUSH HL
    JP (IY)
```

### OR

**Native:** `$0154` · **Token:** `$54` · **Stack:** `( a b -- a|b )`

Bitwise OR of two 16-bit cells.

**Example:** `$0010 $0003 OR  ( -- $0013 )`

**Original native implementation** (`TERSE_BITWISE_OR`):

```z80
    POP DE
    POP HL
    LD A,L
    OR E
    LD L,A
    LD A,H
    OR D
    LD H,A
    PUSH HL
    JP (IY)
```

### I

**Native:** `$01B6` · **Token:** `$24` · **Stack:** `( -- index )`

Push current counted-loop index from the IX control frame.

**Example:** `I  ( -- current index )`

**Original native implementation** (`TERSE_LOOP_INDEX`):

```z80
    LD L,(IX+$00)
    LD H,(IX+$01)
    PUSH HL
    JP (IY)
```

### OUTP

**Native:** `$01D1` · **Token:** `$1F` · **Stack:** `( value port -- )`

Send the low data byte to a Z80 I/O port.

**Example:** `$000F $0010 OUTP`

**Original native implementation** (`TERSE_PORT_OUT`):

```z80
    EXX
    POP BC
    POP HL
    OUT (C),L
    EXX
    JP (IY)
```

### INP

**Native:** `$01D9` · **Token:** `$21` · **Stack:** `( port -- byte )`

Read a Z80 I/O port and zero-extend the result.

**Example:** `$0010 INP`

**Original native implementation** (`TERSE_PORT_IN`):

```z80
    EXX
    POP BC
    IN L,(C)
    LD H,$00
    PUSH HL
    EXX
    JP (IY)
```

### BRANCH_ABSOLUTE

**Native:** `$01F4` · **Token:** `$46` · **Stack:** `( -- )`

Set BC to the little-endian address following the token.

**Example:** `BRANCH_ABSOLUTE target_label`

**Original native implementation** (`TERSE_BRANCH_ABSOLUTE`):

```z80
    LD A,(BC)
    LD E,A
    INC BC
    LD A,(BC)
    LD B,A
    LD C,E
    JP (IY)
```

### ZERO_BRANCH

**Native:** `$01FC` · **Token:** `$03` · **Stack:** `( flag -- )`

Jump to the inline absolute thread address if flag is zero; otherwise skip its two-byte operand.

**Example:** `0 ZERO_BRANCH target_label`

**Original native implementation** (`TERSE_ZERO_BRANCH`):

```z80
    POP HL
    LD A,H
    OR L
    JP Z,$0206
    INC BC
    INC BC
    JP (IY)
```

## DNA standard vocabulary correspondence

| DNA standard word | Space Zap token | Native entry | Verified semantics |
| --- | --- | --- | --- |
| `@`, `B@`, `!`, `B!` | `$0C`, `$25`, `$10`, `$08` | `$009D`, `$00A4`, `$00AB`, `$00B2` | Word/byte memory access |
| `+`, `-`, `1+`, `1-` | `$0F`, `$3F`, `$14`, `$15` | `$00BF`, `$00C5`, `$00D9`, `$00D4` | 16-bit arithmetic |
| `0`, `1`, `ZERO` | `$0B`, `$09`, `$1C` | `$007B`, `$0081`, `$00B7` | Constants versus memory clear |
| `AND`, `OR`, `=`, `U>=` | `$4C`, `$54`, `$44`, `$C2` | `$0149`, `$0154`, `$00EE`, `$00FD` | Bitwise and comparison |
| `ROT`, `PICK`, `I` | `$13`, `$45`, `$24` | `$01E3`, `$01EA`, `$01B6` | Stack and loop frame |
| `INP`, `OUTP` | `$21`, `$1F` | `$01D9`, `$01D1` | Z80 port operations |
| `MINUS`, `1-B!` | `$82`, `$43` | `$00CD`, `$00E6` | Negation and byte decrement |
| `BMOVE` | `$16` | `$015F` | Byte move, edge cases under review |

**Remaining analysis:** verify the colon-return word and specialized inline control/branch routines against their native implementations and DNA vocabulary. See the sprint plan for additional primitive recovery.

## Native-address tokens still being recovered

The indexed table contains 256 slots, including five invalid `$FFFF` entries. Not every valid native target has a fully established Forth-level meaning or stack contract. The [complete token-vector inventory](TERSE-TOKEN-VECTORS.md) retains all 256 values; this dictionary contains only words with a recovered implementation and a meaningful stack effect. Add each resolved word here as source recovery progresses.
