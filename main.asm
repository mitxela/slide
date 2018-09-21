.include "m328pdef.inc"


; PD0 RXD midi

; PB0 TX/RX ax-12

; valve servo PB2
; motor control PD6


.def rStatus = r20
.def rBend   = r21


; timer for servo pwm signal
  ldi r16, 1<<2
  out DDRB, r16
  ldi r16, 1<<COM1B1 | 1<<WGM11 | 1<<WGM10
  sts TCCR1A, r16
  ldi r16, 1<<WGM13 | 1<<CS11
  sts TCCR1B, r16

  ldi r16,$50
  sts OCR1AH, r16
  ldi r16,$00
  sts OCR1AL, r16

  ldi r16,$02
  sts OCR1BH, r16
  ldi r16,$ff
  sts OCR1BL, r16

;timer for motor control pwm
  ldi r16, 1<<6
  out DDRD, r16
  ldi r16, 1<<COM0A1 | 1<<WGM00
  out TCCR0A, r16
  ldi r16, 1<<CS00
  out TCCR0B, r16

  ldi r16, 1
  out OCR0A, r16


; uart
  ldi r16, 1<<UCSZ01 | 1<<UCSZ00
  sts UCSR0C, r16
  ldi r16, 1<<RXEN0
  sts UCSR0B, r16


  ldi r16,31 ;31250bps
  sts UBRR0L, r16
  ldi r16,0
  sts UBRR0H, r16




initServos:
  ldi ZH, HIGH(torqueEnable*2)
  ldi ZL,  LOW(torqueEnable*2)
  ldi r19, 7
  rcall sendData

  rcall wait

  ldi rBend, 64
  ldi YH,1
  ldi YL,0



  
main:

  rcall receiveByte

  cpi rStatus, 0x90
  breq noteOn
  cpi rStatus, 0x80
  breq noteOff
  cpi rStatus, 0xE0
  breq pitchBend

rjmp main


noteOn:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte

  cpi r16,0
	breq noteoffb

  st Y+, r17


    ldi r16,40
    out OCR0A, r16

  rcall setNote


  rjmp main

noteOff:
  sbrc r16,7
  rcall receiveByte
  mov r17, r16
  rcall receiveByte
noteoffb:

movw X,Y


noteOffLook:
  ld r19,-Y
  cp r17,r19
  brne noteOffLook

noteOffMove:
  ldd r16,Y+1
  st Y+,r16
  cp YL,XL
  cpc YH,XH
  brne noteOffMove


sbiw Y,1


  cpi YL,0
  breq changeNote



    ldi r16,0
    out OCR0A, r16

changeNote:

  ld r17,-Y
  adiw Y,1
  rcall setNote


  rjmp main




pitchBend:
  sbrc r16,7
  rcall receiveByte

  rcall receiveByte
  mov rBend, r16

  ld r17,-Y
  adiw Y,1
  rcall setNote



  rjmp main







setNote:
  cpi r17,89
  brcc outOfRange
  subi r17,69
  brcs outOfRange

  ldi ZH, high(lookupTable*2)
  ldi ZL,  low(lookupTable*2)
  clr r16
  lsl r17

  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16
  rol r17
  rol r16

  add ZL, r17
  adc ZH, r16

  clr r16
  add ZL, rBend
  adc ZH, r16
  add ZL, rBend
  adc ZH, r16

  lpm r16, Z+
  out OCR0A, r16


  clr XH
  lpm XL, Z+
  ldi r16, 0x02
  ldi r17, 0x30

  add XL, r17
  adc XH, r16

  rcall setPosition

  ret

outOfRange:
    ldi r16,0
    out OCR0A, r16
  ret










  ; rcall USART_Receive
  ; mov ZH, r16
  ; rcall USART_Receive
  ; mov ZL, r16
  ; rcall setPosition


  ; rcall wait



;hang: rjmp hang

  rjmp main

; servo:
  ; rcall USART_Receive
  ; sts OCR1BH, r16
  ; rcall USART_Receive
  ; sts OCR1BL, r16

  ; rjmp main

; motor:
  ; rcall USART_Receive
  ; out OCR0A, r16
  ; rjmp main



