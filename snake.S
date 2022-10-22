.define snake_head $0300
.define snake_length $01
.define snake_speed $04
.define snake_counter $05

.define apple_location $03
.define apple_seed $06

.define current_direction $02

;$0300 to $03FF is reserved to snake body

.org $8000
start:
; init
    JSR clear_screen
    LDX #$FF
    TXS
    LDA #$78
    STA snake_head
    STA apple_seed
    LDA #$20
    STA snake_speed
    STA snake_counter
    LDA #$28
    STA apple_location
    LDA #$00
    STA snake_length
    LDA #$00
    STA current_direction

game:
    JMP game

nmi:
    ;read movement
        LDA $4000
        CMP #$00
        BEQ no_dir
            STA current_direction
        no_dir:
    DEC snake_counter
    LDA snake_counter
    CMP #$00
    BEQ reset_counter
    RTI

reset_counter:
    LDA snake_speed
    STA snake_counter
    LDX snake_head
    JSR move

    ; get_apple
    JSR get_apple

    ; draw
    LDA #$0F
    LDX #$00
    draw_tail_loop:
        LDY snake_head, X
        STA $0200, Y
        CPX snake_length
        INX
        BCC draw_tail_loop
        BEQ draw_tail_loop

    ; draw_apple
    LDA #$01
    LDX apple_location
    STA $0200, X
    RTI

move:
    ; move tail, but first check length
    JSR clear_pixel
    LDA snake_length
    CMP #$00
    BEQ no_tail
        LDX snake_length
        LDY snake_length
        tail_loop:
            DEX
            LDA snake_head, X
            STA snake_head, Y
            DEY
            CPX #$00
            BNE tail_loop
    no_tail:
    
    LDA current_direction
    CMP #$00
        BEQ stay
            CMP #$01
            BNE up
            LDA snake_head
            SBC #$10
            STA snake_head
        up:
        LDA current_direction
        ; go down
            CMP #$02
            BNE down
            LDA snake_head
            ADC #$0F
            STA snake_head
        down:
        LDA current_direction
        ; go left
            CMP #$04
            BNE left
            LDA snake_head
            SBC #$01
            STA snake_head
        left:
        LDA current_direction
        ; go right
            CMP #$08
            BNE right
            LDA snake_head
            ADC #$00
            STA snake_head
        right:
    stay:
    RTS

clear_screen:
    loop:
        LDA #$00
        STA $0200, X
        INX
        BNE loop
    RTS

clear_pixel:
    LDA #$00
    LDX #$00
    clear_tail_loop:
        LDY snake_head, X
        STA $0200, Y
        CPX snake_length
        INX
        BCC clear_tail_loop
        BEQ clear_tail_loop
    RTS

get_apple:
    LDA snake_head
    CMP apple_location
    BNE no_apple
    INC snake_length
    ; spawn new apple
    ; not random yet, needs a lot of fixing
    LDA snake_head
    STA apple_seed
    LDA apple_location
    ADC apple_seed
    STA apple_location
    DEC snake_speed
no_apple:
RTS

.goto $FFFA
.dw nmi ; not maskable
.dw start ; reset
.dw start ; interrupt
