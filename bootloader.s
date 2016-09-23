				PRESERVE8
				AREA RESET,CODE,READONLY
				ARM
				IMPORT main
				IMPORT |Image$$SDZI$$ZI$$Limit|
				IMPORT |Image$$SDZI$$ZI$$Base|
START
CLOCK_BASE      EQU     0x4C000000      ; Clock Base Address
LOCKTIME_OFS    EQU     0x00            ; PLL Lock Time Count Register   Offset
MPLLCON_OFS     EQU     0x04            ; M PLL Configuration Register    Offset
UPLLCON_OFS     EQU     0x08            ; UPLL Configuration Register    Offset
CLKCON_OFS      EQU     0x0C            ; Clock Generator Control Reg    Offset
CLKSLOW_OFS     EQU     0x10            ; Clock Slow Control Register    Offset
CLKDIVN_OFS     EQU     0x14            ; Clock Divider Control Register Offset
CAMDIVN_OFS     EQU     0x18            ; Camera Clock Divider Register  Offset

LOCKTIME_Val    EQU     0x0FFF0FFF
;MPLL=2*m*Fin/(p*2S)	m=MDIV+8(75), p=PDIV+2, s=SDIV	   	
MPLLCON_Val     EQU     0x00043011	;mdiv=0x43(67),pdiv=0x1,sdiv=0x1	mpll=300mhz
;UPLL=(m*Fin)/(p*2S)	m=MDIV+8(64), p=PDIV+2, s=SDIV
UPLLCON_Val     EQU     0x00038021	;mdiv=0x38(56),pdiv=0x2,sdiv=0x1	upll=96mhz
CLKCON_Val      EQU     0x001FFFF0	;睡眠模式空闲模式无效，所有模块都接入时钟
CLKSLOW_Val     EQU     0x00000004	;没有设置,为初始值
CLKDIVN_Val     EQU     0x0000000F	;uclk=upll/2,fclk:hclk:pclk=1:3:6
CAMDIVN_Val     EQU     0x00000000	;没有设置,为初始值

MC_BASE         EQU     0x48000000      ; Memory Controller Base Address
BWSCON_OFS      EQU     0x00            ; Bus Width and Wait Status Ctrl Offset
BANKCON0_OFS    EQU     0x04            ; Bank 0 Control Register        Offset
BANKCON1_OFS    EQU     0x08            ; Bank 1 Control Register        Offset
BANKCON2_OFS    EQU     0x0C            ; Bank 2 Control Register        Offset
BANKCON3_OFS    EQU     0x10            ; Bank 3 Control Register        Offset
BANKCON4_OFS    EQU     0x14            ; Bank 4 Control Register        Offset
BANKCON5_OFS    EQU     0x18            ; Bank 5 Control Register        Offset
BANKCON6_OFS    EQU     0x1C            ; Bank 6 Control Register        Offset
BANKCON7_OFS    EQU     0x20            ; Bank 7 Control Register        Offset
REFRESH_OFS     EQU     0x24            ; SDRAM Refresh Control Register Offset
BANKSIZE_OFS    EQU     0x28            ; Flexible Bank Size Register    Offset
MRSRB6_OFS      EQU     0x2C            ; Bank 6 Mode Register           Offset
MRSRB7_OFS      EQU     0x30            ; Bank 7 Mode Register           Offset

;BWSCON_Val      EQU     0x22000000	;原定义32位bank7bank6，其他8位
BWSCON_Val      EQU     0x22011110	;32位bank7bank6,8位bank5，16位bank1-4,8位bank0,bank4等待、ublb
BANKCON0_Val    EQU     0x00000700
BANKCON1_Val    EQU     0x00000700
BANKCON2_Val    EQU     0x00000700
BANKCON3_Val    EQU     0x00000700
BANKCON4_Val    EQU     0x00000700	;bank没有设置为初始值
BANKCON5_Val    EQU     0x00000700	
BANKCON6_Val    EQU     0x00018005
BANKCON7_Val    EQU     0x00018005	;bank6bank7修改低四位，9位列地址
REFRESH_Val     EQU     0x008404F3	
;REFRESH_Val     EQU		0x008E04EB ;VIVI
;BANKSIZE_Val    EQU     0x00000032	;原定义bank6、7设置为128m，sdram powerdown模式有效，sclk仅在访问周期激活
BANKSIZE_Val    EQU     0x00000031	;bank6、7为64m
;MRSRB6_Val      EQU     0x00000020	;原定义，cas反应时间2clocks
;MRSRB7_Val      EQU     0x00000020
MRSRB6_Val      EQU     0x00000030	;cas反应时间3clocks
MRSRB7_Val      EQU     0x00000030
SDRAM_BASE		EQU		0x33E00000		
				B     	Reset_Addr         
                LDR     PC, =Undef_Addr
                LDR     PC, =SWI_Addr
                LDR     PC, =PAbt_Addr
                LDR     PC, =DAbt_Addr
				LDR		PC,	=HandleNotUsed
				LDR     PC, =IRQ_Addr
                LDR     PC, =FIQ_Addr
