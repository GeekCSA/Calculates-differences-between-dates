data segment 
    MsgOpen             db "This program asks for two dates in yyyy-mm-dd format and " 
                        db 10,13,"calculates and prints the period in between these two dates."
                        db 10,13,10,13,"The period is reported in years, months and days"
                        db 10,13,"(including the first and last day).$"
    msg1                db 10,13,10,13,"Input first date  (yyyy-mm-dd): $"
    msg2                db 10,13,10,13,"Input second date (yyyy-mm-dd): $"
    IllegalInput        db 10,13,10,13,"You have to enter a digit between 0-9$"
    Msgcaution          db 10,13,10,13,"Incorrect input. Please enter a number according to the format yyyy or mm or dd.$"
    MsgAskAgine         db 10,13,10,13,9,"If you want to calculate again enter Y, if you don't want enter N: $"   
    MsgAns              db 10,13,10,13,9,"The difference between the two dates is: $"
    MsgYears            db " Years, $" 
    MsgMonths           db " Months, $"
    MsgDays             db " Days.$"
    NewLine             dw 10,13,10,13,"$" ; new line               
    temp                dw 0 ; This parameter is used to exchange between first and second dates depending on their order.
    tempD               dw 0 ; count of digits that were entered for Days   
    tempY               dw 0 ; count of digits that were entered for Years
    tempM               dw 0 ; count of digits that were entered for Months
    FirstYear           dw ? ; first year that was entered
    FirstMonth          dw ? ; first month that was entered
    FirstDay            dw ? ; first day that was entered
    SecondYear          dw ? ; second year that was entered
    SecondMonth         dw ? ; second month that was entered
    SecondDay           dw ? ; second day that was entered
    AnswerY             dw 0 ; number of years
    AnswerM             dw 0 ; number of months
    AnswerD             dw 0 ; number of days
    
ends                                                           
stack segment                                                  
    dw   128  dup(0)
ends
code segment
start:
       mov ax, data
       mov ds, ax           ; set segment registers:                                     
       mov es, ax
    
       lea  dx, MsgOpen 
       call PrintMsg
agine:
ErrorInFirstDate:        
       mov  SecondYear,0        ;\
       mov  SecondMonth,0       ; \    
       mov  tempY,0             ;  \ 
       mov  FirstMonth,0        ;   \
       mov  FirstYear,0         ;    \
       mov  tempM,0             ;     \
       mov  FirstDay,0          ;      \ 
       mov  SecondDay,0         ;       \
       mov  tempD,0             ;        \
       mov  AnswerD,0           ;         >Initialize variables 
       mov  AnswerM,0           ;        /
       mov  AnswerY,0           ;       /
       mov  temp,0              ;      /
       mov  ax,0                ;     /
       mov  bx,0                ;    /
       mov  cx,0                ;   /
       mov  dx,0                ;  /
       mov  si,0                ; /
       mov  di,0                ;/
    
       lea  dx, msg1            ; 
       call PrintMsg            ; Print message "Input the first date"
    
       push tempM        
       push FirstMonth    
       push FirstYear      
       push tempY        
       push SecondMonth  
       push SecondYear   
            
       call InputDate           ; Function to read the year and the month for the first date
                          
       mov  SecondYear,di       ;\
       mov  SecondMonth,si      ; \    
       mov  tempY,dx            ;  \ Transfer the values from the register into the appropriate variable
       mov  FirstYear,cx        ;  /
       mov  FirstMonth,bx       ; /  
       mov  tempM,ax            ;/ 
     
       mov  dx,'-'              ;\
       mov  ah,2                ; > Print '-' after number of month
       int  21h                 ;/
    
       push tempD
       push FirstDay    
       push SecondDay
       push SecondMonth  
       push SecondYear                  
       push FirstMonth   
       push FirstYear               
       push tempM
       mov  bp,sp       
    
       call InputbDayDate       ; Function to read the day for the first date 
    
       cmp  si,0                ;\ Flag of error in input of day 
       je   AllGoodOfFirstDay   ;/                    
       lea  dx, Msgcaution      ;\ Print error message
       call PrintMsg            ;/
       jmp  ErrorInFirstDate 
    
AllGoodOfFirstDay:                                        
       mov  tempD,ax            ;\ Transfer the values from the register into the appropriate variable
       mov  FirstDay,bx         ;/    
                                  
ErrorInSecondDate:
       mov  SecondYear,0        ;\
       mov  SecondMonth,0       ; \    
       mov  tempY,4             ;  \ Initialize variables of second date 
       mov  tempM,2             ;  /  
       mov  SecondDay,0         ; /
       mov  tempD,2             ;/
    
       lea  dx, msg2            ;\ Input the second date
       call PrintMsg            ;/ 
    
       push tempM        
       push FirstMonth   
       push FirstYear    
       push tempY         
       push SecondMonth  
       push SecondYear  
          
       call InputDate           ; Function to read the year and the month for the second date
    
       mov  SecondYear,di       ;\
       mov  SecondMonth,si      ; \    
       mov  tempY,dx            ;  \ Transfer the values from the register into the appropriate variable
       mov  FirstYear,cx        ;  /
       mov  FirstMonth,bx       ; /   
       mov  tempM,ax            ;/
     
       mov  dx,'-'              ;\
       mov  ah,2                ; > Print '-' after number of month
       int  21h                 ;/
    
       push tempD
       push FirstDay    
       push SecondDay
       push SecondMonth  
       push SecondYear                  
       push FirstMonth   
       push FirstYear               
       push tempM
       mov  bp,sp       
    
       call InputbDayDate
       cmp  si,0                ;\ Flag of error in input of day
       je   AllGoodOfSecondDay  ;/                
    
       lea  dx, Msgcaution      ;\ Print error message
       call PrintMsg            ;/
       jmp  ErrorInSecondDate
    
AllGoodOfSecondDay:                                        
       mov  tempD,ax            ;\ Transfer the values from the register into the appropriate variable
       mov  SecondDay,cx        ;/                                  
                           ;---------------------------------------------------------------------;          
                           ; The period between the two dates is calculated in Years+Months+Days ;
       push SecondMonth    ;---------------------------------------------------------------------;
       push SecondYear                  
       push FirstMonth    
       push FirstYear     
       push FirstDay     
       push SecondDay   
                                   
       call CalculateD          ; Function that calculates days
       mov  AnswerD,si          ; Transfer the values from the register into the appropriate variable
    
       mov  ax,FirstYear        ; FirstYear --> ax
       mov  bx,SecondYear       ; SecondYear --> bx
    
       cmp  ax , bx             ; Check to see if the first year is greater than the second year
       jge  skipToCalMonth       
       mov  ax,FirstMonth       ;\ 
       mov  bx,SecondMonth      ; \  
       mov  temp,ax             ;  \  
       mov  ax, bx              ;   > Exchange order of months if the first year is greater than the second year
       mov  bx, temp            ;  /
       mov  FirstMonth,ax       ; /
       mov  SecondMonth,bx      ;/
       cmp  dx,1                ; DX Get value from function "CalculateD"
       je   ItIsFullYear
                       
