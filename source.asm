INCLUDE Irvine32.inc

PRINT MACRO msg
    mov edx, OFFSET msg
    call WriteString
ENDM

NITEMS = 5
GST_PCT = 5
LOCK_SECS = 15

.data
    msgWelcome      BYTE 13,10,"     Welcome to Restaurant POS System      ",13,10,0

    msgPass         BYTE "Enter password: ",0
    msgBad          BYTE "Wrong password!",13,10,0
    msgLocked       BYTE "Too many wrong attempts.",13,10,0

    msgCashierMenu  BYTE 13,10,"--- CASHIER MENU ---",13,10,
                    "1. New Order",13,10,
                    "2. Logout",13,10,
                    "3. Exit Program",13,10,
                    "Choice: ",0
    msgManagerMenu  BYTE 13,10,"--- MANAGER MENU ---",13,10,
                    "1. View Sales Report",13,10,
                    "2. Change Cashier Password",13,10,
                    "3. Logout",13,10,
                    "4. Exit Program",13,10,
                    "Choice: ",0

    msgInvalid      BYTE "Invalid choice, try again.",13,10,0
    msgNumericInvalid BYTE "Invalid input! Please enter a valid number.",13,10,0
    msgAccessDenied BYTE "Access denied. Managers only.",13,10,0
    msgLoginCashier BYTE "Successfully logged in as CASHIER.",13,10,0
    msgLoginManager BYTE "Successfully logged in as MANAGER.",13,10,0
    msgLogout       BYTE 13,10,"You have been logged out.",13,10,0
    msgBye          BYTE "Goodbye!",13,10,0

    msgItemAddSuccess Byte "Item Added Successfully!",13,10,0
    msgItemRemoveSuccess Byte "Item Removed!",13,10,0

    msgOrder        BYTE 13,10,"--- ORDER ---",13,10,
                "1. Pizza  (Rs 300)",13,10,
                "2. Burger (Rs 150)",13,10,
                "3. Tea    (Rs 50)",13,10,
                "4. Cold Drink (Rs 80)",13,10,
                "5. Fries  (Rs 100)",13,10,
                "6. Generate Bill",13,10,
                "7. Cancel Order",13,10,
                "8. View Order",13,10,
                "9. Remove Item",13,10,
                "Choice: ",0
    msgQty          BYTE "Quantity: ",0
    msgRemQty       BYTE "Quantity to remove: ",0
    msgEmpty        BYTE "Order list is empty!",13,10,0
    msgCancel       BYTE "Order cancelled.",13,10,0
    msgSub          BYTE 13,10,"Subtotal: Rs ",0
    msgGst          BYTE "GST 5%:   Rs ",0
    msgTotal        BYTE "TOTAL:     Rs ",0
    msgPay          BYTE 13,10,"Payment: 1.Cash  2.Card  3.Mobile Wallet (Easypaisa) : ",0
    msgCashIn       BYTE "Cash received: Rs ",0
    msgChange       BYTE "Change: Rs ",0
    msgShort        BYTE "Not enough cash!",13,10,0
    msgPaid         BYTE "Payment successful. Thank you!",13,10,0
    msgLine         BYTE "----------------",13,10,0
    msgX            BYTE " x ",0

    msgMgr          BYTE "Manager re-authentication required. ",0
    msgNewPass      BYTE "Enter new cashier password: ",0
    msgConfirmPass  BYTE "Confirm new cashier password: ",0
    msgPassChanged  BYTE "Cashier password changed successfully.",13,10,0
    msgPassMismatch BYTE "Passwords do not match. Please try again.",13,10,0
    msgPassEmpty    BYTE "Password cannot be empty. Please try again.",13,10,0
    msgMgrAuthFail  BYTE "Manager authentication failed. Password unchanged.",13,10,0

    msgRepHead      BYTE 13,10," SALES REPORT ",13,10,0
    msgSold         BYTE " sold: ",0
    msgCashT        BYTE "Cash total: Rs ",0
    msgCardT        BYTE "Card total: Rs ",0
    msgUpiT         BYTE "Mobile Wallet total:  Rs ",0
    msgDayT         BYTE "TOTAL SALES: Rs ",0
    msgBest         BYTE "Best selling item: ",0
    msgNoSale       BYTE "No sales yet.",13,10,0
    msgLockHead     BYTE 13,10,"Too many wrong attempts. System locked, wait: ",0
    msgSpace        BYTE " ",0
    msgLockEnd      BYTE 13,10,"Unlocked. You can try again.",13,10,0

    msgCurrentCart  BYTE 13,10,"--- CURRENT ORDER ---",13,10,0
    msgRemoveMenu   BYTE 13,10,"--- REMOVE ITEM ---",13,10,
                    "Enter item number (1-5), or 0 to go back: ",0
    msgNoItems      BYTE "There are no items available to remove.",13,10,0
    msgNotInCart    BYTE "This item is not in your order.",13,10,0
    msgRemoved      BYTE "Order has been updated successfully.",13,10,0
    msgRemoveQty    BYTE "Specify the quantity you want to remove? ",0

    ; SimpleHash("c1234") = 293 342 078
    ; SimpleHash("m9999") = 302 822 534
    cashHash        DWORD 293342078
    mgrHash         DWORD 302822534

    passBuf         BYTE 20 DUP(0)
    confirmBuf      BYTE 20 DUP(0)
    tempHash        DWORD 0
    triesLeft       DWORD 0
    userRole        DWORD 0       ; 1 = cashier, 2 = manager, 0 = logged out
    retryMode       DWORD 1       ; 1 = retry after lockout, 0 = return to caller

    n1              BYTE "Pizza",0
    n2              BYTE "Burger",0
    n3              BYTE "Tea",0
    n4              BYTE "Cold Drink",0
    n5              BYTE "Fries",0
    names           DWORD OFFSET n1, OFFSET n2, OFFSET n3, OFFSET n4, OFFSET n5

    prices          DWORD 300,150,50,80,100
    cart            DWORD NITEMS DUP(0)
    sold            DWORD NITEMS DUP(0)
    payTot          DWORD 3 DUP(0)
    dayTotal        DWORD 0
    billTotal       DWORD 0
    billSub         DWORD 0
    billGst         DWORD 0

