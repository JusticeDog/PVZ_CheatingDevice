.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include windows.inc
include user32.inc 
include kernel32.inc 
include	psapi.inc
include gdi32.inc
include gdiplus.inc
includelib user32.lib 
includelib kernel32.lib 
includelib msvcrt.lib
includelib	psapi.lib
includelib gdi32.lib
includelib gdiplus.lib

; 声明自己写的函数
change_sun		PROTO, :DWORD		
change_money		PROTO, :DWORD

freeze_cardCD		PROTO
infinite_bug_spary		PROTO
infinite_fertilizer		PROTO
infinite_chocolates		PROTO
infinite_tree_food		PROTO

get_pvz_base_addr	PROTO,pointer_hWnd_pro:DWORD,pointer_model_base_addr:DWORD	

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Pvz修改器",0 
MenuName db "FirstMenu",0 
ButtonClassName db "button",0 
ButtonText db "修改阳光",0 
ButtonTextMoney db "修改金钱(x10)",0 
ButtonTextTreeh db "修改智慧树高度",0 
ButtonTextAdven db "修改当前冒险关卡",0 
ButtonTextBug db "杀虫剂无限",0 
ButtonTextFertilizer db "肥料无限",0 
ButtonTextTree db "智慧树肥料无限",0 
ButtonTextChoco db "巧克力无限",0 
ButtonTextCard db "卡牌无冷却",0 
ButtonTextDebug db "取消杀虫剂无限",0 
ButtonTextDefertilizer db "取消肥料无限",0 
ButtonTextDetree db "取消智慧树肥料无限",0 
ButtonTextDechoco db "取消巧克力无限",0 
ButtonTextDecard db "取消卡牌无冷却",0 
EditClassName db "edit",0 
TestString db "Wow! I'm in an edit box now",0 
buffer db "阳光值改为", 512 DUP(0)     
bufferMoney db "金币值改为", 512 DUP(0)   
bufferTreeh db "树高度改为", 512 DUP(0)   
bufferAdven db "关卡值改为", 512 DUP(0)   
bufferfail db "阳光值修改失败！", 0
bufferfailMoney db "金币值修改失败！", 0
bufferfailTreeh db "树高度修改失败！", 0
bufferfailAdven db "关卡值修改失败！", 0
bufferNumAdven db "关卡值不能超过6-1！", 0
fontBlack		db "微软雅黑", 0 
middle		db "-", 0 
pvz_title		byte	"Plants vs. Zombies",0
BugChange       byte    0
FertilizerChange byte   0
TreeChange		byte    0
ChocoChange     byte    0
CardChange      byte    0
;element			DWORD   COLOR_BACKGROUND
GpInput       GdiplusStartupInput<1,0,0,0>

.data? 
;hdc	      HDC       ?
;crColor   COLORREF  ?
font	  HFONT     ?
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndButton HWND ? 
hwndEdit HWND ?     
hwndFocus HWND ?     
hwndButtonMoney HWND ? 
hwndEditMoney HWND ?  
hwndButtonTreeh HWND ?     
hwndEditTreeh HWND ?   
hwndButtonAdven HWND ?     
hwndEditAdven HWND ?   
hwndEditAdven2 HWND ?   
hwndButtonBug HWND ?     
hwndButtonFertilizer HWND ?     
hwndButtonTree HWND ?     
hwndButtonChoco HWND ?     
hwndButtonCard HWND ?    
bufferInt db 512 dup(?)
Newsun DWORD ?
Newmoney DWORD ?
Newtreeh DWORD ?
Newadven DWORD ?
hToken DWORD ?

.const 
ButtonID equ 1                                ; The control ID of the button control 
ButtonMoneyID equ 6  
ButtonBugID equ 7
ButtonFertilizerID equ 8 
ButtonTreeID equ 9  
ButtonChocoID equ 10 
ButtonCardID equ 11  
ButtonAdvenID equ 12
ButtonTreehID   equ 13
EditID equ 2                                    ; The control ID of the edit control 
IDM_HELLO equ 1 
IDM_CLEAR equ 2 
IDM_GETTEXT equ 3 
IDM_GETTEXT_MONEY equ 5 
IDM_GETTEXT_TREEH equ 16
IDM_GETTEXT_ADVEN equ 17
IDM_EXIT equ 4 


