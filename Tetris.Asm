.386
.model flat, stdcall
option casemap:none

;--------------▼-include-▼----------------------------
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include msvcrt.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib msvcrt.lib


include Tetris_Game.inc
include TetrisRc.inc

;--------------▼-macro-▼----------------------------
ID_TIMER1 equ 1
BOX_WIDTH  equ 32      ;m_nWidth
BOX_PADDING equ 1        ;m_nPadding

;--------------▼-Data-▼----------------------------
.data
    g_hInstance HINSTANCE ?
    g_szWindowClass db 'Tetris_win32', 0
    g_szTitle db 'Tetris', 0
    g_hIcon HICON ?
    g_hNextIcon HICON ?
    g_hIconBK HICON ?     
    
    ;**********View_Data***********
    g_hBg HBRUSH  ?     ;外框刷
    g_hBgb HBRUSH  ?    ;内框刷子
    g_szOver db 'Game Over!',0
    ;**********Game_Data***********   
    g_szScore db '得分：%d',0dh,0ah,0dh,0ah
    g_szHelp db '使用说明：', 0dh,0ah
            db '↓← → : 操作方块移动',0dh,0ah,0dh,0ah
            db '↑ :旋转方块 ',0dh,0ah,0dh,0ah
            db '空格: 暂停游戏 ',0dh,0ah, 0
    g_sGame GameStruct <?>
    
    

;--------------▼-Code-▼----------------------------
.code

;>>>>>>>>>>>>>>>>>▼*--ViewCode--*▼>>>>>>>>>>>>>>>>>
OnDraw proc uses edx ecx hdc:HDC    ; 绘制
    
    LOCAL @i:byte
    LOCAL @j:byte
    LOCAL @ii:byte
    LOCAL @jj:byte
    mov edx, offset g_BackGround
    
    ;********画背景********************************** 
FOR_I_INT:
    mov @i, 0   ;mov cx, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i    ;inc ch
FOR_I_CMP:
    cmp @i, GAME_ROWS
    jz FOR_I_END
    
    mov @j, 0   ;mov cl, 0
    .while TRUE
        .break .if @j == GAME_COLS   
        mov edx, offset g_BackGround
        mov al, GAME_COLS ;i*GAME_COLS
        mul @i 
        add al,@j 
        and eax, 0ffffh ;清除高位
        add edx, eax
        
        mov al,[edx]
        .if al == GAME_WALL ;lpBg[i * nCols + j] == GAME_WALL
            mov al, BOX_WIDTH   ;j * m_nWidth
            mul @j
            and eax, 0ffffh ;清除高位
            mov edx, eax
            
            mov eax, 0
            mov al, BOX_WIDTH   ;i * m_nWidth
            mul @i
            and eax, 0ffffh
            ; 用图标画            
            invoke DrawIcon,hdc,edx,eax,g_hIconBK
;           ; 用画刷画
;           ; DrawShape(hdc, );
        .endif
        
        inc @j  ;inc cl
    .endw
    
    jmp STEP_I
FOR_I_END:

    ;invoke GetCurShape  ;拿当前方块
    ;mov edx, eax
FOR_I_INT_2:
    mov @ii, 0
    jmp FOR_I_CMP_2
STEP_I_2:
    inc @ii 
FOR_I_CMP_2:
    cmp @ii, 4
    jz FOR_I_END_2
    
    mov @jj, 0 
    .while TRUE
        .break .if @jj == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        
        mov al, 4
        mul @ii
        add al, @jj
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2        
            mov eax, 0
            mov al, g_sGame.m_x 
            add al, @jj
            mov ch,BOX_WIDTH
            mul ch
            and eax, 0ffffh
            mov edx, eax
            
            mov eax, 0
            mov al, g_sGame.m_y 
            add al, @ii
            mov ch,BOX_WIDTH
            mul ch
            and eax, 0ffffh
            ; 用图标画
            invoke DrawIcon, hdc, edx, eax, g_hIcon
;            ; 用画刷画
;            ;DrawShape(hdc, )
        .endif
        
        inc @jj
    .endw
    
    jmp STEP_I_2
FOR_I_END_2:

    ;画下个方块
    invoke DrawNext,hdc
    ret
OnDraw endp

DrawNext proc uses edx ecx ebx hdc:HDC  ;画下个方块
    
    LOCAL @i:byte
    LOCAL @j:byte
            