skipToCalMonth:
       push FirstYear   
       push SecondYear       
       push FirstMonth   
       push SecondMonth  
    
       call CalculateM          ; Function that calculates months
       mov  AnswerM,si          ; Transfer the values from the register into the appropriate variable
ItIsFullYear:   
       mov  ax,FirstYear        ; FirstYear --> ax
       mov  bx,SecondYear       ; SecondYear --> bx
                            
       cmp  ax , bx             ; Check to see if the first year >= second year
       jge  skipToCalYear      
       mov  temp,ax             ;\
       mov  ax, bx              ; \
       mov  bx, temp            ;  > If first year < second year 
       mov  FirstYear,ax        ; /  
       mov  SecondYear,bx       ;/
    
       mov  ax,FirstDay         ; FirstDay --> ax
       mov  bx,SecondDay        ; SecondDay --> bx 
       mov  temp,ax             ;\
       mov  ax,bx               ; \
       mov  bx,temp             ;  > If first year < second year
       mov  FirstDay,ax         ; /
       mov  SecondDay,bx        ;/
        
skipToCalYear:        
       push FirstYear    
       push SecondYear   
       push FirstMonth  
       push SecondMonth  
   
       call CalculateY          ; Function that calculates years    
       mov  AnswerY,si          ; Transfer the values from the register into the appropriate variable
    
       mov  ax,FirstYear        ; FirstYear --> ax
       mov  bx,SecondYear       ; SecondYear --> bx
       cmp  ax , bx             ; Check to see if the first year > second year
       jg   skipToCheckAnswerD      
       cmp  ax,bx               ;\
       je   YearEqale           ;/ Check to see if the first year = second year
       mov  temp,ax             ;\
       mov  ax, bx              ; \
       mov  bx, temp            ;  > If first year < second year 
       mov  FirstYear,ax        ; /  
       mov  SecondYear,bx       ;/
                         
       mov  ax,FirstMonth       ; FirstMonth --> ax
       mov  bx,SecondMonth      ; SecondMonth --> bx 
       mov  temp,ax             ;\    
       mov  ax, bx              ; \  
       mov  bx, temp            ;  > If first year < second year
       mov  FirstMonth,ax       ; /
       mov  SecondMonth,bx      ;/
    
       mov  ax,FirstDay         ; FirstDay --> ax
       mov  bx,SecondDay        ; SecondDay --> bx 
       mov  temp,ax             ;\
       mov  ax,bx               ; \
       mov  bx,temp             ;  > If first year < second year
       mov  FirstDay,ax         ; /
       mov  SecondDay,bx        ;/
    
YearEqale:
       mov  ax,FirstMonth       ; FirstMonth --> ax
       mov  bx,SecondMonth      ; SecondMonth --> bx 
       cmp  ax,bx               ;\ If First Month > second Month
       jg   MonthEqual          ;/
 
       mov  ax,FirstMonth       ;\ 
       mov  bx,SecondMonth      ; \  
       mov  temp,ax             ;  \  
       mov  ax, bx              ;   > If First Month <= second Month
       mov  bx, temp            ;  /
       mov  FirstMonth,ax       ; /
       mov  SecondMonth,bx      ;/
    
       mov  ax,FirstDay         ; FirstDay --> ax
       mov  bx,SecondDay        ; SecondDay --> bx
       mov  temp,ax             ;\
       mov  ax,bx               ; \ 
       mov  bx,temp             ;  > If First Month <= second Month
       mov  FirstDay,ax         ; /
       mov  SecondDay,bx        ;/
    
MonthEqual:
       mov  ax,FirstDay         ; FirstDay --> ax
       mov  bx,SecondDay        ; SecondDay --> bx
       cmp  ax,bx               ;\ Check to see if the first day > second day
       jg   skipToCheckAnswerD  ;/
       mov  temp,ax             ;\
       mov  ax,bx               ; \
       mov  bx,temp             ;  > If First day <= second day
       mov  FirstDay,ax         ; /
       mov  SecondDay,bx        ;/
        
skipToCheckAnswerD:                       
       push di                  ;DI Get value from function "CalculateD"
       push AnswerY
       push AnswerM
       push AnswerD     
       push FirstYear
       push FirstDay    
       push FirstMonth
    
       call CheckAnswerD,M,Y    ; Function that calculates years
       mov  AnswerY,cx          ;\
       mov  AnswerM,bx          ; > Transfer the values from the register into the appropriate variable
       mov  AnswerD,ax          ;/
    
ContinueToPrint: 
       lea  dx, MsgAns          
       call PrintMsg            
       mov  dx,AnswerY          ; dx <-- number of years
       call TypeNumber          ; print number of years
       lea  dx, MsgYears    
       call PrintMsg
       mov  dx,AnswerM          ; dx <-- number of months
       call TypeNumber          ; print number of months    
       lea  dx, MsgMonths    
       call PrintMsg
       mov  dx,AnswerD          ; dx <-- number of days
       call TypeNumber          ; print number of days
       lea  dx, MsgDays    
       call PrintMsg
       lea  dx, NewLine
       call PrintMsg                   
       lea  dx, MsgAskAgine
       call PrintMsg
    
IfExit:call InputDigit          ; Function that input digit
       cmp  al,'N'              ;\
       je   exit                ; \ If input N/n then the program end
       cmp  al,'n'              ; / 
       je   exit                ;/
       cmp  al,'Y'              ;\
       je   agine               ; \ If input Y/y then the program again
       cmp  al,'y'              ; /
       je   agine               ;/     
       lea  dx, MsgAskAgine
       call PrintMsg
       jmp  IfExit
     
