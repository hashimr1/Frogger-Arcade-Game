#####################################################################
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Raazia Hashim, 1006819454
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display number of lives
# 2. Game over/restart screen
# 3. Extra row
# 4. Second level of difficulty after win
# 5. Sound effects for moving, win, restart, colisions
# 6. Die Animation
# The combination is 3 easy and 3 hard features
#
# Any additional information that the TA needs to know:
# - Thank you for an amazing semester Alireza!
#
#####################################################################
.data
displayAddress: .word 0x10008000
# Colors:
green: .word 0xa6ff8c
purple: .word 0xac8cff
blue: .word 0x8cffff
red: .word 0xff8c8c
grey: .word 0x717171
yellow: .word 0xffff8c
frogalive: .word 0xf7c1f6
frogdead: .word 0x000000
frogwin: .word 0xff00d4
lives: .word 0x1007b8
turtle: .word 0x40bda0

# all x positions must be updated in multiples of 4
frogx: .word 64 
frogy: .word 56 # updated in multiples of 8 in interval {0, 56}
h: .word 64

log3x: .word 96 # bounded on [36, 96]
log3y: .word 8 # constant - very top row
log1x: .word 16  # bounded on [0, 60]
log1y: .word 16 # constant 
log2x: .word 96 # bounded on [36, 96]
log2y: .word 24 # constant

car1x: .word 0  # bounded on [0, 60]
car1y: .word 40 # constant
car2x: .word 96 # bounded on [36, 96]
car2y: .word 48 # constant

lossnumber: .word 0 # bounded on [0, 3]
win: .word 0 # bounded on [0, 1]
speed: .word 1500

string1: .asciiz "Press 'r' to restart, 'e' to exit \n"

.text
lw $s0, displayAddress # $s0 stores the base address for display

GameLoop:

Checkforinput:
lw $t8, 0xffff0000
beq $t8, 1, KeyboardInput

CheckCollisions: j CheckColi

RedrawScreen: j Draw

Wait: li $v0, 32
lw $a0, speed
syscall

lw $t6, lossnumber
li $t3, 3
beq $t6, $t3, Retry

BacktoStart: j GameLoop

Draw:
# win area
lw $t3, win
beqz $t3, Green1
lw $t0 frogx
li $t1 0
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, frogwin
jal FrogFunc

# First green block
Green1: addi $a1, $s0, 0  
addi $a2, $a1, 512 
lw $a0, green
jal RectFunc

# draw lives
lw $a0, lives
lw $a1, lossnumber

beqz $a1, three
li $t1, 1
beq $a1, $t1, two
li $t1, 2
beq $a1, $t1, one
li $t1, 3
beq $a1, $t1, River

one: sw $a0, 124($s0)
j River
two: sw $a0, 116($s0)
sw $a0, 124($s0)
j River
three: sw $a0, 108($s0)
sw $a0, 116($s0)
sw $a0, 124($s0)

# Logs and River
River: addi $a1, $s0, 512 
addi $a2, $a1, 512  
lw $a0, red
jal RectFunc

addi $a1, $s0, 1024 
addi $a2, $a1, 512  
lw $a0, turtle
jal RectFunc

addi $a1, $s0, 1536 
addi $a2, $a1, 512  
lw $a0, red
jal RectFunc

# top row of logs
Log5: lw $t0 log3x
lw $t1 log3y
lw $t2 h
mult $t1, $t2
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
lw $a0, blue
jal SmallRectFunc

Log6: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32 # 1: 60-32 < 32
startx: bnez $s3, small5
li $a3, 32
li $v0, 96
jal SmallRectFunc
j Log1
small5: sub $a3, $t0, $s1  #60 = t0 - 32 = s1 = 28
sub $v0, $v0, $a3  # 128 - 28 = 128 - (32 - (36 - 32)))
add $a1, $s0, 512
addi $a2, $a1, 512
jal SmallRectFunc
sub $a3, $s1, $a3 # 32 - 28 = 4
li $v0, 128
sub $v0, $v0, $a3 # 128 - 4
li $s3, 512
add $s3, $s3, $v0
add $a1, $s0, $s3 # 1536 + (128 - 4)
addi $a2, $a1, 512
jal SmallRectFunc

