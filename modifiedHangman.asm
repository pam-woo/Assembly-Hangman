.model small
.stack 100h




.data
    ; Menu messages
    title_msg db 13,10,'  -----------------------------------------',13,10
             db '  |             RIYAL OR PAKE             |',13,10
             db '  -----------------------------------------',13,10,13,10
             db '  [1] Start Game',13,10
             db '  [2] Game Mechanics',13,10
             db '  [3] Exit',13,10,13,10,'Select: $'




    ; Mechanics
    mech db 13,10,'===== GAME MECHANICS =====',13,10,13,10
         db 'HOW TO PLAY:',13,10
         db '1. Riyal or Pake is a two-player game',13,10
         db '2. Players take turns giving words and guessing',13,10
         db '3. Word giver enters secret word (max 20 letters)',13,10
         db '4. The other player will be a guesser and will be given 6 lives',13,10
         db '5. Each wrong guess of letter removes one life',13,10
         db '6. Losing one life will gradually reveal a body part of the hangman',13,10
         db '7. Right guess of letter will reveal its placement in the word',13,10
         db '8. Guesser wins by completing the word before running out of lives',13,10
         db '9. Word giver wins if guesser runs out of lives',13,10
         db '10. First to win majority of rounds wins!',13,10
         db '11. BONUS: Two consecutive correct guesses grant an extra life!',13,10,13,10
         db 'Return? (Y/N): $'




    ; Round selection
    rounds db 13,10,'SELECT ROUNDS:',13,10
           db '  [1] Best of 3 (First to 2)',13,10
           db '  [2] Best of 5 (First to 3)',13,10
           db '  [3] Best of 7 (First to 4)',13,10
           db '  [4] Back to Menu',13,10,13,10
           db 'Select: $'




    ; Game messages
    p1_word db 13,10,'Player 1: Enter word (max 20): $'
    p2_word db 13,10,'Player 2: Enter word (max 20): $'
    p2_play db 13,10,'Player 2: Start guessing!',13,10,'$'
    p1_play db 13,10,'Player 1: Start guessing!',13,10,'$'
    round_msg db 13,10,'===== ROUND $'
    word_msg db 13,10,'Word: $'
    guess_msg db 13,10,'Letter: $'
    lives_msg db 13,10,'Lives: $'
    guessed_msg db 13,10,'Guessed: $'
    correct db ' - Correct!$'
    wrong db ' - Wrong!$'
    already db ' - Already guessed!$'
    bonus_msg db ' - BONUS: Extra life awarded!$'
    p1_win db 13,10,13,10,'*** Player 1 wins this round! ***',13,10,'$'
    p2_win db 13,10,13,10,'*** Player 2 wins this round! ***',13,10,'$'
    word_was db 13,10,'Word was: $'
    score_msg db 13,10,'SCORES: P1=$'
    score_p2 db ' P2=$'
    p1_champ db 13,10,13,10,'*** PLAYER 1 WINS GAME! ***',13,10,'$'
    p2_champ db 13,10,13,10,'*** PLAYER 2 WINS GAME! ***',13,10,'$'
    continue_msg db 13,10,'Continue? (Y/N): $'
    again_msg db 13,10,'Play again? (Y/N): $'
    thanks db 13,10,'Thanks for playing!',13,10,'$'
    invalid db 13,10,'Invalid! Try again.',13,10,'$'




    ; Game variables
    secret_word db 21 dup('$')
    display_word db 21 dup('$')
    word_length dw 0
    lives db 3
    guessed db 26 dup(0)
    p1_score db 0
    p2_score db 0
    round_num db 1
    giver db 1
    max_rounds db 5
    win_need db 3
    consecutive_correct db 0




    ; Hangman lines
    h1 db 13,10,'  +---+',13,10,'  |   |',13,10,'$'
    h_empty db '      |',13,10,'$'
    h_head db '  O   |',13,10,'$'
    h_body db '  |   |',13,10,'$'
    h_larm db ' /|   |',13,10,'$'
    h_arms db ' /|\  |',13,10,'$'
    h_lleg db ' /    |',13,10,'$'
    h_legs db ' / \  |',13,10,'$'
    h_base db '      |',13,10,'=========',13,10,'$'




    ; Hints
    hint_text db 51 dup('$')
    hint_msg db 13,10,'HINT: $'
    hint_prompt db 13,10,'Enter hint (max 50): $'




.code
main proc
    mov ax,@data
    mov ds,ax