exit: mov  ax, 4c00h          ; exit to operating system.
      int  21h    
               
    ;=================================================================  
    ; This procedure builds the number of year from the digits entered
    ; 
    ; al =  last digit that was entered in "InputDate"
    ; tempY      [bp] + 6 --> bx
    ; FirstYear  [bp] + 4
    ; SecondYear [bp] + 2 
    ;
    ; returns tempY by DX 
    ;         FirstYear by SI
    ;         SecondYear by DI
    ;=================================================================   
    
    year PROC  Near
         mov   bp, sp
         
         push  ax  
         push  bx
         push  cx  
                 
         xor   bx,bx         ; bx = 0
         xor   dx,dx         ; dx = 0 
         
         mov   bx, [bp] + 6  ; tempY --> bx
         
         inc   bx            ; Increase by 1 count of digits that were entered for years.
         
         xor   ah,ah         ; ah = 0
         sub   ax,'0'        ; Calculate the value of digit entered by subtracting ASCII code of zero.
         
         mov   dx,10         ; DX <-- 10  To multiply by 10 later
                          
         cmp   bx,4          ; Check to see whether 4 digits have been entered for "FirstYear" 
         jg    secondY         
         add   [bp] + 4,ax   ; add to "FirstYear" the new digit
         mov   ax,[bp] + 4
         cmp   cx,3          ; if CX = 3 means that this digit is the last digit of year. Therefore, it should not be multiplied by 10.
         je    next1
         mul   dx
   next1:mov   [bp] + 4,ax          
         jmp   end1Y               
 secondY:add   [bp] + 2,ax   ;\  
         mov   ax,[bp] + 2   ; \  
         cmp   cx,3          ;  \Same procedure as above for the "SecondYear". 
         je    next2         ;  /
         mul   dx            ; /
   next2:mov   [bp] + 2,ax   ;/
         je    end1Y
         mul   dx               
   end1Y:        
         mov   [bp] + 6,bx
         
         mov   dx,[bp] + 6   ; dx <-- tempY
         mov   si,[bp] + 4   ; si <-- FirstYear
         mov   di,[bp] + 2   ; di <-- SecondYear                 
         
         pop   cx
         pop   bx
         pop   ax
         
         ret   6
    year ENDP        
  
    ;=========================================================  
    ; This procedure builds the number of month from the digits entered
    ; 
    ; al =  last digit that was entered in "InputDate"
    ; tempM       [bp] + 6 --> bx
    ; FirstMonth  [bp] + 4
    ; SecondMonth [bp] + 2
    ;
    ; returns tempM by DX
    ;         FirstMonth by SI
    ;         SecondMonth by DI
    ;=========================================================  
    
   Month PROC  Near
         mov   bp, sp
         
         push  ax  
         push  bx
         push  cx  
         
         xor   bx,bx         ; bx = 0
         xor   dx,dx         ; dx = 0
         
         mov   bx, [bp] + 6  ; tempM --> bx
                             
         inc   bx            ; Increase by 1 count of digits that were entered for months.                     
         
         xor   ah,ah         ; ah = 0
         sub   ax,'0'        ; Calculate the value of digit entered by subtracting ASCII code of zero.
         
         mov   dx,10         ; DX <-- 10  To multiply by 10 later
                   
         cmp   bx,2          ; Check to see whether 2 digits have been entered for "FirstMonth"
         jg    secondM
         add   [bp] + 4,ax   ; add to "FirstYear" the new number
         mov   ax,[bp] + 4
         cmp   cx,6          ; if CX = 6 means that this digit is the last digit of month. Therefore, it should not be multiplied by 10.
         je    next6
         mul   dx
         mov   [bp] + 4,ax
   next6:jmp   end1M
 secondM:add   [bp] + 2,ax   ;\
         mov   ax,[bp] + 2   ; \
         cmp   cx,6          ;  \
         je    next6         ;   > Same procedure as above for the "SecondMonth".
         mov   dx,10         ;  /
         mul   dx            ; /
         mov   [bp] + 2,ax   ;/  
   end1M:mov   [bp] + 6,bx
         
         mov   dx,[bp] + 6   ; dx <-- tempM
         mov   si,[bp] + 4   ; si <-- FirstMonth
         mov   di,[bp] + 2   ; di <-- SecondMonth
         
         pop   cx
         pop   bx
         pop   ax
         
         ret   6
   Month ENDP        
      
    ;=========================================================
    ; The procedure assigns value to the variables of month       
    ; and year
    ;
    ; tempM      [bp] + 12 
    ; FirstMonth [bp] + 10
    ; FirstYear  [bp] + 8
    ; tempY      [bp] + 6 
    ; SecondMonth[bp] + 4
    ; SecondYear [bp] + 2 
    ;
    ; returns tempM by AX
    ;         FirstMonth by BX
    ;         FirstYear by CX
    ;         tempY by DX
    ;         SecondMonth by SI
    ;         SecondYear by DI
    ;=========================================================

    InputDate PROC NEAR
         mov   bp,sp 
         mov   bx,bp          ; The initial bp value is stored in bx
      
         xor   ax,ax          ; ax = 0
         xor   bx,bx          ; bx = 0
         xor   cx,cx          ; cx = 0
         xor   dx,dx          ; dx = 0       
              
         jmp   up
Illegal:       
         mov   bp,bx 
       
         lea   dx, Msgcaution ;\ Print error message
         call  PrintMsg       ;/
       
         cmp   [bp] + 12, 1   ;\ Check if the error is in the first or second date
         jg    ErrorIn2       ;/ If tempY is > 3 then error is in the second date and jump to "ErrorIn2".
       
         lea   dx, msg1       ;\ Print message asking for the first date.
         call  PrintMsg       ;/           
       
         mov   [bp] + 12,0    ;\
         mov   [bp] + 11,0    ; \
         mov   [bp] + 10,0    ;  \
         mov   [bp] + 8,0     ;  / When there is an error detected, initialize all variables
         mov   [bp] + 9,0     ; /
         mov   [bp] + 6,0     ;/
         mov   cx,0           ; cx --> 0 , to start the loop for input of digits.
         jmp   up       

ErrorIn2:lea   dx, msg2
          
         call  PrintMsg 
        
         mov   [bp] + 5,0     ;\     
         mov   [bp] + 4,0     ; \ When there is an error detected, initialize all variables
         mov   [bp] + 2,0     ; /
         mov   [bp] + 3,0     ;/
         mov   [bp] + 12,2    ;\ Initialize counter for digits for second date.
         mov   [bp] + 6,4     ;/
         mov   cx,0           ; cx --> 0 , to start the loop for input of digits.
                    
      up:mov   bx,bp
         mov   si,0           ; flag error for "ErrorFilter" that locate below
         cmp   cx,4
         je    stam
         call  InputDigit     ; Input digit
         cmp   al,'0'         ;\
         jl    Illegal        ; \check if the character is digit. If not, jump to Illegal
         cmp   al,'9'         ; /
         jg    Illegal        ;/   
         cmp   cx,4
         jg    DMonth
       

         push  [bp]+6        
         push  [bp]+8
         push  [bp]+2

         mov   bx,bp
       
         call  year           ; Construction of number of years for the 1st and 2nd date 

         mov   bp, bx       
       
         mov   [bp]+2,di      ;\
         mov   [bp]+8,si      ; > Fill the numbers that were built into the stack area assigned for 1st and 2nd year     
         mov   [bp]+6,dx      ;/
      
         jmp   skip
              
  DMonth:mov   bx,bp
         
       
         push  [bp]+12
         push  [bp]+10
         push  [bp]+4
          
         call  ErrorFilter    ;\
         cmp   si,1           ; > checks for errors in number of month 
         je    Illegal        ;/
         
         mov   bp, bx
       
         push  [bp]+12        
         push  [bp]+10
         push  [bp]+4
       
         call  Month          ; Construction of number of months for the 1st and 2nd date
       
         mov   bp, bx
      
         mov   [bp]+4 ,di     ;\
         mov   [bp]+10,si     ; > Fill the numbers that were built into the stack area assigned for 1st and 2nd month   
         mov   [bp]+12,dx     ;/
         
         jmp   skip
       
    stam:mov   dx,'-'         ;\
         mov   ah,2           ; > print '-' after month
         int   21h            ;/
  
    skip:inc   cx    
         cmp   cx,7
         jl    up
  
         mov   ax,[bp] + 12
         mov   bx,[bp] + 10
         mov   cx,[bp] + 8
         mov   dx,[bp] + 6
         mov   si,[bp] + 4
         mov   di,[bp] + 2  
       
         ret   12
    InputDate ENDP    
        
    ;===============================================================
    ; The procedure checks for errors in the number of months
    ;
    ; tempM = dx  [bp] + 6
    ; FirstMonth  = bx [bp] + 4
    ; SecondMonth = bx [bp] + 2
    ; cx = cx  count of loop
    ; ax = ax  digit that was entered
    ;
    ; returns the answer in SI:
    ;                   1) If found illegal input ==> SI = 1
    ;                   2) If did not found illegal input ==> SI = 0
    ;===============================================================
   
    ErrorFilter PROC NEAR
         mov   bp, sp 
        
         push  ax
         push  bx
         push  cx
         push  dx
       
         xor   bx,bx
         xor   dx,dx
       
         mov   dx,[bp] + 6          ; dx <-- tempM
   
         cmp   cx,5                 ; if cx = 5 then this digit is first digit in month
         je    Month_FirstDigit
         cmp   cx,6                 ; if cx = 6 then this digit is second digit in month
         je    Month_SecondDigit       
       
