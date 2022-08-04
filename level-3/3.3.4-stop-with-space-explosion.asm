org #4000
run code_start

animation_width     equ 40
animation_ticks     equ 10
barrels_quantity    equ 19
initial_position    equ #C3C0

first_barrel_position:  dw      #C3EA

code_start:
ld      HL, #C410
ld      BC, #0800
ld      D, animation_width

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

ld      HL, initial_position
call    draw_cart

movement_delay:
    ld      A, #80
    delay_loop:
        halt
        dec     A
        jr      NZ, delay_loop

move_cart:
    ld      E, 47   ;; space
    call    test_key
    jr      NZ, reset_loop
    call    clear_sprite
    inc     HL
    call    draw_cart
    push    AF
    ld      A, animation_ticks
    call    animation_wait
    pop     AF
    dec     D
    jr      NZ, move_cart

;; If move_cart finishes executing, it means the cart reached the end
play_explosion_animation:
    call    clear_sprite    ;; HL holding cart's position
    inc     HL              ;; Second half of the cart
    call    draw_explosion  ;; Draw 8x8, 1/2 cart + barrel
    dec     HL              ;; Back to cart's position before reset

reset_loop:
    ld      E, 50    ;; R
    call    test_key
    jr      Z, reset_loop
    call    reset_animation
    jr      movement_delay  ;; space_loop will follow automatically

reset_animation:
    call    clear_sprite                ;; Clear old cart
    ld      HL, (first_barrel_position)
    call    draw_barrel
    ld      HL, initial_position
    ld      D, animation_width
    call    draw_cart
    ret

;; A - (in) number of halts to execute
animation_wait:
    halt
    dec     A
    jr      NZ, animation_wait
    ret

;; E - (in) key to test, unchanged. Z = 0 on key pressed. A corrupt after ret.
test_key:
    push    BC
    push    HL
    ld      A, E
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

;; 8x8 pixels. Blank line after each row.
draw_explosion:
    push    HL

    ld      (HL), #80
    inc     HL
    ld      (HL), #10

    add     HL, BC
    ld      (HL), #E2
    dec     HL
    ld      (HL), #74

    add     HL, BC
    ld      (HL), #72
    inc     HL
    ld      (HL), #E4

    add     HL, BC
    ld      (HL), #E8
    dec     HL
    ld      (HL), #71

    add     HL, BC
    ld      (HL), #71
    inc     HL
    ld      (HL), #E8

    add     HL, BC
    ld      (HL), #E4
    dec     HL
    ld      (HL), #72

    add     HL, BC
    ld      (HL), #74
    inc     HL
    ld      (HL), #E2

    add     HL, BC
    ld      (HL), #10
    dec     HL
    ld      (HL), #80

    pop     HL
    push    HL
    ld      A, 10
    call    animation_wait

    ld      (HL), #F8
    inc     HL
    ld      (HL), #F1

    add     HL, BC
    ld      (HL), #FB
    dec     HL
    ld      (HL), #F5

    add     HL, BC
    ld      (HL), #D1
    inc     HL
    ld      (HL), #B8

    add     HL, BC
    ld      (HL), #76
    dec     HL
    ld      (HL), #E6

    add     HL, BC
    ld      (HL), #E6
    inc     HL
    ld      (HL), #76

    add     HL, BC
    ld      (HL), #B8
    dec     HL
    ld      (HL), #D1

    add     HL, BC
    ld      (HL), #F5
    inc     HL
    ld      (HL), #FB

    add     HL, BC
    ld      (HL), #F1
    dec     HL
    ld      (HL), #F8

    pop     HL
    push    HL
    ld      A, 10
    call    animation_wait

    ld      (HL), #77
    inc     HL
    ld      (HL), #EE

    add     HL, BC
    ld      (HL), #55
    dec     HL
    ld      (HL), #AA

    add     HL, BC
    ld      (HL), #CC
    inc     HL
    ld      (HL), #33

    add     HL, BC
    ld      (HL), #11
    dec     HL
    ld      (HL), #88

    add     HL, BC
    ld      (HL), #88
    inc     HL
    ld      (HL), #11

    add     HL, BC
    ld      (HL), #33
    dec     HL
    ld      (HL), #CC

    add     HL, BC
    ld      (HL), #AA
    inc     HL
    ld      (HL), #55

    add     HL, BC
    ld      (HL), #EE
    dec     HL
    ld      (HL), #77

    pop     HL
    ld      A, 10
    call    animation_wait

    call    clear_sprite    ;; Leave blank after the explosion
    ret