.code

; Input: EDX = address of null-terminated string
; Output: EAX = simple demonstration hash
SimpleHash PROC
    push esi
    push ebx
    mov esi, edx
    mov eax, 7
HashLoop:
    movzx ebx, BYTE PTR [esi]
    cmp ebx, 0
    je HashDone
    imul eax, 31
    add eax, ebx
    inc esi
    jmp HashLoop
HashDone:
    pop ebx
    pop esi
    ret
SimpleHash ENDP


LockDelay PROC
    pushad
    PRINT msgLockHead
    mov ecx, LOCK_SECS
LockLoop:
    mov eax, ecx
    call WriteDec
    PRINT msgSpace
    mov eax, 1000
    call Delay
    dec ecx
    jnz LockLoop
    PRINT msgLockEnd
    popad
    ret
LockDelay ENDP


; Login accepts either role.
; Returns EAX=1 for cashier, EAX=2 for manager.
AuthenticateLogin PROC
LoginStart:
    mov triesLeft, 3
LoginTry:
    PRINT msgPass
    mov edx, OFFSET passBuf
    mov ecx, 19
    call ReadString

    mov edx, OFFSET passBuf
    call SimpleHash

    cmp eax, cashHash
    je LoginCashier
    cmp eax, mgrHash
    je LoginManager

    PRINT msgBad
    dec triesLeft
    jnz LoginTry

    call LockDelay
    jmp LoginStart

LoginCashier:
    mov eax, 1
    ret
LoginManager:
    mov eax, 2
    ret
AuthenticateLogin ENDP


; Manager re-authentication.
CheckPassword PROC
PasswordStart:
    mov triesLeft, 3
PasswordTry:
    PRINT msgPass
    mov edx, OFFSET passBuf
    mov ecx, 19
    call ReadString

    mov edx, OFFSET passBuf
    call SimpleHash
    cmp eax, ebx
    je PasswordOK

    PRINT msgBad
    dec triesLeft
    jnz PasswordTry

    call LockDelay
    cmp retryMode, 1
    je PasswordStart

    mov eax, 0
    ret
PasswordOK:
    mov eax, 1
    ret
CheckPassword ENDP


ChangeCashierPassword PROC
    pushad
NewPasswordTry:
    PRINT msgNewPass
    mov edx, OFFSET passBuf
    mov ecx, 19
    call ReadString
    cmp eax, 0
    je EmptyPassword

    mov edx, OFFSET passBuf
    call SimpleHash
    mov tempHash, eax

    PRINT msgConfirmPass
    mov edx, OFFSET confirmBuf
    mov ecx, 19
    call ReadString
    cmp eax, 0
    je PasswordMismatch

    mov edx, OFFSET confirmBuf
    call SimpleHash
    cmp eax, tempHash
    jne PasswordMismatch

    mov eax, tempHash
    mov cashHash, eax
    PRINT msgPassChanged
    jmp ChangePasswordDone

EmptyPassword:
    PRINT msgPassEmpty
    jmp NewPasswordTry

PasswordMismatch:
    PRINT msgPassMismatch
    jmp NewPasswordTry

ChangePasswordDone:
    ; Clear both buffers after password update.
    mov edi, OFFSET passBuf
    mov ecx, 20
    xor eax, eax
    cld
    rep stosb
    mov edi, OFFSET confirmBuf
    mov ecx, 20
    xor eax, eax
    rep stosb
    popad
    ret
