# 4 pixels

ld   A , #FF
ld   HL, #C000
ld (HL), A

jr $

# Mining cart

ld    HL, #C410
ld    BC, #0800

ld  (HL), #88
inc   HL
ld  (HL), #11

add   HL, BC
ld  (HL), #F1
dec   HL
ld  (HL), #F8

add   HL, BC
ld  (HL), #FE
inc   HL
ld  (HL), #F7

add   HL, BC
ld  (HL), #FF
dec   HL
ld  (HL), #FF

add   HL, BC
ld  (HL), #BB
inc   HL
ld  (HL), #DD

add   HL, BC
ld  (HL), #8A
dec   HL
ld  (HL), #15

add   HL, BC
ld  (HL), #4A
inc   HL
ld  (HL), #25

add   HL, BC
ld  (HL), #02
dec   HL
ld  (HL), #04

jr $