Log1: lw $t0 log1x
lw $t1 log1y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, blue
li $a3, 32
li $v0, 96
jal SmallRectFunc

Log2: add $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 0
start: beqz $s3, small
li $a3, 32
li $v0, 96
jal SmallRectFunc
j Log3
small: sub $a3, $s1, $s2  
sub $v0, $v0, $a3  
jal SmallRectFunc
add $a1, $s0, 1024
addi $a2, $a1, 512
add $a3, $zero, $s2  
li $v0, 128
sub $v0, $v0, $s2 
jal SmallRectFunc

Log3: lw $t0 log2x
lw $t1 log2y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
jal SmallRectFunc

Log4: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32 
start2: bnez $s3, small2
li $a3, 32
li $v0, 96
jal SmallRectFunc
j Rest
small2: sub $a3, $t0, $s1  
sub $v0, $v0, $a3 
add $a1, $s0, 1536
addi $a2, $a1, 512
jal SmallRectFunc
sub $a3, $s1, $a3 
li $v0, 128
sub $v0, $v0, $a3
li $s3, 1536
add $s3, $s3, $v0
add $a1, $s0, $s3 
addi $a2, $a1, 512
jal SmallRectFunc

# Rest block
Rest: addi $a1, $s0, 2048 
addi $a2, $a1, 512 
lw $a0, purple
jal RectFunc

# Road and cars
Road: addi $a1, $s0, 2560
addi $a2, $a1, 1024 
lw $a0, grey
jal RectFunc

Car1: lw $t0 car1x
lw $t1 car1y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, yellow
li $a3, 32
li $v0, 96
jal SmallRectFunc

Car2: add $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 0
start3: beqz $s3, small3
li $a3, 32
li $v0, 96
jal SmallRectFunc
j Car3
small3: sub $a3, $s1, $s2 
sub $v0, $v0, $a3  
jal SmallRectFunc
add $a1, $s0, 2560 
addi $a2, $a1, 512
add $a3, $zero, $s2  
li $v0, 128
sub $v0, $v0, $s2 
jal SmallRectFunc

Car3: lw $t0 car2x
lw $t1 car2y
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $a3, 32
li $v0, 96
jal SmallRectFunc

Car4: sub $t3, $t3, 64
add $a1, $s0, $t3
addi $a2, $a1, 512
li $s1, 32
li $v0, 128
sub $s2, $t0, $s1
slti $s3, $s2, 32
start4: bnez $s3, small4
li $a3, 32
li $v0, 96
jal SmallRectFunc
j Green2
small4: sub $a3, $t0, $s1
sub $v0, $v0, $a3  
add $a1, $s0, 3072
addi $a2, $a1, 512
jal SmallRectFunc
sub $a3, $s1, $a3 
li $v0, 128
sub $v0, $v0, $a3
li $s3, 3072
add $s3, $s3, $v0
add $a1, $s0, $s3 
addi $a2, $a1, 512
jal SmallRectFunc

# Green block
Green2: addi $a1, $s0, 3584 
addi $a2, $a1, 512 
lw $a0, green
jal RectFunc

# Frog
Frog: lw $t0 frogx
lw $t1 frogy
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
li $t3, 8
lw $a0, frogalive
jal FrogFunc

# Update car and log positions
row1:
lw $t0 log1x
la $t7 car1x
la $t8 log1x
li $t9 60
beq $t0, $t9, back
addi $t0, $t0, 4
sw $t0, 0($t8)
sw $t0, 0($t7)
j row2
back: sw $zero, 0($t8)
sw $zero, 0($t7)
j row2

row2:
lw $t0 log2x
la $t7 car2x
la $t8 log2x
la $t2 log3x
li $t9 36
beq $t0, $t9, froward
subi $t0, $t0, 4
sw $t0, 0($t8)
sw $t0, 0($t7)
sw $t0, 0($t2)
j Win
froward: li $t0, 96
sw $t0, 0($t8)
sw $t0, 0($t7)
sw $t0, 0($t2)
j Win

