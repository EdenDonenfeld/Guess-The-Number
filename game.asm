MODEL small
STACK 100h
DATASEG
game_name db "GUESS THE NUMBER$"
credit db "By: Eden Donenfeld$"
press_key db "*Press any key to start*$"
press_key_exit db "*Press any key to exit*$"
press_key_continue db "*Press any key to continue*$"
help_logo db "GAME INSTRUCTIONS$"
thanks_for_playing db "THANK YOU FOR PLAYING !!$"
welcome db "Welcome $"
show_number db "Do you want to see the number? [y/n] $"
number_str db "The number is: $"
lose_msg db "The number was: $"
username_input db "Please enter your name: $"
username db 10 dup (?), '$'
won db "YOU WON :)$"
lost db "YOU LOST :($"
smiley db ":)$"
input db "Please enter a number between 1-255: $"
bigger db "The number you entered is too BIG$"
smaller db "The number you entered is too SMALL$"
range db "The number you entered is not in range$"
correct db "Good job! You guessed it :)$"
invalid db "You entered invalid input$"
again db "Do you want to play again? [y/n]: $"
try_again db "Type again...$"
score_screen db "SCORE:  $"
duplicate_msg db "You already guessed it...$"
score dw 0
score_str db 4 dup (?), '0', '$'
new_line db 10,13,'$'
correct_number db 30 
correct_number_str db 3 dup (?), '$'
guessed_number_int dw 0
guessed_number db 3 dup (0), '$'
status db "l" ; l for lose
tries_str db "Number of tries: $"
tries db 3 dup (?), '$'
tries_int db 0 ; tries as a number
numbers dw 10 dup (?)
Clock equ es:6Ch
bx_saver dw 0
note_c5 dw 8e9h
note_d5 dw 7f0h
note_e5 dw 712h
note_f5 dw 6ADh
note_g5 dw 5F1h
note_a5 dw 54Bh
note_b5 dw 4b8h
note_c6 dw 474h
note_c4 dw 11dbh
note_d4 dw 0fe8h
note_e4 dw 0e2ah
filename db 'smile.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10 ,'$'
include logo.asm
CODESEG
start:
mov ax, @data
mov ds, ax

mov bx, 0
call start_computer_logo
cmp bx, 0
jne exit_input_break

; Graphic mode - logo, credit, etc.
call start_graphics

; Printing the GUESS THE NUMBER logo
mov ah, 9h
mov dx, offset start_game
int 21h

call print_new_line
call print_new_line

; Getting the user's name
call username_func

; Calling the main program 
call Main_Program

; GAME OVER
exit:
mov dx, offset game_over
mov ah, 9h
int 21h
call print_new_line

; Delay of 0.5 seconds
call sec_clock
call sec_clock
call sec_clock

exit_input_break:
jmp exit_input

; ***************************************

; Open file
OpenFile proc 
mov ah, 3Dh
xor al, al
mov dx, offset filename
int 21h
jc openerror
mov [filehandle], ax
ret
openerror :
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFile

; ***************************************

; Read BMP file header, 54 bytes
ReadHeader proc 
mov ah,3fh
mov bx, [filehandle]
mov cx,54
mov dx,offset Header
int 21h
ret
endp ReadHeader

; ***************************************

; Read BMP file color palette, 256 colors * 4 bytes (400h)
ReadPalette proc 
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
ret
endp ReadPalette

; ***************************************

; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
CopyPal proc 
mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0
; Copy starting color to port 3C8h
out dx,al
; Copy palette itself to port 3C9h
inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB .
mov al,[si+2] ; Get red value .
shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
out dx,al ; Send it .
mov al,[si+1] ; Get green value .
shr al,2
out dx,al ; Send it .
mov al,[si] ; Get blue value .
shr al,2
out dx,al ; Send it .
add si,4 ; Point to next color .
; (There is a null chr. after every color.)
loop PalLoop
ret
endp CopyPal

; ***************************************