.code 
Str_concat PROC, target:DWORD, source:DWORD
	mov edi, target
	mov ecx, 10
next:
	inc edi
	cmp byte ptr [edi], 0
	loop next
	mov esi, source
next2:
	mov al, byte ptr [esi]
	mov byte ptr [edi], al
	inc edi
	inc esi
	cmp al, 0
	loopnz next2
	ret
Str_concat ENDP

Str_concat_not_fixed PROC, target:DWORD, source:DWORD
	mov edi, target
	mov ecx, 100
next:
	inc edi
	cmp byte ptr [edi], 0
	loopnz next
	mov esi, source
next2:
	mov al, byte ptr [esi]
	mov byte ptr [edi], al
	inc edi
	inc esi
	cmp al, 0
	loopnz next2
	ret
Str_concat_not_fixed ENDP

Int_Change PROC, source: DWORD
	mov edi, source
	mov eax, 0
next:
	mov bl, byte ptr [edi]
	and ebx, 000000FFh
	sub ebx, '0'
	add eax, ebx
	inc edi
	cmp byte ptr [edi], 0
	jz quit
	mov ebx, 10
	mul ebx
	loop next
quit:
	ret
Int_Change ENDP

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_BACKGROUND 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,106
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        300,680,NULL,NULL, hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_CREATE 
		invoke GetStockObject, SYSTEM_FONT
		;invoke CreateFontA, -15, -7.5, 0, 0, 400, 0, 0, 0, GB2312_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, fontBlack
		mov font, eax
		invoke SetTimer,hWnd, 1, 1000, NULL				; 设置计时器
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,35,200,25,hWnd,8,hInstance,NULL 
        mov  hwndEdit,eax 
        invoke SetFocus, hwndEdit 
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,70,140,25,hWnd,ButtonID,hInstance,NULL 
        mov  hwndButton,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,135,200,25,hWnd,8,hInstance,NULL 
        mov  hwndEditMoney,eax 
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextMoney,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,170,140,25,hWnd,ButtonMoneyID,hInstance,NULL 
        mov  hwndButtonMoney,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextBug,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,220,140,25,hWnd,ButtonBugID,hInstance,NULL 
        mov  hwndButtonBug,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextFertilizer,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,270,140,25,hWnd,ButtonFertilizerID,hInstance,NULL 
        mov  hwndButtonFertilizer,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextTree,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,320,140,25,hWnd,ButtonTreeID,hInstance,NULL 
        mov  hwndButtonTree,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextChoco,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,370,140,25,hWnd,ButtonChocoID,hInstance,NULL 
        mov  hwndButtonChoco,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextCard,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,420,140,25,hWnd,ButtonCardID,hInstance,NULL 
        mov  hwndButtonCard,eax 
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,470,200,25,hWnd,8,hInstance,NULL 
        mov  hwndEditTreeh,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextTreeh,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,510,140,25,hWnd,ButtonTreehID,hInstance,NULL 
        mov  hwndButtonTreeh,eax 
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,550,90,25,hWnd,8,hInstance,NULL 
        mov  hwndEditAdven,eax 
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        160,550,90,25,hWnd,8,hInstance,NULL 
        mov  hwndEditAdven2,eax 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextAdven,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,600,140,25,hWnd,ButtonAdvenID,hInstance,NULL 
        mov  hwndButtonAdven,eax 
		invoke SendMessage, hwndButtonAdven, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonTreeh, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonCard, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonChoco, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonTree, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonFertilizer, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonBug, WM_SETFONT, font, 1
		invoke SendMessage, hwndButtonMoney, WM_SETFONT, font, 1
		invoke SendMessage, hwndButton, WM_SETFONT, font, 1
	.ELSEIF uMsg==WM_TIMER			; 处理计时器事件
		;invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
		.IF BugChange == 1
			;invoke Endlessbug
			invoke	infinite_bug_spary
		.ENDIF
		.IF FertilizerChange == 1
			;invoke EndlessFertilizer
			invoke	infinite_fertilizer
		.ENDIF
		.IF TreeChange == 1
			;invoke EndlessTree
			invoke	infinite_tree_food
		.ENDIF
		.IF ChocoChange == 1
			;invoke EndlessChoco
			invoke	infinite_chocolates
		.ENDIF
		.IF CardChange == 1
			;invoke InstantCard
			invoke	freeze_cardCD
		.ENDIF
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_HELLO 
                invoke SetWindowText,hwndEdit,ADDR TestString 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetWindowText,hwndEdit,NULL 
            .ELSEIF  ax==IDM_GETTEXT 
                invoke GetWindowText,hwndEdit,ADDR bufferInt,512 
				invoke Str_concat,ADDR buffer,ADDR bufferInt
				invoke Int_Change,ADDR bufferInt
				mov Newsun, eax
				;invoke Change_sunshine, Newsun
				mov eax, 1 ;For testing
				invoke change_sun, Newsun
				.IF eax==1
					invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
				.ELSE
					invoke MessageBox,NULL,ADDR bufferfail,ADDR AppName,MB_OK 
				.ENDIF
			.ELSEIF  ax==IDM_GETTEXT_MONEY
                invoke GetWindowText,hwndEditMoney,ADDR bufferInt,512 
				invoke Str_concat,ADDR bufferMoney,ADDR bufferInt
				invoke Int_Change,ADDR bufferInt
				mov Newmoney, eax
				;invoke Change_money, Newmoney
				mov eax, 1 ;For testing
				invoke change_money, Newmoney
				.IF eax==1
					invoke MessageBox,NULL,ADDR bufferMoney,ADDR AppName,MB_OK 
				.ELSE
					invoke MessageBox,NULL,ADDR bufferfailMoney,ADDR AppName,MB_OK 
				.ENDIF
			.ELSEIF  ax==IDM_GETTEXT_TREEH
                invoke GetWindowText,hwndEditTreeh,ADDR bufferInt,512 
				invoke Str_concat,ADDR bufferTreeh,ADDR bufferInt
				invoke Int_Change,ADDR bufferInt
				mov Newtreeh, eax
				;invoke Change_treeh, Newtreeh
				mov eax, 1 ;For testing
				.IF eax==1
					invoke MessageBox,NULL,ADDR bufferTreeh,ADDR AppName,MB_OK 
				.ELSE
					invoke MessageBox,NULL,ADDR bufferfailTreeh,ADDR AppName,MB_OK 
				.ENDIF
			.ELSEIF  ax==IDM_GETTEXT_ADVEN
                invoke GetWindowText,hwndEditAdven,ADDR bufferInt,512 
				invoke Str_concat,ADDR bufferAdven,ADDR bufferInt
				invoke Int_Change,ADDR bufferInt
				sub eax, 1
				mov ebx, 10
				mul ebx
				mov Newadven, eax
				invoke GetWindowText,hwndEditAdven2,ADDR bufferInt,512 
				invoke Str_concat_not_fixed,ADDR bufferAdven,ADDR middle
				invoke Str_concat_not_fixed,ADDR bufferAdven,ADDR bufferInt
				invoke Int_Change,ADDR bufferInt
				add Newadven, eax
				.IF Newadven <= 51
					;invoke Change_adven, Newadven
					mov eax, 1 ;For testing
					.IF eax==1
						invoke MessageBox,NULL,ADDR bufferAdven,ADDR AppName,MB_OK					
					.ELSE
						invoke MessageBox,NULL,ADDR bufferfailAdven,ADDR AppName,MB_OK 
					.ENDIF
				.ELSE
					invoke MessageBox,NULL,ADDR bufferNumAdven,ADDR AppName,MB_OK 
				.ENDIF
            .ELSE 
                invoke DestroyWindow,hWnd 
            .ENDIF 
        .ELSE 
            .IF ax==ButtonID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT,0 
                .ENDIF 
			.ELSEIF ax==ButtonMoneyID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT_MONEY,0 
                .ENDIF 
			.ELSEIF ax==ButtonTreehID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT_TREEH,0 
                .ENDIF 
			.ELSEIF ax==ButtonAdvenID
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT_ADVEN,0 
                .ENDIF 
			.ELSEIF ax==ButtonBugID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    .IF BugChange == 0
						mov al, 1
						mov BugChange, al
						;invoke  GetDC, hwndButtonBug
						;mov hdc, eax
						;mov crColor, 000000FFh
						;invoke  SetTextColor, hdc, crColor
						;invoke  SetSysColors, 1, ADDR element, ADDR crColor
						invoke  SetWindowText, hwndButtonBug, ADDR ButtonTextDebug
					.ElSE
						mov al, 0
						mov BugChange, al
						invoke  SetWindowText, hwndButtonBug, ADDR ButtonTextBug
					.ENDIF
                .ENDIF 
			.ELSEIF ax==ButtonFertilizerID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    .IF FertilizerChange == 0
						mov al, 1
						mov FertilizerChange, al
						invoke  SetWindowText, hwndButtonFertilizer, ADDR ButtonTextDefertilizer
					.ElSE
						mov al, 0
						mov FertilizerChange, al
						invoke  SetWindowText, hwndButtonFertilizer, ADDR ButtonTextFertilizer
					.ENDIF
                .ENDIF 
			.ELSEIF ax==ButtonTreeID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    .IF TreeChange == 0
						mov al, 1
						mov TreeChange, al
						invoke  SetWindowText, hwndButtonTree, ADDR ButtonTextDetree
					.ElSE
						mov al, 0
						mov TreeChange, al
						invoke  SetWindowText, hwndButtonTree, ADDR ButtonTextTree
					.ENDIF
                .ENDIF 
			.ELSEIF ax==ButtonChocoID 
                shr eax,16 
                .IF ax==BN_CLICKED 
					.IF ChocoChange == 0
						mov al, 1
						mov ChocoChange, al
						invoke  SetWindowText, hwndButtonChoco, ADDR ButtonTextDechoco
					.ElSE
						mov al, 0
						mov ChocoChange, al
						invoke  SetWindowText, hwndButtonChoco, ADDR ButtonTextChoco
					.ENDIF
                .ENDIF 
			.ELSEIF ax==ButtonCardID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    .IF CardChange == 0
						mov al, 1
						mov CardChange, al
						invoke  SetWindowText, hwndButtonCard, ADDR ButtonTextDecard
					.ElSE
						mov al, 0
						mov CardChange, al
						invoke  SetWindowText, hwndButtonCard, ADDR ButtonTextCard
					.ENDIF
                .ENDIF 
            .ENDIF 
        .ENDIF 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
     xor    eax,eax 
    ret 