sendData:
  sbi DDRB,0 ; TX EN

  clr r15
  loop1:
    lpm r16,Z+
    rcall transmit
    dec r19
    brne loop1

  ; checksum
  ldi r16, 253
  sub r16, r15
  rcall transmit

  cbi DDRB,0
  ret


setPosition:
  sbi DDRB,0 ; TX EN
  clr r15

  ldi r16,0xFF
  rcall transmit
  ldi r16,0xFF
  rcall transmit
  ldi r16,0xFE
  rcall transmit
  ldi r16,0x0A ;length
  rcall transmit
  ldi r16,0x83 ;instruction sync write
  rcall transmit
  ldi r16,0x1E ;param 1
  rcall transmit
  ldi r16,0x02 ;length of data
  rcall transmit
  ldi r16,0x01 ;data 1
  rcall transmit
  mov r16,XL 
  rcall transmit
  mov r16,XH
  rcall transmit
  ldi r16,0x02 ;data 2
  rcall transmit
  ldi r19, $03
  ldi r16, $ff
  sub r16, XL
  sbc r19, XH
  rcall transmit
  mov r16,r19
  rcall transmit


  ;checksum
  ldi r16, 253
  sub r16, r15
  rcall transmit
ret


data1:

;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01, 0xF6 ; setID
;.db 0xff, 0xff, 0xfe, 0x18, 0x83, 0x1e, 0x04, 0x00, 0x10, 0x00, 0x50, 0x01, 0x01, 0x20, 0x02, 0x60, 0x03, 0x02, 0x30, 0x00, 0x70, 0x01, 0x03, 0x20, 0x02, 0x80, 0x03, 0x12
;.db 0xFF, 0xFF, 0x01, 0x04, 0x02, 0x00, 0x03, 0xF5


;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01

;     FF    FF    ID   Len    Op  data  data

;ledOn2:
;.db 0xFF, 0xFF, 0x01, 0x04, 0x03, 0x19, 0x01


;setID:
;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x02

;goalzero:
;.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0x00, 0x00

;goalff:
;.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0xff, 0x03



torqueEnable:
.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x18, 0x01

;retDelay:
;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x05, 0x01 ; Set return delay to 1 (default 250)



crash:
  ldi r16,0xff
  out DDRB,r16
crash1:
  com r16
  out PORTB,r16
  rjmp crash1
  



wait:
  ldi XH,50
  ldi XL,0
wait1:
  sbiw X,1
  brne wait1
  ret





transmit:
; 16Mhz, 1Mbaud - each bit is 16 cycles

  add r15,r16 ; tally for checksum
  ldi r18,10

  ldi r17,0
  out PORTB, r17
  rjmp PC+1
  nop
transmitloop:
  rjmp PC+1
  rjmp PC+1
  rjmp PC+1
  rjmp PC+1
  mov r17,r16
  sec
  ror r16
  andi r17,1
  out PORTB,r17
  dec r18
  brne transmitloop

ret




receiveByte:
  lds r16, UCSR0A
  sbrs r16, RXC0
  rjmp receiveByte
  lds r16, UDR0

  sbrc r16,7
  mov rStatus,r16

ret