; BMP graphics are saved upside-down .
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
CopyBitmap proc 
mov ax, 0A000h
mov es, ax
mov cx,200
PrintBMPLoop :
push cx
; di = cx*320, point to the correct screen line
mov di,cx
shl cx,6
shl di,8
add di,cx
; Read one line
mov ah,3fh
mov cx,320
mov dx,offset ScrLine
int 21h
; Copy one line into video memory
cld ; Clear direction flag, for movsb
mov cx,320
mov si,offset ScrLine
rep movsb ; Copy line to the screen
pop cx
loop PrintBMPLoop
ret
endp CopyBitmap


exit_input:
call end_graphics

mov ax, 4c00h
int 21h

; ***************************************

; Main program
Main_Program proc 
push ax
push bx
push cx
push dx

call random ; making a random number between 1-255
call display_number ; printing the number if the user wants to

mov al, 0
mov bx, 0
mov cx, 0 ; cx = counter

checking_something:
	mov di, offset numbers
Main:
	call print_new_line
	mov dx, offset input ; Getting a guess from the user
	mov ah, 9
	int 21h           
	call Main_Checking_Input ; Call the main checking input program
	inc cx
	cmp cx, 10 ; Up to 10 guesses
	je end_game
	
	yes:
	cmp [status], "w" ; w for win
	jne Main
	
	mov dx, offset win
	mov ah, 9
	int 21h
	
	call print_new_line
	call print_new_line
	
	mov dx, offset tries_str ; printing the amount of tries
	mov ah, 9
	int 21h
	
	call num_to_str
	
	call print_new_line
	
	; Delay of 2 seconds
	call sec_clock
	call sec_clock
	call sec_clock
	call sec_clock
	call sec_clock
	
	call won_graphics ; Starting the winning graphic
	call clear_array
	
	; Loop for checking if the user wants to play again
	myReplayLoop:
		mov bl, 0
		call print_new_line
		; Asking the player if he wants to play again
		mov dx, offset again 
		mov ah, 9
		int 21h
		
		; Input - y for yes, n for no
		mov ah, 1
		int 21h
		
		call print_new_line
		
		cmp al, 'y'
		jne check
		; The player typed y, resetting the variables
		mov cx, 0
		mov [status], 'l'
		call random
		call display_number
		call clear_array
		jmp checking_something
		check:
		cmp al, 'n'
		je ending_game ; The player typed n, the game is over
		; The player typed an ivalid input, he need to type until it's y or n
		mov dx, offset try_again
		mov ah, 9
		int 21h
		jmp myReplayLoop
		
	
end_game:
mov ah, 0
mov al, [correct_number]
cmp [guessed_number_int], ax
je yes ; The guessed number is correct
mov dx, offset lose ; Te guessed number isn't correct - the player lost
mov ah, 9
int 21h

call print_new_line
call print_new_line

mov dx, offset lose_msg
mov ah, 9
int 21h

call correct_number_print

; Delay of 2 seconds
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock
	
; Lost graphics
call lost_graphics
; Resetting the array of guesses
call clear_array

jmp myReplayLoop

ending_game:
pop dx
pop cx
pop bx
pop ax
ret 
endp Main_Program

; ***************************************

; Main checking input program
Main_Checking_Input proc 
push ax
push bx
push cx
push dx
push si


mov bx, offset guessed_number
mov cx, 0 ; counter

; Main loop
myLoop:
	mov ah, 1 ;l input a char until the char is a space - ' '
	int 21h
	cmp al, ' '
	je cont
	mov [bx], al ; adding it to a variable
	inc bx
	inc cx
	cmp al, '0'
	jl invalid_input ; input is smaller than 0 - invalid
	cmp al, '9'
	jg invalid_input ; input is bigger than 9 - invalid
	cont:
	cmp al, ' '
	je nexting ; end of input
	cmp cx, 3 ; up to 3 digits
	je nexting
	jmp myLoop
	
