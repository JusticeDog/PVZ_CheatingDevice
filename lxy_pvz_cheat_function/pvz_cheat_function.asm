.386
.model flat, stdcall
option casemap:none

includelib      msvcrt.lib
include		user32.inc
include		kernel32.inc
include		psapi.inc
includelib	user32.lib
includelib	kernel32.lib
includelib	psapi.lib
;includelib	\masm32\lib\user32.lib
;includelib	\masm32\lib\kernel32.lib

printf          PROTO C :ptr sbyte, :VARARG
scanf           PROTO C :ptr sbyte, :VARARG

.data
;msg_handle_is	byte	"����ǣ�%d",0ah, 0dh, 0
msg_found_hwnd			byte	"�ҵ���PVZ���򣬾��: %d",0ah,0dh,0
msg_not_found_hwnd		byte	"û���ҵ�PVZ����",0ah,0dh,0
msg_found_pro			byte	"�ҵ��˽���,����id: %d",0ah,0dh,0
msg_not_found_pro		byte	"û���ҵ�����id",0ah,0dh,0
msg_found_prohwnd		byte	"�ҵ��˽��̾��,���̾��: %d",0ah,0dh,0
msg_not_found_prohwnd	byte	"û���ҵ����̾��",0ah,0dh,0
msg_found_model			byte	"�ҵ���ģ��,ģ���ַ��: 0x%08X",0ah,0dh,0
msg_not_found_model		byte	"û���ҵ�ģ��",0ah,0dh,0
pvz_title		byte	"Plants vs. Zombies",0
msg_debug           byte    "debug:%d", 0ah, 0dh, 0
msg_scanf_int		byte	"%d",0
msg_input_new_sun	byte	"�������µ�������ֵ��",0ah,0dh,0
msg_input_new_money	byte	"�������µĽ�Ǯ��ֵ��",0ah,0dh,0
;szMsg           byte    "�������������֣��ÿո����:", 0ah, 0dh, 0
;scanMsg         byte    "%d %d", 0
;ansMsg          byte    "�����%d", 0ah, 0dh, 0  ; 0ah 0dh�ǻس�����


.code
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
					mov		success,0
					jmp	quit_get_pvz_base_addr
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
change_cardCD PROC
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
					jmp	quit_change_cardCD
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

quit_change_cardCD:
				mov		eax, success		; ����ֵ����Ϊ�Ƿ�ɹ�
				pop		edi
				pop		esi
				pop		ebx
				ret
change_cardCD ENDP

main PROC,
				var1:DWORD
				local	new_sun_value:SDWORD			; ���������ֵ
				local	new_money_value:SDWORD			; money������ֵ
				local	success:DWORD				; �Ƿ�ɹ�

				;mov		new_sun_value, 5000
				;invoke	printf, offset msg_input_new_sun
				;invoke	scanf, offset msg_scanf_int, addr new_sun_value
				;mov		success,0
				;invoke	change_sun,new_sun_value


				;mov		new_money_value, 5000
				;invoke	printf, offset msg_input_new_money
				;invoke	scanf, offset msg_scanf_int, addr new_money_value
				;mov		success,0
				;invoke	change_money,new_money_value

				mov	ecx,10
L_2:
				pushad
				invoke	printf,offset msg_debug, ecx
				invoke	change_cardCD
				popad
				loop	L_2

				
				ret
main ENDP

start:
				invoke	main,0
				ret
end             start
