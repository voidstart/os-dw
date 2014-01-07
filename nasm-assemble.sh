nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o STAGE2.SYS
nasm -f bin stage3.asm -o KRNL.SYS
