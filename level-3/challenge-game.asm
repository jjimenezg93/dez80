org #4000
run code_start

weapon_range                    equ     6
move_animation_ticks            equ     8
fire_animation_ticks            equ     15
animation_ticks                 equ     5
left_wall_position              equ     #C3C0
right_wall_position             equ     left_wall_position + #50
next_pixel_offset_v             equ     #0800
starting_position               equ     #C3E8       ;; Screen center

last_move_direction:            db      0           ;; 0 == left, 1 == right
is_game_over:                   db      0
reset_game_key:                 db      50          ;; R
move_left_key:                  db      69          ;; A
move_right_key:                 db      61          ;; D
hit_key:                        db      47          ;; Space
barrels_array:                  dw      #C3C8, #C3CB, #C3FC, #C400
barrels_active:                 dw      #0001, #0001, #0001, #0001  ;; dw so that offset works
barrels_arrays_offset:          dw      barrels_active - barrels_array
current_player_position:        dw      starting_position
current_barrel_ptr:             dw      barrels_array

code_start:
ld      HL, right_wall_position
ld      A, 80
draw_floor:
    call    draw_tile
    inc     HL
    dec     A
    jr      NZ, draw_floor

ld      A, 4
call    reset_current_barrel_ptr
draw_barrels:
    call    current_barrel_ptr_get
    call    draw_barrel
    call    inc_current_barrel_ptr
    dec     A
    jr      NZ, draw_barrels

ld      HL, (current_player_position)
call    draw_character

main_loop:
    call    handle_input
    call    handle_collisions
    ld      A, (is_game_over)
    and     A
    jr      NZ, game_over
    ld      HL, (current_player_position)
    call    draw_character
    ld      A, move_animation_ticks
    call    wait_animation
    jr      main_loop

game_over:
    ld      A, (reset_game_key)
    call    test_key
    jr      NZ, reset_game
    jr      game_over

reset_game:
    push    AF
    push    HL

    ;; Re-activate all barrels
    ld      A, 4
    ld      HL, barrels_active
    reset_barrels_loop:
        ld      (HL), #01
        inc     HL
        ld      (HL), #00
        inc     HL
        dec     A
        jr      NZ, reset_barrels_loop

    ;; Clear current character's position
    ld      HL, (current_player_position)
    call    clear_8x8_sprite

    ;; Reset starting position
    ld      HL, starting_position
    ld      (current_player_position), HL

    ld      A, 0
    ld      (is_game_over), A

    pop     HL
    pop     AF
    jr      code_start

handle_input:
    push    AF
    push    HL

    ld      A, (hit_key)
    call    test_key
    jr      Z, handle_movement

    call    play_fire_animation
    jr      end_handle_input

    handle_movement:
    ld      A, (move_right_key)
    call    test_key
    push    AF                  ;; Save flags
    ld      HL, (current_player_position)
    call    NZ, clear_8x8_sprite    ;; Clear if about to move
    pop     AF
    call    NZ, move_right

    ld      A, (move_left_key)
    call    test_key
    push    AF                  ;; Save flags
    ld      HL, (current_player_position)
    call    NZ, clear_8x8_sprite    ;; Clear if about to move
    pop     AF
    call    NZ, move_left

    end_handle_input:
        pop     HL
        pop     AF
        ret

play_fire_animation:
    push    HL

    ld      A, (last_move_direction)
    and     A
    jr      NZ, fire_right
    ;; fire_left
    ld      HL, (current_player_position)
    dec     HL
    call    clear_4x8_sprite
    call    play_left_fire_animation
    call    destroy_barrel_left
    jr      play_fire_animation_end
    
    fire_right:
        ld      HL, (current_player_position)
        inc     HL
        inc     HL
        call    clear_4x8_sprite
        call    play_right_fire_animation
        call    destroy_barrel_right

    play_fire_animation_end:
        pop     HL
        ret

