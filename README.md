# DEZ80

This repository holds the code for all of the challenges of the [DEZ80][dez80] course.

**Check out the `README.md` inside each level's subfolder for a preview of all of them.**

# Trying out the code

All of the code in this repository has been tested in [WinAPE](http://www.winape.net/) using the `CPC 464 with ParaDOS` preset.

## Levels 1 and 2

- Copy the machine code that you want to test.
- Open the debugger window of WinApe.
- Paste the code in the memory position `0x4000` (use `Ctrl+G` or `Right Click > Goto...`).
- Change the value of the PC to the position where the code starts. By default this will be where you pasted the code in the previous step, but some programs store data at the beginning so their code will start in a higher position. The comments in each section (or a lot of `0`s in the middle of the machine code) should make it clear if this is the case.
- Close the debugger window and the program will execute.

## Level 3

- Open the assembler window.
- Open the `.asm` file.
- Assemble and run (`Assemble > Run` or `F9`).

**NOTE**: Some of these machine code programs assume that executable instructions start at position `0x4000` and reference memory positions directly based on this assumption (e.g. to store data). This is for the sake of simplicity or complying with constraints for that specific challenge (e.g. use specific instruction).

# Links

- [Course link (Dominando Ensamblador Z80)][dez80]
- [Z80 User Manual][user-manual]
- [Z80 Instruction Set][instruction-set]
- [Amstrad CPC Firmware guide][firmware-guide]
- [Amstrad CPC User Instructions][user-instructions] (keycodes in page 334)

# Notes

## Time

CRTC generates an interruption every time it draws 52 rows of the screen and generates 300 interrupts/s. Therefore:

300 interrupts/s

6 interrupts/frame

300/6 = 50 frame/s

## Video mode 1 (default)

### Color encoding

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

### Examples

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


[dez80]: https://profesorretroman.com/course/view.php?id=2
[user-manual]: https://www.z80cpu.eu/mirrors/www.z80.info/zip/z80cpu_um.pdf
[user-instructions]: https://www.cpcwiki.eu/manuals/AmstradCPC6128-hypertext-en-Sinewalker.pdf
[firmware-guide]: http://www.cantrell.org.uk/david/tech/cpc/cpc-firmware/firmware.pdf
[instruction-set]: https://clrhome.org/table/