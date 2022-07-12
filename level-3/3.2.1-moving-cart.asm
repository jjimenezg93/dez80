org #4000
run code_start

animation_length equ 40

code_start:
ld      HL, #C410
ld      BC, #0800
ld      D, animation_length

ld      A, 80
draw_floor:
    call    draw_tile
    inc     HL
    dec     A
    jr      NZ,draw_floor

ld      IX, #C3C0
push    IX
pop     HL
ld      A, 1 ;; must move (change during runtime to stop)
main_loop:
    and     A
    jr      NZ, must_move
    jr      must_not_move
    must_move:
        call    clear_sprite
        dec     D
        jr      Z, reset_hl
        inc     HL
        jr      loop_draw
        reset_hl:
            ld      D, animation_length
            push    IX
            pop     HL

    loop_draw:
        call    draw_cart

    must_not_move: ;; No need to redraw if not moving
        push    AF
        ld      A, 10
        animation_wait:
            halt
            dec     A
            jr      NZ, animation_wait
        pop     AF
    jr      main_loop

jr      $

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

;; HL - (in) start drawing position (char boundary not checked), corrupt after ret
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
