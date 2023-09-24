;PROMTP ChatGPT 3.5
;create a programa in 6502 assembler for the Commodore 64 that draws 
;in the screen the word OSOLABS 5 fives, in 5 the colours red, blue, green, yellow, black


;the program vas wrong lda (color_addr),x is not supported in old style please fix it
;ChatGPT
;I apologize for the oversight. You're right; the old-style addressing mode doesn't support 
;indexed addressing with indirect addressing like LDA (COLOR_ADDR),X. 
;To work around this limitation, you can use the following modified code:
; Variables
CHAR_ADDR   = $0400      ; Start address of character ROM
SCREEN_ADDR = $0400      ; Screen memory address
COLOR_ADDR  = $D800      ; Color memory address
ROW         = 10         ; Row where the text will be displayed
DELAY       = 5000      ; Delay for color change

; Character set data for "OSOLABS"
CHARS       .word $0000  ; Address of the character string
CHARS_STR   .byte "OSOLABS", $00 ; Actual character string

; Color values
RED         = $02
BLUE        = $08
GREEN       = $04
YELLOW      = $0E
BLACK       = $00

; Delay variables
DELAY_LOW   .byte 0
DELAY_HIGH  .byte 0

; Initialization code
        LDX #0            ; Initialize X register (for color loop)

; Main loop
LOOP:
        LDY #0            ; Initialize Y register (for character loop)

        ; Display "OSOLABS" at the specified row
CHAR_LOOP:
        LDA (CHARS),Y     ; Load the character from the string
        BEQ NEXT_COLOR    ; Branch to change color if null terminator
        STA SCREEN_ADDR,Y ; Display the character on the screen (fixed)
        LDA CHAR_ADDR,X   ; Load the character's corresponding character data
        STA CHAR_ADDR+1,X ; Store it in the character ROM
        INY               ; Increment Y for the next character
        INX               ; Increment X for the next color
        JMP CHAR_LOOP     ; Repeat for the next character

; Change color
NEXT_COLOR:
        LDA #$18           ; Load the color code offset from COLOR_ADDR
        CLC                ; Clear carry flag
        ADC X              ; Add the color offset to X
        TAX                ; Transfer the result to X
        LDA RED_ARRAY,X    ; Load the color code from the color array (fixed)
        STA COLOR_ADDR,Y   ; Store the new color value directly (fixed)
        JMP DELAY_LOOP

; Define the color array
RED_ARRAY:   .byte RED, BLUE, GREEN, YELLOW, BLACK

; Delay loop
DELAY_LOOP:
        LDX #0
DELAY_LOOP_INNER:
        LDA $D012          ; Read the VIC-II raster line register
        CMP X              ; Compare with the desired delay
        BNE DELAY_LOOP_INNER ; If not equal, continue waiting
        INX
        CPX DELAY_LOW      ; Compare with the low byte of DELAY
        BCC DELAY_LOOP_INNER ; If not reached the desired delay, continue
        CPX DELAY_HIGH     ; Compare with the high byte of DELAY
        BCC DELAY_LOOP_INNER ; If not reached the desired delay, continue
        JMP LOOP            ; Go back to the main loop

; Initialize and run the program
        .org $0801
        .word START
        .byte $0e, $08, $0c, $0c, $12, $34, $30, $32, $37, $00, $00
START:
        SEI
        CLD
        LDA $FF00
        STA $DD00
        LDA $FF01
        STA $DD01
        LDA $FF0D
        STA $DD0D
        LDA $FF0E
        STA $DD0E
        LDA $FF0F
        STA $DD0F
        LDA $DD0E
        ORA #$80
        STA $DD0E
        CLI
        LDA #$00
        STA $D020
        STA $D021
        LDX #$FF
        TXS

        ; Split the 16-bit DELAY into low and high bytes
        LDA #<DELAY
        STA DELAY_LOW
        LDA #>DELAY
        STA DELAY_HIGH

        JSR LOOP

        RTS
