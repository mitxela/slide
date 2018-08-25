.include "m328pdef.inc"

; PD0 RXD
; PD1 TXD





ldi r16, 1<<0
out DDRB, r16




; main2:
; inc r0
  ; mov r16,r0
  ; rcall transmit
  ; rcall wait

  ; rjmp main2































  ; ldi r16, 1<<UCSZ01 | 1<<UCSZ00
  ; sts UCSR0C, r16


  ; ldi r16,0
  ; sts UBRR0L, r16
  ; ldi r16,0
  ; sts UBRR0H, r16




asdf:
  ldi ZH, HIGH(ledOn2*2)
  ldi ZL,  LOW(ledOn2*2)
  ldi r19, 7
  rcall sendData
  

  
rcall wait
rcall wait
rjmp asdf
  



  
  ldi ZH, HIGH(torqueEnable*2)
  ldi ZL,  LOW(torqueEnable*2)
  ldi r19, 7
  rcall sendData
  
  rcall USART_Receive
  rcall USART_Receive
  rcall USART_Receive
  rcall USART_Receive
  rcall USART_Receive
  rcall USART_Receive
  
  
  rcall wait
  
main:


  ldi ZH, HIGH(goalzero*2)
  ldi ZL,  LOW(goalzero*2)
  ldi r19, 8
  rcall sendData
  

  rcall wait
  rcall wait

;  rcall USART_Receive


;hang: rjmp hang

  rjmp main


sendData:
;  ldi r16,  1<<TXEN0
;  sts UCSR0B, r16

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

waitDone:
  lds r17, UCSR0A
  sbrs r17, UDRE0
  rjmp waitDone

  ; ldi r16, 1<<RXEN0 
  ; sts UCSR0B, r16
  cbi DDRB,0
  ret





data1:

;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01, 0xF6 ; setID
;.db 0xff, 0xff, 0xfe, 0x18, 0x83, 0x1e, 0x04, 0x00, 0x10, 0x00, 0x50, 0x01, 0x01, 0x20, 0x02, 0x60, 0x03, 0x02, 0x30, 0x00, 0x70, 0x01, 0x03, 0x20, 0x02, 0x80, 0x03, 0x12
;.db 0xFF, 0xFF, 0x01, 0x04, 0x02, 0x00, 0x03, 0xF5


;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01

;     FF    FF    ID   Len    Op  data  data

ledOn2:
.db 0xFF, 0xFF, 0x01, 0x04, 0x03, 0x19, 0x01


setID:
.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x02

goalzero:
.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0x00, 0x00

goalff:
.db 0xFF, 0xFF, 0x01, 0x05, 0x03, 0x1e, 0xff, 0x03



torqueEnable:
.db 0xFF, 0xFF, 0x01, 0x04, 0x03, 0x18, 0x01 ; Torque Enable 

retDelay:
.db 0xFF, 0xFF, 0x01, 0x04, 0x03, 0x05, 0x01 ; Set return delay to 1 (default 250)



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





; USART_Transmit:
 ; Wait for empty transmit buffer
  ; lds r17, UCSR0A
  ; sbrs r17, UDRE0
  ; rjmp USART_Transmit

  ; add r15,r16 ; tally for checksum
 ; Put data (r16) into buffer, sends the data
  ; sts UDR0,r16
; ret



USART_Receive:
  ; Wait for data to be received
  lds r17, UCSR0A
  sbrs r17, RXC0
  rjmp USART_Receive
  ; Get and return received data from buffer
  lds r16, UDR0
ret
