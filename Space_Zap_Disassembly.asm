;*******************************************************************************
; SPACE ZAP (1980)
;*******************************************************************************
; Four-direction space-defense arcade game for Midway Astrocade hardware.
;
; Developer : Dave Nutting Associates (DNA)
; Publisher : Midway Manufacturing
; CPU       : Z80
; Software  : TERSE indexed-byte interpreter and native Z80 routines
; RE version: v20261107-0007
;*******************************************************************************

	 ORG 0000H

	 nop
	 nop
	 di
	 jp   $0015
	 nop
	 nop
; TERSE_COLON_ENTRY $0008: RST08 pushes a new threaded IP onto SP.
; Preserve caller BC on IX then POP BC to enter that inline thread.
TERSE_COLON_ENTRY:
	 dec  ix
	 ld   (ix+$00),b
	 dec  ix
	 ld   (ix+$00),c
	 pop  bc
	 jp   (iy)
; TERSE_COLD_START $0015: machine and thread stacks initialization.
TERSE_COLD_START:
	 ld   a,$01
	 out  ($08),a
	 ld   a,$F0
	 out  ($F8),a
	 ld   a,$0F
	 out  ($FA),a
	 out  ($FB),a
	 ld   a,$01
	 out  ($FF),a
	 ld   ix,$D800
	 ld   sp,$D780
	 ld   bc,$3CDC
	 ld   iy,$0035
; TERSE_INDEXED_NEXT $0035: BC reads one-byte token, indexes 256
; 16-bit handler addresses at $3DEA. This is not direct-address NEXT.
TERSE_INDEXED_NEXT:
	 ld   a,(bc)
	 inc  bc
	 ld   de,TERSE_TOKEN_VECTORS
	 ld   l,a
	 ld   h,$00
	 add  hl,hl
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 jp   (hl)
; TERSE_EXIT $0044: recover parent BC from the IX control stack.
TERSE_EXIT:
	 ld   c,(ix+$00)
	 inc  ix
	 ld   b,(ix+$00)
	 inc  ix
	 jp   (iy)
; TERSE_LIT16 $0050: consume following little-endian 16-bit literal.
TERSE_LIT16:
	 ld   a,(bc)
	 inc  bc
	 ld   l,a
	 ld   a,(bc)
	 inc  bc
	 ld   h,a
	 push hl
	 jp   (iy)
; TERSE_LIT8 $0059: consume following unsigned byte literal.
TERSE_LIT8:
	 ld   a,(bc)
	 inc  bc
	 ld   l,a
	 ld   h,$00
	 push hl
	 jp   (iy)
	 ld   a,(bc)
	 inc  bc
	 ld   l,a
	 ld   a,(bc)
	 inc  bc
	 ld   h,a
	 push hl
	 jp   $0050
; TERSE_ADD_INLINE16 $006B, token $94: ( n -- n+offset ).
; Fetch a little-endian signed/unsigned 16-bit inline displacement from BC,
; add to the top stack cell modulo 65536, then continue through IY.
TERSE_ADD_INLINE16:
	 pop  hl
	 ld   a,(bc)
	 inc  bc
	 ld   e,a
	 ld   a,(bc)
	 inc  bc
	 ld   d,a
	 add  hl,de
	 push hl
	 jp   (iy)
	 pop  hl
	 add  hl,hl
	 jp   $006C
; The entry at $0076 doubles HL before entering the shared inline-add body.
; No vector-table token currently points to this entry.
; Push 16-bit zero.
TERSE_ZERO:
	 ld   hl,$0000
	 push hl
	 jp   (iy)
; Push 16-bit one.
TERSE_ONE:
	 ld   hl,$0001
	 push hl
	 jp   (iy)
; ( n -- n n ) Duplicate top data-stack cell.
TERSE_DUP:
	 pop  hl
	 push hl
	 push hl
	 jp   (iy)
; ( a b -- a b a b ) Duplicate two data-stack cells.
TERSE_2DUP:
	 pop  hl
	 pop  de
	 push de
	 push hl
	 push de
	 push hl
	 jp   (iy)
; ( n -- ) Discard top data-stack cell.
TERSE_DROP:
	 pop  hl
	 jp   (iy)
; ( a b -- b a ) Exchange top two cells.
TERSE_SWAP:
	 pop  hl
	 pop  de
	 push hl
	 push de
	 jp   (iy)
; ( addr -- value ) Load little-endian 16-bit word.
TERSE_FETCH:
	 pop  hl
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 push de
	 jp   (iy)
; ( addr -- byte ) Load zero-extended byte.
TERSE_BYTE_FETCH:
	 pop  hl
	 ld   e,(hl)
	 ld   d,$00
	 push de
	 jp   (iy)
; ( value addr -- ) Store little-endian 16-bit word.
TERSE_STORE:
	 pop  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
; ( value addr -- ) Store low byte.
TERSE_BYTE_STORE:
	 pop  hl
	 pop  de
	 ld   (hl),e
	 jp   (iy)
; ( addr -- ) Clear the addressed 16-bit word.
TERSE_ZERO_WORD_AT_ADDRESS:
	 pop  hl
	 ld   (hl),$00
	 inc  hl
	 ld   (hl),$00
	 jp   (iy)
; ( a b -- a+b ) Unsigned 16-bit addition, wrapping.
TERSE_ADD:
	 pop  de
	 pop  hl
	 add  hl,de
	 push hl
	 jp   (iy)
; ( a b -- a-b ) 16-bit subtraction, wrapping.
TERSE_SUBTRACT:
	 pop  de
	 pop  hl
	 xor  a
	 sbc  hl,de
	 push hl
	 jp   (iy)
	 pop  de
	 ld   hl,$0000
	 jp   $00C7
; ( n -- n-1 ) Decrement word.
TERSE_DECREMENT:
	 pop  hl
	 dec  hl
	 push hl
	 jp   (iy)
; ( n -- n+1 ) Increment word.
TERSE_INCREMENT:
	 pop  hl
	 inc  hl
	 push hl
	 jp   (iy)
; ( signed-n -- signed-n/2 ) Arithmetic signed 16-bit shift right.
TERSE_ARITH_SHIFT_RIGHT:
	 pop  hl
	 sra  h
	 rr   l
	 push hl
	 jp   (iy)
; ( addr -- ) Decrement addressed byte.
TERSE_DECREMENT_BYTE_AT_ADDRESS:
	 pop  hl
	 dec  (hl)
	 jp   (iy)
; ( addr -- ) Increment addressed byte.
TERSE_INCREMENT_BYTE_AT_ADDRESS:
	 pop  hl
	 inc  (hl)
	 jp   (iy)
	 pop  de
	 pop  hl
	 xor  a
	 sbc  hl,de
	 ld   hl,$0000
	 jp   nz,$00FA
	 inc  hl
	 push hl
	 jp   (iy)
	 pop  de
	 pop  hl
	 xor  a
	 sbc  hl,de
	 ld   hl,$0000
	 jp   c,$0109
	 inc  hl
	 push hl
	 jp   (iy)
	 pop  de
	 pop  hl
	 xor  a
	 sbc  hl,de
	 ld   de,$0000
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   pe,$011D
	 inc  de
	 push de
	 jp   (iy)
	 pop  de
	 pop  hl
	 xor  a
	 sbc  hl,de
	 ld   de,$0000
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$0131
	 inc  de
	 push de
	 jp   (iy)
	 pop  hl
	 pop  de
	 jp   $010E
	 ld   de,$0000
	 jp   $00EF
	 pop  hl
	 ld   a,l
	 or   h
	 jp   z,$0146
	 push hl
	 push hl
	 jp   (iy)
; ( a b -- a AND b ) 16-bit bitwise AND.
TERSE_BITWISE_AND:
	 pop  de
	 pop  hl
	 ld   a,l
	 and  e
	 ld   l,a
	 ld   a,h
	 and  d
	 ld   h,a
	 push hl
	 jp   (iy)
; ( a b -- a OR b ) 16-bit bitwise OR.
TERSE_BITWISE_OR:
	 pop  de
	 pop  hl
	 ld   a,l
	 or   e
	 ld   l,a
	 ld   a,h
	 or   d
	 ld   h,a
	 push hl
	 jp   (iy)
; ( src dest count -- ) Transfer BC bytes with Z80 LDIR; BC/DE/HL preserved on alternate register bank.
TERSE_MEMORY_COPY:
	 exx
	 pop  bc
	 pop  de
	 pop  hl
	 ld   a,b
	 or   c
	 jp   z,$016A
	 ldir
	 exx
	 jp   (iy)
	 ld   de,$FFFA
	 add  ix,de
	 pop  hl
	 pop  de
	 ld   (ix+$00),l
	 ld   (ix+$01),h
	 ld   (ix+$02),e
	 ld   (ix+$03),d
	 ld   (ix+$04),c
	 ld   (ix+$05),b
	 jp   (iy)
	 ld   l,(ix+$00)
	 ld   h,(ix+$01)
	 inc  hl
	 ld   (ix+$00),l
	 ld   (ix+$01),h
	 ld   e,(ix+$02)
	 ld   d,(ix+$03)
	 xor  a
	 sbc  hl,de
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$01AE
	 ld   de,$0006
	 add  ix,de
	 jp   $01B4
	 ld   c,(ix+$04)
	 ld   b,(ix+$05)
	 jp   (iy)
; ( -- index ) Push active counted-loop index from the IX frame.
TERSE_LOOP_INDEX:
	 ld   l,(ix+$00)
	 ld   h,(ix+$01)
	 push hl
	 jp   (iy)
	 pop  hl
	 pop  de
	 push de
	 push hl
	 push de
	 jp   (iy)
; ( value addr -- ) Add a 16-bit quantity into the addressed little-endian word.
TERSE_ADD_TO_MEMORY_WORD:
	 pop  hl
	 pop  de
	 ld   a,(hl)
	 add  a,e
	 ld   (hl),a
	 inc  hl
	 ld   a,(hl)
	 adc  a,d
	 ld   (hl),a
	 jp   (iy)
; ( value port -- ) Write the low data byte through the variable I/O port in C.
TERSE_PORT_OUT:
	 exx
	 pop  bc
	 pop  hl
	 out  (c),l
	 exx
	 jp   (iy)
; ( port -- byte ) Read variable I/O port through C, returning zero-extended result.
TERSE_PORT_IN:
	 exx
	 pop  bc
	 in   l,(c)
	 ld   h,$00
	 push hl
	 exx
	 jp   (iy)
; ( a b c -- b c a ) Rotate three cells through the processor stack.
TERSE_STACK_ROTATE:
	 pop  de
	 pop  hl
	 ex   (sp),hl
	 push de
	 push hl
	 jp   (iy)
; ( index -- value ) Fetch a stack cell using a 1-based word offset.
TERSE_STACK_PICK:
	 pop  hl
	 dec  hl
	 add  hl,hl
	 add  hl,sp
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 push de
	 jp   (iy)
; Read a little-endian 16-bit inline branch target and replace the BC instruction pointer.
TERSE_BRANCH_ABSOLUTE:
	 ld   a,(bc)
	 ld   e,a
	 inc  bc
	 ld   a,(bc)
	 ld   b,a
	 ld   c,e
	 jp   (iy)
; ( flag -- ) Test zero and select inline branch target or skip its two-byte operand.
TERSE_ZERO_BRANCH:
	 pop  hl
	 ld   a,h
	 or   l
	 jp   z,$0206
	 inc  bc
	 inc  bc
	 jp   (iy)
	 jp   $01F4
	 ld   a,(ix+$00)
	 ld   (ix+$02),a
	 ld   a,(ix+$01)
	 ld   (ix+$03),a
	 jp   (iy)
; $0217-$021F: first compact TERSE colon word.
TERSE_SMALL_COLON_0217:
	 rst  $08
	 DB $01 ; TERSE_2DUP
	 DB $02 ; native $010C
	 DB $03 ; TERSE_ZERO_BRANCH
	 DW TERSE_SMALL_021E_DROP
	 DB $04 ; TERSE_SWAP
TERSE_SMALL_021E_DROP:
	 DB $05 ; TERSE_DROP
	 DB $06 ; TERSE_EXIT

TERSE_SMALL_COLON_0220:
	 rst  $08
	 DB $01 ; TERSE_2DUP
	 DB $07 ; native $0134
	 DB $03 ; TERSE_ZERO_BRANCH
	 DW TERSE_SMALL_0227_DROP
	 DB $04 ; TERSE_SWAP
TERSE_SMALL_0227_DROP:
	 DB $05 ; TERSE_DROP
	 DB $06 ; TERSE_EXIT

; $0229, token $93: ( a b -- ) if equal; ( a b -- a ) if unequal.
; Compare b against a; equal advances BC past an inline 16-bit branch address.
; Unequal loads BC from that inline little-endian address and preserves a.
; The unequal path has a different stack effect from the equal path.
TERSE_COMPARE_BRANCH_NE:
	 pop  hl
	 pop  de
	 or   a
	 sbc  hl,de
	 jp   nz,$0235
	 inc  bc
	 inc  bc
	 jp   (iy)
	 ld   a,(bc)
	 ld   l,a
	 inc  bc
	 ld   a,(bc)
	 ld   b,a
	 ld   c,l
	 push de
	 jp   (iy)
	 ld   a,(bc)
	 ld   e,a
	 inc  bc
	 ld   a,(bc)
	 ld   d,a
	 inc  bc
	 pop  hl
	 sla  l
	 rl   h
	 add  hl,bc
	 ld   b,d
	 ld   c,e
	 ex   de,hl
	 or   a
	 sbc  hl,de
	 jp   c,$025C
	 jp   z,$025C
	 ld   a,(de)
	 ld   l,a
	 inc  de
	 ld   a,(de)
	 ld   h,a
	 jp   (hl)
	 jp   (iy)
; $025E-$0269: three short threaded helper definitions.
TERSE_SMALL_COLON_025E:
	 rst  $08
	 DB $04 ; TERSE_SWAP
	 DB $08 ; indexed native vector $08
	 DB $06 ; TERSE_EXIT

TERSE_SMALL_COLON_0262:
	 rst  $08
	 DB $09 ; native token $09
	 DB $0A ; native token $0A
	 DB $06 ; TERSE_EXIT

TERSE_SMALL_COLON_0266:
	 rst  $08
	 DB $0B ; TERSE_ZERO
	 DB $0A ; native token $0A
	 DB $06 ; TERSE_EXIT
;==============================================================================
; NATIVE_NEGATE_HL ($026A)
; Two's-complement HL; restore AF before returning to native caller.
;==============================================================================
NATIVE_NEGATE_HL:
	 push af
	 ld   a,h
	 cpl
	 ld   h,a
	 ld   a,l
	 cpl
	 ld   l,a
	 inc  hl
	 pop  af
	 ret

;==============================================================================
; NATIVE_NEGATE_DE ($0273)
; Two's-complement DE while preserving AF.
;==============================================================================
NATIVE_NEGATE_DE:
	 push af
	 ld   a,d
	 cpl
	 ld   d,a
	 ld   a,e
	 cpl
	 ld   e,a
	 inc  de
	 pop  af
	 ret
;==============================================================================
; TERSE_COLON_027E: original thirteen-byte TERSE threaded word.
; Indexed token cells and one literal byte; no Z80 instruction stream.
;==============================================================================
TERSE_COLON_027E:
	 RST $08
	 DB $0C,$0D,$0E,$04,$0F,$04,$01,$10,$0E,$02,$0F,$10,$06

;==============================================================================
; NATIVE_ATOMIC_COMPARE_UPDATE ($028C)
; Compare expected two-byte fields and update the active record under DI.
; Preserves interrupt-enable state through saved AF; returns status in HL.
;==============================================================================
NATIVE_ATOMIC_COMPARE_UPDATE:
	 ld   a,i
	 push af
	 di
	 push de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 push de
	 pop  iy
	 inc  hl
	 ld   c,(iy+$00)
	 ld   e,c
	 ld   b,(iy+$01)
	 ld   d,b
	 ld   a,(hl)
	 inc  hl
	 cp   c
	 jp   nz,$02A8
	 ld   a,(hl)
	 cp   b
	 jp   nz,$02B0
	 push iy
	 pop  bc
	 inc  bc
	 inc  bc
	 inc  bc
	 inc  bc
	 ld   a,(iy+$02)
	 cp   c
	 ld   a,(iy+$03)
	 jp   nz,$02BD
	 cp   b
	 jp   nz,$02CA
	 pop  de
	 ld   hl,$0001
	 pop  af
	 jp   po,$02C9
	 ei
	 ret
	 pop  hl
	 ld   a,l
	 ld   (de),a
	 inc  de
	 ld   a,h
	 ld   (de),a
	 ld   (iy+$00),c
	 ld   (iy+$01),b
	 ld   hl,$0000
	 pop  af
	 jp   po,$02DE
	 ei
	 ret

;==============================================================================
; NATIVE_ATOMIC_RECORD_CHECK ($02DF)
; Compare and update an indexed two-word record with interrupts masked.
; Return status in HL; original interrupt-enable state restored.
;==============================================================================
NATIVE_ATOMIC_RECORD_CHECK:
	 ld   a,i
	 push af
	 di
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 push de
	 pop  iy
	 inc  hl
	 ld   c,(iy+$02)
	 ld   b,(iy+$03)
	 ld   a,(iy+$00)
	 cp   c
	 jp   nz,$02FB
	 ld   a,(iy+$01)
	 cp   b
	 jp   nz,$0307
	 ld   hl,$0001
	 pop  af
	 jp   po,$0306
	 ei
	 ret
	 ld   a,(bc)
	 ld   e,a
	 inc  bc
	 ld   a,(bc)
	 ld   d,a
	 dec  bc
	 ld   a,(hl)
	 inc  hl
	 cp   c
	 jp   nz,$0315
	 ld   a,(hl)
	 cp   b
	 jp   nz,$031D
	 push iy
	 pop  bc
	 inc  bc
	 inc  bc
	 inc  bc
	 inc  bc
	 ld   (iy+$02),c
	 ld   (iy+$03),b
	 ld   hl,$0000
	 pop  af
	 jp   po,$032D
	 ei
	 ret
	 di
	 add  a,$09
	 out  ($00),a
	 jp   $032E
;==============================================================================
; EVENT_RAM_ADDRESS_TABLE_0336 ($0336-$0345)
; Eight little-endian RAM addresses passed to the native record handlers.
;==============================================================================
EVENT_RAM_ADDRESS_TABLE_0336:
	 DW $D0A1,$D0D7,$D0D9,$D10F
	 DW $D111,$D12F,$D131,$D14F

; Native event/state record dispatch.
NATIVE_EVENT_RECORD_DISPATCH_0346:
	 ld   hl,EVENT_RAM_ADDRESS_TABLE_0336
	 ld   a,$01
	 push iy
	 ld   ($D09E),a
	 push iy
	 pop  de
	 call $028C
	 ld   a,l
	 or   h
	 jp   z,$035F
	 ld   hl,($D09F)
	 jp   (hl)
	 pop  iy
	 ret
	 ld   hl,$D093
	 inc  (hl)
	 ld   hl,$033A
	 ld   a,$02
	 jp   $034B
	 ld   a,(iy+$0a)
	 cp   $01
	 ret  nc
	 inc  (iy+$0a)
	 ld   hl,$D095
	 inc  (hl)
	 ld   a,($D08F)
	 cp   (iy+$1f)
	 jp   nc,$038C
	 ld   a,$04
	 ld   hl,$0342
	 jp   $0391
	 ld   a,$03
	 ld   hl,$033E
	 jp   $034B
	 push bc
	 ld   a,($D08E)
	 out  ($00),a
	 ei
	 ld   a,($D097)
	 or   a
	 jp   z,$03AA
	 di
	 xor  a
	 ld   ($D097),a
	 pop  bc
	 jp   (iy)
	 ld   ($D09C),sp
	 ld   ($D09A),ix
	 ld   hl,$0336
	 push iy
	 call $02DF
	 pop  iy
	 ld   a,l
	 or   h
	 jp   nz,$0407
	 ld   ($D098),de
	 push de
	 ex   (sp),iy
	 ld   a,(iy+$0a)
	 or   a
	 jp   nz,$0402
	 ld   bc,$040A
	 dec  ix
	 ld   (ix+$00),b
	 dec  ix
	 ld   (ix+$00),c
	 ld   a,($D08D)
	 out  ($00),a
	 bit  0,(iy+$04)
	 jp   z,$03F5
	 ld   c,(iy+$00)
	 ld   b,(iy+$01)
	 res  0,(iy+$04)
	 jp   $03FB
	 ld   c,(iy+$02)
	 ld   b,(iy+$03)
	 pop  iy
	 jp   (iy)
	 jp   $0407
	 call $0346
	 pop  iy
	 jp   $0422
	 ld   (de),a
	 push iy
	 ld   iy,($D098)
	 bit  2,(iy+$04)
	 jp   nz,$041C
	 res  1,(iy+$04)
	 set  0,(iy+$04)
	 pop  iy
	 ld   sp,($D09C)
	 ld   ix,($D09A)
	 pop  bc
	 jp   $0394
	 and  l
	 ex   (sp),iy
	 ld   (iy+$01),b
	 ld   (iy+$00),c
	 ld   a,(iy+$04)
	 bit  1,a
	 jp   z,$0442
	 cpl
	 bit  3,a
	 jp   nz,$044F
	 call $0346
	 ld   a,($D089)
	 dec  a
	 ld   (iy+$0b),a
	 ld   (iy+$04),$00
	 set  1,(iy+$04)
	 set  0,(iy+$04)
	 push iy
	 pop  hl
	 ld   de,($D098)
	 or   a
	 sbc  hl,de
	 jp   nz,$0470
	 call $0346
	 pop  iy
	 jp   $0422
	 pop  iy
	 ld   c,(ix+$00)
	 inc  ix
	 ld   b,(ix+$00)
	 inc  ix
	 jp   (iy)
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$02),c
	 ld   (iy+$03),b
	 call $0346
	 pop  iy
	 jp   $0422
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$02),c
	 ld   (iy+$03),b
	 call $0362
	 pop  iy
	 jp   $0422
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$02),c
	 ld   (iy+$03),b
	 set  3,(iy+$04)
	 pop  iy
	 jp   $0422
	 ex   (sp),iy
	 push bc
	 bit  3,(iy+$04)
	 jp   z,$04D3
	 call $0346
	 ld   a,($D089)
	 dec  a
	 ld   (iy+$0b),a
	 res  3,(iy+$04)
	 pop  bc
	 pop  iy
	 jp   (iy)
	 push af
	 push bc
	 push de
	 push hl
	 exx
	 ex   af,af'
	 push af
	 push bc
	 push de
	 push hl
	 push iy
	 push ix
	 ld   a,($D086)
	 out  ($0F),a
	 ld   a,$D0
	 ld   i,a
	 ld   a,$80
	 out  ($0D),a
	 ld   hl,$D089
	 inc  (hl)
	 ld   a,($D091)
	 cp   $00
	 jp   nz,$05D5
	 ld   a,$01
	 ei
	 ld   ($D091),a
	 xor  a
	 ld   ($D096),a
	 ld   a,($D091)
	 cp   $01
	 jp   nz,$0520
	 ld   a,($D096)
	 or   a
	 jp   nz,$0520
	 ld   hl,$033E
	 call $02DF
	 ld   a,l
	 or   h
	 jp   nz,$0547
	 ld   hl,$D095
	 dec  (hl)
	 push de
	 pop  iy
	 dec  (iy+$0a)
	 ld   hl,$053E
	 push hl
	 ld   h,(iy+$09)
	 ld   l,(iy+$08)
	 ld   a,($D08A)
	 out  ($00),a
	 di
	 jp   (hl)
	 ei
	 ld   a,($D08E)
	 out  ($00),a
	 jp   $0509
	 di
	 ld   a,($D090)
	 cp   $00
	 jp   nz,$05CF
	 ld   a,$01
	 ei
	 ld   ($D090),a
	 xor  a
	 ld   ($D094),a
	 ld   a,($D090)
	 cp   $01
	 jp   nz,$057B
	 ld   a,($D093)
	 ld   b,a
	 ld   a,($D094)
	 cp   b
	 jp   nc,$0578
	 ld   hl,$033A
	 call $02DF
	 ld   a,l
	 or   h
	 jp   $057B
	 ld   a,$01
	 or   a
	 jp   nz,$05CA
	 push de
	 pop  iy
	 ld   hl,$D093
	 dec  (hl)
	 ld   hl,$D094
	 inc  (hl)
	 bit  2,(iy+$04)
	 jp   z,$0594
	 xor  a
	 jp   $0598
	 bit  0,(iy+$04)
	 jp   z,$05A1
	 call $0346
	 jp   $05C7
	 ld   a,($D08C)
	 out  ($00),a
	 ld   a,($D089)
	 sub  (iy+$0b)
	 jp   z,$05BE
	 ld   hl,$05C1
	 push hl
	 ld   h,(iy+$07)
	 ld   l,(iy+$06)
	 di
	 jp   (hl)
	 jp   $05C1
	 call $0362
	 ei
	 ld   a,($D08E)
	 out  ($00),a
	 jp   $055A
	 ld   a,$00
	 ld   ($D090),a
	 di
	 ld   a,$00
	 ld   ($D091),a
	 pop  ix
	 pop  iy
	 pop  hl
	 pop  de
	 pop  bc
	 pop  af
	 ex   af,af'
	 exx
	 pop  hl
	 pop  de
	 pop  bc
	 pop  af
	 ei
	 ret
	 di
	 ld   a,$08
	 out  ($0E),a
	 im   2
	 call $04D8
	 di
	 jp   (iy)
	 push af
	 push bc
	 push de
	 push hl
	 exx
	 ex   af,af'
	 push af
	 push bc
	 push de
	 push hl
	 push iy
	 push ix
	 ld   a,($D087)
	 out  ($0F),a
	 ld   a,$D0
	 ld   i,a
	 ld   a,$82
	 out  ($0D),a
	 ld   a,($D091)
	 cp   $01
	 jp   nz,$061A
	 ld   a,$02
	 ld   ($D091),a
	 ld   a,($D092)
	 cp   $00
	 jp   nz,$0670
	 ld   a,$01
	 ei
	 ld   ($D092),a
	 xor  a
	 ld   ($D096),a
	 ld   a,($D092)
	 cp   $01
	 jp   nz,$0643
	 ld   a,($D096)
	 or   a
	 jp   nz,$0643
	 ld   hl,$0342
	 call $02DF
	 ld   a,l
	 or   h
	 jp   nz,$066A
	 ld   hl,$D095
	 dec  (hl)
	 push de
	 pop  iy
	 dec  (iy+$0a)
	 ld   hl,$0661
	 push hl
	 ld   h,(iy+$09)
	 ld   l,(iy+$08)
	 ld   a,($D08B)
	 out  ($00),a
	 di
	 jp   (hl)
	 ei
	 ld   a,($D08E)
	 out  ($00),a
	 jp   $062C
	 di
	 ld   a,$00
	 ld   ($D092),a
	 jp   $05D5
	 push af
	 ld   a,($D088)
	 out  ($0F),a
	 ld   a,$D0
	 ld   i,a
	 ld   a,$84
	 out  ($0D),a
	 ld   a,($D092)
	 cp   $01
	 jp   nz,$068E
	 ld   a,$02
	 ld   ($D092),a
	 ld   a,($D090)
	 cp   $01
	 jp   nz,$069B
	 ld   a,$02
	 ld   ($D090),a
	 pop  af
	 ei
	 ret
;*******************************************************************************
; MAGIC_DRAW_BITMAP
;
; Configures and starts a Magic/DNA bitmap transfer.
;
; Input:
;   B  XPAND value
;   C  Magic control and transform flags
;   D  Bitmap height in rows
;   E  Bitmap width in bytes
;   HL Destination address
;   IX Source bitmap address
;
; Bit 2 is cleared before the Magic register write. Bits 6 and 7 select the
; horizontal and vertical hardware transforms used by Space Zap.
;*******************************************************************************
MAGIC_DRAW_BITMAP:
	 ld   a,b
	 out  ($19),a
	 ld   a,c
	 res  2,a
	 out  ($0C),a
	 ld   a,$24
	 bit  7,c
	 jp   z,$06AF
	 set  4,a
	 bit  6,c
	 jp   z,$06B6
	 res  5,a
	 bit  3,c
	 jp   z,$06BD
	 set  1,a
	 bit  2,c
	 jp   z,$06C7
	 inc  e
	 res  2,a
	 set  3,a
	 ld   b,a
	 out  ($7A),a
	 push hl
	 push ix
	 pop  hl
	 ld   a,l
	 out  ($78),a
	 ld   a,h
	 out  ($79),a
	 pop  hl
	 ld   a,l
	 out  ($7B),a
	 ld   a,h
	 out  ($7C),a
	 ld   h,e
	 bit  3,c
	 jp   z,$06E3
	 rlc  h
	 dec  h
	 bit  7,c
	 jp   z,$06FA
	 bit  6,c
	 jp   z,$06F4
	 ld   a,$B0
	 add  a,h
	 jp   $06F7
	 ld   a,$B0
	 sub  h
	 jp   $0708
	 bit  6,c
	 jp   z,$0705
	 ld   a,$50
	 add  a,h
	 jp   $0708
	 ld   a,$50
	 sub  h
	 out  ($7B),a
	 ld   a,h
	 out  ($7D),a
	 ld   a,d
	 dec  a
	 out  ($7E),a
	 ret
;*******************************************************************************
; DRAW_SPRITE_FROM_HEADER
;
; Reads the width and height at IX, advances IX to the packed bitmap, and enters
; MAGIC_DRAW_BITMAP. Object-record callers pass object address + 2.
;*******************************************************************************
DRAW_SPRITE_FROM_HEADER:
	 ld   e,(ix+$00)
	 inc  ix
	 ld   d,(ix+$00)
	 inc  ix
	 jp   MAGIC_DRAW_BITMAP
	 sla  l
	 rl   h
	 sla  l
	 rl   h
	 ld   a,h
	 ld   h,$00
	 ld   l,a
	 add  hl,hl
	 add  hl,hl
	 add  hl,hl
	 add  hl,hl
	 push de
	 ld   e,l
	 ld   d,h
	 add  hl,hl
	 add  hl,hl
	 add  hl,de
	 ex   de,hl
	 pop  hl
	 ld   a,l
	 ld   l,h
	 ld   h,$00
	 add  hl,de
	 rlca
	 rlca
	 and  $03
	 ret
	 bit  6,c
	 jp   z,$074C
	 neg
	 jp   nz,$074C
	 dec  hl
	 and  $03
	 ld   e,a
	 ld   a,c
	 and  $FC
	 or   e
	 ld   c,a
	 ret
; Draw the object referenced by the active actor state and preserve its render
; parameters for the corresponding erase/redraw operation.
DRAW_ACTIVE_OBJECT:
	 ld   b,(iy+$1b)
	 ld   (iy+$23),b
	 ld   c,(iy+$1a)
	 ld   (iy+$22),c
	 ld   h,(iy+$21)
	 ld   l,(iy+$20)
	 ld   (iy+$37),h
	 ld   (iy+$36),l
	 inc  hl
	 inc  hl
	 push hl
	 pop  ix
	 ld   h,(iy+$39)
	 ld   l,(iy+$38)
	 ld   (iy+$3b),h
	 ld   (iy+$3a),l
	 jp   DRAW_SPRITE_FROM_HEADER

; Redraw the object using the render parameters saved by DRAW_ACTIVE_OBJECT.
REDRAW_SAVED_OBJECT:
	 ld   b,(iy+$23)
	 ld   c,(iy+$22)
	 ld   h,(iy+$37)
	 ld   l,(iy+$36)
	 inc  hl
	 inc  hl
	 push hl
	 pop  ix
	 ld   h,(iy+$3b)
	 ld   l,(iy+$3a)
	 jp   DRAW_SPRITE_FROM_HEADER
	 bit  3,(iy+$24)
	 jp   nz,$07B1
	 ld   a,(iy+$37)
	 or   (iy+$36)
	 jp   z,$07AE
	 call REDRAW_SAVED_OBJECT
	 jp   $07B5
	 res  3,(iy+$24)
	 bit  1,(iy+$24)
	 jp   nz,$07D5
	 in   a,($08)
	 call $0755
	 bit  0,(iy+$0f)
	 jp   z,$07D2
	 in   a,($08)
	 and  a
	 jp   z,$07D2
	 set  1,(iy+$11)
	 jp   $07D9
	 res  1,(iy+$24)
	 ret
	 sla  l
	 rl   h
	 sla  l
	 rl   h
	 ld   b,(iy+$21)
	 ld   c,(iy+$20)
	 push bc
	 pop  ix
	 ld   c,(iy+$1a)
	 push hl
	 ex   de,hl
	 ld   d,(ix+$00)
	 ld   e,$00
	 sra  d
	 rr   e
	 sra  d
	 rr   e
	 bit  6,c
	 jp   z,$0806
	 add  hl,de
	 jp   $0809
	 or   a
	 sbc  hl,de
	 ex   (sp),hl
	 ld   d,(ix+$01)
	 ld   e,$00
	 bit  7,c
	 jp   z,$0819
	 add  hl,de
	 dec  hl
	 jp   $081C
	 or   a
	 sbc  hl,de
	 pop  de
	 ld   a,h
	 ld   h,$00
	 ld   l,a
	 add  hl,hl
	 add  hl,hl
	 add  hl,hl
	 add  hl,hl
	 push de
	 ld   e,l
	 ld   d,h
	 add  hl,hl
	 add  hl,hl
	 add  hl,de
	 ex   de,hl
	 pop  hl
	 ld   a,l
	 ld   l,h
	 ld   h,$00
	 add  hl,de
	 rlca
	 rlca
	 and  $03
	 bit  6,c
	 jp   z,$0841
	 neg
	 jp   nz,$0841
	 dec  hl
	 and  $03
	 ld   e,a
	 ld   a,c
	 and  $FC
	 or   e
	 ld   (iy+$1a),a
	 ld   (iy+$39),h
	 ld   (iy+$38),l
	 ret
	 ld   a,(iy+$0d)
	 sub  b
	 ld   (iy+$0d),a
	 ld   a,(iy+$0e)
	 sbc  a,$00
	 ld   (iy+$0e),a
	 ld   b,(iy+$0c)
	 xor  a
	 add  a,c
	 djnz $0865
	 add  a,(iy+$0b)
	 ld   (iy+$0b),a
	 bit  4,(iy+$24)
	 jp   nz,$08F3
	 bit  5,(iy+$0f)
	 jp   nz,$08F3
	 bit  0,(iy+$24)
	 jp   nz,$08DE
	 ld   a,(iy+$36)
	 xor  (iy+$20)
	 jp   nz,$08DE
	 ld   a,(iy+$37)
	 xor  (iy+$21)
	 jp   nz,$08DE
	 exx
	 ld   d,(iy+$27)
	 ld   e,(iy+$26)
	 ld   h,(iy+$2f)
	 ld   l,(iy+$2e)
	 bit  7,h
	 call nz,$026A
	 bit  7,d
	 call nz,$0274
	 or   a
	 sbc  hl,de
	 jp   nc,$08CA
	 exx
	 push hl
	 ld   h,(iy+$1d)
	 ld   l,(iy+$1c)
	 ld   a,$C0
	 and  l
	 ld   l,a
	 ld   a,$C0
	 and  e
	 ld   c,a
	 ld   b,d
	 xor  a
	 sbc  hl,bc
	 pop  hl
	 jp   $08DE
	 exx
	 push hl
	 ld   b,(iy+$1f)
	 ld   c,(iy+$1e)
	 ld   a,$C0
	 and  l
	 ld   l,a
	 ld   a,$C0
	 and  c
	 ld   c,a
	 xor  a
	 sbc  hl,bc
	 pop  hl
	 ld   (iy+$1f),h
	 ld   (iy+$1e),l
	 ld   (iy+$1d),d
	 ld   (iy+$1c),e
	 jp   z,$08F3
	 call $07DA
	 call $036E
	 ld   a,(iy+$11)
	 and  a
	 jp   z,$0905
	 ld   (iy+$0f),$00
	 ld   (iy+$10),$00
	 jp   $0346
	 jp   $0362
	 push bc
	 ex   af,af'
	 ld   a,b
	 ld   h,(iy+$1d)
	 ld   l,(iy+$1c)
	 ld   d,(iy+$27)
	 ld   e,(iy+$26)
	 ld   b,(iy+$29)
	 ld   c,(iy+$28)
	 exx
	 ld   h,(iy+$1f)
	 ld   l,(iy+$1e)
	 ld   d,(iy+$2f)
	 ld   e,(iy+$2e)
	 ld   b,(iy+$31)
	 ld   c,(iy+$30)
	 ex   de,hl
	 add  hl,bc
	 ex   de,hl
	 add  hl,de
	 exx
	 ex   de,hl
	 add  hl,bc
	 ex   de,hl
	 add  hl,de
	 exx
	 dec  a
	 jp   nz,$0930
	 ld   (iy+$2f),d
	 ld   (iy+$2e),e
	 push hl
	 exx
	 ld   (iy+$27),d
	 ld   (iy+$26),e
	 pop  de
	 ex   de,hl
	 pop  bc
	 ex   af,af'
	 ret
	 exx
	 ld   h,(iy+$16)
	 ld   l,(iy+$15)
	 push hl
	 exx
	 ret
	 xor  a
	 push hl
	 sbc  hl,de
	 ex   af,af'
	 pop  hl
	 sbc  hl,bc
	 jp   nc,$096C
	 ex   af,af'
	 jr   nc,$0972
	 jp   $0971
	 ex   af,af'
	 jr   c,$0972
	 jr   z,$0972
	 ret
	 inc  a
	 set  2,(iy+$11)
	 ret
	 ex   af,af'
	 push hl
	 push de
	 exx
	 pop  de
	 bit  1,(iy+$10)
	 jp   z,$099B
	 ld   h,(iy+$3d)
	 ld   l,(iy+$3c)
	 ld   b,(iy+$1d)
	 ld   c,(iy+$1c)
	 call $095B
	 and  a
	 jp   z,$099B
	 set  4,(iy+$12)
	 pop  de
	 bit  2,(iy+$10)
	 jp   z,$09BA
	 ld   h,(iy+$3f)
	 ld   l,(iy+$3e)
	 ld   b,(iy+$1f)
	 ld   c,(iy+$1e)
	 call $095B
	 and  a
	 jp   z,$09BA
	 set  5,(iy+$12)
	 ex   af,af'
	 exx
	 ret
	 ex   af,af'
	 ld   c,$00
	 ld   d,c
	 ld   h,(iy+$0e)
	 ld   l,(iy+$0d)
	 ld   a,l
	 ld   e,b
	 or   a
	 sbc  hl,de
	 jp   nc,$09D8
	 ld   c,l
	 ld   b,a
	 set  3,(iy+$11)
	 jp   $09DF
	 jp   nz,$09DF
	 set  3,(iy+$11)
	 ex   af,af'
	 ret
	 ex   af,af'
	 ld   l,(iy+$13)
	 ld   h,(iy+$14)
	 ld   a,(hl)
	 or   a
	 jp   z,$09F3
	 ld   (hl),$00
	 set  4,(iy+$11)
	 ex   af,af'
	 ret
	 ex   af,af'
	 exx
	 ld   l,(iy+$40)
	 ld   h,(iy+$41)
	 bit  1,(iy+$25)
	 jp   z,$0A41
	 exx
	 ld   a,b
	 exx
	 ld   b,a
	 ld   e,(iy+$43)
	 ld   c,e
	 ld   d,$00
	 add  hl,de
	 sla  e
	 rl   d
	 add  hl,de
	 ld   a,(iy+$42)
	 sub  b
	 jp   nc,$0A1C
	 cp   a
	 jp   nz,$0A36
	 neg
	 ld   b,a
	 inc  hl
	 inc  hl
	 inc  hl
	 inc  c
	 ld   a,(hl)
	 or   a
	 jp   nz,$0A33
	 inc  hl
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 ld   a,(hl)
	 ld   c,$00
	 jp   $0A17
	 inc  hl
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 ld   (iy+$42),a
	 ld   (iy+$43),c
	 ld   (iy+$21),h
	 ld   (iy+$20),l
	 exx
	 ex   af,af'
	 ret
	 ex   af,af'
	 push de
	 exx
	 bit  7,(iy+$27)
	 jp   nz,$0A71
	 pop  hl
	 ld   e,(iy+$2c)
	 ld   d,(iy+$2d)
	 or   a
	 sbc  hl,de
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$0A6E
	 set  2,(iy+$12)
	 set  0,(iy+$11)
	 jp   $0A8B
	 pop  de
	 ld   l,(iy+$2a)
	 ld   h,(iy+$2b)
	 or   a
	 sbc  hl,de
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$0A8B
	 set  3,(iy+$12)
	 set  0,(iy+$11)
	 exx
	 push hl
	 exx
	 bit  7,(iy+$2f)
	 jp   nz,$0AB2
	 pop  hl
	 ld   e,(iy+$32)
	 ld   d,(iy+$33)
	 or   a
	 sbc  hl,de
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$0AAF
	 set  0,(iy+$12)
	 set  0,(iy+$11)
	 jp   $0ACC
	 pop  de
	 ld   l,(iy+$34)
	 ld   h,(iy+$35)
	 or   a
	 sbc  hl,de
	 push af
	 pop  hl
	 ld   a,l
	 and  $84
	 jp   po,$0ACC
	 set  1,(iy+$12)
	 set  0,(iy+$11)
	 exx
	 bit  0,(iy+$10)
	 jp   z,$0B0D
	 bit  0,(iy+$11)
	 jp   z,$0AFD
	 dec  b
	 dec  c
	 push hl
	 ex   de,hl
	 ld   d,(iy+$27)
	 ld   e,(iy+$26)
	 or   a
	 sbc  hl,de
	 ex   (sp),hl
	 ld   d,(iy+$2f)
	 ld   e,(iy+$2e)
	 or   a
	 sbc  hl,de
	 pop  de
	 res  0,(iy+$11)
	 ld   a,$01
	 or   a
	 jp   $0B0A
	 ld   a,(iy+$12)
	 and  $0F
	 jp   z,$0B09
	 set  0,(iy+$11)
	 xor  a
	 jp   $0B4F
	 bit  0,(iy+$11)
	 jp   z,$0B4E
	 bit  2,(iy+$12)
	 jp   z,$0B24
	 ld   e,(iy+$2c)
	 ld   d,(iy+$2d)
	 jp   $0B31
	 bit  3,(iy+$12)
	 jp   z,$0B31
	 ld   e,(iy+$2a)
	 ld   d,(iy+$2b)
	 bit  0,(iy+$12)
	 jp   z,$0B41
	 ld   l,(iy+$32)
	 ld   h,(iy+$33)
	 jp   $0B4E
	 bit  1,(iy+$12)
	 jp   z,$0B4E
	 ld   l,(iy+$34)
	 ld   h,(iy+$35)
	 xor  a
	 jp   nz,$0A4B
	 ex   af,af'
	 ret
	 ld   bc,$0101
	 rst  $38
	 rst  $38
	 cp   $FD
	 call m,$FAFB
	 ret  m
	 rst  $30
	 push af
	 di
	 pop  af
	 rst  $28
	 db   $ed,$ea
	 rst  $20
	 push hl
	 jp   po,$DCDF
	 ret  c
	 push de
	 pop  de
	 adc  a,$CA
	 add  a,$C2
	 cp   (hl)
	 cp   c
	 or   l
	 or   c
	 xor  h
	 and  a
	 and  d
	 sbc  a,l
	 sbc  a,b
	 sub  e
	 adc  a,(hl)
	 adc  a,c
	 add  a,h
	 ld   a,(hl)
	 ld   a,c
	 ld   (hl),e
	 ld   l,l
	 ld   l,b
	 ld   h,d
	 ld   e,h
	 ld   d,(hl)
	 ld   d,b
	 ld   c,d
	 ld   b,h
	 ld   a,$38
	 ld   ($262C),a
	 rra
	 add  hl,de
	 inc  de
	 dec  c
	 ld   b,$00
	 ld   hl,$0B54
	 ld   d,$00
	 cp   $40
	 jp   nc,$0BA7
	 ld   e,a
	 add  hl,de
	 ld   e,(hl)
	 ld   d,$00
	 jp   $0BD2
	 sub  $40
	 cp   $40
	 jp   nc,$0BB9
	 xor  $3F
	 ld   e,a
	 add  hl,de
	 inc  hl
	 ld   e,(hl)
	 ld   d,$FF
	 jp   $0BD2
	 sub  $40
	 cp   $40
	 jp   nc,$0BC8
	 ld   e,a
	 add  hl,de
	 ld   e,(hl)
	 ld   d,$FF
	 jp   $0BD2
	 sub  $40
	 xor  $3F
	 ld   e,a
	 add  hl,de
	 inc  hl
	 ld   e,(hl)
	 ld   d,$00
	 ld   l,c
	 ld   h,b
	 ld   a,d
	 or   a
	 push af
	 ld   a,e
	 cp   $01
	 jp   z,$0BF2
	 ld   c,e
	 ld   e,$00
	 xor  a
	 ld   b,$10
	 srl  h
	 rr   l
	 jp   nc,$0BEB
	 add  a,c
	 rra
	 rr   e
	 djnz $0BE3
	 ld   h,a
	 ld   l,e
	 pop  af
	 jp   z,$0BFD
	 ld   a,l
	 cpl
	 ld   l,a
	 ld   a,h
	 cpl
	 ld   h,a
	 inc  hl
	 ret
	 ld   a,(iy+$4a)
	 ld   c,(iy+$46)
	 ld   b,(iy+$47)
	 push af
	 push bc
	 call $0B95
	 ld   (iy+$26),l
	 ld   (iy+$27),h
	 pop  bc
	 pop  af
	 push af
	 sub  $40
	 call $0B95
	 ld   (iy+$2e),l
	 ld   (iy+$2f),h
	 ld   c,(iy+$48)
	 ld   b,(iy+$49)
	 ld   a,b
	 or   c
	 jp   z,$0C47
	 pop  af
	 push af
	 push bc
	 call $0B95
	 ld   (iy+$28),l
	 ld   (iy+$29),h
	 pop  bc
	 pop  af
	 sub  $40
	 call $0B95
	 ld   (iy+$30),l
	 ld   (iy+$31),h
	 jp   $0C55
	 pop  af
	 xor  a
	 ld   (iy+$28),a
	 ld   (iy+$29),a
	 ld   (iy+$30),a
	 ld   (iy+$31),a
	 set  4,(iy+$0f)
	 ret
	 ex   af,af'
	 ld   a,b
	 exx
	 ld   b,a
	 ld   a,(iy+$4b)
	 or   a
	 jp   nz,$0C82
	 ld   e,(iy+$48)
	 ld   d,(iy+$49)
	 ld   a,e
	 or   d
	 jp   nz,$0C7F
	 ld   l,(iy+$46)
	 ld   h,(iy+$47)
	 add  hl,de
	 djnz $0C76
	 ld   (iy+$46),l
	 ld   (iy+$47),h
	 jp   $0C90
	 sub  b
	 jp   nc,$0C87
	 xor  a
	 ld   (iy+$4b),a
	 jp   nz,$0C90
	 call $0BFE
	 exx
	 ex   af,af'
	 ret
	 ld   b,$00
	 ld   c,(iy+$0c)
	 cp   c
	 jp   c,$0362
	 sub  c
	 inc  b
	 cp   c
	 jp   nc,$0C9C
	 ld   c,a
	 ld   a,($D089)
	 sub  c
	 ld   (iy+$0b),a
	 ld   c,$00
	 ld   a,(iy+$0f)
	 bit  1,a
	 call nz,$09E1
	 bit  7,a
	 call nz,$09BD
	 bit  5,a
	 jp   nz,$0CDA
	 call $0908
	 bit  4,a
	 jp   z,$0CC9
	 call $0C5A
	 bit  3,a
	 call nz,$0978
	 bit  2,a
	 call nz,$0A4A
	 bit  0,(iy+$25)
	 call nz,$09F5
	 bit  6,a
	 call nz,$0951
	 jp   $0852
	 push iy
	 ld   iy,($D098)
	 ld   hl,$0C93
	 ld   (iy+$07),h
	 ld   (iy+$06),l
	 ld   hl,$079B
	 ld   (iy+$09),h
	 ld   (iy+$08),l
	 ld   (iy+$11),$00
	 ld   (iy+$12),$00
	 xor  a
	 cp   (iy+$0c)
	 jp   nz,$0D0D
	 ld   (iy+$0c),$01
	 jp   $0498
	 xor  e
	 push iy
	 ld   iy,($D098)
	 set  5,(iy+$0f)
	 jp   $0CE8
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$07),h
	 ld   (iy+$06),l
	 jp   $0498
	 push hl
	 ld   hl,($D098)
	 ld   de,$0008
	 add  hl,de
	 pop  de
	 ld   a,i
	 push af
	 di
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 pop  af
	 jp   po,$0D42
	 ei
	 ret
	 rst  $08
	 inc  de
	 inc  de
	 ld   bc,$0410
	 dec  b
	 dec  c
	 inc  d
	 inc  de
	 dec  d
	 ld   d,$06
	 nop
	 inc  bc
	 inc  c
	 rrca
	 jr   nc,$0D89
	 inc  a
	 ccf
	 ret  nz
	 jp   $CFCC
	 ret  p
	 di
	 call m,$E5FF
	 push iy
	 pop  hl
	 push af
	 rra
	 rra
	 rra
	 rra
	 and  $0F
	 ld   d,$00
	 ld   e,a
	 push hl
	 add  hl,de
	 ld   b,(hl)
	 pop  hl
	 pop  af
	 and  $0F
	 ld   e,a
	 add  hl,de
	 ld   c,(hl)
	 pop  hl
	 ret
	 ld   a,b
	 call $0D7F
	 ld   a,c
	 bit  6,(ix+$00)
	 jp   z,$0D94
	 ld   (hl),a
	 dec  hl
	 bit  3,(ix+$00)
	 jp   z,$0D91
	 ld   (hl),a
	 dec  hl
	 jp   $0D9F
	 ld   (hl),a
	 inc  hl
	 bit  3,(ix+$00)
	 jp   z,$0D9F
	 ld   (hl),a
	 inc  hl
	 ret
	 ld   a,b
	 and  $C0
	 jp   nz,$0DAC
	 call MAGIC_DRAW_BITMAP
	 ld   e,$01
	 ret
	 ld   a,c
	 out  ($0C),a
	 ld   a,b
	 out  ($19),a
	 push bc
	 push ix
	 pop  bc
	 ld   ix,$0000
	 add  ix,sp
	 dec  sp
	 dec  sp
	 dec  sp
	 dec  sp
	 ld   iy,$0D50
	 and  $C0
	 rlca
	 rlca
	 rlca
	 ld   (ix-$04),a
	 ld   (ix-$02),c
	 ld   (ix-$01),b
	 ld   a,(ix-$04)
	 ld   (ix-$03),a
	 ld   c,(ix-$02)
	 ld   b,(ix-$01)
	 push de
	 push hl
	 push de
	 ld   a,(bc)
	 inc  bc
	 push bc
	 call $0D60
	 call $0D7A
	 pop  bc
	 pop  de
	 dec  e
	 jp   nz,$0DE0
	 pop  hl
	 ld   de,$0050
	 bit  7,(ix+$00)
	 jp   z,$0E01
	 or   a
	 sbc  hl,de
	 jp   $0E02
	 add  hl,de
	 pop  de
	 dec  (ix-$03)
	 jp   nz,$0DD8
	 dec  d
	 jp   nz,$0DCC
	 pop  de
	 pop  hl
	 pop  bc
	 ret
	 ld   hl,($D098)
	 ld   de,$0046
	 add  hl,de
	 pop  de
	 sra  d
	 rr   e
	 sra  d
	 rr   e
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$004A
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 jp   (iy)
	 push bc
	 push iy
	 ld   iy,($D098)
	 call $0BFE
	 pop  iy
	 pop  bc
	 jp   (iy)
	 pop  de
	 pop  hl
	 push bc
	 ld   a,e
	 ld   c,l
	 ld   b,h
	 call $0B95
	 pop  bc
	 push hl
	 jp   (iy)
	 pop  de
	 pop  hl
	 push bc
	 push iy
	 ld   iy,($D098)
	 ld   a,(iy+$4a)
	 add  a,l
	 ld   (iy+$4a),a
	 ld   (iy+$4b),e
	 ld   c,(iy+$46)
	 ld   b,(iy+$47)
	 push af
	 push bc
	 call $0B95
	 exx
	 pop  bc
	 pop  af
	 sub  $40
	 call $0B95
	 ld   e,(iy+$2e)
	 ld   d,(iy+$2f)
	 or   a
	 sbc  hl,de
	 ld   a,(iy+$4b)
	 sra  h
	 rr   l
	 srl  a
	 jp   nz,$0E7F
	 ld   a,h
	 and  l
	 cp   $FF
	 jp   nz,$0E92
	 ld   hl,$0000
	 ld   (iy+$31),h
	 ld   (iy+$30),l
	 exx
	 ld   e,(iy+$26)
	 ld   d,(iy+$27)
	 or   a
	 sbc  hl,de
	 ld   a,(iy+$4b)
	 sra  h
	 rr   l
	 srl  a
	 jp   nz,$0EA5
	 ld   a,h
	 and  l
	 cp   $FF
	 jp   nz,$0EB8
	 ld   hl,$0000
	 ld   (iy+$29),h
	 ld   (iy+$28),l
	 set  4,(iy+$0f)
	 pop  iy
	 pop  bc
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  7,(hl)
	 ld   de,$FFFE
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  1,(hl)
	 ld   de,$0004
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0011
	 add  hl,de
	 ld   de,$0000
	 bit  4,(hl)
	 jp   z,$0EFD
	 inc  e
	 push de
	 jp   (iy)
	 ld   de,$00A0
	 add  hl,de
	 xor  a
	 sra  h
	 rr   l
	 rra
	 sra  h
	 rr   l
	 rra
	 ld   h,l
	 ld   l,a
	 ret
	 sra  d
	 rr   e
	 sra  d
	 rr   e
	 ret
	 sla  e
	 rl   d
	 sla  e
	 rl   d
	 ret
	 bit  7,h
	 jp   z,$0F2E
	 ld   a,$FF
	 jp   $0F2F
	 xor  a
	 sla  l
	 rl   h
	 rla
	 sla  l
	 rl   h
	 rla
	 ld   l,h
	 ld   h,a
	 or   a
	 ld   de,$00A0
	 sbc  hl,de
	 ret
	 sra  d
	 rr   e
	 sra  d
	 rr   e
	 ld   a,d
	 cpl
	 ld   d,a
	 ld   a,e
	 cpl
	 ld   e,a
	 inc  de
	 ret
	 ld   a,d
	 cpl
	 ld   d,a
	 ld   a,e
	 cpl
	 ld   e,a
	 inc  de
	 sla  e
	 rl   d
	 sla  e
	 rl   d
	 ret
	 call $026A
	 ld   de,$0063
	 add  hl,de
	 xor  a
	 sra  h
	 rr   l
	 rra
	 sra  h
	 rr   l
	 rra
	 ld   h,l
	 ld   l,a
	 ret
	 bit  7,h
	 jp   z,$0F81
	 ld   a,$FF
	 jp   $0F82
	 xor  a
	 sla  l
	 rl   h
	 rla
	 sla  l
	 rl   h
	 rla
	 ld   l,h
	 ld   h,a
	 or   a
	 ld   de,$0063
	 sbc  hl,de
	 call $026A
	 ret
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  2,(hl)
	 inc  hl
	 set  0,(hl)
	 jp   (iy)
	 pop  hl
	 call $0F00
	 push hl
	 ld   hl,($D098)
	 ld   de,$002A
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 pop  hl
	 call $0F00
	 push hl
	 ld   hl,($D098)
	 ld   de,$002C
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 pop  hl
	 call $0F62
	 push hl
	 ld   hl,($D098)
	 ld   de,$0032
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 pop  hl
	 call $0F62
	 push hl
	 ld   hl,($D098)
	 ld   de,$0034
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  3,(hl)
	 inc  hl
	 set  1,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  3,(hl)
	 inc  hl
	 set  2,(hl)
	 jp   (iy)
	 pop  hl
	 call $0F00
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$3c),l
	 ld   (iy+$3d),h
	 set  3,(iy+$0f)
	 set  1,(iy+$10)
	 pop  iy
	 jp   (iy)
	 pop  hl
	 call $0F62
	 push iy
	 ld   iy,($D098)
	 ld   (iy+$3e),l
	 ld   (iy+$3f),h
	 set  3,(iy+$0f)
	 set  2,(iy+$10)
	 pop  iy
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0012
	 add  hl,de
	 ld   de,$0000
	 bit  4,(hl)
	 jp   z,$1052
	 inc  e
	 push de
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0011
	 add  hl,de
	 ld   de,$0000
	 bit  2,(hl)
	 jp   z,$1065
	 inc  e
	 push de
	 jp   (iy)
	 pop  hl
	 ld   de,$003C
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 call $0F24
	 push hl
	 jp   (iy)
	 pop  hl
	 ld   de,$003E
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 call $0F77
	 push hl
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 set  6,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000F
	 add  hl,de
	 res  6,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0015
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   (iy+$41),h
	 ld   (iy+$40),l
	 set  0,(iy+$25)
	 pop  iy
	 jp   (iy)
	 pop  hl
	 push iy
	 ld   iy,($D098)
	 ld   a,(hl)
	 ld   (iy+$43),$00
	 ld   (iy+$42),a
	 set  1,(iy+$25)
	 jp   $10A9
	 ld   hl,($D098)
	 ld   de,$0025
	 add  hl,de
	 ld   a,(hl)
	 and  $F0
	 ld   (hl),a
	 jp   (iy)
	 pop  hl
	 call $0F00
	 push hl
	 ld   hl,($D098)
	 ld   de,$001C
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 pop  hl
	 call $0F62
	 push hl
	 ld   hl,($D098)
	 ld   de,$001E
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0026
	 add  hl,de
	 pop  de
	 call $0F12
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$002E
	 add  hl,de
	 pop  de
	 call $0F42
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 pop  hl
	 ld   de,$001C
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 call $0F24
	 push hl
	 jp   (iy)
	 pop  hl
	 ld   de,$001E
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ex   de,hl
	 call $0F77
	 push hl
	 jp   (iy)
	 pop  hl
	 ld   de,$0026
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 call $0F1B
	 push de
	 jp   (iy)
	 pop  hl
	 ld   de,$002E
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 call $0F52
	 push de
	 jp   (iy)
	 pop  hl
	 ld   de,$0046
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 call $0F1B
	 push de
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0026
	 add  hl,de
	 xor  a
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 ld   de,$0005
	 add  hl,de
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 inc  hl
	 ld   (hl),a
	 jp   (iy)
	 rst  $08
	 dec  bc
	 rla
	 dec  bc
	 jr   $118E
	 ld   hl,($D098)
	 ld   de,$0020
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),d
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001B
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 set  3,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 res  3,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 set  4,(hl)
	 res  5,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 res  4,(hl)
	 set  5,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 set  7,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 set  6,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 set  2,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 res  2,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 res  7,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001A
	 add  hl,de
	 res  6,(hl)
	 jp   (iy)
	 rst  $08
	 add  hl,de
	 ld   a,(de)
	 ld   b,$2A
	 sbc  a,b
	 ret  nc
	 push hl
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$0024
	 add  hl,de
	 set  0,(hl)
	 set  3,(hl)
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000B
	 add  hl,de
	 ld   a,($D089)
	 dec  a
	 ld   (hl),a
	 jp   (iy)
	 pop  hl
	 ld   de,$0004
	 add  hl,de
	 bit  3,(hl)
	 ld   de,$0000
	 jp   z,$1245
	 inc  e
	 push de
	 jp   (iy)
	 push bc
	 ld   bc,($D151)
	 ld   hl,$1321
	 add  hl,bc
	 push hl
	 ld   hl,$2776
	 adc  hl,bc
	 ld   de,($D153)
	 add  hl,de
	 ex   (sp),hl
	 add  hl,bc
	 ex   (sp),hl
	 adc  hl,de
	 ex   (sp),hl
	 add  hl,bc
	 ex   (sp),hl
	 adc  hl,de
	 ex   (sp),hl
	 ld   d,e
	 ld   e,b
	 ld   b,c
	 ld   c,$00
	 add  hl,bc
	 ld   ($D151),hl
	 ex   (sp),hl
	 adc  hl,de
	 ld   ($D153),hl
	 pop  de
	 pop  bc
	 ret
	 push bc
	 exx
	 ld   hl,$0000
	 ld   d,h
	 ld   e,l
	 exx
	 push de
	 pop  bc
	 ex   de,hl
	 ld   hl,$0000
	 srl  b
	 rr   c
	 jp   nc,$1293
	 add  hl,de
	 exx
	 adc  hl,de
	 exx
	 ld   a,b
	 or   c
	 jp   z,$12A5
	 sla  e
	 rl   d
	 exx
	 rl   e
	 rl   d
	 exx
	 jp   $1287
	 exx
	 pop  bc
	 ret
	 push de
	 call $1248
	 pop  de
	 call $1279
	 ret
	 call $1248
	 push hl
	 jp   (iy)
	 call $1248
	 pop  de
	 call $1279
	 push hl
	 jp   (iy)
	 call $0346
	 jp   $036E
	 push iy
	 push bc
	 ld   iy,($D098)
	 ld   hl,$0781
	 call $0D2D
	 ld   hl,$12C1
	 pop  bc
	 jp   $0D24
	 push bc
	 push ix
	 push iy
	 ld   a,i
	 push af
	 di
	 ld   iy,($D098)
	 ld   d,(iy+$1d)
	 ld   e,(iy+$1c)
	 ld   h,(iy+$1f)
	 ld   l,(iy+$1e)
	 call $07DA
	 call $0755
	 pop  af
	 jp   po,$12FF
	 ei
	 pop  iy
	 pop  ix
	 pop  bc
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$000C
	 add  hl,de
	 pop  de
	 ld   (hl),e
	 jp   (iy)
; $1311–$13B9: TERSE colon program and inline operands.
; $13BA–$13C3: ten padding bytes before 8x10 character font.
TERSE_COLON_1311:
	 RST $08
TERSE_THREAD_1312:
	 DB $1B ; $1312 token $1B => native $0050
	 DW $032E ; inline 16-bit literal
	 DB $1B ; $1315 token $1B => native $0050
	 DW $D09F ; inline 16-bit literal
	 DB $10 ; $1318 token $10 => native $00AB
	 DB $1B ; $1319 token $1B => native $0050
	 DW $D098 ; inline 16-bit literal
	 DB $1C ; $131C token $1C => native $00B7
	 DB $1B ; $131D token $1B => native $0050
	 DW $04D8 ; inline 16-bit literal
	 DB $1B ; $1320 token $1B => native $0050
	 DW $D084 ; inline 16-bit literal
	 DB $10 ; $1323 token $10 => native $00AB
	 DB $0E ; $1324 token $0E => native $0059
	 DB $64 ; inline byte
	 DB $1B ; $1326 token $1B => native $0050
	 DW $D088 ; inline 16-bit literal
	 DB $08 ; $1329 token $08 => native $00B2
	 DB $1B ; $132A token $1B => native $0050
	 DW $D091 ; inline 16-bit literal
	 DB $1D ; $132D token $1D => native $0266
	 DB $1B ; $132E token $1B => native $0050
	 DW $D092 ; inline 16-bit literal
	 DB $1D ; $1331 token $1D => native $0266
	 DB $1B ; $1332 token $1B => native $0050
	 DW $05F2 ; inline 16-bit literal
	 DB $1B ; $1335 token $1B => native $0050
	 DW $D080 ; inline 16-bit literal
	 DB $10 ; $1338 token $10 => native $00AB
	 DB $0E ; $1339 token $0E => native $0059
	 DB $C8 ; inline byte
	 DB $1B ; $133B token $1B => native $0050
	 DW $D086 ; inline 16-bit literal
	 DB $08 ; $133E token $08 => native $00B2
	 DB $1B ; $133F token $1B => native $0050
	 DW $D090 ; inline 16-bit literal
	 DB $1D ; $1342 token $1D => native $0266
	 DB $1B ; $1343 token $1B => native $0050
	 DW $D093 ; inline 16-bit literal
	 DB $1D ; $1346 token $1D => native $0266
	 DB $1B ; $1347 token $1B => native $0050
	 DW $0673 ; inline 16-bit literal
	 DB $1B ; $134A token $1B => native $0050
	 DW $D082 ; inline 16-bit literal
	 DB $10 ; $134D token $10 => native $00AB
	 DB $0E ; $134E token $0E => native $0059
	 DB $32 ; inline byte
	 DB $1B ; $1350 token $1B => native $0050
	 DW $D087 ; inline 16-bit literal
	 DB $08 ; $1353 token $08 => native $00B2
	 DB $1B ; $1354 token $1B => native $0050
	 DW $D095 ; inline 16-bit literal
	 DB $1D ; $1357 token $1D => native $0266
	 DB $0E ; $1358 token $0E => native $0059
	 DB $19 ; inline byte
	 DB $1B ; $135A token $1B => native $0050
	 DW $D08F ; inline 16-bit literal
	 DB $08 ; $135D token $08 => native $00B2
	 DB $1B ; $135E token $1B => native $0050
	 DW $D089 ; inline 16-bit literal
	 DB $1D ; $1361 token $1D => native $0266
	 DB $1B ; $1362 token $1B => native $0050
	 DW $D096 ; inline 16-bit literal
	 DB $1D ; $1365 token $1D => native $0266
	 DB $1B ; $1366 token $1B => native $0050
	 DW $D097 ; inline 16-bit literal
	 DB $1D ; $1369 token $1D => native $0266
	 DB $1B ; $136A token $1B => native $0050
	 DW $0336 ; inline 16-bit literal
	 DB $1E ; $136D token $1E => native $027E
	 DB $1B ; $136E token $1B => native $0050
	 DW $033A ; inline 16-bit literal
	 DB $1E ; $1371 token $1E => native $027E
	 DB $1B ; $1372 token $1B => native $0050
	 DW $033E ; inline 16-bit literal
	 DB $1E ; $1375 token $1E => native $027E
	 DB $1B ; $1376 token $1B => native $0050
	 DW $0342 ; inline 16-bit literal
	 DB $1E ; $1379 token $1E => native $027E
	 DB $0E ; $137A token $0E => native $0059
	 DB $28 ; inline byte
	 DB $0E ; $137C token $0E => native $0059
	 DB $09 ; inline byte
	 DB $1F ; $137E token $1F => native $01D1
	 DB $09 ; $137F token $09 => native $0081
	 DB $0E ; $1380 token $0E => native $0059
	 DB $08 ; inline byte
	 DB $1F ; $1382 token $1F => native $01D1
	 DB $0E ; $1383 token $0E => native $0059
	 DB $4A ; inline byte
	 DB $1B ; $1385 token $1B => native $0050
	 DW $D08D ; inline 16-bit literal
	 DB $08 ; $1388 token $08 => native $00B2
	 DB $0E ; $1389 token $0E => native $0059
	 DB $F5 ; inline byte
	 DB $1B ; $138B token $1B => native $0050
	 DW $D08A ; inline 16-bit literal
	 DB $08 ; $138E token $08 => native $00B2
	 DB $0E ; $138F token $0E => native $0059
	 DB $07 ; inline byte
	 DB $1B ; $1391 token $1B => native $0050
	 DW $D08B ; inline 16-bit literal
	 DB $08 ; $1394 token $08 => native $00B2
	 DB $0E ; $1395 token $0E => native $0059
	 DB $94 ; inline byte
	 DB $1B ; $1397 token $1B => native $0050
	 DW $D08C ; inline 16-bit literal
	 DB $08 ; $139A token $08 => native $00B2
	 DB $1B ; $139B token $1B => native $0050
	 DW $D08E ; inline 16-bit literal
	 DB $1D ; $139E token $1D => native $0266
	 DB $0E ; $139F token $0E => native $0059
	 DB $C8 ; inline byte
	 DB $0E ; $13A1 token $0E => native $0059
	 DB $0A ; inline byte
	 DB $1F ; $13A3 token $1F => native $01D1
	 DB $0E ; $13A4 token $0E => native $0059
	 DB $70 ; inline byte
	 DB $0E ; $13A6 token $0E => native $0059
	 DB $04 ; inline byte
	 DB $1F ; $13A8 token $1F => native $01D1
	 DB $0E ; $13A9 token $0E => native $0059
	 DB $53 ; inline byte
	 DB $0E ; $13AB token $0E => native $0059
	 DB $05 ; inline byte
	 DB $1F ; $13AD token $1F => native $01D1
	 DB $0E ; $13AE token $0E => native $0059
	 DB $E6 ; inline byte
	 DB $0E ; $13B0 token $0E => native $0059
	 DB $06 ; inline byte
	 DB $1F ; $13B2 token $1F => native $01D1
	 DB $0E ; $13B3 token $0E => native $0059
	 DB $6F ; inline byte
	 DB $0E ; $13B5 token $0E => native $0059
	 DB $07 ; inline byte
	 DB $1F ; $13B7 token $1F => native $01D1
	 DB $20 ; $13B8 token $20 => native $05E5
	 DB $06 ; $13B9 token $06 => native $0044
TERSE_FONT_PADDING:
	 DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
; $13C4-$1535: 8x10 monochrome character bitmaps.
; Each glyph consists of ten rows; bit 7 is the leftmost pixel.
SCREEN_FONT_8X10:
; $13C4  0  (8 x 10)
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
; $13CE  1  (8 x 10)
FONT_DIGIT_1:
	 DB $18 ; ...##...
	 DB $38 ; ..###...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $3C ; ..####..
	 DB $3C ; ..####..
; $13D8  2  (8 x 10)
FONT_DIGIT_2:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $06 ; .....##.
	 DB $3E ; ..#####.
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7E ; .######.
	 DB $7E ; .######.
; $13E2  3  (8 x 10)
FONT_DIGIT_3:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $06 ; .....##.
	 DB $1C ; ...###..
	 DB $1E ; ...####.
	 DB $06 ; .....##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $13EC  4  (8 x 10)
FONT_DIGIT_4:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
; $13F6  5  (8 x 10)
FONT_DIGIT_5:
	 DB $7C ; .#####..
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $06 ; .....##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $1400  6  (8 x 10)
FONT_DIGIT_6:
	 DB $3C ; ..####..
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $140A  7  (8 x 10)
FONT_DIGIT_7:
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $06 ; .....##.
	 DB $0E ; ....###.
	 DB $0C ; ....##..
	 DB $1C ; ...###..
	 DB $18 ; ...##...
	 DB $38 ; ..###...
	 DB $30 ; ..##....
	 DB $30 ; ..##....
; $1414  8  (8 x 10)
FONT_DIGIT_8:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $141E  9  (8 x 10)
FONT_DIGIT_9:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3E ; ..#####.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $3E ; ..#####.
	 DB $3C ; ..####..
; $1428  @  (8 x 10)
FONT_SYMBOL_AT:
	 DB $3C ; ..####..
	 DB $42 ; .#....#.
	 DB $99 ; #..##..#
	 DB $A5 ; #.#..#.#
	 DB $A1 ; #.#....#
	 DB $A1 ; #.#....#
	 DB $A5 ; #.#..#.#
	 DB $99 ; #..##..#
	 DB $42 ; .#....#.
	 DB $3C ; ..####..
; $1432  A  (8 x 10)
FONT_LETTER_A:
	 DB $18 ; ...##...
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $143C  B  (8 x 10)
FONT_LETTER_B:
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7C ; .#####..
; $1446  C  (8 x 10)
FONT_LETTER_C:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $1450  D  (8 x 10)
FONT_LETTER_D:
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7C ; .#####..
; $145A  E  (8 x 10)
FONT_LETTER_E:
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7C ; .#####..
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7E ; .######.
	 DB $7E ; .######.
; $1464  F  (8 x 10)
FONT_LETTER_F:
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7C ; .#####..
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
; $146E  G  (8 x 10)
FONT_LETTER_G:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $6E ; .##.###.
	 DB $6E ; .##.###.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $1478  H  (8 x 10)
FONT_LETTER_H:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $1482  I  (8 x 10)
FONT_LETTER_I:
	 DB $3C ; ..####..
	 DB $3C ; ..####..
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $3C ; ..####..
	 DB $3C ; ..####..
; $148C  J  (8 x 10)
FONT_LETTER_J:
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $06 ; .....##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $1496  K  (8 x 10)
FONT_LETTER_K:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $6E ; .##.###.
	 DB $7C ; .#####..
	 DB $78 ; .####...
	 DB $78 ; .####...
	 DB $6C ; .##.##..
	 DB $6E ; .##.###.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $14A0  L  (8 x 10)
FONT_LETTER_L:
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $7E ; .######.
	 DB $7E ; .######.
; $14AA  M  (8 x 10)
FONT_LETTER_M:
	 DB $C3 ; ##....##
	 DB $E7 ; ###..###
	 DB $E7 ; ###..###
	 DB $DB ; ##.##.##
	 DB $DB ; ##.##.##
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
; $14B4  N  (8 x 10)
FONT_LETTER_N:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $76 ; .###.##.
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $6E ; .##.###.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $14BE  O  (8 x 10)
FONT_LETTER_O:
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
; $14C8  P  (8 x 10)
FONT_LETTER_P:
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7C ; .#####..
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
	 DB $60 ; .##.....
; $14D2  Q  (8 x 10)
FONT_LETTER_Q:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $6E ; .##.###.
	 DB $64 ; .##..#..
	 DB $3A ; ..###.#.
; $14DC  R  (8 x 10)
FONT_LETTER_R:
	 DB $7C ; .#####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $7C ; .#####..
	 DB $6E ; .##.###.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $14E6  S  (8 x 10)
FONT_LETTER_S:
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $60 ; .##.....
	 DB $7C ; .#####..
	 DB $3E ; ..#####.
	 DB $06 ; .....##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $14F0  T  (8 x 10)
FONT_LETTER_T:
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
; $14FA  U  (8 x 10)
FONT_LETTER_U:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
; $1504  V  (8 x 10)
FONT_LETTER_V:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
	 DB $3C ; ..####..
	 DB $18 ; ...##...
	 DB $18 ; ...##...
; $150E  W  (8 x 10)
FONT_LETTER_W:
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
	 DB $DB ; ##.##.##
	 DB $DB ; ##.##.##
	 DB $DB ; ##.##.##
	 DB $FF ; ########
	 DB $E7 ; ###..###
	 DB $C3 ; ##....##
	 DB $C3 ; ##....##
; $1518  X  (8 x 10)
FONT_LETTER_X:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $3C ; ..####..
	 DB $7E ; .######.
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
; $1522  Y  (8 x 10)
FONT_LETTER_Y:
	 DB $66 ; .##..##.
	 DB $66 ; .##..##.
	 DB $7E ; .######.
	 DB $3C ; ..####..
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
	 DB $18 ; ...##...
; $152C  Z  (8 x 10)
FONT_LETTER_Z:
	 DB $7E ; .######.
	 DB $7E ; .######.
	 DB $06 ; .....##.
	 DB $0E ; ....###.
	 DB $1C ; ...###..
	 DB $38 ; ..###...
	 DB $70 ; .###....
	 DB $60 ; .##.....
	 DB $7E ; .######.
	 DB $7E ; .######.
	 sbc  a,(hl)
	 push ix
	 push iy
	 push bc
	 ld   iy,($D098)
	 set  3,(iy+$1a)
	 ld   c,(iy+$1a)
	 ld   e,(iy+$1c)
	 ld   d,(iy+$1d)
	 ld   l,(iy+$1e)
	 ld   h,(iy+$1f)
	 call $071F
	 bit  6,(iy+$1a)
	 jp   z,$155E
	 dec  hl
	 ld   e,(iy+$20)
	 ld   d,(iy+$21)
	 ld   a,(de)
	 ld   b,a
	 inc  de
	 ld   a,(de)
	 push bc
	 push de
	 push hl
	 push hl
	 cp   $30
	 jp   nc,$1576
	 sub  $20
	 jp   $1582
	 cp   $40
	 jp   nc,$1580
	 sub  $2F
	 jp   $1582
	 sub  $35
	 ld   l,a
	 ld   h,$00
	 ld   e,l
	 ld   d,h
	 add  hl,de
	 add  hl,hl
	 add  hl,de
	 bit  5,(iy+$1b)
	 jp   nz,$159C
	 add  hl,hl
	 ld   de,$13BA
	 add  hl,de
	 ld   de,$0A01
	 jp   $15A3
	 ld   de,$1537
	 add  hl,de
	 ld   de,$0501
	 push hl
	 pop  ix
	 ld   b,(iy+$1b)
	 ld   c,(iy+$1a)
	 pop  hl
	 push iy
	 ld   a,i
	 push af
	 di
	 call $0DA0
	 pop  af
	 jp   po,$15BB
	 ei
	 pop  iy
	 ld   a,e
	 pop  hl
	 pop  de
	 pop  bc
	 inc  de
	 dec  b
	 jp   z,$15E9
	 bit  5,(iy+$1b)
	 jp   nz,$15CE
	 add  a,a
	 bit  6,(iy+$1a)
	 jp   nz,$15DE
	 add  a,l
	 ld   l,a
	 jp   nc,$15DB
	 inc  h
	 jp   $15E6
	 ld   c,a
	 ld   a,l
	 sub  c
	 ld   l,a
	 jp   nc,$15E6
	 dec  h
	 jp   $1567
	 pop  bc
	 pop  iy
	 pop  ix
	 jp   (iy)
	 ld   bc,$0000
	 nop
	 ld   a,(bc)
	 nop
	 nop
	 nop
	 ld   h,h
	 nop
	 nop
	 nop
	 ret  pe
	 inc  bc
	 nop
	 nop
	 djnz $1629
	 nop
	 nop
	 and  b
	 add  a,(hl)
	 ld   bc,$4000
	 ld   b,d
	 rrca
	 nop
	 add  a,b
	 sub  (hl)
	 sbc  a,b
	 nop
	 nop
	 pop  hl
	 push af
	 dec  b
	 nop
	 jp   z,$3B9A
	 xor  a
	 add  a,h
	 ld   a,$2B
	 jp   p,$1634
	 ld   de,$0000
	 exx
	 ld   de,$0000
	 exx
	 ex   de,hl
	 exx
	 ex   de,hl
	 exx
	 exx
	 or   a
	 sbc  hl,de
	 exx
	 sbc  hl,de
	 ld   a,$2D
	 ld   (iy+$00),a
	 inc  iy
	 ld   de,$15EC
	 push bc
	 pop  ix
	 add  ix,ix
	 add  ix,ix
	 add  ix,de
	 ld   d,(ix+$03)
	 ld   e,(ix+$02)
	 exx
	 ld   d,(ix+$01)
	 ld   e,(ix+$00)
	 exx
	 ld   a,$30
	 ld   b,$0A
	 exx
	 or   a
	 sbc  hl,de
	 exx
	 sbc  hl,de
	 jp   m,$1665
	 inc  a
	 djnz $1657
	 dec  a
	 exx
	 add  hl,de
	 exx
	 adc  hl,de
	 ld   (iy+$00),a
	 inc  iy
	 ld   de,$FFFC
	 add  ix,de
	 dec  c
	 jp   nz,$1645
	 ret
	 exx
	 pop  bc
	 pop  de
	 pop  hl
	 exx
	 pop  hl
	 push bc
	 push ix
	 push iy
	 exx
	 push de
	 pop  iy
	 call $1618
	 pop  iy
	 pop  ix
	 pop  bc
	 jp   (iy)
	 pop  hl
	 ld   e,(hl)
	 inc  hl
	 ld   a,e
	 cp   $01
	 jp   z,$16A9
	 ld   a,(hl)
	 cp   $30
	 jp   nz,$16A8
	 ld   (hl),$20
	 inc  hl
	 dec  e
	 jp   $16A9
	 xor  a
	 jp   nz,$1695
	 jp   (iy)
;*******************************************************************************
; SPRITE OBJECT RECORDS - PACKED 2BPP
;*******************************************************************************
;   +0  Horizontal hotspot offset
;   +1  Vertical hotspot offset
;   +2  Bitmap width in bytes
;   +3  Bitmap height in rows
;   +4  Packed 2bpp bitmap data
;
; Each bitmap byte stores four pixels, most-significant pair first. The shared
; object draw path advances past the two hotspot bytes before reading the
; width/height header.
; Inline pixels use "." for value 0 and "1" through "3" for the color index.
;*******************************************************************************
;*******************************************************************************
; ALIEN_SHIP_DESTROY_1
;
; Alien ship destruction animation, frame 1.
; Object record: $16AE; bitmap header: $16B0.
; Hotspot offsets: X = 16, Y = 4.
; Bitmap: 20 x 10 pixels, 5 bytes per row.
;*******************************************************************************
ALIEN_SHIP_DESTROY_1:
        DB      $10,$04 ; Hotspot offsets: X = 16, Y = 4

ALIEN_SHIP_DESTROY_1_HEADER:
        DB      $05,$0A ; Bitmap size: 5 bytes/row, 10 rows
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
        DB      $00,$05,$40,$00,$00 ; . . . . . . 1 1 1 . . . . . . . . . . .
        DB      $00,$24,$78,$00,$00 ; . . . . . 2 1 . 1 3 2 . . . . . . . . .
        DB      $00,$15,$58,$00,$00 ; . . . . . 1 1 1 1 1 2 . . . . . . . . .
        DB      $00,$27,$E8,$00,$00 ; . . . . . 2 1 3 3 2 2 . . . . . . . . .
        DB      $00,$64,$90,$00,$00 ; . . . . 1 2 1 . 2 1 . . . . . . . . . .
        DB      $00,$46,$18,$00,$00 ; . . . . 1 . 1 2 . 1 2 . . . . . . . . .
        DB      $00,$08,$00,$00,$00 ; . . . . . . 2 . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
;*******************************************************************************
; ALIEN_SHIP_DESTROY_2
;
; Alien ship destruction animation, frame 2.
; Object record: $16E4; bitmap header: $16E6.
; Hotspot offsets: X = 16, Y = 4.
; Bitmap: 20 x 10 pixels, 5 bytes per row.
;*******************************************************************************
ALIEN_SHIP_DESTROY_2:
        DB      $10,$04 ; Hotspot offsets: X = 16, Y = 4

ALIEN_SHIP_DESTROY_2_HEADER:
        DB      $05,$0A ; Bitmap size: 5 bytes/row, 10 rows
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
        DB      $00,$81,$0C,$00,$00 ; . . . . 2 . . 1 . . 3 . . . . . . . . .
        DB      $00,$41,$10,$E0,$00 ; . . . . 1 . . 1 . 1 . . 3 2 . . . . . .
        DB      $00,$00,$00,$18,$00 ; . . . . . . . . . . . . . 1 2 . . . . .
        DB      $0F,$70,$21,$F8,$00 ; . . 3 3 1 3 . . . 2 . 1 3 3 2 . . . . .
        DB      $00,$0E,$10,$33,$00 ; . . . . . . 3 2 . 1 . . . 3 . 3 . . . .
        DB      $01,$F3,$0C,$C7,$00 ; . . . 1 3 3 . 3 . . 3 . 3 . 1 3 . . . .
        DB      $0C,$43,$1C,$F0,$00 ; . . 3 . 1 . . 3 . 1 3 . 3 3 . . . . . .
        DB      $30,$82,$0E,$30,$00 ; . 3 . . 2 . . 2 . . 3 2 . 3 . . . . . .
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
;*******************************************************************************
; ALIEN_SHIP_DESTROY_3
;
; Alien ship destruction animation, frame 3.
; Object record: $171A; bitmap header: $171C.
; Hotspot offsets: X = 16, Y = 4.
; Bitmap: 20 x 10 pixels, 5 bytes per row.
;*******************************************************************************
ALIEN_SHIP_DESTROY_3:
        DB      $10,$04 ; Hotspot offsets: X = 16, Y = 4

ALIEN_SHIP_DESTROY_3_HEADER:
        DB      $05,$0A ; Bitmap size: 5 bytes/row, 10 rows
        DB      $00,$80,$02,$00,$00 ; . . . . 2 . . . . . . 2 . . . . . . . .
        DB      $00,$01,$00,$02,$00 ; . . . . . . . 1 . . . . . . . 2 . . . .
        DB      $00,$40,$10,$10,$00 ; . . . . 1 . . . . 1 . . . 1 . . . . . .
        DB      $00,$04,$04,$00,$00 ; . . . . . . 1 . . . 1 . . . . . . . . .
        DB      $90,$02,$01,$20,$08 ; 2 1 . . . . . 2 . . . 1 . 2 . . . . 2 .
        DB      $00,$40,$10,$24,$00 ; . . . . 1 . . . . 1 . . . 2 1 . . . . .
        DB      $01,$10,$08,$01,$00 ; . . . 1 . 1 . . . . 2 . . . . 1 . . . .
        DB      $20,$04,$08,$08,$00 ; . 2 . . . . 1 . . . 2 . . . 2 . . . . .
        DB      $08,$02,$00,$04,$00 ; . . 2 . . . . 2 . . . . . . 1 . . . . .
        DB      $04,$02,$00,$00,$10 ; . . 1 . . . . 2 . . . . . . . . . 1 . .
 
;*******************************************************************************
; ALIEN_SHIP_DESTROY_4
;
; Alien ship destruction animation, frame 4.
; Object record: $1750; bitmap header: $1752.
; Hotspot offsets: X = 16, Y = 4.
; Bitmap: 20 x 10 pixels, 5 bytes per row.
;*******************************************************************************
ALIEN_SHIP_DESTROY_4:
        DB      $10,$04 ; Hotspot offsets: X = 16, Y = 4

ALIEN_SHIP_DESTROY_4_HEADER:
        DB      $05,$0A ; Bitmap size: 5 bytes/row, 10 rows
        DB      $00,$02,$00,$00,$08 ; . . . . . . . 2 . . . . . . . . . . 2 .
        DB      $02,$00,$00,$00,$00 ; . . . 2 . . . . . . . . . . . . . . . .
        DB      $00,$00,$04,$00,$00 ; . . . . . . . . . . 1 . . . . . . . . .
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
        DB      $08,$00,$00,$01,$00 ; . . 2 . . . . . . . . . . . . 1 . . . .
        DB      $00,$04,$00,$00,$00 ; . . . . . . 1 . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$40,$01,$00 ; . . . . . . . . 1 . . . . . . 1 . . . .
        DB      $00,$10,$00,$00,$00 ; . . . . . 1 . . . . . . . . . . . . . .
        DB      $80,$00,$00,$80,$00 ; 2 . . . . . . . . . . . 2 . . . . . . .
;*******************************************************************************
; BLANK
;
; Blank replacement object used to remove an animated frame.
; Object record: $1786; bitmap header: $1788.
; Hotspot offsets: X = 0, Y = 0.
; Bitmap: 4 x 1 pixels, 1 byte per row.
;*******************************************************************************
BLANK:
        DB      $00,$00 ; Hotspot offsets: X = 0, Y = 0
BLANK_HEADER:
        DB      $01,$01 ; Bitmap size: 1 byte/row, 1 row
        DB      $00 ; . . . .
; Alien ship destruction-frame sequence. Each entry is a control byte
; followed by a pointer to a complete sprite object record.
ALIEN_SHIP_DESTROY_SEQUENCE:
        DB      $09
        DW      ALIEN_SHIP_DESTROY_1
        DB      $08
        DW      ALIEN_SHIP_DESTROY_2
        DB      $06
        DW      ALIEN_SHIP_DESTROY_3
        DB      $06
        DW      ALIEN_SHIP_DESTROY_4
        DB      $FF
        DW      BLANK
        DB      $00
        DW      ALIEN_SHIP_DESTROY_SEQUENCE
;*******************************************************************************
; ALIEN_SHIP_VERTICAL
;
; Alien ship oriented for vertical approaches.
; Object record: $179D; bitmap header: $179F.
; Hotspot offsets: X = 8, Y = 6.
; Bitmap: 8 x 12 pixels, 2 bytes per row.
;*******************************************************************************
ALIEN_SHIP_VERTICAL:
        DB      $08,$06 ; Hotspot offsets: X = 8, Y = 6

ALIEN_SHIP_VERTICAL_HEADER:
        DB      $02,$0C ; Bitmap size: 2 bytes/row, 12 rows
        DB      $40,$00 ; 1 . . . . . . .
        DB      $30,$00 ; . 3 . . . . . .
        DB      $1A,$00 ; . 1 2 2 . . . .
        DB      $0E,$00 ; . . 3 2 . . . .
        DB      $3A,$00 ; . 3 2 2 . . . .
        DB      $FE,$00 ; 3 3 3 2 . . . .
        DB      $FE,$00 ; 3 3 3 2 . . . .
        DB      $3A,$00 ; . 3 2 2 . . . .
        DB      $0E,$00 ; . . 3 2 . . . .
        DB      $1A,$00 ; . 1 2 2 . . . .
        DB      $30,$00 ; . 3 . . . . . .
        DB      $40,$00 ; 1 . . . . . . .
;*******************************************************************************
; ALIEN_SHIP_HORIZONTAL
;
; Alien ship oriented for horizontal approaches.
; Object record: $17B9; bitmap header: $17BB.
; Hotspot offsets: X = 7, Y = 8.
; Bitmap: 12 x 7 pixels, 3 bytes per row.
;*******************************************************************************
ALIEN_SHIP_HORIZONTAL:
        DB      $07,$08 ; Hotspot offsets: X = 7, Y = 8

ALIEN_SHIP_HORIZONTAL_HEADER:
        DB      $03,$07 ; Bitmap size: 3 bytes/row, 7 rows
        DB      $03,$00,$00 ; . . . 3 . . . . . . . .
        DB      $83,$04,$00 ; 2 . . 3 . . 1 . . . . .
        DB      $4F,$C8,$00 ; 1 . 3 3 3 . 2 . . . . .
        DB      $6F,$D8,$00 ; 1 2 3 3 3 1 2 . . . . .
        DB      $3F,$F0,$00 ; . 3 3 3 3 3 . . . . . .
        DB      $17,$A0,$00 ; . 1 1 3 2 2 . . . . . .
        DB      $3F,$F0,$00 ; . 3 3 3 3 3 . . . . . .
	 nop
	 ld   bc,$021D
	 rst  $38
	 ld   bc,$0100
	 jr   c,$17CC
;*******************************************************************************
; LASER_BASE_BODY
;
; Intact center laser-base body.
; Object record: $17DC; bitmap header: $17DE.
; Hotspot offsets: X = 0, Y = 0.
; Bitmap: 24 x 21 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_BODY:
        DB      $00,$00 ; Hotspot offsets: X = 0, Y = 0

LASER_BASE_BODY_HEADER:
        DB      $06,$15 ; Bitmap size: 6 bytes/row, 21 rows
        DB      $55,$55,$55,$5A,$40,$00 ; 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 1 . . . . . . .
        DB      $5F,$FD,$FF,$5A,$40,$00 ; 1 1 3 3 3 3 3 1 3 3 3 3 1 1 2 2 1 . . . . . . .
        DB      $77,$FF,$7F,$DA,$40,$00 ; 1 3 1 3 3 3 3 3 1 3 3 3 3 1 2 2 1 . . . . . . .
        DB      $7D,$FF,$DF,$DA,$40,$00 ; 1 3 3 1 3 3 3 3 3 1 3 3 3 1 2 2 1 . . . . . . .
        DB      $7F,$7F,$FF,$DA,$40,$00 ; 1 3 3 3 1 3 3 3 3 3 3 3 3 1 2 2 1 . . . . . . .
        DB      $7F,$DF,$FF,$DA,$40,$00 ; 1 3 3 3 3 1 3 3 3 3 3 3 3 1 2 2 1 . . . . . . .
        DB      $7F,$FF,$FF,$DA,$40,$00 ; 1 3 3 3 3 3 3 3 3 3 3 3 3 1 2 2 1 . . . . . . .
        DB      $7F,$FF,$FF,$DA,$40,$00 ; 1 3 3 3 3 3 3 3 3 3 3 3 3 1 2 2 1 . . . . . . .
        DB      $7F,$FF,$FF,$DA,$50,$00 ; 1 3 3 3 3 3 3 3 3 3 3 3 3 1 2 2 1 1 . . . . . .
        DB      $7F,$FF,$FF,$DA,$94,$00 ; 1 3 3 3 3 3 3 3 3 3 3 3 3 1 2 2 2 1 1 . . . . .
        DB      $7F,$FF,$FF,$D6,$A5,$00 ; 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 2 2 2 1 1 . . . .
        DB      $7F,$FF,$FF,$55,$A9,$40 ; 1 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 2 2 2 1 1 . . .
        DB      $57,$FF,$FD,$D5,$6A,$40 ; 1 1 1 3 3 3 3 3 3 3 3 1 3 1 1 1 1 2 2 2 1 . . .
        DB      $55,$55,$55,$75,$5A,$40 ; 1 1 1 1 1 1 1 1 1 1 1 1 1 3 1 1 1 1 2 2 1 . . .
        DB      $AA,$AA,$A5,$5D,$5A,$40 ; 2 2 2 2 2 2 2 2 2 2 1 1 1 1 3 1 1 1 2 2 1 . . .
        DB      $AA,$AA,$A9,$57,$5A,$40 ; 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 3 1 1 2 2 1 . . .
        DB      $55,$55,$6A,$55,$DA,$40 ; 1 1 1 1 1 1 1 1 1 2 2 2 1 1 1 1 3 1 2 2 1 . . .
        DB      $00,$00,$5A,$95,$5A,$40 ; . . . . . . . . 1 1 2 2 2 1 1 1 1 1 2 2 1 . . .
        DB      $00,$00,$16,$AA,$AA,$40 ; . . . . . . . . . 1 1 2 2 2 2 2 2 2 2 2 1 . . .
        DB      $00,$00,$05,$AA,$AA,$40 ; . . . . . . . . . . 1 1 2 2 2 2 2 2 2 2 1 . . .
        DB      $00,$00,$01,$55,$55,$40 ; . . . . . . . . . . . 1 1 1 1 1 1 1 1 1 1 . . .
;*******************************************************************************
; LASER_BASE_BODY_DESTROY
;
; Damaged center laser-base body.
; Object record: $185E; bitmap header: $1860.
; Hotspot offsets: X = 0, Y = 0.
; Bitmap: 24 x 21 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_BODY_DESTROY:
        DB      $00,$00 ; Hotspot offsets: X = 0, Y = 0

LASER_BASE_BODY_DESTROY_HEADER:
        DB      $06,$15 ; Bitmap size: 6 bytes/row, 21 rows
        DB      $00,$00,$00,$08,$D0,$00 ; . . . . . . . . . . . . . . 2 . 3 1 . . . . . .
        DB      $00,$00,$00,$04,$20,$C0 ; . . . . . . . . . . . . . . 1 . . 2 . . 3 . . .
        DB      $00,$00,$00,$43,$20,$00 ; . . . . . . . . . . . . 1 . . 3 . 2 . . . . . .
        DB      $00,$00,$00,$04,$00,$00 ; . . . . . . . . . . . . . . 1 . . . . . . . . .
        DB      $00,$00,$00,$23,$00,$00 ; . . . . . . . . . . . . . 2 . 3 . . . . . . . .
        DB      $00,$00,$00,$20,$C0,$00 ; . . . . . . . . . . . . . 2 . . 3 . . . . . . .
        DB      $00,$00,$08,$0C,$F0,$00 ; . . . . . . . . . . 2 . . . 3 . 3 3 . . . . . .
        DB      $00,$08,$0C,$30,$40,$40 ; . . . . . . 2 . . . 3 . . 3 . . 1 . . . 1 . . .
        DB      $00,$00,$0D,$23,$01,$00 ; . . . . . . . . . . 3 1 . 2 . 3 . . . 1 . . . .
        DB      $00,$00,$00,$C2,$01,$00 ; . . . . . . . . . . . . 3 . . 2 . . . 1 . . . .
        DB      $00,$00,$0C,$20,$40,$40 ; . . . . . . . . . . 3 . . 2 . . 1 . . . 1 . . .
        DB      $00,$0C,$20,$50,$FD,$00 ; . . . . . . 3 . . 2 . . 1 1 . . 3 3 3 1 . . . .
        DB      $00,$00,$01,$10,$63,$40 ; . . . . . . . . . . . 1 . 1 . . 1 2 . 3 1 . . .
        DB      $00,$B2,$9C,$8A,$8A,$00 ; . . . . 2 3 . 2 2 1 3 . 2 . 2 2 2 . 2 2 . . . .
        DB      $00,$E0,$50,$20,$20,$00 ; . . . . 3 2 . . 1 1 . . . 2 . . . 2 . . . . . .
        DB      $23,$C8,$7C,$20,$00,$00 ; . 2 . 3 3 . 2 . 1 3 3 . . 2 . . . . . . . . . .
        DB      $67,$CB,$30,$0C,$00,$00 ; 1 2 1 3 3 . 2 3 . 3 . . . . 3 . . . . . . . . .
        DB      $31,$01,$50,$00,$00,$00 ; . 3 . 1 . . . 1 1 1 . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$40,$00,$00,$00,$00 ; . . . . 1 . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
;*******************************************************************************
; LASER_TURRET_VERTICAL
;
; Laser turret oriented vertically.
; Object record: $18E0; bitmap header: $18E2.
; Hotspot offsets: X = 7, Y = 9.
; Bitmap: 20 x 19 pixels, 5 bytes per row.
;*******************************************************************************
LASER_TURRET_VERTICAL:
        DB      $07,$09 ; Hotspot offsets: X = 7, Y = 9

LASER_TURRET_VERTICAL_HEADER:
        DB      $05,$13 ; Bitmap size: 5 bytes/row, 19 rows
        DB      $00,$0F,$00,$00,$00 ; . . . . . . 3 3 . . . . . . . . . . . .
        DB      $00,$3F,$C0,$00,$00 ; . . . . . 3 3 3 3 . . . . . . . . . . .
        DB      $00,$30,$C0,$00,$00 ; . . . . . 3 . . 3 . . . . . . . . . . .
        DB      $00,$3F,$C0,$00,$00 ; . . . . . 3 3 3 3 . . . . . . . . . . .
        DB      $00,$0F,$00,$00,$00 ; . . . . . . 3 3 . . . . . . . . . . . .
        DB      $02,$0F,$08,$00,$00 ; . . . 2 . . 3 3 . . 2 . . . . . . . . .
        DB      $0A,$0F,$0A,$00,$00 ; . . 2 2 . . 3 3 . . 2 2 . . . . . . . .
        DB      $0A,$0F,$0A,$00,$00 ; . . 2 2 . . 3 3 . . 2 2 . . . . . . . .
        DB      $2B,$FF,$FE,$80,$00 ; . 2 2 3 3 3 3 3 3 3 3 2 2 . . . . . . .
        DB      $2F,$FF,$FF,$80,$00 ; . 2 3 3 3 3 3 3 3 3 3 3 2 . . . . . . .
        DB      $AF,$FF,$FF,$A0,$00 ; 2 2 3 3 3 3 3 3 3 3 3 3 2 2 . . . . . .
        DB      $BF,$F5,$FF,$E0,$00 ; 2 3 3 3 3 3 1 1 3 3 3 3 3 2 . . . . . .
        DB      $B7,$F5,$FD,$E0,$00 ; 2 3 1 3 3 3 1 1 3 3 3 1 3 2 . . . . . .
        DB      $BB,$F5,$FD,$60,$00 ; 2 3 2 3 3 3 1 1 3 3 3 1 1 2 . . . . . .
        DB      $85,$F5,$F5,$20,$00 ; 2 . 1 1 3 3 1 1 3 3 1 1 . 2 . . . . . .
        DB      $85,$55,$55,$20,$00 ; 2 . 1 1 1 1 1 1 1 1 1 1 . 2 . . . . . .
        DB      $81,$55,$54,$20,$00 ; 2 . . 1 1 1 1 1 1 1 1 . . 2 . . . . . .
        DB      $80,$15,$40,$20,$00 ; 2 . . . . 1 1 1 1 . . . . 2 . . . . . .
        DB      $00,$05,$00,$00,$00 ; . . . . . . 1 1 . . . . . . . . . . . .
;*******************************************************************************
; LASER_TURRET_VERTICAL_FIRE
;
; Vertical laser-turret firing frame.
; Object record: $1943; bitmap header: $1945.
; Hotspot offsets: X = 7, Y = 4.
; Bitmap: 20 x 16 pixels, 5 bytes per row.
;*******************************************************************************
LASER_TURRET_VERTICAL_FIRE:
        DB      $07,$04 ; Hotspot offsets: X = 7, Y = 4

LASER_TURRET_VERTICAL_FIRE_HEADER:
        DB      $05,$10 ; Bitmap size: 5 bytes/row, 16 rows
        DB      $00,$0F,$00,$00,$00 ; . . . . . . 3 3 . . . . . . . . . . . .
        DB      $00,$3F,$C0,$00,$00 ; . . . . . 3 3 3 3 . . . . . . . . . . .
        DB      $02,$30,$C8,$00,$00 ; . . . 2 . 3 . . 3 . 2 . . . . . . . . .
        DB      $0A,$3F,$CA,$00,$00 ; . . 2 2 . 3 3 3 3 . 2 2 . . . . . . . .
        DB      $0A,$0F,$0A,$00,$00 ; . . 2 2 . . 3 3 . . 2 2 . . . . . . . .
        DB      $2B,$FF,$FE,$80,$00 ; . 2 2 3 3 3 3 3 3 3 3 2 2 . . . . . . .
        DB      $2F,$FF,$FF,$80,$00 ; . 2 3 3 3 3 3 3 3 3 3 3 2 . . . . . . .
        DB      $AF,$FF,$FF,$A0,$00 ; 2 2 3 3 3 3 3 3 3 3 3 3 2 2 . . . . . .
        DB      $BF,$F5,$FF,$E0,$00 ; 2 3 3 3 3 3 1 1 3 3 3 3 3 2 . . . . . .
        DB      $B7,$F5,$FD,$E0,$00 ; 2 3 1 3 3 3 1 1 3 3 3 1 3 2 . . . . . .
        DB      $BB,$F5,$FD,$60,$00 ; 2 3 2 3 3 3 1 1 3 3 3 1 1 2 . . . . . .
        DB      $85,$F5,$F5,$20,$00 ; 2 . 1 1 3 3 1 1 3 3 1 1 . 2 . . . . . .
        DB      $85,$55,$55,$20,$00 ; 2 . 1 1 1 1 1 1 1 1 1 1 . 2 . . . . . .
        DB      $81,$55,$54,$20,$00 ; 2 . . 1 1 1 1 1 1 1 1 . . 2 . . . . . .
        DB      $80,$15,$40,$20,$00 ; 2 . . . . 1 1 1 1 . . . . 2 . . . . . .
        DB      $00,$05,$00,$00,$00 ; . . . . . . 1 1 . . . . . . . . . . . .
;*******************************************************************************
; LASER_TURRET_HORIZONTAL
;
; Laser turret oriented horizontally.
; Object record: $1997; bitmap header: $1999.
; Hotspot offsets: X = 7, Y = 7.
; Bitmap: 20 x 14 pixels, 5 bytes per row.
;*******************************************************************************
LASER_TURRET_HORIZONTAL:
        DB      $07,$07 ; Hotspot offsets: X = 7, Y = 7

LASER_TURRET_HORIZONTAL_HEADER:
        DB      $05,$0E ; Bitmap size: 5 bytes/row, 14 rows
        DB      $00,$00,$0A,$A8,$00 ; . . . . . . . . . . 2 2 2 2 2 . . . . .
        DB      $00,$00,$AB,$C0,$00 ; . . . . . . . . 2 2 2 3 3 . . . . . . .
        DB      $00,$0A,$3F,$50,$00 ; . . . . . . 2 2 . 3 3 3 1 1 . . . . . .
        DB      $00,$2A,$FF,$D0,$00 ; . . . . . 2 2 2 3 3 3 3 3 1 . . . . . .
        DB      $00,$00,$FF,$D4,$00 ; . . . . . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $3F,$00,$FF,$D4,$00 ; . 3 3 3 . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $F3,$FF,$FD,$55,$00 ; 3 3 . 3 3 3 3 3 3 3 3 1 1 1 1 1 . . . .
        DB      $F3,$FF,$FD,$55,$00 ; 3 3 . 3 3 3 3 3 3 3 3 1 1 1 1 1 . . . .
        DB      $3F,$00,$FF,$D4,$00 ; . 3 3 3 . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $00,$00,$FF,$D4,$00 ; . . . . . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $00,$2A,$FF,$D0,$00 ; . . . . . 2 2 2 3 3 3 3 3 1 . . . . . .
        DB      $00,$0A,$3F,$50,$00 ; . . . . . . 2 2 . 3 3 3 1 1 . . . . . .
        DB      $00,$00,$AB,$C0,$00 ; . . . . . . . . 2 2 2 3 3 . . . . . . .
        DB      $00,$00,$0A,$A8,$00 ; . . . . . . . . . . 2 2 2 2 2 . . . . .
;*******************************************************************************
; LASER_TURRET_HORIZONTAL_FIRE
;
; Horizontal laser-turret firing frame.
; Object record: $19E1; bitmap header: $19E3.
; Hotspot offsets: X = 5, Y = 7.
; Bitmap: 20 x 14 pixels, 5 bytes per row.
;*******************************************************************************
LASER_TURRET_HORIZONTAL_FIRE:
        DB      $05,$07 ; Hotspot offsets: X = 5, Y = 7

LASER_TURRET_HORIZONTAL_FIRE_HEADER:
        DB      $05,$0E ; Bitmap size: 5 bytes/row, 14 rows
        DB      $00,$00,$0A,$A8,$00 ; . . . . . . . . . . 2 2 2 2 2 . . . . .
        DB      $00,$00,$AB,$C0,$00 ; . . . . . . . . 2 2 2 3 3 . . . . . . .
        DB      $00,$0A,$3F,$50,$00 ; . . . . . . 2 2 . 3 3 3 1 1 . . . . . .
        DB      $00,$2A,$FF,$D0,$00 ; . . . . . 2 2 2 3 3 3 3 3 1 . . . . . .
        DB      $00,$00,$FF,$D4,$00 ; . . . . . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $00,$FC,$FF,$D4,$00 ; . . . . 3 3 3 . 3 3 3 3 3 1 1 . . . . .
        DB      $03,$CF,$FD,$55,$00 ; . . . 3 3 . 3 3 3 3 3 1 1 1 1 1 . . . .
        DB      $03,$CF,$FD,$55,$00 ; . . . 3 3 . 3 3 3 3 3 1 1 1 1 1 . . . .
        DB      $00,$FC,$FF,$D4,$00 ; . . . . 3 3 3 . 3 3 3 3 3 1 1 . . . . .
        DB      $00,$00,$FF,$D4,$00 ; . . . . . . . . 3 3 3 3 3 1 1 . . . . .
        DB      $00,$2A,$FF,$D0,$00 ; . . . . . 2 2 2 3 3 3 3 3 1 . . . . . .
        DB      $00,$0A,$3F,$50,$00 ; . . . . . . 2 2 . 3 3 3 1 1 . . . . . .
        DB      $00,$00,$AB,$C0,$00 ; . . . . . . . . 2 2 2 3 3 . . . . . . .
        DB      $00,$00,$0A,$A8,$00 ; . . . . . . . . . . 2 2 2 2 2 . . . . .
; Laser-turret frame sequences. Control bytes precede object-record pointers;
; $00 terminates each list by pointing back to its first entry.
LASER_TURRET_VERTICAL_IDLE_SEQUENCE:
        DB      $FF
        DW      LASER_TURRET_VERTICAL
        DB      $00
        DW      LASER_TURRET_VERTICAL_IDLE_SEQUENCE

LASER_TURRET_HORIZONTAL_IDLE_SEQUENCE:
        DB      $FF
        DW      LASER_TURRET_HORIZONTAL
        DB      $00
        DW      LASER_TURRET_HORIZONTAL_IDLE_SEQUENCE

LASER_TURRET_VERTICAL_FIRE_SEQUENCE:
        DB      $0E
        DW      LASER_TURRET_VERTICAL_FIRE
        DB      $FF
        DW      LASER_TURRET_VERTICAL
        DB      $00
        DW      LASER_TURRET_VERTICAL_FIRE_SEQUENCE

LASER_TURRET_HORIZONTAL_FIRE_SEQUENCE:
        DB      $0E
        DW      LASER_TURRET_HORIZONTAL_FIRE
        DB      $FF
        DW      LASER_TURRET_HORIZONTAL
        DB      $00
        DW      LASER_TURRET_HORIZONTAL_FIRE_SEQUENCE
;*******************************************************************************
; SPACE_MINE_1
;
; Incoming space mine, growth stage 1.
; Object record: $1A49; bitmap header: $1A4B.
; Hotspot offsets: X = 2, Y = 2.
; Bitmap: 8 x 4 pixels, 2 bytes per row.
;*******************************************************************************
SPACE_MINE_1:
        DB      $02,$02 ; Hotspot offsets: X = 2, Y = 2

SPACE_MINE_1_HEADER:
        DB      $02,$04 ; Bitmap size: 2 bytes/row, 4 rows
        DB      $14,$00 ; . 1 1 . . . . .
        DB      $DD,$00 ; 3 1 3 1 . . . .
        DB      $77,$00 ; 1 3 1 3 . . . .
        DB      $1C,$00 ; . 1 3 . . . . .
;*******************************************************************************
; SPACE_MINE_2
;
; Incoming space mine, growth stage 2.
; Object record: $1A55; bitmap header: $1A57.
; Hotspot offsets: X = 3, Y = 3.
; Bitmap: 12 x 6 pixels, 3 bytes per row.
;*******************************************************************************
SPACE_MINE_2:
        DB      $03,$03 ; Hotspot offsets: X = 3, Y = 3

SPACE_MINE_2_HEADER:
        DB      $03,$06 ; Bitmap size: 3 bytes/row, 6 rows
        DB      $07,$00,$00 ; . . 1 3 . . . . . . . .
        DB      $37,$C0,$00 ; . 3 1 3 3 . . . . . . .
        DB      $D5,$50,$00 ; 3 1 1 1 1 1 . . . . . .
        DB      $77,$D0,$00 ; 1 3 1 3 3 1 . . . . . .
        DB      $3D,$40,$00 ; . 3 3 1 1 . . . . . . .
        DB      $0D,$00,$00 ; . . 3 1 . . . . . . . .
;*******************************************************************************
; SPACE_MINE_3
;
; Incoming space mine, growth stage 3.
; Object record: $1A6B; bitmap header: $1A6D.
; Hotspot offsets: X = 4, Y = 4.
; Bitmap: 12 x 8 pixels, 3 bytes per row.
;*******************************************************************************
SPACE_MINE_3:
        DB      $04,$04 ; Hotspot offsets: X = 4, Y = 4

SPACE_MINE_3_HEADER:
        DB      $03,$08 ; Bitmap size: 3 bytes/row, 8 rows
        DB      $03,$C0,$00 ; . . . 3 3 . . . . . . .
        DB      $0F,$50,$00 ; . . 3 3 1 1 . . . . . .
        DB      $3D,$74,$00 ; . 3 3 1 1 3 1 . . . . .
        DB      $DD,$DD,$00 ; 3 1 3 1 3 1 3 1 . . . .
        DB      $77,$77,$00 ; 1 3 1 3 1 3 1 3 . . . .
        DB      $17,$D4,$00 ; . 1 1 3 3 1 1 . . . . .
        DB      $0D,$50,$00 ; . . 3 1 1 1 . . . . . .
        DB      $01,$40,$00 ; . . . 1 1 . . . . . . .
;*******************************************************************************
; SPACE_MINE_4
;
; Incoming space mine, growth stage 4.
; Object record: $1A87; bitmap header: $1A89.
; Hotspot offsets: X = 4, Y = 5.
; Bitmap: 16 x 9 pixels, 4 bytes per row.
;*******************************************************************************
SPACE_MINE_4:
        DB      $04,$05 ; Hotspot offsets: X = 4, Y = 5

SPACE_MINE_4_HEADER:
        DB      $04,$09 ; Bitmap size: 4 bytes/row, 9 rows
        DB      $01,$70,$00,$00 ; . . . 1 1 3 . . . . . . . . . .
        DB      $05,$FC,$00,$00 ; . . 1 1 3 3 3 . . . . . . . . .
        DB      $35,$75,$00,$00 ; . 3 1 1 1 3 1 1 . . . . . . . .
        DB      $3D,$55,$00,$00 ; . 3 3 1 1 1 1 1 . . . . . . . .
        DB      $DF,$5D,$40,$00 ; 3 1 3 3 1 1 3 1 1 . . . . . . .
        DB      $55,$5F,$C0,$00 ; 1 1 1 1 1 1 3 3 3 . . . . . . .
        DB      $35,$7D,$00,$00 ; . 3 1 1 1 3 3 1 . . . . . . . .
        DB      $07,$74,$00,$00 ; . . 1 3 1 3 1 . . . . . . . . .
        DB      $03,$D0,$00,$00 ; . . . 3 3 1 . . . . . . . . . .
;*******************************************************************************
; SPACE_MINE_5
;
; Incoming space mine, growth stage 5.
; Object record: $1AAF; bitmap header: $1AB1.
; Hotspot offsets: X = 5, Y = 6.
; Bitmap: 16 x 11 pixels, 4 bytes per row.
;*******************************************************************************
SPACE_MINE_5:
        DB      $05,$06 ; Hotspot offsets: X = 5, Y = 6

SPACE_MINE_5_HEADER:
        DB      $04,$0B ; Bitmap size: 4 bytes/row, 11 rows
        DB      $00,$D4,$00,$00 ; . . . . 3 1 1 . . . . . . . . .
        DB      $0F,$57,$C0,$00 ; . . 3 3 1 1 1 3 3 . . . . . . .
        DB      $3F,$F5,$D0,$00 ; . 3 3 3 3 3 1 1 3 1 . . . . . .
        DB      $3D,$FD,$50,$00 ; . 3 3 1 3 3 3 1 1 1 . . . . . .
        DB      $35,$75,$70,$00 ; . 3 1 1 1 3 1 1 1 3 . . . . . .
        DB      $D7,$55,$FC,$00 ; 3 1 1 3 1 1 1 1 3 3 3 . . . . .
        DB      $55,$5D,$F4,$00 ; 1 1 1 1 1 1 3 1 3 3 1 . . . . .
        DB      $1D,$DF,$F0,$00 ; . 1 3 1 3 1 3 3 3 3 . . . . . .
        DB      $3F,$57,$F0,$00 ; . 3 3 3 1 1 1 3 3 3 . . . . . .
        DB      $05,$5F,$40,$00 ; . . 1 1 1 1 3 3 1 . . . . . . .
        DB      $00,$5C,$00,$00 ; . . . . 1 1 3 . . . . . . . . .
; Space-mine growth sequences. Control bytes precede object-record pointers.
SPACE_MINE_GROW_SEQUENCE:
        DB      $1C
        DW      SPACE_MINE_1
        DB      $14
        DW      SPACE_MINE_2
        DB      $10
        DW      SPACE_MINE_3
        DB      $0C
        DW      SPACE_MINE_4
        DB      $FF
        DW      SPACE_MINE_5
        DB      $00
        DW      SPACE_MINE_GROW_SEQUENCE

SPACE_MINE_FAST_GROW_SEQUENCE:
        DB      $09
        DW      SPACE_MINE_1
        DB      $09
        DW      SPACE_MINE_2
        DB      $09
        DW      SPACE_MINE_3
        DB      $09
        DW      SPACE_MINE_4
        DB      $FF
        DW      SPACE_MINE_5
        DB      $00
        DW      SPACE_MINE_GROW_SEQUENCE
;*******************************************************************************
; LASER_BASE_DESTROY_1
;
; Laser-base destruction animation, frame 1.
; Object record: $1B03; bitmap header: $1B05.
; Hotspot offsets: X = 8, Y = 6.
; Bitmap: 16 x 12 pixels, 4 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_1:
        DB      $08,$06 ; Hotspot offsets: X = 8, Y = 6

LASER_BASE_DESTROY_1_HEADER:
        DB      $04,$0C ; Bitmap size: 4 bytes/row, 12 rows
        DB      $00,$C0,$04,$00 ; . . . . 3 . . . . . 1 . . . . .
        DB      $C0,$F3,$00,$00 ; 3 . . . 3 3 . 3 . . . . . . . .
        DB      $3F,$FF,$0C,$00 ; . 3 3 3 3 3 3 3 . . 3 . . . . .
        DB      $0F,$FF,$FC,$00 ; . . 3 3 3 3 3 3 3 3 3 . . . . .
        DB      $0F,$DF,$7F,$00 ; . . 3 3 3 1 3 3 1 3 3 3 . . . .
        DB      $FF,$55,$7C,$00 ; 3 3 3 3 1 1 1 1 1 3 3 . . . . .
        DB      $FD,$55,$7C,$00 ; 3 3 3 1 1 1 1 1 1 3 3 . . . . .
        DB      $3F,$F5,$7C,$00 ; . 3 3 3 3 3 1 1 1 3 3 . . . . .
        DB      $0F,$3F,$F0,$00 ; . . 3 3 . 3 3 3 3 3 . . . . . .
        DB      $4C,$0F,$C1,$00 ; 1 . 3 . . . 3 3 3 . . 1 . . . .
        DB      $00,$0F,$C0,$00 ; . . . . . . 3 3 3 . . . . . . .
        DB      $00,$03,$00,$00 ; . . . . . . . 3 . . . . . . . .
;*******************************************************************************
; LASER_BASE_DESTROY_2
;
; Laser-base destruction animation, frame 2.
; Object record: $1B37; bitmap header: $1B39.
; Hotspot offsets: X = 10, Y = 8.
; Bitmap: 20 x 17 pixels, 5 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_2:
        DB      $0A,$08 ; Hotspot offsets: X = 10, Y = 8

LASER_BASE_DESTROY_2_HEADER:
        DB      $05,$11 ; Bitmap size: 5 bytes/row, 17 rows
        DB      $01,$00,$00,$00,$00 ; . . . 1 . . . . . . . . . . . . . . . .
        DB      $00,$40,$00,$00,$00 ; . . . . 1 . . . . . . . . . . . . . . .
        DB      $00,$54,$00,$00,$00 ; . . . . 1 1 1 . . . . . . . . . . . . .
        DB      $00,$14,$04,$00,$00 ; . . . . . 1 1 . . . 1 . . . . . . . . .
        DB      $00,$15,$54,$00,$C0 ; . . . . . 1 1 1 1 1 1 . . . . . 3 . . .
        DB      $00,$1D,$54,$14,$00 ; . . . . . 1 3 1 1 1 1 . . 1 1 . . . . .
        DB      $00,$5F,$D5,$55,$00 ; . . . . 1 1 3 3 3 1 1 1 1 1 1 1 . . . .
        DB      $00,$5F,$FF,$F5,$00 ; . . . . 1 1 3 3 3 3 3 3 3 3 1 1 . . . .
        DB      $C1,$7F,$FF,$F4,$00 ; 3 . . 1 1 3 3 3 3 3 3 3 3 3 1 . . . . .
        DB      $15,$7F,$FF,$D4,$00 ; . 1 1 1 1 3 3 3 3 3 3 3 3 1 1 . . . . .
        DB      $15,$FF,$FF,$D4,$00 ; . 1 1 1 3 3 3 3 3 3 3 3 3 1 1 . . . . .
        DB      $05,$FF,$FF,$F5,$00 ; . . 1 1 3 3 3 3 3 3 3 3 3 3 1 1 . . . .
        DB      $05,$F5,$FD,$F4,$00 ; . . 1 1 3 3 1 1 3 3 3 1 3 3 1 . . . . .
        DB      $00,$55,$55,$54,$00 ; . . . . 1 1 1 1 1 1 1 1 1 1 1 . . . . .
        DB      $05,$14,$14,$45,$40 ; . . 1 1 . 1 1 . . 1 1 . 1 . 1 1 1 . . .
        DB      $04,$00,$00,$40,$40 ; . . 1 . . . . . . . . . 1 . . . 1 . . .
        DB      $50,$00,$00,$40,$00 ; 1 1 . . . . . . . . . . 1 . . . . . . .
;*******************************************************************************
; LASER_BASE_DESTROY_3
;
; Laser-base destruction animation, frame 3.
; Object record: $1B90; bitmap header: $1B92.
; Hotspot offsets: X = 12, Y = 11.
; Bitmap: 24 x 23 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_3:
        DB      $0C,$0B ; Hotspot offsets: X = 12, Y = 11

LASER_BASE_DESTROY_3_HEADER:
        DB      $06,$17 ; Bitmap size: 6 bytes/row, 23 rows
        DB      $00,$00,$80,$00,$00,$00 ; . . . . . . . . 2 . . . . . . . . . . . . . . .
        DB      $00,$02,$60,$00,$00,$00 ; . . . . . . . 2 1 2 . . . . . . . . . . . . . .
        DB      $00,$A9,$58,$00,$00,$00 ; . . . . 2 2 2 1 1 1 2 . . . . . . . . . . . . .
        DB      $02,$55,$56,$0A,$00,$00 ; . . . 2 1 1 1 1 1 1 1 2 . . 2 2 . . . . . . . .
        DB      $0B,$DF,$F5,$A6,$80,$00 ; . . 2 3 3 1 3 3 3 3 1 1 2 2 1 2 2 . . . . . . .
        DB      $25,$FF,$FD,$7D,$60,$00 ; . 2 1 1 3 3 3 3 3 3 3 1 1 3 3 1 1 2 . . . . . .
        DB      $09,$7F,$FF,$FD,$58,$00 ; . . 2 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 2 . . . . .
        DB      $02,$FF,$FF,$FF,$56,$00 ; . . . 2 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 2 . . . .
        DB      $00,$BF,$FF,$FF,$D5,$80 ; . . . . 2 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 2 . . .
        DB      $02,$5F,$FF,$FF,$FD,$60 ; . . . 2 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 2 . .
        DB      $09,$7F,$FF,$FF,$F5,$80 ; . . 2 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 2 . . .
        DB      $25,$FF,$FF,$FF,$D6,$00 ; . 2 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 2 . . . .
        DB      $A5,$FF,$FF,$FF,$58,$00 ; 2 2 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 2 . . . . .
        DB      $25,$5F,$FF,$F5,$58,$00 ; . 2 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 2 . . . . .
        DB      $09,$FF,$FF,$FD,$A0,$00 ; . . 2 1 3 3 3 3 3 3 3 3 3 3 3 1 2 2 . . . . . .
        DB      $02,$FB,$FF,$FE,$00,$00 ; . . . 2 3 3 2 3 3 3 3 3 3 3 3 2 . . . . . . . .
        DB      $00,$ED,$FF,$FE,$00,$00 ; . . . . 3 2 3 1 3 3 3 3 3 3 3 2 . . . . . . . .
        DB      $00,$9F,$FF,$FE,$A0,$00 ; . . . . 2 1 3 3 3 3 3 3 3 3 3 2 2 2 . . . . . .
        DB      $02,$57,$DF,$FD,$58,$00 ; . . . 2 1 1 1 3 3 1 3 3 3 3 3 1 1 1 2 . . . . .
        DB      $00,$95,$5B,$75,$60,$00 ; . . . . 2 1 1 1 1 1 2 3 1 3 1 1 1 2 . . . . . .
        DB      $00,$25,$62,$55,$80,$00 ; . . . . . 2 1 1 1 2 . 2 1 1 1 1 2 . . . . . . .
        DB      $00,$09,$80,$96,$00,$00 ; . . . . . . 2 1 2 . . . 2 1 1 2 . . . . . . . .
        DB      $00,$02,$00,$28,$00,$00 ; . . . . . . . 2 . . . . . 2 2 . . . . . . . . .
	 ld   h,(hl)
;*******************************************************************************
; LASER_BASE_DESTROY_4
;
; Laser-base destruction animation, frame 4.
; Object record: $1C1F; bitmap header: $1C21.
; Hotspot offsets: X = 12, Y = 11.
; Bitmap: 24 x 23 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_4:
        DB      $0C,$0B ; Hotspot offsets: X = 12, Y = 11

LASER_BASE_DESTROY_4_HEADER:
        DB      $06,$17 ; Bitmap size: 6 bytes/row, 23 rows
        DB      $80,$00,$08,$00,$00,$80 ; 2 . . . . . . . . . 2 . . . . . . . . . 2 . . .
        DB      $20,$00,$20,$00,$02,$00 ; . 2 . . . . . . . 2 . . . . . . . . . 2 . . . .
        DB      $08,$00,$80,$00,$08,$00 ; . . 2 . . . . . 2 . . . . . . . . . 2 . . . . .
        DB      $02,$00,$80,$00,$20,$00 ; . . . 2 . . . . 2 . . . . . . . . 2 . . . . . .
        DB      $00,$A2,$A1,$40,$80,$00 ; . . . . 2 2 . 2 2 2 . 1 1 . . . 2 . . . . . . .
        DB      $00,$2B,$7E,$52,$00,$00 ; . . . . . 2 2 3 1 3 3 2 1 1 . 2 . . . . . . . .
        DB      $00,$AF,$FF,$94,$02,$00 ; . . . . 2 2 3 3 3 3 3 3 2 1 1 . . . . 2 . . . .
        DB      $00,$2D,$FF,$F4,$08,$00 ; . . . . . 2 3 1 3 3 3 3 3 3 1 . . . 2 . . . . .
        DB      $00,$2B,$7F,$D5,$A0,$00 ; . . . . . 2 2 3 1 3 3 3 3 1 1 1 2 2 . . . . . .
        DB      $00,$0B,$7F,$D8,$00,$00 ; . . . . . . 2 3 1 3 3 3 3 1 2 . . . . . . . . .
        DB      $00,$AB,$7F,$DA,$00,$00 ; . . . . 2 2 2 3 1 3 3 3 3 1 2 2 . . . . . . . .
        DB      $02,$BD,$FF,$F6,$00,$00 ; . . . 2 2 3 3 1 3 3 3 3 3 3 1 2 . . . . . . . .
        DB      $0A,$DF,$FF,$E8,$00,$00 ; . . 2 2 3 1 3 3 3 3 3 3 3 2 2 . . . . . . . . .
        DB      $2B,$D7,$FF,$60,$00,$00 ; . 2 2 3 3 1 1 3 3 3 3 3 1 2 . . . . . . . . . .
        DB      $02,$B5,$FD,$68,$00,$00 ; . . . 2 2 3 1 1 3 3 3 1 1 2 2 . . . . . . . . .
        DB      $02,$AF,$FD,$FA,$00,$00 ; . . . 2 2 2 3 3 3 3 3 1 3 3 2 2 . . . . . . . .
        DB      $08,$2E,$AF,$F8,$00,$00 ; . . 2 . . 2 3 2 2 2 3 3 3 3 2 . . . . . . . . .
        DB      $20,$28,$2B,$EA,$00,$00 ; . 2 . . . 2 2 . . 2 2 3 3 2 2 2 . . . . . . . .
        DB      $80,$00,$0A,$A2,$80,$00 ; 2 . . . . . . . . . 2 2 2 2 . 2 2 . . . . . . .
        DB      $00,$00,$08,$00,$20,$00 ; . . . . . . . . . . 2 . . . . . . 2 . . . . . .
        DB      $00,$00,$20,$00,$08,$00 ; . . . . . . . . . 2 . . . . . . . . 2 . . . . .
        DB      $00,$00,$80,$00,$02,$00 ; . . . . . . . . 2 . . . . . . . . . . 2 . . . .
        DB      $00,$00,$00,$00,$00,$80 ; . . . . . . . . . . . . . . . . . . . . 2 . . .
;*******************************************************************************
; LASER_BASE_DESTROY_5
;
; Laser-base destruction animation, frame 5.
; Object record: $1CAD; bitmap header: $1CAF.
; Hotspot offsets: X = 12, Y = 11.
; Bitmap: 24 x 23 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_5:
        DB      $0C,$0B ; Hotspot offsets: X = 12, Y = 11

LASER_BASE_DESTROY_5_HEADER:
        DB      $06,$17 ; Bitmap size: 6 bytes/row, 23 rows
        DB      $00,$00,$04,$03,$00,$00 ; . . . . . . . . . . 1 . . . . 3 . . . . . . . .
        DB      $00,$30,$41,$40,$30,$00 ; . . . . . 3 . . 1 . . 1 1 . . . . 3 . . . . . .
        DB      $00,$8C,$20,$08,$00,$00 ; . . . . 2 . 3 . . 2 . . . . 2 . . . . . . . . .
        DB      $00,$00,$01,$00,$00,$00 ; . . . . . . . . . . . 1 . . . . . . . . . . . .
        DB      $30,$90,$80,$C0,$20,$00 ; . 3 . . 2 1 . . 2 . . . 3 . . . . 2 . . . . . .
        DB      $0C,$20,$02,$00,$0F,$C0 ; . . 3 . . 2 . . . . . 2 . . . . . . 3 3 3 . . .
        DB      $30,$08,$28,$0C,$30,$00 ; . 3 . . . . 2 . . 2 2 . . . 3 . . 3 . . . . . .
        DB      $00,$00,$30,$00,$03,$00 ; . . . . . . . . . 3 . . . . . . . . . 3 . . . .
        DB      $0F,$C2,$A0,$14,$05,$40 ; . . 3 3 3 . . 2 2 2 . . . 1 1 . . . 1 1 1 . . .
        DB      $03,$C1,$80,$50,$1A,$00 ; . . . 3 3 . . 1 2 . . . 1 1 . . . 1 2 2 . . . .
        DB      $0F,$A1,$A1,$44,$4A,$40 ; . . 3 3 2 2 . 1 2 2 . 1 1 . 1 . 1 . 2 2 1 . . .
        DB      $F0,$29,$85,$50,$54,$00 ; 3 3 . . . 2 2 1 2 . 1 1 1 1 . . 1 1 1 . . . . .
        DB      $FC,$0A,$81,$54,$50,$00 ; 3 3 3 . . . 2 2 2 . . 1 1 1 1 . 1 1 . . . . . .
        DB      $0C,$80,$2A,$90,$00,$40 ; . . 3 . 2 . . . . 2 2 2 2 1 . . . . . . 1 . . .
        DB      $0F,$54,$08,$48,$50,$00 ; . . 3 3 1 1 1 . . . 2 . 1 . 2 . 1 1 . . . . . .
        DB      $30,$14,$20,$40,$10,$00 ; . 3 . . . 1 1 . . 2 . . 1 . . . . 1 . . . . . .
        DB      $01,$03,$0C,$04,$0C,$00 ; . . . 1 . . . 3 . . 3 . . . 1 . . . 3 . . . . .
        DB      $00,$10,$00,$00,$40,$00 ; . . . . . 1 . . . . . . . . . . 1 . . . . . . .
        DB      $20,$00,$04,$00,$00,$00 ; . 2 . . . . . . . . 1 . . . . . . . . . . . . .
        DB      $01,$0C,$00,$0C,$04,$00 ; . . . 1 . . 3 . . . . . . . 3 . . . 1 . . . . .
        DB      $00,$00,$08,$00,$00,$00 ; . . . . . . . . . . 2 . . . . . . . . . . . . .
        DB      $00,$04,$00,$10,$C0,$00 ; . . . . . . 1 . . . . . . 1 . . 3 . . . . . . .
        DB      $00,$00,$12,$0C,$00,$00 ; . . . . . . . . . 1 . 2 . . 3 . . . . . . . . .
;*******************************************************************************
; LASER_BASE_DESTROY_6
;
; Laser-base destruction animation, frame 6.
; Object record: $1D3B; bitmap header: $1D3D.
; Hotspot offsets: X = 12, Y = 11.
; Bitmap: 24 x 23 pixels, 6 bytes per row.
;*******************************************************************************
LASER_BASE_DESTROY_6:
        DB      $0C,$0B ; Hotspot offsets: X = 12, Y = 11

LASER_BASE_DESTROY_6_HEADER:
        DB      $06,$17 ; Bitmap size: 6 bytes/row, 23 rows
        DB      $00,$00,$C0,$00,$00,$00 ; . . . . . . . . 3 . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $20,$00,$00,$00,$04,$00 ; . 2 . . . . . . . . . . . . . . . . 1 . . . . .
        DB      $00,$00,$00,$20,$00,$00 ; . . . . . . . . . . . . . 2 . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$80 ; . . . . . . . . . . . . . . . . . . . . 2 . . .
        DB      $02,$00,$00,$00,$00,$00 ; . . . 2 . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$10,$00,$00,$00 ; . . . . . . . . . 1 . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $C0,$00,$00,$00,$03,$00 ; 3 . . . . . . . . . . . . . . . . . . 3 . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$01,$02,$00,$00,$00 ; . . . . . . . 1 . . . 2 . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$C0,$00 ; . . . . . . . . . . . . . . . . 3 . . . . . . .
        DB      $00,$00,$00,$00,$00,$40 ; . . . . . . . . . . . . . . . . . . . . 1 . . .
        DB      $40,$00,$00,$00,$00,$00 ; 1 . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$40,$00,$00,$00 ; . . . . . . . . 1 . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$00,$00,$00 ; . . . . . . . . . . . . . . . . . . . . . . . .
        DB      $01,$00,$00,$00,$00,$00 ; . . . 1 . . . . . . . . . . . . . . . . . . . .
        DB      $00,$00,$00,$03,$00,$00 ; . . . . . . . . . . . . . . . 3 . . . . . . . .
        DB      $00,$00,$04,$00,$00,$00 ; . . . . . . . . . . 1 . . . . . . . . . . . . .
        DB      $00,$01,$00,$40,$00,$00 ; . . . . . . . 1 . . . . 1 . . . . . . . . . . .
; Laser-base destruction sequence.
LASER_BASE_DESTROY_SEQUENCE:
        DB      $06
        DW      LASER_BASE_DESTROY_1
        DB      $06
        DW      LASER_BASE_DESTROY_2
        DB      $06
        DW      LASER_BASE_DESTROY_3
        DB      $06
        DW      LASER_BASE_DESTROY_4
        DB      $06
        DW      LASER_BASE_DESTROY_5
        DB      $06
        DW      LASER_BASE_DESTROY_6
        DB      $FF
        DW      BLANK
        DB      $00
        DW      LASER_BASE_DESTROY_SEQUENCE
;*******************************************************************************
; ATTACK_SATELLITE_1
;
; Attack-satellite animation, frame 1.
; Object record: $1DE1; bitmap header: $1DE3.
; Hotspot offsets: X = 7, Y = 5.
; Bitmap: 20 x 11 pixels, 5 bytes per row.
;*******************************************************************************
ATTACK_SATELLITE_1:
        DB      $07,$05 ; Hotspot offsets: X = 7, Y = 5

ATTACK_SATELLITE_1_HEADER:
        DB      $05,$0B ; Bitmap size: 5 bytes/row, 11 rows
        DB      $00,$01,$00,$00,$00 ; . . . . . . . 1 . . . . . . . . . . . .
        DB      $C0,$05,$40,$0C,$00 ; 3 . . . . . 1 1 1 . . . . . 3 . . . . .
        DB      $C0,$16,$50,$0C,$00 ; 3 . . . . 1 1 2 1 1 . . . . 3 . . . . .
        DB      $C0,$5A,$94,$0C,$00 ; 3 . . . 1 1 2 2 2 1 1 . . . 3 . . . . .
        DB      $C1,$6B,$A5,$0C,$00 ; 3 . . 1 1 2 2 3 2 2 1 1 . . 3 . . . . .
        DB      $FD,$AF,$E9,$FC,$00 ; 3 3 3 1 2 2 3 3 3 2 2 1 3 3 3 . . . . .
        DB      $C1,$6B,$A5,$0C,$00 ; 3 . . 1 1 2 2 3 2 2 1 1 . . 3 . . . . .
        DB      $C0,$5A,$94,$0C,$00 ; 3 . . . 1 1 2 2 2 1 1 . . . 3 . . . . .
        DB      $C0,$16,$50,$0C,$00 ; 3 . . . . 1 1 2 1 1 . . . . 3 . . . . .
        DB      $C0,$05,$40,$0C,$00 ; 3 . . . . . 1 1 1 . . . . . 3 . . . . .
        DB      $00,$01,$00,$00,$00 ; . . . . . . . 1 . . . . . . . . . . . .
;*******************************************************************************
; ATTACK_SATELLITE_2
;
; Attack-satellite animation, frame 2.
; Object record: $1E1C; bitmap header: $1E1E.
; Hotspot offsets: X = 7, Y = 5.
; Bitmap: 20 x 11 pixels, 5 bytes per row.
;*******************************************************************************
ATTACK_SATELLITE_2:
        DB      $07,$05 ; Hotspot offsets: X = 7, Y = 5

ATTACK_SATELLITE_2_HEADER:
        DB      $05,$0B ; Bitmap size: 5 bytes/row, 11 rows
        DB      $00,$02,$00,$00,$00 ; . . . . . . . 2 . . . . . . . . . . . .
        DB      $00,$0A,$80,$00,$00 ; . . . . . . 2 2 2 . . . . . . . . . . .
        DB      $C0,$2B,$A0,$0C,$00 ; 3 . . . . 2 2 3 2 2 . . . . 3 . . . . .
        DB      $C0,$AF,$E8,$0C,$00 ; 3 . . . 2 2 3 3 3 2 2 . . . 3 . . . . .
        DB      $C2,$BD,$FA,$0C,$00 ; 3 . . 2 2 3 3 1 3 3 2 2 . . 3 . . . . .
        DB      $FE,$F5,$7E,$FC,$00 ; 3 3 3 2 3 3 1 1 1 3 3 2 3 3 3 . . . . .
        DB      $C2,$BD,$FA,$0C,$00 ; 3 . . 2 2 3 3 1 3 3 2 2 . . 3 . . . . .
        DB      $C0,$AF,$E8,$0C,$00 ; 3 . . . 2 2 3 3 3 2 2 . . . 3 . . . . .
        DB      $C0,$2B,$A0,$0C,$00 ; 3 . . . . 2 2 3 2 2 . . . . 3 . . . . .
        DB      $00,$0A,$80,$00,$00 ; . . . . . . 2 2 2 . . . . . . . . . . .
        DB      $00,$02,$00,$00,$00 ; . . . . . . . 2 . . . . . . . . . . . .
;*******************************************************************************
; ATTACK_SATELLITE_3
;
; Attack-satellite animation, frame 3.
; Object record: $1E57; bitmap header: $1E59.
; Hotspot offsets: X = 7, Y = 5.
; Bitmap: 20 x 11 pixels, 5 bytes per row.
;*******************************************************************************
ATTACK_SATELLITE_3:
        DB      $07,$05 ; Hotspot offsets: X = 7, Y = 5

ATTACK_SATELLITE_3_HEADER:
        DB      $05,$0B ; Bitmap size: 5 bytes/row, 11 rows
        DB      $00,$03,$00,$00,$00 ; . . . . . . . 3 . . . . . . . . . . . .
        DB      $00,$0F,$C0,$00,$00 ; . . . . . . 3 3 3 . . . . . . . . . . .
        DB      $00,$3D,$F0,$00,$00 ; . . . . . 3 3 1 3 3 . . . . . . . . . .
        DB      $00,$F5,$7C,$00,$00 ; . . . . 3 3 1 1 1 3 3 . . . . . . . . .
        DB      $C3,$D6,$5F,$0C,$00 ; 3 . . 3 3 1 1 2 1 1 3 3 . . 3 . . . . .
        DB      $FF,$5A,$97,$FC,$00 ; 3 3 3 3 1 1 2 2 2 1 1 3 3 3 3 . . . . .
        DB      $C3,$D6,$5F,$0C,$00 ; 3 . . 3 3 1 1 2 1 1 3 3 . . 3 . . . . .
        DB      $00,$F5,$7C,$00,$00 ; . . . . 3 3 1 1 1 3 3 . . . . . . . . .
        DB      $00,$3D,$F0,$00,$00 ; . . . . . 3 3 1 3 3 . . . . . . . . . .
        DB      $00,$0F,$C0,$00,$00 ; . . . . . . 3 3 3 . . . . . . . . . . .
        DB      $00,$03,$00,$00,$00 ; . . . . . . . 3 . . . . . . . . . . . .
; Attack-satellite animation sequence.
ATTACK_SATELLITE_SEQUENCE:
        DB      $04
        DW      ATTACK_SATELLITE_1
        DB      $04
        DW      ATTACK_SATELLITE_2
        DB      $04
        DW      ATTACK_SATELLITE_3
        DB      $04
        DW      ATTACK_SATELLITE_2
        DB      $00
        DW      ATTACK_SATELLITE_SEQUENCE
        push de
	 ld   de,$0024
	 add  hl,de
	 pop  de
	 ret
	 ld   a,i
	 push af
	 xor  a
	 ld   i,a
	 ld   a,$A5
	 out  ($5B),a
	 ld   (hl),e
	 inc  hl
	 out  ($5B),a
	 ld   (hl),d
	 pop  af
	 ld   i,a
	 ret
	 ld   a,i
	 push af
	 di
	 call $1EA8
	 dec  hl
	 call $1EA1
	 call $1EA8
	 pop  af
	 jp   po,$1ECE
	 ei
	 ret
	 ld   a,i
	 push af
	 xor  a
	 ld   i,a
	 ld   a,$A5
	 out  ($5B),a
	 ld   (hl),e
	 pop  af
	 ld   i,a
	 ret
	 ld   a,i
	 push af
	 di
	 call $1ECF
	 call $1EA1
	 call $1ECF
	 pop  af
	 jp   po,$1EF0
	 ei
	 ret
	 pop  hl
	 pop  de
	 call $1EBB
	 jp   (iy)
	 pop  hl
	 ld   de,$0000
	 call $1EBB
	 jp   (iy)
	 pop  hl
	 pop  de
	 call $1EDE
	 jp   (iy)
	 pop  hl
	 ld   e,$01
	 call $1EDE
	 jp   (iy)
	 pop  hl
	 ld   e,$00
	 call $1EDE
	 jp   (iy)
	 pop  hl
	 ld   e,(hl)
	 dec  e
	 call $1EDE
	 jp   (iy)
	 exx
	 ld   a,r
	 ld   ($D151),a
	 ld   bc,$001A
	 ld   hl,$D001
	 ld   de,$D025
	 ld   a,(de)
	 cp   (hl)
	 jp   z,$1F35
	 inc  b
	 inc  hl
	 inc  de
	 dec  c
	 jp   nz,$1F2F
	 ld   a,b
	 or   a
	 jp   nz,$1F55
	 ld   hl,$D001
	 ld   a,(hl)
	 ld   bc,$0024
	 inc  hl
	 cp   (hl)
	 jp   z,$1F4D
	 inc  b
	 dec  c
	 jp   nz,$1F47
	 ld   a,b
	 jp   $1F56
	 xor  a
	 or   a
	 jp   nz,$1F85
	 ld   bc,$003F
	 ld   hl,$D001
	 ld   a,i
	 push af
	 di
	 ld   a,i
	 push af
	 xor  a
	 ld   i,a
	 ld   a,$A5
	 out  ($5B),a
	 ld   (hl),$00
	 inc  hl
	 dec  c
	 jp   nz,$1F6A
	 pop  af
	 ld   i,a
	 pop  af
	 jp   po,$1F7D
	 ei
	 ld   hl,$D001
	 ld   e,$01
	 call $1EDE
	 ld   hl,$D00F
	 ld   c,$10
	 in   e,(c)
	 call $1EDE
	 exx
	 jp   (iy)
; $1F92–$1FC2: audio-related native/TERSE command sequence.
TERSE_COLON_1F92:
	 RST $08
TERSE_THREAD_1F93:
	 DB $0E ; $1F93 token $0E -> $0059
	 DB $10 ; inline byte
	 DB $21 ; $1F95 token $21 -> $01D9
	 DB $05 ; $1F96 token $05 -> $0094
TERSE_THREAD_1F97:
	 DB $0B ; $1F97 token $0B -> $007B
	 DB $1B ; $1F98 token $1B -> $0050
	 DW $D155 ; inline word
	 DB $1B ; $1F9B token $1B -> $0050
	 DW $03B6 ; inline word
	 DB $22 ; $1F9E token $22 -> $0D43
	 DB $0B ; $1F9F token $0B -> $007B
	 DB $1B ; $1FA0 token $1B -> $0050
	 DW $7E80 ; inline word
	 DB $1B ; $1FA3 token $1B -> $0050
	 DW $0180 ; inline word
	 DB $22 ; $1FA6 token $22 -> $0D43
	 DB $0B ; $1FA7 token $0B -> $007B
	 DB $1B ; $1FA8 token $1B -> $0050
	 DW $D50B ; inline word
	 DB $1B ; $1FAB token $1B -> $0050
	 DW $D155 ; inline word
	 DB $23 ; $1FAE token $23 -> $016D
	 DB $24 ; $1FAF token $24 -> $01B6
	 DB $25 ; $1FB0 token $25 -> $00A4
	 DB $0F ; $1FB1 token $0F -> $00BF
	 DB $26 ; $1FB2 token $26 -> $0188
	 DB $1B ; $1FB3 token $1B -> $0050
	 DW $8000 ; inline word
	 DB $1B ; $1FB6 token $1B -> $0050
	 DW $7E80 ; inline word
	 DB $23 ; $1FB9 token $23 -> $016D
	 DB $24 ; $1FBA token $24 -> $01B6
	 DB $25 ; $1FBB token $25 -> $00A4
	 DB $0F ; $1FBC token $0F -> $00BF
	 DB $26 ; $1FBD token $26 -> $0188
	 DB $27 ; $1FBE token $27 -> $0139
	 DB $03 ; $1FBF token $03 -> $01FC
	 DW TERSE_THREAD_1F97 ; 0BRANCH
	 DB $06 ; $1FC2 token $06 -> $0044
; $1FC3–$1FC8: native address/control state initialization.
AUDIO_STATE_INIT_1FC3:
	 LD HL,$0032
	 ADD HL,DE
	 LD (HL),$01
; AUDIO_CLEAR_SOUND_REGISTERS  $1FC9
; Clear eight sound-chip registers ($10-$17).
; B counts registers; C walks backward from $17 to $10.
;==============================================================================
AUDIO_CLEAR_SOUND_REGISTERS:
	 xor  a
	 ld   bc,$0818
	 dec  c
	 out  (c),a
	 dec  b
	 jp   nz,$1FCD
	 ld   hl,$001A
	 add  hl,de
	 ld   c,$18
	 ld   (hl),a
	 inc  hl
	 dec  c
	 jp   nz,$1FDA
	 exx
	 ret
	 ld   a,(iy+$22)
	 or   a
	 jp   z,$1FF7
	 dec  a
	 ld   (iy+$22),a
	 jp   nz,$1FF7
	 ld   (iy+$1c),a
	 ld   (iy+$32),$01
	 ret
	 xor  a
	 cp   (iy+$32)
	 jp   z,$2002
	 jp   $0362
	 ld   hl,$D002
	 cp   (hl)
	 jp   z,$20DE
	 inc  (iy+$31)
	 inc  a
	 cp   (iy+$31)
	 jp   nz,$20D2
	 xor  a
	 cp   (iy+$30)
	 jp   z,$2027
	 dec  (iy+$30)
	 jp   z,$2023
	 jp   $2027
	 ld   (iy+$32),$01
	 ld   a,(iy+$1c)
	 or   a
	 jp   z,$20A8
	 dec  (iy+$20)
	 jp   nz,$20A8
;==============================================================================
; AUDIO_MASTER_OSCILLATOR_STEP  $2034
; Advance oscillator state and write sound register $10.
; IY points to the active sound-effect state record.
;==============================================================================
AUDIO_MASTER_OSCILLATOR_STEP:
	 ld   l,(iy+$1f)
	 ld   c,$10
	 ld   a,(iy+$1a)
	 add  a,l
	 ld   (iy+$1a),a
	 out  (c),a
	 ld   d,a
	 ld   a,(iy+$1e)
	 dec  a
	 cp   d
	 jp   nc,$2073
	 call $1FE2
	 ld   a,(iy+$1b)
	 cp   $03
	 jp   nz,$205E
	 ld   a,$01
	 ld   (iy+$1b),a
	 jp   $2073
	 or   a
	 jp   z,$206F
	 inc  (iy+$1b)
	 ld   a,(iy+$1d)
	 sub  l
	 ld   (iy+$1a),a
	 jp   $2073
	 sub  l
	 ld   (iy+$1f),a
	 ld   a,(iy+$1d)
	 cp   d
	 jp   c,$20A2
	 call $1FE2
	 ld   a,(iy+$1b)
	 cp   $02
	 jp   nz,$208B
	 dec  (iy+$1b)
	 jp   $20A2
	 or   a
	 jp   z,$209E
	 ld   a,$03
	 ld   (iy+$1b),a
	 ld   a,(iy+$1e)
	 sub  l
	 ld   (iy+$1a),a
	 jp   $20A2
	 sub  l
	 ld   (iy+$1f),a
	 ld   a,(iy+$21)
	 ld   (iy+$20),a
	 ld   a,(iy+$25)
	 or   a
	 jp   z,$20CE
	 dec  (iy+$25)
	 jp   nz,$20CE
;==============================================================================
; AUDIO_NOISE_VOLUME_STEP  $20B5
; Advance noise-envelope state and write sound register $17.
; Uses IY+$24 as increment and IY+$27 as accumulator.
;==============================================================================
AUDIO_NOISE_VOLUME_STEP:
	 ld   c,$17
	 ld   a,(iy+$27)
	 add  a,(iy+$24)
	 ld   (iy+$27),a
	 out  (c),a
	 cp   (iy+$23)
	 jp   z,$20CE
	 ld   a,(iy+$26)
	 ld   (iy+$25),a
	 xor  a
	 ld   (iy+$31),a
	 cp   (iy+$32)
	 ld   (iy+$32),a
	 jp   nz,$20DE
	 jp   $0362
	 jp   $0346
	 ld   hl,$D187
	 ld   (hl),$00
	 ld   hl,$1FF8
	 jp   $0D1E
	 exx
	 ld   hl,$D185
	 pop  bc
	 ld   (hl),c
	 ld   hl,$D187
	 ld   (hl),$00
	 exx
	 ld   hl,$1FF8
	 jp   $0D1E
	 jp   $20EC
	 xor  a
	 ld   hl,$D170
	 ld   (hl),a
	 inc  hl
	 inc  a
	 ld   (hl),a
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),e
	 jp   (iy)
	 ld   a,$01
	 ld   hl,$D171
	 ld   (hl),a
	 ld   hl,$D177
	 pop  de
	 ld   (hl),e
	 jp   (iy)
	 exx
	 ld   c,$17
	 ld   hl,$D178
	 pop  de
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 inc  hl
	 ld   (hl),e
	 inc  hl
	 pop  de
	 ld   (hl),e
	 out  (c),e
	 exx
	 jp   (iy)
;==============================================================================
; AUDIO_WRITE_REGISTER_INDEXED  $213E
; Write data byte to a selected sound register.
; Input B = reverse register index; C = data. Port = $18-B.
;==============================================================================
AUDIO_WRITE_REGISTER_INDEXED:
	 ld   a,$18
	 sub  b
	 ld   e,c
	 ld   c,a
	 out  (c),e
	 ret
	 exx
	 pop  bc
	 ld   b,$08
	 call AUDIO_WRITE_REGISTER_INDEXED
	 ld   hl,$D16F
	 ld   (hl),e
	 exx
	 jp   (iy)
	 exx
	 pop  bc
	 ld   b,$01
	 call AUDIO_WRITE_REGISTER_INDEXED
	 ld   hl,$D17C
	 ld   (hl),e
	 exx
	 jp   (iy)
	 exx
	 pop  bc
	 ld   b,$02
	 call AUDIO_WRITE_REGISTER_INDEXED
	 exx
	 jp   (iy)
	 exx
	 pop  bc
	 ld   b,$03
	 call AUDIO_WRITE_REGISTER_INDEXED
	 exx
	 jp   (iy)
	 pop  hl
	 exx
	 pop  bc
	 ld   b,$07
	 call AUDIO_WRITE_REGISTER_INDEXED
	 pop  de
	 inc  c
	 out  (c),e
	 pop  de
	 inc  c
	 out  (c),e
	 exx
	 jp   (hl)
	 call $2176
	 jp   (iy)
	 call $2176
	 jp   $20EC
	 exx
	 ld   de,$D155
	 call $1FC3
	 jp   (iy)
	 rst  $08
	 jr   z,$21BA
	 inc  bc
	 ret  nc
	 add  hl,hl
	 ld   b,$CF
	 jr   z,$21C1
	 ld   (bc),a
	 ret  nc
	 dec  h
	 ld   b,$CF
	 ld   hl,($1D1B)
	 call nc,$2B1D
	 inc  bc
	 sub  $21
	 ld   c,$20
	 ld   c,$06
	 add  hl,bc
	 ld   c,$2F
	 inc  l
	 dec  bc
	 dec  l
	 ld   c,$06
	 add  hl,bc
	 ld   c,$0F
	 dec  bc
	 ld   l,$09
	 cpl
	 ld   c,$2E
	 ld   c,$59
	 ld   c,$85
	 jr   nc,$21DD
	 xor  d
	 ld   sp,$1C0E
	 ld   ($3433),a
	 dec  (hl)
	 ld   b,$CF
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 inc  bc
	 jp   po,$3621
	 scf
	 ld   b,$CF
	 ld   hl,($2B38)
	 inc  bc
	 ld   (de),a
	 ld   ($110E),hl
	 ld   c,$35
	 ld   c,$66
	 jr   nc,$2200
	 sub  a
	 ld   sp,$080E
	 ld   ($4D1B),a
	 jp   nc,$3A39
	 ld   c,$80
	 rrca
	 ld   c,$14
	 rra
	 dec  de
	 ld   c,l
	 jp   nc,$3A3B
	 ld   a,($350E)
	 rrca
	 dec  l
	 add  hl,bc
	 inc  a
	 dec  bc
	 inc  bc
	 rst  $30
	 ld   hl,$CF06
	 ld   c,$16
	 ld   b,$CF
	 ld   c,$1E
	 ld   b,$CF
	 ld   c,$2F
	 ld   b,$CF
	 ld   c,$50
	 ld   b,$CF
	 dec  d
	 dec  a
	 jr   nc,$224A
	 inc  de
	 ld   ($2217),hl
	 dec  de
	 ld   ($221F),hl
	 ld   b,$CF
	 ld   hl,($2B38)
	 inc  bc
	 ld   e,l
	 ld   ($951B),hl
	 pop  de
	 dec  h
	 ld   a,$0E
	 djnz $227F
	 dec  c
	 dec  l
	 add  hl,bc
	 ld   c,$03
	 inc  de
	 dec  c
	 ld   c,$27
	 rrca
	 inc  b
	 ld   l,$09
	 cpl
	 ld   c,$64
	 ld   c,$42
	 ld   c,$2C
	 jr   nc,$2264
	 ld   (hl),a
	 ld   sp,$080E
	 ld   ($3433),a
	 ld   b,$CF
	 ld   hl,($021B)
	 ret  nc
	 dec  h
	 inc  bc
	 add  a,(hl)
	 ld   ($1C0E),hl
	 ld   ($BB0E),a
	 ld   sp,$4D1B
	 jp   nc,$3A39
	 ld   c,$80
	 rrca
	 ld   b,b
	 dec  de
	 ld   c,l
	 jp   nc,$3A3B
	 ld   a,($350E)
	 rrca
	 dec  l
	 add  hl,bc
	 inc  a
	 dec  bc
	 inc  bc
	 ld   l,l
	 ld   ($CF06),hl
	 ld   hl,($032B)
	 cp   a
	 ld   ($030E),hl
	 dec  l
	 ld   c,$08
	 ld   b,b
	 ld   c,$1D
	 ld   ($BC0E),a
	 ld   sp,$0B0E
	 dec  de
	 dec  d
	 call nc,$0E08
	 inc  b
	 ld   b,c
	 ld   b,c
	 ld   b,c
	 ld   b,d
	 dec  de
	 dec  d
	 call nc,$1B43
	 inc  bc
	 ret  nc
	 dec  h
	 ld   c,$03
	 ld   b,h
	 inc  bc
	 or   a
	 ld   ($031B),hl
	 ret  nc
	 add  hl,hl
	 dec  de
	 dec  d
	 call nc,$2725
	 inc  bc
	 sbc  a,a
	 ld   ($1B34),hl
	 dec  d
	 call nc,$1B1D
	 dec  e
	 call nc,$381D
	 ld   b,$CF
	 ld   hl,($2B38)
	 inc  bc
	 ld   sp,hl
	 ld   ($881B),hl
	 pop  de
	 dec  h
	 ld   a,$0D
	 dec  l
	 add  hl,bc
	 dec  de
	 cp   $FF
	 ld   c,$03
	 ld   b,l
	 dec  c
	 ld   c,$14
	 ccf
	 ld   l,$0E
	 adc  a,l
	 ld   c,$4A
	 ld   c,$1F
	 jr   nc,$22F5
	 cpl
	 ld   c,$16
	 ccf
	 ld   b,b
	 ld   c,$66
	 ld   sp,$170E
	 ld   ($3433),a
	 ld   b,$CF
	 ld   hl,($2B38)
	 inc  bc
	 inc  e
	 inc  hl
	 ld   c,$10
	 dec  l
	 ld   c,$20
	 add  hl,bc
	 dec  de
	 cp   $FF
	 dec  bc
	 inc  l
	 ld   c,$A9
	 ld   sp,$1A0E
	 ld   ($110E),a
	 ld   c,$07
	 ld   c,$40
	 ld   c,$68
	 ld   b,d
	 inc  (hl)
	 ld   b,$CF
	 ld   hl,($2B38)
	 inc  bc
	 ld   c,a
	 inc  hl
	 dec  de
	 adc  a,b
	 pop  de
	 dec  h
	 ld   a,$0E
	 ld   (bc),a
	 ccf
	 dec  c
	 dec  l
	 ld   c,$02
	 add  hl,bc
	 ld   c,$03
	 ld   b,l
	 dec  c
	 ld   c,$28
	 rrca
	 inc  b
	 ld   l,$09
	 cpl
	 ld   c,$14
	 ccf
	 ld   b,b
	 ld   c,$66
	 ld   sp,$170E
	 ld   ($640E),a
	 ld   c,$42
	 ld   c,$2C
	 jr   nc,$2381
	 inc  (hl)
	 ld   b,$CF
	 ld   hl,($032B)
	 adc  a,(hl)
	 inc  hl
	 ld   c,$80
	 dec  l
	 ld   c,$94
	 add  hl,bc
	 dec  de
	 call m,$0EFF
	 ld   h,b
	 inc  l
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 inc  bc
	 ld   (hl),b
	 inc  hl
	 ld   c,$FF
	 ld   c,$1F
	 ld   b,(hl)
	 ld   (hl),h
	 inc  hl
	 ld   c,$99
	 ld   c,$19
	 ld   ($0931),a
	 ld   c,$20
	 ld   c,$30
	 ld   c,$44
	 ld   b,d
	 dec  de
	 inc  bc
	 ret  nc
	 add  hl,hl
	 ld   c,$05
	 inc  a
	 ld   c,$70
	 dec  l
	 ld   c,$08
	 inc  a
	 ld   b,(hl)
	 adc  a,a
	 inc  hl
	 inc  (hl)
	 jr   c,$23C5
	 dec  (hl)
	 ld   b,$CF
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 add  hl,bc
	 ld   b,h
	 daa
	 inc  bc
	 xor  b
	 inc  hl
	 ld   c,$03
	 dec  de
	 inc  bc
	 ret  nc
	 ld   b,a
	 dec  de
	 ld   d,l
	 pop  de
	 ld   c,b
	 ld   b,$CF
	 ld   hl,($032B)
	 inc  bc
	 inc  h
	 ld   c,$22
	 dec  l
	 ld   c,$77
	 ld   sp,$070E
	 ld   ($180E),a
	 dec  de
	 ld   de,$25D0
	 inc  bc
	 jp   z,$0E23
	 ld   a,(hl)
	 ld   c,$8D
	 ld   c,$A8
	 ld   b,(hl)
	 ret  nc
	 inc  hl
	 ld   c,$BD
	 ld   c,$7E
	 ld   c,$4A
	 ld   b,d
	 dec  de
	 ld   bc,$25D0
	 inc  bc
	 call po,$0E23
	 xor  d
	 ld   sp,$1B09
	 cp   $FF
	 ld   c,$05
	 ld   b,(hl)
	 pop  af
	 inc  hl
	 ld   c,$02
	 dec  de
	 rst  $38
	 rst  $38
	 add  hl,bc
	 ld   c,$1B
	 dec  de
	 ld   d,l
	 pop  de
	 rrca
	 ld   c,c
	 cpl
	 ld   c,$24
	 ld   c,$04
	 ld   l,$0E
	 inc  b
	 ld   c,$17
	 rra
	 ld   c,$24
	 dec  l
	 ld   c,$1A
	 ld   ($3433),a
	 dec  (hl)
	 ld   b,$79
	 rst  $08
	 ld   hl,($052B)
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 ld   c,$FD
	 ld   c,$64
	 ld   c,$54
	 jr   nc,$2425
	 ld   d,b
	 dec  l
	 add  hl,bc
	 dec  de
	 rst  $38
	 rst  $38
	 ld   c,$50
	 ld   c,$08
	 ld   l,$0E
	 xor  d
	 ld   sp,$090E
	 ld   ($900E),a
	 inc  a
	 inc  (hl)
	 dec  de
	 ld   bc,$25D0
	 dec  de
	 di
	 call nc,$4C4B
	 inc  bc
	 inc  a
	 inc  h
	 dec  de
	 ld   (bc),a
	 ret  nc
	 add  hl,hl
	 dec  de
	 inc  bc
	 ret  nc
	 ld   c,l
	 dec  de
	 dec  e
	 call nc,$4E25
	 inc  bc
	 ld   e,h
	 inc  h
	 ld   c,$02
	 dec  de
	 inc  bc
	 ret  nc
	 ex   af,af'
	 dec  de
	 ld   d,l
	 pop  de
	 inc  b
	 dec  d
	 dec  a
	 ld   e,h
	 inc  h
	 ex   (sp),hl
	 ld   hl,$225E
	 add  a,a
	 ld   ($0635),hl
	 rst  $08
	 ld   hl,($032B)
	 sub  d
	 inc  h
	 ld   c,$22
	 dec  l
	 ld   c,$1E
	 ld   c,$22
	 ld   c,$44
	 ld   c,$22
	 ld   l,$0E
	 ex   af,af'
	 ld   c,$66
	 ld   c,$55
	 ld   c,$40
	 jr   nc,$2488
	 call z,$0E31
	 dec  c
	 ld   ($020E),a
	 cpl
	 dec  de
	 ld   d,l
	 pop  de
	 ld   c,$1C
	 rrca
	 ld   c,c
	 inc  sp
	 dec  de
	 dec  d
	 call nc,$2725
	 inc  bc
	 ld   a,a
	 inc  h
	 inc  (hl)
	 dec  (hl)
	 ld   b,$CF
	 ld   hl,($032B)
	 cp   c
	 inc  h
	 ld   c,$85
	 ld   c,$77
	 ld   c,$59
	 jr   nc,$24B1
	 ld   b,b
	 dec  l
	 add  hl,bc
	 dec  de
	 call m,$0EFF
	 ld   b,b
	 ld   c,$08
	 ld   l,$0E
	 ld   d,$2F
	 ld   c,$DD
	 ld   sp,$0F0E
	 ld   ($3433),a
	 dec  (hl)
	 ld   b,$2A
	 sbc  a,b
	 ret  nc
	 ld   de,$001A
	 add  hl,de
	 res  4,(hl)
	 res  5,(hl)
	 jp   (iy)
	 ld   a,(iy+$1a)
	 xor  $80
	 ld   (iy+$1a),a
	 ret
	 ld   a,(iy+$1a)
	 xor  $40
	 ld   (iy+$1a),a
	 ret
	 rst  $08
	 dec  de
	 dec  l
	 call nc,$0D25
	 inc  bc
	 rst  $20
	 inc  h
	 dec  de
	 dec  l
	 call nc,$0643
	 rst  $08
	 dec  de
	 ld   l,$D4
	 dec  h
	 dec  c
	 inc  bc
	 push af
	 inc  h
	 dec  de
	 ld   l,$D4
	 ld   b,e
	 ld   b,$CF
	 dec  bc
	 dec  de
	 inc  l
	 call nc,$0608
	 rst  $08
	 ld   c,$07
	 dec  de
	 inc  l
	 call nc,$0E08
	 ld   b,$4F
	 ld   b,$CF
	 ld   d,b
	 ld   d,c
	 ld   c,$05
	 ld   d,d
	 ld   c,a
	 ld   b,$FD
	 sla  h
	 sbc  a,$C9
; Alternate alien-ship destruction sequence used by the gameplay script.
ALIEN_SHIP_DESTROY_SEQUENCE_ALT:
        DB      $02
        DW      BLANK
        DB      $03
        DW      ALIEN_SHIP_DESTROY_1
        DB      $03
        DW      ALIEN_SHIP_DESTROY_2
        DB      $03
        DW      ALIEN_SHIP_DESTROY_3
        DB      $04
        DW      ALIEN_SHIP_DESTROY_4
        DB      $FF
        DW      BLANK
        DB      $00
        DW      ALIEN_SHIP_DESTROY_SEQUENCE
	 ld   hl,($D098)
	 ld   de,$001C
	 add  hl,de
	 ld   (hl),$00
	 inc  hl
	 ld   (hl),$28
	 jp   (iy)
	 ld   hl,($D098)
	 ld   de,$001E
	 add  hl,de
	 ld   (hl),$C0
	 inc  hl
	 ld   (hl),$18
	 jp   (iy)
	 ld   a,$01
	 ld   ($D431),a
	 ret
	 pop  de
	 ld   hl,($D426)
	 add  hl,de
	 add  hl,de
	 ld   ($D426),hl
	 ld   a,($D014)
	 ld   l,a
	 ld   a,($D001)
	 or   l
	 jp   nz,$257C
	 ld   a,($D011)
	 or   a
	 jp   nz,$2571
	 ld   hl,($D015)
	 add  hl,de
	 ld   de,$D015
	 jp   $2578
	 ld   hl,($D017)
	 add  hl,de
	 ld   de,$D017
	 ex   de,hl
	 call $1EBB
	 ld   a,($D011)
	 or   a
	 jp   z,$25AA
	 ld   hl,($D017)
	 ld   de,($D01B)
	 sbc  hl,de
	 jp   c,$25A7
	 ld   hl,$D013
	 ld   e,(hl)
	 inc  e
	 call $1EDE
	 ld   hl,($D01B)
	 ld   e,l
	 ld   d,h
	 add  hl,de
	 ld   de,$D01B
	 ex   de,hl
	 call $1EBB
	 call $2546
	 jp   $25CE
	 ld   hl,($D015)
	 ld   de,($D019)
	 sbc  hl,de
	 jp   c,$25CE
	 ld   hl,$D012
	 ld   e,(hl)
	 inc  e
	 call $1EDE
	 ld   hl,($D019)
	 ld   e,l
	 ld   d,h
	 add  hl,de
	 ld   de,$D019
	 ex   de,hl
	 call $1EBB
	 call $2546
	 jp   (iy)
	 rst  $08
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   e,$26
	 ld   c,$10
	 dec  de
	 add  a,a
	 ret  nc
	 ex   af,af'
	 dec  de
	 inc  d
	 ret  nc
	 ld   c,d
	 dec  de
	 inc  hl
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   bc,$25D0
	 daa
	 inc  bc
	 ld   a,(de)
	 ld   h,$1B
	 ld   de,$25D0
	 inc  bc
	 call m,$1B25
	 inc  de
	 ret  nc
	 ld   b,(hl)
	 rst  $38
	 dec  h
	 dec  de
	 ld   (de),a
	 ret  nc
	 dec  c
	 dec  h
	 inc  bc
	 ex   af,af'
	 ld   h,$53
	 ld   b,(hl)
	 add  hl,bc
	 ld   h,$05
	 dec  de
	 ld   (de),a
	 ret  nc
	 dec  h
	 dec  de
	 inc  de
	 ret  nc
	 dec  h
	 ld   d,h
	 daa
	 inc  bc
	 ld   a,(de)
	 ld   h,$1B
	 ld   bc,$4AD0
	 dec  de
	 ld   bc,$55D2
	 ld   b,$CF
	 dec  de
	 sbc  a,h
	 pop  de
	 inc  c
	 dec  de
	 nop
	 ld   bc,$0307
	 ld   sp,$1B26
	 pop  af
	 ld   a,(de)
	 ld   b,(hl)
	 inc  (hl)
	 ld   h,$1B
	 rst  $18
	 ld   a,(de)
	 ld   b,$CF
	 dec  de
	 sbc  a,h
	 pop  de
	 inc  c
	 dec  c
	 ld   a,($060F)
	 rst  $08
	 ld   hl,($5756)
	 ld   e,b
	 ld   e,c
	 ld   e,d
	 dec  de
	 nop
	 ld   bc,$1B5B
	 djnz $2671
	 ld   e,h
	 ld   b,c
	 ld   e,l
	 ld   c,$88
	 ld   e,(hl)
	 dec  de
	 ld   a,b
	 rst  $38
	 ld   e,a
	 ld   c,$88
	 ld   h,b
	 dec  de
	 ld   a,b
	 rst  $38
	 ld   h,c
	 ld   b,c
	 ld   c,$0F
	 ld   c,h
	 ld   c,$05
	 ld   (bc),a
	 inc  bc
	 ld   l,b
	 ld   h,$62
	 ld   (hl),$63
	 ld   c,$60
	 rrca
	 ld   b,c
	 ld   c,$0F
	 ld   c,h
	 rrca
	 dec  de
	 nop
	 ld   b,$64
	 ld   e,e
	 ld   b,c
	 ld   c,$0C
	 ld   c,h
	 ld   c,$04
	 ld   d,d
	 ld   h,l
	 ld   h,(hl)
	 ld   d,a
	 ld   h,a
	 ld   l,b
	 ld   l,c
	 ld   l,d
	 dec  de
	 dec  d
	 dec  h
	 ld   l,e
	 ld   c,$10
	 ld   c,a
	 ld   l,h
	 ld   l,l
	 ld   b,c
	 ld   c,$07
	 ld   c,h
	 ld   c,$02
	 rlca
	 inc  bc
	 xor  (hl)
	 ld   h,$6E
	 dec  de
	 sub  c
	 pop  de
	 dec  h
	 ld   c,$40
	 rrca
	 ld   b,c
	 ld   c,$3F
	 ld   c,h
	 rrca
	 dec  c
	 dec  de
	 sub  c
	 pop  de
	 ex   af,af'
	 ld   e,l
	 ld   b,(hl)
	 or   c
	 ld   h,$56
	 ld   b,c
	 ld   e,l
	 ld   l,a
	 inc  bc
	 ld   e,l
	 ld   h,$06
	 rst  $08
	 ld   hl,($5756)
	 ld   e,b
	 ld   (hl),b
	 ld   e,d
	 ld   (hl),c
	 ld   h,a
	 ld   l,d
	 ld   (hl),d
	 ld   (hl),e
	 ld   d,b
	 ld   h,d
	 dec  de
	 ret
	 dec  e
	 ld   l,e
	 ld   c,$26
	 ld   c,a
	 ld   l,h
	 ld   l,l
	 ld   l,a
	 inc  bc
	 ret  nz
	 ld   h,$06
; $26D2-$270C: twelve 16-bit literal-return TERSE colon definitions.
TERSE_COLON_26D2:
	 RST $08
	 DB $1B ; LIT16
	 DW $D299 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26D7:
	 RST $08
	 DB $1B ; LIT16
	 DW $D2E5 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26DC:
	 RST $08
	 DB $1B ; LIT16
	 DW $D331 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26E1:
	 RST $08
	 DB $1B ; LIT16
	 DW $D37D ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26E6:
	 RST $08
	 DB $1B ; LIT16
	 DW $D18D ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26EB:
	 RST $08
	 DB $1B ; LIT16
	 DW $D18E ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26F0:
	 RST $08
	 DB $1B ; LIT16
	 DW $D18F ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26F5:
	 RST $08
	 DB $1B ; LIT16
	 DW $D190 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26FA:
	 RST $08
	 DB $1B ; LIT16
	 DW $D1A1 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_26FF:
	 RST $08
	 DB $1B ; LIT16
	 DW $D1A2 ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_2704:
	 RST $08
	 DB $1B ; LIT16
	 DW $D19F ; address/value
	 DB $06 ; TERSE_EXIT

TERSE_COLON_2709:
	 RST $08
	 DB $1B ; LIT16
	 DW $D1A0 ; address/value

;==============================================================================
; TERSE COMPILED WORDS $270D-$2AE0
;==============================================================================
; Native indexed tokens and inline operands, represented as typed ROM data.
	 DB $06 ; EXIT for the preceding LIT16 address word

; Original TERSE colon word at $270E
TERSE_COLON_270E:
	 RST $08
	 DB $1B ; $270F token -> native $0050
	 DW $1A37 ; LIT16
	 DB $06 ; $2712 token -> native $0044

; Original TERSE colon word at $2713
TERSE_COLON_2713:
	 RST $08
	 DB $1B ; $2714 token -> native $0050
	 DW $1A40 ; LIT16
	 DB $06 ; $2717 token -> native $0044

; Original TERSE colon word at $2718
TERSE_COLON_2718:
	 RST $08
	 DB $74 ; $2719 token -> native $254C
	 DB $1B ; $271A token -> native $0050
	 DW $D003 ; LIT16
	 DB $25 ; $271D token -> native $00A4
	 DB $27 ; $271E token -> native $0139
	 DB $03 ; $271F token -> native $01FC
	 DW TERSE_THREAD_2726 ; 0BRANCH
	 DB $1B ; $2722 token -> native $0050
	 DW $D155 ; LIT16
	 DB $75 ; $2725 token -> native $22FA
TERSE_THREAD_2726:
	 DB $58 ; $2726 token -> native $1212
	 DB $70 ; $2727 token -> native $11AB
	 DB $1B ; $2728 token -> native $0050
	 DW $1DC9 ; LIT16
	 DB $6B ; $272B token -> native $10B7
	 DB $0E ; $272C token -> native $0059
	 DB $26 ; LIT8
	 DB $4F ; $272E token -> native $0EC7
	 DB $06 ; $272F token -> native $0044

; Original TERSE colon word at $2730
TERSE_COLON_2730:
	 RST $08
	 DB $0B ; $2731 token -> native $007B
	 DB $17 ; $2732 token -> native $10DA
	 DB $1B ; $2733 token -> native $0050
	 DW $FFA8 ; LIT16
	 DB $18 ; $2736 token -> native $10EC
	 DB $1B ; $2737 token -> native $0050
	 DW $1A2B ; LIT16
	 DB $06 ; $273A token -> native $0044

; Original TERSE colon word at $273B
TERSE_COLON_273B:
	 RST $08
	 DB $0B ; $273C token -> native $007B
	 DB $17 ; $273D token -> native $10DA
	 DB $0E ; $273E token -> native $0059
	 DB $58 ; LIT8
	 DB $18 ; $2740 token -> native $10EC
	 DB $1B ; $2741 token -> native $0050
	 DW $1A2B ; LIT16
	 DB $76 ; $2744 token -> native $11D0
	 DB $06 ; $2745 token -> native $0044

; Original TERSE colon word at $2746
TERSE_COLON_2746:
	 RST $08
	 DB $0E ; $2747 token -> native $0059
	 DB $8C ; LIT8
	 DB $17 ; $2749 token -> native $10DA
	 DB $0B ; $274A token -> native $007B
	 DB $18 ; $274B token -> native $10EC
	 DB $1B ; $274C token -> native $0050
	 DW $1A31 ; LIT16
	 DB $06 ; $274F token -> native $0044

; Original TERSE colon word at $2750
TERSE_COLON_2750:
	 RST $08
	 DB $1B ; $2751 token -> native $0050
	 DW $FF74 ; LIT16
	 DB $17 ; $2754 token -> native $10DA
	 DB $0B ; $2755 token -> native $007B
	 DB $18 ; $2756 token -> native $10EC
	 DB $1B ; $2757 token -> native $0050
	 DW $1A31 ; LIT16
	 DB $77 ; $275A token -> native $11DB
	 DB $06 ; $275B token -> native $0044

; Original TERSE colon word at $275C
TERSE_COLON_275C:
	 RST $08
	 DB $2A ; $275D token -> native $042F
	 DB $0E ; $275E token -> native $0059
	 DB $0C ; LIT8
	 DB $65 ; $2760 token -> native $1195
	 DB $56 ; $2761 token -> native $11C3
	 DB $71 ; $2762 token -> native $1166
TERSE_THREAD_2763:
	 DB $57 ; $2763 token -> native $121C
	 DB $6A ; $2764 token -> native $10CD
	 DB $19 ; $2765 token -> native $11FC
	 DB $1A ; $2766 token -> native $1207
	 DB $70 ; $2767 token -> native $11AB
	 DB $35 ; $2768 token -> native $04A6
	 DB $78 ; $2769 token -> native $24DA
	 DB $4E ; $276A token -> native $013F
	 DB $27 ; $276B token -> native $0139
	 DB $03 ; $276C token -> native $01FC
	 DW TERSE_THREAD_2809 ; 0BRANCH
	 DB $68 ; $276F token -> native $1229
	 DB $1B ; $2770 token -> native $0050
	 DW $D19A ; LIT16
	 DB $1D ; $2773 token -> native $0266
	 DB $1B ; $2774 token -> native $0050
	 DW $D188 ; LIT16
	 DB $25 ; $2777 token -> native $00A4
	 DB $15 ; $2778 token -> native $00D4
	 DB $3D ; $2779 token -> native $023E
	 DB $84 ; $277A token -> native $0FEE
	 DB $27 ; $277B token -> native $0139
	 DB $3B ; $277C token -> native $112D
	 DB $27 ; $277D token -> native $0139
	 DB $46 ; $277E token -> native $01F4
	 DW $3027 ; BRANCH
	 DB $27 ; $2781 token -> native $0139
	 DB $50 ; $2782 token -> native $24F6
	 DB $27 ; $2783 token -> native $0139
	 DB $6B ; $2784 token -> native $10B7
	 DB $1B ; $2785 token -> native $0050
	 DW $D18C ; LIT16
	 DB $25 ; $2788 token -> native $00A4
	 DB $4E ; $2789 token -> native $013F
	 DB $03 ; $278A token -> native $01FC
	 DW TERSE_THREAD_279B ; 0BRANCH
	 DB $0D ; $278D token -> native $0087
	 DB $1B ; $278E token -> native $0050
	 DW $D18B ; LIT16
	 DB $25 ; $2791 token -> native $00A4
	 DB $04 ; $2792 token -> native $0097
	 DB $3F ; $2793 token -> native $00C5
	 DB $1B ; $2794 token -> native $0050
	 DW $D19B ; LIT16
	 DB $08 ; $2797 token -> native $00B2
	 DB $46 ; $2798 token -> native $01F4
	 DW TERSE_THREAD_27A3 ; BRANCH
TERSE_THREAD_279B:
	 DB $1B ; $279B token -> native $0050
	 DW $D18B ; LIT16
	 DB $25 ; $279E token -> native $00A4
	 DB $1B ; $279F token -> native $0050
	 DW $D19B ; LIT16
	 DB $1D ; $27A2 token -> native $0266
TERSE_THREAD_27A3:
	 DB $4F ; $27A3 token -> native $0EC7
	 DB $1B ; $27A4 token -> native $0050
	 DW $D19A ; LIT16
	 DB $79 ; $27A7 token -> native $0EDA
	 DB $6C ; $27A8 token -> native $0CE2
	 DB $7A ; $27A9 token -> native $0EED
	 DB $1B ; $27AA token -> native $0050
	 DW $D19A ; LIT16
	 DB $25 ; $27AD token -> native $00A4
	 DB $54 ; $27AE token -> native $0154
	 DB $03 ; $27AF token -> native $01FC
	 DW TERSE_THREAD_27B9 ; 0BRANCH
	 DB $0E ; $27B2 token -> native $0059
	 DB $32 ; LIT8
	 DB $7B ; $27B4 token -> native $2718
	 DB $6C ; $27B5 token -> native $0CE2
	 DB $46 ; $27B6 token -> native $01F4
	 DW TERSE_THREAD_2807 ; BRANCH
TERSE_THREAD_27B9:
	 DB $1B ; $27B9 token -> native $0050
	 DW $D18C ; LIT16
	 DB $25 ; $27BC token -> native $00A4
	 DB $03 ; $27BD token -> native $01FC
	 DW TERSE_THREAD_2807 ; 0BRANCH
	 DB $1B ; $27C0 token -> native $0050
	 DW $D188 ; LIT16
	 DB $25 ; $27C3 token -> native $00A4
	 DB $15 ; $27C4 token -> native $00D4
	 DB $0D ; $27C5 token -> native $0087
	 DB $0D ; $27C6 token -> native $0087
	 DB $3D ; $27C7 token -> native $023E
	 DB $D2 ; $27C8 token -> native $0120
	 DB $27 ; $27C9 token -> native $0139
	 DB $D2 ; $27CA token -> native $0120
	 DB $26 ; $27CB token -> native $0188
	 DB $D7 ; $27CC token -> native $3222
	 DB $26 ; $27CD token -> native $0188
	 DB $DC ; $27CE token -> native $34BE
	 DB $26 ; $27CF token -> native $0188
	 DB $E1 ; $27D0 token -> native $328A
	 DB $26 ; $27D1 token -> native $0188
	 DB $0D ; $27D2 token -> native $0087
	 DB $4B ; $27D3 token -> native $1237
	 DB $03 ; $27D4 token -> native $01FC
	 DW TERSE_THREAD_27F3 ; 0BRANCH
	 DB $55 ; $27D7 token -> native $04BB
	 DB $3D ; $27D8 token -> native $023E
	 DB $E3 ; $27D9 token -> native $3377
	 DB $27 ; $27DA token -> native $0139
	 DB $E6 ; $27DB token -> native $28AA
	 DB $26 ; $27DC token -> native $0188
	 DB $EB ; $27DD token -> native $2495
	 DB $26 ; $27DE token -> native $0188
	 DB $F0 ; $27DF token -> native $2231
	 DB $26 ; $27E0 token -> native $0188
	 DB $F5 ; $27E1 token -> native $01BF
	 DB $26 ; $27E2 token -> native $0188
	 DB $49 ; $27E3 token -> native $0262
	 DB $3D ; $27E4 token -> native $023E
	 DB $EF ; $27E5 token -> native $3BD9
	 DB $27 ; $27E6 token -> native $0139
	 DB $0E ; $27E7 token -> native $0059
	 DB $27 ; LIT8
	 DB $13 ; $27E9 token -> native $01E3
	 DB $27 ; $27EA token -> native $0139
	 DB $0E ; $27EB token -> native $0059
	 DB $27 ; LIT8
	 DB $13 ; $27ED token -> native $01E3
	 DB $27 ; $27EE token -> native $0139
	 DB $6B ; $27EF token -> native $10B7
	 DB $46 ; $27F0 token -> native $01F4
	 DW TERSE_THREAD_27F5 ; BRANCH
TERSE_THREAD_27F3:
	 DB $05 ; $27F3 token -> native $0094
	 DB $05 ; $27F4 token -> native $0094
TERSE_THREAD_27F5:
	 DB $1B ; $27F5 token -> native $0050
	 DW $D19B ; LIT16
	 DB $25 ; $27F8 token -> native $00A4
	 DB $4F ; $27F9 token -> native $0EC7
	 DB $1B ; $27FA token -> native $0050
	 DW $D19A ; LIT16
	 DB $79 ; $27FD token -> native $0EDA
	 DB $6C ; $27FE token -> native $0CE2
	 DB $7A ; $27FF token -> native $0EED
	 DB $03 ; $2800 token -> native $01FC
	 DW TERSE_THREAD_2807 ; 0BRANCH
	 DB $0E ; $2803 token -> native $0059
	 DB $32 ; LIT8
	 DB $7B ; $2805 token -> native $2718
	 DB $6C ; $2806 token -> native $0CE2
TERSE_THREAD_2807:
	 DB $6D ; $2807 token -> native $12C7
	 DB $78 ; $2808 token -> native $24DA
TERSE_THREAD_2809:
	 DB $03 ; $2809 token -> native $01FC
	 DW TERSE_THREAD_2763 ; 0BRANCH
	 DB $36 ; $280C token -> native $1216
	 DB $7C ; $280D token -> native $263E
	 DB $06 ; $280E token -> native $0044

; Original TERSE colon word at $280F
TERSE_COLON_280F:
	 RST $08
	 DB $0E ; $2810 token -> native $0059
	 DB $0A ; LIT8
	 DB $06 ; $2812 token -> native $0044

; Original TERSE colon word at $2813
TERSE_COLON_2813:
	 RST $08
	 DB $1B ; $2814 token -> native $0050
	 DW $FFF6 ; LIT16
	 DB $06 ; $2817 token -> native $0044

; Original TERSE colon word at $2818
TERSE_COLON_2818:
	 RST $08
	 DB $0E ; $2819 token -> native $0059
	 DB $0B ; LIT8
	 DB $06 ; $281B token -> native $0044

; Original TERSE colon word at $281C
TERSE_COLON_281C:
	 RST $08
	 DB $1B ; $281D token -> native $0050
	 DW $FFF5 ; LIT16
	 DB $06 ; $2820 token -> native $0044

; Original TERSE colon word at $2821
TERSE_COLON_2821:
	 RST $08
	 DB $0B ; $2822 token -> native $007B
	 DB $06 ; $2823 token -> native $0044

; Original TERSE colon word at $2824
TERSE_COLON_2824:
	 RST $08
	 DB $09 ; $2825 token -> native $0081
	 DB $06 ; $2826 token -> native $0044

; Original TERSE colon word at $2827
TERSE_COLON_2827:
	 RST $08
	 DB $0E ; $2828 token -> native $0059
	 DB $02 ; LIT8
	 DB $06 ; $282A token -> native $0044

; Original TERSE colon word at $282B
TERSE_COLON_282B:
	 RST $08
	 DB $0E ; $282C token -> native $0059
	 DB $03 ; LIT8
	 DB $06 ; $282E token -> native $0044

; Original TERSE colon word at $282F
TERSE_COLON_282F:
	 RST $08
	 DB $0E ; $2830 token -> native $0059
	 DB $C0 ; LIT8
	 DB $06 ; $2832 token -> native $0044

; Original TERSE colon word at $2833
TERSE_COLON_2833:
	 RST $08
	 DB $0E ; $2834 token -> native $0059
	 DB $80 ; LIT8
	 DB $06 ; $2836 token -> native $0044

; Original TERSE colon word at $2837
TERSE_COLON_2837:
	 RST $08
	 DB $0E ; $2838 token -> native $0059
	 DB $40 ; LIT8
	 DB $06 ; $283A token -> native $0044

; Original TERSE colon word at $283B
TERSE_COLON_283B:
	 RST $08
	 DB $0E ; $283C token -> native $0059
	 DB $18 ; LIT8
	 DB $7D ; $283E token -> native $100A
	 DB $7E ; $283F token -> native $2833
	 DB $06 ; $2840 token -> native $0044

; Original TERSE colon word at $2841
TERSE_COLON_2841:
	 RST $08
	 DB $1B ; $2842 token -> native $0050
	 DW $FFE8 ; LIT16
	 DB $7F ; $2845 token -> native $1026
	 DB $80 ; $2846 token -> native $282F
	 DB $06 ; $2847 token -> native $0044

; Original TERSE colon word at $2848
TERSE_COLON_2848:
	 RST $08
	 DB $1B ; $2849 token -> native $0050
	 DW $FFE8 ; LIT16
	 DB $7D ; $284C token -> native $100A
	 DB $0B ; $284D token -> native $007B
	 DB $06 ; $284E token -> native $0044

; Original TERSE colon word at $284F
TERSE_COLON_284F:
	 RST $08
	 DB $0E ; $2850 token -> native $0059
	 DB $18 ; LIT8
	 DB $7F ; $2852 token -> native $1026
	 DB $81 ; $2853 token -> native $2837
	 DB $06 ; $2854 token -> native $0044

; Original TERSE colon word at $2855
TERSE_COLON_2855:
	 RST $08
	 DB $1B ; $2856 token -> native $0050
	 DW $D198 ; LIT16
	 DB $25 ; $2859 token -> native $00A4
	 DB $3D ; $285A token -> native $023E
	 DB $65 ; $285B token -> native $1195
	 DB $28 ; $285C token -> native $2193
	 DB $EB ; $285D token -> native $2495
	 DB $26 ; $285E token -> native $0188
	 DB $F0 ; $285F token -> native $2231
	 DB $26 ; $2860 token -> native $0188
	 DB $F5 ; $2861 token -> native $01BF
	 DB $26 ; $2862 token -> native $0188
	 DB $E6 ; $2863 token -> native $28AA
	 DB $26 ; $2864 token -> native $0188
	 DB $06 ; $2865 token -> native $0044

; Mixed token/data record
TERSE_DATA_2866:
	 DB $CF,$1B,$98,$D1,$25,$3D,$76,$28,$09,$27,$FA,$26,$FF,$26,$04,$27 ; $2866-$2875
	 DB $06 ; $2876-$2876

; Original TERSE colon word at $2877
TERSE_COLON_2877:
	 RST $08
	 DB $1B ; $2878 token -> native $0050
	 DW $D198 ; LIT16
	 DB $25 ; $287B token -> native $00A4
	 DB $3D ; $287C token -> native $023E
	 DB $87 ; $287D token -> native $1042
	 DB $28 ; $287E token -> native $2193
	 DB $D7 ; $287F token -> native $3222
	 DB $26 ; $2880 token -> native $0188
	 DB $DC ; $2881 token -> native $34BE
	 DB $26 ; $2882 token -> native $0188
	 DB $E1 ; $2883 token -> native $328A
	 DB $26 ; $2884 token -> native $0188
	 DB $D2 ; $2885 token -> native $0120
	 DB $26 ; $2886 token -> native $0188
	 DB $06 ; $2887 token -> native $0044

; Original TERSE colon word at $2888
TERSE_COLON_2888:
	 RST $08
	 DB $0E ; $2889 token -> native $0059
	 DB $37 ; LIT8
	 DB $0E ; $288B token -> native $0059
	 DB $37 ; LIT8
	 DB $0B ; $288D token -> native $007B
	 DB $06 ; $288E token -> native $0044

; Original TERSE colon word at $288F
TERSE_COLON_288F:
	 RST $08
	 DB $0E ; $2890 token -> native $0059
	 DB $37 ; LIT8
	 DB $0E ; $2892 token -> native $0059
	 DB $37 ; LIT8
	 DB $82 ; $2894 token -> native $00CD
	 DB $09 ; $2895 token -> native $0081
	 DB $06 ; $2896 token -> native $0044

; Original TERSE colon word at $2897
TERSE_COLON_2897:
	 RST $08
	 DB $0E ; $2898 token -> native $0059
	 DB $37 ; LIT8
	 DB $82 ; $289A token -> native $00CD
	 DB $0E ; $289B token -> native $0059
	 DB $37 ; LIT8
	 DB $82 ; $289D token -> native $00CD
	 DB $0E ; $289E token -> native $0059
	 DB $02 ; LIT8
	 DB $06 ; $28A0 token -> native $0044

; Original TERSE colon word at $28A1
TERSE_COLON_28A1:
	 RST $08
	 DB $0E ; $28A2 token -> native $0059
	 DB $37 ; LIT8
	 DB $82 ; $28A4 token -> native $00CD
	 DB $0E ; $28A5 token -> native $0059
	 DB $37 ; LIT8
	 DB $0E ; $28A7 token -> native $0059
	 DB $03 ; LIT8
	 DB $06 ; $28A9 token -> native $0044

; Additional original compiled bytes; operand contracts not yet assigned
TERSE_DATA_28AA:
	 DB $CF,$2A,$41,$0E,$07,$4C,$1B,$11,$D0,$25,$03,$BD,$28,$1B,$93,$D1 ; $28AA-$28B9
	 DB $46,$C0,$28,$1B,$92,$D1,$25,$0F,$09,$52,$1B,$96,$D1,$08,$0E,$0C ; $28BA-$28C9
	 DB $65,$56,$71,$6A,$57,$58,$70,$1B,$92,$1E,$6B,$41,$0E,$03,$4C,$3D ; $28CA-$28D9
	 DB $E4,$28,$88,$28,$8F,$28,$97,$28,$A1,$28,$1B,$97,$D1,$08,$18,$17 ; $28DA-$28E9
	 DB $0E,$58,$5E,$1B,$A8,$FF,$5F,$0E,$58,$60,$1B,$A8,$FF,$61,$41,$0E ; $28EA-$28F9
	 DB $07,$4C,$0E,$04,$02,$1B,$94,$D1,$08,$1B,$97,$D1,$25,$3D,$12,$29 ; $28FA-$2909
	 DB $18,$28,$18,$28,$1C,$28,$1C,$28,$7D,$1B,$97,$D1,$25,$3D,$22,$29 ; $290A-$2919
	 DB $0F,$28,$13,$28,$13,$28,$0F,$28,$7F,$1B,$97,$D1,$25,$1B,$94,$D1 ; $291A-$2929
	 DB $25,$03,$3C,$29,$3D,$39,$29,$7B,$00,$37,$28,$33,$28,$2F,$28,$46 ; $292A-$2939
	 DB $47,$29,$3D,$47,$29,$2F,$28,$7B,$00,$37,$28,$33,$28,$5D,$1B,$00 ; $293A-$2949
	 DB $03,$5B,$66,$1B,$94,$D1,$25,$03,$59,$29,$0E,$20,$46,$5C,$29,$1B ; $294A-$2959
	 DB $E0,$FF,$0E,$10,$83,$0E,$10,$4F,$84,$85,$69,$68,$6C,$66,$1B,$94 ; $295A-$2969
	 DB $D1,$25,$03,$74,$29,$0E,$20,$46,$77,$29,$1B,$E0,$FF,$0E,$10,$83 ; $296A-$2979
	 DB $0E,$10,$4F,$84,$85,$69,$6C,$66,$86,$27,$03,$8B,$29,$84,$85,$69 ; $297A-$2989
	 DB $6C,$87,$03,$CC,$29,$36,$88,$82,$7D,$1B,$97,$D1,$25,$3D,$A2,$29 ; $298A-$2999
	 DB $33,$28,$33,$28,$7B,$00,$7B,$00,$5D,$1B,$97,$D1,$25,$3D,$B2,$29 ; $299A-$29A9
	 DB $2B,$28,$24,$28,$24,$28,$2B,$28,$1B,$98,$D1,$08,$1B,$97,$D1,$25 ; $29AA-$29B9
	 DB $3D,$C5,$29,$2B,$28,$27,$28,$24,$28,$21,$28,$1B,$97,$D1,$08,$46 ; $29BA-$29C9
	 DB $06,$2A,$36,$89,$82,$7F,$1B,$97,$D1,$25,$3D,$DF,$29,$37,$28,$2F ; $29CA-$29D9
	 DB $28,$2F,$28,$37,$28,$5D,$1B,$97,$D1,$25,$3D,$EF,$29,$21,$28,$21 ; $29DA-$29E9
	 DB $28,$27,$28,$27,$28,$1B,$98,$D1,$08,$1B,$97,$D1,$25,$3D,$02,$2A ; $29EA-$29F9
	 DB $24,$28,$21,$28,$2B,$28,$27,$28,$1B,$97,$D1,$08,$68,$1B,$98,$D1 ; $29FA-$2A09
	 DB $25,$3D,$16,$2A,$38,$25,$2A,$25,$38,$25,$2A,$25,$8A,$1D,$8B,$49 ; $2A0A-$2A19
	 DB $8A,$79,$36,$0E,$1C,$0F,$0C,$8C,$0E,$1C,$0F,$10,$36,$0E,$1E,$0F ; $2A1A-$2A29
	 DB $0C,$8C,$0E,$1E,$0F,$10,$1B,$96,$D1,$43,$1B,$96,$D1,$25,$27,$03 ; $2A2A-$2A39
	 DB $96,$2A,$1B,$98,$D1,$25,$3D,$4B,$2A,$3B,$28,$41,$28,$48,$28,$4F ; $2A3A-$2A49
	 DB $28,$5D,$66,$1B,$03,$D0,$25,$0E,$02,$44,$03,$61,$2A,$0E,$02,$1B ; $2A4A-$2A59
	 DB $1D,$D4,$08,$1B,$55,$D1,$8D,$6C,$7A,$03,$6C,$2A,$0E,$C8,$74,$46 ; $2A5A-$2A69
	 DB $71,$2A,$8E,$1B,$C9,$D3,$55,$1B,$03,$D0,$25,$0E,$02,$44,$03,$88 ; $2A6A-$2A79
	 DB $2A,$0E,$03,$1B,$1D,$D4,$08,$1B,$55,$D1,$8F,$46,$8C,$2A,$1B,$1D ; $2A7A-$2A89
	 DB $D4,$1D,$71,$8B,$1D,$0B,$7B,$6C,$09,$46,$C6,$2A,$66,$6C,$7A,$8A ; $2A8A-$2A99
	 DB $25,$54,$03,$C5,$2A,$71,$8B,$1D,$0E,$C8,$7B,$1B,$03,$D0,$25,$0E ; $2A9A-$2AA9
	 DB $02,$44,$03,$BC,$2A,$0E,$03,$1B,$1D,$D4,$08,$1B,$55,$D1,$8F,$46 ; $2AAA-$2AB9
	 DB $C0,$2A,$1B,$1D,$D4,$1D,$6C,$09,$46,$C6,$2A,$0B,$8B,$1D,$8A,$1D ; $2ABA-$2AC9
	 DB $03,$03,$29,$6D,$1B,$14,$D0,$25,$03,$DF,$2A,$90,$78,$03,$D5,$2A ; $2ACA-$2AD9
	 DB $36,$91,$46,$E1,$2A,$36,$92 ; $2ADA-$2AE0

; $2AE1: EXIT of preceding TERSE definition.
	 DB $06 ; TERSE_EXIT
; $2AE2: original compiled TERSE game-control word.
TERSE_COLON_2AE2:
	 RST $08
	 DB $1B ; $2AE3 -> $0050
	 DW $D188 ; LIT16
	 DB $25 ; $2AE6 -> $00A4
	 DB $44 ; $2AE7 -> $00EE
	 DB $03 ; $2AE8 -> $01FC
	 DW TERSE_THREAD_2AF1 ; 0BRANCH
	 DB $1B ; $2AEB -> $0050
	 DW $D19A ; LIT16
	 DB $46 ; $2AEE -> $01F4
	 DW TERSE_THREAD_2AF4 ; BRANCH
TERSE_THREAD_2AF1:
	 DB $1B ; $2AF1 -> $0050
	 DW $D199 ; LIT16
TERSE_THREAD_2AF4:
	 DB $49 ; $2AF4 -> $0262
	 DB $06 ; $2AF5 -> $0044
; $2AF6: original compiled TERSE game-control word.
TERSE_COLON_2AF6:
	 RST $08
	 DB $1B ; $2AF7 -> $0050
	 DW $D189 ; LIT16
	 DB $25 ; $2AFA -> $00A4
	 DB $0D ; $2AFB -> $0087
	 DB $1B ; $2AFC -> $0050
	 DW $D195 ; LIT16
	 DB $08 ; $2AFF -> $00B2
	 DB $09 ; $2B00 -> $0081
	 DB $93 ; $2B01 -> TERSE_COMPARE_BRANCH_NE
	 DW $2B2C ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2B04 -> $007B
	 DB $94 ; $2B05 -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $95 ; $2B08 -> $1188
	 DB $0E ; $2B09 -> $0059
	 DB $18 ; LIT8
	 DB $18 ; $2B0B -> $10EC
	 DB $0B ; $2B0C -> $007B
	 DB $17 ; $2B0D -> $10DA
	 DB $76 ; $2B0E -> $11D0
	 DB $96 ; $2B0F -> $26E6
	 DB $25 ; $2B10 -> $00A4
	 DB $03 ; $2B11 -> $01FC
	 DW TERSE_THREAD_2B27 ; 0BRANCH
	 DB $97 ; $2B14 -> $2704
	 DB $49 ; $2B15 -> $0262
	 DB $98 ; $2B16 -> $26D2
	 DB $3B ; $2B17 -> $112D
	 DB $36 ; $2B18 -> $1216
	 DB $3B ; $2B19 -> $112D
	 DB $3F ; $2B1A -> $00C5
	 DB $0E ; $2B1B -> $0059
	 DB $06 ; LIT8
	 DB $52 ; $2B1D -> $0217
	 DB $0E ; $2B1E -> $0059
	 DB $03 ; LIT8
	 DB $94 ; $2B20 -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $08 ; $2B23 -> $00B2
	 DB $46 ; $2B24 -> $01F4
	 DW TERSE_THREAD_2B29 ; BRANCH
TERSE_THREAD_2B27:
	 DB $09 ; $2B27 -> $0081
	 DB $99 ; $2B28 -> $2AE2
TERSE_THREAD_2B29:
	 DB $46 ; $2B29 -> $01F4
	 DW TERSE_THREAD_2BBF ; BRANCH
	 DB $0E ; $2B2C -> $0059
	 DB $02 ; LIT8
	 DB $93 ; $2B2E -> TERSE_COMPARE_BRANCH_NE
	 DW $2B5B ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2B31 -> $007B
	 DB $94 ; $2B32 -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $95 ; $2B35 -> $1188
	 DB $0B ; $2B36 -> $007B
	 DB $18 ; $2B37 -> $10EC
	 DB $0E ; $2B38 -> $0059
	 DB $18 ; LIT8
	 DB $17 ; $2B3A -> $10DA
	 DB $9A ; $2B3B -> $26EB
	 DB $25 ; $2B3C -> $00A4
	 DB $03 ; $2B3D -> $01FC
	 DW TERSE_THREAD_2B55 ; 0BRANCH
	 DB $9B ; $2B40 -> $2709
	 DB $49 ; $2B41 -> $0262
	 DB $9C ; $2B42 -> $26D7
	 DB $39 ; $2B43 -> $111E
	 DB $36 ; $2B44 -> $1216
	 DB $39 ; $2B45 -> $111E
	 DB $3F ; $2B46 -> $00C5
	 DB $0E ; $2B47 -> $0059
	 DB $08 ; LIT8
	 DB $52 ; $2B49 -> $0217
	 DB $3A ; $2B4A -> $00DE
	 DB $3A ; $2B4B -> $00DE
	 DB $0E ; $2B4C -> $0059
	 DB $02 ; LIT8
	 DB $94 ; $2B4E -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $08 ; $2B51 -> $00B2
	 DB $46 ; $2B52 -> $01F4
	 DW TERSE_THREAD_2B58 ; BRANCH
TERSE_THREAD_2B55:
	 DB $0E ; $2B55 -> $0059
	 DB $02 ; LIT8
	 DB $99 ; $2B57 -> $2AE2
TERSE_THREAD_2B58:
	 DB $46 ; $2B58 -> $01F4
	 DW TERSE_THREAD_2BBF ; BRANCH
	 DB $0E ; $2B5B -> $0059
	 DB $03 ; LIT8
	 DB $93 ; $2B5D -> TERSE_COMPARE_BRANCH_NE
	 DW $2B8B ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2B60 -> $007B
	 DB $94 ; $2B61 -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $95 ; $2B64 -> $1188
	 DB $1B ; $2B65 -> $0050
	 DW $FFE8 ; LIT16
	 DB $18 ; $2B68 -> $10EC
	 DB $0B ; $2B69 -> $007B
	 DB $17 ; $2B6A -> $10DA
	 DB $9D ; $2B6B -> $26F0
	 DB $25 ; $2B6C -> $00A4
	 DB $03 ; $2B6D -> $01FC
	 DW TERSE_THREAD_2B85 ; 0BRANCH
	 DB $9E ; $2B70 -> $26FA
	 DB $49 ; $2B71 -> $0262
	 DB $9F ; $2B72 -> $26DC
	 DB $3B ; $2B73 -> $112D
	 DB $82 ; $2B74 -> $00CD
	 DB $36 ; $2B75 -> $1216
	 DB $3B ; $2B76 -> $112D
	 DB $82 ; $2B77 -> $00CD
	 DB $3F ; $2B78 -> $00C5
	 DB $0E ; $2B79 -> $0059
	 DB $06 ; LIT8
	 DB $52 ; $2B7B -> $0217
	 DB $0E ; $2B7C -> $0059
	 DB $03 ; LIT8
	 DB $94 ; $2B7E -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $08 ; $2B81 -> $00B2
	 DB $46 ; $2B82 -> $01F4
	 DW TERSE_THREAD_2B88 ; BRANCH
TERSE_THREAD_2B85:
	 DB $0E ; $2B85 -> $0059
	 DB $03 ; LIT8
	 DB $99 ; $2B87 -> $2AE2
TERSE_THREAD_2B88:
	 DB $46 ; $2B88 -> $01F4
	 DW TERSE_THREAD_2BBF ; BRANCH
	 DB $0E ; $2B8B -> $0059
	 DB $04 ; LIT8
	 DB $93 ; $2B8D -> TERSE_COMPARE_BRANCH_NE
	 DW $2BBE ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2B90 -> $007B
	 DB $94 ; $2B91 -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $95 ; $2B94 -> $1188
	 DB $0B ; $2B95 -> $007B
	 DB $18 ; $2B96 -> $10EC
	 DB $1B ; $2B97 -> $0050
	 DW $FFE8 ; LIT16
	 DB $17 ; $2B9A -> $10DA
	 DB $77 ; $2B9B -> $11DB
	 DB $A0 ; $2B9C -> $26F5
	 DB $25 ; $2B9D -> $00A4
	 DB $03 ; $2B9E -> $01FC
	 DW TERSE_THREAD_2BB8 ; 0BRANCH
	 DB $A1 ; $2BA1 -> $26FF
	 DB $49 ; $2BA2 -> $0262
	 DB $A2 ; $2BA3 -> $26E1
	 DB $39 ; $2BA4 -> $111E
	 DB $82 ; $2BA5 -> $00CD
	 DB $36 ; $2BA6 -> $1216
	 DB $39 ; $2BA7 -> $111E
	 DB $82 ; $2BA8 -> $00CD
	 DB $3F ; $2BA9 -> $00C5
	 DB $0E ; $2BAA -> $0059
	 DB $08 ; LIT8
	 DB $52 ; $2BAC -> $0217
	 DB $3A ; $2BAD -> $00DE
	 DB $3A ; $2BAE -> $00DE
	 DB $0E ; $2BAF -> $0059
	 DB $02 ; LIT8
	 DB $94 ; $2BB1 -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $08 ; $2BB4 -> $00B2
	 DB $46 ; $2BB5 -> $01F4
	 DW TERSE_THREAD_2BBB ; BRANCH
TERSE_THREAD_2BB8:
	 DB $0E ; $2BB8 -> $0059
	 DB $04 ; LIT8
	 DB $99 ; $2BBA -> $2AE2
TERSE_THREAD_2BBB:
	 DB $46 ; $2BBB -> $01F4
	 DW TERSE_THREAD_2BBF ; BRANCH
	 DB $05 ; $2BBE -> $0094
TERSE_THREAD_2BBF:
	 DB $06 ; $2BBF -> $0044
; $2BC0: original compiled TERSE game-control word.
TERSE_COLON_2BC0:
	 RST $08
	 DB $2A ; $2BC1 -> $042F
	 DB $56 ; $2BC2 -> $11C3
	 DB $71 ; $2BC3 -> $1166
	 DB $57 ; $2BC4 -> $121C
	 DB $A3 ; $2BC5 -> $11E6
	 DB $1B ; $2BC6 -> $0050
	 DW $17D2 ; LIT16
	 DB $0B ; $2BC9 -> $007B
	 DB $94 ; $2BCA -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $0E ; $2BCD -> $0059
	 DB $05 ; LIT8
	 DB $16 ; $2BCF -> $015F
	 DB $1B ; $2BD0 -> $0050
	 DW $17D7 ; LIT16
	 DB $0B ; $2BD3 -> $007B
	 DB $94 ; $2BD4 -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $0E ; $2BD7 -> $0059
	 DB $05 ; LIT8
	 DB $16 ; $2BD9 -> $015F
TERSE_THREAD_2BDA:
	 DB $0E ; $2BDA -> $0059
	 DB $38 ; LIT8
	 DB $0E ; $2BDC -> $0059
	 DB $03 ; LIT8
	 DB $94 ; $2BDE -> TERSE_ADD_INLINE16
	 DW $D1A9 ; inline little-endian displacement for token $94
	 DB $08 ; $2BE1 -> $00B2
	 DB $0E ; $2BE2 -> $0059
	 DB $1D ; LIT8
	 DB $0E ; $2BE4 -> $0059
	 DB $02 ; LIT8
	 DB $94 ; $2BE6 -> TERSE_ADD_INLINE16
	 DW $D1A4 ; inline little-endian displacement for token $94
	 DB $08 ; $2BE9 -> $00B2
	 DB $1B ; $2BEA -> $0050
	 DW $D418 ; LIT16
	 DB $25 ; $2BED -> $00A4
	 DB $27 ; $2BEE -> $0139
	 DB $03 ; $2BEF -> $01FC
	 DW TERSE_THREAD_2BF3 ; 0BRANCH
	 DB $35 ; $2BF2 -> $04A6
TERSE_THREAD_2BF3:
	 DB $1B ; $2BF3 -> $0050
	 DW $D418 ; LIT16
	 DB $43 ; $2BF6 -> $00E6
	 DB $78 ; $2BF7 -> $24DA
	 DB $4E ; $2BF8 -> $013F
	 DB $27 ; $2BF9 -> $0139
	 DB $03 ; $2BFA -> $01FC
	 DW TERSE_THREAD_2C20 ; 0BRANCH
	 DB $1B ; $2BFD -> $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2C00 -> $00A4
	 DB $27 ; $2C01 -> $0139
	 DB $03 ; $2C02 -> $01FC
	 DW TERSE_THREAD_2C1F ; 0BRANCH
	 DB $1B ; $2C05 -> $0050
	 DW $D199 ; LIT16
	 DB $1D ; $2C08 -> $0266
	 DB $A4 ; $2C09 -> $2AF6
	 DB $A5 ; $2C0A -> $12DB
	 DB $09 ; $2C0B -> $0081
	 DB $4F ; $2C0C -> $0EC7
	 DB $73 ; $2C0D -> $0D11
	 DB $A5 ; $2C0E -> $12DB
	 DB $1B ; $2C0F -> $0050
	 DW $D41D ; LIT16
	 DB $25 ; $2C12 -> $00A4
	 DB $03 ; $2C13 -> $01FC
	 DW TERSE_THREAD_2C1E ; 0BRANCH
	 DB $1B ; $2C16 -> $0050
	 DW $D199 ; LIT16
	 DB $25 ; $2C19 -> $00A4
	 DB $03 ; $2C1A -> $01FC
	 DW TERSE_THREAD_2C1E ; 0BRANCH
	 DB $A4 ; $2C1D -> $2AF6
TERSE_THREAD_2C1E:
	 DB $58 ; $2C1E -> $1212
TERSE_THREAD_2C1F:
	 DB $78 ; $2C1F -> $24DA
TERSE_THREAD_2C20:
	 DB $03 ; $2C20 -> $01FC
	 DW TERSE_THREAD_2BDA ; 0BRANCH
	 DB $36 ; $2C23 -> $1216
	 DB $91 ; $2C24 -> $26B6
	 DB $06 ; $2C25 -> $0044
; $2C26: original compiled TERSE game-control word.
TERSE_COLON_2C26:
	 RST $08
	 DB $36 ; $2C27 -> $1216
	 DB $A6 ; $2C28 -> $113C
	 DB $82 ; $2C29 -> $00CD
	 DB $A7 ; $2C2A -> $10FE
	 DB $36 ; $2C2B -> $1216
	 DB $A8 ; $2C2C -> $114A
	 DB $82 ; $2C2D -> $00CD
	 DB $A9 ; $2C2E -> $110E
	 DB $0E ; $2C2F -> $0059
	 DB $85 ; LIT8
	 DB $60 ; $2C31 -> $0FB8
	 DB $1B ; $2C32 -> $0050
	 DW $FF7B ; LIT16
	 DB $61 ; $2C35 -> $0FA6
	 DB $0E ; $2C36 -> $0059
	 DB $56 ; LIT8
	 DB $5E ; $2C38 -> $0FDC
	 DB $1B ; $2C39 -> $0050
	 DW $FFAA ; LIT16
	 DB $5F ; $2C3C -> $0FCA
	 DB $69 ; $2C3D -> $0F98
	 DB $0E ; $2C3E -> $0059
	 DB $19 ; LIT8
	 DB $74 ; $2C40 -> $254C
	 DB $AA ; $2C41 -> $1091
	 DB $62 ; $2C42 -> $2393
	 DB $6A ; $2C43 -> $10CD
	 DB $59 ; $2C44 -> $11A0
	 DB $1B ; $2C45 -> $0050
	 DW $178B ; LIT16
	 DB $6B ; $2C48 -> $10B7
	 DB $0E ; $2C49 -> $0059
	 DB $1E ; LIT8
	 DB $4F ; $2C4B -> $0EC7
	 DB $06 ; $2C4C -> $0044
TERSE_INTERWORD_2C4D:
	 DB $8A ; original byte between colon definitions
; $2C4E: original compiled TERSE game-control word.
TERSE_COLON_2C4E:
	 RST $08
	 DB $2A ; $2C4F -> $042F
	 DB $0E ; $2C50 -> $0059
	 DB $0C ; LIT8
	 DB $65 ; $2C52 -> $1195
	 DB $56 ; $2C53 -> $11C3
	 DB $71 ; $2C54 -> $1166
TERSE_THREAD_2C55:
	 DB $0B ; $2C55 -> $007B
	 DB $A9 ; $2C56 -> $110E
	 DB $1B ; $2C57 -> $0050
	 DW $24C8 ; LIT16
	 DB $5C ; $2C5A -> $109C
	 DB $57 ; $2C5B -> $121C
	 DB $6A ; $2C5C -> $10CD
	 DB $9B ; $2C5D -> $2709
	 DB $1D ; $2C5E -> $0266
	 DB $35 ; $2C5F -> $04A6
	 DB $78 ; $2C60 -> $24DA
	 DB $4E ; $2C61 -> $013F
	 DB $27 ; $2C62 -> $0139
	 DB $03 ; $2C63 -> $01FC
	 DW TERSE_THREAD_2CAC ; 0BRANCH
	 DB $0E ; $2C66 -> $0059
	 DB $84 ; LIT8
	 DB $17 ; $2C68 -> $10DA
	 DB $0B ; $2C69 -> $007B
	 DB $18 ; $2C6A -> $10EC
	 DB $AB ; $2C6B -> $2635
	 DB $82 ; $2C6C -> $00CD
	 DB $A7 ; $2C6D -> $10FE
	 DB $9A ; $2C6E -> $26EB
	 DB $49 ; $2C6F -> $0262
	 DB $1B ; $2C70 -> $0050
	 DW $D003 ; LIT16
	 DB $25 ; $2C73 -> $00A4
	 DB $27 ; $2C74 -> $0139
	 DB $03 ; $2C75 -> $01FC
	 DW TERSE_THREAD_2C7C ; 0BRANCH
	 DB $1B ; $2C78 -> $0050
	 DW $D155 ; LIT16
	 DB $AC ; $2C7B -> $231D
TERSE_THREAD_2C7C:
	 DB $AD ; $2C7C -> $1086
	 DB $70 ; $2C7D -> $11AB
	 DB $AE ; $2C7E -> $261F
	 DB $6B ; $2C7F -> $10B7
	 DB $19 ; $2C80 -> $11FC
	 DB $9B ; $2C81 -> $2709
	 DB $79 ; $2C82 -> $0EDA
	 DB $0E ; $2C83 -> $0059
	 DB $18 ; LIT8
	 DB $7D ; $2C85 -> $100A
	 DB $6C ; $2C86 -> $0CE2
	 DB $9A ; $2C87 -> $26EB
	 DB $1D ; $2C88 -> $0266
	 DB $7A ; $2C89 -> $0EED
	 DB $9B ; $2C8A -> $2709
	 DB $25 ; $2C8B -> $00A4
	 DB $54 ; $2C8C -> $0154
	 DB $03 ; $2C8D -> $01FC
	 DW TERSE_THREAD_2C95 ; 0BRANCH
	 DB $AF ; $2C90 -> $2C26
	 DB $6C ; $2C91 -> $0CE2
	 DB $46 ; $2C92 -> $01F4
	 DW TERSE_THREAD_2CAA ; BRANCH
TERSE_THREAD_2C95:
	 DB $8E ; $2C95 -> $25D0
	 DB $AD ; $2C96 -> $1086
	 DB $0B ; $2C97 -> $007B
	 DB $7D ; $2C98 -> $100A
	 DB $6C ; $2C99 -> $0CE2
	 DB $71 ; $2C9A -> $1166
	 DB $1B ; $2C9B -> $0050
	 DW $D3C9 ; LIT16
	 DB $55 ; $2C9E -> $04BB
	 DB $58 ; $2C9F -> $1212
	 DB $70 ; $2CA0 -> $11AB
	 DB $1B ; $2CA1 -> $0050
	 DW $1DC9 ; LIT16
	 DB $6B ; $2CA4 -> $10B7
	 DB $0E ; $2CA5 -> $0059
	 DB $26 ; LIT8
	 DB $4F ; $2CA7 -> $0EC7
	 DB $6C ; $2CA8 -> $0CE2
	 DB $62 ; $2CA9 -> $2393
TERSE_THREAD_2CAA:
	 DB $6D ; $2CAA -> $12C7
	 DB $78 ; $2CAB -> $24DA
TERSE_THREAD_2CAC:
	 DB $03 ; $2CAC -> $01FC
	 DW TERSE_THREAD_2C55 ; 0BRANCH
	 DB $36 ; $2CAF -> $1216
	 DB $7C ; $2CB0 -> $263E
	 DB $06 ; $2CB1 -> $0044
; $2CB2: original compiled TERSE game-control word.
TERSE_COLON_2CB2:
	 RST $08
	 DB $2A ; $2CB3 -> $042F
	 DB $0E ; $2CB4 -> $0059
	 DB $0C ; LIT8
	 DB $65 ; $2CB6 -> $1195
	 DB $56 ; $2CB7 -> $11C3
	 DB $71 ; $2CB8 -> $1166
TERSE_THREAD_2CB9:
	 DB $0B ; $2CB9 -> $007B
	 DB $A7 ; $2CBA -> $10FE
	 DB $1B ; $2CBB -> $0050
	 DW $24D1 ; LIT16
	 DB $5C ; $2CBE -> $109C
	 DB $57 ; $2CBF -> $121C
	 DB $6A ; $2CC0 -> $10CD
	 DB $9E ; $2CC1 -> $26FA
	 DB $1D ; $2CC2 -> $0266
	 DB $35 ; $2CC3 -> $04A6
	 DB $78 ; $2CC4 -> $24DA
	 DB $4E ; $2CC5 -> $013F
	 DB $27 ; $2CC6 -> $0139
	 DB $03 ; $2CC7 -> $01FC
	 DW TERSE_THREAD_2D13 ; 0BRANCH
	 DB $0B ; $2CCA -> $007B
	 DB $17 ; $2CCB -> $10DA
	 DB $1B ; $2CCC -> $0050
	 DW $FFAB ; LIT16
	 DB $18 ; $2CCF -> $10EC
	 DB $1B ; $2CD0 -> $0050
	 DW $D19C ; LIT16
	 DB $0C ; $2CD3 -> $009D
	 DB $A9 ; $2CD4 -> $110E
	 DB $9D ; $2CD5 -> $26F0
	 DB $49 ; $2CD6 -> $0262
	 DB $1B ; $2CD7 -> $0050
	 DW $D003 ; LIT16
	 DB $25 ; $2CDA -> $00A4
	 DB $27 ; $2CDB -> $0139
	 DB $03 ; $2CDC -> $01FC
	 DW TERSE_THREAD_2CE3 ; 0BRANCH
	 DB $1B ; $2CDF -> $0050
	 DW $D155 ; LIT16
	 DB $AC ; $2CE2 -> $231D
TERSE_THREAD_2CE3:
	 DB $AD ; $2CE3 -> $1086
	 DB $70 ; $2CE4 -> $11AB
	 DB $AE ; $2CE5 -> $261F
	 DB $6B ; $2CE6 -> $10B7
	 DB $9E ; $2CE7 -> $26FA
	 DB $79 ; $2CE8 -> $0EDA
	 DB $1B ; $2CE9 -> $0050
	 DW $FFE8 ; LIT16
	 DB $7F ; $2CEC -> $1026
	 DB $6C ; $2CED -> $0CE2
	 DB $9D ; $2CEE -> $26F0
	 DB $1D ; $2CEF -> $0266
	 DB $7A ; $2CF0 -> $0EED
	 DB $9E ; $2CF1 -> $26FA
	 DB $25 ; $2CF2 -> $00A4
	 DB $54 ; $2CF3 -> $0154
	 DB $03 ; $2CF4 -> $01FC
	 DW TERSE_THREAD_2CFC ; 0BRANCH
	 DB $AF ; $2CF7 -> $2C26
	 DB $6C ; $2CF8 -> $0CE2
	 DB $46 ; $2CF9 -> $01F4
	 DW TERSE_THREAD_2D11 ; BRANCH
TERSE_THREAD_2CFC:
	 DB $8E ; $2CFC -> $25D0
	 DB $AD ; $2CFD -> $1086
	 DB $0B ; $2CFE -> $007B
	 DB $7F ; $2CFF -> $1026
	 DB $6C ; $2D00 -> $0CE2
	 DB $71 ; $2D01 -> $1166
	 DB $1B ; $2D02 -> $0050
	 DW $D3C9 ; LIT16
	 DB $55 ; $2D05 -> $04BB
	 DB $58 ; $2D06 -> $1212
	 DB $70 ; $2D07 -> $11AB
	 DB $1B ; $2D08 -> $0050
	 DW $1DC9 ; LIT16
	 DB $6B ; $2D0B -> $10B7
	 DB $0E ; $2D0C -> $0059
	 DB $26 ; LIT8
	 DB $4F ; $2D0E -> $0EC7
	 DB $6C ; $2D0F -> $0CE2
	 DB $62 ; $2D10 -> $2393
TERSE_THREAD_2D11:
	 DB $6D ; $2D11 -> $12C7
	 DB $78 ; $2D12 -> $24DA
TERSE_THREAD_2D13:
	 DB $03 ; $2D13 -> $01FC
	 DW TERSE_THREAD_2CB9 ; 0BRANCH
	 DB $36 ; $2D16 -> $1216
	 DB $7C ; $2D17 -> $263E
	 DB $06 ; $2D18 -> $0044
; $2D19: original compiled TERSE game-control word.
TERSE_COLON_2D19:
	 RST $08
	 DB $2A ; $2D1A -> $042F
	 DB $0E ; $2D1B -> $0059
	 DB $0C ; LIT8
	 DB $65 ; $2D1D -> $1195
	 DB $56 ; $2D1E -> $11C3
	 DB $71 ; $2D1F -> $1166
TERSE_THREAD_2D20:
	 DB $0B ; $2D20 -> $007B
	 DB $A9 ; $2D21 -> $110E
	 DB $1B ; $2D22 -> $0050
	 DW $24C8 ; LIT16
	 DB $5C ; $2D25 -> $109C
	 DB $57 ; $2D26 -> $121C
	 DB $6A ; $2D27 -> $10CD
	 DB $A1 ; $2D28 -> $26FF
	 DB $1D ; $2D29 -> $0266
	 DB $35 ; $2D2A -> $04A6
	 DB $78 ; $2D2B -> $24DA
	 DB $4E ; $2D2C -> $013F
	 DB $27 ; $2D2D -> $0139
	 DB $03 ; $2D2E -> $01FC
	 DW TERSE_THREAD_2D77 ; 0BRANCH
	 DB $1B ; $2D31 -> $0050
	 DW $FF7C ; LIT16
	 DB $17 ; $2D34 -> $10DA
	 DB $0B ; $2D35 -> $007B
	 DB $18 ; $2D36 -> $10EC
	 DB $AB ; $2D37 -> $2635
	 DB $A7 ; $2D38 -> $10FE
	 DB $A0 ; $2D39 -> $26F5
	 DB $49 ; $2D3A -> $0262
	 DB $1B ; $2D3B -> $0050
	 DW $D003 ; LIT16
	 DB $25 ; $2D3E -> $00A4
	 DB $27 ; $2D3F -> $0139
	 DB $03 ; $2D40 -> $01FC
	 DW TERSE_THREAD_2D47 ; 0BRANCH
	 DB $1B ; $2D43 -> $0050
	 DW $D155 ; LIT16
	 DB $AC ; $2D46 -> $231D
TERSE_THREAD_2D47:
	 DB $AD ; $2D47 -> $1086
	 DB $70 ; $2D48 -> $11AB
	 DB $AE ; $2D49 -> $261F
	 DB $6B ; $2D4A -> $10B7
	 DB $A1 ; $2D4B -> $26FF
	 DB $79 ; $2D4C -> $0EDA
	 DB $1B ; $2D4D -> $0050
	 DW $FFE8 ; LIT16
	 DB $7D ; $2D50 -> $100A
	 DB $6C ; $2D51 -> $0CE2
	 DB $A0 ; $2D52 -> $26F5
	 DB $1D ; $2D53 -> $0266
	 DB $7A ; $2D54 -> $0EED
	 DB $A1 ; $2D55 -> $26FF
	 DB $25 ; $2D56 -> $00A4
	 DB $54 ; $2D57 -> $0154
	 DB $03 ; $2D58 -> $01FC
	 DW TERSE_THREAD_2D60 ; 0BRANCH
	 DB $AF ; $2D5B -> $2C26
	 DB $6C ; $2D5C -> $0CE2
	 DB $46 ; $2D5D -> $01F4
	 DW TERSE_THREAD_2D75 ; BRANCH
TERSE_THREAD_2D60:
	 DB $8E ; $2D60 -> $25D0
	 DB $AD ; $2D61 -> $1086
	 DB $0B ; $2D62 -> $007B
	 DB $7D ; $2D63 -> $100A
	 DB $6C ; $2D64 -> $0CE2
	 DB $71 ; $2D65 -> $1166
	 DB $1B ; $2D66 -> $0050
	 DW $D3C9 ; LIT16
	 DB $55 ; $2D69 -> $04BB
	 DB $58 ; $2D6A -> $1212
	 DB $70 ; $2D6B -> $11AB
	 DB $1B ; $2D6C -> $0050
	 DW $1DC9 ; LIT16
	 DB $6B ; $2D6F -> $10B7
	 DB $0E ; $2D70 -> $0059
	 DB $26 ; LIT8
	 DB $4F ; $2D72 -> $0EC7
	 DB $6C ; $2D73 -> $0CE2
	 DB $62 ; $2D74 -> $2393
TERSE_THREAD_2D75:
	 DB $6D ; $2D75 -> $12C7
	 DB $78 ; $2D76 -> $24DA
TERSE_THREAD_2D77:
	 DB $03 ; $2D77 -> $01FC
	 DW TERSE_THREAD_2D20 ; 0BRANCH
	 DB $36 ; $2D7A -> $1216
	 DB $7C ; $2D7B -> $263E
; $2D7C: EXIT of preceding colon program.
	 DB $06 ; TERSE_EXIT
; $2D7D compiled TERSE byte-token definition.
TERSE_COLON_2D7D:
	 RST $08
	 DB $2A ; $2D7E => $042F
	 DB $0E ; $2D7F => $0059
	 DB $0C ; LIT8
	 DB $65 ; $2D81 => $1195
	 DB $56 ; $2D82 => $11C3
	 DB $71 ; $2D83 => $1166
TERSE_THREAD_2D84:
	 DB $0B ; $2D84 => $007B
	 DB $A7 ; $2D85 => $10FE
	 DB $1B ; $2D86 => $0050
	 DW $24D1 ; LIT16
	 DB $5C ; $2D89 => $109C
	 DB $57 ; $2D8A => $121C
	 DB $6A ; $2D8B => $10CD
	 DB $97 ; $2D8C => $2704
	 DB $1D ; $2D8D => $0266
	 DB $35 ; $2D8E => $04A6
	 DB $78 ; $2D8F => $24DA
	 DB $4E ; $2D90 => $013F
	 DB $27 ; $2D91 => $0139
	 DB $03 ; $2D92 => $01FC
	 DW TERSE_THREAD_2DDD ; 0BRANCH
	 DB $0B ; $2D95 => $007B
	 DB $17 ; $2D96 => $10DA
	 DB $0E ; $2D97 => $0059
	 DB $55 ; LIT8
	 DB $18 ; $2D99 => $10EC
	 DB $1B ; $2D9A => $0050
	 DW $D19C ; LIT16
	 DB $0C ; $2D9D => $009D
	 DB $82 ; $2D9E => $00CD
	 DB $A9 ; $2D9F => $110E
	 DB $96 ; $2DA0 => $26E6
	 DB $49 ; $2DA1 => $0262
	 DB $1B ; $2DA2 => $0050
	 DW $D003 ; LIT16
	 DB $25 ; $2DA5 => $00A4
	 DB $27 ; $2DA6 => $0139
	 DB $03 ; $2DA7 => $01FC
	 DW TERSE_THREAD_2DAE ; 0BRANCH
	 DB $1B ; $2DAA => $0050
	 DW $D155 ; LIT16
	 DB $AC ; $2DAD => $231D
TERSE_THREAD_2DAE:
	 DB $AD ; $2DAE => $1086
	 DB $70 ; $2DAF => $11AB
	 DB $AE ; $2DB0 => $261F
	 DB $6B ; $2DB1 => $10B7
	 DB $97 ; $2DB2 => $2704
	 DB $79 ; $2DB3 => $0EDA
	 DB $0E ; $2DB4 => $0059
	 DB $18 ; LIT8
	 DB $7F ; $2DB6 => $1026
	 DB $6C ; $2DB7 => $0CE2
	 DB $96 ; $2DB8 => $26E6
	 DB $1D ; $2DB9 => $0266
	 DB $7A ; $2DBA => $0EED
	 DB $97 ; $2DBB => $2704
	 DB $25 ; $2DBC => $00A4
	 DB $54 ; $2DBD => $0154
	 DB $03 ; $2DBE => $01FC
	 DW TERSE_THREAD_2DC6 ; 0BRANCH
	 DB $AF ; $2DC1 => $2C26
	 DB $6C ; $2DC2 => $0CE2
	 DB $46 ; $2DC3 => $01F4
	 DW TERSE_THREAD_2DDB ; BRANCH
TERSE_THREAD_2DC6:
	 DB $8E ; $2DC6 => $25D0
	 DB $AD ; $2DC7 => $1086
	 DB $0B ; $2DC8 => $007B
	 DB $7F ; $2DC9 => $1026
	 DB $6C ; $2DCA => $0CE2
	 DB $71 ; $2DCB => $1166
	 DB $1B ; $2DCC => $0050
	 DW $D3C9 ; LIT16
	 DB $55 ; $2DCF => $04BB
	 DB $58 ; $2DD0 => $1212
	 DB $70 ; $2DD1 => $11AB
	 DB $1B ; $2DD2 => $0050
	 DW $1DC9 ; LIT16
	 DB $6B ; $2DD5 => $10B7
	 DB $0E ; $2DD6 => $0059
	 DB $26 ; LIT8
	 DB $4F ; $2DD8 => $0EC7
	 DB $6C ; $2DD9 => $0CE2
	 DB $62 ; $2DDA => $2393
TERSE_THREAD_2DDB:
	 DB $6D ; $2DDB => $12C7
	 DB $78 ; $2DDC => $24DA
TERSE_THREAD_2DDD:
	 DB $03 ; $2DDD => $01FC
	 DW TERSE_THREAD_2D84 ; 0BRANCH
	 DB $36 ; $2DE0 => $1216
	 DB $7C ; $2DE1 => $263E
	 DB $06 ; $2DE2 => $0044
; $2DE3 compiled TERSE byte-token definition.
TERSE_COLON_2DE3:
	 RST $08
	 DB $2A ; $2DE4 => $042F
	 DB $71 ; $2DE5 => $1166
	 DB $67 ; $2DE6 => $1182
	 DB $57 ; $2DE7 => $121C
TERSE_THREAD_2DE8:
	 DB $35 ; $2DE8 => $04A6
	 DB $1B ; $2DE9 => $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2DEC => $00A4
	 DB $03 ; $2DED => $01FC
	 DW TERSE_THREAD_2EC4 ; 0BRANCH
	 DB $56 ; $2DF0 => $11C3
	 DB $1B ; $2DF1 => $0050
	 DW $D19A ; LIT16
	 DB $49 ; $2DF4 => $0262
	 DB $9B ; $2DF5 => $2709
	 DB $49 ; $2DF6 => $0262
	 DB $A1 ; $2DF7 => $26FF
	 DB $49 ; $2DF8 => $0262
	 DB $97 ; $2DF9 => $2704
	 DB $49 ; $2DFA => $0262
	 DB $9E ; $2DFB => $26FA
	 DB $49 ; $2DFC => $0262
	 DB $1B ; $2DFD => $0050
	 DW $D003 ; LIT16
	 DB $25 ; $2E00 => $00A4
	 DB $09 ; $2E01 => $0081
	 DB $4C ; $2E02 => $0149
	 DB $27 ; $2E03 => $0139
	 DB $03 ; $2E04 => $01FC
	 DW TERSE_THREAD_2E0F ; 0BRANCH
	 DB $1B ; $2E07 => $0050
	 DW $D003 ; LIT16
	 DB $29 ; $2E0A => $1F10
	 DB $1B ; $2E0B => $0050
	 DW $D155 ; LIT16
	 DB $37 ; $2E0E => $21AA
TERSE_THREAD_2E0F:
	 DB $0E ; $2E0F => $0059
	 DB $06 ; LIT8
	 DB $1B ; $2E11 => $0050
	 DW $D42D ; LIT16
	 DB $08 ; $2E14 => $00B2
	 DB $98 ; $2E15 => $26D2
	 DB $55 ; $2E16 => $04BB
	 DB $9F ; $2E17 => $26DC
	 DB $55 ; $2E18 => $04BB
	 DB $A2 ; $2E19 => $26E1
	 DB $55 ; $2E1A => $04BB
	 DB $9C ; $2E1B => $26D7
	 DB $55 ; $2E1C => $04BB
	 DB $1B ; $2E1D => $0050
	 DW $D1B5 ; LIT16
	 DB $55 ; $2E20 => $04BB
	 DB $1B ; $2E21 => $0050
	 DW $D24D ; LIT16
	 DB $55 ; $2E24 => $04BB
	 DB $72 ; $2E25 => $24FD
	 DB $73 ; $2E26 => $0D11
	 DB $50 ; $2E27 => $24F6
	 DB $1B ; $2E28 => $0050
	 DW $185E ; LIT16
	 DB $95 ; $2E2B => $1188
	 DB $A5 ; $2E2C => $12DB
	 DB $76 ; $2E2D => $11D0
	 DB $A5 ; $2E2E => $12DB
	 DB $77 ; $2E2F => $11DB
	 DB $A5 ; $2E30 => $12DB
	 DB $19 ; $2E31 => $11FC
	 DB $A5 ; $2E32 => $12DB
	 DB $1A ; $2E33 => $1207
	 DB $0E ; $2E34 => $0059
	 DB $09 ; LIT8
	 DB $4F ; $2E36 => $0EC7
	 DB $73 ; $2E37 => $0D11
	 DB $1B ; $2E38 => $0050
	 DW $17DC ; LIT16
	 DB $95 ; $2E3B => $1188
	 DB $A5 ; $2E3C => $12DB
	 DB $76 ; $2E3D => $11D0
	 DB $A5 ; $2E3E => $12DB
	 DB $77 ; $2E3F => $11DB
	 DB $A5 ; $2E40 => $12DB
	 DB $19 ; $2E41 => $11FC
	 DB $A5 ; $2E42 => $12DB
	 DB $1A ; $2E43 => $1207
	 DB $0E ; $2E44 => $0059
	 DB $09 ; LIT8
	 DB $4F ; $2E46 => $0EC7
	 DB $73 ; $2E47 => $0D11
	 DB $1B ; $2E48 => $0050
	 DW $185E ; LIT16
	 DB $95 ; $2E4B => $1188
	 DB $A5 ; $2E4C => $12DB
	 DB $76 ; $2E4D => $11D0
	 DB $A5 ; $2E4E => $12DB
	 DB $77 ; $2E4F => $11DB
	 DB $A5 ; $2E50 => $12DB
	 DB $19 ; $2E51 => $11FC
	 DB $A5 ; $2E52 => $12DB
	 DB $1A ; $2E53 => $1207
	 DB $72 ; $2E54 => $24FD
	 DB $73 ; $2E55 => $0D11
	 DB $0E ; $2E56 => $0059
	 DB $10 ; LIT8
	 DB $B0 ; $2E58 => $2508
	 DB $73 ; $2E59 => $0D11
	 DB $72 ; $2E5A => $24FD
	 DB $73 ; $2E5B => $0D11
	 DB $0E ; $2E5C => $0059
	 DB $12 ; LIT8
	 DB $B0 ; $2E5E => $2508
	 DB $73 ; $2E5F => $0D11
	 DB $72 ; $2E60 => $24FD
	 DB $73 ; $2E61 => $0D11
	 DB $0E ; $2E62 => $0059
	 DB $16 ; LIT8
	 DB $B0 ; $2E64 => $2508
	 DB $73 ; $2E65 => $0D11
	 DB $72 ; $2E66 => $24FD
	 DB $73 ; $2E67 => $0D11
	 DB $0E ; $2E68 => $0059
	 DB $20 ; LIT8
	 DB $B0 ; $2E6A => $2508
	 DB $73 ; $2E6B => $0D11
	 DB $72 ; $2E6C => $24FD
	 DB $73 ; $2E6D => $0D11
	 DB $0E ; $2E6E => $0059
	 DB $10 ; LIT8
	 DB $B0 ; $2E70 => $2508
	 DB $73 ; $2E71 => $0D11
	 DB $72 ; $2E72 => $24FD
	 DB $73 ; $2E73 => $0D11
	 DB $0E ; $2E74 => $0059
	 DB $12 ; LIT8
	 DB $B0 ; $2E76 => $2508
	 DB $73 ; $2E77 => $0D11
TERSE_THREAD_2E78:
	 DB $90 ; $2E78 => $047E
	 DB $1B ; $2E79 => $0050
	 DW $D42D ; LIT16
	 DB $25 ; $2E7C => $00A4
	 DB $27 ; $2E7D => $0139
	 DB $03 ; $2E7E => $01FC
	 DW TERSE_THREAD_2E78 ; 0BRANCH
	 DB $1B ; $2E81 => $0050
	 DW $D011 ; LIT16
	 DB $25 ; $2E84 => $00A4
	 DB $1B ; $2E85 => $0050
	 DW $D012 ; LIT16
	 DB $0F ; $2E88 => $00BF
	 DB $25 ; $2E89 => $00A4
	 DB $27 ; $2E8A => $0139
	 DB $03 ; $2E8B => $01FC
	 DW TERSE_THREAD_2E94 ; 0BRANCH
	 DB $1B ; $2E8E => $0050
	 DW $0180 ; LIT16
	 DB $46 ; $2E91 => $01F4
	 DW TERSE_THREAD_2E96 ; BRANCH
TERSE_THREAD_2E94:
	 DB $0E ; $2E94 => $0059
	 DB $60 ; LIT8
TERSE_THREAD_2E96:
	 DB $4F ; $2E96 => $0EC7
	 DB $1B ; $2E97 => $0050
	 DW $D1A3 ; LIT16
	 DB $79 ; $2E9A => $0EDA
	 DB $73 ; $2E9B => $0D11
	 DB $0E ; $2E9C => $0059
	 DB $06 ; LIT8
	 DB $1B ; $2E9E => $0050
	 DW $D42E ; LIT16
	 DB $08 ; $2EA1 => $00B2
TERSE_THREAD_2EA2:
	 DB $90 ; $2EA2 => $047E
	 DB $1B ; $2EA3 => $0050
	 DW $D42E ; LIT16
	 DB $25 ; $2EA6 => $00A4
	 DB $27 ; $2EA7 => $0139
	 DB $03 ; $2EA8 => $01FC
	 DW TERSE_THREAD_2EA2 ; 0BRANCH
	 DB $98 ; $2EAB => $26D2
	 DB $B1 ; $2EAC => $2D7D
	 DB $9F ; $2EAD => $26DC
	 DB $B2 ; $2EAE => $2CB2
	 DB $1B ; $2EAF => $0050
	 DW $D24D ; LIT16
	 DB $92 ; $2EB2 => $275C
	 DB $A2 ; $2EB3 => $26E1
	 DB $B3 ; $2EB4 => $2D19
	 DB $9C ; $2EB5 => $26D7
	 DB $B4 ; $2EB6 => $2C4E
	 DB $1B ; $2EB7 => $0050
	 DW $D1B5 ; LIT16
	 DB $B5 ; $2EBA => $2BC0
TERSE_THREAD_2EBB:
	 DB $35 ; $2EBB => $04A6
	 DB $1B ; $2EBC => $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2EBF => $00A4
	 DB $27 ; $2EC0 => $0139
	 DB $03 ; $2EC1 => $01FC
	 DW TERSE_THREAD_2EBB ; 0BRANCH
TERSE_THREAD_2EC4:
	 DB $B6 ; $2EC4 => $24BB
	 DB $1B ; $2EC5 => $0050
	 DW $17DC ; LIT16
	 DB $95 ; $2EC8 => $1188
	 DB $A5 ; $2EC9 => $12DB
	 DB $76 ; $2ECA => $11D0
	 DB $A5 ; $2ECB => $12DB
	 DB $77 ; $2ECC => $11DB
	 DB $A5 ; $2ECD => $12DB
	 DB $19 ; $2ECE => $11FC
	 DB $A5 ; $2ECF => $12DB
	 DB $1A ; $2ED0 => $1207
	 DB $0B ; $2ED1 => $007B
	 DB $03 ; $2ED2 => $01FC
	 DW TERSE_THREAD_2DE8 ; 0BRANCH
; $2ED5: EXIT of preceding game-control definition.
	 DB $06 ; TERSE_EXIT
; $2ED6-$2F66: TERSE game-control definition.
TERSE_COLON_2ED6:
	 RST $08
	 DB $2A ; $2ED7 -> $042F
	 DB $0E ; $2ED8 -> $0059
	 DB $08 ; LIT8
	 DB $65 ; $2EDA -> $1195
	 DB $56 ; $2EDB -> $11C3
	 DB $59 ; $2EDC -> $11A0
	 DB $71 ; $2EDD -> $1166
	 DB $57 ; $2EDE -> $121C
	 DB $35 ; $2EDF -> $04A6
TERSE_THREAD_2EE0:
	 DB $1B ; $2EE0 -> $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2EE3 -> $00A4
	 DB $03 ; $2EE4 -> $01FC
	 DW TERSE_THREAD_2EFE ; 0BRANCH
	 DB $62 ; $2EE7 -> $2393
	 DB $57 ; $2EE8 -> $121C
	 DB $1B ; $2EE9 -> $0050
	 DW $178B ; LIT16
	 DB $6B ; $2EEC -> $10B7
	 DB $0E ; $2EED -> $0059
	 DB $1E ; LIT8
	 DB $4F ; $2EEF -> $0EC7
	 DB $6C ; $2EF0 -> $0CE2
	 DB $6A ; $2EF1 -> $10CD
TERSE_THREAD_2EF2:
	 DB $35 ; $2EF2 -> $04A6
	 DB $1B ; $2EF3 -> $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2EF6 -> $00A4
	 DB $27 ; $2EF7 -> $0139
	 DB $03 ; $2EF8 -> $01FC
	 DW TERSE_THREAD_2EF2 ; 0BRANCH
	 DB $46 ; $2EFB -> $01F4
	 DW TERSE_THREAD_2F62 ; BRANCH
TERSE_THREAD_2EFE:
	 DB $1B ; $2EFE -> $0050
	 DW $D18A ; LIT16
	 DB $25 ; $2F01 -> $00A4
	 DB $09 ; $2F02 -> $0081
	 DB $93 ; $2F03 -> TERSE_COMPARE_BRANCH_NE
	 DW $2F13 ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2F06 -> $007B
	 DB $17 ; $2F07 -> $10DA
	 DB $0E ; $2F08 -> $0059
	 DB $10 ; LIT8
	 DB $18 ; $2F0A -> $10EC
	 DB $1B ; $2F0B -> $0050
	 DW $17B9 ; LIT16
	 DB $1A ; $2F0E -> $1207
	 DB $19 ; $2F0F -> $11FC
	 DB $46 ; $2F10 -> $01F4
	 DW TERSE_THREAD_2F44 ; BRANCH
	 DB $0E ; $2F13 -> $0059
	 DB $02 ; LIT8
	 DB $93 ; $2F15 -> TERSE_COMPARE_BRANCH_NE
	 DW $2F25 ; inline branch-on-not-equal target for token $93
	 DB $0E ; $2F18 -> $0059
	 DB $10 ; LIT8
	 DB $17 ; $2F1A -> $10DA
	 DB $0B ; $2F1B -> $007B
	 DB $18 ; $2F1C -> $10EC
	 DB $1B ; $2F1D -> $0050
	 DW $179D ; LIT16
	 DB $77 ; $2F20 -> $11DB
	 DB $19 ; $2F21 -> $11FC
	 DB $46 ; $2F22 -> $01F4
	 DW TERSE_THREAD_2F44 ; BRANCH
	 DB $0E ; $2F25 -> $0059
	 DB $03 ; LIT8
	 DB $93 ; $2F27 -> TERSE_COMPARE_BRANCH_NE
	 DW $2F38 ; inline branch-on-not-equal target for token $93
	 DB $0B ; $2F2A -> $007B
	 DB $17 ; $2F2B -> $10DA
	 DB $1B ; $2F2C -> $0050
	 DW $FFF0 ; LIT16
	 DB $18 ; $2F2F -> $10EC
	 DB $1B ; $2F30 -> $0050
	 DW $17B9 ; LIT16
	 DB $1A ; $2F33 -> $1207
	 DB $76 ; $2F34 -> $11D0
	 DB $46 ; $2F35 -> $01F4
	 DW TERSE_THREAD_2F44 ; BRANCH
	 DB $05 ; $2F38 -> $0094
	 DB $1B ; $2F39 -> $0050
	 DW $FFF0 ; LIT16
	 DB $17 ; $2F3C -> $10DA
	 DB $0B ; $2F3D -> $007B
	 DB $18 ; $2F3E -> $10EC
	 DB $1B ; $2F3F -> $0050
	 DW $179D ; LIT16
	 DB $1A ; $2F42 -> $1207
	 DB $19 ; $2F43 -> $11FC
TERSE_THREAD_2F44:
	 DB $95 ; $2F44 -> $1188
	 DB $A5 ; $2F45 -> $12DB
	 DB $1B ; $2F46 -> $0050
	 DW $D014 ; LIT16
	 DB $25 ; $2F49 -> $00A4
	 DB $27 ; $2F4A -> $0139
	 DB $1B ; $2F4B -> $0050
	 DW $D189 ; LIT16
	 DB $25 ; $2F4E -> $00A4
	 DB $1B ; $2F4F -> $0050
	 DW $D18A ; LIT16
	 DB $25 ; $2F52 -> $00A4
	 DB $44 ; $2F53 -> $00EE
	 DB $4C ; $2F54 -> $0149
	 DB $03 ; $2F55 -> $01FC
	 DW TERSE_THREAD_2F59 ; 0BRANCH
	 DB $35 ; $2F58 -> $04A6
TERSE_THREAD_2F59:
	 DB $1B ; $2F59 -> $0050
	 DW $D189 ; LIT16
	 DB $25 ; $2F5C -> $00A4
	 DB $1B ; $2F5D -> $0050
	 DW $D18A ; LIT16
	 DB $08 ; $2F60 -> $00B2
	 DB $6D ; $2F61 -> $12C7
TERSE_THREAD_2F62:
	 DB $0B ; $2F62 -> $007B
	 DB $03 ; $2F63 -> $01FC
	 DW TERSE_THREAD_2EE0 ; 0BRANCH
	 DB $06 ; $2F66 -> $0044
	 in   a,($10)
	 bit  2,a
	 jp   nz,$300A
	 ld   d,a
	 ld   e,$FF
	 ld   hl,$0002
	 exx
	 exx
	 ld   a,e
	 exx
	 ld   hl,$4000
	 ld   de,$4001
	 ld   bc,$3FFF
	 ld   (hl),a
	 ldir
	 in   a,($10)
	 exx
	 cp   d
	 exx
	 jp   z,$2F90
	 xor  a
	 jp   $2FAC
	 ld   a,(hl)
	 exx
	 cp   e
	 jp   z,$2FA5
	 inc  hl
	 inc  hl
	 exx
	 inc  a
	 out  ($00),a
	 out  ($04),a
	 dec  de
	 ld   a,d
	 or   e
	 jp   nz,$2F99
	 exx
	 ld   a,e
	 cpl
	 ld   e,a
	 dec  hl
	 ld   a,l
	 or   h
	 exx
	 jp   nz,$2F75
	 exx
	 di
	 xor  a
	 ld   i,a
	 in   a,($10)
	 ld   d,a
	 ld   e,$FF
	 ld   hl,$0002
	 exx
	 ld   hl,$D000
	 ld   de,$D001
	 ld   bc,$07FF
	 ld   a,$A5
	 out  ($5B),a
	 exx
	 ld   a,e
	 exx
	 ld   (hl),a
	 ld   a,(hl)
	 ex   af,af'
	 ld   a,$A5
	 out  ($5B),a
	 ex   af,af'
	 ld   (de),a
	 inc  de
	 inc  hl
	 dec  bc
	 ld   a,b
	 or   c
	 jp   nz,$2FCE
	 in   a,($10)
	 exx
	 cp   d
	 exx
	 jp   z,$2FEA
	 xor  a
	 jp   $3006
	 ld   a,(hl)
	 exx
	 cp   e
	 jp   z,$2FFF
	 inc  hl
	 inc  hl
	 exx
	 inc  a
	 out  ($00),a
	 out  ($04),a
	 dec  de
	 ld   a,d
	 or   e
	 jp   nz,$2FF3
	 exx
	 ld   a,e
	 cpl
	 ld   e,a
	 dec  hl
	 ld   a,l
	 or   h
	 exx
	 jp   nz,$2FBD
	 exx
	 jp   (iy)
	 exx
	 pop  hl
	 exx
	 push bc
	 ld   a,$10
	 out  ($0C),a
	 exx
	 push hl
	 call $1248
	 exx
	 pop  hl
	 exx
	 ld   a,$0F
	 and  d
	 exx
	 ld   d,a
	 exx
	 ld   a,$03
	 and  l
	 jp   nz,$302D
	 ld   a,$03
	 jp   $3041
	 dec  a
	 jp   nz,$3036
	 ld   a,$0C
	 jp   $3041
	 dec  a
	 jp   nz,$303F
	 ld   a,$30
	 jp   $3041
	 ld   a,$C0
	 ld   c,a
	 and  h
	 jp   nz,$3048
	 ld   a,c
	 and  e
	 exx
	 ld   (hl),a
	 ld   a,$89
	 add  a,d
	 ld   d,a
	 inc  hl
	 dec  d
	 jp   nz,$304E
	 ex   de,hl
	 ld   hl,$7E7D
	 or   a
	 sbc  hl,de
	 ex   de,hl
	 exx
	 jp   nc,$3014
	 pop  bc
	 jp   (iy)
	 ld   hl,$0000
	 in   a,($12)
	 bit  5,a
	 jp   nz,$3074
	 ld   a,($D011)
	 or   a
	 jp   z,$3074
	 inc  hl
	 ld   a,l
	 ret
	 call $3062
	 push hl
	 jp   (iy)
; $307C-$3095: two original compiled TERSE display helpers.
TERSE_COLON_307C:
	 RST $08
	 DB $95 ; $307D token -> native $1188
	 DB $65 ; $307E token -> native $1195
	 DB $B7 ; $307F token -> native $3076
	 DB $03 ; $3080 token -> native $01FC
	 DW TERSE_THREAD_308C ; 0BRANCH
	 DB $82 ; $3083 token -> native $00CD
	 DB $04 ; $3084 token -> native $0097
	 DB $82 ; $3085 token -> native $00CD
	 DB $04 ; $3086 token -> native $0097
	 DB $76 ; $3087 token -> native $11D0
	 DB $77 ; $3088 token -> native $11DB
	 DB $46 ; $3089 token -> native $01F4
	 DW TERSE_THREAD_308D ; BRANCH
TERSE_THREAD_308C:
	 DB $58 ; $308C token -> native $1212
TERSE_THREAD_308D:
	 DB $18 ; $308D token -> native $10EC
	 DB $17 ; $308E token -> native $10DA
	 DB $B8 ; $308F token -> native $1537
	 DB $06 ; $3090 token -> native $0044

TERSE_COLON_3091:
	 RST $08
	 DB $0E ; $3092 token -> native $0059
	 DB $40 ; LIT8
	 DB $54 ; $3094 token -> native $0154
	 DB $06 ; $3095 token -> native $0044

SPACE_ZAP_SCREEN_TEXT_PREFIX:
	 DB $11 ; original byte preceding MIDWAY copyright string
; $3097  @ 1980 MIDWAY MFG
TEXT_MIDWAY_COPYRIGHT:
	 DB "@ 1980 MIDWAY MFG"
	 dec  b
; $30A9  SPACE
TEXT_SPACE_TITLE:
	 DB "SPACE"
; Title separator and remaining three letters.
	 DB $03

TEXT_ZAP_TITLE:
	 DB "ZAP"
	 rst  $08
	 dec  de
	 sub  b
	 rst  $38
	 ld   c,$0A
	 inc  de
	 inc  bc
	 pop  bc
	 jr   nc,$3113
	 ld   b,c
	 ld   b,(hl)
	 call nz,$B630
	 ld   c,$0C
	 ld   c,$0C
	 ld   c,h
	 cp   c
	 dec  de
	 xor  b
	 jr   nc,$3086
	 ld   b,$CF
	 ld   c,$20
	 ld   c,$0A
	 inc  de
	 inc  bc
	 in   a,($30)
	 ld   d,(hl)
	 ld   b,c
	 ld   b,(hl)
	 sbc  a,$30
	 or   (hl)
	 ld   c,$0C
	 ld   c,$0C
	 ld   c,h
	 cp   c
	 dec  de
	 xor  (hl)
	 jr   nc,$30A0
	 ld   b,$CF
	 dec  c
	 cp   e
	 cp   h
	 ld   b,$0C
; $30ED  INSERT COINS
TEXT_INSERT_COINS:
	 DB "INSERT COINS"
	 add  hl,bc
; $30FA  ADD COINS
TEXT_ADD_COINS:
	 DB "ADD COINS"
	 inc  c
; $3104  FOR 2 PLAYER
TEXT_FOR_TWO_PLAYERS:
	 DB "FOR 2 PLAYER"
	 ld   (bc),a
	 ld   c,a
	 ld   d,d
	 dec  d
; $3114  PUSH 1 PLAYER TO PLAY
TEXT_PUSH_ONE_PLAYER:
	 DB "PUSH 1 PLAYER TO PLAY"
	 rlca
; $312A  DEPOSIT
TEXT_DEPOSIT:
	 DB "DEPOSIT"
	 rrca
; $3132  ADDITIONAL COIN
TEXT_ADDITIONAL_COIN:
	 DB "ADDITIONAL COIN"
	 rst  $08
	 ld   c,(hl)
	 inc  bc
	 ld   a,d
	 ld   sp,$4409
	 inc  bc
	 ld   h,h
	 ld   sp,$D41B
	 rst  $38
	 ld   c,$42
	 ld   c,$08
	 dec  de
	 add  hl,hl
	 ld   sp,$1BBA
	 or   h
	 rst  $38
	 ld   c,$34
	 ld   c,$08
	 dec  de
	 ld   sp,$BA31
	 ld   b,(hl)
	 ld   a,d
	 ld   sp,$CC1B
	 rst  $38
	 ld   c,$42
	 ld   c,$08
	 dec  de
	 ld   sp,hl
	 jr   nc,$3129
	 dec  de
	 ret  nz
	 rst  $38
	 ld   c,$34
	 ld   c,$08
	 dec  de
	 inc  bc
	 ld   sp,$06BA
	 rst  $08
	 dec  de
	 ret  pe
	 rst  $38
	 ld   c,$26
	 ld   d,(hl)
	 ld   c,$08
	 dec  de
	 djnz $31B8
	 cp   d
	 ld   b,$CF
	 dec  de
	 sbc  a,h
	 rst  $38
	 ld   c,$18
	 ld   d,(hl)
	 ld   c,$08
	 dec  de
	 inc  de
	 ld   sp,$06BA
	 ex   af,af'
; $3198  HI SCORE
TEXT_HI_SCORE:
	 DB "HI SCORE"
	 ex   af,af'
; $31A1  PLAYER 1
TEXT_PLAYER_1:
	 DB "PLAYER 1"
	 ex   af,af'
; $31AA  PLAYER 2
TEXT_PLAYER_2:
	 DB "PLAYER 2"
	 rlca
; $31B3  CREDITS
TEXT_CREDITS:
	 DB "CREDITS"
	 dec  b
; $31BB  BASES
TEXT_BASES:
	 DB "BASES"
	 ld   a,(bc)
; $31C1  BONUS BASE
TEXT_BONUS_BASE:
	 DB "BONUS BASE"
	 rst  $08
	 inc  c
	 dec  bc
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 ld   c,$05
	 cp   l
	 ld   c,$30
	 ld   c,$06
	 sub  h
	 xor  (hl)
	 pop  de
	 ex   af,af'
	 ld   c,$06
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 ex   af,af'
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 dec  c
	 cp   (hl)
	 cp   d
	 ld   b,$CF
	 dec  bc
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 ld   c,$04
	 ld   b,l
	 cp   l
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 ex   af,af'
	 dec  bc
	 sub  h
	 xor  (hl)
	 pop  de
	 cp   d
	 ld   b,$CF
	 inc  b
	 dec  h
	 cp   a
	 ld   b,$CF
	 dec  de
	 ld   l,d
	 rst  $38
	 ld   c,$55
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 dec  d
	 ret  nc
	 ret  nz
	 ld   b,$CF
	 dec  de
	 ld   l,d
	 rst  $38
	 ld   c,$39
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 rla
	 ret  nc
	 ret  nz
	 ld   b,$CF
	 ld   c,$6E
	 dec  de
	 xor  h
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 rlca
	 ret  nc
	 ld   c,$02
	 pop  bc
	 ld   b,$10
; $3233  High score and game-over announcement strings.
TEXT_NEW_HIGH_SCORE:
	 DB " N E W  H I G H "
	 DB $0B ; separator byte

TEXT_GAME_OVER:
	 DB " GAME OVER "
	 DB $16 ; original screen-text separator at $324F

; $3250  PUSH 1 OR 2 PLAYER FOR
TEXT_PUSH_ONE_OR_TWO:
	 DB "PUSH 1 OR 2 PLAYER FOR"
	 ld   a,(bc)
; $3267  1ST PLAYER
TEXT_FIRST_PLAYER:
	 DB "1ST PLAYER"
	 ld   a,(bc)
; $3272  2ND PLAYER
TEXT_SECOND_PLAYER:
	 DB "2ND PLAYER"
	 rst  $08
	 dec  de
	 ret  c
	 rst  $38
	 ld   c,$18
	 ld   d,(hl)
	 ld   c,$0C
	 dec  de
	 ld   h,(hl)
	 ld   ($06BA),a
	 rst  $08
	 dec  de
	 ret  c
	 rst  $38
	 ld   c,$18
	 ld   d,(hl)
	 ld   c,$0C
	 dec  de
	 ld   (hl),c
	 ld   ($06BA),a
	 ld   hl,$D41D
	 ld   (hl),$01
	 ld   de,$0352
	 call $12A8
	 ld   de,$015E
	 add  hl,de
	 ret
	 call $329D
	 pop  de
	 add  hl,de
	 push hl
	 jp   (iy)
	 ld   a,($D011)
	 or   a
	 jp   z,$32D1
	 ld   hl,($D017)
	 ld   de,($D420)
	 sbc  hl,de
	 jp   c,$32CE
	 call $3298
	 ld   de,($D017)
	 add  hl,de
	 ld   ($D420),hl
	 jp   $32E8
	 ld   hl,($D015)
	 ld   de,($D41E)
	 sbc  hl,de
	 jp   c,$32E8
	 call $3298
	 ld   de,($D015)
	 add  hl,de
	 ld   ($D41E),hl
	 jp   (iy)
	 pop  hl
	 ld   de,($D428)
	 or   a
	 sbc  hl,de
	 jp   c,$332C
	 ld   de,$1388
	 sbc  hl,de
	 ld   hl,$D42B
	 jp   c,$3302
	 ld   (hl),$01
	 dec  (hl)
	 jp   nz,$332C
	 ld   (hl),$05
	 ld   hl,$D42A
	 ld   a,(hl)
	 or   a
	 jp   z,$3316
	 sub  $08
	 ld   (hl),a
	 jp   $3318
	 ld   a,$08
	 ld   hl,($D428)
	 ld   de,$09C4
	 add  hl,de
	 ld   ($D428),hl
	 ld   hl,($D19C)
	 ld   e,a
	 ld   d,$00
	 add  hl,de
	 ld   ($D19C),hl
	 jp   (iy)
	 rst  $08
	 dec  de
	 ld   bc,$25D0
	 dec  de
	 di
	 call nc,$4C4B
	 daa
	 inc  bc
	 ld   d,a
	 inc  sp
	 dec  de
	 ld   a,d
	 rst  $38
	 dec  de
	 xor  h
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 ld   de,$25D0
	 inc  bc
	 ld   d,d
	 inc  sp
	 dec  de
	 inc  de
	 ret  nc
	 ld   b,(hl)
	 ld   d,l
	 inc  sp
	 dec  de
	 ld   (de),a
	 ret  nc
	 add  hl,bc
	 pop  bc
	 ld   b,$CF
	 inc  c
	 ld   c,$08
	 dec  bc
	 inc  hl
	 dec  c
	 dec  de
	 db   $dd,$05
	 jp   nz,$0327
	 ld   l,e
	 inc  sp
	 jp   $6E46
	 inc  sp
	 inc  b
	 dec  d
	 inc  b
	 dec  de
	 call c,$3F05
	 ld   h,$05
	 inc  b
	 ex   af,af'
	 ld   b,$CF
	 ld   hl,($1E0E)
	 call nz,$050E
	 dec  de
	 dec  hl
	 call nc,$C508
	 dec  de
	 dec  e
	 call nc,$0325
	 sbc  a,h
	 inc  sp
	 dec  de
	 sub  d
	 pop  de
	 ld   c,$08
	 dec  de
	 dec  d
	 ret  nc
	 add  a,$1B
	 sub  e
	 pop  de
	 ld   c,$08
	 dec  de
	 rla
	 ret  nc
	 add  a,$1B
	 ld   de,$25D0
	 inc  bc
	 xor  e
	 inc  sp
	 rst  $00
	 dec  de
	 rla
	 ret  nc
	 inc  c
	 ld   b,(hl)
	 or   b
	 inc  sp
	 ret  z
	 dec  de
	 dec  d
	 ret  nc
	 inc  c
	 ret
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 inc  bc
	 add  a,d
	 inc  sp
	 dec  (hl)
	 dec  bc
	 inc  bc
	 ld   a,h
	 inc  sp
	 ld   b,$CF
	 ld   c,$5C
	 ld   c,$55
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 dec  e
	 ret  nc
	 ret  nz
	 ld   c,$5C
	 ld   c,$47
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 rra
	 ret  nc
	 ret  nz
	 ld   c,$5C
	 ld   c,$39
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 ld   hl,$C0D0
	 dec  de
	 ld   h,d
	 rst  $38
	 ld   c,$63
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 and  b
	 ld   sp,$C8BA
	 dec  de
	 djnz $33C3
	 dec  h
	 inc  bc
	 inc  b
	 inc  (hl)
	 dec  de
	 ld   h,d
	 rst  $38
	 ld   c,$47
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 xor  c
	 ld   sp,$C7BA
	 ld   b,$ED
	 ld   e,e
	 ld   h,$D4
	 ld   hl,$1130
	 sbc  hl,de
	 jp   nc,$3414
	 ld   de,$1130
	 ld   e,d
	 ld   d,$00
	 rl   e
	 rl   e
	 pop  hl
	 or   a
	 sbc  hl,de
	 ld   de,$0005
	 add  hl,de
	 ld   a,h
	 or   a
	 jp   p,$342B
	 ld   hl,$0002
	 ld   a,l
	 cp   $02
	 jp   nc,$3433
	 ld   a,$02
	 ld   ($D18B),a
	 ld   hl,$D423
	 ld   a,($D422)
	 or   a
	 jp   nz,$3445
	 ld   (hl),$01
	 jp   $344C
	 cp   $40
	 jp   nz,$344C
	 ld   (hl),$FF
	 add  a,(hl)
	 ld   ($D422),a
	 jp   (iy)
	 rst  $08
	 ld   hl,($120E)
	 call nz,$500E
	 dec  de
	 ld   ($25D4),hl
	 jp   z,$09CB
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   e,a
	 inc  (hl)
	 dec  bc
	 inc  bc
	 ld   d,a
	 inc  (hl)
	 ld   b,$CF
	 dec  de
	 inc  h
	 ret  nc
	 dec  h
	 inc  bc
	 and  c
	 inc  (hl)
	 dec  de
	 ld   bc,$25D0
	 inc  bc
	 and  c
	 inc  (hl)
	 dec  de
	 ld   b,$D0
	 dec  h
	 inc  bc
	 adc  a,l
	 inc  (hl)
	 dec  de
	 jr   nc,$345C
	 ld   c,c
	 add  hl,bc
	 ld   b,(hl)
	 and  b
	 inc  (hl)
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 add  hl,bc
	 ld   b,h
	 inc  bc
	 sbc  a,a
	 inc  (hl)
	 dec  de
	 cpl
	 call nc,$0E49
	 ld   (bc),a
	 ld   b,(hl)
	 and  b
	 inc  (hl)
	 dec  bc
	 call z,$CF06
	 ld   hl,($CF06)
	 ld   hl,($070E)
	 call nz,$BB09
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 add  hl,bc
	 cp   h
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 inc  bc
	 xor  d
	 inc  (hl)
	 dec  bc
	 call $CF06
	 dec  bc
	 dec  de
	 nop
	 ld   b,b
	 dec  de
	 add  a,b
	 ld   a,$22
	 dec  de
	 cpl
	 call nc,$061C
	 rst  $08
	 ld   hl,($050E)
	 call nz,$1B35
	 ld   bc,$25D0
	 inc  bc
	 ld   e,$35
	 ld   b,c
	 add  hl,bc
	 ld   c,h
	 ld   c,$02
	 rrca
	 ld   c,a
	 ld   (hl),e
	 ld   b,c
	 ld   c,$03
	 ld   c,h
	 inc  d
	 dec  c
	 dec  de
	 adc  a,c
	 pop  de
	 dec  h
	 ld   b,h
	 daa
	 inc  bc
	 ei
	 inc  (hl)
	 dec  de
	 adc  a,c
	 pop  de
	 ex   af,af'
	 dec  de
	 ld   bc,$55D2
	 ld   b,(hl)
	 call m,$0534
	 dec  de
	 or   l
	 pop  de
	 ld   d,l
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 or   l
	 pop  de
	 ld   d,l
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 inc  bc
	 rla
	 dec  (hl)
	 adc  a,(hl)
	 ld   c,$04
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ret
	 out  ($55),a
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 inc  bc
	 exx
	 inc  (hl)
	 dec  (hl)
	 ld   b,$CD
	 ld   c,b
	 ld   (de),a
	 ld   a,l
	 add  a,h
	 and  $03
	 inc  a
	 ld   ($D188),a
	 ld   a,($D18B)
	 rra
	 ex   af,af'
	 ld   hl,$D18C
	 ld   a,d
	 add  a,e
	 and  $07
	 jp   nz,$353D
	 ex   af,af'
	 xor  a
	 ex   af,af'
	 ex   af,af'
	 ld   (hl),a
	 jp   (iy)
	 rst  $08
	 inc  c
	 dec  c
	 dec  de
	 dec  e
	 ret  nc
	 inc  c
	 jp   nz,$6403
	 dec  (hl)
	 dec  de
	 rra
	 ret  nc
	 inc  c
	 dec  de
	 ld   hl,$CED0
	 dec  de
	 dec  e
	 ret  nc
	 inc  c
	 dec  de
	 rra
	 ret  nc
	 adc  a,$1B
	 dec  e
	 ret  nc
	 adc  a,$09
	 ld   b,(hl)
	 sub  b
	 dec  (hl)
	 dec  c
	 dec  de
	 rra
	 ret  nc
	 inc  c
	 jp   nz,$7D03
	 dec  (hl)
	 dec  de
	 rra
	 ret  nc
	 inc  c
	 dec  de
	 ld   hl,$CED0
	 dec  de
	 rra
	 ret  nc
	 adc  a,$0B
	 ld   b,(hl)
	 sub  b
	 dec  (hl)
	 dec  c
	 dec  de
	 ld   hl,$0CD0
	 jp   nz,$8E03
	 dec  (hl)
	 dec  de
	 ld   hl,$CED0
	 dec  bc
	 ld   b,(hl)
	 sub  b
	 dec  (hl)
	 dec  b
	 dec  bc
	 ld   b,$CF
	 dec  de
	 nop
	 inc  bc
	 dec  de
	 inc  b
	 ret  nc
	 adc  a,$06
	 rst  $08
	 dec  de
	 ld   de,$25D0
	 inc  d
	 add  hl,bc
	 ld   c,h
	 dec  c
	 dec  de
	 ld   de,$47D0
	 dec  de
	 inc  hl
	 ret  nc
	 add  hl,hl
	 dec  de
	 ld   (de),a
	 ret  nc
	 rrca
	 dec  h
	 ld   b,$A4
	 rst  $08
	 ld   c,$11
	 ld   hl,$200E
	 ld   c,h
	 inc  bc
	 pop  bc
	 dec  (hl)
	 ld   c,$03
	 ld   b,(hl)
	 jp   $0E35
	 inc  b
	 ld   b,$CF
	 sbc  a,b
	 ld   c,e
	 sbc  a,a
	 ld   c,e
	 and  d
	 ld   c,e
	 sbc  a,h
	 ld   c,e
	 ld   c,h
	 ld   c,h
	 ld   c,h
	 ld   b,$CF
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 jp   po,$1B35
	 inc  bc
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   d,l
	 pop  de
	 rst  $08
	 ld   b,$CF
	 ret  nc
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 xor  $35
	 jr   z,$35F5
	 rst  $08
	 ld   hl,($030E)
	 call nz,$241B
	 ret  nc
	 dec  h
	 inc  bc
	 ret  nc
	 ld   (hl),$1B
	 ld   (de),a
	 ret  nc
	 ld   c,l
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 inc  bc
	 or   e
	 ld   (hl),$D0
	 dec  de
	 ld   d,h
	 call nc,$1BD1
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 dec  de
	 dec  d
	 ret  nc
	 ld   c,l
	 dec  de
	 rla
	 ret  nc
	 ld   c,l
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 ld   c,$02
	 jp   nc,$3C03
	 ld   (hl),$0B
	 call $981B
	 rst  $38
	 ld   c,$18
	 ld   d,(hl)
	 ld   c,$08
	 dec  de
	 ld   c,a
	 ld   ($D3BA),a
	 sub  b
	 dec  de
	 dec  h
	 call nc,$0325
	 cpl
	 ld   (hl),$09
	 ld   b,(hl)
	 ld   h,d
	 ld   (hl),$D4
	 push de
	 dec  bc
	 call $90D3
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 ld   c,$02
	 jp   nc,$5203
	 ld   (hl),$D5
	 call nc,$4609
	 ld   d,e
	 ld   (hl),$0B
	 dec  de
	 dec  h
	 call nc,$5425
	 inc  bc
	 ld   b,b
	 ld   (hl),$1B
	 rlca
	 ret  nc
	 dec  h
	 ld   c,$02
	 ld   (bc),a
	 inc  bc
	 rla
	 ld   (hl),$0B
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 ld   c,$02
	 jp   nc,$8503
	 ld   (hl),$1B
	 dec  h
	 call nc,$0E25
	 ld   (bc),a
	 jp   nc,$8503
	 ld   (hl),$1B
	 rlca
	 ret  nc
	 ld   d,e
	 sub  $1B
	 inc  de
	 ret  nc
	 ld   b,a
	 dec  b
	 add  hl,bc
	 dec  de
	 djnz $3658
	 ld   b,a
	 dec  de
	 rlca
	 ret  nc
	 ld   d,e
	 dec  de
	 dec  h
	 call nc,$D71D
	 dec  de
	 ld   de,$29D0
	 sub  $1B
	 ld   (de),a
	 ret  nc
	 ld   b,a
	 dec  de
	 ld   bc,$29D0
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 dec  de
	 djnz $3676
	 dec  h
	 daa
	 inc  bc
	 or   b
	 ld   (hl),$D8
	 ld   c,$14
	 ld   c,a
	 ld   (hl),e
	 ld   b,(hl)
	 cp   e
	 ld   (hl),$0E
	 inc  bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 di
	 call nc,$1BD9
	 ld   c,h
	 dec  e
	 dec  de
	 add  hl,de
	 ret  nc
	 adc  a,$1B
	 ld   c,h
	 dec  e
	 dec  de
	 dec  de
	 ret  nc
	 adc  a,$1B
	 ld   sp,$1DD4
	 ld   b,(hl)
	 ex   de,hl
	 ld   (hl),$1B
	 ld   bc,$29D0
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 ret  nc
	 dec  de
	 inc  hl
	 ret  nc
	 dec  h
	 inc  bc
	 ex   de,hl
	 ld   (hl),$DA
	 daa
	 inc  bc
	 ex   de,hl
	 ld   (hl),$1B
	 inc  hl
	 ret  nc
	 ld   c,d
	 jp   c,$1B05
	 inc  hl
	 call nc,$1B49
	 ld   ($1DD4),hl
	 dec  de
	 inc  hl
	 ret  nc
	 add  hl,hl
	 dec  de
	 rla
	 ret  nc
	 inc  c
	 in   a,($1B)
	 jr   nz,$36D3
	 djnz $371C
	 dec  d
	 ret  nc
	 inc  c
	 in   a,($1B)
	 ld   e,$D4
	 djnz $3725
	 dec  e
	 call nc,$D01D
	 dec  de
	 and  e
	 pop  de
	 dec  e
	 call c,$0E0B
	 ld   a,(bc)
	 rra
	 dec  de
	 nop
	 ld   bc,$1B51
	 nop
	 ld   b,b
	 rrca
	 db   $dd,$0e
	 ret  z
	 ld   c,$0A
	 rra
	 or   (hl)
	 sbc  a,$DF
	 rst  $10
	 ret  po
	 ld   c,$58
	 ld   c,$63
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 sub  a
	 ld   sp,$0EBA
	 ld   e,d
	 dec  de
	 cp   d
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 or   d
	 ld   sp,$1BBA
	 ld   l,d
	 rst  $38
	 dec  de
	 cp   d
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 cp   d
	 ld   sp,$1BBA
	 inc  h
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   bc,$25D0
	 daa
	 inc  bc
	 adc  a,d
	 scf
	 ret  nc
	 dec  de
	 djnz $372E
	 dec  h
	 inc  bc
	 adc  a,d
	 scf
	 dec  de
	 ld   de,$25D0
	 inc  bc
	 ld   l,l
	 scf
	 pop  hl
	 ld   b,(hl)
	 ld   l,(hl)
	 scf
	 jp   po,$1B90
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   l,(hl)
	 scf
	 ret  c
	 ret  po
	 ld   l,b
	 ld   c,$28
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ld   de,$25D0
	 inc  bc
	 adc  a,c
	 scf
	 pop  hl
	 ld   b,(hl)
	 adc  a,d
	 scf
	 jp   po,$4F09
	 ld   (hl),e
	 dec  de
	 and  e
	 pop  de
	 dec  h
	 daa
	 inc  bc
	 jp   z,$0E38
	 ld   h,b
	 dec  de
	 ld   hl,($08D4)
	 ld   c,$90
	 dec  de
	 sbc  a,h
	 pop  de
	 djnz $37BD
	 call nz,$1B09
	 jr   z,$377B
	 djnz $37C4
	 inc  d
	 ret  nc
	 add  hl,hl
	 dec  de
	 ld   h,$D4
	 inc  e
	 dec  de
	 di
	 call nc,$1B55
	 cp   d
	 call nc,$1BE3
	 ret
	 out  ($55),a
	 dec  de
	 ld   bc,$55D2
	 ld   l,b
	 ld   c,$1E
	 ld   c,a
	 ld   (hl),e
	 sub  b
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 push bc
	 scf
	 dec  de
	 ld   c,l
	 jp   nc,$034B
	 xor  e
	 jr   c,$37F1
	 inc  bc
	 ret  nc
	 dec  h
	 add  hl,bc
	 ld   b,h
	 inc  bc
	 jp   po,$0937
	 ld   b,(hl)
	 ex   (sp),hl
	 scf
	 dec  bc
	 dec  de
	 ld   bc,$25D0
	 daa
	 ld   d,h
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   b,a
	 ret  nc
	 dec  de
	 dec  e
	 call nc,$0325
	 ld   a,($9038)
	 call po,$F503
	 scf
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   a,($1B38)
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 inc  d
	 jr   c,$3819
	 ld   (bc),a
	 dec  de
	 inc  bc
	 ret  nc
	 ld   b,a
	 dec  de
	 ld   d,l
	 pop  de
	 push hl
	 ld   c,$05
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ld   c,l
	 jp   nc,$09E6
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ld   c,l
	 jp   nc,$1B4B
	 dec  e
	 call nc,$2725
	 ld   c,h
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 ld   d,h
	 inc  bc
	 inc  e
	 jr   c,$3802
	 dec  de
	 dec  e
	 call nc,$0E1D
	 ld   e,$4F
	 ld   (hl),e
	 dec  de
	 ld   bc,$25D0
	 daa
	 dec  de
	 ld   sp,$25D4
	 ld   c,h
	 inc  bc
	 sub  c
	 jr   c,$3818
	 dec  de
	 ld   sp,$1DD4
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 call po,$4C03
	 jr   c,$3862
	 inc  c
	 dec  de
	 dec  d
	 call nc,$1B08
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   l,c
	 jr   c,$387D
	 inc  bc
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   d,l
	 pop  de
	 rst  $20
	 ret  po
	 ret  nc
	 dec  de
	 ret  c
	 rst  $38
	 dec  de
	 out  ($FF),a
	 ld   d,(hl)
	 ld   c,$0C
	 dec  de
	 ret  nz
	 ld   sp,$68BA
	 ld   c,$0A
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 dec  d
	 call nc,$1B43
	 dec  d
	 call nc,$2725
	 inc  bc
	 ld   l,d
	 jr   c,$3898
	 inc  d
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ld   ($1DD4),hl
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 xor  e
	 jr   c,$38B5
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 and  l
	 jr   c,$38BD
	 ld   d,l
	 pop  de
	 ret  pe
	 jp   (hl)
	 dec  de
	 ld   c,l
	 jp   nc,$D055
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 inc  bc
	 adc  a,$37
	 ret  nc
	 ld   l,b
	 ld   c,$28
	 ld   c,a
	 ld   (hl),e
	 ret  po
	 ret  nc
	 sub  b
	 dec  de
	 ret
	 out  ($4B),a
	 dec  de
	 ld   d,l
	 pop  de
	 ld   c,e
	 ld   c,h
	 inc  bc
	 cp   l
	 jr   c,$38E6
	 add  a,a
	 ret  nc
	 dec  e
	 dec  de
	 ld   bc,$25D0
	 dec  de
	 di
	 call nc,$4C4B
	 inc  bc
	 sbc  a,$38
	 add  hl,bc
	 ld   b,(hl)
	 ld   e,b
	 add  hl,sp
	 ret  nc
	 dec  de
	 cp   d
	 call nc,$0E55
	 ld   e,$4F
	 ld   (hl),e
	 dec  de
	 inc  hl
	 call nc,$1B49
	 ld   ($1DD4),hl
	 jp   c,$F703
	 jr   c,$38FF
	 ld   b,(hl)
	 ld   e,b
	 add  hl,sp
	 dec  de
	 inc  hl
	 ret  nc
	 ld   c,d
	 jp   c,$0303
	 add  hl,sp
	 dec  bc
	 ld   b,(hl)
	 ld   e,b
	 add  hl,sp
	 dec  de
	 dec  d
	 ret  nc
	 jp   pe,$171B
	 ret  nc
	 jp   pe,$0DDF
	 dec  de
	 ld   de,$47D0
	 ld   d,h
	 inc  bc
	 add  hl,sp
	 add  hl,sp
	 sub  b
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 dec  d
	 add  hl,sp
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   d,l
	 pop  de
	 ex   de,hl
	 dec  de
	 ret  nz
	 rst  $38
	 dec  de
	 rst  $30
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 ld   ($BA32),a
	 ld   l,b
	 ret  nc
	 ld   c,$6E
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   b,l
	 add  hl,sp
	 dec  de
	 ld   d,l
	 pop  de
	 rst  $08
	 dec  de
	 call nc,$0EFF
	 dec  b
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 ld   b,e
	 ld   ($1BBA),a
	 ld   de,$29D0
	 or   (hl)
	 sbc  a,$09
	 inc  bc
	 dec  c
	 scf
	 ret  nc
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 ld   l,c
	 add  hl,sp
	 ld   c,$96
	 ld   b,(hl)
	 ld   l,e
	 add  hl,sp
	 ld   c,$32
	 ld   l,b
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 ld   ($55D4),a
	 ld   b,$00
	 dec  b
	 nop
	 inc  bc
	 add  a,b
	 nop
	 nop
	 ld   bc,$B7D9
	 rla
	 ld   hl,$3973
	 ld   e,a
	 ld   d,$00
	 add  hl,de
	 ld   e,(hl)
	 inc  hl
	 ld   d,(hl)
	 ld   hl,($D006)
	 add  hl,de
	 ex   de,hl
	 ld   hl,$D006
	 call $1EBB
	 exx
	 ret
	 exx
	 ld   hl,$D00D
	 ld   e,$01
	 call $1EDE
	 exx
	 ret
	 ld   de,$D155
	 call $1FC3
	 ld   e,$06
	 dec  l
	 jp   nz,$39A8
	 dec  h
	 jp   nz,$39A8
	 dec  e
	 jp   nz,$39A8
	 jp   $0000
	 push af
	 push hl
	 push de
	 push bc
	 ex   af,af'
	 exx
	 push af
	 push hl
	 push de
	 push bc
	 ld   a,($D42C)
	 out  ($04),a
	 ld   a,($D001)
	 or   a
	 jp   nz,$3A41
	 ld   a,($D014)
	 or   a
	 jp   nz,$3A41
	 call $3062
	 ld   hl,$D41A
	 or   a
	 jp   nz,$39E3
	 in   a,($12)
	 jp   $39E5
	 in   a,($11)
	 and  $0F
	 ld   e,a
	 xor  (hl)
	 jp   z,$3A30
	 and  (hl)
	 jp   z,$3A13
	 ld   hl,$D41A
	 ld   (hl),e
	 inc  hl
	 ld   (hl),e
	 inc  hl
	 ld   (hl),$00
	 ld   d,$01
	 bit  0,a
	 jp   nz,$3A0D
	 inc  d
	 bit  3,a
	 jp   nz,$3A0D
	 inc  d
	 bit  1,a
	 jp   nz,$3A0D
	 inc  d
	 jp   $3A32
	 jp   $3A30
	 inc  hl
	 ld   (hl),e
	 ld   a,e
	 cp   $0F
	 jp   z,$3A30
	 inc  hl
	 xor  a
	 cp   (hl)
	 jp   nz,$3A26
	 ld   (hl),$03
	 jp   $3A30
	 dec  (hl)
	 jp   nz,$3A30
	 ld   a,e
	 xor  $0F
	 jp   $39F0
	 ld   d,$00
	 ld   a,d
	 ld   hl,$D189
	 or   a
	 jp   z,$3A3B
	 ld   (hl),a
	 ld   a,(hl)
	 inc  hl
	 cp   (hl)
	 jp   nz,$3A44
	 ld   hl,$0000
	 ld   a,h
	 or   l
	 ld   ($D417),a
	 ld   hl,($D004)
	 ld   de,$0001
	 or   a
	 sbc  hl,de
	 jp   nc,$3A58
	 jp   $0000
	 ld   de,$D004
	 ex   de,hl
	 call $1EBB
	 in   a,($10)
	 bit  3,a
	 jp   nz,$3A71
	 ld   e,$01
	 ld   hl,$D00E
	 call $1EDE
	 jp   $39A0
	 bit  2,a
	 jp   nz,$3A79
	 jp   $39A0
	 ld   b,a
	 in   a,($10)
	 cp   b
	 jp   nz,$3A79
	 ld   hl,$D00F
	 ld   bc,$FFFF
	 xor  (hl)
	 bit  0,a
	 jp   z,$3AB6
	 ex   af,af'
	 ld   a,(hl)
	 bit  0,a
	 jp   z,$3A9D
	 res  0,a
	 ld   e,a
	 call $1EDE
	 ex   af,af'
	 jp   $3AB6
	 set  0,a
	 ld   e,a
	 call $1EDE
	 call $3995
	 exx
	 ld   a,($D00C)
	 ld   b,a
	 ld   c,$13
	 in   a,(c)
	 and  $01
	 or   $02
	 exx
	 ld   c,a
	 ex   af,af'
	 bit  1,a
	 jp   z,$3AF4
	 ex   af,af'
	 ld   a,(hl)
	 bit  1,a
	 jp   z,$3ACC
	 res  1,a
	 ld   e,a
	 call $1EDE
	 ex   af,af'
	 jp   $3AF4
	 set  1,a
	 ld   e,a
	 call $1EDE
	 call $3995
	 exx
	 ld   a,($D00C)
	 ld   c,$13
	 ld   b,a
	 in   a,(c)
	 ld   b,a
	 and  $06
	 rra
	 ld   c,a
	 ld   a,b
	 and  $01
	 or   $02
	 cp   c
	 jp   z,$3AF2
	 ld   a,c
	 exx
	 ld   b,a
	 jp   $3AF4
	 exx
	 ld   c,a
	 ld   a,c
	 cp   $FF
	 jp   z,$3B05
	 call $397B
	 ld   hl,$D009
	 ld   e,(hl)
	 inc  e
	 call $1EDE
	 ld   a,b
	 cp   $FF
	 jp   z,$3B25
	 call $397B
	 cp   c
	 jp   nz,$3B1D
	 ld   hl,$D009
	 ld   e,(hl)
	 inc  e
	 call $1EDE
	 jp   $3B25
	 ld   hl,$D00B
	 ld   e,(hl)
	 inc  e
	 call $1EDE
	 ld   c,$13
	 xor  a
	 ld   b,a
	 ld   hl,$D008
	 cp   (hl)
	 jp   z,$3B43
	 ld   e,(hl)
	 dec  e
	 call $1EDE
	 ld   hl,$D008
	 ld   a,$0A
	 cp   (hl)
	 jp   nc,$3B40
	 set  0,b
	 jp   $3B55
	 inc  hl
	 cp   (hl)
	 jp   z,$3B55
	 ld   e,(hl)
	 dec  e
	 call $1EDE
	 ld   hl,$D008
	 ld   e,$14
	 call $1EDE
	 xor  a
	 ld   hl,$D00A
	 cp   (hl)
	 jp   z,$3B70
	 ld   e,(hl)
	 dec  e
	 call $1EDE
	 ld   hl,$D00A
	 ld   a,$0A
	 cp   (hl)
	 jp   nc,$3B6D
	 set  1,b
	 jp   $3B82
	 inc  hl
	 cp   (hl)
	 jp   z,$3B82
	 ld   e,(hl)
	 dec  e
	 call $1EDE
	 ld   hl,$D00A
	 ld   e,$14
	 call $1EDE
	 in   a,(c)
	 ld   e,b
	 ld   hl,$D00C
	 call $1EDE
	 call $3062
	 or   a
	 jp   nz,$3B97
	 in   a,($12)
	 jp   $3B99
	 in   a,($11)
	 ld   hl,$D419
	 xor  (hl)
	 bit  4,a
	 jp   z,$3BB5
	 bit  4,(hl)
	 jp   z,$3BAE
	 res  4,(hl)
	 ld   d,$01
	 jp   $3BB2
	 set  4,(hl)
	 ld   d,$00
	 jp   $3BB7
	 ld   d,$00
	 ld   a,($D001)
	 ld   l,a
	 ld   a,($D014)
	 or   l
	 ld   hl,$D418
	 jp   z,$3BC9
	 ld   d,$00
	 ld   (hl),$00
	 ld   a,d
	 add  a,(hl)
	 ld   (hl),a
	 pop  bc
	 pop  de
	 pop  hl
	 pop  af
	 exx
	 ex   af,af'
	 pop  bc
	 pop  de
	 pop  hl
	 pop  af
	 jp   $05F2
	 ld   a,($D007)
	 or   a
	 jp   z,$3BFA
	 ld   a,($D001)
	 or   a
	 jp   z,$3BFA
	 in   a,($10)
	 ld   hl,$D425
	 bit  4,a
	 jp   nz,$3BF3
	 ld   (hl),$01
	 bit  5,a
	 jp   nz,$3BFA
	 ld   (hl),$02
	 jp   (iy)
	 rst  $08
	 ld   hl,($C00E)
	 call nz,$540E
	 ld   c,$05
	 rra
	 ld   c,$C5
	 ld   c,$06
	 rra
	 ld   c,$7F
	 ld   c,$07
	 rra
	 ret  nc
	 call c,$DEB6
	 dec  de
	 inc  h
	 ret  nc
	 dec  h
	 inc  bc
	 ld   h,c
	 inc  a
	 rst  $10
	 dec  bc
	 call $AC1B
	 rst  $38
	 ld   c,$5E
	 or   (hl)
	 ld   c,$04
	 dec  de
	 sub  (hl)
	 jr   nc,$3BE4
	 dec  de
	 ret  nz
	 rst  $38
	 dec  de
	 xor  h
	 rst  $38
	 or   (hl)
	 ld   c,$0C
	 dec  de
	 call pe,$BA30
	 dec  de
	 rlca
	 ret  nc
	 dec  h
	 inc  bc
	 ld   d,l
	 inc  a
	 dec  de
	 dec  h
	 call nc,$2725
	 inc  bc
	 ld   d,d
	 inc  a
	 dec  de
	 ld   (bc),a
	 ret  nc
	 ld   c,d
	 dec  de
	 inc  bc
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   d,l
	 pop  de
	 call pe,$6146
	 inc  a
	 dec  de
	 ld   d,h
	 call nc,$28ED
	 dec  de
	 ld   (bc),a
	 ret  nc
	 add  hl,hl
	 add  hl,bc
	 ld   c,a
	 ld   (hl),e
	 dec  de
	 sbc  a,b
	 call nc,$35EE
	 dec  bc
	 inc  bc
	 djnz $3CA6
	 ld   b,$CF
	 ld   hl,($171B)
	 call nc,$0325
	 ld   a,b
	 inc  a
	 dec  de
	 ld   bc,$55D2
	 dec  de
	 dec  c
	 ret  nc
	 dec  h
	 inc  bc
	 or   l
	 inc  a
	 dec  de
	 dec  c
	 ret  nc
	 add  hl,hl
	 ld   d,(hl)
	 dec  de
	 cpl
	 call nc,$0325
	 sub  d
	 inc  a
	 ld   c,$02
	 call z,$2F1B
	 call nc,$1B1D
	 jr   nc,$3C69
	 dec  h
	 inc  bc
	 sbc  a,a
	 inc  a
	 add  hl,bc
	 call z,$301B
	 call nc,$B61D
	 sbc  a,$1B
	 ld   bc,$25D0
	 inc  bc
	 xor  h
	 inc  a
	 dec  de
	 and  e
	 pop  de
	 ld   c,c
	 rst  $10
	 dec  de
	 inc  bc
	 ret  nc
	 ld   c,d
	 dec  de
	 ld   d,l
	 pop  de
	 call pe,$1BEF
	 jr   $3C8D
	 dec  h
	 inc  bc
	 push de
	 inc  a
	 dec  de
	 inc  d
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 push de
	 inc  a
	 dec  de
	 or   l
	 pop  de
	 ld   d,l
	 dec  de
	 inc  bc
	 ret  nc
	 dec  h
	 daa
	 inc  bc
	 push de
	 inc  a
	 dec  de
	 ld   d,l
	 pop  de
	 ret  p
	 sub  b
	 dec  bc
	 inc  bc
	 ld   l,l
	 inc  a
; $3CDA: end of preceding compiled TERSE word.
	 DB $06 ; TERSE_EXIT (token $06)
; $3CDB: RST 08 colon entry; cold start sets BC to the following byte.
SPACE_ZAP_MAIN_COLON:
	 DB $CF ; RST $08
; $3CDC-$3DE8: original main TERSE byte-token program.
; 8-bit token -> native target through TERSE_TOKEN_VECTORS.
; Inline byte/word literals and absolute branch addresses follow their tokens.
SPACE_ZAP_MAIN_THREAD:
	 DB $F1 ; $3CDC token $F1 -> XT $2F67
	 DB $F2 ; $3CDD token $F2 -> XT $1311
	 DB $F3 ; $3CDE token $F3 -> XT $1F92
	 DB $F4 ; $3CDF token $F4 -> XT $1F20
	 DB $1B ; $3CE0 token $1B -> TERSE_LIT16
	 DW $D024 ; inline word
	 DB $4A ; $3CE3 token $4A -> XT $1F08
	 DB $1B ; $3CE4 token $1B -> TERSE_LIT16
	 DW $D00E ; inline word
	 DB $25 ; $3CE7 token $25 -> TERSE_BYTE_FETCH
	 DB $03 ; $3CE8 token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D05 ; 0BRANCH target $3D05
	 DB $1B ; $3CEB token $1B -> TERSE_LIT16
	 DW $D00E ; inline word
	 DB $29 ; $3CEE token $29 -> XT $1F10
	 DB $1B ; $3CEF token $1B -> TERSE_LIT16
	 DW $D001 ; inline word
	 DB $4A ; $3CF2 token $4A -> XT $1F08
	 DB $1B ; $3CF3 token $1B -> TERSE_LIT16
	 DW $D006 ; inline word
	 DB $29 ; $3CF6 token $29 -> XT $1F10
	 DB $1B ; $3CF7 token $1B -> TERSE_LIT16
	 DW $D007 ; inline word
	 DB $25 ; $3CFA token $25 -> TERSE_BYTE_FETCH
	 DB $03 ; $3CFB token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D02 ; 0BRANCH target $3D02
	 DB $1B ; $3CFE token $1B -> TERSE_LIT16
	 DW $D007 ; inline word
	 DB $53 ; $3D01 token $53 -> XT $1F18

SPACE_ZAP_THREAD_3D02:
	 DB $46 ; $3D02 token $46 -> TERSE_BRANCH_ABSOLUTE
	 DW SPACE_ZAP_THREAD_3D25 ; BRANCH target $3D25

SPACE_ZAP_THREAD_3D05:
	 DB $1B ; $3D05 token $1B -> TERSE_LIT16
	 DW $D001 ; inline word
	 DB $25 ; $3D08 token $25 -> TERSE_BYTE_FETCH
	 DB $27 ; $3D09 token $27 -> XT $0139
	 DB $03 ; $3D0A token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D25 ; 0BRANCH target $3D25
	 DB $1B ; $3D0D token $1B -> TERSE_LIT16
	 DW $D012 ; inline word
	 DB $25 ; $3D10 token $25 -> TERSE_BYTE_FETCH
	 DB $0E ; $3D11 token $0E -> TERSE_LIT8
	 DB $0D ; inline byte
	 DB $02 ; $3D13 token $02 -> XT $010C
	 DB $03 ; $3D14 token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D25 ; 0BRANCH target $3D25
	 DB $1B ; $3D17 token $1B -> TERSE_LIT16
	 DW $D013 ; inline word
	 DB $25 ; $3D1A token $25 -> TERSE_BYTE_FETCH
	 DB $0E ; $3D1B token $0E -> TERSE_LIT8
	 DB $0D ; inline byte
	 DB $02 ; $3D1D token $02 -> XT $010C
	 DB $03 ; $3D1E token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D25 ; 0BRANCH target $3D25
	 DB $1B ; $3D21 token $1B -> TERSE_LIT16
	 DW $D024 ; inline word
	 DB $29 ; $3D24 token $29 -> XT $1F10

SPACE_ZAP_THREAD_3D25:
	 DB $0E ; $3D25 token $0E -> TERSE_LIT8
	 DB $10 ; inline byte
	 DB $21 ; $3D27 token $21 -> TERSE_PORT_IN
	 DB $0E ; $3D28 token $0E -> TERSE_LIT8
	 DB $04 ; inline byte
	 DB $4C ; $3D2A token $4C -> TERSE_BITWISE_AND
	 DB $27 ; $3D2B token $27 -> XT $0139
	 DB $03 ; $3D2C token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D6B ; 0BRANCH target $3D6B
	 DB $0B ; $3D2F token $0B -> TERSE_ZERO
	 DB $0E ; $3D30 token $0E -> TERSE_LIT8
	 DB $09 ; inline byte
	 DB $09 ; $3D32 token $09 -> TERSE_ONE
	 DB $23 ; $3D33 token $23 -> XT $016D
	 DB $0B ; $3D34 token $0B -> TERSE_ZERO
	 DB $1B ; $3D35 token $1B -> TERSE_LIT16
	 DW $0800 ; inline word
	 DB $0B ; $3D38 token $0B -> TERSE_ZERO
	 DB $23 ; $3D39 token $23 -> XT $016D
	 DB $F5 ; $3D3A token $F5 -> XT $01BF
	 DB $24 ; $3D3B token $24 -> TERSE_LOOP_INDEX
	 DB $0F ; $3D3C token $0F -> TERSE_ADD
	 DB $25 ; $3D3D token $25 -> TERSE_BYTE_FETCH
	 DB $0F ; $3D3E token $0F -> TERSE_ADD
	 DB $0E ; $3D3F token $0E -> TERSE_LIT8
	 DB $10 ; inline byte
	 DB $21 ; $3D41 token $21 -> TERSE_PORT_IN
	 DB $05 ; $3D42 token $05 -> TERSE_DROP
	 DB $26 ; $3D43 token $26 -> XT $0188
	 DB $0E ; $3D44 token $0E -> TERSE_LIT8
	 DB $FF ; inline byte
	 DB $4C ; $3D46 token $4C -> TERSE_BITWISE_AND
	 DB $0E ; $3D47 token $0E -> TERSE_LIT8
	 DB $FF ; inline byte
	 DB $44 ; $3D49 token $44 -> XT $00EE
	 DB $27 ; $3D4A token $27 -> XT $0139
	 DB $03 ; $3D4B token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D62 ; 0BRANCH target $3D62
	 DB $1B ; $3D4E token $1B -> TERSE_LIT16
	 DW $D432 ; inline word
	 DB $1B ; $3D51 token $1B -> TERSE_LIT16
	 DW $D098 ; inline word
	 DB $10 ; $3D54 token $10 -> TERSE_STORE
	 DB $24 ; $3D55 token $24 -> TERSE_LOOP_INDEX
	 DB $0D ; $3D56 token $0D -> TERSE_DUP
	 DB $0F ; $3D57 token $0F -> TERSE_ADD
	 DB $0D ; $3D58 token $0D -> TERSE_DUP
	 DB $0F ; $3D59 token $0F -> TERSE_ADD
	 DB $0D ; $3D5A token $0D -> TERSE_DUP
	 DB $0F ; $3D5B token $0F -> TERSE_ADD
	 DB $0B ; $3D5C token $0B -> TERSE_ZERO
	 DB $0E ; $3D5D token $0E -> TERSE_LIT8
	 DB $0C ; inline byte
	 DB $09 ; $3D5F token $09 -> TERSE_ONE
	 DB $24 ; $3D60 token $24 -> TERSE_LOOP_INDEX
	 DB $BF ; $3D61 token $BF -> XT $31EC

SPACE_ZAP_THREAD_3D62:
	 DB $1B ; $3D62 token $1B -> TERSE_LIT16
	 DW $0800 ; inline word
	 DB $0F ; $3D65 token $0F -> TERSE_ADD
	 DB $26 ; $3D66 token $26 -> XT $0188

SPACE_ZAP_THREAD_3D67:
	 DB $0B ; $3D67 token $0B -> TERSE_ZERO
	 DB $03 ; $3D68 token $03 -> TERSE_ZERO_BRANCH
	 DW SPACE_ZAP_THREAD_3D67 ; 0BRANCH target $3D67

SPACE_ZAP_THREAD_3D6B:
	 DB $D0 ; $3D6B token $D0 -> XT $3591
	 DB $F3 ; $3D6C token $F3 -> XT $1F92
	 DB $34 ; $3D6D token $34 -> XT $219C
	 DB $1B ; $3D6E token $1B -> TERSE_LIT16
	 DW $D189 ; inline word
	 DB $49 ; $3D71 token $49 -> XT $0262
	 DB $0E ; $3D72 token $0E -> TERSE_LIT8
	 DB $55 ; inline byte
	 DB $1B ; $3D74 token $1B -> TERSE_LIT16
	 DW $D18B ; inline word
	 DB $08 ; $3D77 token $08 -> TERSE_BYTE_STORE
	 DB $1B ; $3D78 token $1B -> TERSE_LIT16
	 DW $D001 ; inline word
	 DB $4A ; $3D7B token $4A -> XT $1F08
	 DB $1B ; $3D7C token $1B -> TERSE_LIT16
	 DW $D42C ; inline word
	 DB $1D ; $3D7F token $1D -> XT $0266
	 DB $1B ; $3D80 token $1B -> TERSE_LIT16
	 DW $D42D ; inline word
	 DB $1C ; $3D83 token $1C -> TERSE_ZERO_WORD_AT_ADDRESS
	 DB $1B ; $3D84 token $1B -> TERSE_LIT16
	 DW $D08A ; inline word
	 DB $1D ; $3D87 token $1D -> XT $0266
	 DB $1B ; $3D88 token $1B -> TERSE_LIT16
	 DW $D08B ; inline word
	 DB $1D ; $3D8B token $1D -> XT $0266
	 DB $1B ; $3D8C token $1B -> TERSE_LIT16
	 DW $D08C ; inline word
	 DB $1D ; $3D8F token $1D -> XT $0266
	 DB $1B ; $3D90 token $1B -> TERSE_LIT16
	 DW $D08D ; inline word
	 DB $1D ; $3D93 token $1D -> XT $0266
	 DB $1B ; $3D94 token $1B -> TERSE_LIT16
	 DW $D08E ; inline word
	 DB $1D ; $3D97 token $1D -> XT $0266
	 DB $0E ; $3D98 token $0E -> TERSE_LIT8
	 DB $3F ; inline byte
	 DB $1B ; $3D9A token $1B -> TERSE_LIT16
	 DW $D419 ; inline word
	 DB $08 ; $3D9D token $08 -> TERSE_BYTE_STORE
	 DB $0E ; $3D9E token $0E -> TERSE_LIT8
	 DB $0F ; inline byte
	 DB $1B ; $3DA0 token $1B -> TERSE_LIT16
	 DW $D41A ; inline word
	 DB $08 ; $3DA3 token $08 -> TERSE_BYTE_STORE
	 DB $1B ; $3DA4 token $1B -> TERSE_LIT16
	 DW $D087 ; inline word
	 DB $1D ; $3DA7 token $1D -> XT $0266
	 DB $1B ; $3DA8 token $1B -> TERSE_LIT16
	 DW $D4BA ; inline word
	 DB $D1 ; $3DAB token $D1 -> XT $34A2
	 DB $1B ; $3DAC token $1B -> TERSE_LIT16
	 DW $D4F3 ; inline word
	 DB $D1 ; $3DAF token $D1 -> XT $34A2
	 DB $1B ; $3DB0 token $1B -> TERSE_LIT16
	 DW $D498 ; inline word
	 DB $D1 ; $3DB3 token $D1 -> XT $34A2
	 DB $98 ; $3DB4 token $98 -> XT $26D2
	 DB $B1 ; $3DB5 token $B1 -> XT $2D7D
	 DB $9F ; $3DB6 token $9F -> XT $26DC
	 DB $B2 ; $3DB7 token $B2 -> XT $2CB2
	 DB $1B ; $3DB8 token $1B -> TERSE_LIT16
	 DW $D3C9 ; inline word
	 DB $F6 ; $3DBB token $F6 -> XT $2DE3
	 DB $9C ; $3DBC token $9C -> XT $26D7
	 DB $B4 ; $3DBD token $B4 -> XT $2C4E
	 DB $A2 ; $3DBE token $A2 -> XT $26E1
	 DB $B3 ; $3DBF token $B3 -> XT $2D19
	 DB $1B ; $3DC0 token $1B -> TERSE_LIT16
	 DW $D014 ; inline word
	 DB $4A ; $3DC3 token $4A -> XT $1F08
	 DB $1B ; $3DC4 token $1B -> TERSE_LIT16
	 DW $D24D ; inline word
	 DB $92 ; $3DC7 token $92 -> XT $275C
	 DB $1B ; $3DC8 token $1B -> TERSE_LIT16
	 DW $D432 ; inline word
	 DB $F7 ; $3DCB token $F7 -> XT $3BFC
	 DB $1B ; $3DCC token $1B -> TERSE_LIT16
	 DW $D201 ; inline word
	 DB $F8 ; $3DCF token $F8 -> XT $2ED6
	 DB $1B ; $3DD0 token $1B -> TERSE_LIT16
	 DW $D1B5 ; inline word
	 DB $B5 ; $3DD3 token $B5 -> XT $2BC0
	 DB $1B ; $3DD4 token $1B -> TERSE_LIT16
	 DW $D4DC ; inline word
	 DB $F9 ; $3DD7 token $F9 -> XT $3452
	 DB $1B ; $3DD8 token $1B -> TERSE_LIT16
	 DW $D3C9 ; inline word
	 DB $F6 ; $3DDB token $F6 -> XT $2DE3
	 DB $1B ; $3DDC token $1B -> TERSE_LIT16
	 DW $D476 ; inline word
	 DB $FA ; $3DDF token $FA -> XT $3C6B
	 DB $1B ; $3DE0 token $1B -> TERSE_LIT16
	 DW $39B7 ; inline word
	 DB $1B ; $3DE3 token $1B -> TERSE_LIT16
	 DW $D080 ; inline word
	 DB $10 ; $3DE6 token $10 -> TERSE_STORE
	 DB $FB ; $3DE7 token $FB -> XT $0394
	 DB $06 ; $3DE8 token $06 -> TERSE_EXIT

SPACE_ZAP_MAIN_TRAILING_BYTE:
	 DB $F3 ; byte between EXIT and vector table
; $3DEA-$3FE9: 256 indexed TERSE native execution vectors.
; Each byte token from BC selects one little-endian DW.
; Derived from the official ROM. Undefined tokens remain $FFFF.
TERSE_TOKEN_VECTORS:
	 DW $0000	; token $00 (zero vector)
	 DW TERSE_2DUP	; token $01
	 DW $010C	; token $02
	 DW TERSE_ZERO_BRANCH	; token $03
	 DW TERSE_SWAP	; token $04
	 DW TERSE_DROP	; token $05
	 DW TERSE_EXIT	; token $06
	 DW $0134	; token $07
	 DW TERSE_BYTE_STORE	; token $08
	 DW TERSE_ONE	; token $09
	 DW $025E	; token $0A
	 DW TERSE_ZERO	; token $0B
	 DW TERSE_FETCH	; token $0C
	 DW TERSE_DUP	; token $0D
	 DW TERSE_LIT8	; token $0E
	 DW TERSE_ADD	; token $0F
	 DW TERSE_STORE	; token $10
	 DW $FFFF	; token $11 (unassigned)
	 DW $040B	; token $12
	 DW TERSE_STACK_ROTATE	; token $13
	 DW TERSE_INCREMENT	; token $14
	 DW TERSE_DECREMENT	; token $15
	 DW TERSE_MEMORY_COPY	; token $16
	 DW $10DA	; token $17
	 DW $10EC	; token $18
	 DW $11FC	; token $19
	 DW $1207	; token $1A
	 DW TERSE_LIT16	; token $1B
	 DW TERSE_ZERO_WORD_AT_ADDRESS	; token $1C
	 DW $0266	; token $1D
	 DW $027E	; token $1E
	 DW TERSE_PORT_OUT	; token $1F
	 DW $05E5	; token $20
	 DW TERSE_PORT_IN	; token $21
	 DW $0D43	; token $22
	 DW $016D	; token $23
	 DW TERSE_LOOP_INDEX	; token $24
	 DW TERSE_BYTE_FETCH	; token $25
	 DW $0188	; token $26
	 DW $0139	; token $27
	 DW $2193	; token $28
	 DW $1F10	; token $29
	 DW $042F	; token $2A
	 DW $21A3	; token $2B
	 DW $2126	; token $2C
	 DW $2146	; token $2D
	 DW $2101	; token $2E
	 DW $2119	; token $2F
	 DW $2188	; token $30
	 DW $2162	; token $31
	 DW $216C	; token $32
	 DW $20E1	; token $33
	 DW $219C	; token $34
	 DW $04A6	; token $35
	 DW $1216	; token $36
	 DW $21AA	; token $37
	 DW $21D8	; token $38
	 DW $111E	; token $39
	 DW TERSE_ARITH_SHIFT_RIGHT	; token $3A
	 DW $112D	; token $3B
	 DW $20FE	; token $3C
	 DW $023E	; token $3D
	 DW $2223	; token $3E
	 DW TERSE_SUBTRACT	; token $3F
	 DW $2154	; token $40
	 DW $12B1	; token $41
	 DW $218D	; token $42
	 DW TERSE_DECREMENT_BYTE_AT_ADDRESS	; token $43
	 DW $00EE	; token $44
	 DW TERSE_STACK_PICK	; token $45
	 DW TERSE_BRANCH_ABSOLUTE	; token $46
	 DW $1F01	; token $47
	 DW $2350	; token $48
	 DW $0262	; token $49
	 DW $1F08	; token $4A
	 DW $1237	; token $4B
	 DW TERSE_BITWISE_AND	; token $4C
	 DW $1EF8	; token $4D
	 DW $013F	; token $4E
	 DW $0EC7	; token $4F
	 DW $24F6	; token $50
	 DW $12B7	; token $51
	 DW $0217	; token $52
	 DW $1F18	; token $53
	 DW TERSE_BITWISE_OR	; token $54
	 DW $04BB	; token $55
	 DW $11C3	; token $56
	 DW $121C	; token $57
	 DW $1212	; token $58
	 DW $11A0	; token $59
	 DW $11F1	; token $5A
	 DW $0E11	; token $5B
	 DW $109C	; token $5C
	 DW $0E26	; token $5D
	 DW $0FDC	; token $5E
	 DW $0FCA	; token $5F
	 DW $0FB8	; token $60
	 DW $0FA6	; token $61
	 DW $2393	; token $62
	 DW $1158	; token $63
	 DW $0220	; token $64
	 DW $1195	; token $65
	 DW $0E31	; token $66
	 DW $1182	; token $67
	 DW $1229	; token $68
	 DW $0F98	; token $69
	 DW $10CD	; token $6A
	 DW $10B7	; token $6B
	 DW $0CE2	; token $6C
	 DW $12C7	; token $6D
	 DW $11B6	; token $6E
	 DW $24E8	; token $6F
	 DW $11AB	; token $70
	 DW $1166	; token $71
	 DW $24FD	; token $72
	 DW $0D11	; token $73
	 DW $254C	; token $74
	 DW $22FA	; token $75
	 DW $11D0	; token $76
	 DW $11DB	; token $77
	 DW $24DA	; token $78
	 DW $0EDA	; token $79
	 DW $0EED	; token $7A
	 DW $2718	; token $7B
	 DW $263E	; token $7C
	 DW $100A	; token $7D
	 DW $2833	; token $7E
	 DW $1026	; token $7F
	 DW $282F	; token $80
	 DW $2837	; token $81
	 DW $00CD	; token $82
	 DW $0E4D	; token $83
	 DW $0FEE	; token $84
	 DW $0FFC	; token $85
	 DW $1055	; token $86
	 DW $1042	; token $87
	 DW $1068	; token $88
	 DW $1077	; token $89
	 DW $2866	; token $8A
	 DW $2855	; token $8B
	 DW $2877	; token $8C
	 DW $225E	; token $8D
	 DW $25D0	; token $8E
	 DW $2287	; token $8F
	 DW $047E	; token $90
	 DW $26B6	; token $91
	 DW $275C	; token $92
	 DW $0229	; token $93
	 DW $006B	; token $94
	 DW $1188	; token $95
	 DW $26E6	; token $96
	 DW $2704	; token $97
	 DW $26D2	; token $98
	 DW $2AE2	; token $99
	 DW $26EB	; token $9A
	 DW $2709	; token $9B
	 DW $26D7	; token $9C
	 DW $26F0	; token $9D
	 DW $26FA	; token $9E
	 DW $26DC	; token $9F
	 DW $26F5	; token $A0
	 DW $26FF	; token $A1
	 DW $26E1	; token $A2
	 DW $11E6	; token $A3
	 DW $2AF6	; token $A4
	 DW $12DB	; token $A5
	 DW $113C	; token $A6
	 DW $10FE	; token $A7
	 DW $114A	; token $A8
	 DW $110E	; token $A9
	 DW $1091	; token $AA
	 DW $2635	; token $AB
	 DW $231D	; token $AC
	 DW $1086	; token $AD
	 DW $261F	; token $AE
	 DW $2C26	; token $AF
	 DW $2508	; token $B0
	 DW $2D7D	; token $B1
	 DW $2CB2	; token $B2
	 DW $2D19	; token $B3
	 DW $2C4E	; token $B4
	 DW $2BC0	; token $B5
	 DW $24BB	; token $B6
	 DW $3076	; token $B7
	 DW $1537	; token $B8
	 DW $3091	; token $B9
	 DW $307C	; token $BA
	 DW $30B2	; token $BB
	 DW $30CD	; token $BC
	 DW $1679	; token $BD
	 DW $1692	; token $BE
	 DW $31EC	; token $BF
	 DW $31CB	; token $C0
	 DW $3201	; token $C1
	 DW $00FD	; token $C2
	 DW $0209	; token $C3
	 DW $1306	; token $C4
	 DW $32B0	; token $C5
	 DW $3358	; token $C6
	 DW $3214	; token $C7
	 DW $3206	; token $C8
	 DW $32EA	; token $C9
	 DW $0E40	; token $CA
	 DW $3405	; token $CB
	 DW $3141	; token $CC
	 DW $30E7	; token $CD
	 DW $1EF1	; token $CE
	 DW $23A9	; token $CF
	 DW $3591	; token $D0
	 DW $34A2	; token $D1
	 DW $0120	; token $D2
	 DW $35E3	; token $D3
	 DW $317B	; token $D4
	 DW $3189	; token $D5
	 DW $35B2	; token $D6
	 DW $3222	; token $D7
	 DW $35D1	; token $D8
	 DW $34CC	; token $D9
	 DW $359A	; token $DA
	 DW $32A8	; token $DB
	 DW $34BE	; token $DC
	 DW $300C	; token $DD
	 DW $346F	; token $DE
	 DW $33C1	; token $DF
	 DW $332E	; token $E0
	 DW $328A	; token $E1
	 DW $327C	; token $E2
	 DW $3377	; token $E3
	 DW $35C4	; token $E4
	 DW $21E3	; token $E5
	 DW $28AA	; token $E6
	 DW $245E	; token $E7
	 DW $22CA	; token $E8
	 DW $3520	; token $E9
	 DW $3541	; token $EA
	 DW $2495	; token $EB
	 DW $2407	; token $EC
	 DW $34A5	; token $ED
	 DW $35EF	; token $EE
	 DW $3BD9	; token $EF
	 DW $2231	; token $F0
	 DW $2F67	; token $F1
	 DW $1311	; token $F2
	 DW $1F92	; token $F3
	 DW $1F20	; token $F4
	 DW $01BF	; token $F5
	 DW $2DE3	; token $F6
	 DW $3BFC	; token $F7
	 DW $2ED6	; token $F8
	 DW $3452	; token $F9
	 DW $3C6B	; token $FA
	 DW $0394	; token $FB
	 DW $FFFF	; token $FC (unassigned)
	 DW $FFFF	; token $FD (unassigned)
	 DW $FFFF	; token $FE (unassigned)
	 DW $FFFF	; token $FF (unassigned)
; $3FEA-$3FEE: original ROM padding between table and title.
	 DB $FF,$FF,$FF,$FF,$FF
; $3FEF-$3FFF: original ROM identification and date.
SPACE_ZAP_TITLE:
	 DB "SPACE ZAP",0

SPACE_ZAP_DEVELOPER:
	 DB "DNA",0

SPACE_ZAP_ROM_DATE:
	 DB $08,$19,$80 ; 08/19/80 (MM/DD/YY, packed decimal bytes)
;
	 END
