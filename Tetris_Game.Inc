
ifndef MYFUN_VIEW_INC_20160319

;--------------▼-equ-▼----------------------------    
    GAME_ROWS       equ 20d
    GAME_COLS       equ 12d
    GAME_WALL       equ 1d
    GAME_NOT_WALL   equ 0d
    GAME_RUN        equ 11d   ;游戏状态.运行
    GAME_PAUSE      equ 12d   ;游戏状态.暂停
    GAME_OVER       equ 13d   ;游戏状态.结束
    
    
    
GameStruct struct
    m_nRows word GAME_ROWS
    m_nCols word GAME_COLS
    m_x byte ?
    m_y byte ?
    m_nType byte ?        ;当前什么图形       
    m_nRotate byte ?      ;什么旋转方式
    
    m_nNextType byte ?    ;下个方块图形
    m_nNextRotate byte ?  ;下个旋转   
    m_nScore Dword 0      ;得分
    m_nState byte ?       ;游戏状态
    ;m_AllShape[][4] :byte 
GameStruct ends    

;--------------▼-Proto-▼----------------------------    
GetCurShape proto   ; 返回值为char* 
GetBackGround proto ; 返回值为char*
GetRows proto       ; return nRows
GetCols proto       ; return nCols
GetX proto          ; return _x
GetY proto          ; return _y

Rotate proto        ; 旋转 ;return bool 
Down proto          ; 下落 ;return bool 
Right proto         ; 右移 ;return bool 
Left proto          ; 左移 ;return bool 
FixAndDelRow proto  ; 固定和消行
IsCanReaseLine proto bRow:byte   ; 判断是否可以消行 ;return bool

InitGame proto          ; 初始化
StartGame proto         ; 开始游戏
CreateNewShape proto    ; 产生新方块
Eliminate proto         ; 消行，返回得分 ;return int
PauseGame proto         ; 暂停游戏

MyRand  proto bNumber:byte ;获取随机数

;--------------▼-View Proto-▼----------------------------      
OnDraw proto hdc:HDC    ;绘制
DrawNext proto hdc:HDC  ;画下个方块
DrawShape proto  hdc:HDC,x:dword, y:dword   ;用画刷画方块


;--------------▼-Shape Data-▼----------------------------
.data
    g_BackGround byte 240 dup(?); //背景数组
    g_AllShape byte 2, 2, 2, 2 ;448
     ;  逆时针旋转
    ;▇▇▇▇
    ;
    ;2, 2, 2, 2,
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 2, 0, 0, 0

    byte 2, 2, 2, 2
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 2, 0, 0, 0

         ;▇
         ;▇▇▇   
    byte 2, 0, 0, 0
    byte 2, 2, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 0, 2, 0, 0
    byte 0, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 2, 0
    byte 0, 0, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 0, 0, 0, 0

         ;byte ▇
         ;▇▇▇   
    byte 0, 0, 2, 0
    byte 2, 2, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 0, 2, 0, 0
    byte 0, 2, 0, 0
    byte 0, 0, 0, 0
     
    byte 2, 2, 2, 0
    byte 2, 0, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 0, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0

         ;  ▇
         ;▇▇▇   4
    byte 0, 2, 0, 0
    byte 2, 2, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 0, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 2, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 2, 0
    byte 0, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 2, 0, 0
    byte 2, 0, 0, 0
    byte 0, 0, 0, 0

         ;▇▇
         ;  ▇▇  5
    byte 2, 2, 0, 0
    byte 0, 2, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 0, 2, 0, 0
    byte 2, 2, 0, 0
    byte 2, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 0, 2, 2, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 0, 2, 0, 0
    byte 2, 2, 0, 0
    byte 2, 0, 0, 0
    byte 0, 0, 0, 0

         ;  ▇▇
         ;▇▇    6
    byte 0, 2, 2, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 2, 0, 0
    byte 0, 2, 0, 0
    byte 0, 0, 0, 0

    byte 0, 2, 2, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 0, 0, 0
    byte 2, 2, 0, 0
    byte 0, 2, 0, 0
    byte 0, 0, 0, 0

         ;▇▇
         ;▇▇  
    byte 2, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

    byte 2, 2, 0, 0
    byte 2, 2, 0, 0
    byte 0, 0, 0, 0
    byte 0, 0, 0, 0

else
    echo ---------------------------------------------
    echo WARNING Duplicate include file Trtris_view.inc
    echo ---------------------------------------------
endif