# draw win area
Win: lw $t3, win
beq $t3, $zero, w
lw $t0 frogx
li $t1 0
lw $t6 h
mult $t1, $t6
mfhi $t4
mflo $t5
add $t3, $t4, $t0 
add $t3, $t3, $t5
add $a1, $s0, $t3
addi $a2, $a1, 512
lw $a0, frogwin
jal FrogFunc
la $t3, win
sw $zero, 0($t3)

w: j Wait


#Keyboard input:
KeyboardInput: 
addi $t8, $zero, 0
lw $t2, 0xffff0004
beq $t2, 0x77, respond_to_w
beq $t2, 0x73, respond_to_s
beq $t2, 0x61, respond_to_a
beq $t2, 0x64, respond_to_d
j CheckColi

respond_to_w:
lw $t0 frogy 
la $t8 frogy
beqz $t0, paint
subi $t0, $t0, 8
sw $t0, 0($t8)
li $t2, 0

li $a0, 27  # sound
li $a1, 1000
li $a2, 100
li $a3, 127
li $v0, 31     
syscall
j CheckColi
paint: li $t0, 56
sw $t0, 0($t8)
la $t3, win
li $t0, 1
sw $t0, 0($t3)
la $t3, lossnumber
sw $zero, 0($t3)
li $a0, 33  # sound
li $a1, 5000
li $a2, 85
li $a3, 127
li $v0, 31     
syscall

lw $a0, speed
la $t0, speed
subi $a0, $a0, 500
beq $a0, 500, re
sw $a0, 0($t0)
j RedrawScreen
#j Score
re:
li $a0, 500
sw $a0, 0($t0)
j RedrawScreen
#j Score

respond_to_s:
lw $t0 frogy
la $t8 frogy
li $t3, 56
beq $t0, $t3, redo2
addi $t0, $t0, 8
sw $t0, 0($t8)
li $t2, 0

li $a0, 27  # sound
li $a1, 1000
li $a2, 100
li $a3, 127
li $v0, 31     
syscall
redo2: j CheckColi

respond_to_a:
lw $t0 frogx
la $t8 frogx
beq $t0, $zero, redo3
subi $t0, $t0, 16
sw $t0, 0($t8)
li $t2, 0

li $a0, 27  # sound
li $a1, 1000
li $a2, 100
li $a3, 127
li $v0, 31     
syscall
redo3: j CheckColi

respond_to_d:
lw $t0 frogx
la $t8 frogx
li $t3, 112
beq $t0, $t3, redo4
addi $t0, $t0, 16
sw $t0, 0($t8)
li $t2, 0

li $a0, 27  # sound
li $a1, 1000
li $a2, 100
li $a3, 127
li $v0, 31     
syscall
redo4: j CheckColi

# Check colisions
CheckColi:
la $t8 frogy
lw $t0, frogy
lw $t1, car1y
lw $t2, log1y 
lw $t3, car2y 
lw $t4, log2y 
lw $t9, log3y
beq $t0, $t1, c1
beq $t0, $t2, l1
beq $t0, $t3, c2
beq $t0, $t4, l2
beq $t0, $t9, l3
j RedrawScreen

# top car row:
c1: lw $t0, frogx #fx1
lw $t1, car1x # cx1
addi $t2, $t1, 32 # cx2
addi $t4, $t1, 96 # cx4

slti $s1, $t1, 32 # 1: fx1 < 32
bnez $s1, check2 # 0 != s1 = 1 -> [0,28]

addi $t3, $t2, 16 # cx2+16
addi $t5, $t4, 16 # cx4+16

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, n
bnez $s2, n
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t5  -> safe
n: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, m
bnez $s2, m
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
m: j RedrawScreen 

check2: # -> [32,60]
addi $t3, $t2, 16 # cx2+16
sub $t5, $t1, $t1  # cx1-cx1
subi $t6, $t1, 16 # cx1-16

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, k
bnez $s2, k
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t5 <= t0 && t0 <= t6  -> safe
k: slt $s1, $t0, $t5 # 1: t0 < t5
slt $s2, $t6, $t0 # 1: t6 < t0
beqz $s1, l
bnez $s2, l
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
l: j RedrawScreen 

