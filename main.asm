.include "m328pdef.inc"

; PD0 RXD
; PD1 TXD



  ldi r16, 1<<UCSZ01 | 1<<UCSZ00
  sts UCSR0C, r16


  ldi r16,0
  sts UBRR0L, r16
  ldi r16,0
  sts UBRR0H, r16






  

main:
  
  ldi r16,  1<<TXEN0
  sts UCSR0B, r16


  clr r15
  ; ldi ZH, HIGH(data1*2)
  ; ldi ZL,  LOW(data1*2)
  ; ldi r18, 5

 inc r0

  ldi r16,$FF
  rcall USART_Transmit
  ldi r16,$FF
  rcall USART_Transmit
  mov r16,r0
  rcall USART_Transmit
  ldi r16,$02
  rcall USART_Transmit
  ldi r16,$01
  rcall USART_Transmit


  
  
  ; loop1:
    ; lpm r16,Z+
    ; rcall USART_Transmit
    ; dec r18
    ; brne loop1

  ; checksum
  ldi r16, 253
  sub r16, r15
  rcall USART_Transmit

waitDone:
  lds r17, UCSR0A
  sbrs r17, UDRE0
  rjmp waitDone

  ldi r16, 1<<RXEN0 
  sts UCSR0B, r16

  rcall wait


;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive
;  rcall USART_Receive


;hang: rjmp hang

  rjmp main


data1:

;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01, 0xF6 ; setID
;.db 0xff, 0xff, 0xfe, 0x18, 0x83, 0x1e, 0x04, 0x00, 0x10, 0x00, 0x50, 0x01, 0x01, 0x20, 0x02, 0x60, 0x03, 0x02, 0x30, 0x00, 0x70, 0x01, 0x03, 0x20, 0x02, 0x80, 0x03, 0x12
;.db 0xFF, 0xFF, 0x01, 0x04, 0x02, 0x00, 0x03, 0xF5


;.db 0xFF, 0xFF, 0xFE, 0x04, 0x03, 0x03, 0x01

.db 0xFF, 0xFF, 0xFE, 0x02, 0x01



crash:
  ldi r16,0xff
  out DDRB,r16
crash1:
  com r16
  out PORTB,r16
  rjmp crash1
  



wait:
  ldi XH,250
  ldi XL,0
wait1:
  sbiw X,1
  brne wait1
  ret




USART_Transmit:
  ; Wait for empty transmit buffer
  lds r17, UCSR0A
  sbrs r17, UDRE0
  rjmp USART_Transmit

  add r15,r16 ; tally for checksum
  ; Put data (r16) into buffer, sends the data
  sts UDR0,r16
  ret



USART_Receive:
  ; Wait for data to be received
  lds r17, UCSR0A
  sbrs r17, RXC0
  rjmp USART_Receive
  ; Get and return received data from buffer
  lds r16, UDR0
  ret
