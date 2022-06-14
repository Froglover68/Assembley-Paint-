IDEAL
MODEL small
STACK 100h
escmode = 1h

DATASEG
 xvalue dw 270
 yvalue dw 0
 xvalueboard dw 0
 xafterboard dw 271
 yvaluesquare dw 0
 xvaluesquare dw 271
 xmoresquares dw 271
 color db 123
 colors db 32, 48, 39, 0, 15, 44, 89, 60, 7 
 brush db 0
 squarewidth dw 20
 squareheight dw 20
 pressed db 0
 xfirstpress dw 0
 yfirstpress dw 0
 
CODESEG

proc drawboard
mov cx, 270
  draw:
  push cx
   
   mov cx, 200
   loop2:
   push cx
   mov cx, [xvalueboard]
   mov dx, [yvalue] ;y 
   mov bh, 0 ; always 0
   mov al, 15 ; choosing color
   mov ah, 12 ; dont touch
   mov ah, 0ch
   int 10h
   inc [yvalue]
   pop cx
   loop loop2
   inc [xvalueboard]
   pop cx
   mov yvalue, 0
   loop draw
   mov cx, 49
   
   afterboard:
  push cx
   
  mov cx, 200
  loop3:
   push cx
   mov cx, [xafterboard]
   mov dx, [yvalue] ;y 
   mov bh, 0 ; always 0
   mov al, 56 ; choosing color
   mov ah, 12 ; dont touch
   mov ah, 0ch
   int 10h
   inc [yvalue]
   pop cx
   loop loop3
   inc xafterboard
   pop cx
   mov yvalue, 0
   loop afterboard
   
   mov cx, 200
   loop1:
   push cx
   mov cx, [xvalue]
   mov dx, [yvalue] ;y 
   mov bh, 0 ; always 0
   mov al, 0 ; choosing color
   mov ah, 12 ; dont touch
   mov ah, 0ch
   int 10h
   inc [yvalue]
   pop cx
   loop loop1
   
   mov cx, 4
   mov bx, offset colors
   mov al, [bx]
   
   loopbuild:
   push cx
   call buildsquare
   inc bx
   mov al, [bx]
   add [yvaluesquare], 30
   pop cx
   loop loopbuild
   
   mov cx, 5
   add [xmoresquares], 28
   mov [yvaluesquare], 0
   loopbuild2:
   push cx
   call buildsquare
   inc bx
   mov al, [bx]
   add [yvaluesquare], 30
   pop cx
   loop loopbuild2
   
ret
endp drawboard

proc buildsquare
   push [xmoresquares]
   push [yvaluesquare]
       
  mov cx, [squareheight]
  outerloop:
  push cx
  mov cx, [squarewidth]
  innerloop:
  push cx
  mov cx, [xmoresquares]
   mov dx, [yvaluesquare] ;y 
   mov bh, 0 ; always 0
   mov ah, 12 ; dont touch
   int 10h
   inc [xmoresquares]
   pop cx
   loop innerloop
   push ax
   mov ax, [squarewidth]
   sub [xmoresquares],ax
   inc [yvaluesquare]
   pop ax
   pop cx
   loop outerloop
   pop [yvaluesquare]
   pop [xmoresquares]

ret
endp buildsquare






start:
   mov ax, @data ; never delete
   mov ds, ax ; never delete
   mov ax, 13h
   int 10h
   
   call drawboard
   
  mov ax, 0h
   int 33h
   mov ax, 1h
   int 33h
   
   
   
   
   mouse:
   
   
   mov ax, 3h
   int 33h
   shr cx, 1 ; Divide x pos by 2
   sub dx, 1;  ?
   cmp bx, 01h ; is left button pressed
   jne UnPressed
   cmp cx, 270 ;left side of the screen 
   
   jng testie4
   jmp changecolor
   testie4:
   
   
   cmp brush, 0
   jne SquareBrush
   

; paint a pixel
   mov bh, 0 ; always 0
   mov al, [color] ; choosing color
   mov ah, 0ch
   int 10h
  jmp EndDraw 
;draw sqaure

 SquareBrush:
  cmp [pressed],0 
  jne EndDraw
  mov [xfirstpress], cx
  mov [yfirstpress], dx
  mov [pressed],1
 
  
 EndDraw:
 jmp UnPressedEnd
 
 
 UnPressed:
  cmp [pressed],1 
  jne UnPressedEnd
  push ax
  cmp cx, [xfirstpress]
  jg flip1
  mov ax, [xfirstpress]
  mov [xfirstpress], cx
  mov cx, ax
  flip1:
  cmp dx, [yfirstpress]
  jg flip2
  mov ax, [yfirstpress]
  mov [yfirstpress], dx
  mov dx, ax
  flip2:
  push [xfirstpress]
  pop [xmoresquares]
  push [yfirstpress]
  pop [yvaluesquare]
  
  mov [squarewidth], cx
  mov ax, [xfirstpress]
  sub [squarewidth], ax
  mov [squareheight], dx
  mov ax, [yfirstpress]
  sub [squareheight], ax
  pop ax
  mov al,[color]
  call buildsquare
  mov [pressed],0
 
 
 UnPressedEnd:
;check if there was a key press
   
   mov ah, 1
   int 16h
   jnz testie3
   jmp mouse
   testie3:

; if escape pressed the exit   
   mov ah, 0
   int 16h
   cmp ah, escmode
   je testie2
   jmp mouse
   testie2:
   jmp exit
   
   
   
   
   changecolor:
   mov ah, 2h ; hide mouse pointer
   int 33h
   mov ah, 0dh ; get pixel color
   int 10h
   cmp al, 7
   jne brushchange
   cmp [brush], 0
   jne toggleoff
   
   mov [brush], 1
   jmp mouse
   toggleoff:
   mov [brush], 0
   jmp mouse
   
   brushchange:
   
   cmp al, 56
   jne testie
   jmp mouse
   testie:
   
   mov [color], al

   mov ah, 1h ;show mouse pointer
   int 33h
   jmp mouse
  
   
   
   
   
   
   
   mov cx, 270 ;x
   mov dx, 0 ;y 
   mov bh, 0 ; always 0
   mov al, 86 ; choosing color
   mov ah, 12 ; dont touch
   mov ah, 0ch
   int 10h
   
   
   
   
   
   
   exit:
   mov ax, 3h
   int 10h
    
    mov ah, 04Ch
    mov al, 0
    int 21h ; end program with code 0
end start