# top log row:
l1: lw $t0, frogx #fx1
lw $t1, log1x # cx1
addi $t2, $t1, 32 # cx2
addi $t4, $t1, 96 # cx4

slti $s1, $t1, 32 # 1: fx1 < 32
bnez $s1, check3 # 0 != s1 = 1 -> [0,28]

addi $t3, $t2, 16 # cx2+16
addi $t5, $t4, 16 # cx4+16

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, s
bnez $s2, s
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t5  -> safe
s: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, d
bnez $s2, d
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
d: j RedrawScreen

check3: # -> [32,60]
addi $t3, $t2, 16 # cx2+16
sub $t5, $t1, $t1  # cx1-cx1
subi $t6, $t1, 16 # cx1-16

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, r
bnez $s2, r
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t5 <= t0 && t0 <= t6  -> safe
r: slt $s1, $t0, $t5 # 1: t0 < t5
slt $s2, $t6, $t0 # 1: t6 < t0
beqz $s1, t
bnez $s2, t
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
t: j RedrawScreen

# bottom car row:
c2: lw $t0, frogx #fx1
lw $t1, car2x # cx1
subi $t2, $t1, 32 # cx2 = cx1-32
subi $t3, $t1, 16 # cx3 = cx1-16

slti $s1, $t1, 80 # 1: fx1 < 80
bnez $s1, check5 # 0 != s1 = 1 -> [36,78]

sub $t4, $t1, $t1  # cx4 = cx1-cx1
subi $t5, $t1, 80 # cx5 = cx1-80

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, c
bnez $s2, c
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t4  -> safe
c: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, v
bnez $s2, v
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
v: j RedrawScreen

check5: # -> [36,78]
addi $t3, $t1, 32 # cx3 = cx1+32
addi $t4, $t1, 48 # cx4 = cx1+48

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, u
bnez $s2, u
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t5  -> safe
u: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, i
bnez $s2, i
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
i: j RedrawScreen

# bottom log row:
l2: lw $t0, frogx #fx1
lw $t1, log2x # cx1
subi $t2, $t1, 32 # cx2 = cx1-32
subi $t3, $t1, 16 # cx3 = cx1-16

slti $s1, $t1, 80 # 1: fx1 < 80
bnez $s1, check6 # 0 != s1 = 1 -> [36,78]

sub $t4, $t1, $t1  # cx4 = cx1-cx1
subi $t5, $t1, 80 # cx5 = cx1-80

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, o
bnez $s2, o
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t4  -> safe
o: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, p
bnez $s2, p
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
p: j RedrawScreen

check6: # -> [36,78]
addi $t3, $t1, 32 # cx3 = cx1+32
addi $t4, $t1, 48 # cx4 = cx1+48

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, a
bnez $s2, a
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t5  -> safe
a: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, q
bnez $s2, q
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
q: j RedrawScreen

# first log row
l3: lw $t0, frogx #fx1
lw $t1, log3x # cx1
subi $t2, $t1, 32 # cx2 = cx1-32
subi $t3, $t1, 16 # cx3 = cx1-16

slti $s1, $t1, 80 # 1: fx1 < 80
bnez $s1, check7 # 0 != s1 = 1 -> [36,78]

sub $t4, $t1, $t1  # cx4 = cx1-cx1
subi $t5, $t1, 80 # cx5 = cx1-80

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, op
bnez $s2, op
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t4  -> safe
op: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, po
bnez $s2, po
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
po: j RedrawScreen

check7: # -> [36,78]
addi $t3, $t1, 32 # cx3 = cx1+32
addi $t4, $t1, 48 # cx4 = cx1+48