nexting:
call str_to_num ; converting the guessed number from a string to a number
mov [guessed_number_int], si
cmp si, 0
jle out_range ; number is smaller or equal to 0 - out of range
call check_duplicates ; check for duplicates
mov [di], si
inc di
inc di
cmp si, 255
jg out_range ; number is bigger than 255 - out of range
jmp next


; if the guessed_number is out range 1-255
out_range:
	call print_new_line
	mov dx, offset range ; printing a message that the number is out of range
	mov ah, 9
	int 21h
	call print_new_line
	jmp end_proc


; if the input is invalid
invalid_input:
	call print_new_line
	mov dx, offset invalid ; printing a message that the number is invalid (not a digit)
	mov ah, 9
	int 21h
	call print_new_line
	jmp end_proc

; printing the guessed_number
next:
call print_new_line
mov ah, 0
mov al, [correct_number]
cmp [guessed_number_int], ax
jg bigger_than 
cmp [guessed_number_int], ax
jl smaller_than 
call equals
jmp end_proc
bigger_than:
call too_big ; the guessed number is bigger than the correct number
jmp end_proc
smaller_than:
call too_small ; the guessed number is smaller than the correct number

end_proc:
pop si
pop dx
pop cx
pop bx
pop ax
ret
endp Main_Checking_Input

; ***************************************

; if the guessed_number is bigger than the correct_number
too_big proc 
push ax
push bx
push cx
push dx

mov dx, offset bigger
mov ah, 9
int 21h

call print_new_line

pop dx
pop cx
pop bx
pop ax
ret
endp too_big

; ***************************************

; if the guessed_number is smaller than the correct_number
too_small proc 
push ax
push bx
push cx
push dx

mov dx, offset smaller
mov ah, 9
int 21h

call print_new_line

pop dx
pop cx
pop bx
pop ax
ret
endp too_small

; ***************************************

; if the guessed_number is equals to the correct_number
equals proc 
push ax
push bx
push cx
push dx

mov [status], "w" ; w for win
mov dx, offset correct
mov ah, 9
int 21h

call print_new_line

pop dx
pop cx
pop bx
pop ax
ret
endp equals

; ***************************************

; printing a new line
print_new_line proc 
push ax
push bx
push cx
push dx

mov dx, offset new_line
mov ah, 9
int 21h

pop dx
pop cx
pop bx
pop ax
ret
endp print_new_line

; ***************************************

; Checking for duplicates, for each round
check_duplicates proc 
push ax
push bx
push cx
push dx
push si

mov si, offset numbers
mov ax, [guessed_number_int]
mov cl, 0
myDuplicatesLoop:
	cmp [si], ax
	jne not_dup
	; Duplicates found
	call print_new_line
	mov dx, offset duplicate_msg ; printing a message
	mov ah, 9
	int 21h
	jmp end_dup
	not_dup:
	inc si
	inc si
	inc cl
	cmp cl, 10 ; array length = max amount of guessed = 10
	jne myDuplicatesLoop

end_dup:
pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp check_duplicates

; ***************************************

; Converting from string to int type for the guessed number
str_to_num proc 
push ax
push bx
push cx
push dx

mov bx, offset guessed_number
mov si, 0
myLooping:
	mov dl, cl
	mov al, 1
	myMulLoop: ; making a power
		cmp dl, 1
		je case
		mov dh, 10
		mul dh; ax = al * dh = 10 * 10
		dec dl
		cmp dl, 1
		jne myMulLoop
		jmp skip
	
	case:
	mov al, [bx]
	sub al, 30h ; sub 30h from a char to make it a digit
	mov ah, 0
	add si, ax
	jmp skiping
	skip:
	mov ch, [bx]
	sub ch, 30h
	mul ch
	add si, ax
	skiping:
	inc bx
	dec cl
	cmp cl, 0
	jne myLooping
	
pop dx
pop cx
pop bx
pop ax
ret
endp str_to_num

; ***************************************

; Converting from int type to string type for the amount of tries
num_to_str proc 
push ax
push bx
push cx
push dx
push si

