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
get_pvz_base_addr	PROTO,pointer_hWnd_pro:DWORD,pointer_model_base_addr:DWORD	

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Pvz�޸���",0 
MenuName db "FirstMenu",0 
ButtonClassName db "button",0 
ButtonText db "�޸�����",0 
ButtonTextMoney db "�޸Ľ�Ǯ",0 
EditClassName db "edit",0 
TestString db "Wow! I'm in an edit box now",0 
buffer db "����ֵ��Ϊ", 512 DUP(0)     
bufferMoney db "���ֵ��Ϊ", 512 DUP(0)     
bufferfail db "����ֵ�޸�ʧ�ܣ�", 0
bufferfailMoney db "���ֵ�޸�ʧ�ܣ�", 0
pvz_title		byte	"Plants vs. Zombies",0

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndButton HWND ? 
hwndEdit HWND ?     
hwndButtonMoney HWND ? 
hwndEditMoney HWND ?     
bufferInt db 512 dup(?) ; buffer to store the text retrieved from the edit box
Newsun DWORD ?
Newmoney DWORD ?

.const 
ButtonID equ 1                                ; The control ID of the button control 
ButtonMoneyID equ 6   
EditID equ 2                                    ; The control ID of the edit control 
IDM_HELLO equ 1 
IDM_CLEAR equ 2 
IDM_GETTEXT equ 3 
IDM_GETTEXT_MONEY equ 5 
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
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        300,300,NULL,NULL, hInst,NULL 
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
	.ELSEIF uMsg==WM_TIMER			; �����ʱ���¼�
		invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
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

start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 


end start 
