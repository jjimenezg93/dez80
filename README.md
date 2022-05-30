# DEZ80

# Links

- [Course link (Dominando Ensamblador Z80)][course]
- [Z80 User manual][um]
- [Z80 Instruction set][is]

# Machine specs

- Little endian
- Screen width: 320 pixels
- Video memory starting pos: C000

# Time

CRTC generates an interruption every time it draws 52 rows of the screen and generates 300 interrupts/s. Therefore:

300 interrupts/s
6 interrupts/frame
300/6 = 50 frame/s

# Color encoding

Each byte encodes 4 pixels (2 bits per pixel). The byte is split into two nibbles and the same index within both nibbles corresponds to a single pixel.

|        | Index |
|--------|-------|
|Nibble 1|  0123 |
|Nibble 2|  0123 |

The two bits of each pixel should be set according to the following table:

| Red | Yellow | Cyan | Blue |
|-----|--------|------|------|
|  1  |    1   |   0  |   0  |
|  1  |    0   |   1  |   0  |

See [examples](#examples) below for specific encoding examples.

## Examples

|        |  rrrr |
|--------|-------|
|Nibble 1|  1111 |
|Nibble 2|  1111 |
|Byte    |  0xFF |

|        |  rryy |
|--------|-------|
|Nibble 1|  1111 |
|Nibble 2|  1100 |
|Byte    |  0xFC |

|        |  rycb |
|--------|-------|
|Nibble 1|  1100 |
|Nibble 2|  1010 |
|Byte    |  0xCA |


[course]: https://profesorretroman.com/course/view.php?id=2
[um]: https://www.z80cpu.eu/mirrors/www.z80.info/zip/z80cpu_um.pdf
[is]: https://clrhome.org/table/