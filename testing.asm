
          cli  ;;  ensure no interferences
          ;; testing ground
          xor     ax, ax
          mov     ax, 7077h
          xor     cx, cx
          mov     cx, 7077h
          mul     cx
          ;; 7077 x 70277 is 0x31,68,57,51 (1hQW) all printable

          mov [msgPrint], ax
          mov [msgPrint+2], dx
          mov si, msgPrint
          call Print

          cli  ;;
          hlt  ;; Halt here



     msgPrint db "------", 0x00