Month_FirstDigit:
         cmp   al,'0'               ;If this digit is first digit of the month it can only accept values between 0 and 1
         jl    Err1 
         cmp   al,'1'
         jg    Err1
         jmp   EndEr1
        
Month_SecondDigit:
         cmp   dx,2                 ;\
         jg    Month2               ; \
         mov   bx,[bp] + 4          ;  \ Check if it's first month or second month and transfer the desire value to bx
         jmp   skip1                ;  /
                                    ; /
  Month2:mov   bx,[bp] + 2          ;/     
   skip1:cmp   bx,0                 ; when first digit is zero
         je    zero
         cmp   bx,10                ; when first digit is one and after multiplication by 10
         je    one
         jmp   EndEr1
        
    zero:cmp   al,'1'               ;If digit is second digit of the month and first digit is zero, second digit can only accept values between 1 - 9
         jl    Err1 
         cmp   al,'9'        
         jg    Err1
         jmp   EndEr1
     one:cmp   al,'0'               ;If digit is second digit of the month, and first digit is one, second digit can only accept values between 0 - 2
         jl    Err1 
         cmp   al,'2'        
         jg    Err1           
         jmp   EndEr1                
    Err1:mov   si,1                 ;Found error therefore SI = 1
         jmp   EndIntegrityCheckOfTheInput
  EndEr1:xor   si,si                ; Did not find error therefore SI= 0
EndIntegrityCheckOfTheInput:  
         pop   dx                   
         pop   cx
         pop   bx
         pop   ax
         ret   6
    ErrorFilter ENDP                                                         
                                                        
    ;=========================================================
    ; The procedure assigns value to the variables of day
    ; 
    ; tempD         [bp] + 14
    ; FirstDay      [bp] + 12
    ; SecondDay     [bp] + 10 
    ; SecondMonth   [bp] + 8
    ; SecondYear    [bp] + 6
    ; FirstMonth    [bp] + 4 
    ; FirstYear     [bp] + 2
    ; tempM         [bp] 
    ;
    ; returns tempD by AX
    ;         FirstDay by BX
    ;         SecondDay by CX 
    ;         SI is a flag for error in number of days
    ;=========================================================                                                    
    
    InputbDayDate PROC NEAR                       
       
         xor   ax,ax                  ; ax = 0
         xor   bx,bx                  ; bx = 0
         xor   cx,cx                  ; cx = 0
         xor   dx,dx                  ; dx = 0 
       
         mov   cx,2
        ;-----------------------------------------------------------------------; 
        ; " 31 28 31 30 31 30 31 31 30 31 30 31 29 " - number of days in month  ;
        ;-----------------------------------------------------------------------;
       
 loopDay:call  InputDigit             ; Input digit
         cmp   al,'0'                 ;\
         jl    Illegal1               ; \check if the character is digit. If not, jump to Illegal
         cmp   al,'9'                 ; /
         jg    Illegal1               ;/       
                       
         mov   bx,bp
       
         push  [bp]+14
         push  [bp]+12
         push  [bp]+10       
         push  [bp]+8
         push  [bp]+6
         push  [bp]+4
         push  [bp]+2
          
         call  ErrorFilterOfDay       ;\
         cmp   si,1                   ; > checks for errors in number of month 
         je    Illegal1               ;/
       
         mov   bp, bx       
       
         xor   ah,ah                  ; AX = 0
         sub   al,'0'                 ;Subtract ASCII code of 0 from ASCII code of digit to obtain the digit, ex. h39-h30=9
         mov   dx,10                  ; DX <-- 10
 
         cmp   [bp] + 14,0            ; If tempD = 0 then this digit is the first digit of first day
         jg    NotFirstNumInFirstDay
       
         mul   dx                     ; Multiply first digit by 10 for decimal number
         mov   [bp] + 12,ax           ; AX contains the result
         jmp   EndThisNum
       
NotFirstNumInFirstDay:
         cmp   [bp] + 14,1            ; If tempD = 1 then this digit is the second digit of first day
         jg    NotSecondNumInFirstDay 
      
         add   [bp] + 12,al
         jmp   EndThisNum             ; Add the value of the second digit to the first digit after it was multipled by 10.
        
NotSecondNumInFirstDay:
         cmp   [bp] + 14,2            ; If tempD = 2 then this digit is the first digit of second day
         jg    NotFirstNumInSecondDay
       
         mul   dx                     ; Multiply first digit by 10 for decimal number
         mov   [bp] + 10,ax           ; AX contains the result
         jmp   EndThisNum
       
NotFirstNumInSecondDay:               ; this digit is the second digit of second day
         add   [bp] + 10,al           ; Add the value of the second digit to the first digit after it was multipled by 10.
              
EndThisNum:  
         inc   [bp] + 14              ; tempD = tempD + 1
      
         loop  loopDay 
         xor   si,si                  ; SI = 0 Error not found
         jmp   ExitFromThisProcedure
       
Illegal1:mov   si,1                   ; SI = 1 Error found, illegal input
       