menu:
    call clear
    lea dx,title_msg
    call print
    call input
    cmp al,'1'
    je go_sel_rounds
    cmp al,'2'
    je go_show_mech
    cmp al,'3'
    je go_exit
    jmp inv_opt




go_sel_rounds:
    jmp sel_rounds




go_show_mech:
    jmp show_mech




go_exit:
    jmp do_exit




inv_opt:
    lea dx,invalid
    call print
    jmp menu




show_mech:
    call clear
    lea dx,mech
    call print
    call yn_input
    cmp al,'Y'
    je go_menu3
    jmp do_exit




go_menu3:
    jmp menu




sel_rounds:
    call clear
    lea dx,rounds
    call print
    call input
    cmp al,'1'
    je set3
    cmp al,'2'
    je set5
    cmp al,'3'
    je set7
    cmp al,'4'
    je menu
    lea dx,invalid
    call print
    jmp sel_rounds




set3:
    mov max_rounds,3
    mov win_need,2
    jmp new_game




set5:
    mov max_rounds,5
    mov win_need,3
    jmp new_game




set7:
    mov max_rounds,7
    mov win_need,4




new_game:
    mov p1_score,0
    mov p2_score,0
    mov round_num,1
    mov giver,1
    jmp start_round




do_exit:
    call clear
    lea dx,thanks
    call print
    mov ah,4Ch
    int 21h




main endp




game_proc proc




start_round:
    call clear
    lea dx, round_msg
    call print
    mov al, round_num
    call print_num
    mov dl, 13
    call putchar
    mov dl, 10
    call putchar
    call init
    mov al, giver
    cmp al, 1
    jne p2_give
    jmp p1_give




p2_give:
    lea dx, p2_word
    call print
    call get_word
    call clear
    lea dx, p1_play
    call print
    jmp play




p1_give:
    lea dx, p1_word
    call print
    call get_word
    call clear
    lea dx, p2_play
    call print




play:
    call draw_hang
    call show_word
   
    lea dx, lives_msg
    call print
    mov al, lives
    call print_num
   
    cmp lives, 2
    jg skip_hint
    lea dx, hint_msg
    call print
    lea dx, hint_text
    call print
skip_hint:
   
    call show_guessed
   
    call check_win
    cmp al, 1
    jne chk_lose
    jmp win_round




chk_lose:
    cmp lives, 0
    jne get_guess
    jmp lose_round




get_guess:
    lea dx, guess_msg
    call print
    call input
    call proc_guess
    jmp play




win_round:
    call show_word
    mov al, giver
    cmp al, 1
    je p1_gave_p2_won
    jmp p2_gave_p1_won




p1_gave_p2_won:
    inc p2_score
    lea dx, p2_win
    call print
    jmp check_game




p2_gave_p1_won:
    inc p1_score
    lea dx, p1_win
    call print
    jmp check_game




lose_round:
    call draw_hang
    mov al, giver
    cmp al, 1
    je p1_gave_p2_lost
    jmp p2_gave_p1_lost




p1_gave_p2_lost:
    inc p1_score
    lea dx, p1_win
    call print
    jmp show_answer




p2_gave_p1_lost:
    inc p2_score
    lea dx, p2_win
    call print




show_answer:
    lea dx, word_was
    call print
    lea dx, secret_word
    call print




check_game:
    call show_score
    mov al, p1_score
    cmp al, win_need
    jb chk_p2
    jmp p1_champ_win




chk_p2:
    mov al, p2_score
    cmp al, win_need
    jb chk_max
    jmp p2_champ_win




chk_max:
    mov al, round_num
    cmp al, max_rounds
    jl cont_round
    jmp final_win




cont_round:
    inc round_num
    xor giver, 3
    lea dx, continue_msg
    call print
    call yn_input
    cmp al, 'Y'
    jne go_menu1
    jmp start_round




go_menu1:
    jmp menu




final_win:
    mov al, p1_score
    cmp al, p2_score
    jle final_p2
    jmp p1_champ_win




final_p2:
    jmp p2_champ_win




p2_champ_win:
    lea dx, p2_champ
    call print
    jmp ask_again




p1_champ_win:
    lea dx, p1_champ
    call print




ask_again:
    lea dx, again_msg
    call print
    call yn_input
    cmp al, 'Y'
    jne go_menu2
    jmp sel_rounds




go_menu2:
    jmp menu




game_proc endp




init proc
    mov lives, 6
    mov consecutive_correct, 0
    mov cx, 21
    lea di, secret_word
    mov al, '$'
c1: mov [di], al
    inc di
    loop c1
   
    mov cx, 21
    lea di, display_word