WndProc endp 


; 函数get_pvz_base_addr需要两个参数，获得进程的句柄和模块的基址。
get_pvz_base_addr PROC,
				pointer_hWnd_pro:DWORD,	;传入参数，存放进程的句柄
				pointer_model_base_addr:DWORD	;传入参数，存放模块的基址
				local	hWnd_pvz:DWORD	;窗口句柄
				local	pro_id:DWORD	;进程id
				local	hWnd_pro:DWORD	;进程的句柄，实际上是一个句柄
				local	model_base_addr:DWORD	;模块的基址
				local	model_num:SDWORD	; 模块数量
				local	success:DWORD	;是否成功找到了基址
				push	ebx
				push	esi
				push	edi
				; 初始化，成功找到基址
				mov		success,1
				;开始依次寻找
try_find_handle:
				; 01首先找到句柄
				mov		eax,0
				mov		hWnd_pvz, eax
                invoke	FindWindow, 0, offset pvz_title
				.IF	eax == 0
					;invoke	printf, offset msg_not_found_hwnd
					mov		success,0
					jmp		quit_get_pvz_base_addr
				.ELSE
					mov		hWnd_pvz, eax
					;invoke	printf, offset msg_found_hwnd, hWnd_pvz
				.ENDIF
try_find_process_id:
				; 02尝试找到进程id
				lea		edx, pro_id
				invoke	GetWindowThreadProcessId, hWnd_pvz, edx
				mov		eax, pro_id
				.IF eax == 0
					;invoke	printf, offset msg_not_found_pro
					mov		success,0
					jmp		quit_get_pvz_base_addr
				.ELSE
					;invoke	printf, offset msg_found_pro, pro_id
				.ENDIF