ExitFromThisProcedure:
         mov   ax,[bp] + 14
         mov   bx,[bp] + 12
         mov   cx,[bp] + 10
      
         ret   8
    InputbDayDate ENDP
   
    ;===============================================================
    ; The procedure checks for errors in the number of days
    ;                
    ; tempD          [bp] + 14
    ; FirstDay       [bp] + 12
    ; SecondDay      [bp] + 10 
    ; SecondMonth    [bp] + 8
    ; SecondYear     [bp] + 6
    ; FirstMonth     [bp] + 4
    ; FirstYear      [bp] + 2
    ; ax = ax  digit that was entered
    ;
    ; returns the answer in SI: 
    ;                   1) If found illegal input ==> SI = 1
    ;                   2) If did not found illegal input ==> SI = 0
    ;===============================================================
   
    ErrorFilterOfDay PROC NEAR
         mov   bp, sp 
        
         push  ax
         push  bx
         push  cx
         push  dx
       
         xor   bx,bx         ; BX = 0
         xor   cx,cx         ; CX = 0
         xor   dx,dx         ; DX = 0
                
         cmp   [bp] + 14, 1  ; If tempD > 1 then this digit is relevant to SecondDay 
         jg    Day2          ; not jmap to other algoritem but enter other value in parameter
       
         mov   di,[bp] + 4   ;\
         mov   si,[bp] + 2   ; > Enter the values of first date (year, month and day) to register
         mov   cx,[bp] + 12  ;/
              
         jmp   checkD
       
    Day2:mov   di,[bp] + 8   ;\
         mov   si,[bp] + 6   ; > Enter the values of second date (year, month and day) to register
         mov   cx,[bp] + 10  ;/
                
  checkD:cmp   di,1          ;\
         je    N31           ; \
         cmp   di,3          ;  \
         je    N31           ;   \
         cmp   di,5          ;    \
         je    N31           ;     \
         cmp   di,7          ;      \ Check the month how many days have in this month.
         je    N31           ;      / In these months maximal days is 31
         cmp   di,8          ;     /
         je    N31           ;    /
         cmp   di,10         ;   /
         je    N31           ;  /
         cmp   di,12         ; /
         je    N31           ;/
       
         cmp   di,4          ;\
         je    N30           ; \
         cmp   di,6          ;  \
         je    N30           ;   \ Check the month how many days have in this month
         cmp   di,9          ;   / In these months maximal days is 30
         je    N30           ;  /
         cmp   di,11         ; /
         je    N30           ;/
       
         xor   bx,bx         ;\ Save the value of BP before entering to procedure
         mov   bx,bp         ;/
         mov   cx,si         ;\
         xor   si,si         ; \ Check if this year is LeapYear
         push  cx            ; /
         call  LeapYear      ;/
         cmp   si,0          ;\ If SI = 0 then this year in not LeapYear
         je    N28           ;/ If this year is not LeapYear then the maximal number of days in February is 28

         jmp   N29           ; If this year is LeapYear then the maximal number of days in February is 29
   
     N31:cmp   [bp] + 14,1   ;\
         je    digit_2_31    ; \ If tempD = 1 or 3 then this digit is second digit in number of day   
         cmp   [bp] + 14,3   ; /
         je    digit_2_31    ;/   
       
         cmp   al,'3'        ;\ If tempD = 0 or 2 then this digit is first digit in number of day.
         jg    error         ;/ This digit can not be more than 3
         
         jmp   corect       
       
digit_2_31:
         cmp   cx,01Eh       ;\ if CX (number of day) = 30 
         jl    corect        ;/ (If first digit is 0, 1 or 2 then second digit can be all digits)
       
         cmp   al,'0'        ;\
         je    corect        ; \ The second digit can only be 0 or 1
         cmp   al,'1'        ; /
         je    corect        ;/
       
         jmp   error                 
   
     N30:cmp   [bp] + 14,1   ;\
         je    digit_2_30    ; \ If tempD = 1 or 3 then this digit is second digit in number of day
         cmp   [bp] + 14,3   ; /
         je    digit_2_30    ;/   
      
         cmp   al,'3'        ;\ If tempD = 0 or 2 then this digit is first digit in number of day.
         jg    error         ;/ This digit can not be more than 3
              
         jmp   corect 
       
digit_2_30:              
         cmp   cx,01Eh       ;\ if CX (number of day) = 30
         jl    corect        ;/ (If first digit is 0, 1 or 2 then second digit can be all digits)
       
         cmp   al,'0'        ;\ The second digit can only be 0
         je    corect        ;/
       
         jmp   error
       
     N28:pop   cx
         mov   si,cx
         mov   bp,bx
       
         cmp   [bp] + 14,1   ;\
         je    digit_2_28    ; \ If tempD = 1 or 3 then this digit is second digit in number of day
         cmp   [bp] + 14,3   ; /
         je    digit_2_28    ;/  
      
         cmp   al,'2'        ;\ If tempD = 0 or 2 then this digit is first digit in number of day.
         jg    error         ;/ This digit can not be more than 2
       
         jmp   corect       
       
digit_2_28:             
         cmp   cx,014h       ;\ if CX (number of day) = 20
         jl    corect        ;/ (If first digit is 0 or 1 then second digit can be all digits)
       
         cmp   al,'8'        ;\ The second digit can not be more than 8
         jg    error         ;/     
   
         jmp   corect
       
     N29:pop   cx
         mov   si,cx
         mov   bp,bx
          
         cmp   [bp] + 14,1   ;\
         je    digit_2_29    ; \ If tempD = 1 or 3 then this digit is second digit in number of day
         cmp   [bp] + 14,3   ; /
         je    digit_2_29    ;/   
       
         cmp   al,'2'        ;\ If tempD = 0 or 2 then this digit is first digit in number of day.
         jg    error         ;/ This digit can not be more than 2
                
         jmp   corect         
       
digit_2_29:              
         cmp   cx,014h       ;\ if CX (number of day) = 20
         jl    corect        ;/ (If first digit is 0 or 1 then second digit can be all digits)
       
         cmp   al,'9'        ;\ The second digit can not be more than 9
         jg    error         ;/     
   
         jmp   corect                
                
   error:mov   si,1          ; If found illegal input then SI = 1.
         jmp   EndIntegrityCheck  
     
  corect:xor   si,si         ; SI = 0 did not find illegal input
