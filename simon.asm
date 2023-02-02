IDEAL
MODEL small
STACK 100h

DATASEG
floorx dw 140
floory dw 100
color db 3
color1 db 2
mousecolor db 0
floorw dw 40
floorh dw 40
Clock equ es:6Ch
GAME_OVER DB 'GAME OVER                               press the mouse to start again','$'
START_SCREEN DB 'Simon                                   press the mouse to start','$'
note dw 0c71h
note1 dw 0ba6h
note2 dw 09a1h
note3 dw 08b2h

CODESEG
proc gameoverscreen
mov ah,02h                       
mov bh,00h                    
mov dh,04h                      
mov dl,04h						 
int 10h							 
mov ah,09h                      
lea DX,[GAME_OVER]
int 21h          
; Initializes the mouse
mov ax,0h
int 33h
; Show mouse
mov ax,1h
int 33h
; Loop until mouse click
MouseLP1 :
mov ax,3h
int 33h
cmp bx, 01h ; check left mouse click
jne MouseLP1
call startjump
ret
endp gameoverscreen

proc cube
mov ax, 2
int 33h
push [floorw]
rectangleh:
pop [floorw]
push [floorw]
rectanglew:
mov bh,0h
mov cx,[floorx]
add cx,[floorw]
mov dx,[floory]
add dx , [floorh]
mov al,[color]
mov ah,0ch
int 10h
sub [floorw], 1
cmp [floorw], 0
jne rectanglew
sub [floorh], 1
cmp [floorh], 0
jne rectangleh
pop [floorw]
mov [floorw], 40    ;size
mov [floorh], 40
mov ax,0h
int 33h
mov ax,1h
int 33h
ret
endp cube


proc readpixel
; Set graphics mode 320x200x256
mov ax,13h
int 10h
; Read dot
mov bh,0h
inc cx
mov cx,cx
mov dx,dx
mov ah,0Dh
int 10h ; return al the pixel value read
ret
endp readpixel

proc colorcheck
mov [mousecolor],al
call readpixel
cmp al,[mousecolor]
je c
call gameoverscreen
c:
ret
endp colorcheck


proc wait1
; wait for first change in timer
mov ax, 40h
mov es, ax
mov ax, [Clock]
FirstTick:
cmp ax, [Clock]
je FirstTick
; count 1 sec
mov cx, 2 ; 182x0.055sec = ~10sec
DelayLoop:
mov ax, [Clock]
Tick:
cmp ax, [Clock]
je Tick
loop DelayLoop
ret
endp wait1

proc mouse
; Initializes the mouse
mov ax,0h
int 33h
; Show mouse
mov ax,1h
int 33h
; Loop until mouse click
MouseLP :
mov ax,3h
int 33h
cmp bx, 01h ; check left mouse click
jne MouseLP
shr cx,1 ; adjust cx to range 0-319, to fit screen
sub dx, 1 ; move one pixel, so the pixel will not be hidden by mouse
mov bh,0h
mov al,[color1]
mov ah,0Ch
int 10h
ret
endp mouse



proc whitescreen
mov [floorw], 320
mov [floorh], 200
mov [floorx], 0
mov [floory], 0
mov [color], 15
call cube
ret
endp whitescreen

proc startscreen
mov ah,02h                       
mov bh,00h                    
mov dh,04h                      
mov dl,04h						 
int 10h							 
mov ah,09h                      
lea DX,[START_SCREEN]  
int 21h          
; Initializes the mouse
mov ax,0h
int 33h
; Show mouse
mov ax,1h
int 33h
; Loop until mouse click
MouseLP2 :
mov ax,3h
int 33h
cmp bx, 01h ; check left mouse click
jne MouseLP2
call whitescreen
ret
endp startscreen

proc sound
; open speaker
in al, 61h
or al, 00000011b
out 61h, al
; send control word to change frequency
mov al, 0B6h
out 43h, al
; play frequency 131Hz
out 42h, al ; Sending lower byte
mov al, ah
out 42h, al ; Sending upper byte
call wait1
; close the speaker
in al, 61h
and al, 11111100b
out 61h, al
ret
endp sound

proc click1
mov ax, [note]
call sound
mov [floorw], 40
mov [floorh], 40
mov [floorx], 90
mov [floory], 70
mov [color], 10
call cube
call wait1
mov [floorw], 40
mov [floorh], 40
mov [floorx], 90
mov [floory], 70
mov [color], 2
call cube
ret
endp click1

proc click2
mov ax, [note1]
call sound
mov [floorx], 170
mov [floory],70
mov [color],4
call cube
call wait1
mov [floorx], 170
mov [floory],70
mov [color],12
call cube
ret
endp click2

proc click3
mov ax, [note2]
call sound
mov [floorx], 90
mov [floory],140
mov [color],15
call cube
call wait1
mov [floorx], 90
mov [floory],140
mov [color],14
call cube
ret
endp click3

proc click4
mov ax, [note3]
call sound
mov [floorx],170
mov [floory],140
mov [color],11
call cube 
call wait1
mov [floorx],170
mov [floory],140
mov [color],1
call cube 
ret
endp click4

proc startjump
cmp ax,ax
je start
ret
endp startjump

start :
mov ax, @data
mov ds, ax
mov bp, 0
; Graphic mode
mov ax, 13h
int 10h
call startscreen

;cube number 1
mov [floorw], 40
mov [floorh], 40
mov [floorx], 90
mov [floory], 70
mov [color], 2
call cube
;cube number 2
mov [floorx], 170
mov [floory],70
mov [color],4
call cube
;cube number 3
mov [floorx], 90
mov [floory],140
mov [color],14
call cube
;cube number 4
mov [floorx],170
mov [floory],140
mov [color],1
call cube 


call click1
call wait1
call click2
call wait1
call click3
call wait1
call click4
call wait1






cub:
mov ah, 0
int 16h
je cube1
je cube2
je cube3
je cube4


cube1:
mov [floorx], 90
mov [floory], 70
mov [color], al
call cube
jmp cub

cube2:
mov [floorx], 140
mov [floory], 140
call cube
jmp cub

cube3:
mov [floorx], 90
mov [floory],140
jne cube4
call cube
jmp cub

cube4:
mov [floorx],170
mov [floory],140
call cube
jmp cub





exit:
mov ax, 4c00h
int 21h
END start