c2: mov [di], al
    inc di
    loop c2
   
    mov cx, 26
    lea di, guessed
    xor al, al
c3: mov [di], al
    inc di
    loop c3
   
    mov cx, 51
    lea di, hint_text
    mov al, '$'
clear_hint:
    mov [di], al
    inc di
    loop clear_hint
   
    mov word_length, 0
    ret
init endp




get_word proc
    lea si, secret_word
    xor cx, cx
gw1:
    mov ah, 08h
    int 21h
    cmp al, 13
    je gw_done
    cmp al, 8
    je gw_back
    cmp cx, 20
    jge gw1
    cmp al, 'a'
    jb gw_up
    cmp al, 'z'
    ja gw_up
    and al, 0DFh
gw_up:
    cmp al, 'A'
    jb gw1
    cmp al, 'Z'
    ja gw1
    mov [si], al
    inc si
    inc cx
    push ax
    mov dl, '*'
    mov ah, 02h
    int 21h
    pop ax
    jmp gw1




gw_back:
    cmp cx, 0
    je gw1
    dec si
    dec cx
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 8
    int 21h
    jmp gw1




gw_done:
    cmp cx, 0
    je gw1
    mov byte ptr [si], '$'
    mov word_length, cx
   
    lea dx, hint_prompt
    call print
    call get_hint
   
    lea si, display_word
    mov cx, word_length
gw_init:
    mov byte ptr [si], '_'
    inc si
    loop gw_init
    mov byte ptr [si], '$'
    ret
get_word endp




get_hint proc
    lea si, hint_text
    xor cx, cx
gh1:
    mov ah, 08h
    int 21h
    cmp al, 13
    je gh_done
    cmp al, 8
    je gh_back
    cmp cx, 50
    jge gh1
   
    cmp al, 32
    jb gh1
    cmp al, 126
    ja gh1
   
    mov [si], al
    inc si
    inc cx
   
    push ax
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    jmp gh1
   
gh_back:
    cmp cx, 0
    je gh1
    dec si
    dec cx
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 8
    int 21h
    jmp gh1
   
gh_done:
    cmp cx, 0
    je gh1
    mov byte ptr [si], '$'
    ret
get_hint endp




show_word proc
    lea dx, word_msg
    call print
    lea si, display_word
    mov cx, word_length
sw1:
    mov dl, [si]
    call putchar
    mov dl, ' '
    call putchar
    inc si
    loop sw1
    ret
show_word endp




show_guessed proc
    lea dx, guessed_msg
    call print
    lea si, guessed
    mov cx, 26
    mov bl, 'A'
sg_loop:
    cmp byte ptr [si], 1
    jne sg_next
    mov dl, bl
    call putchar
    mov dl, ' '
    call putchar
sg_next:
    inc si
    inc bl
    loop sg_loop
    ret
show_guessed endp




proc_guess proc
    push ax
    cmp al, 'A'
    jb pg_inv
    cmp al, 'Z'
    ja pg_inv
    sub al, 'A'
    xor bh, bh
    mov bl, al
    lea si, guessed
    add si, bx
    cmp byte ptr [si], 1
    je pg_dup
    mov byte ptr [si], 1
    pop ax
    push ax
    lea si, secret_word
    lea di, display_word
    mov cx, word_length
    mov bl, 0
pg_chk:
    cmp al, [si]
    jne pg_next
    mov [di], al
    mov bl, 1
pg_next:
    inc si
    inc di
    loop pg_chk
    cmp bl, 1
    je pg_ok
    dec lives
    mov consecutive_correct, 0
    lea dx, wrong
    call print
    jmp pg_done




pg_ok:
    inc consecutive_correct
    cmp consecutive_correct, 2
    jne pg_ok_no_bonus
    mov consecutive_correct, 0
    inc lives
    lea dx, bonus_msg
    call print
    jmp pg_done
pg_ok_no_bonus:
    lea dx, correct
    call print
    jmp pg_done




pg_dup:
    mov consecutive_correct, 0
    lea dx, already
    call print
    pop ax
    ret




pg_inv:
    pop ax
    ret




pg_done:
    pop ax
    ret
proc_guess endp




check_win proc
    lea si, display_word
    mov cx, word_length
cw1:
    cmp byte ptr [si], '_'
    je cw_no
    inc si
    loop cw1
    mov al, 1
    ret
cw_no:
    mov al, 0
    ret
check_win endp




draw_hang proc
    lea dx, h1
    call print
    mov al, lives
    cmp al, 5
    jg dh1
    lea dx, h_head
    jmp dh2