FOR_I_INT:    
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4        
        ;2 ==
        mov eax, 0
        mov al, 64d
        mul g_sGame.m_nNextType
        mov ebx, eax 
        
        mov eax, 0
        mov al, 16d
        mul g_sGame.m_nNextRotate
        add ebx, eax
        
        mov edx, offset g_AllShape
        add edx, ebx
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
            
        mov al,[edx]
        .if al == 2
            mov al, @j 
            add al, 15
            mov ch, BOX_WIDTH
            mul ch
            and eax, 0ffffh
            mov edx, eax
            
            mov al, @i  ;i * 32
            mov ch, BOX_WIDTH
            mul ch
            and eax, 0ffffh
            
            invoke DrawIcon, hdc, edx, eax, g_hNextIcon        
        .endif     
                
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:

    ret
DrawNext endp

DrawShape proc  hdc:HDC,x:dword, y:dword

    ret
DrawShape endp

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


;>>>>>>>>>>>>>>>>>▼*--GameCode--*▼>>>>>>>>>>>>>>>>>
GetCurShape proc uses edx ; 返回当前方块

    mov eax, 0
    mov edx, offset g_AllShape
    mov al, 64d
    mul g_sGame.m_nType     ;@wType
    add edx, eax
    mov eax, 0
    mov al, 16d
    mul g_sGame.m_nRotate   ;@wRotate
    add edx, eax
    
    mov eax, edx    ;return g_AllShape[xx];    
    ret
GetCurShape endp



Rotate proc  uses ecx edx    ; 旋转 ;return bool 

    LOCAL @i:byte
    LOCAL @j:byte
    
    cmp g_sGame.m_nState, GAME_RUN
    jz FOR_I_INT
    mov eax, 0
    ret
        
FOR_I_INT:
    mov al,g_sGame.m_nRotate
    inc ax
    mov dl,4
    div dl
    mov g_sGame.m_nRotate, ah 
    
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2
            mov edx, offset g_BackGround
            mov al, @i  
            add al, g_sGame.m_y
            mov ch, GAME_COLS 
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,g_sGame.m_x 
            and ecx, 0ffh
            add edx, eax
            add edx, ecx
            mov al, [edx]
            .if al == 1   ; 碰撞
                mov al, g_sGame.m_nRotate
                add ax, 3
                mov dl, 4
                div dl
                mov g_sGame.m_nRotate, ah   ;变回原来的
                
                mov eax, 0
                ret ;return false;  
            .endif           
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:

    mov eax, 1
    ret
Rotate endp

Down proc  uses ecx edx      ; 下落 ;return bool 
    LOCAL @bY :byte
    LOCAL @i:byte
    LOCAL @j:byte
    
    cmp g_sGame.m_nState, GAME_RUN
    jz LEFT_RUN
    mov eax, 0  ;return false
    ret
    
LEFT_RUN:
    mov al, g_sGame.m_y
    inc al
    mov @bY, al

FOR_I_INT:
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2
            mov edx, offset g_BackGround
            mov al, @i  
            add al, @bY     ;g_sGame._y
            mov ch, GAME_COLS   ;12
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,g_sGame.m_x  ;@bX
            and ecx, 0ffh
            add edx, eax
            add edx, ecx
            mov al, [edx]
            .if al == 1                
                invoke FixAndDelRow   ;把砖块变成墙，固定
                mov eax, 0
                ret ;return false;
            .endif
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:
    inc g_sGame.m_y
    mov eax, 1
    ret
Down endp

Right proc  uses ecx edx     ; 右移 ;return bool 
    
    LOCAL @bX :byte
    LOCAL @i:byte
    LOCAL @j:byte
    
    cmp g_sGame.m_nState, GAME_RUN
    jz LEFT_RUN
    mov eax, 0  ;return false
    ret
    
LEFT_RUN:
    mov al, g_sGame.m_x
    inc al
    mov @bX, al

FOR_I_INT:
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2 
            mov edx, offset g_BackGround
            mov al, @i  
            add al, g_sGame.m_y
            mov ch, GAME_COLS   ;12
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,@bX
            and ecx, 0ffh
            add edx, eax
            add edx, ecx
            mov al, [edx]
            .if al == 1 
                mov eax, 0
                ret ;return false;
            .endif
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:
    inc g_sGame.m_x   
    mov eax, 1
    ret
