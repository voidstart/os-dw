
;*******************************************************
;
;	Stage2.asm
;		Stage2 Bootloader
;
;	OS Development Series
;*******************************************************

bits	16

; Remember the memory map-- 0x500 through 0x7bff is unused above the BIOS data area.
; We are loaded at 0x500 (0x50:0)

org 0x500

jmp	main				; go to start

;*******************************************************
;	Preprocessor directives
;*******************************************************

%include "stdio.inc"			; basic i/o routines
%include "Gdt.inc"			; Gdt routines
%include "A20.inc"

;*******************************************************
;	Data Section
;*******************************************************

LoadingMsg db "Preparing to load operating system...", 0x0D, 0x0A, 0x00

;*******************************************************
;	STAGE 2 ENTRY POINT
;
;		-Store BIOS information
;		-Load Kernel
;		-Install GDT; go into protected mode (pmode)
;		-Jump to Stage 3
;*******************************************************

main:

	;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;

	cli				; clear interrupts
	xor	ax, ax			; null segments
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000		; stack begins at 0x9000-0xffff
	mov	ss, ax
	mov	sp, 0xFFFF
	sti				; enable interrupts

	;-------------------------------;
	;   Print loading message	;
	;-------------------------------;

	mov	si, LoadingMsg
	call	Puts16

	;-------------------------------;
	;   Install our GDT		;
	;-------------------------------;

	call	InstallGDT		; install our GDT

	;-------------------------------;
	;   Enable A20			;
	;-------------------------------;

	call	EnableA20_KKbrd_Out

	;-------------------------------;
	;   Go into pmode		;
	;-------------------------------;

	cli				; clear interrupts
	mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

	jmp	CODE_DESC:Stage3	; far jump to fix CS.

	; Note: Do NOT re-enable interrupts! Doing so will triple fault!
	; We will fix this in Stage 3.

;******************************************************
;	ENTRY POINT FOR STAGE 3
;******************************************************

bits 32         ; Welcome to the 32 bit world!
%define VIDEO_MEM 0xB8000
%define COL_NUM 80
%define ROW_NUM 25
%define PIXEL_WIDTH 2h
;; 2 bytes each pixel
%define DEFAULT_ATTR 14h


at_x db 0
at_y db 0
use_char db 0
use_attr db 0

printch:
  pusha

  xor eax,eax
  xor ecx,ecx
  mov al,[at_x]
  mov cl,PIXEL_WIDTH
  mul ecx  
  ;eax is 2*x now
  add eax, VIDEO_MEM
  mov ecx, eax   
  ; ecx is 2x+VIDEO_MEM

  xor eax, eax
  xor edx,edx
  mov al, [at_y] ;
  mov dl, COL_NUM*PIXEL_WIDTH
  mul edx; eax is 80y*2
  add eax, ecx ;eax is VIDEO_MEM+2x+80y

  mov cl,[use_char]
  mov dl,[use_attr]
  mov [eax], cl
  inc eax
  mov [eax], dl

  popa
  ret

print_test:
  pusha

  mov cl, [use_char]
  xor eax,eax
  mov al, [at_x]
  add eax, VIDEO_MEM
  ;mov byte [0xb8000], 'A'
  mov byte [eax],  cl
  mov byte [0xb8001], 14h

  popa
  ret

Stage3:

	;-------------------------------;
	;   Set registers		;
	;-------------------------------;

	mov		ax, DATA_DESC		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h


  mov BYTE [at_x], 1
  mov BYTE [at_y], 1
  mov BYTE [use_char], 'A'
  mov BYTE [use_attr], DEFAULT_ATTR
  call printch
  ;;mov BYTE [use_char], 'A'
  ;;call print_test

	cli
	hlt