mov [tries_int], cl
mov ax, cx
mov	bx,	10
mov	si, offset tries + 2
myNumLoop:	
	mov dx, 0
	div	bx ; getting each digit
	add	dl,	30h ; add 30h from a digit to make it a char
	mov	[si], dl ; adding the char to the string
	dec	si
    cmp	ax,	0
	jne	myNumLoop
	
inc si

; Printing the number of amount of tries
mov	ah,	9
mov	dx,	si
int	21h

pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp num_to_str

; ***************************************

; Checking if the number is out of range
end_range proc 
push ax
push cx
push dx

mov ax, 256 ; start
myCheckLoop:
	cmp [guessed_number_int], ax
	je sof
	inc ax
	jmp myCheckLoop

jmp ending

sof:
mov bx, 1

ending:
pop dx
pop cx
pop ax
ret
endp end_range

; ***************************************

; Asking the user for name, and input the name
username_func proc 
push ax
push bx
push cx
push dx

; Asking the user for a name
mov ah, 9h
mov dx, offset username_input
int 21h

mov bx, offset username 
mov cx, 0 ; counter
myUsernameLoop:
	mov ah, 1 ; input a char
	int 21h
	mov [bx], al ; adding it to a string
	inc bx
	inc cx
	cmp cx, 10 ; name up to 10 chars
	je sof_username_input
	cmp al, ' ' ; input stops at space - ' '
	jne myUsernameLoop
	
sof_username_input:
call print_new_line

; Welcome greeting for the user
mov ah, 9h
mov dx, offset welcome
int 21h

; Printing the user's name
mov dx, offset username
mov ah, 9
int 21h


call print_new_line

pop dx
pop cx
pop bx
pop ax
ret 
endp username_func

; ***************************************

; VIDEO MODE - Start, Help and Exit
start_computer_logo proc 
push ax
push cx
push dx

mov ax, 12h
int 10h

; Printing the computer logo - start, help or exit
lea dx, [computer_logo]
mov ah, 09h
int 21h

call sec_clock
call sec_clock

; Playing a sound for a few seconds
in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_c5] ; 1 - c5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_d5] ; 2 - d5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_e5] ; 3 - e5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

call sec_clock

mov ax, [note_f5] ; 4 - f5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_g5] ; 5 - g5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_a5] ; 6 - a5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_b5] ; 7 - b5
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_c6] ; 8 - c6
out 42h, al
mov al, ah
out 42h, al
call sec_clock
call sec_clock
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

; Waiting for key press
mov ah,00h
int 16h

cmp al, 's'   ; s/S for START
jne not_start
jmp start_sof
not_start:
cmp al, 'h'   ; h/H for HELP
jne not_help
call help_graphics
mov bx, 0
jmp start_sof
not_help:     ; e/E/other for EXIT
inc bx


start_sof:
; Returning to text mode
mov ah, 0
mov al, 2
int 10h

pop dx
pop cx
pop ax
ret 
endp start_computer_logo

; ***************************************

; HELP GRAPHICS - Logo, rules, good luck
help_graphics proc 
push ax
push bx
push cx
push dx

mov ax, 13h
int 10h
mov ah, 06h    ; Scroll up function
xor al, al     ; Clear entire screen
xor cx, cx     ; Upper left corner CH=row, CL=column
mov dx, 184FH  ; lower right corner DH=row, DL=column 
mov bh, 2Ah    ; Orange background color
int 10h

mov dl, 11   ;Column
mov dh, 5    ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; HELP logo
mov si, offset help_logo
myHelpLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myHelpLoop
	
call sec_clock
call sec_clock
call sec_clock
	
mov dl, 0    ;Column
mov dh, 10   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; HELP tries
mov si, offset help_tries
myHelpTriesLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myHelpTriesLoop
	
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock

mov dl, 0    ;Column
mov dh, 12   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; HELP guess
mov si, offset help_guess
myHelpGuessLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myHelpGuessLoop
	
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock

mov dl, 0   ;Column
mov dh, 14   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; HELP name
mov si, offset help_name
myHelpNameLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myHelpNameLoop
	
call sec_clock
call sec_clock
call sec_clock
call sec_clock
call sec_clock

mov dl, 14   ;Column
mov dh, 17   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; HELP GOOD LUCK
mov si, offset help_good_luck
myHelpGoodLuckLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myHelpGoodLuckLoop
	
call sec_clock
	
; MESSAGE to press any key to start the game
mov dl, 7    ;Column
mov dh, 20   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset press_key
myKeyPressNextLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myKeyPressNextLoop
	
; Waiting for key press
mov ah,00h
int 16h

pop dx
pop cx
pop bx
pop ax
ret 
endp help_graphics

; ***************************************

; THE GRAPHICS AT THE START - logo, credit, question marks and a message
start_graphics proc 
push ax
push bx
push cx
push dx

; Get the graphics mode
mov ax, 13h
int 10h

mov ah, 06h    ; Scroll up function
xor al, al     ; Clear entire screen
xor cx, cx     ; Upper left corner CH=row, CL=column
mov dx, 184FH  ; lower right corner DH=row, DL=column 
mov bh, 3Ah    ; Pink background color
int 10h

mov dl, 11   ;Column
mov dh, 10   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; GUESS THE NUMBER logo
mov si, offset game_name
myLogoLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myLogoLoop
	
mov dl, 10   ;Column
mov dh, 12   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; CREDIT
mov si, offset credit
myCreditLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myCreditLoop
	
; 5 QUESTION MARKS in different places
; #1
mov dl, 2    ;Column
mov dh, 2    ;Row
myQuestionMarkLoop:
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h
call question_mark

; #2
mov dl, 20   ;Column
mov dh, 5    ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h
call question_mark

; #3
mov dl, 35
mov dh, 3
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h
call question_mark

; #4	
mov dl, 4    ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h
call question_mark

; #5	
mov dl, 32   ;Column
mov dh, 13   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h
call question_mark

; MESSAGE to press any key to start the game
mov dl, 7    ;Column
mov dh, 20   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset press_key
myKeyPressLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myKeyPressLoop

; Waiting for key press
mov ah,00h
int 16h

call sec_clock
call sec_clock
call sec_clock
; Display a smiley photo
call OpenFile
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
call sec_clock
call sec_clock

; Waiting for key press
mov ah,00h
int 16h

; Returning to text mode
mov ah, 0
mov al, 2
int 10h

pop dx
pop cx
pop bx
pop ax
ret 
endp start_graphics

; ***************************************

; WON GRAPHICS - Won logo, score
won_graphics proc 
push ax
push bx
push cx
push dx
push si

; Get the graphics mode
mov ax, 13h
int 10h

mov ah, 06h    ; Scroll up function
xor al, al     ; Clear entire screen
xor cx, cx     ; Upper left corner CH=row, CL=column
mov dx, 184FH  ; lower right corner DH=row, DL=column 
mov bh, 3Dh    ; Red background color
int 10h


mov dl, 14   ;Column
mov dh, 10   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; YOU WON :) logo
mov si, offset won
myWonLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myWonLoop

call sec_clock
call sec_clock
call sec_clock

mov dl, 13   ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; SCORE: logo
mov si, offset score_screen
myScoreLoop:
	mov  al, [si]
	mov  bl, 0Eh  ;Color is yellow
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myScoreLoop

call sec_clock

mov dl, 19   ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

call num_to_str_score
; [score_str]: logo
mov si, offset score_str
myScoreStrLoop:
	mov  al, [si]
	mov  bl, 0Eh  ;Color is yellow
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myScoreStrLoop

call sec_clock

; Playing a sound for a few seconds
in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_a5]
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_b5]
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_c6]
out 42h, al
mov al, ah
out 42h, al
call sec_clock
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

; MESSAGE to press any key to continue the game
mov dl, 6    ;Column
mov dh, 20   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset press_key_continue
myKeyPressContLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myKeyPressContLoop

