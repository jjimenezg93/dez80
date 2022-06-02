# Bullet

A - aux to add/substract from H and L
B - halts per tick
C - 4 ticks before advancing IX
HL - color
DE - color offset address (88, 44, 22, 11) from which to load into A
IX - current print position (to be swapped with the SP)

Trick to always reset carry bit before depending on it (e.g. when using RR)
37 + 3F - SCF + CCF - set carry flag bit + invert

Done with 16-bit loading via SP, instead of using instructions 21 and 22:
88 44 22 11 DD 21 02 C0 0E 05 11 00 40 3E 00 21 FF 00 06 0C F5 84 67 F1 ED 44 85 6f FD 21 00 00 FD 39 DD F9 E5 FD F9 76 05 20 FC 1A 13 E5 21 04 40 37 3F ED 52 30 03 11 00 40 E1 0D 20 D4 DD 23 E5 D5 21 06 C0 DD E5 D1 37 3F ED 52 30 08 DD 36 FE 00 DD 21 02 C0 D1 E1 C3 08 40

