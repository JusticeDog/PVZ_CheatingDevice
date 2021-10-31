.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include windows.inc 
include user32.inc 
include kernel32.inc 
includelib user32.lib 
includelib kernel32.lib 
includelib msvcrt.lib

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Pvz修改器",0 
MenuName db "FirstMenu",0 
ButtonClassName db "button",0 
ButtonText db "修改阳光",0 
EditClassName db "edit",0 
TestString db "Wow! I'm in an edit box now",0 
buffer db "阳光值改为", 512 DUP(0)     
bufferfail db "阳光值修改失败！", 0

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndButton HWND ? 
hwndEdit HWND ?     
buffer2 db 512 dup(?) ; buffer to store the text retrieved from the edit box
Newsun DWORD ?

.const 
ButtonID equ 1                                ; The control ID of the button control 
EditID equ 2                                    ; The control ID of the edit control 
IDM_HELLO equ 1 
IDM_CLEAR equ 2 
IDM_GETTEXT equ 3 
IDM_EXIT equ 4 


.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

Str_concat PROC, target:DWORD, source:DWORD
	mov edi, target
	mov ecx, 15
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
                        300,200,NULL,NULL, hInst,NULL 
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
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_HELLO 
                invoke SetWindowText,hwndEdit,ADDR TestString 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetWindowText,hwndEdit,NULL 
            .ELSEIF  ax==IDM_GETTEXT 
                invoke GetWindowText,hwndEdit,ADDR buffer2,512 
				invoke Str_concat,ADDR buffer,ADDR buffer2
				invoke Int_Change,ADDR buffer2
				mov Newsun, eax
				;invoke Change_sunshine, Newsun
				mov eax, 0 ;For testing
				.IF eax==0
					invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
				.ELSE
					invoke MessageBox,NULL,ADDR bufferfail,ADDR AppName,MB_OK 
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
            .ENDIF 
        .ENDIF 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
     xor    eax,eax 
    ret 
WndProc endp 
end start 