; Waiting for key press
mov ah,00h
int 16h

; Returning to text mode
mov ah, 0
mov al, 2
int 10h

pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp won_graphics

; ***************************************

; LOST GRAPHICS - lost logo, score
lost_graphics proc 
push ax
push bx
push cx
push dx
push si

; Get the graphics mode
mov ax, 13h
int 10h

mov ah, 06h    ; Scroll up function
xor al, al     ; Clear entire screen
xor cx, cx     ; Upper left corner CH=row, CL=column
mov dx, 184FH  ; lower right corner DH=row, DL=column 
mov bh, 33h    ; Coral background color
int 10h

mov dl, 13   ;Column
mov dh, 10   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; YOU LOST :( logo
mov si, offset lost
myLostLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myLostLoop

call sec_clock
call sec_clock
call sec_clock

mov dl, 13   ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; SCORE: logo
mov si, offset score_screen
myScoreLostLoop:
	mov  al, [si]
	mov  bl, 0Eh  ;Color is yellow
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myScoreLostLoop

call sec_clock

mov dl, 19   ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h


; [score_str]: logo
mov si, offset score_str
myScoreStrLostLoop:
	mov  al, [si]
	mov  bl, 0Eh  ;Color is yellow
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myScoreStrLostLoop

call sec_clock

; Playing a sound for a few seconds
in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_e4]
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_d4]
out 42h, al
mov al, ah
out 42h, al
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

in al, 61h
or al, 00000011b
out 61h, al

mov ax, [note_c4]
out 42h, al
mov al, ah
out 42h, al
call sec_clock
call sec_clock
call sec_clock

in al, 61h
and al, 11111100b
out 61h, al

call sec_clock

; MESSAGE to press any key to continue the game
mov dl, 6    ;Column
mov dh, 20   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset press_key_continue
myKeyPressCont2Loop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myKeyPressCont2Loop

	
; Waiting for key press
mov ah,00h
int 16h

; Returning to text mode
mov ah, 0
mov al, 2
int 10h

pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp lost_graphics

; ***************************************

; THE GRAPHICS AT THE END - thank you for playing :) logo
end_graphics proc 
push ax
push bx
push cx
push dx

mov ax, 13h
int 10h

mov ah, 06h    ; Scroll up function
xor al, al     ; Clear entire screen
xor cx, cx     ; Upper left corner CH=row, CL=column
mov dx, 184FH  ; lower right corner DH=row, DL=column 
mov bh, 4Eh    ; Red background color
int 10h


mov dl, 8   ;Column
mov dh, 10   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

; THANK YOU FOR PLAYING logo
mov si, offset thanks_for_playing
myThanksLoop:
	call sec_clock
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myThanksLoop
	
call sec_clock
call sec_clock
	
; SMILEY :)
mov dl, 18    ;Column
mov dh, 15   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset smiley
mySmileyLoop:
	mov  al, [si]
	mov  bl, 0Eh  ;Color is pink
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne mySmileyLoop
	
call sec_clock
call sec_clock
	
; MESSAGE to press any key to exit the game
mov dl, 8    ;Column
mov dh, 20   ;Row
mov bh, 0    ;Display page
mov ah, 02h  ;SetCursorPosition
int 10h

mov si, offset press_key_exit
myKeyPressExitLoop:
	mov  al, [si]
	mov  bl, 0Fh  ;Color is white
	mov  bh, 0    ;Display page
	mov  ah, 0Eh  ;Teletype
	int  10h
	inc si
	mov cl, [si]
	cmp cl, '$'
	jne myKeyPressExitLoop
	


; Waiting for key press
mov ah,00h
int 16h

; Returning to text mode
mov ah, 0
mov al, 2
int 10h

pop dx
pop cx
pop bx
pop ax
ret 
endp end_graphics

; ***************************************

; 0.165 seconds CLOCK
sec_clock proc 
push ax
push bx
push cx
push dx

