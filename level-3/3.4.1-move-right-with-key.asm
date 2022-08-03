org #4000
run code_start

barrels_quantity        equ     19
move_animation_ticks    equ     8

move_right_key:         db      61      ;; D
current_cart_position:  dw      #C3C0
first_barrel_position:  dw      #C3EA

code_start:
ld      HL, #C410
ld      BC, #0800

ld      A, 80
draw_floor:
    call    draw_tile
    inc     HL
    dec     A
    jr      NZ,draw_floor

ld      A, barrels_quantity
ld      HL, (first_barrel_position)
draw_barrels:
    call    draw_barrel
    inc     HL
    inc     HL
    dec     A
    jr      NZ, draw_barrels

ld      HL, (current_cart_position)
call    draw_cart

input_loop:
    call    clear_sprite
    ld      A, (move_right_key)
    call    test_key
    call    NZ, move_right
    call    draw_cart
    ld      A, move_animation_ticks
    call    animation_wait
    jr      input_loop

move_right:
    ld      HL, (current_cart_position)
    inc     HL
    ld      (current_cart_position), HL
    ret

;; A - (in) number of halts to execute
animation_wait:
    halt
    dec     A
    jr      NZ, animation_wait
    ret

;; A - (in) key to test, unchanged. Z = 0 on key pressed. A corrupt after ret.
test_key:
    push    BC
    push    HL
    call    #BB1E
    pop     HL
    pop     BC
    ret

;; HL - (in) start drawing position (char boundary not checked), corrupt after ret
draw_tile:
    push    HL
    push    BC
    ld      BC, #0800
    ld      (HL), #FF
    add     HL, BC
    ld      (HL), #3C
    add     HL, BC
    ld      (HL), #C3
    add     HL, BC
    ld      (HL), #FF
    pop     BC
    pop     HL
    ret

clear_sprite:
    push    HL
    push    AF
    ld      A, 8
    clear_sprite_loop:
        ld      (HL), #00
        inc     HL
        ld      (HL), #00
        dec     HL
        ADD     HL, BC
        dec     A
        jr      NZ, clear_sprite_loop
    pop     AF
    pop     HL
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_cart:
    push    HL
    ld      (HL), #88
    inc     HL
    ld      (HL), #11

    add     HL, BC
    ld      (HL), #F1
    dec     HL
    ld      (HL), #F8

    add     HL, BC
    ld      (HL), #FE
    inc     HL
    ld      (HL), #F7

    add     HL, BC
    ld      (HL), #FF
    dec     HL
    ld      (HL), #FF

    add     HL, BC
    ld      (HL), #BB
    inc     HL
    ld      (HL), #DD

    add     HL, BC
    ld      (HL), #8A
    dec     HL
    ld      (HL), #15

    add     HL, BC
    ld      (HL), #4A
    inc     HL
    ld      (HL), #25

    add     HL, BC
    ld      (HL), #02
    dec     HL
    ld      (HL), #04

    pop     HL
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_barrel:
    push    HL
    ld      (HL), #99

    add     HL, BC
    ld      (HL), #F6

    add     HL, BC
    ld      (HL), #F9

    add     HL, BC
    ld      (HL), #FF

    add     HL, BC
    ld      (HL), #FF

    add     HL, BC
    ld      (HL), #FF

    add     HL, BC
    ld      (HL), #F6

    add     HL, BC
    ld      (HL), #60

    pop     HL
    ret