Right endp

Left proc uses edx ecx        ; 左移 ;return bool
    LOCAL @bX :byte
    LOCAL @i:byte
    LOCAL @j:byte
    
    cmp g_sGame.m_nState, GAME_RUN
    jz LEFT_RUN
    mov eax, 0  ;return false
    ret
    
LEFT_RUN:
    mov al, g_sGame.m_x
    dec al
    mov @bX, al

FOR_I_INT:
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2
            mov edx, offset g_BackGround
            mov al, @i  
            add al, g_sGame.m_y
            mov ch, GAME_COLS   ;12
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,@bX
            and ecx, 0ffh
            add edx, eax
            add edx, ecx
            mov al, [edx]
            .if al == 1 
                mov eax, 0
                ret ;return false;
            .endif
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:
    dec g_sGame.m_x    
    mov eax, 1  ;return true
    ret
Left endp

FixAndDelRow proc uses ecx edx ; 固定和消行
    
    LOCAL @bY :byte
    LOCAL @i :byte
    LOCAL @j :byte
    
    cmp g_sGame.m_nState, GAME_RUN
    jz LEFT_RUN
    mov eax, 0  ;return false
    ret
    
LEFT_RUN:
    mov al, g_sGame.m_y
    inc al
    mov @bY, al

FOR_I_INT:
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2         
            mov edx, offset g_BackGround
            mov al, @i  
            add al, g_sGame.m_y
            mov ch, GAME_COLS
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,g_sGame.m_x
            and ecx, 0ffh
            add edx, eax
            add edx, ecx    
            mov byte ptr [edx], GAME_WALL   ; 方块变墙  = 1;
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:
    ; 消行
    invoke Eliminate

    ret
FixAndDelRow endp

IsCanReaseLine proc uses ecx edx bRow:byte   ; 判断是否可以消行 ;return bool
    LOCAL @i:byte
    
    mov @i, 0    
    .while @i<GAME_COLS
        mov edx, offset g_BackGround
        mov al, bRow                 
        mov ch, GAME_COLS
        mul ch
        and eax, 0ffffh
        mov cl,@i
        and ecx, 0ffh
        add edx, eax
        add edx, ecx
        mov al,[edx]
        .if al == GAME_NOT_WALL
            mov eax, 0
            ret
        .endif
        inc @i
    .endw
    
    mov eax, 1  ;return true;
    ret
IsCanReaseLine endp

InitGame proc uses ecx edx       ; 初始化
    ;LOCAL w
    
    mov g_sGame.m_nRows, GAME_ROWS
    mov g_sGame.m_nCols, GAME_COLS
    mov g_sGame.m_nScore, 0
    
    ;********初始化背景**********************************
    invoke RtlZeroMemory,offset g_BackGround, sizeof g_BackGround
FOR_I_INT:
    mov cx, 0
    jmp FOR_I_CMP
STEP_I:
    inc ch
FOR_I_CMP:
    cmp ch, GAME_ROWS
    jz FOR_I_END
    
    mov cl, 0
    .while TRUE
        .break .if cl == GAME_COLS
        
        .if cl == 0
            mov edx, offset g_BackGround
            mov al, GAME_COLS ;ch*GAME_COLS
            mul ch
            and eax, 0ffffh ;清除高位
            add edx, eax
            mov byte ptr [edx], GAME_WALL  ;g_BackGround = GAME_WALL
        .elseif cl == GAME_COLS-1
            mov edx, offset g_BackGround
            mov al, GAME_COLS
            mul ch
            and eax, 0ffffh
            add edx, eax
            mov byte ptr [edx + GAME_COLS-1], GAME_WALL
        .elseif ch == GAME_ROWS-1
            mov edx, offset g_BackGround
            mov al, GAME_COLS
            mul ch
            and eax, 0ffffh
            add edx, eax
            movzx eax, cl  ; + cl
            add edx, eax
            mov byte ptr [edx], GAME_WALL
        .endif
        inc cl
    .endw
    
    jmp STEP_I
FOR_I_END:
    invoke crt_time, NULL
    invoke crt_srand,eax ;初始化种子
    invoke crt_rand ; rand() % 7
    and eax,11
    mov dl,7
    div dl
    mov g_sGame.m_nNextType, ah    ;下个方块

    invoke crt_rand   ;rand() % 4
    and eax,7 
    mov dl,4
    div dl
    mov g_sGame.m_nNextRotate, ah  ;下个旋转
    
    invoke CreateNewShape
  
    ret