ChangeCashierPassword ENDP


CalcBill PROC
    push esi
    push ecx
    mov esi, 0
    mov ecx, NITEMS
    xor eax, eax
CB:
    mov ebx, cart[esi*4]
    imul ebx, prices[esi*4]
    add eax, ebx
    inc esi
    loop CB

    mov billSub, eax
    mov ebx, GST_PCT
    mul ebx
    mov ebx, 100
    xor edx, edx
    div ebx
    mov billGst, eax

    mov eax, billSub
    add eax, billGst
    mov billTotal, eax
    mov eax, billSub
    pop ecx
    pop esi
    ret
CalcBill ENDP


ShowBill PROC
    push esi
    PRINT msgLine
    mov esi, 0
SB:
    cmp esi, NITEMS
    jae SBend
    cmp cart[esi*4], 0
    je SBnext
    mov edx, names[esi*4]
    call WriteString
    PRINT msgX
    mov eax, cart[esi*4]
    call WriteDec
    call Crlf
SBnext:
    inc esi
    jmp SB
SBend:
    PRINT msgSub
    mov eax, billSub
    call WriteDec
    call Crlf
    PRINT msgGst
    mov eax, billGst
    call WriteDec
    call Crlf
    PRINT msgTotal
    mov eax, billTotal
    call WriteDec
    call Crlf
    PRINT msgLine
    pop esi
    ret
ShowBill ENDP


ClearCart PROC
    push ecx
    push esi
    mov ecx, NITEMS
    mov esi, 0
CC:
    mov cart[esi*4], 0
    inc esi
    loop CC
    pop esi
    pop ecx
    ret
ClearCart ENDP


TakePayment PROC
AskPay:
    PRINT msgPay
    call ReadValidInt
    cmp eax, 1
    jb AskPay
    cmp eax, 3
    ja AskPay

    mov esi, eax
    dec esi
    cmp esi, 0
    jne PaidOK

    PRINT msgCashIn
    call ReadValidInt
    cmp eax, billTotal
    jae CashOK
    PRINT msgShort
    jmp AskPay

CashOK:
    sub eax, billTotal
    mov ebx, eax
    PRINT msgChange
    mov eax, ebx
    call WriteDec
    call Crlf

PaidOK:
    mov eax, billTotal
    add payTot[esi*4], eax
    PRINT msgPaid
    mov eax, 1
    ret
TakePayment ENDP


DoOrderProc PROC
    call ClearCart
OrdLoop:
    PRINT msgOrder
    call ReadValidInt
    cmp eax, 6
    je DoBill
    cmp eax, 7
    je DoCancel
    cmp eax, 8
    je DoViewOrder
    cmp eax, 9
    je DoRemove
    cmp eax, 1
    jb BadOrd
    cmp eax, NITEMS
    ja BadOrd

    mov esi, eax
    dec esi
    PRINT msgQty
    call ReadValidInt
    cmp eax, 1
    jb BadOrd
    add cart[esi*4], eax
    PRINT msgItemAddSuccess
    jmp OrdLoop

BadOrd:
    PRINT msgInvalid
    jmp OrdLoop

DoViewOrder:
    call ShowCart

    ; Check whether the order is empty
    cmp eax, 0
    je ViewEmpty

    ; Return to the order menu
    jmp OrdLoop

ViewEmpty:
    PRINT msgEmpty
    jmp OrdLoop

DoRemove:

    call ShowCart


    cmp eax, 0
    jne RemoveAskItem

    PRINT msgEmpty
    jmp OrdLoop

RemoveAskItem:
    PRINT msgRemoveMenu
    call ReadValidInt

    ; 0 means return to the order menu
    cmp eax, 0
    je OrdLoop

    ; Validate item selection
    cmp eax, 1
    jb RemoveInvalid

    cmp eax, NITEMS
    ja RemoveInvalid

    mov esi, eax
    dec esi

    ; Check whether selected item is actually in cart
    cmp cart[esi*4], 0
    je RemoveNotAvailable

    ; Ask how many units to remove
    PRINT msgRemoveQty
    call ReadValidInt

    ; Quantity must be positive
    cmp eax, 1
    jb RemoveInvalid

    ; Do not allow the cart quantity to become negative
    cmp eax, cart[esi*4]
    jbe RemoveSubtract

    mov eax, cart[esi*4]

RemoveSubtract:
    sub cart[esi*4], eax

    PRINT msgRemoved
    jmp OrdLoop

RemoveNotAvailable:
    PRINT msgNotInCart
    jmp OrdLoop

RemoveInvalid:
    PRINT msgInvalid
    jmp OrdLoop