lookupTable:
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $00
.db $30, $02
.db $30, $02
.db $30, $03
.db $30, $03
.db $30, $03
.db $31, $04
.db $31, $05
.db $31, $06
.db $31, $06
.db $31, $06
.db $31, $06
.db $32, $07
.db $32, $07
.db $32, $07
.db $32, $07
.db $32, $08
.db $32, $08
.db $32, $08
.db $32, $09
.db $32, $09
.db $32, $09
.db $32, $09
.db $32, $0a
.db $32, $0a
.db $33, $0b
.db $33, $0b
.db $33, $0c
.db $33, $0c
.db $33, $0d
.db $33, $0d
.db $33, $0d
.db $33, $0d
.db $33, $0d
.db $34, $0e
.db $34, $0e
.db $34, $0f
.db $34, $0f
.db $34, $10
.db $34, $10
.db $34, $11
.db $34, $11
.db $34, $11
.db $34, $11
.db $35, $12
.db $35, $12
.db $35, $13
.db $35, $13
.db $35, $13
.db $35, $14
.db $35, $14
.db $35, $14
.db $36, $15
.db $36, $15
.db $36, $15
.db $36, $15
.db $36, $16
.db $36, $16
.db $36, $16
.db $36, $17
.db $36, $17
.db $36, $17
.db $36, $18
.db $36, $18
.db $36, $18
.db $37, $19
.db $37, $19
.db $37, $19
.db $37, $1a
.db $37, $1a
.db $37, $1b
.db $37, $1b
.db $37, $1b
.db $37, $1b
.db $38, $1c
.db $38, $1c
.db $38, $1c
.db $38, $1d
.db $38, $1e
.db $38, $1e
.db $38, $1e
.db $38, $1f
.db $38, $1f
.db $38, $1f
.db $38, $1f
.db $39, $20
.db $39, $20
.db $39, $20
.db $39, $21
.db $39, $21
.db $39, $21
.db $39, $22
.db $39, $22
.db $39, $22
.db $3a, $23
.db $3a, $23
.db $3a, $24
.db $3a, $24
.db $3a, $24
.db $3a, $24
.db $3a, $25
.db $3a, $25
.db $3a, $26
.db $3a, $26
.db $3a, $26
.db $3b, $27
.db $3b, $27
.db $3b, $27
.db $3b, $27
.db $3b, $28
.db $3b, $28
.db $3b, $28
.db $3b, $29
.db $3b, $29
.db $3b, $29
.db $3c, $2a
.db $3c, $2a
.db $3c, $2b
.db $3c, $2b
.db $3c, $2c
.db $3c, $2c
.db $3c, $2c
.db $3c, $2d
.db $3c, $2d
.db $3c, $2d
.db $3c, $2d
.db $3d, $2e
.db $3d, $2e
.db $3d, $2f
.db $3d, $2f
.db $3d, $2f
.db $3d, $2f
.db $3d, $30
.db $3d, $30
.db $3d, $30
.db $3d, $30
.db $3e, $31
.db $3e, $31
.db $3e, $32
.db $3e, $32
.db $3e, $32
.db $3e, $33
.db $3e, $33
.db $3e, $33
.db $3e, $34
.db $3e, $34
.db $3e, $34
.db $3f, $35
.db $3f, $35
.db $3f, $35
.db $3f, $36
.db $3f, $36
.db $3f, $36
.db $3f, $37
.db $3f, $37
.db $40, $38
.db $40, $38
.db $40, $39
.db $40, $39
.db $40, $3a
.db $40, $3a
.db $40, $3a
.db $40, $3b
.db $40, $3b
.db $40, $3b
.db $40, $3b
.db $41, $3c
.db $41, $3c
.db $41, $3c
.db $41, $3d
.db $41, $3d
.db $41, $3e
.db $41, $3e
.db $41, $3e
.db $42, $3f
.db $42, $3f
.db $42, $3f
.db $42, $3f
.db $42, $40
.db $42, $40
.db $42, $40
.db $42, $41
.db $42, $41
.db $42, $42
.db $42, $42
.db $42, $42
.db $43, $43
.db $43, $43
.db $43, $43
.db $43, $44
.db $43, $44
.db $43, $45
.db $43, $45
.db $43, $45
.db $43, $45
.db $44, $46
.db $44, $46
.db $44, $46
.db $44, $47
.db $44, $47
.db $44, $47
.db $44, $48
.db $44, $48
.db $44, $48
.db $44, $49
.db $44, $49
.db $44, $49
.db $45, $4a
.db $45, $4a
.db $45, $4b
.db $45, $4b
.db $45, $4b
.db $45, $4b
.db $45, $4c
.db $45, $4c
.db $45, $4c
.db $46, $4d
.db $46, $4d
.db $46, $4d
.db $46, $4d
.db $46, $4e
.db $46, $4e
.db $46, $4f
.db $46, $4f
.db $46, $4f
.db $46, $50
.db $46, $50
.db $46, $50
.db $46, $50
.db $47, $51
.db $47, $51
.db $47, $51
.db $47, $51
.db $47, $52
.db $47, $52
.db $47, $52
.db $47, $53
.db $47, $53
.db $47, $53
.db $48, $54
.db $48, $54
.db $48, $54
.db $48, $54
.db $48, $55
.db $48, $55
.db $48, $55
.db $48, $56
.db $48, $56
.db $48, $56
.db $48, $57
.db $48, $57
.db $48, $57
.db $48, $57
.db $49, $58
.db $49, $58
.db $49, $58
.db $49, $58
.db $49, $59
.db $49, $59
.db $49, $5a
.db $49, $5a
.db $49, $5a
.db $4a, $5b
.db $4a, $5b
.db $4a, $5c
.db $4a, $5c
.db $4a, $5c
.db $4a, $5c
.db $4a, $5d
.db $4a, $5d
.db $4a, $5e
.db $4a, $5e
.db $4a, $5e
.db $4b, $5f
.db $4b, $5f
.db $4b, $5f
.db $4b, $5f
.db $4b, $60
.db $4b, $60
.db $4b, $60
.db $4b, $60
.db $4b, $61
.db $4b, $61
.db $4b, $61
.db $4c, $62
.db $4c, $62
.db $4c, $62
.db $4c, $62
.db $4c, $63
.db $4c, $63
.db $4c, $63
.db $4c, $65
.db $4c, $64
.db $4c, $64
.db $4d, $66
.db $4d, $66
.db $4d, $66
.db $4d, $66
.db $4d, $67
.db $4d, $67
.db $4d, $67
.db $4d, $68
.db $4d, $68
.db $4d, $68
.db $4e, $69
.db $4e, $69
.db $4e, $69
.db $4e, $69
.db $4e, $6a
.db $4e, $6a
.db $4e, $6a
.db $4e, $6b
.db $4e, $6b
.db $4e, $6b
.db $4e, $6c
.db $4e, $6c
.db $4e, $6c
.db $4e, $6c
.db $4f, $6d
.db $4f, $6d
.db $4f, $6e
.db $4f, $6e
.db $4f, $6e
.db $4f, $6f
.db $4f, $6f
.db $4f, $6f
.db $50, $70
.db $50, $70
.db $50, $70
.db $50, $71
.db $50, $71
.db $50, $71
.db $50, $72
.db $50, $72
.db $50, $72
.db $50, $73
.db $50, $73
.db $50, $73
.db $50, $73
.db $50, $73
.db $51, $74
.db $51, $74
.db $51, $74
.db $51, $74
.db $51, $75
.db $51, $75
.db $51, $75
.db $51, $75
.db $51, $76
.db $51, $76
.db $52, $77
.db $52, $77
.db $52, $77
.db $52, $78
.db $52, $78
.db $52, $78
.db $52, $78
.db $52, $79
.db $52, $79
.db $52, $79
.db $52, $79
.db $52, $7a
.db $52, $7a
.db $53, $7b
.db $53, $7b
.db $53, $7b
.db $53, $7c
.db $53, $7c
.db $53, $7c
.db $53, $7d
.db $53, $7d
.db $53, $7d
.db $53, $7d
.db $54, $7e
.db $54, $7e
.db $54, $7e
.db $54, $7f
.db $54, $7f
.db $54, $7f
.db $54, $7f
.db $54, $80
.db $54, $80
.db $54, $81
.db $54, $81
.db $54, $81
.db $55, $82
.db $55, $82
.db $55, $82
.db $55, $82
.db $55, $83
.db $55, $83
.db $55, $83
.db $55, $84
.db $55, $84
.db $55, $84
.db $55, $84
.db $56, $85
.db $56, $85
.db $56, $85
.db $56, $85
.db $56, $86
.db $56, $86
.db $56, $87
.db $56, $87
.db $56, $87
.db $56, $88
.db $56, $88
.db $56, $88
.db $56, $88
.db $57, $89
.db $57, $89
.db $57, $89
.db $57, $8a
.db $57, $8a
.db $57, $8a
.db $57, $8a
.db $57, $8b
.db $57, $8b
.db $57, $8b
.db $58, $8c
.db $58, $8c
.db $58, $8c
.db $58, $8d
.db $58, $8d
.db $58, $8d
.db $58, $8e
.db $58, $8e
.db $58, $8e
.db $58, $8e
.db $58, $8f
.db $58, $8f
.db $58, $8f
.db $59, $90
.db $59, $90
.db $59, $91
.db $59, $91
.db $59, $91
.db $59, $92
.db $59, $92
.db $59, $92
.db $5a, $93
.db $5a, $93
.db $5a, $93
.db $5a, $94
.db $5a, $94
.db $5a, $94
.db $5a, $95
.db $5a, $95
.db $5a, $95
.db $5a, $96
.db $5a, $96
.db $5a, $96
.db $5b, $97
.db $5b, $97
.db $5b, $97
.db $5b, $98
.db $5b, $98
.db $5b, $98
.db $5b, $98
.db $5b, $99
.db $5b, $99
.db $5b, $99
.db $5c, $9a
.db $5c, $9a
.db $5c, $9a
.db $5c, $9a
.db $5c, $9c
.db $5c, $9b
.db $5c, $9d
.db $5c, $9d
.db $5c, $9d
.db $5c, $9d
.db $5d, $9e
.db $5d, $9e
.db $5d, $9e
.db $5d, $9f
.db $5d, $9f
.db $5d, $9f
.db $5d, $a0
.db $5d, $a0
.db $5d, $a0
.db $5e, $a1
.db $5e, $a1
.db $5e, $a1
.db $5e, $a1
.db $5e, $a2
.db $5e, $a2
.db $5e, $a2
.db $5e, $a3
.db $5e, $a3
.db $5e, $a3
.db $5e, $a4
.db $5e, $a4
.db $5e, $a4
.db $5e, $a4
.db $5f, $a5
.db $5f, $a5
.db $5f, $a5
.db $5f, $a6
.db $5f, $a7
.db $5f, $a7
.db $60, $a8
.db $60, $a8
.db $60, $a8
.db $60, $a9
.db $60, $a9
.db $60, $a9
.db $60, $a9
.db $60, $aa
.db $60, $aa
.db $60, $aa
.db $60, $ab
.db $60, $ab
.db $60, $ab
.db $61, $ac
.db $61, $ac
.db $61, $ac
.db $61, $ad
.db $61, $ad
.db $61, $ae
.db $61, $ae
.db $61, $ae
.db $61, $ae
.db $62, $af
.db $62, $af
.db $62, $af
.db $62, $b0
.db $62, $b0
.db $62, $b1
.db $62, $b2
.db $62, $b2
.db $62, $b2
.db $63, $b3
.db $63, $b3
.db $63, $b3
.db $63, $b4
.db $63, $b4
.db $63, $b5
.db $63, $b5
.db $63, $b5
.db $64, $b6
.db $64, $b6
.db $64, $b6
.db $64, $b7
.db $64, $b7
.db $64, $b7
.db $64, $b8
.db $64, $b8
.db $64, $b8
.db $64, $b9
.db $64, $b9
.db $64, $b9
.db $65, $ba
.db $65, $ba
.db $65, $ba
.db $65, $bb
.db $65, $bb
.db $65, $bc
.db $66, $bd
.db $66, $bd
.db $66, $be
.db $66, $be
.db $66, $be
.db $66, $bf
.db $66, $bf
.db $66, $bf
.db $66, $c0
.db $66, $c0
.db $67, $c1
.db $67, $c1
.db $67, $c1
.db $67, $c2
.db $67, $c2
.db $67, $c2
.db $67, $c3
.db $67, $c3
.db $68, $c4
.db $68, $c4
.db $68, $c4
.db $68, $c5
.db $68, $c5
.db $68, $c6
.db $68, $c7
.db $68, $c7
.db $69, $c8
.db $69, $c8
.db $69, $c9
.db $69, $c9
.db $69, $ca
.db $69, $ca
.db $6a, $cb
.db $6a, $cb
.db $6a, $cb
.db $6a, $cc
.db $6a, $cc
.db $6a, $cd
.db $6a, $cd
.db $6a, $ce
.db $6a, $ce
.db $6b, $cf
.db $6b, $cf
.db $6b, $d0
.db $6b, $d0
.db $6b, $d1
.db $6b, $d1
.db $6c, $d2
.db $6c, $d3
.db $6c, $d4
.db $6c, $d4
.db $6c, $d5
.db $6c, $d5
.db $6d, $d6
.db $6d, $d7
.db $6d, $d8
.db $6e, $d9
.db $6e, $d9
.db $6e, $da
.db $6e, $da
.db $6e, $dc
.db $6f, $dd
.db $6f, $de
.db $6f, $df
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0
.db $70, $e0

