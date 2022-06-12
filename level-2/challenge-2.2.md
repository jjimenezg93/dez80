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

# Press

IX - draw pos (0xC801+ because the bytes of the first col are fixed)
B - space until press (0 = touching wall, ALWAYS < C)
C - length of press
L - animation length (# of halts)
H - height
DE - 0x800

4000 - move direction (1 = right, 0 = left)

01 3E F1 32 00 C0 32 00 F8 3E D3 32 00 C8 32 00 F0 3E B5 32 00 D0 32 00 E8 3E 79 32 00 D8 32 00 E0 06 01 0E 04 11 00 08 DD 21 01 C0 C5 26 08 F5 3E 00 B0 28 18 F1 3E 00 26 08 DD E5 DD 77 00 DD 19 25 20 F8 DD E1 DD 23 05 20 ED 18 01 F1 DD E5 3E FC 26 08 DD 77 00 DD 19 25 20 F8 DD E1 DD 23 C1 C5 79 90 28 16 4F 3E F0 26 08 DD E5 DD 77 00 DD 19 25 20 F8 DD E1 DD 23 0D 20 ED C1 3A 00 40 F6 00 20 03 05 18 01 04 79 90 3E 00 20 03 32 00 40 B0 20 05 3E 01 32 00 40 26 1F 76 25 20 FC C3 28 40