InitGame endp

StartGame proc         ; 开始游戏    
    invoke InitGame
    mov g_sGame.m_nState, GAME_RUN
    ret
StartGame endp

CreateNewShape proc  uses edx ecx ; 产生新方块
    LOCAL @i:byte
    LOCAL @j:byte
    
    mov g_sGame.m_x, 4
    mov g_sGame.m_y, 0
    
    mov al,g_sGame.m_nNextType      ;新方块图形
    mov g_sGame.m_nType, al
    mov al,g_sGame.m_nNextRotate    ;新方块旋转方式
    mov g_sGame.m_nRotate, al
    
    invoke crt_time, NULL
    invoke crt_srand,eax    ;初始化种子
    invoke crt_rand ; rand() % 7
    and eax,0ffh
    mov dl,7
    div dl
    mov g_sGame.m_nNextType, ah    ;下个方块

    invoke crt_rand   ;rand() % 4
    and eax,0ffh 
    mov dl,4
    div dl
    mov g_sGame.m_nNextRotate, ah  ;下个旋转
    
    ; ***********判断是否游戏结束****************
FOR_I_INT:
    mov @i, 0
    jmp FOR_I_CMP
STEP_I:
    inc @i 
FOR_I_CMP:
    cmp @i, 4
    jz FOR_I_END
    
    mov @j, 0
    .while TRUE
        .break .if @j == 4 
        invoke GetCurShape  ;拿当前方块
        mov edx, eax
        mov al, 4
        mul @i
        add al, @j
        and eax, 0ffffh
        add edx, eax
        
        mov al,[edx]
        .if al == 2
            mov edx, offset g_BackGround
            mov al, @i  
            add al, g_sGame.m_y
            mov ch, GAME_COLS 
            mul ch
            and eax, 0ffffh
            mov cl,@j
            add cl,g_sGame.m_x 
            and ecx, 0ffh
            add edx, eax
            add edx, ecx
            mov al, [edx]
            .if al == 1  ; 碰撞
                mov g_sGame.m_nState, GAME_OVER 
                jmp FOR_I_END   
            .endif           
        .endif
        
        inc @j
    .endw
    
    jmp STEP_I
FOR_I_END:
    ;invoke GetCurShape  ;拿当前方块
    ;mov edx, eax
    
    ret
CreateNewShape endp

Eliminate proc uses ecx edx ebx    ; 消行，返回得分 ;return int

    LOCAL @bRow :byte
    LOCAL @i:byte
    LOCAL @j:byte 

FOR_I_INT:
    mov @bRow, GAME_ROWS - 2
    jmp FOR_I_CMP
STEP_I:
    dec @bRow
FOR_I_CMP:
    cmp @bRow, 0
    jz FOR_I_END
    
    invoke IsCanReaseLine,@bRow
    .if eax == 1    
        ; ************** 移动背景方块 *************************
        mov al, @bRow
        mov @i, al
        .while  @i> 0    
            
            mov @j, 0
            .while TRUE 
                .break .if @j >= GAME_COLS-1                
                 
                mov edx, offset g_BackGround
                mov al, @i                 
                mov ch, GAME_COLS
                mul ch
                and eax, 0ffffh
                mov cl,@j
                and ecx, 0ffh
                add edx, eax
                add edx, ecx
                ;
                mov al, [edx - 12]
                mov [edx], al
                                             
                inc @j
            .endw
            dec @i
        .endw   
        inc @bRow
        inc g_sGame.m_nScore    ; 消一行，得分+1
    .endif
    jmp STEP_I
FOR_I_END:

    mov eax, g_sGame.m_nScore
    ret
Eliminate endp

PauseGame proc         ; 暂停游戏
    cmp g_sGame.m_nState, GAME_OVER
    jz EXIT
    
    cmp g_sGame.m_nState, GAME_PAUSE
    jnz PAUSE
    mov g_sGame.m_nState, GAME_RUN
    jmp EXIT
PAUSE:    
    mov g_sGame.m_nState,GAME_PAUSE
EXIT:        
    ret
PauseGame endp

MyRand  proc uses ecx edx bNumber:byte ;随机数

