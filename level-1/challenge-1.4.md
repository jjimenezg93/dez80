# Underlining x8

4000 - 0xC370 - first pixel

4002 - 0x05 - width (in chars)

4003-400A - colors

4040 - code

IX - vMem ptr

BC - offset to reset pointer to starting pos (-8 = FFF8)

HL - offset into color array (++ before loop jump)

D - width loop counter

E - height loop counter

mem + registers loaded:

70 C3 05 FF FF FF F0 F0 FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2A 00 40 01 F8 FF DD 21 03 40 1E 08

70 C3 05 FF FF FF F0 F0 FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 DD 21 70 C3 01 F8 FF 21 03 40 3A 02 40 57 7E 23 DD 77 00 DD 77 01 DD 77 02 DD 77 03 DD 77 04 DD 77 05 DD 77 06 DD 77 07 DD 77 08 DD 77 09 1D FE

70 C3 05 FF FF FF F0 F0 FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 DD 21 70 C3 01 00 08 21 03 40 1E 08 3A 02 40 57 7E 23 DD 77 00 DD 77 01 DD 77 02 DD 77 03 DD 77 04 DD 77 05 DD 77 06 DD 77 07 DD 77 08 DD 77 09 DD 09 1D 20 DB 18 FE

# Surrounding box

4000 - code

top line:

DD 21 9D F9 DD 36 00 03 3E FF 06 06 DD 23 DD 77 00 05 20 F8 DD 36 01 0C 18 FE

top line + first pixel second line:

DD 21 3D FA DD 36 00 03 3E FF 06 06 DD 23 DD 77 00 05 20 F8 DD 36 01 0C 11 4A C8 DD 19 DD 36 00 03 18 FE

top line + sides (2px):

DD 21 3D EA 26 02 3E FF 11 00 08 DD 19 DD 36 00 03 06 06 DD 23 DD 77 00 05 20 F8 DD 36 01 0C 01 FA FF DD 09 25 20 E4 11 50 C0 DD 19 11 00 08 06 07 DD 19 DD 36 00 03 DD 36 07 0C 05 20 F3 18 FE

finished:

DD 21 3D EA 26 02 3E FF 11 00 08 DD 19 DD 36 00 03 06 06 DD 23 DD 77 00 05 20 F8 DD 36 01 0C 01 FA FF DD 09 25 20 E4 11 50 C0 DD 19 11 00 08 06 08 DD 19 DD 36 00 03 DD 36 07 0C 05 20 F3 11 50 C8 DD 19 11 00 08 26 02 DD 36 00 03 06 06 DD 23 DD 77 00 05 20 F8 DD 36 01 0C 01 FA FF DD 09 DD 19 25 20 E4 18 FE

# Dice

H - yellow x2 - F0

L - yellow + red - F3

A - yellow + bg - C0

D - height loop counter

IX - print pos (0xC398 == 0xC000 + 0x50 * 8 + 40)

DD 21 98 C3 01 00 08 26 F0 2E F3 3E C0 16 03 DD 74 00 DD 74 01 DD 77 02 DD 09 DD 75 00 DD 75 01 DD 77 02 15 DD 09 20 E7 DD 74 00 DD 74 01 DD 77 02 18 FE