EndIntegrityCheck:  
         pop   dx 
         pop   cx
         pop   bx
         pop   ax
         ret   14
    ErrorFilterOfDay ENDP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;=========================================================
    ; The procedure calculates the difference between the 
    ; two years
    ;
    ; FirstYear  [bp] + 8
    ; SecondYear [bp] + 6
    ; FirstMonth [bp] + 4
    ; SecondMonth[bp] + 2
    ;
    ; return the answer in SI
    ;=========================================================
   
    CalculateY PROC NEAR
         mov     bp, sp 
        
         push  ax
         push  bx
         push  cx
         push  dx
        
         xor   ax,ax
         xor   bx,bx
         xor   cx,cx
         xor   dx,dx
 
         mov   ax,[bp] + 8   ; ax <-- number of FirstYear
         mov   bx,[bp] + 6   ; bx <-- number of SecondYear
 
         sub   ax,bx         ; difference between the years 
         mov   si,ax   
       
         mov   cx,[bp] + 4   ; cx <-- FirstMonth
         mov   bx,[bp] + 2   ; bx <-- SecondMonth
         
         cmp   si,0
         je    EndCalY
         cmp   bx,cx         ;\
         jle   EndCalY       ; > if FirstMonth < SecondMonth then last year is not a full year. Thus, and need to subtract one year from "AnswerY" 
         sub   ax,1          ;/ 
         mov   si,ax     
       
 EndCalY:pop   dx
         pop   cx
         pop   bx
         pop   ax
       
         ret   8
    CalculateY ENDP
     
    ;===========================================================
    ; The procedure calculates the difference between the months
    ; 
    ; FirstYear   [bp] + 8 
    ; SecondYear  [bp] + 6
    ; FirstMonth  [bp] + 4
    ; SecondMonth [bp] + 2
    ;
    ; return the answer in SI       
    ;===========================================================
   
    CalculateM PROC NEAR
         mov   bp, sp
        
         push  ax
         push  bx
         push  cx
         push  dx
        
         xor   ax,ax
         xor   bx,bx
         xor   cx,cx
         xor   dx,dx 
       
         mov   cx,[bp] + 8
         mov   dx,[bp] + 6
         mov   ax,[bp] + 4   ; ax <-- number of firstmonth
         mov   bx,[bp] + 2   ; bx <-- number of secondmonth
       
         cmp   cx,dx         ; FirstYear = SecondYear
         je    FES

         cmp   ax,bx         ; firstmonth > secondmonth  
         jg    Greater
         cmp   ax,bx         ; firstmonth < secondmonth
         jl    Less
         mov   si,0          ; No difference between
         jmp   EndCalM       

 Greater:sub   ax,bx         ; difference between the months
         mov   si,ax   
         jmp   EndCalM
    Less:sub   bx,ax         ;\
         mov   ax,12         ; > Calculation for months
         sub   ax,bx         ;/ 
         jmp   ansM
     FES:cmp   ax,bx         ;  firstmonth < secondmonth
         jnl   Normal
         mov   bx,[bp] + 4   ; ax <-- number of firstmonth
         mov   ax,[bp] + 2         
       
  Normal:sub   ax,bx
                
    ansM:mov   si,ax
      
 EndCalM:pop   dx
         pop   cx
         pop   bx
         pop   ax
       
         ret   4
    CalculateM ENDP  
    
    ;====================================================
    ; The procedure calculates the difference between the 
    ; two days
    ;
    ; SecondMonth [bp] + 12
    ; SecondYear  [bp] + 10
    ; FirstMonth  [bp] + 8
    ; FirstYear   [bp] + 6
    ; FirstDay    [bp] + 4
    ; SecondDay   [bp] + 2 
    ;
    ; return the answer in SI       
    ;=====================================================
   
    CalculateD PROC NEAR
         mov   bp, sp
      
         push  ax
         push  bx
         push  cx
        
         xor   ax,ax
         xor   bx,bx
         xor   cx,cx
         xor   dx,dx
         ;--------------------;
         ; F ax,bx,cx - D,M,Y ;
         ; S dx,si,di - D,M,Y ;
         ;--------------------;
         mov   si,[bp] + 12
         mov   bx,[bp] + 8
         mov   dx,[bp] + 2
         mov   ax,[bp] + 4
         mov   cx,[bp] + 6
         mov   di,[bp] + 10
       
         cmp   bx,2                         ;\  If one year is leap year and month is 2 and days is 29 
         jne   NotFullYear                  ; \ and second year is not leap and its month is 2 and its days is 28
         cmp   si,2                         ; / then there is a difference of at least a full year
         jne   NotFullYear                  ;/
                                            ;
         push  bx                           ;
         mov   bx,bp                        ;
         push  cx                           ;\ Function that check if one of the two is LeapYear
         call  LeapYear                     ;/
         pop   cx                           ;
         mov   bp,bx                        ;
         pop   bx                           ;
         cmp   si,1                         ;
         jne   CheckOntherYearIfIsLeap      ;  
         cmp   ax,29                        ; If it is LeapYear then check if number of days is 29
         jne   NotFullYear                  ;
         push  si                           ;
         push  di                           ;
         call  LeapYear                     ; Function that check if second year is not LeapYear
         pop   di                           ;
         cmp   si,1                         ;
         je    NotFullYear+popSi            ;
         pop   si                           ;
         cmp   dx,28                        ; If second year is LeapYear then check if number of days is 28
         jmp   FullYear                     ;
                                            ;
CheckOntherYearIfIsLeap:                    ;
         cmp   ax,28                        ; If one of the two is not LeapYear then check if number of day is 28
         jne   NotFullYear                  ;
         push  si                           ;
         push  di                           ;
         call  LeapYear                     ; Function that check if second year is LeapYear
         pop   di                           ;
         cmp   si,1                         ;
         jne   NotFullYear+popSi            ;
         pop   si                           ;
         cmp   dx,29                        ; If number of day of second year (that second year is LeapYear) is 29 then this year is full year
         jne   NotFullYear                  ; If number of day of second year is not 29 then this year is not full year
         jmp   FullYear                     ;

NotFullYear+popSi:
         pop   si              
NotFullYear:                                ; If FirstYear < SecondYear then exchange between First and Second
         cmp   cx,di
         jl    ChangeDate
         cmp   cx,di                        ; If FirstYear = SecondYear then no need exchange between First and Second
         je    NotChangeYears_BetweenDate
         jmp   NotChange_BetweenDate
ChangeDate:        
         mov   si,[bp] + 8                  ;\
         mov   bx,[bp] + 12                 ; \
         mov   dx,[bp] + 4                  ;  \ Exchange between First and Second (Year, Month and Day)
         mov   ax,[bp] + 2                  ;  /
         mov   cx,[bp] + 10                 ; /
         mov   di,[bp] + 6                  ;/
         jmp   NotChange_BetweenDate
       
NotChangeYears_BetweenDate:
         cmp   cx,di                        ; If FirstYear != SecondYear 
         jne   NotChange_BetweenDate
         cmp   bx,si                        ; If FirstMonth >= SecondMonth
         jnl   NotChangeMonths_BetweenDate  
         mov   si,[bp] + 8                  ;\
         mov   bx,[bp] + 12                 ; \ Exchange between First and Second (Month, Day)
         mov   dx,[bp] + 4                  ; /
         mov   ax,[bp] + 2                  ;/
         jmp   NotChange_BetweenDate
               
NotChangeMonths_BetweenDate:
         cmp   ax,dx                        ;  If FirstDay >= SecondDay
         jnl   NotChange_BetweenDate
         mov   dx,[bp] + 4                  ;\ Exchange between First and Second (Day)
         mov   ax,[bp] + 2                  ;/
       