try_find_pro_handle:
				;03找到这个进程的句柄，它和窗口句柄不是一个东西
				invoke	OpenProcess,3Ah,0,pro_id
				mov		hWnd_pro,eax
				.IF		eax == 0
					;invoke	printf, offset msg_not_found_prohwnd
					mov		success,0
					jmp	quit_get_pvz_base_addr
				.ELSE
					;invoke	printf, offset msg_found_prohwnd, hWnd_pro
				.ENDIF
try_find_model_base_addr:
				; 04找到每个模块的基址，这里试图仅仅找一个，因为pvz的第一个基址就是我们想要的
				mov		eax,0
				mov		esi,0
				mov		model_base_addr, esi		;初始化为空
				invoke	EnumProcessModules, hWnd_pro, addr model_base_addr, TYPE DWORD, addr model_num
				.IF		eax == 0	; 返回值为0表示失败了
					;invoke	printf, offset msg_not_found_model
					;mov		success,0
					;jmp	quit_get_pvz_base_addr
				.ELSE
					;invoke	printf, offset msg_found_model, model_base_addr
				.ENDIF
quit_get_pvz_base_addr:
				mov		esi,pointer_hWnd_pro
				mov		edi,pointer_model_base_addr
				.IF		success == 0
					mov	eax,0
					mov [esi],eax
					mov	[edi],eax
				.ELSE
					mov eax, hWnd_pro
					mov	[esi],eax					
					mov eax, model_base_addr
					mov	[edi],eax
				.ENDIF
				pop		edi
				pop		esi
				pop		ebx
				ret