;    STI
;    mov ah,0          ;读时钟
;    int 1ah
;    mov ax,dx          ;取 秒
;    and ah,3
;    mov dl,bNumber    ;除bNumber，产生 0 ~ bNumber-1 余数
;    div dl            ;余数在ah，作随机数
    
    ret
MyRand  endp
;>>>>>>>>>>>>>>>>>--Game-->>>>>>>>>>>>>>>>>


;--------------▼About消息回调▼-----------------
AboutDlgProc proc hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM

    .if message == WM_COMMAND
        mov eax, wParam
        .if ax == IDOK
            invoke EndDialog, hWnd, 0
            mov eax, TRUE
            ret
        .elseif ax == IDCANCEL
            invoke EndDialog, hWnd, 0
            mov eax, TRUE
            ret
        .endif           
    .elseif message == WM_CLOSE
        invoke EndDialog, hWnd, 0
        mov eax, TRUE
        ret
    .endif
    mov eax, FALSE
    ret    
AboutDlgProc endp

;--------------▼键盘消息处理▼--------------
OnKeydown proc hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
    
    LOCAL @x:byte
    LOCAL @y:byte
    LOCAL @rc:RECT
    
    mov al,g_sGame.m_x
    mov @x, al
    mov al,g_sGame.m_y
    mov @y, al
    dec @x
    ;**************** 设置方块重绘区域*****************
    mov al, BOX_WIDTH   
    mul @x
    and eax, 0ffffh
    mov @rc.left, eax
    
    mov @rc.right, eax
    mov al, BOX_WIDTH 
    mov ah, 6
    mul ah
    and eax, 0ffffh
    add @rc.right,eax 
    
    mov al, BOX_WIDTH   
    mul @y
    and eax, 0ffffh
    mov @rc.top, eax 
    
    mov @rc.bottom, eax
    mov al, BOX_WIDTH   
    mov ah, 5
    mul ah
    and eax, 0ffffh
    add @rc.bottom,eax
    
    ;**************** 解析键盘命令*****************
    mov eax, wParam
    .if eax == VK_LEFT
        invoke Left
    .elseif eax== VK_RIGHT
        invoke Right
    .elseif eax== VK_DOWN
        .if g_sGame.m_nState == GAME_PAUSE
            jmp P_EXIT
        .elseif  g_sGame.m_nState == GAME_OVER
            invoke KillTimer, hWnd, 1
            invoke MessageBox, NULL, offset g_szOver, offset g_szTitle, MB_OK
        .endif
        
        invoke Down
        .if eax == 0    ;触底固定，产生新方块
            invoke CreateNewShape
            invoke InvalidateRect, hWnd, NULL, TRUE ;固定时重绘整个客户区
        .endif 
    .elseif eax== VK_UP
        invoke Rotate
    .elseif eax == VK_SPACE
        invoke PauseGame    ;暂停   
    .endif
    
    invoke InvalidateRect, hWnd, addr @rc, TRUE ;重绘方块变化区域
P_EXIT:    
    mov eax, 1
    ret
OnKeydown endp
;--------------------------------------------------------

;--------------▼主消息回调▼--------------
WndProc proc hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
    