# t2 <= t0 && t0 <= t3 -> safe
slt $s1, $t0, $t2 # 1: t0 < t2
slt $s2, $t3, $t0 # 1: t3 < t0
beqz $s1, af
bnez $s2, af
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
j RedrawScreen
# t4 <= t0 && t0 <= t5  -> safe
af: slt $s1, $t0, $t4 # 1: t0 < t4
slt $s2, $t5, $t0 # 1: t5 < t0
beqz $s1, qu
bnez $s2, qu
li $t0, 56
sw $t0, 0($t8)
lw $t1, lossnumber
la $s7, lossnumber
addi $t1, $t1, 1
sw $t1, 0($s7)
li $a0, 120  # sound
li $a1, 1000
li $a2, 95
li $a3, 127
li $v0, 31     
syscall
qu: j RedrawScreen

# retry screen
Retry:
#lw $t0, displayAddress
lw $t2, frogdead
	
li $a0, 50  # sound
li $a1, 5000
li $a2, 55
li $a3, 127
li $v0, 31     
syscall
		
	# I
	addi $t1, $zero, 592
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 560
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 528
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 496
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 464
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
		
	# D
	addi $t1, $zero, 584
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 552
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 520
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 488
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 456
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)

	addi $t1, $zero, 585
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 554
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 522
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 490
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 457
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	# E
	addi $t1, $zero, 598
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 599
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 600
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 566
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 534
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 535
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 536
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
	addi $t1, $zero, 502
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
		
	addi $t1, $zero, 470
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 471
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	addi $t1, $zero, 472
	sll $t1, $t1, 2
	add $t1, $t1, $s0
	sw $t2, 0($t1)
	
li $v0, 32
li $a0, 4000
syscall

li $v0, 4       
la $a0, string1  
syscall

Draw2:
addi $a1, $s0, 0  
addi $a2, $a1, 512 
lw $a0, frogalive
jal RectFunc
addi $a1, $s0, 512  
addi $a2, $a1, 512 
lw $a0, blue
jal RectFunc
addi $a1, $s0, 1024  
addi $a2, $a1, 512 
lw $a0, green
jal RectFunc
addi $a1, $s0, 1536  
addi $a2, $a1, 512 
lw $a0, purple
jal RectFunc
addi $a1, $s0, 2048  
addi $a2, $a1, 512 
lw $a0, yellow
jal RectFunc
addi $a1, $s0, 2560  
addi $a2, $a1, 512 
lw $a0, red
jal RectFunc
addi $a1, $s0, 3072  
addi $a2, $a1, 512 
lw $a0, frogwin
jal RectFunc
addi $a1, $s0, 3072  
addi $a2, $a1, 512 
lw $a0, turtle
jal RectFunc
addi $a1, $s0, 3584 
addi $a2, $a1, 512 
lw $a0, frogalive
jal RectFunc

lw $t8, 0xffff0000
beq $t8, 1, check_in

li $v0, 32
li $a0, 500
syscall

j Draw2
check_in: addi $t8, $zero, 0
lw $t2, 0xffff0004
beq $t2, 0x65, Exit
beq $t2, 0x72, respond_to_r

respond_to_r:
la $t8 frogy
li $t0, 56
sw $t0, 0($t8)
la $t3, win # reset win
sw $zero, 0($t3)
la $t3, lossnumber # reset loss number
sw $zero, 0($t3)
la $t0, speed # reset speed
li $a0, 1500
sw $a0, 0($t0)
li $a0, 33  # sound
li $a1, 5000
li $a2, 55
li $a3, 127
li $v0, 31     
syscall
j GameLoop

Exit: li $v0, 10        # terminate the program gracefully
syscall

# Functions:
RectFunc:
Loop: beq $a1, $a2, Return
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop
Return: jr $ra

FrogFunc:
Loop4: beq $a1, $a2, Return3
addi $t1, $a1, 16
Loop5: beq $a1, $t1, y
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop5
y: addi $a1, $a1, 112
j Loop4
Return3: jr $ra

SmallRectFunc:
Loop2: beq $a1, $a2, Return2
add $t1, $a1, $a3 
Loop3: beq $a1, $t1, x
sw $a0, 0($a1)
addi $a1, $a1, 4
j Loop3
x: add $a1, $a1, $v0
j Loop2
Return2: jr $ra