dh1:
    lea dx, h_empty
dh2:
    call print
    mov al, lives
    cmp al, 4
    jg dh3
    cmp al, 3
    jg dh4
    cmp al, 2
    jg dh5
    lea dx, h_arms
    jmp dh6
dh3:
    lea dx, h_empty
    jmp dh6
dh4:
    lea dx, h_body
    jmp dh6
dh5:
    lea dx, h_larm
dh6:
    call print
    mov al, lives
    cmp al, 1
    jg dh7
    cmp al, 0
    jg dh8
    lea dx, h_legs
    jmp dh9
dh7:
    lea dx, h_empty
    jmp dh9
dh8:
    lea dx, h_lleg
dh9:
    call print
    lea dx, h_base
    call print
    ret
draw_hang endp




show_score proc
    lea dx, score_msg
    call print
    mov al, p1_score
    call print_num
    lea dx, score_p2
    call print
    mov al, p2_score
    call print_num
    ret
show_score endp




print_num proc
    push ax
    push dx
    xor ah, ah
    mov dl, 10
    div dl
    push ax
    cmp al, 0
    je pn_ones
    add al, '0'
    mov dl, al
    call putchar
pn_ones:
    pop ax
    mov al, ah
    add al, '0'
    mov dl, al
    call putchar
    pop dx
    pop ax
    ret
print_num endp




clear proc
    mov ah, 06h
    xor al, al
    mov bh, 07h
    xor cx, cx
    mov dx, 184Fh
    int 10h
    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h
    ret
clear endp




print proc
    mov ah, 09h
    int 21h
    ret
print endp




input proc
    mov ah, 01h
    int 21h
    cmp al, 'a'
    jb in1
    cmp al, 'z'
    ja in1
    and al, 0DFh
in1:
    ret
input endp




putchar proc
    mov ah, 02h
    int 21h
    ret
putchar endp




yn_input proc
yn_loop:
    call input
    cmp al, 'a'
    jb yn_check
    cmp al, 'z'
    ja yn_check
    and al, 0DFh
yn_check:
    cmp al, 'Y'
    je yn_valid
    cmp al, 'N'
    je yn_valid
    push ax
    lea dx, invalid
    call print
    pop ax
    jmp yn_loop
yn_valid:
    ret
yn_input endp




end main

; MODIFICATIONS / ADDITIONS (from original)

; Hints feature added
; hint_text db 51 dup('$')                			; Stores hint entered by word giver
; hint_msg db 13,10,'HINT: $'             			; Message shown when hint is displayed
; hint_prompt db 13,10,'Enter hint (max 50): $' 	; Prompt for player to enter hint

; Guessed letters feature added
; guessed db 26 dup(0)                   			; Array to track guessed letters
; guessed_msg db 13,10,'Guessed: $'    		        ; Message to display letters guessed

; Game flow / score improvements
; p1_score db 0                           			; Player 1 score
; p2_score db 0                           			; Player 2 score
; round_num db 1                          			; Current round
; max_rounds db 5                         			; Max rounds (based on selection)
; win_need db 3                           			; Number of wins needed to win game

; Input handling improvements
; get_word and get_hint now include:
; - Backspace handling
; - Masked input for secret word
; - Input length validation
; - Hint entry limited to 50 characters

; play procedure enhancements
; - Shows guessed letters using show_guessed
; - Displays hint when lives <= 2
; - Correct/wrong/already guessed feedback

; draw_hang modifications
; - Reveals body parts progressively based on lives remaining
; - Includes head, body, arms, legs (enhanced visual feedback)

; proc_guess modifications
; - Prevents duplicate guesses
; - Provides correct/incorrect feedback
; - Decrements lives on wrong guess
; - Converts input to uppercase

; New procedures
;show_guessed proc                        			; Shows letters already guessed
;get_hint proc                           			; Allows entry of hint for word

; CONSECUTIVE CORRECT BONUS FEATURE (NEW)
; consecutive_correct db 0                			; Tracks consecutive correct guesses
; bonus_msg db ' - BONUS: Extra life awarded!$'   ; Bonus life message

; Modified proc_guess procedure:
; - Increments consecutive_correct on correct guess
; - Resets counter on wrong guess or duplicate guess
; - When consecutive_correct reaches 2:
;   - Increments lives variable
;   - Resets counter to 0
;   - Displays bonus message instead of regular correct message

; Updated game mechanics message:
; - Added rule 11 explaining the bonus feature
