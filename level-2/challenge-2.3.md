# Restrictions

Can only draw with:

```
36 XX == ld (HL), XX
```

## Single floor tile

21 A0 C0 11 00 08 36 FF 19 36 96 19 36 69 19 36 FF 18 FE

## Tiled floor

21 A0 C0 11 00 08 3E 50 E5 36 FF 19 36 96 19 36 69 19 36 FF E1 2C 3D 20 EF 18 FE

## Tiled roof

Height must be 16 pixels, including the space for the character later on.

21 A0 C0 11 00 08 3E 50 E5 E5 36 FF 19 36 96 19 36 69 19 36 FF E1 2C 3D 20 EF E1 2E 00 3E 50 E5 36 FF 19 36 FF 19 36 F0 19 36 A5 19 36 5A 19 36 05 19 36 02 E1 E5 F5 7D C6 50 6F F1 06 08 36 00 19 05 20 FA E1 2C 3D 20 D6 18 FE

## Shooting turret

21 A0 C0 11 00 08 3E 50 E5 E5 36 FF 19 36 96 19 36 69 19 36 FF E1 2C 3D 20 EF E1 2E 00 3E 50 E5 36 FF 19 36 FF 19 36 F0 19 36 A5 19 36 5A 19 36 05 19 36 02 E1 E5 F5 7D C6 50 6F F1 06 08 36 00 19 05 20 FA E1 2C 3D 20 D6 21 50 F0 36 33 2C 36 CC 2D 26 F8 36 33 2C 36 CC 2D 3E 40 76 3D 20 FC 21 50 C8 36 01 2C 36 08 2D 19 36 11 2C 36 88 2D 19 36 10 2C 36 80 2D 19 36 98 2C 36 91 2D 19 36 54 2C 36 A2 2D 3E 40 76 3D 20 FC 26 C8 36 10 2C 36 CE 2D 19 36 30 2C 36 C2 2D 19 36 30 2C 36 80 2D 19 36 10 2C 36 80 2D 19 36 10 2C 36 80 2D 3E 40 76 3D 20 FC 26 C8 36 30 2C 36 C4 2D 19 36 30 2C 36 C7 2D 19 2C 36 C4 3E 40 76 3D 20 FC 26 C8 36 D4 19 19 36 D4 3E 10 76 3D 20 FC 26 D0 36 C5 2C 36 08 3E 10 76 3D 20 FC 2D 26 C8 36 C4 26 D8 36 C4 26 D0 36 C4 2C 36 0C 3E 10 76 3D 20 FC 06 99 0E 02 3E 00 ED 67 37 3F 1F ED 6F 1F 1F 1F 1F 1F 2C 77 2D 7E F6 00 20 01 2C 3E 02 76 3D 20 FC 0D 20 E0 05 20 DB 26 C8 E5 19 3E 02 36 66 19 3D 20 FA 3E 15 76 3D 20 FC E1 E5 36 99 19 36 64 19 36 62 19 36 66 3E 15 76 3D 20 FC E1 E5 36 98 19 36 42 19 36 24 19 36 91 3E 15 76 3D 20 FC E1 E5 36 81 19 36 04 19 36 02 19 36 18 3E 15 76 3D 20 FC E1 E5 36 08 19 19 19 36 01 3E 15 76 3D 20 FC E1 C3 00 40

### Cyan Bullet movement explanation

Moving a cyan bullet means rotating through the 4 low order bits of each Byte, since the 4 high order bits must always be 0. Instead of convoluted jumping logic, this does the trick:

```asm
;; starting values
;; (HL)    - 0000 0011
;; (HL+1)  - 0000 0000
;; A       - 0000 0000

RRD
;; A       <- 0000 0011
;; (HL)    <- 0000 0000

;; Reset CY
SCF ;; CY  <- 1
CCF ;; CY  <- 0

RRA
;; A       <- 0000 0001
;; CY      <- 1

RLD
;; A       <- 0000 0000
;; (HL)    <- 0000 0001

RRA
;; A       <- 1000 0000

RRA
;; A       <- 0100 0000

RRA
;; A       <- 0010 0000

RRA
;; A       <- 0001 0000

RRA
;; A       <- 0000 1000

INC L
;; HL      <- HL+1

LD (HL), A
;; (HL+1)  <- 0000 1000
```