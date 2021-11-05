.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include windows.inc 
include user32.inc 
include kernel32.inc 
include	psapi.inc
includelib user32.lib 
includelib kernel32.lib 
includelib msvcrt.lib
includelib	psapi.lib


; �����Լ�д�ĺ���
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
AppName  db "Pvz�޸���",0 
MenuName db "FirstMenu",0 
ButtonClassName db "button",0 
ButtonText db "�޸�����",0 
ButtonTextMoney db "�޸Ľ�Ǯ(x10)",0 
ButtonTextTreeh db "�޸��ǻ����߶�",0 
ButtonTextAdven db "�޸ĵ�ǰð�չؿ�",0 
ButtonTextBug db "ɱ�������",0 
ButtonTextFertilizer db "��������",0 
ButtonTextTree db "�ǻ�����������",0 
ButtonTextChoco db "�ɿ�������",0 
ButtonTextCard db "��������ȴ",0 
ButtonTextDebug db "ȡ��ɱ�������",0 
ButtonTextDefertilizer db "ȡ����������",0 
ButtonTextDetree db "ȡ���ǻ�����������",0 
ButtonTextDechoco db "ȡ���ɿ�������",0 
ButtonTextDecard db "ȡ����������ȴ",0 
EditClassName db "edit",0 
TestString db "Wow! I'm in an edit box now",0 
buffer db "����ֵ��Ϊ", 512 DUP(0)     
bufferMoney db "���ֵ��Ϊ", 512 DUP(0)   
bufferTreeh db "���߶ȸ�Ϊ", 512 DUP(0)   
bufferAdven db "�ؿ�ֵ��Ϊ", 512 DUP(0)   
bufferfail db "����ֵ�޸�ʧ�ܣ�", 0
bufferfailMoney db "���ֵ�޸�ʧ�ܣ�", 0
bufferfailTreeh db "���߶��޸�ʧ�ܣ�", 0
bufferfailAdven db "�ؿ�ֵ�޸�ʧ�ܣ�", 0
pvz_title		byte	"Plants vs. Zombies",0
BugChange       byte    0
FertilizerChange byte   0
TreeChange		byte    0
ChocoChange     byte    0
CardChange      byte    0


.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndButton HWND ? 
hwndEdit HWND ?     
hwndButtonMoney HWND ? 
hwndEditMoney HWND ?  
hwndButtonTreeh HWND ?     
hwndEditTreeh HWND ?   
hwndButtonAdven HWND ?     
hwndEditAdven HWND ?   
hwndButtonBug HWND ?     
hwndButtonFertilizer HWND ?     
hwndButtonTree HWND ?     
hwndButtonChoco HWND ?     
hwndButtonCard HWND ?    
bufferInt db 512 dup(?) ; buffer to store the text retrieved from the edit box
Newsun DWORD ?
Newmoney DWORD ?
Newtreeh DWORD ?
Newadven DWORD ?

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
    mov   wc.hbrBackground,COLOR_BTNFACE+1 
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
		invoke SetTimer,hWnd, 1, 1000, NULL				; ���ü�ʱ��
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
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
        invoke SetFocus, hwndEdit 
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
        invoke SetFocus, hwndEditTreeh 
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextTreeh,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,510,140,25,hWnd,ButtonTreehID,hInstance,NULL 
        mov  hwndButtonTreeh,eax 
		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,550,200,25,hWnd,8,hInstance,NULL 
        mov  hwndEditAdven,eax 
        invoke SetFocus, hwndEditAdven
		invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonTextAdven,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,600,140,25,hWnd,ButtonAdvenID,hInstance,NULL 
        mov  hwndButtonAdven,eax 
	.ELSEIF uMsg==WM_TIMER			; �����ʱ���¼�
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
				mov Newadven, eax
				;invoke Change_adven, Newadven
				mov eax, 1 ;For testing
				.IF eax==1
					invoke MessageBox,NULL,ADDR bufferAdven,ADDR AppName,MB_OK					
				.ELSE
					invoke MessageBox,NULL,ADDR bufferfailAdven,ADDR AppName,MB_OK 
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


; ����get_pvz_base_addr��Ҫ������������ý��̵ľ����ģ��Ļ�ַ��
get_pvz_base_addr PROC,
				pointer_hWnd_pro:DWORD,	;�����������Ž��̵ľ��
				pointer_model_base_addr:DWORD	;������������ģ��Ļ�ַ
				local	hWnd_pvz:DWORD	;���ھ��
				local	pro_id:DWORD	;����id
				local	hWnd_pro:DWORD	;���̵ľ����ʵ������һ�����
				local	model_base_addr:DWORD	;ģ��Ļ�ַ
				local	model_num:SDWORD	; ģ������
				local	success:DWORD	;�Ƿ�ɹ��ҵ��˻�ַ
				push	ebx
				push	esi
				push	edi
				; ��ʼ�����ɹ��ҵ���ַ
				mov		success,1
				;��ʼ����Ѱ��
try_find_handle:
				; 01�����ҵ����
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
				; 02�����ҵ�����id
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
				;03�ҵ�������̵ľ�������ʹ��ھ������һ������
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
				; 04�ҵ�ÿ��ģ��Ļ�ַ��������ͼ������һ������Ϊpvz�ĵ�һ����ַ����������Ҫ��
				mov		eax,0
				mov		esi,0
				mov		model_base_addr, esi		;��ʼ��Ϊ��
				invoke	EnumProcessModules, hWnd_pro, addr model_base_addr, TYPE DWORD, addr model_num
				.IF		eax == 0	; ����ֵΪ0��ʾʧ����
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

; ����change_sun��Ҫһ��������ʾ�µ����⣬����ɹ���eax==1������eax==0
change_sun PROC,
				new_sun_value:DWORD			; ���������ֵ
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	sun_addr:DWORD		; �������ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	sun_value:DWORD		; ����ĵ�ǰֵ

				push	ebx
				push	esi
				push	edi
				
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_change_sun
				.ENDIF
				;�޸�����
				mov		esi,base_addr
				mov		sun_addr, esi
				add		sun_addr, 00331C50h			; sun_addr �������ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����sun_addr
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_addr, TYPE DWORD, 0
				mov		esi, sun_addr
				add		esi, 868h
				mov		sun_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����sun_addr
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_addr, TYPE DWORD, 0
				mov		esi, sun_addr
				add		esi, 5578h
				mov		sun_addr, esi
				; 03 ��ȡ�ڴ�,��ʱsun_addr�������ݾ����������ֵ
				invoke	ReadProcessMemory, hWnd_pro, sun_addr, addr sun_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)sun_addr, &new_sun_value, 4, 0); //�޸�����
				invoke	WriteProcessMemory, hWnd_pro, sun_addr, addr new_sun_value, TYPE DWORD, 0

quit_change_sun:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
change_sun ENDP

; ����change_money��Ҫһ��������ʾ�µĽ�Ǯ������ɹ���eax==1������eax==0
change_money PROC,
				new_money_value:DWORD			; ��Ǯ������ֵ
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	money_addr:DWORD		; ��Ž�Ǯ�ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	money_value:DWORD		; ��Ǯ�ĵ�ǰֵ

				push	ebx
				push	esi
				push	edi
				
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_change_money
				.ENDIF
				;�޸Ľ�Ǯ
				mov		esi,base_addr
				mov		money_addr, esi
				add		money_addr, 00331C50h			; money_addr �ǽ�Ǯ��ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����money_addr
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_addr, TYPE DWORD, 0
				mov		esi, money_addr
				add		esi, 94ch
				mov		money_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����money_addr
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_addr, TYPE DWORD, 0
				mov		esi, money_addr
				add		esi, 54h
				mov		money_addr, esi
				; 03 ��ȡ�ڴ�,��ʱmoney_addr�������ݾ��ǽ�Ǯ����ֵ
				invoke	ReadProcessMemory, hWnd_pro, money_addr, addr money_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)money_addr, &new_money_value, 4, 0); //�޸Ľ�Ǯ
				invoke	WriteProcessMemory, hWnd_pro, money_addr, addr new_money_value, TYPE DWORD, 0

quit_change_money:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
change_money ENDP

; ����change_cardCD�޸Ŀ�����ȴ������ɹ���eax==1������eax==0
freeze_cardCD PROC
				local	new_cardCD_value:DWORD			; ������ֵ
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	cardCD_addr:DWORD		; ��Ž�Ǯ�ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	cardCD_value:DWORD		; ��Ǯ�ĵ�ǰֵ

				push	ebx
				push	esi
				push	edi
				
				mov		new_cardCD_value,10000
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_freeze_cardCD
				.ENDIF
				;�޸Ľ�Ǯ
				mov		esi,base_addr
				mov		cardCD_addr, esi
				add		cardCD_addr, 00331C50h			; cardCD_addr �ǽ�Ǯ��ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 868h
				mov		cardCD_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 15ch
				mov		cardCD_addr, esi
				; 03 ��ȡ�ڴ�,����ֱ���ö�������ֵ����
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_addr, TYPE DWORD, 0
				mov		esi, cardCD_addr
				add		esi, 4ch
				mov		cardCD_addr, esi
				; 04 ��ȡ�ڴ�,��ʱcardCD_addr�������ݾ��ǵ�һ�����۵�cd��ֵ
				; �� 50h ����һ������
				invoke	ReadProcessMemory, hWnd_pro, cardCD_addr, addr cardCD_value, TYPE DWORD, 0
				; 05 д���ڴ�, ѭ�����
				mov		ecx, 10
