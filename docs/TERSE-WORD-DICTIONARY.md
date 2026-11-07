# Space Zap TERSE word dictionary

A programmer's dictionary of **recovered** TERSE execution words in the original 1980 Space Zap ROM. This is organized like a Forth dictionary: word name, purpose, stack effect, example, execution token and native implementation. Examples illustrate each word's stack operation.

**Notation:** `( before -- after )` describes the data stack, bottom-to-top (topmost at right). `R:` denotes the IX control stack. Cells are 16-bit unless noted. Tokens are one byte; `LIT8`, `LIT16`, and branches consume extra inline data. Native routines resume through `JP (IY)` unless they transfer control elsewhere.

See [architecture](TERSE-ARCHITECTURE.md), [complete indexed-token vector inventory](TERSE-TOKEN-VECTORS.md), and [compiled TERSE programs](TERSE-COMPILED-PROGRAMS.md).

## Quick reference

| Word | Token | Native | Stack effect | Purpose |
| :--- | :---: | :---: | :--- | :--- |
| [`EXIT`](#exit) | `$06` | `$0044` | `( R: caller-ip -- )` | Return from a colon definition, restoring the caller's threaded instruction pointer. |
| [`LIT16`](#lit16) | `$1B` | `$0050` | `( -- n )` | Push the little-endian 16-bit word following this token. |
| [`LIT8`](#lit8) | `$0E` | `$0059` | `( -- u )` | Push the unsigned byte following this token, zero-extended. |
| [`ZERO`](#zero) | `$0B` | `$007B` | `( -- 0 )` | Push the 16-bit constant zero. |
| [`ONE`](#one) | `$09` | `$0081` | `( -- 1 )` | Push the 16-bit constant one. |
| [`DUP`](#dup) | `$0D` | `$0087` | `( n -- n n )` | Duplicate the top data-stack cell. |
| [`2DUP`](#2dup) | `$01` | `$008C` | `( a b -- a b a b )` | Duplicate the top two cells in order. |
| [`DROP`](#drop) | `$05` | `$0094` | `( n -- )` | Discard the top data-stack cell. |
| [`SWAP`](#swap) | `$04` | `$0097` | `( a b -- b a )` | Exchange the top two data-stack cells. |
| [`FETCH`](#fetch) | `$0C` | `$009D` | `( addr -- n )` | Read a little-endian 16-bit word from memory. |
| [`BYTE_FETCH`](#byte-fetch) | `$25` | `$00A4` | `( addr -- u )` | Read a single memory byte and zero-extend it. |
| [`STORE`](#store) | `$10` | `$00AB` | `( n addr -- )` | Write a little-endian 16-bit word to memory. |
| [`BYTE_STORE`](#byte-store) | `$08` | `$00B2` | `( n addr -- )` | Write the low eight bits of n to memory. |
| [`ZERO_WORD_AT_ADDRESS`](#zero-word-at-address) | `$1C` | `$00B7` | `( addr -- )` | Clear the addressed two-byte word. |
| [`ADD`](#add) | `$0F` | `$00BF` | `( a b -- a+b )` | Add two 16-bit stack cells with wraparound. |
| [`SUBTRACT`](#subtract) | `$3F` | `$00C5` | `( a b -- a-b )` | Subtract the top cell from the next cell. |
| [`DECREMENT`](#decrement) | `$15` | `$00D4` | `( n -- n-1 )` | Decrement a 16-bit cell. |
| [`INCREMENT`](#increment) | `$14` | `$00D9` | `( n -- n+1 )` | Increment a 16-bit cell. |
| [`ARITH_SHIFT_RIGHT`](#arith-shift-right) | `$3A` | `$00DE` | `( signed-n -- signed-n>>1 )` | Arithmetic shift of a signed 16-bit cell; sign bit is retained. |
| [`BITWISE_AND`](#bitwise-and) | `$4C` | `$0149` | `( a b -- a&b )` | Bitwise AND of two 16-bit cells. |
| [`BITWISE_OR`](#bitwise-or) | `$54` | `$0154` | `( a b -- a|b )` | Bitwise OR of two 16-bit cells. |
| [`LOOP_INDEX`](#loop-index) | `$24` | `$01B6` | `( -- index )` | Push current counted-loop index from the IX control frame. |
| [`PORT_OUT`](#port-out) | `$1F` | `$01D1` | `( value port -- )` | Send the low data byte to a Z80 I/O port. |
| [`PORT_IN`](#port-in) | `$21` | `$01D9` | `( port -- byte )` | Read a Z80 I/O port and zero-extend the result. |
| [`ADD_INLINE16`](#add-inline16) | `$94` | `$006B` | `( n -- n+offset )` | Consume an inline 16-bit displacement and add it to the stack top modulo 65536. |
| [`BRANCH_ABSOLUTE`](#branch-absolute) | `$46` | `$01F4` | `( -- )` | Set BC to the little-endian address following the token. |
| [`ZERO_BRANCH`](#zero-branch) | `$03` | `$01FC` | `( flag -- )` | Jump to the inline absolute thread address if flag is zero; otherwise skip its two-byte operand. |

## Recovered words

### ADD_INLINE16

**Native:** `$006B` · **Token:** `$94` · **Stack:** `( n -- n+offset )`

Pop one 16-bit stack cell, read the next two bytes from the active BC thread as a little-endian 16-bit displacement, add that displacement to the cell modulo 65536, and push the result. BC advances by two bytes. The inline displacement is **not** two subsequent TERSE tokens.

**Example:** `ZERO ADD_INLINE16 $D1A9` leaves `$D1A9` on the data stack.

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

### LIT16

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

### ZERO

**Native:** `$007B` · **Token:** `$0B` · **Stack:** `( -- 0 )`

Push the 16-bit constant zero.

**Example:** `ZERO  ( -- 0 )`

**Original native implementation** (`TERSE_ZERO`):

```z80
    LD HL,$0000
    PUSH HL
    JP (IY)
```

### ONE

**Native:** `$0081` · **Token:** `$09` · **Stack:** `( -- 1 )`

Push the 16-bit constant one.

**Example:** `ONE  ( -- 1 )`

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

### FETCH

**Native:** `$009D` · **Token:** `$0C` · **Stack:** `( addr -- n )`

Read a little-endian 16-bit word from memory.

**Example:** `$D180 FETCH  ( -- word at $D180 )`

**Original native implementation** (`TERSE_FETCH`):

```z80
    POP HL
    LD E,(HL)
    INC HL
    LD D,(HL)
    PUSH DE
    JP (IY)
```

### BYTE_FETCH

**Native:** `$00A4` · **Token:** `$25` · **Stack:** `( addr -- u )`

Read a single memory byte and zero-extend it.

**Example:** `$D180 BYTE_FETCH`

**Original native implementation** (`TERSE_BYTE_FETCH`):

```z80
    POP HL
    LD E,(HL)
    LD D,$00
    PUSH DE
    JP (IY)
```

### STORE

**Native:** `$00AB` · **Token:** `$10` · **Stack:** `( n addr -- )`

Write a little-endian 16-bit word to memory.

**Example:** `$1234 $D180 STORE`

**Original native implementation** (`TERSE_STORE`):

```z80
    POP HL
    POP DE
    LD (HL),E
    INC HL
    LD (HL),D
    JP (IY)
```

### BYTE_STORE

**Native:** `$00B2` · **Token:** `$08` · **Stack:** `( n addr -- )`

Write the low eight bits of n to memory.

**Example:** `$003F $D180 BYTE_STORE`

**Original native implementation** (`TERSE_BYTE_STORE`):

```z80
    POP HL
    POP DE
    LD (HL),E
    JP (IY)
```

### ZERO_WORD_AT_ADDRESS

**Native:** `$00B7` · **Token:** `$1C` · **Stack:** `( addr -- )`

Clear the addressed two-byte word.

**Example:** `$D180 ZERO_WORD_AT_ADDRESS`

**Original native implementation** (`TERSE_ZERO_WORD_AT_ADDRESS`):

```z80
    POP HL
    LD (HL),$00
    INC HL
    LD (HL),$00
    JP (IY)
```

### ADD

**Native:** `$00BF` · **Token:** `$0F` · **Stack:** `( a b -- a+b )`

Add two 16-bit stack cells with wraparound.

**Example:** `2 3 ADD  ( -- 5 )`

**Original native implementation** (`TERSE_ADD`):

```z80
    POP DE
    POP HL
    ADD HL,DE
    PUSH HL
    JP (IY)
```

### SUBTRACT

**Native:** `$00C5` · **Token:** `$3F` · **Stack:** `( a b -- a-b )`

Subtract the top cell from the next cell.

**Example:** `8 3 SUBTRACT  ( -- 5 )`

**Original native implementation** (`TERSE_SUBTRACT`):

```z80
    POP DE
    POP HL
    XOR A
    SBC HL,DE
    PUSH HL
    JP (IY)
```

### DECREMENT

**Native:** `$00D4` · **Token:** `$15` · **Stack:** `( n -- n-1 )`

Decrement a 16-bit cell.

**Example:** `5 DECREMENT  ( -- 4 )`

**Original native implementation** (`TERSE_DECREMENT`):

```z80
    POP HL
    DEC HL
    PUSH HL
    JP (IY)
```

### INCREMENT

**Native:** `$00D9` · **Token:** `$14` · **Stack:** `( n -- n+1 )`

Increment a 16-bit cell.

**Example:** `5 INCREMENT  ( -- 6 )`

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

### BITWISE_AND

**Native:** `$0149` · **Token:** `$4C` · **Stack:** `( a b -- a&b )`

Bitwise AND of two 16-bit cells.

**Example:** `$00F0 $00AA BITWISE_AND  ( -- $00A0 )`

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

### BITWISE_OR

**Native:** `$0154` · **Token:** `$54` · **Stack:** `( a b -- a|b )`

Bitwise OR of two 16-bit cells.

**Example:** `$0010 $0003 BITWISE_OR  ( -- $0013 )`

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

### LOOP_INDEX

**Native:** `$01B6` · **Token:** `$24` · **Stack:** `( -- index )`

Push current counted-loop index from the IX control frame.

**Example:** `LOOP_INDEX  ( -- current index )`

**Original native implementation** (`TERSE_LOOP_INDEX`):

```z80
    LD L,(IX+$00)
    LD H,(IX+$01)
    PUSH HL
    JP (IY)
```

### PORT_OUT

**Native:** `$01D1` · **Token:** `$1F` · **Stack:** `( value port -- )`

Send the low data byte to a Z80 I/O port.

**Example:** `$000F $0010 PORT_OUT`

**Original native implementation** (`TERSE_PORT_OUT`):

```z80
    EXX
    POP BC
    POP HL
    OUT (C),L
    EXX
    JP (IY)
```

### PORT_IN

**Native:** `$01D9` · **Token:** `$21` · **Stack:** `( port -- byte )`

Read a Z80 I/O port and zero-extend the result.

**Example:** `$0010 PORT_IN`

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

## Native-address tokens still being recovered

The indexed table contains 256 slots, including five invalid `$FFFF` entries. Not every valid native target has a fully established Forth-level meaning or stack contract. The [complete token-vector inventory](TERSE-TOKEN-VECTORS.md) retains all 256 values; this dictionary contains only words with a recovered implementation and a meaningful stack effect. Add each resolved word here as source recovery progresses.