get_pvz_base_addr ENDP

; 函数change_sun需要一个参数表示新的阳光，如果成功就eax==1，否则eax==0
change_sun PROC,
				new_sun_value:DWORD			; 阳光的新数值
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	sun_addr:DWORD		; 存放阳光的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	sun_value:DWORD		; 阳光的当前值

				push	ebx
				push	esi
				push	edi
				
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_change_sun
				.ENDIF
				;修改阳光
				mov		esi,base_addr
				mov		sun_addr, esi
				add		sun_addr, 00331C50h			; sun_addr 是阳光基址
				; 01 读取内存,并且直接用读到的数值更新sun_addr
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_addr, TYPE DWORD, 0
				mov		esi, sun_addr
				add		esi, 868h
				mov		sun_addr, esi
				; 02 读取内存,并且直接用读到的数值更新sun_addr
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_addr, TYPE DWORD, 0
				mov		esi, sun_addr
				add		esi, 5578h
				mov		sun_addr, esi
				; 03 读取内存,此时sun_addr处的内容就是阳光的数值
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)sun_addr, &new_sun_value, 4, 0); //修改阳光
				invoke	WriteProcessMemory, hWnd_pro, sun_addr, addr new_sun_value, TYPE DWORD, 0

quit_change_sun:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
change_sun ENDP

; 函数change_money需要一个参数表示新的金钱，如果成功就eax==1，否则eax==0
change_money PROC,
				new_money_value:DWORD			; 金钱的新数值
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	money_addr:DWORD		; 存放金钱的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	money_value:DWORD		; 金钱的当前值

				push	ebx
				push	esi
				push	edi
				
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_change_money
				.ENDIF
				;修改金钱
				mov		esi,base_addr
				mov		money_addr, esi
				add		money_addr, 00331C50h			; money_addr 是金钱基址
				; 01 读取内存,并且直接用读到的数值更新money_addr
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_addr, TYPE DWORD, 0
				mov		esi, money_addr
				add		esi, 94ch
				mov		money_addr, esi
				; 02 读取内存,并且直接用读到的数值更新money_addr
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_addr, TYPE DWORD, 0
				mov		esi, money_addr
				add		esi, 54h
				mov		money_addr, esi
				; 03 读取内存,此时money_addr处的内容就是金钱的数值
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)money_addr, &new_money_value, 4, 0); //修改金钱
				invoke	WriteProcessMemory, hWnd_pro, money_addr, addr new_money_value, TYPE DWORD, 0