NotChange_BetweenDate:
         cmp   si,2                         ; If SecondMonth = 2 and --|
         jne   NoFab                        ; |--------<-----------<---|
         cmp   dx,29                        ; |-> If SecondDay = 29, then SecondDay = 1 and increment the SecondMonth by 1
         jne   NoFab                        ; The reason for this is to simplify computation of days. At the end of the computation I add 1 to the count of days.
                                            ; 
         inc   si                           ; SecondMonth = SecondMonth + 1
         mov   dx,1                         ; SecondDay = 1
         mov   di,1                         ; DI = 1

   NoFab:cmp   ax,dx                        ;\ If FirstDay = SecondDay then AnswerD = 0
         je    NumOfDaysIs0                 ;/
                                
         cmp   ax,dx                        ;\ 
         jng   continue1                    ; \
         xor   cx,cx                        ;  > If FirstDay > SecondDay then the calculation of AnswerD is:
         sub   ax,dx                        ; /  FirstDay - SecondDay.
         mov   cx,ax                        ;/
         jmp   ans                          
                 
continue1:                                  ; For the calculation (details below Lines 1231 - 1235)  
         cmp   bx,1                         ;\
         je    BxIsJan                      ; \ If FirstMonth > 1, then FirstMonth = FirstMonth - 1 
         sub   bx,1                         ; /
         jmp   SkipMov12                    ;/

 BxIsJan:mov   bx,12                        ;\ If FirstMonth = 1, then FirstMonth = 12 and subtract 1 from FirstYear 
         sub   cx,1                         ;/
SkipMov12:
         cmp   bx,1                         ;\
         je    N31OfCakculateDay            ; \
         cmp   bx,3                         ;  \
         je    N31OfCakculateDay            ;   \
         cmp   bx,5                         ;    \
         je    N31OfCakculateDay            ;     \
         cmp   bx,7                         ;      \ Check the month how many days have in this month.
         je    N31OfCakculateDay            ;      / In these months maximal days is 31.
         cmp   bx,8                         ;     /
         je    N31OfCakculateDay            ;    /
         cmp   bx,10                        ;   /
         je    N31OfCakculateDay            ;  /
         cmp   bx,12                        ; /
         je    N31OfCakculateDay            ;/
       
         cmp   bx,4                         ;\
         je    N30OfCakculateDay            ; \
         cmp   bx,6                         ;  \
         je    N30OfCakculateDay            ;   \ Check the month how many days have in this month.
         cmp   bx,9                         ;   / In these months maximal days is 30.
         je    N30OfCakculateDay            ;  /
         cmp   bx,11                        ; /
         je    N30OfCakculateDay            ;/
       
         push  si
         xor   si,si
         
         push  cx                           ;\
         call  LeapYear                     ; \
         cmp   si,0                         ;  \ If this year is not LeapYear then the maximal number of days in month is 28
         je    N28OfCakculateDay            ;  /
                                            ; /
         jmp   N29OfCakculateDay            ;/   else the maximal number of days in month is 29

N31OfCakculateDay:
         xor   cx,cx                        ; CX = 0                                     
         mov   bx,31                        ; BX = 31 (maximal number of days in month (this month is: FirstMonth - 1))  
         sub   bx,dx                        ; BX - DX ( 31 - SecondDay )                 
         add   cx,ax                        ; CX = CX + AX ( AX = FirstDay )            
         add   cx,bx                        ; CX = CX + BX ( BX = 31 - SecondDay )      
         jmp   ans+che
N30OfCakculateDay:
         xor   cx,cx          
         mov   bx,30                        ; CX = 0
         sub   bx,dx                        ; BX = 30 (maximal number of days in month (this month is: FirstMonth - 1)) 
         add   cx,ax                        ; BX - DX ( 30 - SecondDay )
         add   cx,bx                        ; CX = CX + AX ( AX = FirstDay )
         jmp   ans+che                      ; CX = CX + BX ( BX = 30 - SecondDay )
N29OfCakculateDay:
         pop   cx   
         pop   si
         
         xor   cx,cx                        ; CX = 0
         mov   bx,29                        ; BX = 29 (maximal number of days in month (this month is: FirstMonth - 1)) 
         sub   bx,dx                        ; BX - DX ( 29 - SecondDay )
         add   cx,ax                        ; CX = CX + AX ( AX = FirstDay )
         add   cx,bx                        ; CX = CX + BX ( BX = 29 - SecondDay )
         jmp   ans+che
N28OfCakculateDay:
         pop   cx
         pop   si

         xor   cx,cx                        ; CX = 0
         mov   bx,28                        ; BX = 29 (maximal number of days in month (this month is: FirstMonth - 1))
         sub   bx,dx                        ; BX - DX ( 29 - SecondDay )
         add   cx,ax                        ; CX = CX + AX ( AX = FirstDay )
         add   cx,bx                        ; CX = CX + BX ( BX = 28 - SecondDay )
         jmp   ans+che
NumOfDaysIs0:
         xor   dx,dx                        ; DX = 0 because it is not full year
         mov   cx,0                         ; CX = 0 because FirstDay - SecondDay = 0
         jmp   ans
FullYear:mov   dx,1                         ; DX = 1 because it is full year
         mov   si,0                         ; SI = 0 because FirstDay - SecondDay = 0
         jmp   SkipINCsi       

 ans+che:xor   di,di
         mov   di,1                         ; DI = 1 the flag to mark that need to subtract from AnswerD or / and AnswerM or / and AnswerY 
                                            ; in Function " CheckAnswerD,M,Y "
     ans:mov   si,cx
         inc   si                           ; Include last day in difference
         xor   dx,dx    
SkipINCsi:
         pop   cx
         pop   bx
         pop   ax
       
         ret   12
    CalculateD ENDP
    ;===========================================================
    ; The procedure check if this year is a LeapYear 
    ;
    ; this year [bp] + 2
    ;
    ; return the answer in SI 
    ;                     1) If this year is LeapYear SI = 1
    ;                     2) If this year is not LeapYear SI = 0
    ;===========================================================
   
    LeapYear PROC NEAR
         mov   bp,sp 
        
         push  ax
         push  bx
         push  cx
         push  dx 
      
         mov   ax,[bp] + 2   ; AX <-- this year 
                                  
         xor   dx,dx         ;\
         mov   bx,4          ; > Dividing the number of years by 4
         div   bx            ;/

         cmp   dx,0          ;\ If number of years is not divisible by 4 without remainder then this year is not LeapYear
         jne   NoLeap        ;/             
       
         mov   ax,[bp] + 2   ; AX <-- this year
                                  
         xor   dx,dx         ;\
         mov   bx,100        ; > Dividing the number of years by 100
         div   bx            ;/
    
         cmp   dx,0          ;\ If number of years is divisible by 100 without remainder then this year is LeapYear
         jne   Leap          ;/           

         mov   ax,[bp] + 2   ; AX <-- this year
                                    
         xor   dx,dx         ;\
         mov   bx,400        ; > Dividing the number of years by 400
         div   bx            ;/

         cmp   dx,0          ;\ If number of years is not divisible by 400 without remainder then this year is not LeapYear
         jne   NoLeap        ;/             
       
         jmp   Leap          ; This year is not LeapYear
       
  NoLeap:mov   si,0          ; SI = 0 this year is not LeapYear
         jmp   EndProcedure 
    Leap:mov   si,1          ; SI = 1 this year is LeapYear
