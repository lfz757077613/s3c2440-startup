#include<S3C2440.h>
#define uchar unsigned char 
#define uint unsigned int
#define LED1_ON   ~(1<<5)
#define LED2_ON   ~(1<<6)
#define LED3_ON   ~(1<<7)
#define LED4_ON   ~(1<<8)
#define LED1_OFF   (1<<5)
#define LED2_OFF   (1<<6)
#define LED3_OFF   (1<<7)
#define LED4_OFF   (1<<8)
#define TACLS   2
#define TWRPH0  2
#define TWRPH1  0
extern uint Image$$SDZI$$ZI$$Base;
extern uint Image$$SDZI$$ZI$$Limit;
extern uint Image$$SDZI$$ZI$$Length;
extern uint Image$$SDNOR$$Limit;
extern uint Image$$SDRW$$Base;
void clear_zi(void);
void uart0_init(void);
void putc(uchar c);
void puts(char *str);
void puthex(uint val);
void nand_init(void);
void nand_select(void);
void nand_deselect(void);
void nand_addr(uint addr);
void nand_cmd(uchar cmd);
void nand_wait_ready(void);
uchar nand_data(void);
void nand_reset(void);
void setup_start_tag(void);
void setup_memory_tags(void);
void nand_read(uint addr, uchar *buf, uint len);
void setup_commandline_tag(char *cmdline);
void setup_end_tag(void);
void dely(int tt);
uchar strlen(char *str);
void strcpy(char *dest, char *src);
static struct tag *params;
struct tag_header {
	uint size;
	uint tag;
};
struct tag_core {
	uint flags;		/* bit 0 = read-only */
	uint pagesize;
	uint rootdev;
};
struct tag_mem32 {
	uint	size;
	uint	start;	/* physical start address */
};
struct tag_cmdline {
	char	cmdline[1];	/* this is the minimum size */
};
struct tag {
	struct tag_header hdr;
	union {
		struct tag_core		core;
		struct tag_mem32	mem;
		//struct tag_videotext	videotext;
		//struct tag_ramdisk	ramdisk;
		//struct tag_initrd	initrd;
		//struct tag_serialnr	serialnr;
		//struct tag_revision	revision;
		//struct tag_videolfb	videolfb;
		struct tag_cmdline	cmdline;

		/*
		 * Acorn specific
		 */
		//struct tag_acorn	acorn;

		/*
		 * DC21285 specific
		 */
		//struct tag_memclk	memclk;
	} u;
} ;
int main()
{
	void (*theKernel)(int zero, int arch, uint params);
	uart0_init();
	puts("Copy kernel from nand start\n\r");
	nand_init();
	nand_read(0x60000, (uchar *)0x30008000, 0x500000);

	puts("Set boot params\n\r");
	setup_start_tag();
	setup_memory_tags();
	setup_commandline_tag("noinitrd root=/dev/mtdblock3 init=/linuxrc console=ttySAC0,115200");
	setup_end_tag();

	puts("Boot kernel\n\r");
	theKernel = (void (*)(int, int, uint))0x30008040;
	theKernel(0, 1999, 0x30000100); 
	puts("Error!\n\r");

	return -1;
}	  

void dely(int tt)
{
	int i;
	for(i =0;i<tt;i++);
}
void uart0_init()
{
	GPHCON&=~((3<<4)|(3<<6));	//GPH4--TXD0;GPH5--RXD0先清0
	GPHCON|=((2<<4)|(2<<6));    //设置GPH4、GPH5为TXD0、RXD0功能
	GPHUP=0x00;	                //上拉电阻使能
	UFCON0=0x00;				//不使用fifo
	UMCON0=0x00;				//不使用流控
	ULCON0|=0x03;              //设置数据发送格式：8个数据位，1个停止位，无校验位
	UCON0=0x05;	               //发送模式和接收模式都使用查询模式
	UBRDIV0=(int)((50000000/(115200*16))-1);         //设置波特率
	URXH0=0;          //将URXH0清零
	UTXH0=0;
}
void clear_zi()
{
	uint *p = &Image$$SDZI$$ZI$$Base;	
	for (; p < &Image$$SDZI$$ZI$$Limit; p++)
		*p = 0;
}
void nand_init(void)
{
	//NFCONT = (0<<13)|(0<<12)|(0<<10)|(0<<9)|(0<<8)|(1<<6)|(1<<5)|(1<<4)|(1<<1)|(1<<0); 
	NFCONF = (TACLS<<12)|(TWRPH0<<8)|(TWRPH1<<4)|(0<<0); 
	nand_reset();
}