move_left:
    push    AF
    push    HL
    push    BC

    ld      BC, left_wall_position + 1
    ld      HL, (current_player_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      C, move_left_end
    ;; HL > left wall
    dec     HL
    ld      (current_player_position), HL

    ld      A, 0
    ld      (last_move_direction), A
    move_left_end:
        pop     BC
        pop     HL
        pop     AF
        ret

move_right:
    push    AF
    push    HL
    push    BC

    ld      BC, right_wall_position - 2
    ld      HL, (current_player_position)
    push    HL  ;; Overwritten by SBC
    call    reset_carry_flag
    sbc     HL, BC
    pop     HL
    jr      NC, move_right_end
    ;; HL < right wall
    inc     HL
    ld      (current_player_position), HL

    ld      A, 1
    ld      (last_move_direction), A
    move_right_end:
        pop     BC
        pop     HL
        pop     AF
        ret

handle_collisions:
    push    DE

    ld      D, 4
    call    reset_current_barrel_ptr
    handle_barrel_collisions_loop:
        call    is_current_barrel_active
        and     A
        jr      Z, skip_inactive_barrel
        call    handle_barrel_collision
        skip_inactive_barrel:
            call    inc_current_barrel_ptr
            dec     D
            jr      NZ, handle_barrel_collisions_loop

    pop     DE
    ret

;; Returns the address of the current barrel in HL
current_barrel_ptr_get:
    push    AF
    push    DE

    ld      HL, (current_barrel_ptr)
    ld      A, (HL)
    ld      E, A
    inc     HL
    ld      A, (HL)
    ld      D, A
    ex      DE, HL

    pop     DE
    pop     AF
    ret

; Returns activation state in A (1 == active)
is_current_barrel_active:
    push    HL
    push    DE

    ld      DE, (barrels_arrays_offset)
    ld      HL, (current_barrel_ptr)
    add     HL, DE                      ;; Add the offset. HL now pointing to
                                        ;; active state of current barrel
    ld      A, (HL)
    pop     DE
    pop     HL
    ret

reset_current_barrel_ptr:
    push    HL
    ld      HL, barrels_array
    ld      (current_barrel_ptr), HL
    pop     HL
    ret

inc_current_barrel_ptr:
    push    HL
    ld      HL, (current_barrel_ptr)
    inc     HL
    inc     HL
    ld      (current_barrel_ptr), HL
    pop     HL
    ret

handle_barrel_collision:
    push    HL
    push    BC

    call    current_barrel_ptr_get
    ld      BC, (current_player_position)
    call    reset_carry_flag
    sbc     HL, BC
    jr      NC, character_on_left
    ;; character_on_right
    call    current_barrel_ptr_get
    dec     BC
    call    reset_carry_flag
    sbc     HL, BC
    ;; Right side && char pos - 1 <= barrel pos -> collision
    call    current_barrel_ptr_get
    call    NC, play_explosion_animation
    call    Z, play_explosion_animation
    jr      collision_end
    character_on_left:
        call    current_barrel_ptr_get
        inc     BC
        call    reset_carry_flag
        sbc     HL, BC
        ;; Left side && char pos + 1 >= barrel pos -> collision
        call    current_barrel_ptr_get
        call    C, play_explosion_animation
        call    Z, play_explosion_animation

    collision_end:
        pop     BC
        pop     HL
        ret

destroy_barrel_left:
    push    HL

    ld      HL, (current_player_position)


    pop     HL
    ret

destroy_barrel_right:
    push    HL
    push    DE

    call    reset_current_barrel_ptr
    call    inc_current_barrel_ptr
    call    inc_current_barrel_ptr      ;; 3rd barrel is first to the right if active

    ld      DE, (barrels_arrays_offset)
    ld      HL, (current_barrel_ptr)
    add     HL, DE                      ;; Add the offset. HL now pointing to
                                        ;; active state of current barrel
    ld      A, (HL)
    and     A
    jr      NZ, third_barrel_active
    inc     HL
    inc     HL                          ;; Active states are dw too due to offset
    ld      A, (HL)
    and     A
    jr      Z, destroy_barrel_right_end ;; If fourth is also inactive, end
    call    inc_current_barrel_ptr      ;; Else, point to the fourth barrel
    third_barrel_active:
        call    current_barrel_ptr_get
        ex      HL, DE
        ld      HL, (current_player_position)
        ld      A, weapon_range
        ;; Check if the barrel is within weapon range and destroy it if so
        destroy_barrel_right_loop:
            call    reset_carry_flag
            push    HL
            sbc     HL, DE
            pop     HL
            push    AF
            call    Z, destroy_barrel_entity
            pop    AF
            jr      Z, destroy_barrel_right_end
            inc     HL
            dec     A
            jr      NZ, destroy_barrel_right_loop

    destroy_barrel_right_end:
        pop     DE
        pop     HL
        ret

destroy_barrel_entity:
    push    AF
    push    DE
    push    HL

    ;; Clear barrel's sprite
    call    current_barrel_ptr_get
    call    clear_4x8_sprite

    ;; Disable it
    ld      HL, (current_barrel_ptr)
    ld      DE, (barrels_arrays_offset)
    add     HL, DE
    ld      A, 0
    ld      (HL), A

    pop     HL
    pop     DE
    pop     AF
    ret

get_first_barrel_right:
    push    HL

    ld      HL, barrels_active + 2


    pop     HL
    ret

;; HL - (in) draw position
play_explosion_animation:
    call    clear_8x8_sprite
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
wait_animation:
    push    AF

    wait_animation_loop:
        halt
        dec     A
        jr      NZ, wait_animation_loop

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

clear_8x8_sprite:
    push    HL
    push    AF

    ld      A, 2
    clear_8x8_sprite_loop:
        call    clear_4x8_sprite
        inc     HL
        dec     A
        jr      NZ, clear_8x8_sprite_loop

    pop     AF
    pop     HL
    ret

clear_4x8_sprite:
    push    AF
    push    BC
    push    HL

    ld      BC, next_pixel_offset_v
    ld      A, 8
    clear_4x8_sprite_loop:
        ld      (HL), #00
        add     HL, BC
        dec     A
        jr      NZ, clear_4x8_sprite_loop

    pop     HL
    pop     BC
    pop     AF
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_character:
    push    BC
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
    pop     BC
    ret

;; HL - (in) start drawing position (char boundary not checked)
draw_barrel:
    push    BC
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
    pop     BC
    ret

;; 8x8 pixels. Blank line after each row.
draw_explosion:
    push    BC
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
    call    wait_animation

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
    call    wait_animation

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
    call    wait_animation

    pop     HL
    pop     BC
    call    clear_8x8_sprite    ;; Leave blank at the end
    ret

;; HL - (in) start drawing position (char boundary not checked)
play_left_fire_animation:
    push    AF
    push    BC
    push    HL

    ld      BC, next_pixel_offset_v
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #11
    add     HL, BC
    ld      (HL), #33
    add     HL, BC
    ld      (HL), #11
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #00

    pop     HL
    push    HL
    ld      A, fire_animation_ticks
    call    wait_animation

    ld      (HL), #00
    add     HL, BC
    ld      (HL), #80
    add     HL, BC
    ld      (HL), #55
    add     HL, BC
    ld      (HL), #22
    add     HL, BC
    ld      (HL), #55
    add     HL, BC
    ld      (HL), #80
    add     HL, BC
    ld      (HL), #00

    pop     HL
    push    HL
    ld      A, fire_animation_ticks
    call    wait_animation

    ld      (HL), #10
    add     HL, BC
    ld      (HL), #80
    add     HL, BC
    ld      (HL), #60
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #60
    add     HL, BC
    ld      (HL), #80
    add     HL, BC
    ld      (HL), #10

    ld      A, fire_animation_ticks
    call    wait_animation

    pop     HL
    call    clear_4x8_sprite
    pop     BC
    pop     AF
    ret

;; HL - (in) start drawing position (char boundary not checked)
play_right_fire_animation:
    push    AF
    push    BC
    push    HL

    ld      BC, next_pixel_offset_v
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #88
    add     HL, BC
    ld      (HL), #CC
    add     HL, BC
    ld      (HL), #88
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #00

    pop     HL
    push    HL
    ld      A, fire_animation_ticks
    call    wait_animation

    ld      (HL), #00
    add     HL, BC
    ld      (HL), #10
    add     HL, BC
    ld      (HL), #AA
    add     HL, BC
    ld      (HL), #44
    add     HL, BC
    ld      (HL), #AA
    add     HL, BC
    ld      (HL), #10
    add     HL, BC
    ld      (HL), #00

    pop     HL
    push    HL
    ld      A, fire_animation_ticks
    call    wait_animation

    ld      (HL), #80
    add     HL, BC
    ld      (HL), #10
    add     HL, BC
    ld      (HL), #60
    add     HL, BC
    ld      (HL), #00
    add     HL, BC
    ld      (HL), #60
    add     HL, BC
    ld      (HL), #10
    add     HL, BC
    ld      (HL), #80

    ld      A, fire_animation_ticks
    call    wait_animation

    pop     HL
    call    clear_4x8_sprite
    pop     BC
    pop     AF
    ret