EndProcedure:       
         pop   dx
         pop   cx
         pop   bx
         pop   ax
       
         ret 
    LeapYear ENDP
    
    ;==========================================================
    ; This procedure checks the number of days to determine if
    ; it represents a full month. If then, the number of months
    ; and days are adjusted accordingly.
    ;
    ; push di           [bp] + 14
    ; push AnswerY      [bp] + 12
    ; push AnswerM      [bp] + 10
    ; push AnswerD      [bp] + 8
    ; push FirstYear    [bp] + 6
    ; push FirstDay     [bp] + 4
    ; push FirstMonth   [bp] + 2
    ;
    ; return AnswerD by AX
    ;        AnswerM by BX
    ;        AnswerY by CX
    ;==========================================================
   
    CheckAnswerD,M,Y PROC NEAR
         mov   bp,sp
        
         push  dx
        
         xor   ax,ax
         xor   bx,bx
         xor   cx,cx
         xor   dx,dx
  
         cmp   [bp] + 14,1         ; The value of DI is assigned in procedure CalculateD. DI = 1 () If FirstDay < SecondDay then number of month is 1 less then FirstMonth - SecondMonth
         jne   continue            ; Because the last month was not a full month
         cmp   [bp] + 10,0         ; If AnswerM = 0  
         je    subAnsYear1         ;  
         sub   [bp] + 10,1         ; AnswerM = AnswerM - 1
         jmp   continue    
subAnsYear1:    
         mov   [bp] + 10,11        ; AnswerM = 11
         cmp   [bp] + 12,0         ; If AnswerY = 0
         je    continue
         sub   [bp] + 12,1         ; AnswerY = AnswerY - 1

continue:mov   ax,[bp] + 2         ;\
         cmp   ax,1                ; \
         je    N31OfCheckAnswerD   ;  \
         cmp   ax,3                ;   \
         je    N31OfCheckAnswerD   ;    \
         cmp   ax,5                ;     \
         je    N31OfCheckAnswerD   ;      \  
         cmp   ax,7                ;       > Check the month how many days have in this month.
         je    N31OfCheckAnswerD   ;      /  In these months maximal days is 31.
         cmp   ax,8                ;     /
         je    N31OfCheckAnswerD   ;    /
         cmp   ax,10               ;   /
         je    N31OfCheckAnswerD   ;  /
         cmp   ax,12               ; /
         je    N31OfCheckAnswerD   ;/
       
         cmp   ax,4                ;\
         je    N30OfCheckAnswerD   ; \
         cmp   ax,6                ;  \
         je    N30OfCheckAnswerD   ;   \ Check the month how many days have in this month.
         cmp   ax,9                ;   / In these months maximal days is 30.
         je    N30OfCheckAnswerD   ;  /
         cmp   ax,11               ; /
         je    N30OfCheckAnswerD   ;/
        
         mov   bx,bp               ; Save a value of BP before entry to procedure
         push  [bp] + 6
         call  LeapYear            ; function that check if this year is LeapYear ot not LeapYear
         mov   bp,bx               ; return the value that have in BP before entry to procedure
         pop   [bp] + 6
         cmp   si,1                ; If SI = 1 then this year is LeapYear, else this year is not LeapYear
         je    N29OfCheckAnswerD   ; In this month maximal days is 29.
         jmp   N28OfCheckAnswerD   ; In this month maximal days is 28.
       
N31OfCheckAnswerD:             
         cmp   [bp] + 8,31         ; If AnswerD >= 31 then it is full month
         jne   NoProblem
         inc   [bp] + 10           ; AnswerM = AnswerM + 1
         sub   [bp] + 8,31         ; AnswerD = AnswerD - 31
         jmp   NoProblem
N30OfCheckAnswerD:             
         cmp   [bp] + 8,30         ; If AnswerD >= 30 then it is full month
         jne   NoProblem
         inc   [bp] + 10           ; AnswerM = AnswerM + 1
         sub   [bp] + 8,30         ; AnswerD = AnswerD - 30
         jmp   NoProblem
N29OfCheckAnswerD:             
         cmp   [bp] + 8,29         ; If AnswerD >= 29 then it is full month
         jne   NoProblem
         inc   [bp] + 10           ; AnswerM = AnswerM + 1
         sub   [bp] + 8,29         ; AnswerD = AnswerD - 29
         jmp   NoProblem
N28OfCheckAnswerD:             
         cmp   [bp] + 8,28         ; If AnswerD >= 28 then it is full month
         jne   NoProblem
         inc   [bp] + 10           ; AnswerM = AnswerM + 1
         sub   [bp] + 8,28         ; AnswerD = AnswerD - 28
       
NoProblem:
         cmp   [bp] + 10,11        ; If AnswerM > 11 then it is full year
         jng   SkipToEndProcedure
         inc   [bp] + 12           ; AnswerY = AnswerY + 1
         mov   [bp] + 10,0         ; AnswerM = 0
       
SkipToEndProcedure:
         mov   ax,[bp] + 8
         mov   bx,[bp] + 10
         mov   cx,[bp] + 12
             
         pop   dx
       
         ret   14
    CheckAnswerD,M,Y ENDP
      
    ;=========================================================
    ; The procedure input a digit to AL
    ;=========================================================
   
    InputDigit PROC NEAR
               
         xor   ax,ax
        
         mov   ah,1
         int   21h    
       
         ret
    InputDigit ENDP
    
    ;=========================================================
    ; The procedure displays decimal unsigned number of byte size.
    ; It gets this number from DL register
    ;=========================================================
    
    TypeNumber PROC NEAR
               
       push   ax
       push   bx
       push   cx
       push   dx 
        
       mov    ax, dx		    ; Parameter of procedure --> ax
       mov    cx, 0         ; The counter of the digits
       mov	  bx, 10		    ; Divider for digits selection 	

StartOutput: 
	   mov    dx, 0          ; The most significant part of dividend = 0
       div    bx	          ; ax / bx
       push   dx            ; Remainder (lost significant digit) -->STACK
       inc    cx        
       cmp    ax, 0         ; If the Quotient != 0 --> return to Start
       jne    StartOutput

   next12:
       pop    dx            ; STACK --> Most Significant Digit
       add    dl, '0'       ; Digit + ASCII Code of '0' --> dl
       mov    ah, 2         ; Typing of digit
       int    21h
       loop   Next12
       
       pop    dx
       pop    cx
       pop    bx
       pop    ax 
       
       ret
    TypeNumber ENDP
                
    ;=========================================================
    ; The procedure prints the message or character located in DX
    ; It gets the address of message from DX register
    ;=========================================================
   
    PrintMsg PROC NEAR
       push ax
       xor ax,ax
        
       mov ah,9
       int 21h 
       
       pop  ax
       
       ret
    PrintMsg ENDP 
          
ends

end start ; set entry point and stop the assembler.    