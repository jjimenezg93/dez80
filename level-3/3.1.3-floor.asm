org #4000
run #4000

ld      HL, #C460
ld      BC, #0800

ld      A, 80
draw_floor:
    push    HL
    call    draw_tile
    pop     HL
    inc     HL
    dec     A
    jr      NZ,draw_floor
jr      $

draw_tile:
    ld      (HL), #FF
    add     HL, BC
    ld      (HL), #3C
    add     HL, BC
    ld      (HL), #C3
    add     HL, BC
    ld      (HL), #FF
    ret