void nand_reset(void)
{
	NFCONT |= (1<<0);
    NFCONT &= ~(1<<1);
    NFCMD=0xff;  // 复位命令
	while(!(NFSTAT & 1));
	NFCONT &= ~(1<<0);
	NFCONT &= ~(1<<1);
}
void nand_addr(uint addr)
{
	unsigned int col  = addr % 2048;
	unsigned int page = addr / 2048;
	volatile int i;

	NFADDR = col & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR = (col >> 8) & 0xff;
	for (i = 0; i < 10; i++);
	
	NFADDR  = page & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR  = (page >> 8) & 0xff;
	for (i = 0; i < 10; i++);
	NFADDR  = (page >> 16) & 0xff;
	for (i = 0; i < 10; i++);	
}

void nand_read(uint addr, uchar *buf, uint len)
{
	int col = addr%2048;
	int i = 0;
	int j = 0;
	NFCONT |= (1<<0);
    NFCONT &= ~(1<<1);
	while (i < len)
	{
		NFCMD=0x00;
		nand_addr(addr);
		NFCMD=0x30;
		for (j=0; j<10; j++);
		while (!(NFSTAT & 1));
		for (;(col < 2048) && (i < len); col++)
		{
			buf[i] = NFDATA;
			i++;
			addr++;
		}
		col = 0;
	}
	NFCONT &= ~(1<<0);
	NFCONT &= ~(1<<1);
}
void putc(uchar c)
{
	UTXH0=c;
	while(!(UTRSTAT0&(1<<2)));    //等待发送完成
}
void puts(char *str)
{
	int i = 0;
	while (str[i])
	{
		putc(str[i]);
		i++;
	}
}
void puthex(uint val)
{
	/* 0x1234abcd */
	int i;
	int j;
	
	puts("0x");

	for (i = 0; i < 8; i++)
	{
		j = (val >> ((7-i)*4)) & 0xf;
		if ((j >= 0) && (j <= 9))
			putc('0' + j);
		else
			putc('A' + j - 0xa);
		
	}
	
}
void setup_start_tag(void)
{
	params = (struct tag *)0x30000100;

	params->hdr.tag = 0x54410001;
	params->hdr.size =(sizeof(struct tag_header) + sizeof(struct tag_core))/4;

	params->u.core.flags = 0;
	params->u.core.pagesize = 0;
	params->u.core.rootdev = 0;

	params = (struct tag *)((uint *)params + params->hdr.size);
}

void setup_memory_tags(void)
{
	params->hdr.tag = 0x54410002;
	params->hdr.size = (sizeof(struct tag_header) + sizeof(struct tag_mem32))/4;
	
	params->u.mem.start = 0x30000000;
	params->u.mem.size  = 64*1024*1024;
	
	params = (struct tag *)((uint *)params + params->hdr.size);
}
void setup_commandline_tag(char *cmdline)
{
	uchar len = strlen(cmdline) + 1;
	
	params->hdr.tag  = 0x54410009;
	params->hdr.size = (sizeof (struct tag_header) + len + 3)/4;

	strcpy (params->u.cmdline.cmdline, cmdline); //?

	params = (struct tag *)((uint *)params + params->hdr.size);
}

void setup_end_tag(void)
{
	params->hdr.tag = 0;
	params->hdr.size = 0;
}
uchar strlen(char *str)
{
	uchar i = 0;
	while (str[i])
	{
		i++;
	}
	return i;
}
void strcpy(char *dest, char *src)
{
	while ((*dest++ = *src++) != '\0');
}