cardCD_L1:
				push	ecx
				invoke	WriteProcessMemory, hWnd_pro, cardCD_addr, addr new_cardCD_value, TYPE DWORD, 0
				mov		edi, cardCD_addr
				add		edi, 50h			; ��������CD����� 0x50
				mov		cardCD_addr, edi
				pop		ecx
				loop	cardCD_L1

quit_freeze_cardCD:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
freeze_cardCD ENDP

; ����ɱ���
infinite_bug_spary PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	target_addr:DWORD		; ���Ŀ��ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	target_value:DWORD		; Ŀ��ĵ�ǰֵ
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_infinite_bug_spary
				.ENDIF
				;�޸�Ŀ��
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr ��Ŀ���ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 228h
				mov		target_addr, esi
				; 03 ��ȡ�ڴ�,��ʱtarget_addr�������ݾ���Ŀ�����ֵ
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //�޸�Ŀ��
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_bug_spary:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_bug_spary ENDP

; ���޷���
infinite_fertilizer PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	target_addr:DWORD		; ���Ŀ��ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	target_value:DWORD		; Ŀ��ĵ�ǰֵ
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_infinite_fertilizer
				.ENDIF
				;�޸�Ŀ��
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr ��Ŀ���ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 224h
				mov		target_addr, esi
				; 03 ��ȡ�ڴ�,��ʱtarget_addr�������ݾ���Ŀ�����ֵ
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //�޸�Ŀ��
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_fertilizer:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_fertilizer ENDP

; �����ɿ���
infinite_chocolates PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	target_addr:DWORD		; ���Ŀ��ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	target_value:DWORD		; Ŀ��ĵ�ǰֵ
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_infinite_chocolates
				.ENDIF
				;�޸�Ŀ��
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr ��Ŀ���ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 254h
				mov		target_addr, esi
				; 03 ��ȡ�ڴ�,��ʱtarget_addr�������ݾ���Ŀ�����ֵ
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //�޸�Ŀ��
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_chocolates:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_chocolates ENDP

; �������ķ���
infinite_tree_food PROC
				local	new_target_value:DWORD
				local	base_addr:DWORD		; ��Ż�ַ
				local	hWnd_pro:DWORD		; ��Ž��̵ľ��
				local	target_addr:DWORD		; ���Ŀ��ĵ�ַ
				local	success:DWORD	;��ȡ��ַ�;���Ƿ�ɹ�
				local	target_value:DWORD		; Ŀ��ĵ�ǰֵ
				push	ebx
				push	esi
				push	edi
				mov		new_target_value, 1020
				mov		success,1	;Ĭ�ϳɹ�
				invoke	get_pvz_base_addr,addr hWnd_pro, addr base_addr
				.IF		hWnd_pro == 0
					mov		success,0
				.ENDIF
				.IF		base_addr == 0
					mov		success,0
				.ENDIF
				.IF		success == 0	;��ȡʧ��
					jmp	quit_infinite_tree_food
				.ENDIF
				;�޸�Ŀ��
				mov		esi,base_addr
				mov		target_addr, esi
				add		target_addr, 00331C50h			; target_addr ��Ŀ���ַ
				; 01 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 94ch
				mov		target_addr, esi
				; 02 ��ȡ�ڴ�,����ֱ���ö�������ֵ����target_addr
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_addr, TYPE DWORD, 0
				mov		esi, target_addr
				add		esi, 25Ch
				mov		target_addr, esi
				; 03 ��ȡ�ڴ�,��ʱtarget_addr�������ݾ���Ŀ�����ֵ
				invoke	ReadProcessMemory, hWnd_pro, target_addr, addr target_value, TYPE DWORD, 0
				; 04 д���ڴ�
				; WriteProcessMemory(hpro, (LPVOID)target_addr, &new_target_value, 4, 0); //�޸�Ŀ��
				invoke	WriteProcessMemory, hWnd_pro, target_addr, addr new_target_value, TYPE DWORD, 0
quit_infinite_tree_food:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
infinite_tree_food ENDP


start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 
	ret
end start 
