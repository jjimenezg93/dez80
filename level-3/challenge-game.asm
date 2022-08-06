org #4000
run code_start

move_animation_ticks            equ     3
animation_ticks                 equ     5
left_wall_position              equ     #C3C0
right_wall_position             equ     left_wall_position + #50
next_pixel_offset_v             equ     #0800

is_game_over:                   db      1
reset_game_key:                 db      50      ;; R
move_left_key:                  db      69      ;; A
move_right_key:                 db      61      ;; D
hit_key:                        db      47      ;; Space
barrels_array:                  dw      #C3C8, #C3CC, #C3FC, #C400
barrels_active:                 dw      1, 1, 1, 1
current_character_position:     dw      #C3E8   ;; Screen center
current_barrel_idx:             db      0

code_start:
ld      HL, right_wall_position
ld      A, 80
draw_floor:
    call    draw_tile
    inc     HL
    dec     A
    jr      NZ, draw_floor

ld      A, 4
call    reset_current_barrel_idx
draw_barrels:
    call    get_current_barrel_ptr
    call    draw_barrel
    call    inc_current_barrel_idx
    dec     A
    jr      NZ, draw_barrels

ld      HL, (current_character_position)
call    draw_character
jr $
main_loop:
    call    clear_sprite
    call    handle_input
    call    handle_collisions
    ld      A, (is_game_over)
    and     A
    jr      NZ, game_over
    call    draw_character
    ld      A, move_animation_ticks
    call    animation_wait
    jr      main_loop

game_over:
    ld      A, (reset_game_key)
    call    test_key
    jr      NZ, reset_game
    jr      game_over

reset_game:
    push    HL
    ld      A, 4
    ld      HL, barrels_active
    reset_barrels_loop:
        ld      (HL), 1
        inc     HL
        dec     A
        jr      NZ, reset_barrels_loop
    
    pop     HL
    jr      code_start

handle_input:
    push    AF

    ld      A, (move_right_key)
    call    test_key
    call    NZ, move_right
    ld      A, (move_left_key)
    call    test_key
    call    NZ, move_left

    pop     AF
    ret

move_left:
    push    HL
    push    BC

    ld      BC, left_wall_position + 1
    ld      HL, (current_character_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      C, move_left_end
    ;; HL > left wall
    dec     HL
    ld      (current_character_position), HL

    move_left_end:
        pop     BC
        pop     HL
        ret

move_right:
    push    HL
    push    BC

    ld      BC, right_wall_position - 2
    ld      HL, (current_character_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      NC, move_right_end
    ;; HL < right wall
    inc     HL
    ld      (current_character_position), HL

    move_right_end:
        pop     BC
        pop     HL
        ret

handle_collisions:
    push    DE
    ld      D, 4
    call    reset_current_barrel_idx
    handle_barrel_collisions_loop:
        call    is_current_barrel_active
        and     A
        jr      Z, skip_inactive_barrel
        call    handle_barrel_collision
        skip_inactive_barrel:
            call    inc_current_barrel_idx
            dec     D
            jr      NZ, handle_barrel_collisions_loop

    pop     DE
    ret

; Returns the address of the current barrel in HL
get_current_barrel_ptr:
    push    AF
    ld      A, (current_barrel_idx)
    inc     A
    ld      HL, barrels_array - 1 ;; -1 compensates first inc inside loop
    get_barrel_loop:
        inc     HL
        dec     A
        jr      NZ, get_barrel_loop
    push    DE
    ld      DE, (barrels_array)
    ld      (barrels_array), HL
    ld      HL, (barrels_array)
    ld      (barrels_array), DE
    ex      DE, HL
    pop     DE
    pop     AF
    ret

; Returns activation state in A (1 == active)
is_current_barrel_active:
    push    HL
    ld      A, (current_barrel_idx)
    inc     A
    ld      HL, barrels_active - 1 ;; -1 compensates first inc inside loop
    active_barrel_loop:
        inc     HL
        dec     A
        jr      NZ, active_barrel_loop
    ld      A, (HL)
    pop     HL
    ret

reset_current_barrel_idx:
    push    AF
    ld      A, 0
    ld      (current_barrel_idx), A
    pop     AF
    ret

inc_current_barrel_idx:
    push    AF
    ld      A, (current_barrel_idx)
    inc     A
    ld      (current_barrel_idx), A
    pop     AF
    ret

handle_barrel_collision:
    push    HL
    push    BC

    call    get_current_barrel_ptr
    ld      BC, (current_character_position)
    call    reset_carry_flag
    sbc     HL, BC
    jr      NC, character_on_left
    ;; character_on_right
    call    get_current_barrel_ptr
    dec     BC
    call    reset_carry_flag
    sbc     HL, BC
    ;; Right side && char pos - 1 <= barrel pos -> collision
    call    get_current_barrel_ptr
    call    C, play_explosion_animation
    call    Z, play_explosion_animation
    jr      collision_end
    character_on_left:
        call    get_current_barrel_ptr
        inc     BC
        call    reset_carry_flag
        sbc     HL, BC
        ;; Left side && char pos + 1 >= barrel pos -> collision
        call    get_current_barrel_ptr
        call    C, play_explosion_animation
        call    Z, play_explosion_animation

    collision_end:
        pop     BC
        pop     HL
        ret

;; HL - (in) draw position
play_explosion_animation:
    call    clear_sprite
    call    draw_explosion  ;; Draw 8x8, 1/2 cart + barrel
    push    AF
    ld      A, 1
    ld      (is_game_over), A
    pop     AF
    ret

reset_carry_flag:
    SCF ;; CY  <- 1
    CCF ;; CY  <- 0
    ret

;; A - (in) number of halts to execute
animation_wait:
    push    AF

    halt
    dec     A
    jr      NZ, animation_wait

    pop     AF
    ret

;; A - (in) key to test, unchanged. Z = 0 on key pressed. A corrupt after ret.
test_key:
    push    BC
    push    HL
    call    #BB1E
    pop     HL
    pop     BC
    ret

;; HL - (in) start drawing position (char boundary not checked)
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
    push    BC
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
    pop     BC
    pop     HL
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_character:
    push    HL
    push    BC

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

    pop     BC
    pop     HL
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_barrel:
    push    HL
    push    BC

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

    pop     BC
    pop     HL
    ret

;; 8x8 pixels. Blank line after each row.
draw_explosion:
    push    HL
    push    BC

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

    ld      A, animation_ticks
    call    animation_wait

    pop     BC
    pop     HL
    call    clear_sprite    ;; Leave blank after the explosion
    ret