;    local @wmId:WORD
;    local @wmEvent:WORD
	local @ps:PAINTSTRUCT
	local @hdc:HDC
	local @szBuff[100]:TCHAR
	LOCAL @rt:RECT
	LOCAL @crText:COLORREF
	LOCAL @dwLen:dword
    invoke GetClientRect, hWnd, addr @rt
    mov @rt.left, 1E0h   ;15 * 32
    mov @rt.top, 0E0h    ;7 * 32
    mov @rt.right, 2C0h  ;22 * 32
    
    ;@crText.
	;********消息处理**********************************
    .if message == WM_COMMAND
        mov eax, wParam
        .if ax == IDM_START_GAME
            ;invoke MessageBox, hWnd,offset g_szTitle,offset g_szWindowClass,MB_OK
            invoke StartGame    ;开始游戏
            invoke InvalidateRect, hWnd, NULL, TRUE           
            invoke SetTimer, hWnd, ID_TIMER1, 500, NULL    ;设置定时器
        .elseif ax == IDM_GAME_PAUSE
            invoke PauseGame    ;暂停
        .elseif ax == IDM_GAME_EXIT
            invoke KillTimer,hWnd,ID_TIMER1
            invoke PostQuitMessage, 0
            ret
        .elseif ax == IDM_ABOUT
            invoke DialogBoxParam, g_hInstance, IDD_ABOUTBOX, hWnd, offset AboutDlgProc, NULL 
        .else    
            invoke DefWindowProc, hWnd, message, wParam, lParam
        .endif
    .elseif message == WM_TIMER
        invoke OnKeydown, hWnd, WM_KEYDOWN, VK_DOWN, NULL
    .elseif message == WM_KEYDOWN
        invoke OnKeydown, hWnd, message, wParam, lParam
    .elseif message == WM_PAINT
        invoke BeginPaint, hWnd, addr @ps
        mov @hdc, eax  
        
        ; 绘图...
        invoke OnDraw, @hdc

        invoke SetTextColor, @hdc, 0F8F8FFh    ;设置文字色
        invoke SetBkColor, @hdc, 0   ;设置文字背景色
        invoke wsprintf, addr @szBuff, offset g_szScore, g_sGame.m_nScore
        invoke crt_strlen, offset g_szScore
        mov @dwLen, eax
        invoke DrawText, @ps.hdc, addr @szBuff, @dwLen, addr @rt, DT_LEFT ;显示得分 ;显示提示语
                 
        invoke EndPaint, hWnd, addr @ps
    .elseif message == WM_DESTROY
        invoke PostQuitMessage,0
        invoke KillTimer,hWnd,ID_TIMER1
    .else
        invoke DefWindowProc, hWnd, message, wParam, lParam
        
    .endif
    
    ret

WndProc endp

MyRegisterClass proc  hInstance:HINSTANCE  ;注册窗口类
    
    LOCAL @wcex:WNDCLASSEX
    invoke RtlZeroMemory,addr @wcex,sizeof WNDCLASSEX

	mov @wcex.cbSize, sizeof WNDCLASSEX
	mov @wcex.style			, CS_HREDRAW or CS_VREDRAW
	mov @wcex.lpfnWndProc	, offset WndProc
	mov @wcex.cbClsExtra	, 0
	mov @wcex.cbWndExtra	, 0
	push g_hInstance
	pop @wcex.hInstance
	invoke LoadIcon, hInstance, IDI_ICON1
	mov @wcex.hIcon			, eax
	mov @wcex.lpszMenuName	, IDR_MENU1
	invoke LoadCursor,NULL, IDC_ARROW
	mov @wcex.hCursor		, eax
	mov @wcex.hbrBackground	, COLOR_WINDOW+1
	mov @wcex.lpszClassName	, offset g_szWindowClass

	invoke RegisterClassEx, addr @wcex
	
    ret

MyRegisterClass endp

WinMain proc
    
    local @msg:MSG
	;HACCEL hAccelTable
	LOCAL @hWnd:HWND
	
	invoke GetModuleHandle, NULL
	mov g_hInstance, eax
	invoke MyRegisterClass, g_hInstance ;注册窗口类
	
	invoke LoadIcon, g_hInstance, IDI_ICON2 ;加载图标
	mov g_hIconBK, eax
    invoke LoadIcon, g_hInstance, IDI_ICON3 ;加载图标
    mov g_hIcon, eax
    invoke LoadIcon, g_hInstance, IDI_ICON4 ;加载图标
    mov g_hNextIcon, eax
   
	;*******创建、显示窗口******************************************
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, offset g_szWindowClass, offset g_szTitle, WS_MAXIMIZE  or WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, g_hInstance, NULL      
    mov @hWnd, eax
    invoke ShowWindow, @hWnd, SW_SHOWNORMAL or SW_MAXIMIZE
    invoke UpdateWindow, @hWnd
	
	; *******主消息循环:********************************************
	.while TRUE
	    invoke GetMessage, addr @msg, NULL, 0, 0
	    .break .if !eax
	        invoke TranslateMessage, addr @msg
		    invoke DispatchMessage, addr @msg
	.endw
	
	mov eax, @msg.wParam
    ret

WinMain endp

;--------------入口----------------------------
START:
    invoke CreateSolidBrush, 0ffffffh;
    mov g_hBg, eax
    invoke CreateSolidBrush, 0;
    mov g_hBgb, eax
    invoke InitGame
    invoke WinMain
    invoke ExitProcess,NULL
;------------------------------------------
end START