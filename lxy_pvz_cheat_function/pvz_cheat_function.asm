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
;msg_handle_is	byte	"句柄是：%d",0ah, 0dh, 0
msg_found_hwnd			byte	"找到了PVZ程序，句柄: %d",0ah,0dh,0
msg_not_found_hwnd		byte	"没有找到PVZ程序",0ah,0dh,0
msg_found_pro			byte	"找到了进程,进程id: %d",0ah,0dh,0
msg_not_found_pro		byte	"没有找到进程id",0ah,0dh,0
msg_found_prohwnd		byte	"找到了进程句柄,进程句柄: %d",0ah,0dh,0
msg_not_found_prohwnd	byte	"没有找到进程句柄",0ah,0dh,0
msg_found_model			byte	"找到了模块,模块基址是: 0x%08X",0ah,0dh,0
msg_not_found_model		byte	"没有找到模块",0ah,0dh,0
pvz_title		byte	"Plants vs. Zombies",0
msg_debug           byte    "debug:%d", 0ah, 0dh, 0
msg_scanf_int		byte	"%d",0
msg_input_new_sun	byte	"请输入新的阳光数值：",0ah,0dh,0
msg_input_new_money	byte	"请输入新的金钱数值：",0ah,0dh,0
;szMsg           byte    "请输入两个数字，用空格隔开:", 0ah, 0dh, 0
;scanMsg         byte    "%d %d", 0
;ansMsg          byte    "结果是%d", 0ah, 0dh, 0  ; 0ah 0dh是回车换行


.code
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


main PROC,
				var1:DWORD
				local	new_sun_value:SDWORD			; 阳光的新数值
				local	new_money_value:SDWORD			; money的新数值
				local	success:DWORD				; 是否成功

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
				invoke	infinite_bug_spary
				invoke	infinite_fertilizer
				invoke	infinite_chocolates
				invoke	infinite_tree_food
				popad
				loop	L_2

				
				ret
main ENDP

start:
				invoke	main,0
				ret
end             start