Undef_Addr		B		Undef_Addr
SWI_Addr		B		SWI_Addr
PAbt_Addr		B		PAbt_Addr
DAbt_Addr		B		DAbt_Addr
HandleNotUsed	B		HandleNotUsed
IRQ_Addr		B		IRQ_Addr
FIQ_Addr		B		FIQ_Addr

Reset_Addr
				;MSR 	CPSR_C, #0xd3 
				LDR		R0,	=0x53000000		;WATCHDOG
				MOV		R1,	#0

				STR		R1,	[R0]

				LDR     R0, 	 =MC_BASE				;sdram初始化
                LDR     R1,      =BWSCON_Val
                STR     R1, [R0, #BWSCON_OFS]
                LDR     R1,      =BANKCON0_Val
                STR     R1, [R0, #BANKCON0_OFS]
                LDR     R1,      =BANKCON1_Val
                STR     R1, [R0, #BANKCON1_OFS]
                LDR     R1,      =BANKCON2_Val
                STR     R1, [R0, #BANKCON2_OFS]
                LDR     R1,      =BANKCON3_Val
                STR     R1, [R0, #BANKCON3_OFS]
                LDR     R1,      =BANKCON4_Val
                STR     R1, [R0, #BANKCON4_OFS]
                LDR     R1,      =BANKCON5_Val
                STR     R1, [R0, #BANKCON5_OFS]
                LDR     R1,      =BANKCON6_Val
                STR     R1, [R0, #BANKCON6_OFS]
                LDR     R1,      =BANKCON7_Val
                STR     R1, [R0, #BANKCON7_OFS]
                LDR     R1,      =REFRESH_Val
                STR     R1, [R0, #REFRESH_OFS]
                MOV     R1,      #BANKSIZE_Val
                STR     R1, [R0, #BANKSIZE_OFS]
                MOV     R1,      #MRSRB6_Val
                STR     R1, [R0, #MRSRB6_OFS]
                MOV     R1,      #MRSRB7_Val
                STR     R1, [R0, #MRSRB7_OFS]	

				LDR     R0, 	 =CLOCK_BASE			;300:100:50clock
                LDR     R1,      =LOCKTIME_Val
                STR     R1, [R0, #LOCKTIME_OFS]
                MOV     R1,      #CLKDIVN_Val  
                STR     R1, [R0, #CLKDIVN_OFS]
                LDR     R1,      =CAMDIVN_Val
                STR     R1, [R0, #CAMDIVN_OFS]
                LDR     R1,      =MPLLCON_Val
                STR     R1, [R0, #MPLLCON_OFS]
                LDR     R1,      =UPLLCON_Val
                STR     R1, [R0, #UPLLCON_OFS]
                MOV     R1,      #CLKSLOW_Val
                STR     R1, [R0, #CLKSLOW_OFS]
                LDR     R1,      =CLKCON_Val
                STR     R1, [R0, #CLKCON_OFS]
				MRC 	p15,0,r1,c1,c0,0
				ORR 	R1,R1,#0xC0000000
				MCR		p15,0,r1,c1,c0,0
					 
 				ADR		R0, START				;复制代码到sdram
    			LDR 	R1, =SDRAM_BASE
				CMP		R0, R1
				BEQ		STACKSET
    			MOV 	R2, #0x10000				
LOOP    
    			LDMIA	R0!,{R3-R6}
				STMIA	R1!,{R3-R6}
				SUBS	R2,R2,#1     
    			BNE 	LOOP   
STACKSET				 				   
    			MSR 	CPSR_C, #0xd3  
				LDR		SP,	=0x34000000		 ;set supervisor_sp

				LDR  	R0,BSSBAS			 ;CLEAR BSS
				LDR  	R1,BSSLEN
				CMP		R1,#0
				BEQ		JMP_MAIN
CLEAR_ZI		
				MOV		R3,#0
				STR		R3,[R0]
				ADD		R0,R0,#1
				SUBS	R1,R1,#1
				BNE		CLEAR_ZI			 

JMP_MAIN
				LDR		LR,	=HALT
				LDR		PC,	=main 
				;BL		main
HALT										 ;正常不会从main返回，有问题返回则设置蜂鸣器响
				LDR		R0,	=0x56000010
				LDR		R1,	=0x00000001
				STR		R1,	[R0]	;gpb0-output
				LDR		R0,	=0x56000014
				LDR		R1,	=0x1	
				STR		R1,	[R0]	;gbd0-data1
				B		HALT
BSSLEN			DCD 	|Image$$SDZI$$ZI$$Limit| 
BSSBAS			DCD 	|Image$$SDZI$$ZI$$Base| 
				END	
			