quit_change_money:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
change_money ENDP

; 函数change_cardCD修改卡槽冷却，如果成功就eax==1，否则eax==0
freeze_cardCD PROC
				local	new_cardCD_value:DWORD			; 的新数值
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	cardCD_addr:DWORD		; 存放金钱的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	cardCD_value:DWORD		; 金钱的当前值

				push	ebx
				push	esi
				push	edi
				
				mov		new_cardCD_value,10000
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_freeze_cardCD
				.ENDIF
				;修改金钱
				mov		esi,base_addr
				mov		cardCD_addr, esi
				add		cardCD_addr, 00331C50h			; cardCD_addr 是金钱基址
				; 01 读取内存,并且直接用读到的数值更新
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 868h
				mov		cardCD_addr, esi
				; 02 读取内存,并且直接用读到的数值更新
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 15ch
				mov		cardCD_addr, esi
				; 03 读取内存,并且直接用读到的数值更新
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 4ch
				mov		cardCD_addr, esi
				; 04 读取内存,此时cardCD_addr处的内容就是第一个卡槽的cd数值
				; 加 50h 是下一个卡槽
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_value, TYPE DWORD, 0
				; 05 写入内存, 循环多次
				mov		ecx, 10
cardCD_L1:
				push	ecx
				invoke	WriteProcessMemory, hWnd_pro, cardCD_addr, addr new_cardCD_value, TYPE DWORD, 0
				mov		edi, cardCD_addr
				add		edi, 50h			; 两个卡槽CD间隔是 0x50
				mov		cardCD_addr, edi
				pop		ecx
				loop	cardCD_L1

quit_freeze_cardCD:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
freeze_cardCD ENDP

; 无限杀虫剂
infinite_bug_spary PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	target_addr:DWORD		; 存放目标的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	target_value:DWORD		; 目标的当前值
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_infinite_bug_spary
				.ENDIF
				;修改目标
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr 是目标基址
				; 01 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 228h
				mov		target_addr, esi
				; 03 读取内存,此时target_addr处的内容就是目标的数值
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //修改目标
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_bug_spary:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_bug_spary ENDP

; 无限肥料
infinite_fertilizer PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	target_addr:DWORD		; 存放目标的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	target_value:DWORD		; 目标的当前值
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_infinite_fertilizer
				.ENDIF
				;修改目标
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr 是目标基址
				; 01 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 224h
				mov		target_addr, esi
				; 03 读取内存,此时target_addr处的内容就是目标的数值
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //修改目标
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_fertilizer:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_fertilizer ENDP

; 无限巧克力
infinite_chocolates PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	target_addr:DWORD		; 存放目标的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	target_value:DWORD		; 目标的当前值
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_infinite_chocolates
				.ENDIF
				;修改目标
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr 是目标基址
				; 01 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 254h
				mov		target_addr, esi
				; 03 读取内存,此时target_addr处的内容就是目标的数值
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //修改目标
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_chocolates:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_chocolates ENDP

; 无限树的肥料
infinite_tree_food PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; 存放基址
				local	hWnd_pro:DWORD		; 存放进程的句柄
				local	target_addr:DWORD		; 存放目标的地址
				local	success:DWORD	;获取基址和句柄是否成功
				local	target_value:DWORD		; 目标的当前值
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;默认成功
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;获取失败
					jmp	quit_infinite_tree_food
				.ENDIF
				;修改目标
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr 是目标基址
				; 01 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 读取内存,并且直接用读到的数值更新target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 25Ch
				mov		target_addr, esi
				; 03 读取内存,此时target_addr处的内容就是目标的数值
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 写入内存
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //修改目标
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_tree_food:
				mov		eax, success		; 返回值设置为是否成功
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_tree_food ENDP


start: 
	invoke GdiplusStartup, ADDR hToken, ADDR GpInput, NULL
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
	invoke GdiplusShutdown,hToken
    invoke ExitProcess,eax 
	ret
end start 