DoCancel:
    call ClearCart
    PRINT msgCancel
    mov eax, 0
    ret

DoBill:
    call CalcBill
    cmp eax, 0
    jne HaveItems
    PRINT msgEmpty
    jmp OrdLoop

HaveItems:
    call ShowBill
    call TakePayment
    mov esi, 0
AddSold:
    mov eax, cart[esi*4]
    add sold[esi*4], eax
    inc esi
    cmp esi, NITEMS
    jb AddSold
    mov eax, billTotal
    add dayTotal, eax
    mov eax, 1
    ret
DoOrderProc ENDP


ShowCart PROC
    push esi
    push ecx
    push edi

    PRINT msgCurrentCart

    mov esi, 0
    mov ecx, NITEMS
    xor edi, edi

CartDisplayLoop:
    mov eax, cart[esi*4]

    cmp eax, 0
    je CartDisplayNext

    mov edi, 1

    mov edx, names[esi*4]
    call WriteString

    PRINT msgX

    mov eax, cart[esi*4]
    call WriteDec
    call Crlf

CartDisplayNext:
    inc esi
    loop CartDisplayLoop

    mov eax, edi

    pop edi
    pop ecx
    pop esi
    ret
ShowCart ENDP

PrintReport PROC
    PRINT msgRepHead
    mov esi, 0
    mov edi, 0
    mov ebx, 0
RL:
    cmp esi, NITEMS
    jae RLend
    mov edx, names[esi*4]
    call WriteString
    PRINT msgSold
    mov eax, sold[esi*4]
    call WriteDec
    call Crlf
    cmp eax, ebx
    jbe RLnext
    mov ebx, eax
    mov edi, esi
RLnext:
    inc esi
    jmp RL
RLend:
    PRINT msgLine
    PRINT msgCashT
    mov eax, payTot[0]
    call WriteDec
    call Crlf
    PRINT msgCardT
    mov eax, payTot[4]
    call WriteDec
    call Crlf
    PRINT msgUpiT
    mov eax, payTot[8]
    call WriteDec
    call Crlf
    PRINT msgDayT
    mov eax, dayTotal
    call WriteDec
    call Crlf
    cmp ebx, 0
    jne HasBest
    PRINT msgNoSale
    ret
HasBest:
    PRINT msgBest
    mov edx, names[edi*4]
    call WriteString
    call Crlf
    ret
PrintReport ENDP


ReadValidInt PROC
ReadAgain:
    call ReadInt
    jc InvalidNumber
    ret

InvalidNumber:
    PRINT msgNumericInvalid
    jmp ReadAgain
ReadValidInt ENDP


main PROC
    PRINT msgWelcome

LoginLoop:
    call AuthenticateLogin
    mov userRole, eax
    cmp eax, 1
    je CashierLoginSuccess
    PRINT msgLoginManager
    jmp ManagerMenuLoop

CashierLoginSuccess:
    PRINT msgLoginCashier
    jmp CashierMenuLoop


CashierMenuLoop:
    PRINT msgCashierMenu
    call ReadValidInt
    cmp eax, 1
    je NewOrder
    cmp eax, 2
    je DoLogout
    cmp eax, 3
    je DoExit
    PRINT msgInvalid
    jmp CashierMenuLoop


; Manager has management options, logout and exit; no New Order.
ManagerMenuLoop:
    PRINT msgManagerMenu
    call ReadValidInt
    cmp eax, 1
    je DoReport
    cmp eax, 2
    je DoChangeCashier
    cmp eax, 3
    je DoLogout
    cmp eax, 4
    je DoExit
    PRINT msgInvalid
    jmp ManagerMenuLoop


NewOrder:
    cmp userRole, 1
    jne DeniedManager
    call DoOrderProc
    jmp CashierMenuLoop

DeniedManager:
    PRINT msgAccessDenied
    jmp ManagerMenuLoop


DoReport:
    cmp userRole, 2
    jne DeniedCashier
    call PrintReport
    jmp ManagerMenuLoop

DeniedCashier:
    PRINT msgAccessDenied
    jmp CashierMenuLoop


DoChangeCashier:
    cmp userRole, 2
    jne DeniedCashier

    ; Re-authenticate manager before changing a credential.
    PRINT msgMgr
    mov retryMode, 0
    mov ebx, mgrHash
    call CheckPassword
    mov retryMode, 1
    cmp eax, 1
    jne ManagerAuthFailed

    call ChangeCashierPassword
    jmp ManagerMenuLoop

ManagerAuthFailed:
    PRINT msgMgrAuthFail
    jmp ManagerMenuLoop


DoLogout:
    mov userRole, 0
    PRINT msgLogout
    jmp LoginLoop


DoExit:
    PRINT msgBye
    call WaitMsg
    exit

main ENDP
END main
