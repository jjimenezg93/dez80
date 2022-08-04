org #4000
run code_start

move_animation_ticks    equ     3
animation_ticks         equ     5
left_wall_position      equ     #C3C0
right_wall_position     equ     left_wall_position + #50
next_pixel_offset_v     equ     #0800

is_game_over:           db      0
move_left_key:          db      69      ;; A
move_right_key:         db      61      ;; D
current_cart_position:  dw      #C3E8   ;; Screen center
left_barrel_position:   dw      #C3C8
right_barrel_position:  dw      #C3FC

code_start:
ld      HL, right_wall_position
ld      A, 80
draw_floor:
    call    draw_tile
    inc     HL
    dec     A
    jr      NZ,draw_floor

ld      HL, (left_barrel_position)
call    draw_barrel
ld      HL, (right_barrel_position)
call    draw_barrel

ld      HL, (current_cart_position)
call    draw_cart

main_loop:
    call    clear_sprite
    call    handle_input
    call    handle_collision
    ld      A, (is_game_over)
    and     A
    jr      NZ, game_over
    call    draw_cart
    ld      A, move_animation_ticks
    call    animation_wait
    jr      main_loop

game_over:
    jr $

handle_input:
    ld      A, (move_right_key)
    call    test_key
    call    NZ, move_right
    ld      A, (move_left_key)
    call    test_key
    call    NZ, move_left
    ret

move_left:
    push    BC
    ld      BC, left_wall_position + 1
    ld      HL, (current_cart_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      C, move_left_end
    ;; HL > left wall
    dec     HL
    ld      (current_cart_position), HL
    move_left_end:
        pop     BC
        ret

move_right:
    push    BC
    ld      BC, right_wall_position - 2
    ld      HL, (current_cart_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      NC, move_right_end
    ;; HL < right wall
    inc     HL
    ld      (current_cart_position), HL
    move_right_end:
        pop     BC
        ret

handle_collision:
    call    handle_collision_left_barrel
    call    handle_collision_right_barrel
    ret

handle_collision_left_barrel:
    push    HL
    ld      HL, (left_barrel_position)
    ld      BC, (current_cart_position)
    dec     BC
    dec     BC
    call    reset_carry_flag
    sbc     HL, BC
    ld      HL, (left_barrel_position)
    call    NC, play_explosion_animation
    pop    HL
    ret

handle_collision_right_barrel:
    push    HL
    ld      HL, (current_cart_position)
    inc     HL
    ld      BC, (right_barrel_position)
    call    reset_carry_flag
    sbc     HL, BC
    ld      HL, (right_barrel_position)
    call    NC, play_explosion_animation
    pop     HL
    ret

;; HL - (in) draw position
play_explosion_animation:
    call    clear_sprite
    call    draw_explosion  ;; Draw 8x8, 1/2 cart + barrel
    ld      A, 1
    ld      (is_game_over), A
    ret

reset_carry_flag:
    SCF ;; CY  <- 1
    CCF ;; CY  <- 0
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
    ld      BC, next_pixel_offset_v
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
    ld      BC, next_pixel_offset_v
    ld      A, 8
    clear_sprite_loop:
        ld      (HL), #00
        inc     HL
        ld      (HL), #00
        dec     HL
        add     HL, BC
        dec     A
        jr      NZ, clear_sprite_loop
    pop     AF
    pop     HL
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_cart:
    push    HL
    ld      BC, next_pixel_offset_v
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
    ld      BC, next_pixel_offset_v

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
    ld      BC, next_pixel_offset_v

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
    ld      A, animation_ticks
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
    ld      A, animation_ticks
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
    ld      A, animation_ticks
    call    animation_wait

    call    clear_sprite    ;; Leave blank after the explotion
    ret