mov ax, 40h
mov es, ax
mov ax, [Clock]
FirstTick :
	cmp ax, [Clock]
	je FirstTick
	; count 0.165 sec
	mov cx, 3 ; 5x0.055sec = 0.165sec
DelayLoop:
	mov ax, [Clock]
	Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop

pop dx
pop cx
pop bx
pop ax
ret 
endp sec_clock

; ***************************************

; Converting the correct number to a string and printing it
correct_number_print proc 
push ax
push bx
push cx
push dx
push si

	mov ah, 0
	mov	al,	[correct_number]
	mov	bx,	10
	mov	si,	offset correct_number_str+2

next_next:	
	mov dx,0
	div	bx
	add	dl,	30h ; add 30h from a digit to a char
	mov	[si], dl
	dec	si
    cmp	ax,	0
	jne	next_next
	
	inc si
	; Printing the correct number
	mov	ah,	9
	mov	dx,	si
	int	21h
	call print_new_line
	
	
pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp correct_number_print

; ***************************************

; Printing a question mark
question_mark proc 
push ax
push bx
push cx
push dx

call sec_clock
; Printing a '?' in graphic mode
mov  al, '?'
mov  bl, 0Dh  ;Color is white
mov  bh, 0    ;Display page
mov  ah, 0Eh  ;Teletype
int  10h

pop dx
pop cx
pop bx
pop ax
ret 
endp question_mark

; ***************************************

; Asking the user if he wants to see the correct number, and input
display_number proc 
push ax
push bx
push cx
push dx

myCheckInputLoop:
		; Ask the user
		mov dx, offset show_number
		mov ah, 9
		int 21h
		
		; input a char
		mov ah, 1
		int 21h
		
		call print_new_line
		
		cmp al, 'y'
		jne checking
		mov dx, offset number_str ; user typed y - yes
		mov ah, 9
		int 21h
		call correct_number_print ; display the correct number
		jmp end_check
		checking:
		cmp al, 'n'
		je end_check ; user typed n - no
		mov dx, offset try_again ; user typed invalid char - type again until it's y or n
		mov ah, 9
		int 21h
		call print_new_line
		jmp myCheckInputLoop
	

end_check:
pop dx
pop cx
pop bx
pop ax
ret 
endp display_number

; ***************************************

; Calculating the score for each round - depending on the amount of tries
score_calculate proc 
push ax
push bx
push cx
push dx

; Formula : (11 - amount of tries) * 10 = score
mov ah, [tries_int]
mov al, 11
sub al, ah
mov bl, 10
mul bl
add [score], ax ; adding the score to a variable thats sum all the scores from every round

pop dx
pop cx
pop bx
pop ax
ret 
endp score_calculate

; ***************************************

; Converting from num to str in SCORE
num_to_str_score proc 
push ax
push bx
push cx
push dx
push si

call score_calculate
mov ax, [score]
mov	bx,	10
mov	si, offset score_str + 4
myNum2Loop:	
	mov dx, 0
	div	bx
	add	dl,	30h ; add 30h from a digit to a char
	mov	[si], dl
	dec	si
    cmp	ax,	0
	jne	myNum2Loop

pop si
pop dx
pop cx
pop bx
pop ax
ret 
endp num_to_str_score

; ***************************************

; Clearing the array, every time a round ends
clear_array proc 
push ax
push bx
push cx
push dx

mov bx, offset numbers
mov cl, 0 ; counter
mov ax, ? ; ? is nothing
myClearLoop:
	mov [bx], ax
	inc bx
	inc bx
	inc cl
	cmp cl, 10
	jne myClearLoop

pop dx
pop cx
pop bx
pop ax
ret 
endp clear_array

; ***************************************

; Making a random number between 1-255
random proc 
push ax
mov bx, [bx_saver]
mov ax, 40h
mov es, ax
mov ax, [es:6Ch]
xor ax, [bx]
add [bx_saver], ax
and al, 0FFh ; 0FFh is 255
mov [correct_number], al ; setting the correct number
pop ax
ret
endp random


END start


