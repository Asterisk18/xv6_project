
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	addi	sp,sp,-1776 # 80007910 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcbaf>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	605010ef          	jal	80001f1e <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	77e50513          	addi	a0,a0,1918 # 8000f910 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	77248493          	addi	s1,s1,1906 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00010917          	auipc	s2,0x10
    800001aa:	80290913          	addi	s2,s2,-2046 # 8000f9a8 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	778010ef          	jal	80001936 <myproc>
    800001c2:	3f5010ef          	jal	80001db6 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	37b010ef          	jal	80001d46 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	73270713          	addi	a4,a4,1842 # 8000f910 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	4c5010ef          	jal	80001ed4 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	6e850513          	addi	a0,a0,1768 # 8000f910 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	74f72d23          	sw	a5,1882(a4) # 8000f9a8 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	6ac50513          	addi	a0,a0,1708 # 8000f910 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	65850513          	addi	a0,a0,1624 # 8000f910 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	48f010ef          	jal	80001f68 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	63250513          	addi	a0,a0,1586 # 8000f910 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	61470713          	addi	a4,a4,1556 # 8000f910 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	5ee70713          	addi	a4,a4,1518 # 8000f910 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	65c72703          	lw	a4,1628(a4) # 8000f9a8 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	5ae70713          	addi	a4,a4,1454 # 8000f910 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	59e48493          	addi	s1,s1,1438 # 8000f910 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	55c70713          	addi	a4,a4,1372 # 8000f910 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	5ef72323          	sw	a5,1510(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	52878793          	addi	a5,a5,1320 # 8000f910 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	5ac7a123          	sw	a2,1442(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	59650513          	addi	a0,a0,1430 # 8000f9a8 <cons+0x98>
    8000041a:	06c020ef          	jal	80002486 <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	4e050513          	addi	a0,a0,1248 # 8000f910 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00020797          	auipc	a5,0x20
    80000444:	67878793          	addi	a5,a5,1656 # 80020ab8 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	30280813          	addi	a6,a6,770 # 80007780 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	3cc7a783          	lw	a5,972(a5) # 800078e4 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	45a50513          	addi	a0,a0,1114 # 8000f9b8 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	0aec8c93          	addi	s9,s9,174 # 80007780 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	18a7a783          	lw	a5,394(a5) # 800078e4 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	23450513          	addi	a0,a0,564 # 8000f9b8 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	0a97a823          	sw	s1,176(a5) # 800078e4 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	0897a523          	sw	s1,138(a5) # 800078e0 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	14850513          	addi	a0,a0,328 # 8000f9b8 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	10a50513          	addi	a0,a0,266 # 8000f9d0 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	0e650513          	addi	a0,a0,230 # 8000f9d0 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	fe448493          	addi	s1,s1,-28 # 800078ec <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	0c098993          	addi	s3,s3,192 # 8000f9d0 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	fd090913          	addi	s2,s2,-48 # 800078e8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	41a010ef          	jal	80001d46 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	07a50513          	addi	a0,a0,122 # 8000f9d0 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	f6a7a783          	lw	a5,-150(a5) # 800078e4 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	f5c7a783          	lw	a5,-164(a5) # 800078e0 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	f3a7a783          	lw	a5,-198(a5) # 800078e4 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	fca50513          	addi	a0,a0,-54 # 8000f9d0 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	fb050513          	addi	a0,a0,-80 # 8000f9d0 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	ea07a823          	sw	zero,-336(a5) # 800078ec <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	ea450513          	addi	a0,a0,-348 # 800078e8 <tx_chan>
    80000a4c:	23b010ef          	jal	80002486 <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00021797          	auipc	a5,0x21
    80000a6c:	1e878793          	addi	a5,a5,488 # 80021c50 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	f5690913          	addi	s2,s2,-170 # 8000f9e8 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	ec850513          	addi	a0,a0,-312 # 8000f9e8 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00021517          	auipc	a0,0x21
    80000b34:	12050513          	addi	a0,a0,288 # 80021c50 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	e9a50513          	addi	a0,a0,-358 # 8000f9e8 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	ea64b483          	ld	s1,-346(s1) # 8000fa00 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	e8f73d23          	sd	a5,-358(a4) # 8000fa00 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	e7a50513          	addi	a0,a0,-390 # 8000f9e8 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	e5850513          	addi	a0,a0,-424 # 8000f9e8 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	549000ef          	jal	80001916 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	519000ef          	jal	80001916 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	511000ef          	jal	80001916 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	4fd000ef          	jal	80001916 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4c7000ef          	jal	80001916 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	4a3000ef          	jal	80001916 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	24d000ef          	jal	80001902 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	a3670713          	addi	a4,a4,-1482 # 800078f0 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	235000ef          	jal	80001902 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	009010ef          	jal	800026ec <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	2a1040ef          	jal	80005988 <plicinithart>
  }

  scheduler();        
    80000eec:	3f0010ef          	jal	800022dc <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	117000ef          	jal	8000183e <procinit>
    trapinit();      // trap vectors
    80000f2c:	79c010ef          	jal	800026c8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	7bc010ef          	jal	800026ec <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	23b040ef          	jal	8000596e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	251040ef          	jal	80005988 <plicinithart>
    binit();         // buffer cache
    80000f3c:	0be020ef          	jal	80002ffa <binit>
    iinit();         // inode table
    80000f40:	610020ef          	jal	80003550 <iinit>
    fileinit();      // file table
    80000f44:	53c030ef          	jal	80004480 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	331040ef          	jal	80005a78 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	236010ef          	jal	80002182 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	98f72d23          	sw	a5,-1638(a4) # 800078f0 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	98c7b783          	ld	a5,-1652(a5) # 800078f8 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	5c4000ef          	jal	800017a0 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	70a7b023          	sd	a0,1792(a5) # 800078f8 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	356000ef          	jal	80001936 <myproc>
  if (va >= p->sz)
    800015e4:	753c                	ld	a5,104(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	78a8                	ld	a0,112(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a0:	715d                	addi	sp,sp,-80
    800017a2:	e486                	sd	ra,72(sp)
    800017a4:	e0a2                	sd	s0,64(sp)
    800017a6:	fc26                	sd	s1,56(sp)
    800017a8:	f84a                	sd	s2,48(sp)
    800017aa:	f44e                	sd	s3,40(sp)
    800017ac:	f052                	sd	s4,32(sp)
    800017ae:	ec56                	sd	s5,24(sp)
    800017b0:	e85a                	sd	s6,16(sp)
    800017b2:	e45e                	sd	s7,8(sp)
    800017b4:	e062                	sd	s8,0(sp)
    800017b6:	0880                	addi	s0,sp,80
    800017b8:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	0000f497          	auipc	s1,0xf
    800017be:	eb648493          	addi	s1,s1,-330 # 80010670 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	1a1f67b7          	lui	a5,0x1a1f6
    800017c8:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    800017cc:	7d634937          	lui	s2,0x7d634
    800017d0:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    800017d4:	1902                	slli	s2,s2,0x20
    800017d6:	993e                	add	s2,s2,a5
    800017d8:	040009b7          	lui	s3,0x4000
    800017dc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017de:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e0:	4b99                	li	s7,6
    800017e2:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e4:	00015a97          	auipc	s5,0x15
    800017e8:	08ca8a93          	addi	s5,s5,140 # 80016870 <tickslock>
    char *pa = kalloc();
    800017ec:	b58ff0ef          	jal	80000b44 <kalloc>
    800017f0:	862a                	mv	a2,a0
    if(pa == 0)
    800017f2:	c121                	beqz	a0,80001832 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017f4:	418485b3          	sub	a1,s1,s8
    800017f8:	858d                	srai	a1,a1,0x3
    800017fa:	032585b3          	mul	a1,a1,s2
    800017fe:	05b6                	slli	a1,a1,0xd
    80001800:	6789                	lui	a5,0x2
    80001802:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001804:	875e                	mv	a4,s7
    80001806:	86da                	mv	a3,s6
    80001808:	40b985b3          	sub	a1,s3,a1
    8000180c:	8552                	mv	a0,s4
    8000180e:	909ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001812:	18848493          	addi	s1,s1,392
    80001816:	fd549be3          	bne	s1,s5,800017ec <proc_mapstacks+0x4c>
  }
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret
      panic("kalloc");
    80001832:	00006517          	auipc	a0,0x6
    80001836:	92650513          	addi	a0,a0,-1754 # 80007158 <etext+0x158>
    8000183a:	febfe0ef          	jal	80000824 <panic>

000000008000183e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001852:	00006597          	auipc	a1,0x6
    80001856:	90e58593          	addi	a1,a1,-1778 # 80007160 <etext+0x160>
    8000185a:	0000e517          	auipc	a0,0xe
    8000185e:	1ae50513          	addi	a0,a0,430 # 8000fa08 <pid_lock>
    80001862:	b3cff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001866:	00006597          	auipc	a1,0x6
    8000186a:	90258593          	addi	a1,a1,-1790 # 80007168 <etext+0x168>
    8000186e:	0000e517          	auipc	a0,0xe
    80001872:	1b250513          	addi	a0,a0,434 # 8000fa20 <wait_lock>
    80001876:	b28ff0ef          	jal	80000b9e <initlock>
  // a
  initlock(&queue_lock, "queue_lock"); // initialising our new lock
    8000187a:	00006597          	auipc	a1,0x6
    8000187e:	8fe58593          	addi	a1,a1,-1794 # 80007178 <etext+0x178>
    80001882:	0000e517          	auipc	a0,0xe
    80001886:	1b650513          	addi	a0,a0,438 # 8000fa38 <queue_lock>
    8000188a:	b14ff0ef          	jal	80000b9e <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	0000f497          	auipc	s1,0xf
    80001892:	de248493          	addi	s1,s1,-542 # 80010670 <proc>
      initlock(&p->lock, "proc");
    80001896:	00006b17          	auipc	s6,0x6
    8000189a:	8f2b0b13          	addi	s6,s6,-1806 # 80007188 <etext+0x188>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000189e:	8aa6                	mv	s5,s1
    800018a0:	1a1f67b7          	lui	a5,0x1a1f6
    800018a4:	8d178793          	addi	a5,a5,-1839 # 1a1f58d1 <_entry-0x65e0a72f>
    800018a8:	7d634937          	lui	s2,0x7d634
    800018ac:	3eb90913          	addi	s2,s2,1003 # 7d6343eb <_entry-0x29cbc15>
    800018b0:	1902                	slli	s2,s2,0x20
    800018b2:	993e                	add	s2,s2,a5
    800018b4:	040009b7          	lui	s3,0x4000
    800018b8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ba:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018bc:	00015a17          	auipc	s4,0x15
    800018c0:	fb4a0a13          	addi	s4,s4,-76 # 80016870 <tickslock>
      initlock(&p->lock, "proc");
    800018c4:	85da                	mv	a1,s6
    800018c6:	8526                	mv	a0,s1
    800018c8:	ad6ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018cc:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018d0:	415487b3          	sub	a5,s1,s5
    800018d4:	878d                	srai	a5,a5,0x3
    800018d6:	032787b3          	mul	a5,a5,s2
    800018da:	07b6                	slli	a5,a5,0xd
    800018dc:	6709                	lui	a4,0x2
    800018de:	9fb9                	addw	a5,a5,a4
    800018e0:	40f987b3          	sub	a5,s3,a5
    800018e4:	f0bc                	sd	a5,96(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	18848493          	addi	s1,s1,392
    800018ea:	fd449de3          	bne	s1,s4,800018c4 <procinit+0x86>
  }
}
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret

0000000080001902 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001902:	1141                	addi	sp,sp,-16
    80001904:	e406                	sd	ra,8(sp)
    80001906:	e022                	sd	s0,0(sp)
    80001908:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000190a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000190c:	2501                	sext.w	a0,a0
    8000190e:	60a2                	ld	ra,8(sp)
    80001910:	6402                	ld	s0,0(sp)
    80001912:	0141                	addi	sp,sp,16
    80001914:	8082                	ret

0000000080001916 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001916:	1141                	addi	sp,sp,-16
    80001918:	e406                	sd	ra,8(sp)
    8000191a:	e022                	sd	s0,0(sp)
    8000191c:	0800                	addi	s0,sp,16
    8000191e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001920:	2781                	sext.w	a5,a5
    80001922:	079e                	slli	a5,a5,0x7
  return c;
}
    80001924:	0000e517          	auipc	a0,0xe
    80001928:	12c50513          	addi	a0,a0,300 # 8000fa50 <cpus>
    8000192c:	953e                	add	a0,a0,a5
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret

0000000080001936 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001936:	1101                	addi	sp,sp,-32
    80001938:	ec06                	sd	ra,24(sp)
    8000193a:	e822                	sd	s0,16(sp)
    8000193c:	e426                	sd	s1,8(sp)
    8000193e:	1000                	addi	s0,sp,32
  push_off(); // diabling interrupts
    80001940:	aa4ff0ef          	jal	80000be4 <push_off>
    80001944:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001946:	2781                	sext.w	a5,a5
    80001948:	079e                	slli	a5,a5,0x7
    8000194a:	0000e717          	auipc	a4,0xe
    8000194e:	0be70713          	addi	a4,a4,190 # 8000fa08 <pid_lock>
    80001952:	97ba                	add	a5,a5,a4
    80001954:	67bc                	ld	a5,72(a5)
    80001956:	84be                	mv	s1,a5
  pop_off();
    80001958:	b14ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    8000195c:	8526                	mv	a0,s1
    8000195e:	60e2                	ld	ra,24(sp)
    80001960:	6442                	ld	s0,16(sp)
    80001962:	64a2                	ld	s1,8(sp)
    80001964:	6105                	addi	sp,sp,32
    80001966:	8082                	ret

0000000080001968 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001968:	7179                	addi	sp,sp,-48
    8000196a:	f406                	sd	ra,40(sp)
    8000196c:	f022                	sd	s0,32(sp)
    8000196e:	ec26                	sd	s1,24(sp)
    80001970:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001972:	fc5ff0ef          	jal	80001936 <myproc>
    80001976:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001978:	b44ff0ef          	jal	80000cbc <release>

  if (first) {
    8000197c:	00006797          	auipc	a5,0x6
    80001980:	f547a783          	lw	a5,-172(a5) # 800078d0 <first.1>
    80001984:	cf95                	beqz	a5,800019c0 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001986:	4505                	li	a0,1
    80001988:	084020ef          	jal	80003a0c <fsinit>

    first = 0;
    8000198c:	00006797          	auipc	a5,0x6
    80001990:	f407a223          	sw	zero,-188(a5) # 800078d0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001994:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001998:	00005797          	auipc	a5,0x5
    8000199c:	7f878793          	addi	a5,a5,2040 # 80007190 <etext+0x190>
    800019a0:	fcf43823          	sd	a5,-48(s0)
    800019a4:	fc043c23          	sd	zero,-40(s0)
    800019a8:	fd040593          	addi	a1,s0,-48
    800019ac:	853e                	mv	a0,a5
    800019ae:	1e6030ef          	jal	80004b94 <kexec>
    800019b2:	7cbc                	ld	a5,120(s1)
    800019b4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019b6:	7cbc                	ld	a5,120(s1)
    800019b8:	7bb8                	ld	a4,112(a5)
    800019ba:	57fd                	li	a5,-1
    800019bc:	02f70d63          	beq	a4,a5,800019f6 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019c0:	549000ef          	jal	80002708 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019c4:	78a8                	ld	a0,112(s1)
    800019c6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c8:	04000737          	lui	a4,0x4000
    800019cc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019ce:	0732                	slli	a4,a4,0xc
    800019d0:	00004797          	auipc	a5,0x4
    800019d4:	6cc78793          	addi	a5,a5,1740 # 8000609c <userret>
    800019d8:	00004697          	auipc	a3,0x4
    800019dc:	62868693          	addi	a3,a3,1576 # 80006000 <_trampoline>
    800019e0:	8f95                	sub	a5,a5,a3
    800019e2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019e4:	577d                	li	a4,-1
    800019e6:	177e                	slli	a4,a4,0x3f
    800019e8:	8d59                	or	a0,a0,a4
    800019ea:	9782                	jalr	a5
}
    800019ec:	70a2                	ld	ra,40(sp)
    800019ee:	7402                	ld	s0,32(sp)
    800019f0:	64e2                	ld	s1,24(sp)
    800019f2:	6145                	addi	sp,sp,48
    800019f4:	8082                	ret
      panic("exec");
    800019f6:	00005517          	auipc	a0,0x5
    800019fa:	7a250513          	addi	a0,a0,1954 # 80007198 <etext+0x198>
    800019fe:	e27fe0ef          	jal	80000824 <panic>

0000000080001a02 <allocpid>:
{
    80001a02:	1101                	addi	sp,sp,-32
    80001a04:	ec06                	sd	ra,24(sp)
    80001a06:	e822                	sd	s0,16(sp)
    80001a08:	e426                	sd	s1,8(sp)
    80001a0a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a0c:	0000e517          	auipc	a0,0xe
    80001a10:	ffc50513          	addi	a0,a0,-4 # 8000fa08 <pid_lock>
    80001a14:	a14ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a18:	00006797          	auipc	a5,0x6
    80001a1c:	ebc78793          	addi	a5,a5,-324 # 800078d4 <nextpid>
    80001a20:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a22:	0014871b          	addiw	a4,s1,1
    80001a26:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a28:	0000e517          	auipc	a0,0xe
    80001a2c:	fe050513          	addi	a0,a0,-32 # 8000fa08 <pid_lock>
    80001a30:	a8cff0ef          	jal	80000cbc <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret

0000000080001a40 <proc_pagetable>:
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	e04a                	sd	s2,0(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a4e:	fbaff0ef          	jal	80001208 <uvmcreate>
    80001a52:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a54:	cd05                	beqz	a0,80001a8c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a56:	4729                	li	a4,10
    80001a58:	00004697          	auipc	a3,0x4
    80001a5c:	5a868693          	addi	a3,a3,1448 # 80006000 <_trampoline>
    80001a60:	6605                	lui	a2,0x1
    80001a62:	040005b7          	lui	a1,0x4000
    80001a66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a68:	05b2                	slli	a1,a1,0xc
    80001a6a:	df6ff0ef          	jal	80001060 <mappages>
    80001a6e:	02054663          	bltz	a0,80001a9a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a72:	4719                	li	a4,6
    80001a74:	07893683          	ld	a3,120(s2)
    80001a78:	6605                	lui	a2,0x1
    80001a7a:	020005b7          	lui	a1,0x2000
    80001a7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a80:	05b6                	slli	a1,a1,0xd
    80001a82:	8526                	mv	a0,s1
    80001a84:	ddcff0ef          	jal	80001060 <mappages>
    80001a88:	00054f63          	bltz	a0,80001aa6 <proc_pagetable+0x66>
}
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	60e2                	ld	ra,24(sp)
    80001a90:	6442                	ld	s0,16(sp)
    80001a92:	64a2                	ld	s1,8(sp)
    80001a94:	6902                	ld	s2,0(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret
    uvmfree(pagetable, 0);
    80001a9a:	4581                	li	a1,0
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	965ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001aa2:	4481                	li	s1,0
    80001aa4:	b7e5                	j	80001a8c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa6:	4681                	li	a3,0
    80001aa8:	4605                	li	a2,1
    80001aaa:	040005b7          	lui	a1,0x4000
    80001aae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab0:	05b2                	slli	a1,a1,0xc
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	f7aff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab8:	4581                	li	a1,0
    80001aba:	8526                	mv	a0,s1
    80001abc:	947ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001ac0:	4481                	li	s1,0
    80001ac2:	b7e9                	j	80001a8c <proc_pagetable+0x4c>

0000000080001ac4 <proc_freepagetable>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
    80001ad0:	84aa                	mv	s1,a0
    80001ad2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad4:	4681                	li	a3,0
    80001ad6:	4605                	li	a2,1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	f4eff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ae4:	4681                	li	a3,0
    80001ae6:	4605                	li	a2,1
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	slli	a1,a1,0xd
    80001af0:	8526                	mv	a0,s1
    80001af2:	f3cff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001af6:	85ca                	mv	a1,s2
    80001af8:	8526                	mv	a0,s1
    80001afa:	909ff0ef          	jal	80001402 <uvmfree>
}
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret

0000000080001b0a <freeproc>:
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	1000                	addi	s0,sp,32
    80001b14:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b16:	7d28                	ld	a0,120(a0)
    80001b18:	c119                	beqz	a0,80001b1e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b1a:	f43fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b1e:	0604bc23          	sd	zero,120(s1)
  if(p->pagetable)
    80001b22:	78a8                	ld	a0,112(s1)
    80001b24:	c501                	beqz	a0,80001b2c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b26:	74ac                	ld	a1,104(s1)
    80001b28:	f9dff0ef          	jal	80001ac4 <proc_freepagetable>
  p->pagetable = 0;
    80001b2c:	0604b823          	sd	zero,112(s1)
  p->sz = 0;
    80001b30:	0604b423          	sd	zero,104(s1)
  p->pid = 0;
    80001b34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b38:	0404bc23          	sd	zero,88(s1)
  p->name[0] = 0;
    80001b3c:	16048c23          	sb	zero,376(s1)
  p->chan = 0;
    80001b40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b48:	0204a623          	sw	zero,44(s1)
  p->syscount = 0;
    80001b4c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001b50:	0004ac23          	sw	zero,24(s1)
}
    80001b54:	60e2                	ld	ra,24(sp)
    80001b56:	6442                	ld	s0,16(sp)
    80001b58:	64a2                	ld	s1,8(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <allocproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	e04a                	sd	s2,0(sp)
    80001b68:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b6a:	0000f497          	auipc	s1,0xf
    80001b6e:	b0648493          	addi	s1,s1,-1274 # 80010670 <proc>
    80001b72:	00015917          	auipc	s2,0x15
    80001b76:	cfe90913          	addi	s2,s2,-770 # 80016870 <tickslock>
    acquire(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8acff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b80:	4c9c                	lw	a5,24(s1)
    80001b82:	cb91                	beqz	a5,80001b96 <allocproc+0x38>
      release(&p->lock);
    80001b84:	8526                	mv	a0,s1
    80001b86:	936ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8a:	18848493          	addi	s1,s1,392
    80001b8e:	ff2496e3          	bne	s1,s2,80001b7a <allocproc+0x1c>
  return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	a09d                	j	80001bfa <allocproc+0x9c>
  p->pid = allocpid();
    80001b96:	e6dff0ef          	jal	80001a02 <allocpid>
    80001b9a:	d888                	sw	a0,48(s1)
  p->state = USED; // this should be done before allocpid() function call
    80001b9c:	4785                	li	a5,1
    80001b9e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ba0:	fa5fe0ef          	jal	80000b44 <kalloc>
    80001ba4:	892a                	mv	s2,a0
    80001ba6:	fca8                	sd	a0,120(s1)
    80001ba8:	c125                	beqz	a0,80001c08 <allocproc+0xaa>
  p->pagetable = proc_pagetable(p);
    80001baa:	8526                	mv	a0,s1
    80001bac:	e95ff0ef          	jal	80001a40 <proc_pagetable>
    80001bb0:	892a                	mv	s2,a0
    80001bb2:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80001bb4:	c135                	beqz	a0,80001c18 <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001bb6:	07000613          	li	a2,112
    80001bba:	4581                	li	a1,0
    80001bbc:	08048513          	addi	a0,s1,128
    80001bc0:	938ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bc4:	00000797          	auipc	a5,0x0
    80001bc8:	da478793          	addi	a5,a5,-604 # 80001968 <forkret>
    80001bcc:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bce:	70bc                	ld	a5,96(s1)
    80001bd0:	6705                	lui	a4,0x1
    80001bd2:	97ba                	add	a5,a5,a4
    80001bd4:	e4dc                	sd	a5,136(s1)
  p->syscount = 0;
    80001bd6:	0204aa23          	sw	zero,52(s1)
  p->level = LEVEL0;
    80001bda:	0204ac23          	sw	zero,56(s1)
  p->delta_s = 0;
    80001bde:	0204ae23          	sw	zero,60(s1)
  p->curr_ticks = 0;
    80001be2:	0404a023          	sw	zero,64(s1)
  for(int i=0;i<NLEVEL;i++) p->ticks[i] = 0;
    80001be6:	0404a223          	sw	zero,68(s1)
    80001bea:	0404a423          	sw	zero,72(s1)
    80001bee:	0404a623          	sw	zero,76(s1)
    80001bf2:	0404a823          	sw	zero,80(s1)
  p->times_scheduled = 0;
    80001bf6:	0404aa23          	sw	zero,84(s1)
}
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6902                	ld	s2,0(sp)
    80001c04:	6105                	addi	sp,sp,32
    80001c06:	8082                	ret
    freeproc(p);
    80001c08:	8526                	mv	a0,s1
    80001c0a:	f01ff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	8acff0ef          	jal	80000cbc <release>
    return 0;
    80001c14:	84ca                	mv	s1,s2
    80001c16:	b7d5                	j	80001bfa <allocproc+0x9c>
    freeproc(p);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	ef1ff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	89cff0ef          	jal	80000cbc <release>
    return 0;
    80001c24:	84ca                	mv	s1,s2
    80001c26:	bfd1                	j	80001bfa <allocproc+0x9c>

0000000080001c28 <growproc>:
{
    80001c28:	1101                	addi	sp,sp,-32
    80001c2a:	ec06                	sd	ra,24(sp)
    80001c2c:	e822                	sd	s0,16(sp)
    80001c2e:	e426                	sd	s1,8(sp)
    80001c30:	e04a                	sd	s2,0(sp)
    80001c32:	1000                	addi	s0,sp,32
    80001c34:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c36:	d01ff0ef          	jal	80001936 <myproc>
    80001c3a:	892a                	mv	s2,a0
  sz = p->sz;
    80001c3c:	752c                	ld	a1,104(a0)
  if(n > 0){
    80001c3e:	02905963          	blez	s1,80001c70 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c42:	00b48633          	add	a2,s1,a1
    80001c46:	020007b7          	lui	a5,0x2000
    80001c4a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c4c:	07b6                	slli	a5,a5,0xd
    80001c4e:	02c7ea63          	bltu	a5,a2,80001c82 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c52:	4691                	li	a3,4
    80001c54:	7928                	ld	a0,112(a0)
    80001c56:	ea6ff0ef          	jal	800012fc <uvmalloc>
    80001c5a:	85aa                	mv	a1,a0
    80001c5c:	c50d                	beqz	a0,80001c86 <growproc+0x5e>
  p->sz = sz;
    80001c5e:	06b93423          	sd	a1,104(s2)
  return 0;
    80001c62:	4501                	li	a0,0
}
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6902                	ld	s2,0(sp)
    80001c6c:	6105                	addi	sp,sp,32
    80001c6e:	8082                	ret
  } else if(n < 0){
    80001c70:	fe04d7e3          	bgez	s1,80001c5e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c74:	00b48633          	add	a2,s1,a1
    80001c78:	7928                	ld	a0,112(a0)
    80001c7a:	e3eff0ef          	jal	800012b8 <uvmdealloc>
    80001c7e:	85aa                	mv	a1,a0
    80001c80:	bff9                	j	80001c5e <growproc+0x36>
      return -1;
    80001c82:	557d                	li	a0,-1
    80001c84:	b7c5                	j	80001c64 <growproc+0x3c>
      return -1;
    80001c86:	557d                	li	a0,-1
    80001c88:	bff1                	j	80001c64 <growproc+0x3c>

0000000080001c8a <sched>:
{
    80001c8a:	7179                	addi	sp,sp,-48
    80001c8c:	f406                	sd	ra,40(sp)
    80001c8e:	f022                	sd	s0,32(sp)
    80001c90:	ec26                	sd	s1,24(sp)
    80001c92:	e84a                	sd	s2,16(sp)
    80001c94:	e44e                	sd	s3,8(sp)
    80001c96:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001c98:	c9fff0ef          	jal	80001936 <myproc>
    80001c9c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c9e:	f1bfe0ef          	jal	80000bb8 <holding>
    80001ca2:	c935                	beqz	a0,80001d16 <sched+0x8c>
    80001ca4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ca6:	2781                	sext.w	a5,a5
    80001ca8:	079e                	slli	a5,a5,0x7
    80001caa:	0000e717          	auipc	a4,0xe
    80001cae:	d5e70713          	addi	a4,a4,-674 # 8000fa08 <pid_lock>
    80001cb2:	97ba                	add	a5,a5,a4
    80001cb4:	0c07a703          	lw	a4,192(a5)
    80001cb8:	4785                	li	a5,1
    80001cba:	06f71463          	bne	a4,a5,80001d22 <sched+0x98>
  if(p->state == RUNNING)
    80001cbe:	4c98                	lw	a4,24(s1)
    80001cc0:	4791                	li	a5,4
    80001cc2:	06f70663          	beq	a4,a5,80001d2e <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001cca:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ccc:	e7bd                	bnez	a5,80001d3a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001cce:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001cd0:	0000e917          	auipc	s2,0xe
    80001cd4:	d3890913          	addi	s2,s2,-712 # 8000fa08 <pid_lock>
    80001cd8:	2781                	sext.w	a5,a5
    80001cda:	079e                	slli	a5,a5,0x7
    80001cdc:	97ca                	add	a5,a5,s2
    80001cde:	0c47a983          	lw	s3,196(a5)
    80001ce2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ce4:	2781                	sext.w	a5,a5
    80001ce6:	079e                	slli	a5,a5,0x7
    80001ce8:	07a1                	addi	a5,a5,8
    80001cea:	0000e597          	auipc	a1,0xe
    80001cee:	d6658593          	addi	a1,a1,-666 # 8000fa50 <cpus>
    80001cf2:	95be                	add	a1,a1,a5
    80001cf4:	08048513          	addi	a0,s1,128
    80001cf8:	167000ef          	jal	8000265e <swtch>
    80001cfc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001cfe:	2781                	sext.w	a5,a5
    80001d00:	079e                	slli	a5,a5,0x7
    80001d02:	993e                	add	s2,s2,a5
    80001d04:	0d392223          	sw	s3,196(s2)
}
    80001d08:	70a2                	ld	ra,40(sp)
    80001d0a:	7402                	ld	s0,32(sp)
    80001d0c:	64e2                	ld	s1,24(sp)
    80001d0e:	6942                	ld	s2,16(sp)
    80001d10:	69a2                	ld	s3,8(sp)
    80001d12:	6145                	addi	sp,sp,48
    80001d14:	8082                	ret
    panic("sched p->lock");
    80001d16:	00005517          	auipc	a0,0x5
    80001d1a:	48a50513          	addi	a0,a0,1162 # 800071a0 <etext+0x1a0>
    80001d1e:	b07fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001d22:	00005517          	auipc	a0,0x5
    80001d26:	48e50513          	addi	a0,a0,1166 # 800071b0 <etext+0x1b0>
    80001d2a:	afbfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001d2e:	00005517          	auipc	a0,0x5
    80001d32:	49250513          	addi	a0,a0,1170 # 800071c0 <etext+0x1c0>
    80001d36:	aeffe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001d3a:	00005517          	auipc	a0,0x5
    80001d3e:	49650513          	addi	a0,a0,1174 # 800071d0 <etext+0x1d0>
    80001d42:	ae3fe0ef          	jal	80000824 <panic>

0000000080001d46 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001d46:	7179                	addi	sp,sp,-48
    80001d48:	f406                	sd	ra,40(sp)
    80001d4a:	f022                	sd	s0,32(sp)
    80001d4c:	ec26                	sd	s1,24(sp)
    80001d4e:	e84a                	sd	s2,16(sp)
    80001d50:	e44e                	sd	s3,8(sp)
    80001d52:	1800                	addi	s0,sp,48
    80001d54:	89aa                	mv	s3,a0
    80001d56:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001d58:	bdfff0ef          	jal	80001936 <myproc>
    80001d5c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001d5e:	ecbfe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001d62:	854a                	mv	a0,s2
    80001d64:	f59fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80001d68:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001d6c:	4789                	li	a5,2
    80001d6e:	cc9c                	sw	a5,24(s1)

  sched();
    80001d70:	f1bff0ef          	jal	80001c8a <sched>

  // Tidy up.
  p->chan = 0;
    80001d74:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	f43fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80001d7e:	854a                	mv	a0,s2
    80001d80:	ea9fe0ef          	jal	80000c28 <acquire>
}
    80001d84:	70a2                	ld	ra,40(sp)
    80001d86:	7402                	ld	s0,32(sp)
    80001d88:	64e2                	ld	s1,24(sp)
    80001d8a:	6942                	ld	s2,16(sp)
    80001d8c:	69a2                	ld	s3,8(sp)
    80001d8e:	6145                	addi	sp,sp,48
    80001d90:	8082                	ret

0000000080001d92 <setkilled>:
  return -1;
}

void
setkilled(struct proc *p)
{
    80001d92:	1101                	addi	sp,sp,-32
    80001d94:	ec06                	sd	ra,24(sp)
    80001d96:	e822                	sd	s0,16(sp)
    80001d98:	e426                	sd	s1,8(sp)
    80001d9a:	1000                	addi	s0,sp,32
    80001d9c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001d9e:	e8bfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80001da2:	4785                	li	a5,1
    80001da4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001da6:	8526                	mv	a0,s1
    80001da8:	f15fe0ef          	jal	80000cbc <release>
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret

0000000080001db6 <killed>:

int
killed(struct proc *p)
{
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	e04a                	sd	s2,0(sp)
    80001dc0:	1000                	addi	s0,sp,32
    80001dc2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001dc4:	e65fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80001dc8:	549c                	lw	a5,40(s1)
    80001dca:	893e                	mv	s2,a5
  release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	eeffe0ef          	jal	80000cbc <release>
  return k;
}
    80001dd2:	854a                	mv	a0,s2
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6902                	ld	s2,0(sp)
    80001ddc:	6105                	addi	sp,sp,32
    80001dde:	8082                	ret

0000000080001de0 <kwait>:
{
    80001de0:	715d                	addi	sp,sp,-80
    80001de2:	e486                	sd	ra,72(sp)
    80001de4:	e0a2                	sd	s0,64(sp)
    80001de6:	fc26                	sd	s1,56(sp)
    80001de8:	f84a                	sd	s2,48(sp)
    80001dea:	f44e                	sd	s3,40(sp)
    80001dec:	f052                	sd	s4,32(sp)
    80001dee:	ec56                	sd	s5,24(sp)
    80001df0:	e85a                	sd	s6,16(sp)
    80001df2:	e45e                	sd	s7,8(sp)
    80001df4:	0880                	addi	s0,sp,80
    80001df6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80001df8:	b3fff0ef          	jal	80001936 <myproc>
    80001dfc:	892a                	mv	s2,a0
  acquire(&wait_lock); 
    80001dfe:	0000e517          	auipc	a0,0xe
    80001e02:	c2250513          	addi	a0,a0,-990 # 8000fa20 <wait_lock>
    80001e06:	e23fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80001e0a:	4a15                	li	s4,5
        havekids = 1;
    80001e0c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e0e:	00015997          	auipc	s3,0x15
    80001e12:	a6298993          	addi	s3,s3,-1438 # 80016870 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001e16:	0000eb17          	auipc	s6,0xe
    80001e1a:	c0ab0b13          	addi	s6,s6,-1014 # 8000fa20 <wait_lock>
    80001e1e:	a869                	j	80001eb8 <kwait+0xd8>
          pid = pp->pid;
    80001e20:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001e24:	000b8c63          	beqz	s7,80001e3c <kwait+0x5c>
    80001e28:	4691                	li	a3,4
    80001e2a:	02c48613          	addi	a2,s1,44
    80001e2e:	85de                	mv	a1,s7
    80001e30:	07093503          	ld	a0,112(s2)
    80001e34:	821ff0ef          	jal	80001654 <copyout>
    80001e38:	02054a63          	bltz	a0,80001e6c <kwait+0x8c>
          freeproc(pp);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	ccdff0ef          	jal	80001b0a <freeproc>
          release(&pp->lock);
    80001e42:	8526                	mv	a0,s1
    80001e44:	e79fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80001e48:	0000e517          	auipc	a0,0xe
    80001e4c:	bd850513          	addi	a0,a0,-1064 # 8000fa20 <wait_lock>
    80001e50:	e6dfe0ef          	jal	80000cbc <release>
}
    80001e54:	854e                	mv	a0,s3
    80001e56:	60a6                	ld	ra,72(sp)
    80001e58:	6406                	ld	s0,64(sp)
    80001e5a:	74e2                	ld	s1,56(sp)
    80001e5c:	7942                	ld	s2,48(sp)
    80001e5e:	79a2                	ld	s3,40(sp)
    80001e60:	7a02                	ld	s4,32(sp)
    80001e62:	6ae2                	ld	s5,24(sp)
    80001e64:	6b42                	ld	s6,16(sp)
    80001e66:	6ba2                	ld	s7,8(sp)
    80001e68:	6161                	addi	sp,sp,80
    80001e6a:	8082                	ret
            release(&pp->lock);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	e4ffe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80001e72:	0000e517          	auipc	a0,0xe
    80001e76:	bae50513          	addi	a0,a0,-1106 # 8000fa20 <wait_lock>
    80001e7a:	e43fe0ef          	jal	80000cbc <release>
            return -1;
    80001e7e:	59fd                	li	s3,-1
    80001e80:	bfd1                	j	80001e54 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e82:	18848493          	addi	s1,s1,392
    80001e86:	03348063          	beq	s1,s3,80001ea6 <kwait+0xc6>
      if(pp->parent == p){
    80001e8a:	6cbc                	ld	a5,88(s1)
    80001e8c:	ff279be3          	bne	a5,s2,80001e82 <kwait+0xa2>
        acquire(&pp->lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	d97fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80001e96:	4c9c                	lw	a5,24(s1)
    80001e98:	f94784e3          	beq	a5,s4,80001e20 <kwait+0x40>
        release(&pp->lock);
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	e1ffe0ef          	jal	80000cbc <release>
        havekids = 1;
    80001ea2:	8756                	mv	a4,s5
    80001ea4:	bff9                	j	80001e82 <kwait+0xa2>
    if(!havekids || killed(p)){
    80001ea6:	cf19                	beqz	a4,80001ec4 <kwait+0xe4>
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	f0dff0ef          	jal	80001db6 <killed>
    80001eae:	e919                	bnez	a0,80001ec4 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001eb0:	85da                	mv	a1,s6
    80001eb2:	854a                	mv	a0,s2
    80001eb4:	e93ff0ef          	jal	80001d46 <sleep>
    havekids = 0;
    80001eb8:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eba:	0000e497          	auipc	s1,0xe
    80001ebe:	7b648493          	addi	s1,s1,1974 # 80010670 <proc>
    80001ec2:	b7e1                	j	80001e8a <kwait+0xaa>
      release(&wait_lock);
    80001ec4:	0000e517          	auipc	a0,0xe
    80001ec8:	b5c50513          	addi	a0,a0,-1188 # 8000fa20 <wait_lock>
    80001ecc:	df1fe0ef          	jal	80000cbc <release>
      return -1;
    80001ed0:	59fd                	li	s3,-1
    80001ed2:	b749                	j	80001e54 <kwait+0x74>

0000000080001ed4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001ed4:	7179                	addi	sp,sp,-48
    80001ed6:	f406                	sd	ra,40(sp)
    80001ed8:	f022                	sd	s0,32(sp)
    80001eda:	ec26                	sd	s1,24(sp)
    80001edc:	e84a                	sd	s2,16(sp)
    80001ede:	e44e                	sd	s3,8(sp)
    80001ee0:	e052                	sd	s4,0(sp)
    80001ee2:	1800                	addi	s0,sp,48
    80001ee4:	84aa                	mv	s1,a0
    80001ee6:	8a2e                	mv	s4,a1
    80001ee8:	89b2                	mv	s3,a2
    80001eea:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80001eec:	a4bff0ef          	jal	80001936 <myproc>
  if(user_dst){
    80001ef0:	cc99                	beqz	s1,80001f0e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001ef2:	86ca                	mv	a3,s2
    80001ef4:	864e                	mv	a2,s3
    80001ef6:	85d2                	mv	a1,s4
    80001ef8:	7928                	ld	a0,112(a0)
    80001efa:	f5aff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001efe:	70a2                	ld	ra,40(sp)
    80001f00:	7402                	ld	s0,32(sp)
    80001f02:	64e2                	ld	s1,24(sp)
    80001f04:	6942                	ld	s2,16(sp)
    80001f06:	69a2                	ld	s3,8(sp)
    80001f08:	6a02                	ld	s4,0(sp)
    80001f0a:	6145                	addi	sp,sp,48
    80001f0c:	8082                	ret
    memmove((char *)dst, src, len);
    80001f0e:	0009061b          	sext.w	a2,s2
    80001f12:	85ce                	mv	a1,s3
    80001f14:	8552                	mv	a0,s4
    80001f16:	e43fe0ef          	jal	80000d58 <memmove>
    return 0;
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	b7cd                	j	80001efe <either_copyout+0x2a>

0000000080001f1e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001f1e:	7179                	addi	sp,sp,-48
    80001f20:	f406                	sd	ra,40(sp)
    80001f22:	f022                	sd	s0,32(sp)
    80001f24:	ec26                	sd	s1,24(sp)
    80001f26:	e84a                	sd	s2,16(sp)
    80001f28:	e44e                	sd	s3,8(sp)
    80001f2a:	e052                	sd	s4,0(sp)
    80001f2c:	1800                	addi	s0,sp,48
    80001f2e:	8a2a                	mv	s4,a0
    80001f30:	84ae                	mv	s1,a1
    80001f32:	89b2                	mv	s3,a2
    80001f34:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80001f36:	a01ff0ef          	jal	80001936 <myproc>
  if(user_src){
    80001f3a:	cc99                	beqz	s1,80001f58 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001f3c:	86ca                	mv	a3,s2
    80001f3e:	864e                	mv	a2,s3
    80001f40:	85d2                	mv	a1,s4
    80001f42:	7928                	ld	a0,112(a0)
    80001f44:	fceff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001f48:	70a2                	ld	ra,40(sp)
    80001f4a:	7402                	ld	s0,32(sp)
    80001f4c:	64e2                	ld	s1,24(sp)
    80001f4e:	6942                	ld	s2,16(sp)
    80001f50:	69a2                	ld	s3,8(sp)
    80001f52:	6a02                	ld	s4,0(sp)
    80001f54:	6145                	addi	sp,sp,48
    80001f56:	8082                	ret
    memmove(dst, (char*)src, len);
    80001f58:	0009061b          	sext.w	a2,s2
    80001f5c:	85ce                	mv	a1,s3
    80001f5e:	8552                	mv	a0,s4
    80001f60:	df9fe0ef          	jal	80000d58 <memmove>
    return 0;
    80001f64:	8526                	mv	a0,s1
    80001f66:	b7cd                	j	80001f48 <either_copyin+0x2a>

0000000080001f68 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001f68:	711d                	addi	sp,sp,-96
    80001f6a:	ec86                	sd	ra,88(sp)
    80001f6c:	e8a2                	sd	s0,80(sp)
    80001f6e:	e4a6                	sd	s1,72(sp)
    80001f70:	e0ca                	sd	s2,64(sp)
    80001f72:	fc4e                	sd	s3,56(sp)
    80001f74:	f852                	sd	s4,48(sp)
    80001f76:	f456                	sd	s5,40(sp)
    80001f78:	f05a                	sd	s6,32(sp)
    80001f7a:	ec5e                	sd	s7,24(sp)
    80001f7c:	e862                	sd	s8,16(sp)
    80001f7e:	e466                	sd	s9,8(sp)
    80001f80:	1080                	addi	s0,sp,96
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001f82:	00005517          	auipc	a0,0x5
    80001f86:	0f650513          	addi	a0,a0,246 # 80007078 <etext+0x78>
    80001f8a:	d70fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001f8e:	0000f917          	auipc	s2,0xf
    80001f92:	85a90913          	addi	s2,s2,-1958 # 800107e8 <proc+0x178>
    80001f96:	00015997          	auipc	s3,0x15
    80001f9a:	a5298993          	addi	s3,s3,-1454 # 800169e8 <bcache+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001f9e:	4c15                	li	s8,5
      state = states[p->state];
    else
      state = "???";
    80001fa0:	00005a17          	auipc	s4,0x5
    80001fa4:	248a0a13          	addi	s4,s4,584 # 800071e8 <etext+0x1e8>
    printf("%d %s %s", p->pid, state, p->name);
    80001fa8:	00005b97          	auipc	s7,0x5
    80001fac:	248b8b93          	addi	s7,s7,584 # 800071f0 <etext+0x1f0>
    printf(" | Lvl: %d | Ticks: [%d, %d, %d, %d] | Syscalls: %d", p->level, p->ticks[0], p->ticks[1], p->ticks[2], p->ticks[3], p->syscount);
    80001fb0:	00005b17          	auipc	s6,0x5
    80001fb4:	250b0b13          	addi	s6,s6,592 # 80007200 <etext+0x200>
    printf("\n");
    80001fb8:	00005a97          	auipc	s5,0x5
    80001fbc:	0c0a8a93          	addi	s5,s5,192 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001fc0:	00005c97          	auipc	s9,0x5
    80001fc4:	7d8c8c93          	addi	s9,s9,2008 # 80007798 <states.0>
    80001fc8:	a82d                	j	80002002 <procdump+0x9a>
    printf("%d %s %s", p->pid, state, p->name);
    80001fca:	86a6                	mv	a3,s1
    80001fcc:	eb84a583          	lw	a1,-328(s1)
    80001fd0:	855e                	mv	a0,s7
    80001fd2:	d28fe0ef          	jal	800004fa <printf>
    printf(" | Lvl: %d | Ticks: [%d, %d, %d, %d] | Syscalls: %d", p->level, p->ticks[0], p->ticks[1], p->ticks[2], p->ticks[3], p->syscount);
    80001fd6:	ebc4a803          	lw	a6,-324(s1)
    80001fda:	ed84a783          	lw	a5,-296(s1)
    80001fde:	ed44a703          	lw	a4,-300(s1)
    80001fe2:	ed04a683          	lw	a3,-304(s1)
    80001fe6:	ecc4a603          	lw	a2,-308(s1)
    80001fea:	ec04a583          	lw	a1,-320(s1)
    80001fee:	855a                	mv	a0,s6
    80001ff0:	d0afe0ef          	jal	800004fa <printf>
    printf("\n");
    80001ff4:	8556                	mv	a0,s5
    80001ff6:	d04fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ffa:	18890913          	addi	s2,s2,392
    80001ffe:	03390263          	beq	s2,s3,80002022 <procdump+0xba>
    if(p->state == UNUSED)
    80002002:	84ca                	mv	s1,s2
    80002004:	ea092783          	lw	a5,-352(s2)
    80002008:	dbed                	beqz	a5,80001ffa <procdump+0x92>
      state = "???";
    8000200a:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000200c:	fafc6fe3          	bltu	s8,a5,80001fca <procdump+0x62>
    80002010:	02079713          	slli	a4,a5,0x20
    80002014:	01d75793          	srli	a5,a4,0x1d
    80002018:	97e6                	add	a5,a5,s9
    8000201a:	6390                	ld	a2,0(a5)
    8000201c:	f65d                	bnez	a2,80001fca <procdump+0x62>
      state = "???";
    8000201e:	8652                	mv	a2,s4
    80002020:	b76d                	j	80001fca <procdump+0x62>
  }
}
    80002022:	60e6                	ld	ra,88(sp)
    80002024:	6446                	ld	s0,80(sp)
    80002026:	64a6                	ld	s1,72(sp)
    80002028:	6906                	ld	s2,64(sp)
    8000202a:	79e2                	ld	s3,56(sp)
    8000202c:	7a42                	ld	s4,48(sp)
    8000202e:	7aa2                	ld	s5,40(sp)
    80002030:	7b02                	ld	s6,32(sp)
    80002032:	6be2                	ld	s7,24(sp)
    80002034:	6c42                	ld	s8,16(sp)
    80002036:	6ca2                	ld	s9,8(sp)
    80002038:	6125                	addi	sp,sp,96
    8000203a:	8082                	ret

000000008000203c <pop_process>:



// a

struct proc* pop_process(int level){
    8000203c:	1101                	addi	sp,sp,-32
    8000203e:	ec06                	sd	ra,24(sp)
    80002040:	e822                	sd	s0,16(sp)
    80002042:	e426                	sd	s1,8(sp)
    80002044:	1000                	addi	s0,sp,32
    80002046:	84aa                	mv	s1,a0
  acquire(&queue_lock);
    80002048:	0000e517          	auipc	a0,0xe
    8000204c:	9f050513          	addi	a0,a0,-1552 # 8000fa38 <queue_lock>
    80002050:	bd9fe0ef          	jal	80000c28 <acquire>
  struct queue *q = &queues[level];

  if(q->count == 0){
    80002054:	00649793          	slli	a5,s1,0x6
    80002058:	97a6                	add	a5,a5,s1
    8000205a:	078e                	slli	a5,a5,0x3
    8000205c:	0000e717          	auipc	a4,0xe
    80002060:	df470713          	addi	a4,a4,-524 # 8000fe50 <queues>
    80002064:	97ba                	add	a5,a5,a4
    80002066:	2007a603          	lw	a2,512(a5)
    8000206a:	ce21                	beqz	a2,800020c2 <pop_process+0x86>
    release(&queue_lock);
    return 0;
  }

  struct proc *p = q->processes[q->start];
    8000206c:	0000e597          	auipc	a1,0xe
    80002070:	de458593          	addi	a1,a1,-540 # 8000fe50 <queues>
    80002074:	00649713          	slli	a4,s1,0x6
    80002078:	009706b3          	add	a3,a4,s1
    8000207c:	068e                	slli	a3,a3,0x3
    8000207e:	96ae                	add	a3,a3,a1
    80002080:	2046a783          	lw	a5,516(a3)
    80002084:	9726                	add	a4,a4,s1
    80002086:	973e                	add	a4,a4,a5
    80002088:	070e                	slli	a4,a4,0x3
    8000208a:	95ba                	add	a1,a1,a4
    8000208c:	6184                	ld	s1,0(a1)

  q->start = (q->start + 1) % NPROC;
    8000208e:	2785                	addiw	a5,a5,1
    80002090:	41f7d71b          	sraiw	a4,a5,0x1f
    80002094:	01a7571b          	srliw	a4,a4,0x1a
    80002098:	9fb9                	addw	a5,a5,a4
    8000209a:	03f7f793          	andi	a5,a5,63
    8000209e:	9f99                	subw	a5,a5,a4
    800020a0:	20f6a223          	sw	a5,516(a3)
  q->count--;
    800020a4:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    800020a6:	20c6a023          	sw	a2,512(a3)

  release(&queue_lock);
    800020aa:	0000e517          	auipc	a0,0xe
    800020ae:	98e50513          	addi	a0,a0,-1650 # 8000fa38 <queue_lock>
    800020b2:	c0bfe0ef          	jal	80000cbc <release>
  return p;
}
    800020b6:	8526                	mv	a0,s1
    800020b8:	60e2                	ld	ra,24(sp)
    800020ba:	6442                	ld	s0,16(sp)
    800020bc:	64a2                	ld	s1,8(sp)
    800020be:	6105                	addi	sp,sp,32
    800020c0:	8082                	ret
    release(&queue_lock);
    800020c2:	0000e517          	auipc	a0,0xe
    800020c6:	97650513          	addi	a0,a0,-1674 # 8000fa38 <queue_lock>
    800020ca:	bf3fe0ef          	jal	80000cbc <release>
    return 0;
    800020ce:	4481                	li	s1,0
    800020d0:	b7dd                	j	800020b6 <pop_process+0x7a>

00000000800020d2 <add_process>:

void add_process(struct proc *p){
    800020d2:	1101                	addi	sp,sp,-32
    800020d4:	ec06                	sd	ra,24(sp)
    800020d6:	e822                	sd	s0,16(sp)
    800020d8:	e426                	sd	s1,8(sp)
    800020da:	1000                	addi	s0,sp,32
    800020dc:	84aa                	mv	s1,a0
  acquire(&queue_lock);
    800020de:	0000e517          	auipc	a0,0xe
    800020e2:	95a50513          	addi	a0,a0,-1702 # 8000fa38 <queue_lock>
    800020e6:	b43fe0ef          	jal	80000c28 <acquire>
  struct queue *q = &queues[p->level];
    800020ea:	5c94                	lw	a3,56(s1)
  if(q->count == NPROC){
    800020ec:	02069713          	slli	a4,a3,0x20
    800020f0:	9301                	srli	a4,a4,0x20
    800020f2:	00671793          	slli	a5,a4,0x6
    800020f6:	97ba                	add	a5,a5,a4
    800020f8:	078e                	slli	a5,a5,0x3
    800020fa:	0000e717          	auipc	a4,0xe
    800020fe:	d5670713          	addi	a4,a4,-682 # 8000fe50 <queues>
    80002102:	97ba                	add	a5,a5,a4
    80002104:	2007a603          	lw	a2,512(a5)
    80002108:	04000793          	li	a5,64
    8000210c:	04f60e63          	beq	a2,a5,80002168 <add_process+0x96>
    release(&queue_lock);
    return;
  }

  int idx = (q->start + q->count) % NPROC;
  q->processes[idx] = p;
    80002110:	0000e597          	auipc	a1,0xe
    80002114:	d4058593          	addi	a1,a1,-704 # 8000fe50 <queues>
  int idx = (q->start + q->count) % NPROC;
    80002118:	1682                	slli	a3,a3,0x20
    8000211a:	9281                	srli	a3,a3,0x20
    8000211c:	00669713          	slli	a4,a3,0x6
    80002120:	00d707b3          	add	a5,a4,a3
    80002124:	078e                	slli	a5,a5,0x3
    80002126:	97ae                	add	a5,a5,a1
    80002128:	2047a783          	lw	a5,516(a5)
    8000212c:	9fb1                	addw	a5,a5,a2
    8000212e:	41f7d51b          	sraiw	a0,a5,0x1f
    80002132:	01a5551b          	srliw	a0,a0,0x1a
    80002136:	9fa9                	addw	a5,a5,a0
    80002138:	03f7f793          	andi	a5,a5,63
    8000213c:	9f89                	subw	a5,a5,a0
  q->processes[idx] = p;
    8000213e:	9736                	add	a4,a4,a3
    80002140:	97ba                	add	a5,a5,a4
    80002142:	078e                	slli	a5,a5,0x3
    80002144:	97ae                	add	a5,a5,a1
    80002146:	e384                	sd	s1,0(a5)
  q->count++;
    80002148:	070e                	slli	a4,a4,0x3
    8000214a:	95ba                	add	a1,a1,a4
    8000214c:	2605                	addiw	a2,a2,1
    8000214e:	20c5a023          	sw	a2,512(a1)
  release(&queue_lock);
    80002152:	0000e517          	auipc	a0,0xe
    80002156:	8e650513          	addi	a0,a0,-1818 # 8000fa38 <queue_lock>
    8000215a:	b63fe0ef          	jal	80000cbc <release>
    8000215e:	60e2                	ld	ra,24(sp)
    80002160:	6442                	ld	s0,16(sp)
    80002162:	64a2                	ld	s1,8(sp)
    80002164:	6105                	addi	sp,sp,32
    80002166:	8082                	ret
    printf("queue is full\n");
    80002168:	00005517          	auipc	a0,0x5
    8000216c:	0d050513          	addi	a0,a0,208 # 80007238 <etext+0x238>
    80002170:	b8afe0ef          	jal	800004fa <printf>
    release(&queue_lock);
    80002174:	0000e517          	auipc	a0,0xe
    80002178:	8c450513          	addi	a0,a0,-1852 # 8000fa38 <queue_lock>
    8000217c:	b41fe0ef          	jal	80000cbc <release>
    return;
    80002180:	bff9                	j	8000215e <add_process+0x8c>

0000000080002182 <userinit>:
{
    80002182:	1101                	addi	sp,sp,-32
    80002184:	ec06                	sd	ra,24(sp)
    80002186:	e822                	sd	s0,16(sp)
    80002188:	e426                	sd	s1,8(sp)
    8000218a:	1000                	addi	s0,sp,32
  p = allocproc();
    8000218c:	9d3ff0ef          	jal	80001b5e <allocproc>
    80002190:	84aa                	mv	s1,a0
  initproc = p;
    80002192:	00005797          	auipc	a5,0x5
    80002196:	76a7b723          	sd	a0,1902(a5) # 80007900 <initproc>
  p->cwd = namei("/");
    8000219a:	00005517          	auipc	a0,0x5
    8000219e:	0ae50513          	addi	a0,a0,174 # 80007248 <etext+0x248>
    800021a2:	5a5010ef          	jal	80003f46 <namei>
    800021a6:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    800021aa:	478d                	li	a5,3
    800021ac:	cc9c                	sw	a5,24(s1)
  p->level = LEVEL0;
    800021ae:	0204ac23          	sw	zero,56(s1)
  add_process(p); // adding first process to the queue
    800021b2:	8526                	mv	a0,s1
    800021b4:	f1fff0ef          	jal	800020d2 <add_process>
  release(&p->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	b03fe0ef          	jal	80000cbc <release>
}
    800021be:	60e2                	ld	ra,24(sp)
    800021c0:	6442                	ld	s0,16(sp)
    800021c2:	64a2                	ld	s1,8(sp)
    800021c4:	6105                	addi	sp,sp,32
    800021c6:	8082                	ret

00000000800021c8 <kfork>:
{
    800021c8:	7139                	addi	sp,sp,-64
    800021ca:	fc06                	sd	ra,56(sp)
    800021cc:	f822                	sd	s0,48(sp)
    800021ce:	f426                	sd	s1,40(sp)
    800021d0:	e456                	sd	s5,8(sp)
    800021d2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800021d4:	f62ff0ef          	jal	80001936 <myproc>
    800021d8:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800021da:	985ff0ef          	jal	80001b5e <allocproc>
    800021de:	0e050d63          	beqz	a0,800022d8 <kfork+0x110>
    800021e2:	ec4e                	sd	s3,24(sp)
    800021e4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800021e6:	068ab603          	ld	a2,104(s5)
    800021ea:	792c                	ld	a1,112(a0)
    800021ec:	070ab503          	ld	a0,112(s5)
    800021f0:	a44ff0ef          	jal	80001434 <uvmcopy>
    800021f4:	04054863          	bltz	a0,80002244 <kfork+0x7c>
    800021f8:	f04a                	sd	s2,32(sp)
    800021fa:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800021fc:	068ab783          	ld	a5,104(s5)
    80002200:	06f9b423          	sd	a5,104(s3)
  *(np->trapframe) = *(p->trapframe);
    80002204:	078ab683          	ld	a3,120(s5)
    80002208:	87b6                	mv	a5,a3
    8000220a:	0789b703          	ld	a4,120(s3)
    8000220e:	12068693          	addi	a3,a3,288
    80002212:	6388                	ld	a0,0(a5)
    80002214:	678c                	ld	a1,8(a5)
    80002216:	6b90                	ld	a2,16(a5)
    80002218:	e308                	sd	a0,0(a4)
    8000221a:	e70c                	sd	a1,8(a4)
    8000221c:	eb10                	sd	a2,16(a4)
    8000221e:	6f90                	ld	a2,24(a5)
    80002220:	ef10                	sd	a2,24(a4)
    80002222:	02078793          	addi	a5,a5,32
    80002226:	02070713          	addi	a4,a4,32
    8000222a:	fed794e3          	bne	a5,a3,80002212 <kfork+0x4a>
  np->trapframe->a0 = 0;
    8000222e:	0789b783          	ld	a5,120(s3)
    80002232:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002236:	0f0a8493          	addi	s1,s5,240
    8000223a:	0f098913          	addi	s2,s3,240
    8000223e:	170a8a13          	addi	s4,s5,368
    80002242:	a831                	j	8000225e <kfork+0x96>
    freeproc(np);
    80002244:	854e                	mv	a0,s3
    80002246:	8c5ff0ef          	jal	80001b0a <freeproc>
    release(&np->lock);
    8000224a:	854e                	mv	a0,s3
    8000224c:	a71fe0ef          	jal	80000cbc <release>
    return -1;
    80002250:	54fd                	li	s1,-1
    80002252:	69e2                	ld	s3,24(sp)
    80002254:	a89d                	j	800022ca <kfork+0x102>
  for(i = 0; i < NOFILE; i++)
    80002256:	04a1                	addi	s1,s1,8
    80002258:	0921                	addi	s2,s2,8
    8000225a:	01448963          	beq	s1,s4,8000226c <kfork+0xa4>
    if(p->ofile[i])
    8000225e:	6088                	ld	a0,0(s1)
    80002260:	d97d                	beqz	a0,80002256 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80002262:	2a0020ef          	jal	80004502 <filedup>
    80002266:	00a93023          	sd	a0,0(s2)
    8000226a:	b7f5                	j	80002256 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    8000226c:	170ab503          	ld	a0,368(s5)
    80002270:	472010ef          	jal	800036e2 <idup>
    80002274:	16a9b823          	sd	a0,368(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002278:	4641                	li	a2,16
    8000227a:	178a8593          	addi	a1,s5,376
    8000227e:	17898513          	addi	a0,s3,376
    80002282:	bcbfe0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80002286:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    8000228a:	854e                	mv	a0,s3
    8000228c:	a31fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80002290:	0000d517          	auipc	a0,0xd
    80002294:	79050513          	addi	a0,a0,1936 # 8000fa20 <wait_lock>
    80002298:	991fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    8000229c:	0559bc23          	sd	s5,88(s3)
  release(&wait_lock);
    800022a0:	0000d517          	auipc	a0,0xd
    800022a4:	78050513          	addi	a0,a0,1920 # 8000fa20 <wait_lock>
    800022a8:	a15fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    800022ac:	854e                	mv	a0,s3
    800022ae:	97bfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    800022b2:	478d                	li	a5,3
    800022b4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800022b8:	854e                	mv	a0,s3
    800022ba:	a03fe0ef          	jal	80000cbc <release>
  add_process(np); // adding process to the queue
    800022be:	854e                	mv	a0,s3
    800022c0:	e13ff0ef          	jal	800020d2 <add_process>
  return pid;
    800022c4:	7902                	ld	s2,32(sp)
    800022c6:	69e2                	ld	s3,24(sp)
    800022c8:	6a42                	ld	s4,16(sp)
}
    800022ca:	8526                	mv	a0,s1
    800022cc:	70e2                	ld	ra,56(sp)
    800022ce:	7442                	ld	s0,48(sp)
    800022d0:	74a2                	ld	s1,40(sp)
    800022d2:	6aa2                	ld	s5,8(sp)
    800022d4:	6121                	addi	sp,sp,64
    800022d6:	8082                	ret
    return -1;
    800022d8:	54fd                	li	s1,-1
    800022da:	bfc5                	j	800022ca <kfork+0x102>

00000000800022dc <scheduler>:
{
    800022dc:	711d                	addi	sp,sp,-96
    800022de:	ec86                	sd	ra,88(sp)
    800022e0:	e8a2                	sd	s0,80(sp)
    800022e2:	e4a6                	sd	s1,72(sp)
    800022e4:	e0ca                	sd	s2,64(sp)
    800022e6:	fc4e                	sd	s3,56(sp)
    800022e8:	f852                	sd	s4,48(sp)
    800022ea:	f456                	sd	s5,40(sp)
    800022ec:	f05a                	sd	s6,32(sp)
    800022ee:	ec5e                	sd	s7,24(sp)
    800022f0:	e862                	sd	s8,16(sp)
    800022f2:	e466                	sd	s9,8(sp)
    800022f4:	1080                	addi	s0,sp,96
    800022f6:	8492                	mv	s1,tp
  int id = r_tp();
    800022f8:	2481                	sext.w	s1,s1
  acquire(&tickslock);
    800022fa:	00014517          	auipc	a0,0x14
    800022fe:	57650513          	addi	a0,a0,1398 # 80016870 <tickslock>
    80002302:	927fe0ef          	jal	80000c28 <acquire>
  last_tick = ticks;
    80002306:	00005c97          	auipc	s9,0x5
    8000230a:	602cec83          	lwu	s9,1538(s9) # 80007908 <ticks>
  release(&tickslock);
    8000230e:	00014517          	auipc	a0,0x14
    80002312:	56250513          	addi	a0,a0,1378 # 80016870 <tickslock>
    80002316:	9a7fe0ef          	jal	80000cbc <release>
  c->proc = 0;
    8000231a:	00749b13          	slli	s6,s1,0x7
    8000231e:	0000d797          	auipc	a5,0xd
    80002322:	6ea78793          	addi	a5,a5,1770 # 8000fa08 <pid_lock>
    80002326:	97da                	add	a5,a5,s6
    80002328:	0407b423          	sd	zero,72(a5)
          swtch(&c->context, &p->context);
    8000232c:	0000d797          	auipc	a5,0xd
    80002330:	72c78793          	addi	a5,a5,1836 # 8000fa58 <cpus+0x8>
    80002334:	9b3e                	add	s6,s6,a5
    acquire(&tickslock);
    80002336:	00014b97          	auipc	s7,0x14
    8000233a:	53ab8b93          	addi	s7,s7,1338 # 80016870 <tickslock>
        if(p->state == RUNNABLE) {
    8000233e:	4a0d                	li	s4,3
          c->proc = p;
    80002340:	049e                	slli	s1,s1,0x7
    80002342:	0000da97          	auipc	s5,0xd
    80002346:	6c6a8a93          	addi	s5,s5,1734 # 8000fa08 <pid_lock>
    8000234a:	9aa6                	add	s5,s5,s1
    8000234c:	a849                	j	800023de <scheduler+0x102>
    8000234e:	0000e497          	auipc	s1,0xe
    80002352:	b0248493          	addi	s1,s1,-1278 # 8000fe50 <queues>
      for(int level=1;level<NLEVEL;level++){
    80002356:	4905                	li	s2,1
    80002358:	4c11                	li	s8,4
    8000235a:	a031                	j	80002366 <scheduler+0x8a>
    8000235c:	2905                	addiw	s2,s2,1
    8000235e:	20848493          	addi	s1,s1,520
    80002362:	01890e63          	beq	s2,s8,8000237e <scheduler+0xa2>
        while(queues[level].count){
    80002366:	4084a783          	lw	a5,1032(s1)
    8000236a:	dbed                	beqz	a5,8000235c <scheduler+0x80>
          struct proc* p = pop_process(level);
    8000236c:	854a                	mv	a0,s2
    8000236e:	ccfff0ef          	jal	8000203c <pop_process>
          if(p){
    80002372:	d975                	beqz	a0,80002366 <scheduler+0x8a>
            p->level = LEVEL0;
    80002374:	02052c23          	sw	zero,56(a0)
            add_process(p);
    80002378:	d5bff0ef          	jal	800020d2 <add_process>
    8000237c:	b7ed                	j	80002366 <scheduler+0x8a>
      last_tick = curr_tick;
    8000237e:	8cce                	mv	s9,s3
    80002380:	a8bd                	j	800023fe <scheduler+0x122>
        release(&p->lock);
    80002382:	8526                	mv	a0,s1
    80002384:	939fe0ef          	jal	80000cbc <release>
      while(queues[level].count){ // while the current level is not empty
    80002388:	2009a783          	lw	a5,512(s3)
    8000238c:	cbd9                	beqz	a5,80002422 <scheduler+0x146>
        struct proc *p = pop_process(level);
    8000238e:	854a                	mv	a0,s2
    80002390:	cadff0ef          	jal	8000203c <pop_process>
    80002394:	84aa                	mv	s1,a0
        if(p==0) continue; // skip if NULL process
    80002396:	d96d                	beqz	a0,80002388 <scheduler+0xac>
        acquire(&p->lock);
    80002398:	891fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE) {
    8000239c:	4c9c                	lw	a5,24(s1)
    8000239e:	ff4792e3          	bne	a5,s4,80002382 <scheduler+0xa6>
          p->state = RUNNING;
    800023a2:	4791                	li	a5,4
    800023a4:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    800023a6:	049ab423          	sd	s1,72(s5)
          p->delta_s = 0;
    800023aa:	0204ae23          	sw	zero,60(s1)
          p->curr_ticks = 0;
    800023ae:	0404a023          	sw	zero,64(s1)
          int process_level = p->level;
    800023b2:	0384a903          	lw	s2,56(s1)
          swtch(&c->context, &p->context);
    800023b6:	08048593          	addi	a1,s1,128
    800023ba:	855a                	mv	a0,s6
    800023bc:	2a2000ef          	jal	8000265e <swtch>
          p->ticks[process_level]+=p->curr_ticks; // using saved "process_level" value
    800023c0:	00291793          	slli	a5,s2,0x2
    800023c4:	97a6                	add	a5,a5,s1
    800023c6:	43f4                	lw	a3,68(a5)
    800023c8:	40b8                	lw	a4,64(s1)
    800023ca:	9f35                	addw	a4,a4,a3
    800023cc:	c3f8                	sw	a4,68(a5)
          p->times_scheduled++;
    800023ce:	48fc                	lw	a5,84(s1)
    800023d0:	2785                	addiw	a5,a5,1
    800023d2:	c8fc                	sw	a5,84(s1)
          c->proc = 0;
    800023d4:	040ab423          	sd	zero,72(s5)
        release(&p->lock);
    800023d8:	8526                	mv	a0,s1
    800023da:	8e3fe0ef          	jal	80000cbc <release>
    acquire(&tickslock);
    800023de:	855e                	mv	a0,s7
    800023e0:	849fe0ef          	jal	80000c28 <acquire>
    curr_tick = ticks;
    800023e4:	00005997          	auipc	s3,0x5
    800023e8:	5249e983          	lwu	s3,1316(s3) # 80007908 <ticks>
    release(&tickslock);
    800023ec:	855e                	mv	a0,s7
    800023ee:	8cffe0ef          	jal	80000cbc <release>
    if(curr_tick - last_tick >= 128){ // update all the processes to LEVEL0
    800023f2:	41998733          	sub	a4,s3,s9
    800023f6:	07f00793          	li	a5,127
    800023fa:	f4e7eae3          	bltu	a5,a4,8000234e <scheduler+0x72>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002402:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002406:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000240e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002410:	10079073          	csrw	sstatus,a5
    for(int level = 0; level < NLEVEL; level++){
    80002414:	0000e997          	auipc	s3,0xe
    80002418:	a3c98993          	addi	s3,s3,-1476 # 8000fe50 <queues>
    8000241c:	4901                	li	s2,0
    8000241e:	4c11                	li	s8,4
    80002420:	b7a5                	j	80002388 <scheduler+0xac>
    80002422:	2905                	addiw	s2,s2,1
    80002424:	20898993          	addi	s3,s3,520
    80002428:	f78910e3          	bne	s2,s8,80002388 <scheduler+0xac>
      asm volatile("wfi");
    8000242c:	10500073          	wfi
    80002430:	b77d                	j	800023de <scheduler+0x102>

0000000080002432 <yield>:
{
    80002432:	1101                	addi	sp,sp,-32
    80002434:	ec06                	sd	ra,24(sp)
    80002436:	e822                	sd	s0,16(sp)
    80002438:	e426                	sd	s1,8(sp)
    8000243a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000243c:	cfaff0ef          	jal	80001936 <myproc>
    80002440:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002442:	fe6fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002446:	478d                	li	a5,3
    80002448:	cc9c                	sw	a5,24(s1)
  if(p->curr_ticks >= (1<<(p->level+1))){ // process used complete time slice
    8000244a:	40b4                	lw	a3,64(s1)
    8000244c:	5c98                	lw	a4,56(s1)
    8000244e:	0017061b          	addiw	a2,a4,1
    80002452:	4785                	li	a5,1
    80002454:	00c797bb          	sllw	a5,a5,a2
    80002458:	00f6c863          	blt	a3,a5,80002468 <yield+0x36>
    if(p->delta_s>=p->curr_ticks){ // if interactive, keep on the same level
    8000245c:	5cdc                	lw	a5,60(s1)
      if(p->level<3) p->level++;
    8000245e:	00d7d563          	bge	a5,a3,80002468 <yield+0x36>
    80002462:	00373713          	sltiu	a4,a4,3
    80002466:	ef11                	bnez	a4,80002482 <yield+0x50>
  add_process(p);
    80002468:	8526                	mv	a0,s1
    8000246a:	c69ff0ef          	jal	800020d2 <add_process>
  sched();
    8000246e:	81dff0ef          	jal	80001c8a <sched>
  release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	849fe0ef          	jal	80000cbc <release>
}
    80002478:	60e2                	ld	ra,24(sp)
    8000247a:	6442                	ld	s0,16(sp)
    8000247c:	64a2                	ld	s1,8(sp)
    8000247e:	6105                	addi	sp,sp,32
    80002480:	8082                	ret
      if(p->level<3) p->level++;
    80002482:	dc90                	sw	a2,56(s1)
    80002484:	b7d5                	j	80002468 <yield+0x36>

0000000080002486 <wakeup>:
{
    80002486:	7139                	addi	sp,sp,-64
    80002488:	fc06                	sd	ra,56(sp)
    8000248a:	f822                	sd	s0,48(sp)
    8000248c:	f426                	sd	s1,40(sp)
    8000248e:	f04a                	sd	s2,32(sp)
    80002490:	ec4e                	sd	s3,24(sp)
    80002492:	e852                	sd	s4,16(sp)
    80002494:	e456                	sd	s5,8(sp)
    80002496:	0080                	addi	s0,sp,64
    80002498:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000249a:	0000e497          	auipc	s1,0xe
    8000249e:	1d648493          	addi	s1,s1,470 # 80010670 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    800024a2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024a4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800024a6:	00014917          	auipc	s2,0x14
    800024aa:	3ca90913          	addi	s2,s2,970 # 80016870 <tickslock>
    800024ae:	a801                	j	800024be <wakeup+0x38>
      release(&p->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	80bfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024b6:	18848493          	addi	s1,s1,392
    800024ba:	03248563          	beq	s1,s2,800024e4 <wakeup+0x5e>
    if(p != myproc()){
    800024be:	c78ff0ef          	jal	80001936 <myproc>
    800024c2:	fe950ae3          	beq	a0,s1,800024b6 <wakeup+0x30>
      acquire(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	f60fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800024cc:	4c9c                	lw	a5,24(s1)
    800024ce:	ff3791e3          	bne	a5,s3,800024b0 <wakeup+0x2a>
    800024d2:	709c                	ld	a5,32(s1)
    800024d4:	fd479ee3          	bne	a5,s4,800024b0 <wakeup+0x2a>
        p->state = RUNNABLE;
    800024d8:	0154ac23          	sw	s5,24(s1)
        add_process(p); // adding the process back to queue (same level as previous)
    800024dc:	8526                	mv	a0,s1
    800024de:	bf5ff0ef          	jal	800020d2 <add_process>
    800024e2:	b7f9                	j	800024b0 <wakeup+0x2a>
}
    800024e4:	70e2                	ld	ra,56(sp)
    800024e6:	7442                	ld	s0,48(sp)
    800024e8:	74a2                	ld	s1,40(sp)
    800024ea:	7902                	ld	s2,32(sp)
    800024ec:	69e2                	ld	s3,24(sp)
    800024ee:	6a42                	ld	s4,16(sp)
    800024f0:	6aa2                	ld	s5,8(sp)
    800024f2:	6121                	addi	sp,sp,64
    800024f4:	8082                	ret

00000000800024f6 <reparent>:
{
    800024f6:	7179                	addi	sp,sp,-48
    800024f8:	f406                	sd	ra,40(sp)
    800024fa:	f022                	sd	s0,32(sp)
    800024fc:	ec26                	sd	s1,24(sp)
    800024fe:	e84a                	sd	s2,16(sp)
    80002500:	e44e                	sd	s3,8(sp)
    80002502:	e052                	sd	s4,0(sp)
    80002504:	1800                	addi	s0,sp,48
    80002506:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002508:	0000e497          	auipc	s1,0xe
    8000250c:	16848493          	addi	s1,s1,360 # 80010670 <proc>
      pp->parent = initproc;
    80002510:	00005a17          	auipc	s4,0x5
    80002514:	3f0a0a13          	addi	s4,s4,1008 # 80007900 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002518:	00014997          	auipc	s3,0x14
    8000251c:	35898993          	addi	s3,s3,856 # 80016870 <tickslock>
    80002520:	a029                	j	8000252a <reparent+0x34>
    80002522:	18848493          	addi	s1,s1,392
    80002526:	01348b63          	beq	s1,s3,8000253c <reparent+0x46>
    if(pp->parent == p){
    8000252a:	6cbc                	ld	a5,88(s1)
    8000252c:	ff279be3          	bne	a5,s2,80002522 <reparent+0x2c>
      pp->parent = initproc;
    80002530:	000a3503          	ld	a0,0(s4)
    80002534:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    80002536:	f51ff0ef          	jal	80002486 <wakeup>
    8000253a:	b7e5                	j	80002522 <reparent+0x2c>
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6a02                	ld	s4,0(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <kexit>:
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000255e:	bd8ff0ef          	jal	80001936 <myproc>
    80002562:	89aa                	mv	s3,a0
  if(p == initproc)
    80002564:	00005797          	auipc	a5,0x5
    80002568:	39c7b783          	ld	a5,924(a5) # 80007900 <initproc>
    8000256c:	0f050493          	addi	s1,a0,240
    80002570:	17050913          	addi	s2,a0,368
    80002574:	00a79b63          	bne	a5,a0,8000258a <kexit+0x3e>
    panic("init exiting");
    80002578:	00005517          	auipc	a0,0x5
    8000257c:	cd850513          	addi	a0,a0,-808 # 80007250 <etext+0x250>
    80002580:	aa4fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002584:	04a1                	addi	s1,s1,8
    80002586:	01248963          	beq	s1,s2,80002598 <kexit+0x4c>
    if(p->ofile[fd]){
    8000258a:	6088                	ld	a0,0(s1)
    8000258c:	dd65                	beqz	a0,80002584 <kexit+0x38>
      fileclose(f);
    8000258e:	7bb010ef          	jal	80004548 <fileclose>
      p->ofile[fd] = 0;
    80002592:	0004b023          	sd	zero,0(s1)
    80002596:	b7fd                	j	80002584 <kexit+0x38>
  begin_op();
    80002598:	38d010ef          	jal	80004124 <begin_op>
  iput(p->cwd);
    8000259c:	1709b503          	ld	a0,368(s3)
    800025a0:	2fa010ef          	jal	8000389a <iput>
  end_op();
    800025a4:	3f1010ef          	jal	80004194 <end_op>
  p->cwd = 0;
    800025a8:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    800025ac:	0000d517          	auipc	a0,0xd
    800025b0:	47450513          	addi	a0,a0,1140 # 8000fa20 <wait_lock>
    800025b4:	e74fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800025b8:	854e                	mv	a0,s3
    800025ba:	f3dff0ef          	jal	800024f6 <reparent>
  wakeup(p->parent);
    800025be:	0589b503          	ld	a0,88(s3)
    800025c2:	ec5ff0ef          	jal	80002486 <wakeup>
  acquire(&p->lock);
    800025c6:	854e                	mv	a0,s3
    800025c8:	e60fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800025cc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025d0:	4795                	li	a5,5
    800025d2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025d6:	0000d517          	auipc	a0,0xd
    800025da:	44a50513          	addi	a0,a0,1098 # 8000fa20 <wait_lock>
    800025de:	edefe0ef          	jal	80000cbc <release>
  sched();
    800025e2:	ea8ff0ef          	jal	80001c8a <sched>
  panic("zombie exit");
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	c7a50513          	addi	a0,a0,-902 # 80007260 <etext+0x260>
    800025ee:	a36fe0ef          	jal	80000824 <panic>

00000000800025f2 <kkill>:
{
    800025f2:	7179                	addi	sp,sp,-48
    800025f4:	f406                	sd	ra,40(sp)
    800025f6:	f022                	sd	s0,32(sp)
    800025f8:	ec26                	sd	s1,24(sp)
    800025fa:	e84a                	sd	s2,16(sp)
    800025fc:	e44e                	sd	s3,8(sp)
    800025fe:	1800                	addi	s0,sp,48
    80002600:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002602:	0000e497          	auipc	s1,0xe
    80002606:	06e48493          	addi	s1,s1,110 # 80010670 <proc>
    8000260a:	00014997          	auipc	s3,0x14
    8000260e:	26698993          	addi	s3,s3,614 # 80016870 <tickslock>
    acquire(&p->lock);
    80002612:	8526                	mv	a0,s1
    80002614:	e14fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002618:	589c                	lw	a5,48(s1)
    8000261a:	01278b63          	beq	a5,s2,80002630 <kkill+0x3e>
    release(&p->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	e9cfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002624:	18848493          	addi	s1,s1,392
    80002628:	ff3495e3          	bne	s1,s3,80002612 <kkill+0x20>
  return -1;
    8000262c:	557d                	li	a0,-1
    8000262e:	a819                	j	80002644 <kkill+0x52>
      p->killed = 1;
    80002630:	4785                	li	a5,1
    80002632:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002634:	4c98                	lw	a4,24(s1)
    80002636:	4789                	li	a5,2
    80002638:	00f70d63          	beq	a4,a5,80002652 <kkill+0x60>
      release(&p->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	e7efe0ef          	jal	80000cbc <release>
      return 0;
    80002642:	4501                	li	a0,0
}
    80002644:	70a2                	ld	ra,40(sp)
    80002646:	7402                	ld	s0,32(sp)
    80002648:	64e2                	ld	s1,24(sp)
    8000264a:	6942                	ld	s2,16(sp)
    8000264c:	69a2                	ld	s3,8(sp)
    8000264e:	6145                	addi	sp,sp,48
    80002650:	8082                	ret
        p->state = RUNNABLE;
    80002652:	478d                	li	a5,3
    80002654:	cc9c                	sw	a5,24(s1)
        add_process(p);
    80002656:	8526                	mv	a0,s1
    80002658:	a7bff0ef          	jal	800020d2 <add_process>
    8000265c:	b7c5                	j	8000263c <kkill+0x4a>

000000008000265e <swtch>:
# Save current registers in old. Load from new.	

# here a0 means first input, i.e. *old and a1 means second input, i.e. *new
.globl swtch
swtch:
        sd ra, 0(a0)
    8000265e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002662:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002666:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002668:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000266a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000266e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002672:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002676:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000267a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000267e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002682:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002686:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000268a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000268e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002692:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002696:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000269a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000269c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000269e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800026a2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800026a6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800026aa:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800026ae:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800026b2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800026b6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800026ba:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800026be:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800026c2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800026c6:	8082                	ret

00000000800026c8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c8:	1141                	addi	sp,sp,-16
    800026ca:	e406                	sd	ra,8(sp)
    800026cc:	e022                	sd	s0,0(sp)
    800026ce:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026d0:	00005597          	auipc	a1,0x5
    800026d4:	bd058593          	addi	a1,a1,-1072 # 800072a0 <etext+0x2a0>
    800026d8:	00014517          	auipc	a0,0x14
    800026dc:	19850513          	addi	a0,a0,408 # 80016870 <tickslock>
    800026e0:	cbefe0ef          	jal	80000b9e <initlock>
}
    800026e4:	60a2                	ld	ra,8(sp)
    800026e6:	6402                	ld	s0,0(sp)
    800026e8:	0141                	addi	sp,sp,16
    800026ea:	8082                	ret

00000000800026ec <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026ec:	1141                	addi	sp,sp,-16
    800026ee:	e406                	sd	ra,8(sp)
    800026f0:	e022                	sd	s0,0(sp)
    800026f2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f4:	00003797          	auipc	a5,0x3
    800026f8:	21c78793          	addi	a5,a5,540 # 80005910 <kernelvec>
    800026fc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002700:	60a2                	ld	ra,8(sp)
    80002702:	6402                	ld	s0,0(sp)
    80002704:	0141                	addi	sp,sp,16
    80002706:	8082                	ret

0000000080002708 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002708:	1141                	addi	sp,sp,-16
    8000270a:	e406                	sd	ra,8(sp)
    8000270c:	e022                	sd	s0,0(sp)
    8000270e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002710:	a26ff0ef          	jal	80001936 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002714:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002718:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000271a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000271e:	04000737          	lui	a4,0x4000
    80002722:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002724:	0732                	slli	a4,a4,0xc
    80002726:	00004797          	auipc	a5,0x4
    8000272a:	8da78793          	addi	a5,a5,-1830 # 80006000 <_trampoline>
    8000272e:	00004697          	auipc	a3,0x4
    80002732:	8d268693          	addi	a3,a3,-1838 # 80006000 <_trampoline>
    80002736:	8f95                	sub	a5,a5,a3
    80002738:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000273e:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002740:	18002773          	csrr	a4,satp
    80002744:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002746:	7d38                	ld	a4,120(a0)
    80002748:	713c                	ld	a5,96(a0)
    8000274a:	6685                	lui	a3,0x1
    8000274c:	97b6                	add	a5,a5,a3
    8000274e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002750:	7d3c                	ld	a5,120(a0)
    80002752:	00000717          	auipc	a4,0x0
    80002756:	0fc70713          	addi	a4,a4,252 # 8000284e <usertrap>
    8000275a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000275c:	7d3c                	ld	a5,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000275e:	8712                	mv	a4,tp
    80002760:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002762:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002766:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000276a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000276e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002772:	7d3c                	ld	a5,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002774:	6f9c                	ld	a5,24(a5)
    80002776:	14179073          	csrw	sepc,a5
}
    8000277a:	60a2                	ld	ra,8(sp)
    8000277c:	6402                	ld	s0,0(sp)
    8000277e:	0141                	addi	sp,sp,16
    80002780:	8082                	ret

0000000080002782 <clockintr>:

// runs clock interrupt generator in CPU:0
// increases tick count by 1
void
clockintr()
{
    80002782:	1141                	addi	sp,sp,-16
    80002784:	e406                	sd	ra,8(sp)
    80002786:	e022                	sd	s0,0(sp)
    80002788:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000278a:	978ff0ef          	jal	80001902 <cpuid>
    8000278e:	cd11                	beqz	a0,800027aa <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002790:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002794:	000f4737          	lui	a4,0xf4
    80002798:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000279c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000279e:	14d79073          	csrw	stimecmp,a5
}
    800027a2:	60a2                	ld	ra,8(sp)
    800027a4:	6402                	ld	s0,0(sp)
    800027a6:	0141                	addi	sp,sp,16
    800027a8:	8082                	ret
    acquire(&tickslock);
    800027aa:	00014517          	auipc	a0,0x14
    800027ae:	0c650513          	addi	a0,a0,198 # 80016870 <tickslock>
    800027b2:	c76fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800027b6:	00005717          	auipc	a4,0x5
    800027ba:	15270713          	addi	a4,a4,338 # 80007908 <ticks>
    800027be:	431c                	lw	a5,0(a4)
    800027c0:	2785                	addiw	a5,a5,1
    800027c2:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800027c4:	853a                	mv	a0,a4
    800027c6:	cc1ff0ef          	jal	80002486 <wakeup>
    release(&tickslock);
    800027ca:	00014517          	auipc	a0,0x14
    800027ce:	0a650513          	addi	a0,a0,166 # 80016870 <tickslock>
    800027d2:	ceafe0ef          	jal	80000cbc <release>
    800027d6:	bf6d                	j	80002790 <clockintr+0xe>

00000000800027d8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027d8:	1101                	addi	sp,sp,-32
    800027da:	ec06                	sd	ra,24(sp)
    800027dc:	e822                	sd	s0,16(sp)
    800027de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027e0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800027e4:	57fd                	li	a5,-1
    800027e6:	17fe                	slli	a5,a5,0x3f
    800027e8:	07a5                	addi	a5,a5,9
    800027ea:	00f70c63          	beq	a4,a5,80002802 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800027ee:	57fd                	li	a5,-1
    800027f0:	17fe                	slli	a5,a5,0x3f
    800027f2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027f4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027f6:	04f70863          	beq	a4,a5,80002846 <devintr+0x6e>
  }
}
    800027fa:	60e2                	ld	ra,24(sp)
    800027fc:	6442                	ld	s0,16(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret
    80002802:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002804:	1b8030ef          	jal	800059bc <plic_claim>
    80002808:	872a                	mv	a4,a0
    8000280a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000280c:	47a9                	li	a5,10
    8000280e:	00f50963          	beq	a0,a5,80002820 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002812:	4785                	li	a5,1
    80002814:	00f50963          	beq	a0,a5,80002826 <devintr+0x4e>
    return 1;
    80002818:	4505                	li	a0,1
    } else if(irq){
    8000281a:	eb09                	bnez	a4,8000282c <devintr+0x54>
    8000281c:	64a2                	ld	s1,8(sp)
    8000281e:	bff1                	j	800027fa <devintr+0x22>
      uartintr();
    80002820:	9d4fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002824:	a819                	j	8000283a <devintr+0x62>
      virtio_disk_intr();
    80002826:	62c030ef          	jal	80005e52 <virtio_disk_intr>
    if(irq)
    8000282a:	a801                	j	8000283a <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000282c:	85ba                	mv	a1,a4
    8000282e:	00005517          	auipc	a0,0x5
    80002832:	a7a50513          	addi	a0,a0,-1414 # 800072a8 <etext+0x2a8>
    80002836:	cc5fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000283a:	8526                	mv	a0,s1
    8000283c:	1a0030ef          	jal	800059dc <plic_complete>
    return 1;
    80002840:	4505                	li	a0,1
    80002842:	64a2                	ld	s1,8(sp)
    80002844:	bf5d                	j	800027fa <devintr+0x22>
    clockintr();
    80002846:	f3dff0ef          	jal	80002782 <clockintr>
    return 2;
    8000284a:	4509                	li	a0,2
    8000284c:	b77d                	j	800027fa <devintr+0x22>

000000008000284e <usertrap>:
{
    8000284e:	1101                	addi	sp,sp,-32
    80002850:	ec06                	sd	ra,24(sp)
    80002852:	e822                	sd	s0,16(sp)
    80002854:	e426                	sd	s1,8(sp)
    80002856:	e04a                	sd	s2,0(sp)
    80002858:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000285e:	1007f793          	andi	a5,a5,256
    80002862:	eba5                	bnez	a5,800028d2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002864:	00003797          	auipc	a5,0x3
    80002868:	0ac78793          	addi	a5,a5,172 # 80005910 <kernelvec>
    8000286c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002870:	8c6ff0ef          	jal	80001936 <myproc>
    80002874:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002876:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002878:	14102773          	csrr	a4,sepc
    8000287c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002882:	47a1                	li	a5,8
    80002884:	04f70d63          	beq	a4,a5,800028de <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002888:	f51ff0ef          	jal	800027d8 <devintr>
    8000288c:	892a                	mv	s2,a0
    8000288e:	e945                	bnez	a0,8000293e <usertrap+0xf0>
    80002890:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002894:	47bd                	li	a5,15
    80002896:	08f70863          	beq	a4,a5,80002926 <usertrap+0xd8>
    8000289a:	14202773          	csrr	a4,scause
    8000289e:	47b5                	li	a5,13
    800028a0:	08f70363          	beq	a4,a5,80002926 <usertrap+0xd8>
    800028a4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800028a8:	5890                	lw	a2,48(s1)
    800028aa:	00005517          	auipc	a0,0x5
    800028ae:	a3e50513          	addi	a0,a0,-1474 # 800072e8 <etext+0x2e8>
    800028b2:	c49fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028b6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ba:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800028be:	00005517          	auipc	a0,0x5
    800028c2:	a5a50513          	addi	a0,a0,-1446 # 80007318 <etext+0x318>
    800028c6:	c35fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800028ca:	8526                	mv	a0,s1
    800028cc:	cc6ff0ef          	jal	80001d92 <setkilled>
    800028d0:	a035                	j	800028fc <usertrap+0xae>
    panic("usertrap: not from user mode");
    800028d2:	00005517          	auipc	a0,0x5
    800028d6:	9f650513          	addi	a0,a0,-1546 # 800072c8 <etext+0x2c8>
    800028da:	f4bfd0ef          	jal	80000824 <panic>
    if(killed(p)) // if the process is killed, then simply exit it
    800028de:	cd8ff0ef          	jal	80001db6 <killed>
    800028e2:	ed15                	bnez	a0,8000291e <usertrap+0xd0>
    p->trapframe->epc += 4;
    800028e4:	7cb8                	ld	a4,120(s1)
    800028e6:	6f1c                	ld	a5,24(a4)
    800028e8:	0791                	addi	a5,a5,4
    800028ea:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f4:	10079073          	csrw	sstatus,a5
    syscall();
    800028f8:	26c000ef          	jal	80002b64 <syscall>
  if(killed(p))
    800028fc:	8526                	mv	a0,s1
    800028fe:	cb8ff0ef          	jal	80001db6 <killed>
    80002902:	e139                	bnez	a0,80002948 <usertrap+0xfa>
  prepare_return();
    80002904:	e05ff0ef          	jal	80002708 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002908:	78a8                	ld	a0,112(s1)
    8000290a:	8131                	srli	a0,a0,0xc
    8000290c:	57fd                	li	a5,-1
    8000290e:	17fe                	slli	a5,a5,0x3f
    80002910:	8d5d                	or	a0,a0,a5
}
    80002912:	60e2                	ld	ra,24(sp)
    80002914:	6442                	ld	s0,16(sp)
    80002916:	64a2                	ld	s1,8(sp)
    80002918:	6902                	ld	s2,0(sp)
    8000291a:	6105                	addi	sp,sp,32
    8000291c:	8082                	ret
      kexit(-1);
    8000291e:	557d                	li	a0,-1
    80002920:	c2dff0ef          	jal	8000254c <kexit>
    80002924:	b7c1                	j	800028e4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002926:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000292e:	164d                	addi	a2,a2,-13
    80002930:	00163613          	seqz	a2,a2
    80002934:	78a8                	ld	a0,112(s1)
    80002936:	c9bfe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000293a:	f169                	bnez	a0,800028fc <usertrap+0xae>
    8000293c:	b7a5                	j	800028a4 <usertrap+0x56>
  if(killed(p))
    8000293e:	8526                	mv	a0,s1
    80002940:	c76ff0ef          	jal	80001db6 <killed>
    80002944:	c511                	beqz	a0,80002950 <usertrap+0x102>
    80002946:	a011                	j	8000294a <usertrap+0xfc>
    80002948:	4901                	li	s2,0
    kexit(-1);
    8000294a:	557d                	li	a0,-1
    8000294c:	c01ff0ef          	jal	8000254c <kexit>
  if(which_dev == 2){
    80002950:	4789                	li	a5,2
    80002952:	faf919e3          	bne	s2,a5,80002904 <usertrap+0xb6>
    p->curr_ticks++;
    80002956:	40bc                	lw	a5,64(s1)
    80002958:	2785                	addiw	a5,a5,1
    8000295a:	c0bc                	sw	a5,64(s1)
    if(1<<(p->level+1) <= p->curr_ticks) // yield if time slice at current level is used
    8000295c:	5c94                	lw	a3,56(s1)
    8000295e:	2685                	addiw	a3,a3,1 # 1001 <_entry-0x7fffefff>
    80002960:	4705                	li	a4,1
    80002962:	00d7173b          	sllw	a4,a4,a3
    80002966:	f8e7cfe3          	blt	a5,a4,80002904 <usertrap+0xb6>
    yield();
    8000296a:	ac9ff0ef          	jal	80002432 <yield>
    8000296e:	bf59                	j	80002904 <usertrap+0xb6>

0000000080002970 <kerneltrap>:
{
    80002970:	7179                	addi	sp,sp,-48
    80002972:	f406                	sd	ra,40(sp)
    80002974:	f022                	sd	s0,32(sp)
    80002976:	ec26                	sd	s1,24(sp)
    80002978:	e84a                	sd	s2,16(sp)
    8000297a:	e44e                	sd	s3,8(sp)
    8000297c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002982:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002986:	142027f3          	csrr	a5,scause
    8000298a:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000298c:	1004f793          	andi	a5,s1,256
    80002990:	c795                	beqz	a5,800029bc <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002992:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002996:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002998:	eb85                	bnez	a5,800029c8 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    8000299a:	e3fff0ef          	jal	800027d8 <devintr>
    8000299e:	c91d                	beqz	a0,800029d4 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0){
    800029a0:	4789                	li	a5,2
    800029a2:	04f50a63          	beq	a0,a5,800029f6 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029a6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029aa:	10049073          	csrw	sstatus,s1
}
    800029ae:	70a2                	ld	ra,40(sp)
    800029b0:	7402                	ld	s0,32(sp)
    800029b2:	64e2                	ld	s1,24(sp)
    800029b4:	6942                	ld	s2,16(sp)
    800029b6:	69a2                	ld	s3,8(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029bc:	00005517          	auipc	a0,0x5
    800029c0:	98450513          	addi	a0,a0,-1660 # 80007340 <etext+0x340>
    800029c4:	e61fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    800029c8:	00005517          	auipc	a0,0x5
    800029cc:	9a050513          	addi	a0,a0,-1632 # 80007368 <etext+0x368>
    800029d0:	e55fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800029dc:	85ce                	mv	a1,s3
    800029de:	00005517          	auipc	a0,0x5
    800029e2:	9aa50513          	addi	a0,a0,-1622 # 80007388 <etext+0x388>
    800029e6:	b15fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800029ea:	00005517          	auipc	a0,0x5
    800029ee:	9c650513          	addi	a0,a0,-1594 # 800073b0 <etext+0x3b0>
    800029f2:	e33fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0){
    800029f6:	f41fe0ef          	jal	80001936 <myproc>
    800029fa:	d555                	beqz	a0,800029a6 <kerneltrap+0x36>
    struct proc *p = myproc();
    800029fc:	f3bfe0ef          	jal	80001936 <myproc>
    p->curr_ticks++;
    80002a00:	413c                	lw	a5,64(a0)
    80002a02:	2785                	addiw	a5,a5,1
    80002a04:	c13c                	sw	a5,64(a0)
    if(1<<(p->level+1) <= p->curr_ticks) // yield if time slice at current level is used
    80002a06:	5d14                	lw	a3,56(a0)
    80002a08:	2685                	addiw	a3,a3,1
    80002a0a:	4705                	li	a4,1
    80002a0c:	00d7173b          	sllw	a4,a4,a3
    80002a10:	f8e7cbe3          	blt	a5,a4,800029a6 <kerneltrap+0x36>
    yield();
    80002a14:	a1fff0ef          	jal	80002432 <yield>
    80002a18:	b779                	j	800029a6 <kerneltrap+0x36>

0000000080002a1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	1000                	addi	s0,sp,32
    80002a24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a26:	f11fe0ef          	jal	80001936 <myproc>
  switch (n) {
    80002a2a:	4795                	li	a5,5
    80002a2c:	0497e163          	bltu	a5,s1,80002a6e <argraw+0x54>
    80002a30:	048a                	slli	s1,s1,0x2
    80002a32:	00005717          	auipc	a4,0x5
    80002a36:	d9670713          	addi	a4,a4,-618 # 800077c8 <states.0+0x30>
    80002a3a:	94ba                	add	s1,s1,a4
    80002a3c:	409c                	lw	a5,0(s1)
    80002a3e:	97ba                	add	a5,a5,a4
    80002a40:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a42:	7d3c                	ld	a5,120(a0)
    80002a44:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a46:	60e2                	ld	ra,24(sp)
    80002a48:	6442                	ld	s0,16(sp)
    80002a4a:	64a2                	ld	s1,8(sp)
    80002a4c:	6105                	addi	sp,sp,32
    80002a4e:	8082                	ret
    return p->trapframe->a1;
    80002a50:	7d3c                	ld	a5,120(a0)
    80002a52:	7fa8                	ld	a0,120(a5)
    80002a54:	bfcd                	j	80002a46 <argraw+0x2c>
    return p->trapframe->a2;
    80002a56:	7d3c                	ld	a5,120(a0)
    80002a58:	63c8                	ld	a0,128(a5)
    80002a5a:	b7f5                	j	80002a46 <argraw+0x2c>
    return p->trapframe->a3;
    80002a5c:	7d3c                	ld	a5,120(a0)
    80002a5e:	67c8                	ld	a0,136(a5)
    80002a60:	b7dd                	j	80002a46 <argraw+0x2c>
    return p->trapframe->a4;
    80002a62:	7d3c                	ld	a5,120(a0)
    80002a64:	6bc8                	ld	a0,144(a5)
    80002a66:	b7c5                	j	80002a46 <argraw+0x2c>
    return p->trapframe->a5;
    80002a68:	7d3c                	ld	a5,120(a0)
    80002a6a:	6fc8                	ld	a0,152(a5)
    80002a6c:	bfe9                	j	80002a46 <argraw+0x2c>
  panic("argraw");
    80002a6e:	00005517          	auipc	a0,0x5
    80002a72:	95250513          	addi	a0,a0,-1710 # 800073c0 <etext+0x3c0>
    80002a76:	daffd0ef          	jal	80000824 <panic>

0000000080002a7a <fetchaddr>:
{
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	e04a                	sd	s2,0(sp)
    80002a84:	1000                	addi	s0,sp,32
    80002a86:	84aa                	mv	s1,a0
    80002a88:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a8a:	eadfe0ef          	jal	80001936 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a8e:	753c                	ld	a5,104(a0)
    80002a90:	02f4f663          	bgeu	s1,a5,80002abc <fetchaddr+0x42>
    80002a94:	00848713          	addi	a4,s1,8
    80002a98:	02e7e463          	bltu	a5,a4,80002ac0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a9c:	46a1                	li	a3,8
    80002a9e:	8626                	mv	a2,s1
    80002aa0:	85ca                	mv	a1,s2
    80002aa2:	7928                	ld	a0,112(a0)
    80002aa4:	c6ffe0ef          	jal	80001712 <copyin>
    80002aa8:	00a03533          	snez	a0,a0
    80002aac:	40a0053b          	negw	a0,a0
}
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6902                	ld	s2,0(sp)
    80002ab8:	6105                	addi	sp,sp,32
    80002aba:	8082                	ret
    return -1;
    80002abc:	557d                	li	a0,-1
    80002abe:	bfcd                	j	80002ab0 <fetchaddr+0x36>
    80002ac0:	557d                	li	a0,-1
    80002ac2:	b7fd                	j	80002ab0 <fetchaddr+0x36>

0000000080002ac4 <fetchstr>:
{
    80002ac4:	7179                	addi	sp,sp,-48
    80002ac6:	f406                	sd	ra,40(sp)
    80002ac8:	f022                	sd	s0,32(sp)
    80002aca:	ec26                	sd	s1,24(sp)
    80002acc:	e84a                	sd	s2,16(sp)
    80002ace:	e44e                	sd	s3,8(sp)
    80002ad0:	1800                	addi	s0,sp,48
    80002ad2:	89aa                	mv	s3,a0
    80002ad4:	84ae                	mv	s1,a1
    80002ad6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ad8:	e5ffe0ef          	jal	80001936 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002adc:	86ca                	mv	a3,s2
    80002ade:	864e                	mv	a2,s3
    80002ae0:	85a6                	mv	a1,s1
    80002ae2:	7928                	ld	a0,112(a0)
    80002ae4:	a15fe0ef          	jal	800014f8 <copyinstr>
    80002ae8:	00054c63          	bltz	a0,80002b00 <fetchstr+0x3c>
  return strlen(buf);
    80002aec:	8526                	mv	a0,s1
    80002aee:	b94fe0ef          	jal	80000e82 <strlen>
}
    80002af2:	70a2                	ld	ra,40(sp)
    80002af4:	7402                	ld	s0,32(sp)
    80002af6:	64e2                	ld	s1,24(sp)
    80002af8:	6942                	ld	s2,16(sp)
    80002afa:	69a2                	ld	s3,8(sp)
    80002afc:	6145                	addi	sp,sp,48
    80002afe:	8082                	ret
    return -1;
    80002b00:	557d                	li	a0,-1
    80002b02:	bfc5                	j	80002af2 <fetchstr+0x2e>

0000000080002b04 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b04:	1101                	addi	sp,sp,-32
    80002b06:	ec06                	sd	ra,24(sp)
    80002b08:	e822                	sd	s0,16(sp)
    80002b0a:	e426                	sd	s1,8(sp)
    80002b0c:	1000                	addi	s0,sp,32
    80002b0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b10:	f0bff0ef          	jal	80002a1a <argraw>
    80002b14:	c088                	sw	a0,0(s1)
}
    80002b16:	60e2                	ld	ra,24(sp)
    80002b18:	6442                	ld	s0,16(sp)
    80002b1a:	64a2                	ld	s1,8(sp)
    80002b1c:	6105                	addi	sp,sp,32
    80002b1e:	8082                	ret

0000000080002b20 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	e426                	sd	s1,8(sp)
    80002b28:	1000                	addi	s0,sp,32
    80002b2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b2c:	eefff0ef          	jal	80002a1a <argraw>
    80002b30:	e088                	sd	a0,0(s1)
}
    80002b32:	60e2                	ld	ra,24(sp)
    80002b34:	6442                	ld	s0,16(sp)
    80002b36:	64a2                	ld	s1,8(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret

0000000080002b3c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b3c:	1101                	addi	sp,sp,-32
    80002b3e:	ec06                	sd	ra,24(sp)
    80002b40:	e822                	sd	s0,16(sp)
    80002b42:	e426                	sd	s1,8(sp)
    80002b44:	e04a                	sd	s2,0(sp)
    80002b46:	1000                	addi	s0,sp,32
    80002b48:	892e                	mv	s2,a1
    80002b4a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002b4c:	ecfff0ef          	jal	80002a1a <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002b50:	8626                	mv	a2,s1
    80002b52:	85ca                	mv	a1,s2
    80002b54:	f71ff0ef          	jal	80002ac4 <fetchstr>
}
    80002b58:	60e2                	ld	ra,24(sp)
    80002b5a:	6442                	ld	s0,16(sp)
    80002b5c:	64a2                	ld	s1,8(sp)
    80002b5e:	6902                	ld	s2,0(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret

0000000080002b64 <syscall>:
[SYS_getmlfqinfo] sys_getmlfqinfo,
};

void
syscall(void)
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	e04a                	sd	s2,0(sp)
    80002b6e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b70:	dc7fe0ef          	jal	80001936 <myproc>
    80002b74:	84aa                	mv	s1,a0
  
  num = p->trapframe->a7;
    80002b76:	07853903          	ld	s2,120(a0)
    80002b7a:	0a893783          	ld	a5,168(s2)
    80002b7e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b82:	37fd                	addiw	a5,a5,-1
    80002b84:	4771                	li	a4,28
    80002b86:	02f76b63          	bltu	a4,a5,80002bbc <syscall+0x58>
    80002b8a:	00369713          	slli	a4,a3,0x3
    80002b8e:	00005797          	auipc	a5,0x5
    80002b92:	c5278793          	addi	a5,a5,-942 # 800077e0 <syscalls>
    80002b96:	97ba                	add	a5,a5,a4
    80002b98:	639c                	ld	a5,0(a5)
    80002b9a:	c38d                	beqz	a5,80002bbc <syscall+0x58>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b9c:	9782                	jalr	a5
    80002b9e:	06a93823          	sd	a0,112(s2)

    // a
    acquire(&p->lock);
    80002ba2:	8526                	mv	a0,s1
    80002ba4:	884fe0ef          	jal	80000c28 <acquire>
    p->syscount++;
    80002ba8:	58dc                	lw	a5,52(s1)
    80002baa:	2785                	addiw	a5,a5,1
    80002bac:	d8dc                	sw	a5,52(s1)
    p->delta_s++;
    80002bae:	5cdc                	lw	a5,60(s1)
    80002bb0:	2785                	addiw	a5,a5,1
    80002bb2:	dcdc                	sw	a5,60(s1)
    release(&p->lock);
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	906fe0ef          	jal	80000cbc <release>
    80002bba:	a829                	j	80002bd4 <syscall+0x70>

  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bbc:	17848613          	addi	a2,s1,376
    80002bc0:	588c                	lw	a1,48(s1)
    80002bc2:	00005517          	auipc	a0,0x5
    80002bc6:	80650513          	addi	a0,a0,-2042 # 800073c8 <etext+0x3c8>
    80002bca:	931fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bce:	7cbc                	ld	a5,120(s1)
    80002bd0:	577d                	li	a4,-1
    80002bd2:	fbb8                	sd	a4,112(a5)
  }
}
    80002bd4:	60e2                	ld	ra,24(sp)
    80002bd6:	6442                	ld	s0,16(sp)
    80002bd8:	64a2                	ld	s1,8(sp)
    80002bda:	6902                	ld	s2,0(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002be8:	fec40593          	addi	a1,s0,-20
    80002bec:	4501                	li	a0,0
    80002bee:	f17ff0ef          	jal	80002b04 <argint>
  kexit(n);
    80002bf2:	fec42503          	lw	a0,-20(s0)
    80002bf6:	957ff0ef          	jal	8000254c <kexit>
  return 0;  // not reached
}
    80002bfa:	4501                	li	a0,0
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	6105                	addi	sp,sp,32
    80002c02:	8082                	ret

0000000080002c04 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c04:	1141                	addi	sp,sp,-16
    80002c06:	e406                	sd	ra,8(sp)
    80002c08:	e022                	sd	s0,0(sp)
    80002c0a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c0c:	d2bfe0ef          	jal	80001936 <myproc>
}
    80002c10:	5908                	lw	a0,48(a0)
    80002c12:	60a2                	ld	ra,8(sp)
    80002c14:	6402                	ld	s0,0(sp)
    80002c16:	0141                	addi	sp,sp,16
    80002c18:	8082                	ret

0000000080002c1a <sys_fork>:

uint64
sys_fork(void)
{
    80002c1a:	1141                	addi	sp,sp,-16
    80002c1c:	e406                	sd	ra,8(sp)
    80002c1e:	e022                	sd	s0,0(sp)
    80002c20:	0800                	addi	s0,sp,16
  return kfork();
    80002c22:	da6ff0ef          	jal	800021c8 <kfork>
}
    80002c26:	60a2                	ld	ra,8(sp)
    80002c28:	6402                	ld	s0,0(sp)
    80002c2a:	0141                	addi	sp,sp,16
    80002c2c:	8082                	ret

0000000080002c2e <sys_wait>:

uint64
sys_wait(void)
{
    80002c2e:	1101                	addi	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c36:	fe840593          	addi	a1,s0,-24
    80002c3a:	4501                	li	a0,0
    80002c3c:	ee5ff0ef          	jal	80002b20 <argaddr>
  return kwait(p);
    80002c40:	fe843503          	ld	a0,-24(s0)
    80002c44:	99cff0ef          	jal	80001de0 <kwait>
}
    80002c48:	60e2                	ld	ra,24(sp)
    80002c4a:	6442                	ld	s0,16(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c50:	7179                	addi	sp,sp,-48
    80002c52:	f406                	sd	ra,40(sp)
    80002c54:	f022                	sd	s0,32(sp)
    80002c56:	ec26                	sd	s1,24(sp)
    80002c58:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c5a:	fd840593          	addi	a1,s0,-40
    80002c5e:	4501                	li	a0,0
    80002c60:	ea5ff0ef          	jal	80002b04 <argint>
  argint(1, &t);
    80002c64:	fdc40593          	addi	a1,s0,-36
    80002c68:	4505                	li	a0,1
    80002c6a:	e9bff0ef          	jal	80002b04 <argint>
  addr = myproc()->sz;
    80002c6e:	cc9fe0ef          	jal	80001936 <myproc>
    80002c72:	7524                	ld	s1,104(a0)

  if(t == SBRK_EAGER || n < 0) { // eagerly allocate memory
    80002c74:	fdc42703          	lw	a4,-36(s0)
    80002c78:	4785                	li	a5,1
    80002c7a:	02f70763          	beq	a4,a5,80002ca8 <sys_sbrk+0x58>
    80002c7e:	fd842783          	lw	a5,-40(s0)
    80002c82:	0207c363          	bltz	a5,80002ca8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002c86:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002c88:	02000737          	lui	a4,0x2000
    80002c8c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c8e:	0736                	slli	a4,a4,0xd
    80002c90:	02f76a63          	bltu	a4,a5,80002cc4 <sys_sbrk+0x74>
    80002c94:	0297e863          	bltu	a5,s1,80002cc4 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002c98:	c9ffe0ef          	jal	80001936 <myproc>
    80002c9c:	fd842703          	lw	a4,-40(s0)
    80002ca0:	753c                	ld	a5,104(a0)
    80002ca2:	97ba                	add	a5,a5,a4
    80002ca4:	f53c                	sd	a5,104(a0)
    80002ca6:	a039                	j	80002cb4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ca8:	fd842503          	lw	a0,-40(s0)
    80002cac:	f7dfe0ef          	jal	80001c28 <growproc>
    80002cb0:	00054863          	bltz	a0,80002cc0 <sys_sbrk+0x70>
  }
  return addr;
}
    80002cb4:	8526                	mv	a0,s1
    80002cb6:	70a2                	ld	ra,40(sp)
    80002cb8:	7402                	ld	s0,32(sp)
    80002cba:	64e2                	ld	s1,24(sp)
    80002cbc:	6145                	addi	sp,sp,48
    80002cbe:	8082                	ret
      return -1;
    80002cc0:	54fd                	li	s1,-1
    80002cc2:	bfcd                	j	80002cb4 <sys_sbrk+0x64>
      return -1;
    80002cc4:	54fd                	li	s1,-1
    80002cc6:	b7fd                	j	80002cb4 <sys_sbrk+0x64>

0000000080002cc8 <sys_pause>:

uint64
sys_pause(void)
{
    80002cc8:	7139                	addi	sp,sp,-64
    80002cca:	fc06                	sd	ra,56(sp)
    80002ccc:	f822                	sd	s0,48(sp)
    80002cce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cd0:	fcc40593          	addi	a1,s0,-52
    80002cd4:	4501                	li	a0,0
    80002cd6:	e2fff0ef          	jal	80002b04 <argint>
  if(n < 0)
    80002cda:	fcc42783          	lw	a5,-52(s0)
    80002cde:	0607c863          	bltz	a5,80002d4e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ce2:	00014517          	auipc	a0,0x14
    80002ce6:	b8e50513          	addi	a0,a0,-1138 # 80016870 <tickslock>
    80002cea:	f3ffd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002cee:	fcc42783          	lw	a5,-52(s0)
    80002cf2:	c3b9                	beqz	a5,80002d38 <sys_pause+0x70>
    80002cf4:	f426                	sd	s1,40(sp)
    80002cf6:	f04a                	sd	s2,32(sp)
    80002cf8:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002cfa:	00005997          	auipc	s3,0x5
    80002cfe:	c0e9a983          	lw	s3,-1010(s3) # 80007908 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d02:	00014917          	auipc	s2,0x14
    80002d06:	b6e90913          	addi	s2,s2,-1170 # 80016870 <tickslock>
    80002d0a:	00005497          	auipc	s1,0x5
    80002d0e:	bfe48493          	addi	s1,s1,-1026 # 80007908 <ticks>
    if(killed(myproc())){
    80002d12:	c25fe0ef          	jal	80001936 <myproc>
    80002d16:	8a0ff0ef          	jal	80001db6 <killed>
    80002d1a:	ed0d                	bnez	a0,80002d54 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002d1c:	85ca                	mv	a1,s2
    80002d1e:	8526                	mv	a0,s1
    80002d20:	826ff0ef          	jal	80001d46 <sleep>
  while(ticks - ticks0 < n){
    80002d24:	409c                	lw	a5,0(s1)
    80002d26:	413787bb          	subw	a5,a5,s3
    80002d2a:	fcc42703          	lw	a4,-52(s0)
    80002d2e:	fee7e2e3          	bltu	a5,a4,80002d12 <sys_pause+0x4a>
    80002d32:	74a2                	ld	s1,40(sp)
    80002d34:	7902                	ld	s2,32(sp)
    80002d36:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d38:	00014517          	auipc	a0,0x14
    80002d3c:	b3850513          	addi	a0,a0,-1224 # 80016870 <tickslock>
    80002d40:	f7dfd0ef          	jal	80000cbc <release>
  return 0;
    80002d44:	4501                	li	a0,0
}
    80002d46:	70e2                	ld	ra,56(sp)
    80002d48:	7442                	ld	s0,48(sp)
    80002d4a:	6121                	addi	sp,sp,64
    80002d4c:	8082                	ret
    n = 0;
    80002d4e:	fc042623          	sw	zero,-52(s0)
    80002d52:	bf41                	j	80002ce2 <sys_pause+0x1a>
      release(&tickslock);
    80002d54:	00014517          	auipc	a0,0x14
    80002d58:	b1c50513          	addi	a0,a0,-1252 # 80016870 <tickslock>
    80002d5c:	f61fd0ef          	jal	80000cbc <release>
      return -1;
    80002d60:	557d                	li	a0,-1
    80002d62:	74a2                	ld	s1,40(sp)
    80002d64:	7902                	ld	s2,32(sp)
    80002d66:	69e2                	ld	s3,24(sp)
    80002d68:	bff9                	j	80002d46 <sys_pause+0x7e>

0000000080002d6a <sys_kill>:

// kills the current process
uint64
sys_kill(void)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d72:	fec40593          	addi	a1,s0,-20
    80002d76:	4501                	li	a0,0
    80002d78:	d8dff0ef          	jal	80002b04 <argint>
  return kkill(pid);
    80002d7c:	fec42503          	lw	a0,-20(s0)
    80002d80:	873ff0ef          	jal	800025f2 <kkill>
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d96:	00014517          	auipc	a0,0x14
    80002d9a:	ada50513          	addi	a0,a0,-1318 # 80016870 <tickslock>
    80002d9e:	e8bfd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002da2:	00005797          	auipc	a5,0x5
    80002da6:	b667a783          	lw	a5,-1178(a5) # 80007908 <ticks>
    80002daa:	84be                	mv	s1,a5
  release(&tickslock);
    80002dac:	00014517          	auipc	a0,0x14
    80002db0:	ac450513          	addi	a0,a0,-1340 # 80016870 <tickslock>
    80002db4:	f09fd0ef          	jal	80000cbc <release>
  return xticks;
}
    80002db8:	02049513          	slli	a0,s1,0x20
    80002dbc:	9101                	srli	a0,a0,0x20
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6105                	addi	sp,sp,32
    80002dc6:	8082                	ret

0000000080002dc8 <sys_hello>:


// a
uint64
sys_hello(void)
{
    80002dc8:	1141                	addi	sp,sp,-16
    80002dca:	e406                	sd	ra,8(sp)
    80002dcc:	e022                	sd	s0,0(sp)
    80002dce:	0800                	addi	s0,sp,16
  printf("Hello from the kernel!\n");
    80002dd0:	00004517          	auipc	a0,0x4
    80002dd4:	61850513          	addi	a0,a0,1560 # 800073e8 <etext+0x3e8>
    80002dd8:	f22fd0ef          	jal	800004fa <printf>
  return 0;
}
    80002ddc:	4501                	li	a0,0
    80002dde:	60a2                	ld	ra,8(sp)
    80002de0:	6402                	ld	s0,0(sp)
    80002de2:	0141                	addi	sp,sp,16
    80002de4:	8082                	ret

0000000080002de6 <sys_getpid2>:

uint64
sys_getpid2(void)
{
    80002de6:	1141                	addi	sp,sp,-16
    80002de8:	e406                	sd	ra,8(sp)
    80002dea:	e022                	sd	s0,0(sp)
    80002dec:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dee:	b49fe0ef          	jal	80001936 <myproc>
}
    80002df2:	5908                	lw	a0,48(a0)
    80002df4:	60a2                	ld	ra,8(sp)
    80002df6:	6402                	ld	s0,0(sp)
    80002df8:	0141                	addi	sp,sp,16
    80002dfa:	8082                	ret

0000000080002dfc <sys_getppid>:
extern struct spinlock wait_lock;
extern struct proc proc[NPROC];

uint64
sys_getppid(void)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80002e06:	b31fe0ef          	jal	80001936 <myproc>
    80002e0a:	84aa                	mv	s1,a0
  int ppid;

  acquire(&wait_lock);
    80002e0c:	0000d517          	auipc	a0,0xd
    80002e10:	c1450513          	addi	a0,a0,-1004 # 8000fa20 <wait_lock>
    80002e14:	e15fd0ef          	jal	80000c28 <acquire>
  if(p->parent){
    80002e18:	6cbc                	ld	a5,88(s1)
    ppid = p->parent->pid;
  }
  else{
    ppid = -1;
    80002e1a:	54fd                	li	s1,-1
  if(p->parent){
    80002e1c:	c391                	beqz	a5,80002e20 <sys_getppid+0x24>
    ppid = p->parent->pid;
    80002e1e:	5b84                	lw	s1,48(a5)
  }
  release(&wait_lock);
    80002e20:	0000d517          	auipc	a0,0xd
    80002e24:	c0050513          	addi	a0,a0,-1024 # 8000fa20 <wait_lock>
    80002e28:	e95fd0ef          	jal	80000cbc <release>

  return ppid;
}
    80002e2c:	8526                	mv	a0,s1
    80002e2e:	60e2                	ld	ra,24(sp)
    80002e30:	6442                	ld	s0,16(sp)
    80002e32:	64a2                	ld	s1,8(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret

0000000080002e38 <sys_getnumchild>:

uint64
sys_getnumchild(void)
{
    80002e38:	1101                	addi	sp,sp,-32
    80002e3a:	ec06                	sd	ra,24(sp)
    80002e3c:	e822                	sd	s0,16(sp)
    80002e3e:	e426                	sd	s1,8(sp)
    80002e40:	e04a                	sd	s2,0(sp)
    80002e42:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80002e44:	af3fe0ef          	jal	80001936 <myproc>
    80002e48:	84aa                	mv	s1,a0
  int count = 0;
  struct proc* it;

  // in parent-child iteration, always lock before starting the loop. 
  // This things mitigates the possibility of parent/child state changing while current function is running
  acquire(&wait_lock); 
    80002e4a:	0000d517          	auipc	a0,0xd
    80002e4e:	bd650513          	addi	a0,a0,-1066 # 8000fa20 <wait_lock>
    80002e52:	dd7fd0ef          	jal	80000c28 <acquire>

  for(it = proc; it < &proc[NPROC]; it++){
    80002e56:	0000e797          	auipc	a5,0xe
    80002e5a:	81a78793          	addi	a5,a5,-2022 # 80010670 <proc>
  int count = 0;
    80002e5e:	4901                	li	s2,0
    if(it->parent == p && it->state != ZOMBIE){
    80002e60:	4615                	li	a2,5
  for(it = proc; it < &proc[NPROC]; it++){
    80002e62:	00014697          	auipc	a3,0x14
    80002e66:	a0e68693          	addi	a3,a3,-1522 # 80016870 <tickslock>
    80002e6a:	a031                	j	80002e76 <sys_getnumchild+0x3e>
      count++;
    80002e6c:	2905                	addiw	s2,s2,1
  for(it = proc; it < &proc[NPROC]; it++){
    80002e6e:	18878793          	addi	a5,a5,392
    80002e72:	00d78963          	beq	a5,a3,80002e84 <sys_getnumchild+0x4c>
    if(it->parent == p && it->state != ZOMBIE){
    80002e76:	6fb8                	ld	a4,88(a5)
    80002e78:	fe971be3          	bne	a4,s1,80002e6e <sys_getnumchild+0x36>
    80002e7c:	4f98                	lw	a4,24(a5)
    80002e7e:	fec717e3          	bne	a4,a2,80002e6c <sys_getnumchild+0x34>
    80002e82:	b7f5                	j	80002e6e <sys_getnumchild+0x36>
    }
  }

  release(&wait_lock);
    80002e84:	0000d517          	auipc	a0,0xd
    80002e88:	b9c50513          	addi	a0,a0,-1124 # 8000fa20 <wait_lock>
    80002e8c:	e31fd0ef          	jal	80000cbc <release>

  return count;
}
    80002e90:	854a                	mv	a0,s2
    80002e92:	60e2                	ld	ra,24(sp)
    80002e94:	6442                	ld	s0,16(sp)
    80002e96:	64a2                	ld	s1,8(sp)
    80002e98:	6902                	ld	s2,0(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret

0000000080002e9e <sys_getsyscount>:

uint64
sys_getsyscount(void)
{
    80002e9e:	1141                	addi	sp,sp,-16
    80002ea0:	e406                	sd	ra,8(sp)
    80002ea2:	e022                	sd	s0,0(sp)
    80002ea4:	0800                	addi	s0,sp,16
  struct proc* p = myproc();
    80002ea6:	a91fe0ef          	jal	80001936 <myproc>
    80002eaa:	87aa                	mv	a5,a0

  // since the syscount value is not changed or read 
  // by anyother process other that the one which it belongs to, 
  // hence we dont need to employ locks here
  if(p) syscount = p->syscount;
  else syscount = -1;
    80002eac:	557d                	li	a0,-1
  if(p) syscount = p->syscount;
    80002eae:	c391                	beqz	a5,80002eb2 <sys_getsyscount+0x14>
    80002eb0:	5bc8                	lw	a0,52(a5)

  return syscount;
}
    80002eb2:	60a2                	ld	ra,8(sp)
    80002eb4:	6402                	ld	s0,0(sp)
    80002eb6:	0141                	addi	sp,sp,16
    80002eb8:	8082                	ret

0000000080002eba <sys_getchildsyscount>:

uint64
sys_getchildsyscount(void)
{
    80002eba:	7179                	addi	sp,sp,-48
    80002ebc:	f406                	sd	ra,40(sp)
    80002ebe:	f022                	sd	s0,32(sp)
    80002ec0:	ec26                	sd	s1,24(sp)
    80002ec2:	e84a                	sd	s2,16(sp)
    80002ec4:	1800                	addi	s0,sp,48
  int pid;
  argint(0, &pid);
    80002ec6:	fdc40593          	addi	a1,s0,-36
    80002eca:	4501                	li	a0,0
    80002ecc:	c39ff0ef          	jal	80002b04 <argint>

  struct proc* p = myproc();
    80002ed0:	a67fe0ef          	jal	80001936 <myproc>
    80002ed4:	892a                	mv	s2,a0
  struct proc* it;
  int syscount = -1;

  acquire(&wait_lock);
    80002ed6:	0000d517          	auipc	a0,0xd
    80002eda:	b4a50513          	addi	a0,a0,-1206 # 8000fa20 <wait_lock>
    80002ede:	d4bfd0ef          	jal	80000c28 <acquire>
  for(it=proc; it<&proc[NPROC]; it++){
    if(it->parent == p && it->pid == pid){ // we are considering zombie children also
    80002ee2:	fdc42683          	lw	a3,-36(s0)
  for(it=proc; it<&proc[NPROC]; it++){
    80002ee6:	0000d497          	auipc	s1,0xd
    80002eea:	78a48493          	addi	s1,s1,1930 # 80010670 <proc>
    80002eee:	00014717          	auipc	a4,0x14
    80002ef2:	98270713          	addi	a4,a4,-1662 # 80016870 <tickslock>
    80002ef6:	a029                	j	80002f00 <sys_getchildsyscount+0x46>
    80002ef8:	18848493          	addi	s1,s1,392
    80002efc:	02e48d63          	beq	s1,a4,80002f36 <sys_getchildsyscount+0x7c>
    if(it->parent == p && it->pid == pid){ // we are considering zombie children also
    80002f00:	6cbc                	ld	a5,88(s1)
    80002f02:	ff279be3          	bne	a5,s2,80002ef8 <sys_getchildsyscount+0x3e>
    80002f06:	589c                	lw	a5,48(s1)
    80002f08:	fed798e3          	bne	a5,a3,80002ef8 <sys_getchildsyscount+0x3e>
      
      acquire(&it->lock);
    80002f0c:	8526                	mv	a0,s1
    80002f0e:	d1bfd0ef          	jal	80000c28 <acquire>
      syscount = it->syscount;
    80002f12:	0344a903          	lw	s2,52(s1)
      release(&it->lock);
    80002f16:	8526                	mv	a0,s1
    80002f18:	da5fd0ef          	jal	80000cbc <release>
      break;
    }
  }
  release(&wait_lock);
    80002f1c:	0000d517          	auipc	a0,0xd
    80002f20:	b0450513          	addi	a0,a0,-1276 # 8000fa20 <wait_lock>
    80002f24:	d99fd0ef          	jal	80000cbc <release>

  return syscount;
}
    80002f28:	854a                	mv	a0,s2
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	64e2                	ld	s1,24(sp)
    80002f30:	6942                	ld	s2,16(sp)
    80002f32:	6145                	addi	sp,sp,48
    80002f34:	8082                	ret
  int syscount = -1;
    80002f36:	597d                	li	s2,-1
    80002f38:	b7d5                	j	80002f1c <sys_getchildsyscount+0x62>

0000000080002f3a <sys_getlevel>:

uint64
sys_getlevel(void)
{
    80002f3a:	1141                	addi	sp,sp,-16
    80002f3c:	e406                	sd	ra,8(sp)
    80002f3e:	e022                	sd	s0,0(sp)
    80002f40:	0800                	addi	s0,sp,16
  struct proc * p = myproc();
    80002f42:	9f5fe0ef          	jal	80001936 <myproc>
  return p->level;
}
    80002f46:	03856503          	lwu	a0,56(a0)
    80002f4a:	60a2                	ld	ra,8(sp)
    80002f4c:	6402                	ld	s0,0(sp)
    80002f4e:	0141                	addi	sp,sp,16
    80002f50:	8082                	ret

0000000080002f52 <sys_getmlfqinfo>:

uint64
sys_getmlfqinfo(void)
{
    80002f52:	715d                	addi	sp,sp,-80
    80002f54:	e486                	sd	ra,72(sp)
    80002f56:	e0a2                	sd	s0,64(sp)
    80002f58:	fc26                	sd	s1,56(sp)
    80002f5a:	f84a                	sd	s2,48(sp)
    80002f5c:	0880                	addi	s0,sp,80
  int pid;
  uint64 mlfq_ptr;
  argint(0, &pid);
    80002f5e:	fdc40593          	addi	a1,s0,-36
    80002f62:	4501                	li	a0,0
    80002f64:	ba1ff0ef          	jal	80002b04 <argint>
  argaddr(1, &mlfq_ptr);
    80002f68:	fd040593          	addi	a1,s0,-48
    80002f6c:	4505                	li	a0,1
    80002f6e:	bb3ff0ef          	jal	80002b20 <argaddr>

  struct proc* it;
  for(it = proc; it<&proc[NPROC]; it++){
    80002f72:	0000d497          	auipc	s1,0xd
    80002f76:	6fe48493          	addi	s1,s1,1790 # 80010670 <proc>
    80002f7a:	00014917          	auipc	s2,0x14
    80002f7e:	8f690913          	addi	s2,s2,-1802 # 80016870 <tickslock>
    80002f82:	a801                	j	80002f92 <sys_getmlfqinfo+0x40>
      info.times_scheduled = it->times_scheduled;

      release(&it->lock);
      return copyout(myproc()->pagetable ,mlfq_ptr, (char*)&info, sizeof(struct mlfqinfo));
    }
    release(&it->lock);
    80002f84:	8526                	mv	a0,s1
    80002f86:	d37fd0ef          	jal	80000cbc <release>
  for(it = proc; it<&proc[NPROC]; it++){
    80002f8a:	18848493          	addi	s1,s1,392
    80002f8e:	07248463          	beq	s1,s2,80002ff6 <sys_getmlfqinfo+0xa4>
    acquire(&it->lock);
    80002f92:	8526                	mv	a0,s1
    80002f94:	c95fd0ef          	jal	80000c28 <acquire>
    if(it->pid == pid  && it->state != UNUSED){
    80002f98:	5898                	lw	a4,48(s1)
    80002f9a:	fdc42783          	lw	a5,-36(s0)
    80002f9e:	fef713e3          	bne	a4,a5,80002f84 <sys_getmlfqinfo+0x32>
    80002fa2:	4c9c                	lw	a5,24(s1)
    80002fa4:	d3e5                	beqz	a5,80002f84 <sys_getmlfqinfo+0x32>
      info.level = it->level;
    80002fa6:	5c9c                	lw	a5,56(s1)
    80002fa8:	faf42823          	sw	a5,-80(s0)
      info.total_syscalls = it->syscount;
    80002fac:	58dc                	lw	a5,52(s1)
    80002fae:	fcf42423          	sw	a5,-56(s0)
      for(int i=0;i<NLEVEL;i++) info.ticks[i] = it->ticks[i];
    80002fb2:	40fc                	lw	a5,68(s1)
    80002fb4:	faf42a23          	sw	a5,-76(s0)
    80002fb8:	44bc                	lw	a5,72(s1)
    80002fba:	faf42c23          	sw	a5,-72(s0)
    80002fbe:	44fc                	lw	a5,76(s1)
    80002fc0:	faf42e23          	sw	a5,-68(s0)
    80002fc4:	48bc                	lw	a5,80(s1)
    80002fc6:	fcf42023          	sw	a5,-64(s0)
      info.times_scheduled = it->times_scheduled;
    80002fca:	48fc                	lw	a5,84(s1)
    80002fcc:	fcf42223          	sw	a5,-60(s0)
      release(&it->lock);
    80002fd0:	8526                	mv	a0,s1
    80002fd2:	cebfd0ef          	jal	80000cbc <release>
      return copyout(myproc()->pagetable ,mlfq_ptr, (char*)&info, sizeof(struct mlfqinfo));
    80002fd6:	961fe0ef          	jal	80001936 <myproc>
    80002fda:	46f1                	li	a3,28
    80002fdc:	fb040613          	addi	a2,s0,-80
    80002fe0:	fd043583          	ld	a1,-48(s0)
    80002fe4:	7928                	ld	a0,112(a0)
    80002fe6:	e6efe0ef          	jal	80001654 <copyout>
  }

  return -1; // process with given pid not found
    80002fea:	60a6                	ld	ra,72(sp)
    80002fec:	6406                	ld	s0,64(sp)
    80002fee:	74e2                	ld	s1,56(sp)
    80002ff0:	7942                	ld	s2,48(sp)
    80002ff2:	6161                	addi	sp,sp,80
    80002ff4:	8082                	ret
  return -1; // process with given pid not found
    80002ff6:	557d                	li	a0,-1
    80002ff8:	bfcd                	j	80002fea <sys_getmlfqinfo+0x98>

0000000080002ffa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ffa:	7179                	addi	sp,sp,-48
    80002ffc:	f406                	sd	ra,40(sp)
    80002ffe:	f022                	sd	s0,32(sp)
    80003000:	ec26                	sd	s1,24(sp)
    80003002:	e84a                	sd	s2,16(sp)
    80003004:	e44e                	sd	s3,8(sp)
    80003006:	e052                	sd	s4,0(sp)
    80003008:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000300a:	00004597          	auipc	a1,0x4
    8000300e:	3f658593          	addi	a1,a1,1014 # 80007400 <etext+0x400>
    80003012:	00014517          	auipc	a0,0x14
    80003016:	87650513          	addi	a0,a0,-1930 # 80016888 <bcache>
    8000301a:	b85fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000301e:	0001c797          	auipc	a5,0x1c
    80003022:	86a78793          	addi	a5,a5,-1942 # 8001e888 <bcache+0x8000>
    80003026:	0001c717          	auipc	a4,0x1c
    8000302a:	aca70713          	addi	a4,a4,-1334 # 8001eaf0 <bcache+0x8268>
    8000302e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003032:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003036:	00014497          	auipc	s1,0x14
    8000303a:	86a48493          	addi	s1,s1,-1942 # 800168a0 <bcache+0x18>
    b->next = bcache.head.next;
    8000303e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003040:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003042:	00004a17          	auipc	s4,0x4
    80003046:	3c6a0a13          	addi	s4,s4,966 # 80007408 <etext+0x408>
    b->next = bcache.head.next;
    8000304a:	2b893783          	ld	a5,696(s2)
    8000304e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003050:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003054:	85d2                	mv	a1,s4
    80003056:	01048513          	addi	a0,s1,16
    8000305a:	328010ef          	jal	80004382 <initsleeplock>
    bcache.head.next->prev = b;
    8000305e:	2b893783          	ld	a5,696(s2)
    80003062:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003064:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003068:	45848493          	addi	s1,s1,1112
    8000306c:	fd349fe3          	bne	s1,s3,8000304a <binit+0x50>
  }
}
    80003070:	70a2                	ld	ra,40(sp)
    80003072:	7402                	ld	s0,32(sp)
    80003074:	64e2                	ld	s1,24(sp)
    80003076:	6942                	ld	s2,16(sp)
    80003078:	69a2                	ld	s3,8(sp)
    8000307a:	6a02                	ld	s4,0(sp)
    8000307c:	6145                	addi	sp,sp,48
    8000307e:	8082                	ret

0000000080003080 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003080:	7179                	addi	sp,sp,-48
    80003082:	f406                	sd	ra,40(sp)
    80003084:	f022                	sd	s0,32(sp)
    80003086:	ec26                	sd	s1,24(sp)
    80003088:	e84a                	sd	s2,16(sp)
    8000308a:	e44e                	sd	s3,8(sp)
    8000308c:	1800                	addi	s0,sp,48
    8000308e:	892a                	mv	s2,a0
    80003090:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003092:	00013517          	auipc	a0,0x13
    80003096:	7f650513          	addi	a0,a0,2038 # 80016888 <bcache>
    8000309a:	b8ffd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000309e:	0001c497          	auipc	s1,0x1c
    800030a2:	aa24b483          	ld	s1,-1374(s1) # 8001eb40 <bcache+0x82b8>
    800030a6:	0001c797          	auipc	a5,0x1c
    800030aa:	a4a78793          	addi	a5,a5,-1462 # 8001eaf0 <bcache+0x8268>
    800030ae:	02f48b63          	beq	s1,a5,800030e4 <bread+0x64>
    800030b2:	873e                	mv	a4,a5
    800030b4:	a021                	j	800030bc <bread+0x3c>
    800030b6:	68a4                	ld	s1,80(s1)
    800030b8:	02e48663          	beq	s1,a4,800030e4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800030bc:	449c                	lw	a5,8(s1)
    800030be:	ff279ce3          	bne	a5,s2,800030b6 <bread+0x36>
    800030c2:	44dc                	lw	a5,12(s1)
    800030c4:	ff3799e3          	bne	a5,s3,800030b6 <bread+0x36>
      b->refcnt++;
    800030c8:	40bc                	lw	a5,64(s1)
    800030ca:	2785                	addiw	a5,a5,1
    800030cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ce:	00013517          	auipc	a0,0x13
    800030d2:	7ba50513          	addi	a0,a0,1978 # 80016888 <bcache>
    800030d6:	be7fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    800030da:	01048513          	addi	a0,s1,16
    800030de:	2da010ef          	jal	800043b8 <acquiresleep>
      return b;
    800030e2:	a889                	j	80003134 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030e4:	0001c497          	auipc	s1,0x1c
    800030e8:	a544b483          	ld	s1,-1452(s1) # 8001eb38 <bcache+0x82b0>
    800030ec:	0001c797          	auipc	a5,0x1c
    800030f0:	a0478793          	addi	a5,a5,-1532 # 8001eaf0 <bcache+0x8268>
    800030f4:	00f48863          	beq	s1,a5,80003104 <bread+0x84>
    800030f8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030fa:	40bc                	lw	a5,64(s1)
    800030fc:	cb91                	beqz	a5,80003110 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030fe:	64a4                	ld	s1,72(s1)
    80003100:	fee49de3          	bne	s1,a4,800030fa <bread+0x7a>
  panic("bget: no buffers");
    80003104:	00004517          	auipc	a0,0x4
    80003108:	30c50513          	addi	a0,a0,780 # 80007410 <etext+0x410>
    8000310c:	f18fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80003110:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003114:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003118:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000311c:	4785                	li	a5,1
    8000311e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003120:	00013517          	auipc	a0,0x13
    80003124:	76850513          	addi	a0,a0,1896 # 80016888 <bcache>
    80003128:	b95fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    8000312c:	01048513          	addi	a0,s1,16
    80003130:	288010ef          	jal	800043b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003134:	409c                	lw	a5,0(s1)
    80003136:	cb89                	beqz	a5,80003148 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003138:	8526                	mv	a0,s1
    8000313a:	70a2                	ld	ra,40(sp)
    8000313c:	7402                	ld	s0,32(sp)
    8000313e:	64e2                	ld	s1,24(sp)
    80003140:	6942                	ld	s2,16(sp)
    80003142:	69a2                	ld	s3,8(sp)
    80003144:	6145                	addi	sp,sp,48
    80003146:	8082                	ret
    virtio_disk_rw(b, 0);
    80003148:	4581                	li	a1,0
    8000314a:	8526                	mv	a0,s1
    8000314c:	2f5020ef          	jal	80005c40 <virtio_disk_rw>
    b->valid = 1;
    80003150:	4785                	li	a5,1
    80003152:	c09c                	sw	a5,0(s1)
  return b;
    80003154:	b7d5                	j	80003138 <bread+0xb8>

0000000080003156 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003156:	1101                	addi	sp,sp,-32
    80003158:	ec06                	sd	ra,24(sp)
    8000315a:	e822                	sd	s0,16(sp)
    8000315c:	e426                	sd	s1,8(sp)
    8000315e:	1000                	addi	s0,sp,32
    80003160:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003162:	0541                	addi	a0,a0,16
    80003164:	2d2010ef          	jal	80004436 <holdingsleep>
    80003168:	c911                	beqz	a0,8000317c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000316a:	4585                	li	a1,1
    8000316c:	8526                	mv	a0,s1
    8000316e:	2d3020ef          	jal	80005c40 <virtio_disk_rw>
}
    80003172:	60e2                	ld	ra,24(sp)
    80003174:	6442                	ld	s0,16(sp)
    80003176:	64a2                	ld	s1,8(sp)
    80003178:	6105                	addi	sp,sp,32
    8000317a:	8082                	ret
    panic("bwrite");
    8000317c:	00004517          	auipc	a0,0x4
    80003180:	2ac50513          	addi	a0,a0,684 # 80007428 <etext+0x428>
    80003184:	ea0fd0ef          	jal	80000824 <panic>

0000000080003188 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	e04a                	sd	s2,0(sp)
    80003192:	1000                	addi	s0,sp,32
    80003194:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003196:	01050913          	addi	s2,a0,16
    8000319a:	854a                	mv	a0,s2
    8000319c:	29a010ef          	jal	80004436 <holdingsleep>
    800031a0:	c125                	beqz	a0,80003200 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    800031a2:	854a                	mv	a0,s2
    800031a4:	25a010ef          	jal	800043fe <releasesleep>

  acquire(&bcache.lock);
    800031a8:	00013517          	auipc	a0,0x13
    800031ac:	6e050513          	addi	a0,a0,1760 # 80016888 <bcache>
    800031b0:	a79fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	37fd                	addiw	a5,a5,-1
    800031b8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031ba:	e79d                	bnez	a5,800031e8 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031bc:	68b8                	ld	a4,80(s1)
    800031be:	64bc                	ld	a5,72(s1)
    800031c0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031c2:	68b8                	ld	a4,80(s1)
    800031c4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031c6:	0001b797          	auipc	a5,0x1b
    800031ca:	6c278793          	addi	a5,a5,1730 # 8001e888 <bcache+0x8000>
    800031ce:	2b87b703          	ld	a4,696(a5)
    800031d2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031d4:	0001c717          	auipc	a4,0x1c
    800031d8:	91c70713          	addi	a4,a4,-1764 # 8001eaf0 <bcache+0x8268>
    800031dc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031de:	2b87b703          	ld	a4,696(a5)
    800031e2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031e4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031e8:	00013517          	auipc	a0,0x13
    800031ec:	6a050513          	addi	a0,a0,1696 # 80016888 <bcache>
    800031f0:	acdfd0ef          	jal	80000cbc <release>
}
    800031f4:	60e2                	ld	ra,24(sp)
    800031f6:	6442                	ld	s0,16(sp)
    800031f8:	64a2                	ld	s1,8(sp)
    800031fa:	6902                	ld	s2,0(sp)
    800031fc:	6105                	addi	sp,sp,32
    800031fe:	8082                	ret
    panic("brelse");
    80003200:	00004517          	auipc	a0,0x4
    80003204:	23050513          	addi	a0,a0,560 # 80007430 <etext+0x430>
    80003208:	e1cfd0ef          	jal	80000824 <panic>

000000008000320c <bpin>:

void
bpin(struct buf *b) {
    8000320c:	1101                	addi	sp,sp,-32
    8000320e:	ec06                	sd	ra,24(sp)
    80003210:	e822                	sd	s0,16(sp)
    80003212:	e426                	sd	s1,8(sp)
    80003214:	1000                	addi	s0,sp,32
    80003216:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003218:	00013517          	auipc	a0,0x13
    8000321c:	67050513          	addi	a0,a0,1648 # 80016888 <bcache>
    80003220:	a09fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003224:	40bc                	lw	a5,64(s1)
    80003226:	2785                	addiw	a5,a5,1
    80003228:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000322a:	00013517          	auipc	a0,0x13
    8000322e:	65e50513          	addi	a0,a0,1630 # 80016888 <bcache>
    80003232:	a8bfd0ef          	jal	80000cbc <release>
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <bunpin>:

void
bunpin(struct buf *b) {
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	e426                	sd	s1,8(sp)
    80003248:	1000                	addi	s0,sp,32
    8000324a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000324c:	00013517          	auipc	a0,0x13
    80003250:	63c50513          	addi	a0,a0,1596 # 80016888 <bcache>
    80003254:	9d5fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003258:	40bc                	lw	a5,64(s1)
    8000325a:	37fd                	addiw	a5,a5,-1
    8000325c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000325e:	00013517          	auipc	a0,0x13
    80003262:	62a50513          	addi	a0,a0,1578 # 80016888 <bcache>
    80003266:	a57fd0ef          	jal	80000cbc <release>
}
    8000326a:	60e2                	ld	ra,24(sp)
    8000326c:	6442                	ld	s0,16(sp)
    8000326e:	64a2                	ld	s1,8(sp)
    80003270:	6105                	addi	sp,sp,32
    80003272:	8082                	ret

0000000080003274 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003274:	1101                	addi	sp,sp,-32
    80003276:	ec06                	sd	ra,24(sp)
    80003278:	e822                	sd	s0,16(sp)
    8000327a:	e426                	sd	s1,8(sp)
    8000327c:	e04a                	sd	s2,0(sp)
    8000327e:	1000                	addi	s0,sp,32
    80003280:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003282:	00d5d79b          	srliw	a5,a1,0xd
    80003286:	0001c597          	auipc	a1,0x1c
    8000328a:	cde5a583          	lw	a1,-802(a1) # 8001ef64 <sb+0x1c>
    8000328e:	9dbd                	addw	a1,a1,a5
    80003290:	df1ff0ef          	jal	80003080 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003294:	0074f713          	andi	a4,s1,7
    80003298:	4785                	li	a5,1
    8000329a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000329e:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800032a0:	90d9                	srli	s1,s1,0x36
    800032a2:	00950733          	add	a4,a0,s1
    800032a6:	05874703          	lbu	a4,88(a4)
    800032aa:	00e7f6b3          	and	a3,a5,a4
    800032ae:	c29d                	beqz	a3,800032d4 <bfree+0x60>
    800032b0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032b2:	94aa                	add	s1,s1,a0
    800032b4:	fff7c793          	not	a5,a5
    800032b8:	8f7d                	and	a4,a4,a5
    800032ba:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800032be:	000010ef          	jal	800042be <log_write>
  brelse(bp);
    800032c2:	854a                	mv	a0,s2
    800032c4:	ec5ff0ef          	jal	80003188 <brelse>
}
    800032c8:	60e2                	ld	ra,24(sp)
    800032ca:	6442                	ld	s0,16(sp)
    800032cc:	64a2                	ld	s1,8(sp)
    800032ce:	6902                	ld	s2,0(sp)
    800032d0:	6105                	addi	sp,sp,32
    800032d2:	8082                	ret
    panic("freeing free block");
    800032d4:	00004517          	auipc	a0,0x4
    800032d8:	16450513          	addi	a0,a0,356 # 80007438 <etext+0x438>
    800032dc:	d48fd0ef          	jal	80000824 <panic>

00000000800032e0 <balloc>:
{
    800032e0:	715d                	addi	sp,sp,-80
    800032e2:	e486                	sd	ra,72(sp)
    800032e4:	e0a2                	sd	s0,64(sp)
    800032e6:	fc26                	sd	s1,56(sp)
    800032e8:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800032ea:	0001c797          	auipc	a5,0x1c
    800032ee:	c627a783          	lw	a5,-926(a5) # 8001ef4c <sb+0x4>
    800032f2:	0e078263          	beqz	a5,800033d6 <balloc+0xf6>
    800032f6:	f84a                	sd	s2,48(sp)
    800032f8:	f44e                	sd	s3,40(sp)
    800032fa:	f052                	sd	s4,32(sp)
    800032fc:	ec56                	sd	s5,24(sp)
    800032fe:	e85a                	sd	s6,16(sp)
    80003300:	e45e                	sd	s7,8(sp)
    80003302:	e062                	sd	s8,0(sp)
    80003304:	8baa                	mv	s7,a0
    80003306:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003308:	0001cb17          	auipc	s6,0x1c
    8000330c:	c40b0b13          	addi	s6,s6,-960 # 8001ef48 <sb>
      m = 1 << (bi % 8);
    80003310:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003312:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003314:	6c09                	lui	s8,0x2
    80003316:	a09d                	j	8000337c <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003318:	97ca                	add	a5,a5,s2
    8000331a:	8e55                	or	a2,a2,a3
    8000331c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003320:	854a                	mv	a0,s2
    80003322:	79d000ef          	jal	800042be <log_write>
        brelse(bp);
    80003326:	854a                	mv	a0,s2
    80003328:	e61ff0ef          	jal	80003188 <brelse>
  bp = bread(dev, bno);
    8000332c:	85a6                	mv	a1,s1
    8000332e:	855e                	mv	a0,s7
    80003330:	d51ff0ef          	jal	80003080 <bread>
    80003334:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003336:	40000613          	li	a2,1024
    8000333a:	4581                	li	a1,0
    8000333c:	05850513          	addi	a0,a0,88
    80003340:	9b9fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80003344:	854a                	mv	a0,s2
    80003346:	779000ef          	jal	800042be <log_write>
  brelse(bp);
    8000334a:	854a                	mv	a0,s2
    8000334c:	e3dff0ef          	jal	80003188 <brelse>
}
    80003350:	7942                	ld	s2,48(sp)
    80003352:	79a2                	ld	s3,40(sp)
    80003354:	7a02                	ld	s4,32(sp)
    80003356:	6ae2                	ld	s5,24(sp)
    80003358:	6b42                	ld	s6,16(sp)
    8000335a:	6ba2                	ld	s7,8(sp)
    8000335c:	6c02                	ld	s8,0(sp)
}
    8000335e:	8526                	mv	a0,s1
    80003360:	60a6                	ld	ra,72(sp)
    80003362:	6406                	ld	s0,64(sp)
    80003364:	74e2                	ld	s1,56(sp)
    80003366:	6161                	addi	sp,sp,80
    80003368:	8082                	ret
    brelse(bp);
    8000336a:	854a                	mv	a0,s2
    8000336c:	e1dff0ef          	jal	80003188 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003370:	015c0abb          	addw	s5,s8,s5
    80003374:	004b2783          	lw	a5,4(s6)
    80003378:	04faf863          	bgeu	s5,a5,800033c8 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000337c:	40dad59b          	sraiw	a1,s5,0xd
    80003380:	01cb2783          	lw	a5,28(s6)
    80003384:	9dbd                	addw	a1,a1,a5
    80003386:	855e                	mv	a0,s7
    80003388:	cf9ff0ef          	jal	80003080 <bread>
    8000338c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000338e:	004b2503          	lw	a0,4(s6)
    80003392:	84d6                	mv	s1,s5
    80003394:	4701                	li	a4,0
    80003396:	fca4fae3          	bgeu	s1,a0,8000336a <balloc+0x8a>
      m = 1 << (bi % 8);
    8000339a:	00777693          	andi	a3,a4,7
    8000339e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033a2:	41f7579b          	sraiw	a5,a4,0x1f
    800033a6:	01d7d79b          	srliw	a5,a5,0x1d
    800033aa:	9fb9                	addw	a5,a5,a4
    800033ac:	4037d79b          	sraiw	a5,a5,0x3
    800033b0:	00f90633          	add	a2,s2,a5
    800033b4:	05864603          	lbu	a2,88(a2)
    800033b8:	00c6f5b3          	and	a1,a3,a2
    800033bc:	ddb1                	beqz	a1,80003318 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033be:	2705                	addiw	a4,a4,1
    800033c0:	2485                	addiw	s1,s1,1
    800033c2:	fd471ae3          	bne	a4,s4,80003396 <balloc+0xb6>
    800033c6:	b755                	j	8000336a <balloc+0x8a>
    800033c8:	7942                	ld	s2,48(sp)
    800033ca:	79a2                	ld	s3,40(sp)
    800033cc:	7a02                	ld	s4,32(sp)
    800033ce:	6ae2                	ld	s5,24(sp)
    800033d0:	6b42                	ld	s6,16(sp)
    800033d2:	6ba2                	ld	s7,8(sp)
    800033d4:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800033d6:	00004517          	auipc	a0,0x4
    800033da:	07a50513          	addi	a0,a0,122 # 80007450 <etext+0x450>
    800033de:	91cfd0ef          	jal	800004fa <printf>
  return 0;
    800033e2:	4481                	li	s1,0
    800033e4:	bfad                	j	8000335e <balloc+0x7e>

00000000800033e6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800033e6:	7179                	addi	sp,sp,-48
    800033e8:	f406                	sd	ra,40(sp)
    800033ea:	f022                	sd	s0,32(sp)
    800033ec:	ec26                	sd	s1,24(sp)
    800033ee:	e84a                	sd	s2,16(sp)
    800033f0:	e44e                	sd	s3,8(sp)
    800033f2:	1800                	addi	s0,sp,48
    800033f4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033f6:	47ad                	li	a5,11
    800033f8:	02b7e363          	bltu	a5,a1,8000341e <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800033fc:	02059793          	slli	a5,a1,0x20
    80003400:	01e7d593          	srli	a1,a5,0x1e
    80003404:	00b509b3          	add	s3,a0,a1
    80003408:	0509a483          	lw	s1,80(s3)
    8000340c:	e0b5                	bnez	s1,80003470 <bmap+0x8a>
      addr = balloc(ip->dev);
    8000340e:	4108                	lw	a0,0(a0)
    80003410:	ed1ff0ef          	jal	800032e0 <balloc>
    80003414:	84aa                	mv	s1,a0
      if(addr == 0)
    80003416:	cd29                	beqz	a0,80003470 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003418:	04a9a823          	sw	a0,80(s3)
    8000341c:	a891                	j	80003470 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000341e:	ff45879b          	addiw	a5,a1,-12
    80003422:	873e                	mv	a4,a5
    80003424:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003426:	0ff00793          	li	a5,255
    8000342a:	06e7e763          	bltu	a5,a4,80003498 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000342e:	08052483          	lw	s1,128(a0)
    80003432:	e891                	bnez	s1,80003446 <bmap+0x60>
      addr = balloc(ip->dev);
    80003434:	4108                	lw	a0,0(a0)
    80003436:	eabff0ef          	jal	800032e0 <balloc>
    8000343a:	84aa                	mv	s1,a0
      if(addr == 0)
    8000343c:	c915                	beqz	a0,80003470 <bmap+0x8a>
    8000343e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003440:	08a92023          	sw	a0,128(s2)
    80003444:	a011                	j	80003448 <bmap+0x62>
    80003446:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003448:	85a6                	mv	a1,s1
    8000344a:	00092503          	lw	a0,0(s2)
    8000344e:	c33ff0ef          	jal	80003080 <bread>
    80003452:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003454:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003458:	02099713          	slli	a4,s3,0x20
    8000345c:	01e75593          	srli	a1,a4,0x1e
    80003460:	97ae                	add	a5,a5,a1
    80003462:	89be                	mv	s3,a5
    80003464:	4384                	lw	s1,0(a5)
    80003466:	cc89                	beqz	s1,80003480 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003468:	8552                	mv	a0,s4
    8000346a:	d1fff0ef          	jal	80003188 <brelse>
    return addr;
    8000346e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003470:	8526                	mv	a0,s1
    80003472:	70a2                	ld	ra,40(sp)
    80003474:	7402                	ld	s0,32(sp)
    80003476:	64e2                	ld	s1,24(sp)
    80003478:	6942                	ld	s2,16(sp)
    8000347a:	69a2                	ld	s3,8(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
      addr = balloc(ip->dev);
    80003480:	00092503          	lw	a0,0(s2)
    80003484:	e5dff0ef          	jal	800032e0 <balloc>
    80003488:	84aa                	mv	s1,a0
      if(addr){
    8000348a:	dd79                	beqz	a0,80003468 <bmap+0x82>
        a[bn] = addr;
    8000348c:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003490:	8552                	mv	a0,s4
    80003492:	62d000ef          	jal	800042be <log_write>
    80003496:	bfc9                	j	80003468 <bmap+0x82>
    80003498:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000349a:	00004517          	auipc	a0,0x4
    8000349e:	fce50513          	addi	a0,a0,-50 # 80007468 <etext+0x468>
    800034a2:	b82fd0ef          	jal	80000824 <panic>

00000000800034a6 <iget>:
{
    800034a6:	7179                	addi	sp,sp,-48
    800034a8:	f406                	sd	ra,40(sp)
    800034aa:	f022                	sd	s0,32(sp)
    800034ac:	ec26                	sd	s1,24(sp)
    800034ae:	e84a                	sd	s2,16(sp)
    800034b0:	e44e                	sd	s3,8(sp)
    800034b2:	e052                	sd	s4,0(sp)
    800034b4:	1800                	addi	s0,sp,48
    800034b6:	892a                	mv	s2,a0
    800034b8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034ba:	0001c517          	auipc	a0,0x1c
    800034be:	aae50513          	addi	a0,a0,-1362 # 8001ef68 <itable>
    800034c2:	f66fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800034c6:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034c8:	0001c497          	auipc	s1,0x1c
    800034cc:	ab848493          	addi	s1,s1,-1352 # 8001ef80 <itable+0x18>
    800034d0:	0001d697          	auipc	a3,0x1d
    800034d4:	54068693          	addi	a3,a3,1344 # 80020a10 <log>
    800034d8:	a809                	j	800034ea <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034da:	e781                	bnez	a5,800034e2 <iget+0x3c>
    800034dc:	00099363          	bnez	s3,800034e2 <iget+0x3c>
      empty = ip;
    800034e0:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034e2:	08848493          	addi	s1,s1,136
    800034e6:	02d48563          	beq	s1,a3,80003510 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034ea:	449c                	lw	a5,8(s1)
    800034ec:	fef057e3          	blez	a5,800034da <iget+0x34>
    800034f0:	4098                	lw	a4,0(s1)
    800034f2:	ff2718e3          	bne	a4,s2,800034e2 <iget+0x3c>
    800034f6:	40d8                	lw	a4,4(s1)
    800034f8:	ff4715e3          	bne	a4,s4,800034e2 <iget+0x3c>
      ip->ref++;
    800034fc:	2785                	addiw	a5,a5,1
    800034fe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003500:	0001c517          	auipc	a0,0x1c
    80003504:	a6850513          	addi	a0,a0,-1432 # 8001ef68 <itable>
    80003508:	fb4fd0ef          	jal	80000cbc <release>
      return ip;
    8000350c:	89a6                	mv	s3,s1
    8000350e:	a015                	j	80003532 <iget+0x8c>
  if(empty == 0)
    80003510:	02098a63          	beqz	s3,80003544 <iget+0x9e>
  ip->dev = dev;
    80003514:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003518:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000351c:	4785                	li	a5,1
    8000351e:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003522:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003526:	0001c517          	auipc	a0,0x1c
    8000352a:	a4250513          	addi	a0,a0,-1470 # 8001ef68 <itable>
    8000352e:	f8efd0ef          	jal	80000cbc <release>
}
    80003532:	854e                	mv	a0,s3
    80003534:	70a2                	ld	ra,40(sp)
    80003536:	7402                	ld	s0,32(sp)
    80003538:	64e2                	ld	s1,24(sp)
    8000353a:	6942                	ld	s2,16(sp)
    8000353c:	69a2                	ld	s3,8(sp)
    8000353e:	6a02                	ld	s4,0(sp)
    80003540:	6145                	addi	sp,sp,48
    80003542:	8082                	ret
    panic("iget: no inodes");
    80003544:	00004517          	auipc	a0,0x4
    80003548:	f3c50513          	addi	a0,a0,-196 # 80007480 <etext+0x480>
    8000354c:	ad8fd0ef          	jal	80000824 <panic>

0000000080003550 <iinit>:
{
    80003550:	7179                	addi	sp,sp,-48
    80003552:	f406                	sd	ra,40(sp)
    80003554:	f022                	sd	s0,32(sp)
    80003556:	ec26                	sd	s1,24(sp)
    80003558:	e84a                	sd	s2,16(sp)
    8000355a:	e44e                	sd	s3,8(sp)
    8000355c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000355e:	00004597          	auipc	a1,0x4
    80003562:	f3258593          	addi	a1,a1,-206 # 80007490 <etext+0x490>
    80003566:	0001c517          	auipc	a0,0x1c
    8000356a:	a0250513          	addi	a0,a0,-1534 # 8001ef68 <itable>
    8000356e:	e30fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003572:	0001c497          	auipc	s1,0x1c
    80003576:	a1e48493          	addi	s1,s1,-1506 # 8001ef90 <itable+0x28>
    8000357a:	0001d997          	auipc	s3,0x1d
    8000357e:	4a698993          	addi	s3,s3,1190 # 80020a20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003582:	00004917          	auipc	s2,0x4
    80003586:	f1690913          	addi	s2,s2,-234 # 80007498 <etext+0x498>
    8000358a:	85ca                	mv	a1,s2
    8000358c:	8526                	mv	a0,s1
    8000358e:	5f5000ef          	jal	80004382 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003592:	08848493          	addi	s1,s1,136
    80003596:	ff349ae3          	bne	s1,s3,8000358a <iinit+0x3a>
}
    8000359a:	70a2                	ld	ra,40(sp)
    8000359c:	7402                	ld	s0,32(sp)
    8000359e:	64e2                	ld	s1,24(sp)
    800035a0:	6942                	ld	s2,16(sp)
    800035a2:	69a2                	ld	s3,8(sp)
    800035a4:	6145                	addi	sp,sp,48
    800035a6:	8082                	ret

00000000800035a8 <ialloc>:
{
    800035a8:	7139                	addi	sp,sp,-64
    800035aa:	fc06                	sd	ra,56(sp)
    800035ac:	f822                	sd	s0,48(sp)
    800035ae:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b0:	0001c717          	auipc	a4,0x1c
    800035b4:	9a472703          	lw	a4,-1628(a4) # 8001ef54 <sb+0xc>
    800035b8:	4785                	li	a5,1
    800035ba:	06e7f063          	bgeu	a5,a4,8000361a <ialloc+0x72>
    800035be:	f426                	sd	s1,40(sp)
    800035c0:	f04a                	sd	s2,32(sp)
    800035c2:	ec4e                	sd	s3,24(sp)
    800035c4:	e852                	sd	s4,16(sp)
    800035c6:	e456                	sd	s5,8(sp)
    800035c8:	e05a                	sd	s6,0(sp)
    800035ca:	8aaa                	mv	s5,a0
    800035cc:	8b2e                	mv	s6,a1
    800035ce:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800035d0:	0001ca17          	auipc	s4,0x1c
    800035d4:	978a0a13          	addi	s4,s4,-1672 # 8001ef48 <sb>
    800035d8:	00495593          	srli	a1,s2,0x4
    800035dc:	018a2783          	lw	a5,24(s4)
    800035e0:	9dbd                	addw	a1,a1,a5
    800035e2:	8556                	mv	a0,s5
    800035e4:	a9dff0ef          	jal	80003080 <bread>
    800035e8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035ea:	05850993          	addi	s3,a0,88
    800035ee:	00f97793          	andi	a5,s2,15
    800035f2:	079a                	slli	a5,a5,0x6
    800035f4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035f6:	00099783          	lh	a5,0(s3)
    800035fa:	cb9d                	beqz	a5,80003630 <ialloc+0x88>
    brelse(bp);
    800035fc:	b8dff0ef          	jal	80003188 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003600:	0905                	addi	s2,s2,1
    80003602:	00ca2703          	lw	a4,12(s4)
    80003606:	0009079b          	sext.w	a5,s2
    8000360a:	fce7e7e3          	bltu	a5,a4,800035d8 <ialloc+0x30>
    8000360e:	74a2                	ld	s1,40(sp)
    80003610:	7902                	ld	s2,32(sp)
    80003612:	69e2                	ld	s3,24(sp)
    80003614:	6a42                	ld	s4,16(sp)
    80003616:	6aa2                	ld	s5,8(sp)
    80003618:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000361a:	00004517          	auipc	a0,0x4
    8000361e:	e8650513          	addi	a0,a0,-378 # 800074a0 <etext+0x4a0>
    80003622:	ed9fc0ef          	jal	800004fa <printf>
  return 0;
    80003626:	4501                	li	a0,0
}
    80003628:	70e2                	ld	ra,56(sp)
    8000362a:	7442                	ld	s0,48(sp)
    8000362c:	6121                	addi	sp,sp,64
    8000362e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003630:	04000613          	li	a2,64
    80003634:	4581                	li	a1,0
    80003636:	854e                	mv	a0,s3
    80003638:	ec0fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    8000363c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003640:	8526                	mv	a0,s1
    80003642:	47d000ef          	jal	800042be <log_write>
      brelse(bp);
    80003646:	8526                	mv	a0,s1
    80003648:	b41ff0ef          	jal	80003188 <brelse>
      return iget(dev, inum);
    8000364c:	0009059b          	sext.w	a1,s2
    80003650:	8556                	mv	a0,s5
    80003652:	e55ff0ef          	jal	800034a6 <iget>
    80003656:	74a2                	ld	s1,40(sp)
    80003658:	7902                	ld	s2,32(sp)
    8000365a:	69e2                	ld	s3,24(sp)
    8000365c:	6a42                	ld	s4,16(sp)
    8000365e:	6aa2                	ld	s5,8(sp)
    80003660:	6b02                	ld	s6,0(sp)
    80003662:	b7d9                	j	80003628 <ialloc+0x80>

0000000080003664 <iupdate>:
{
    80003664:	1101                	addi	sp,sp,-32
    80003666:	ec06                	sd	ra,24(sp)
    80003668:	e822                	sd	s0,16(sp)
    8000366a:	e426                	sd	s1,8(sp)
    8000366c:	e04a                	sd	s2,0(sp)
    8000366e:	1000                	addi	s0,sp,32
    80003670:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003672:	415c                	lw	a5,4(a0)
    80003674:	0047d79b          	srliw	a5,a5,0x4
    80003678:	0001c597          	auipc	a1,0x1c
    8000367c:	8e85a583          	lw	a1,-1816(a1) # 8001ef60 <sb+0x18>
    80003680:	9dbd                	addw	a1,a1,a5
    80003682:	4108                	lw	a0,0(a0)
    80003684:	9fdff0ef          	jal	80003080 <bread>
    80003688:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000368a:	05850793          	addi	a5,a0,88
    8000368e:	40d8                	lw	a4,4(s1)
    80003690:	8b3d                	andi	a4,a4,15
    80003692:	071a                	slli	a4,a4,0x6
    80003694:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003696:	04449703          	lh	a4,68(s1)
    8000369a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000369e:	04649703          	lh	a4,70(s1)
    800036a2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036a6:	04849703          	lh	a4,72(s1)
    800036aa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036ae:	04a49703          	lh	a4,74(s1)
    800036b2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036b6:	44f8                	lw	a4,76(s1)
    800036b8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036ba:	03400613          	li	a2,52
    800036be:	05048593          	addi	a1,s1,80
    800036c2:	00c78513          	addi	a0,a5,12
    800036c6:	e92fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    800036ca:	854a                	mv	a0,s2
    800036cc:	3f3000ef          	jal	800042be <log_write>
  brelse(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	ab7ff0ef          	jal	80003188 <brelse>
}
    800036d6:	60e2                	ld	ra,24(sp)
    800036d8:	6442                	ld	s0,16(sp)
    800036da:	64a2                	ld	s1,8(sp)
    800036dc:	6902                	ld	s2,0(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret

00000000800036e2 <idup>:
{
    800036e2:	1101                	addi	sp,sp,-32
    800036e4:	ec06                	sd	ra,24(sp)
    800036e6:	e822                	sd	s0,16(sp)
    800036e8:	e426                	sd	s1,8(sp)
    800036ea:	1000                	addi	s0,sp,32
    800036ec:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036ee:	0001c517          	auipc	a0,0x1c
    800036f2:	87a50513          	addi	a0,a0,-1926 # 8001ef68 <itable>
    800036f6:	d32fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800036fa:	449c                	lw	a5,8(s1)
    800036fc:	2785                	addiw	a5,a5,1
    800036fe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003700:	0001c517          	auipc	a0,0x1c
    80003704:	86850513          	addi	a0,a0,-1944 # 8001ef68 <itable>
    80003708:	db4fd0ef          	jal	80000cbc <release>
}
    8000370c:	8526                	mv	a0,s1
    8000370e:	60e2                	ld	ra,24(sp)
    80003710:	6442                	ld	s0,16(sp)
    80003712:	64a2                	ld	s1,8(sp)
    80003714:	6105                	addi	sp,sp,32
    80003716:	8082                	ret

0000000080003718 <ilock>:
{
    80003718:	1101                	addi	sp,sp,-32
    8000371a:	ec06                	sd	ra,24(sp)
    8000371c:	e822                	sd	s0,16(sp)
    8000371e:	e426                	sd	s1,8(sp)
    80003720:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003722:	cd19                	beqz	a0,80003740 <ilock+0x28>
    80003724:	84aa                	mv	s1,a0
    80003726:	451c                	lw	a5,8(a0)
    80003728:	00f05c63          	blez	a5,80003740 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000372c:	0541                	addi	a0,a0,16
    8000372e:	48b000ef          	jal	800043b8 <acquiresleep>
  if(ip->valid == 0){
    80003732:	40bc                	lw	a5,64(s1)
    80003734:	cf89                	beqz	a5,8000374e <ilock+0x36>
}
    80003736:	60e2                	ld	ra,24(sp)
    80003738:	6442                	ld	s0,16(sp)
    8000373a:	64a2                	ld	s1,8(sp)
    8000373c:	6105                	addi	sp,sp,32
    8000373e:	8082                	ret
    80003740:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003742:	00004517          	auipc	a0,0x4
    80003746:	d7650513          	addi	a0,a0,-650 # 800074b8 <etext+0x4b8>
    8000374a:	8dafd0ef          	jal	80000824 <panic>
    8000374e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003750:	40dc                	lw	a5,4(s1)
    80003752:	0047d79b          	srliw	a5,a5,0x4
    80003756:	0001c597          	auipc	a1,0x1c
    8000375a:	80a5a583          	lw	a1,-2038(a1) # 8001ef60 <sb+0x18>
    8000375e:	9dbd                	addw	a1,a1,a5
    80003760:	4088                	lw	a0,0(s1)
    80003762:	91fff0ef          	jal	80003080 <bread>
    80003766:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003768:	05850593          	addi	a1,a0,88
    8000376c:	40dc                	lw	a5,4(s1)
    8000376e:	8bbd                	andi	a5,a5,15
    80003770:	079a                	slli	a5,a5,0x6
    80003772:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003774:	00059783          	lh	a5,0(a1)
    80003778:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000377c:	00259783          	lh	a5,2(a1)
    80003780:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003784:	00459783          	lh	a5,4(a1)
    80003788:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000378c:	00659783          	lh	a5,6(a1)
    80003790:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003794:	459c                	lw	a5,8(a1)
    80003796:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003798:	03400613          	li	a2,52
    8000379c:	05b1                	addi	a1,a1,12
    8000379e:	05048513          	addi	a0,s1,80
    800037a2:	db6fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    800037a6:	854a                	mv	a0,s2
    800037a8:	9e1ff0ef          	jal	80003188 <brelse>
    ip->valid = 1;
    800037ac:	4785                	li	a5,1
    800037ae:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037b0:	04449783          	lh	a5,68(s1)
    800037b4:	c399                	beqz	a5,800037ba <ilock+0xa2>
    800037b6:	6902                	ld	s2,0(sp)
    800037b8:	bfbd                	j	80003736 <ilock+0x1e>
      panic("ilock: no type");
    800037ba:	00004517          	auipc	a0,0x4
    800037be:	d0650513          	addi	a0,a0,-762 # 800074c0 <etext+0x4c0>
    800037c2:	862fd0ef          	jal	80000824 <panic>

00000000800037c6 <iunlock>:
{
    800037c6:	1101                	addi	sp,sp,-32
    800037c8:	ec06                	sd	ra,24(sp)
    800037ca:	e822                	sd	s0,16(sp)
    800037cc:	e426                	sd	s1,8(sp)
    800037ce:	e04a                	sd	s2,0(sp)
    800037d0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037d2:	c505                	beqz	a0,800037fa <iunlock+0x34>
    800037d4:	84aa                	mv	s1,a0
    800037d6:	01050913          	addi	s2,a0,16
    800037da:	854a                	mv	a0,s2
    800037dc:	45b000ef          	jal	80004436 <holdingsleep>
    800037e0:	cd09                	beqz	a0,800037fa <iunlock+0x34>
    800037e2:	449c                	lw	a5,8(s1)
    800037e4:	00f05b63          	blez	a5,800037fa <iunlock+0x34>
  releasesleep(&ip->lock);
    800037e8:	854a                	mv	a0,s2
    800037ea:	415000ef          	jal	800043fe <releasesleep>
}
    800037ee:	60e2                	ld	ra,24(sp)
    800037f0:	6442                	ld	s0,16(sp)
    800037f2:	64a2                	ld	s1,8(sp)
    800037f4:	6902                	ld	s2,0(sp)
    800037f6:	6105                	addi	sp,sp,32
    800037f8:	8082                	ret
    panic("iunlock");
    800037fa:	00004517          	auipc	a0,0x4
    800037fe:	cd650513          	addi	a0,a0,-810 # 800074d0 <etext+0x4d0>
    80003802:	822fd0ef          	jal	80000824 <panic>

0000000080003806 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003806:	7179                	addi	sp,sp,-48
    80003808:	f406                	sd	ra,40(sp)
    8000380a:	f022                	sd	s0,32(sp)
    8000380c:	ec26                	sd	s1,24(sp)
    8000380e:	e84a                	sd	s2,16(sp)
    80003810:	e44e                	sd	s3,8(sp)
    80003812:	1800                	addi	s0,sp,48
    80003814:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003816:	05050493          	addi	s1,a0,80
    8000381a:	08050913          	addi	s2,a0,128
    8000381e:	a021                	j	80003826 <itrunc+0x20>
    80003820:	0491                	addi	s1,s1,4
    80003822:	01248b63          	beq	s1,s2,80003838 <itrunc+0x32>
    if(ip->addrs[i]){
    80003826:	408c                	lw	a1,0(s1)
    80003828:	dde5                	beqz	a1,80003820 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000382a:	0009a503          	lw	a0,0(s3)
    8000382e:	a47ff0ef          	jal	80003274 <bfree>
      ip->addrs[i] = 0;
    80003832:	0004a023          	sw	zero,0(s1)
    80003836:	b7ed                	j	80003820 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003838:	0809a583          	lw	a1,128(s3)
    8000383c:	ed89                	bnez	a1,80003856 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000383e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003842:	854e                	mv	a0,s3
    80003844:	e21ff0ef          	jal	80003664 <iupdate>
}
    80003848:	70a2                	ld	ra,40(sp)
    8000384a:	7402                	ld	s0,32(sp)
    8000384c:	64e2                	ld	s1,24(sp)
    8000384e:	6942                	ld	s2,16(sp)
    80003850:	69a2                	ld	s3,8(sp)
    80003852:	6145                	addi	sp,sp,48
    80003854:	8082                	ret
    80003856:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003858:	0009a503          	lw	a0,0(s3)
    8000385c:	825ff0ef          	jal	80003080 <bread>
    80003860:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003862:	05850493          	addi	s1,a0,88
    80003866:	45850913          	addi	s2,a0,1112
    8000386a:	a021                	j	80003872 <itrunc+0x6c>
    8000386c:	0491                	addi	s1,s1,4
    8000386e:	01248963          	beq	s1,s2,80003880 <itrunc+0x7a>
      if(a[j])
    80003872:	408c                	lw	a1,0(s1)
    80003874:	dde5                	beqz	a1,8000386c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003876:	0009a503          	lw	a0,0(s3)
    8000387a:	9fbff0ef          	jal	80003274 <bfree>
    8000387e:	b7fd                	j	8000386c <itrunc+0x66>
    brelse(bp);
    80003880:	8552                	mv	a0,s4
    80003882:	907ff0ef          	jal	80003188 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003886:	0809a583          	lw	a1,128(s3)
    8000388a:	0009a503          	lw	a0,0(s3)
    8000388e:	9e7ff0ef          	jal	80003274 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003892:	0809a023          	sw	zero,128(s3)
    80003896:	6a02                	ld	s4,0(sp)
    80003898:	b75d                	j	8000383e <itrunc+0x38>

000000008000389a <iput>:
{
    8000389a:	1101                	addi	sp,sp,-32
    8000389c:	ec06                	sd	ra,24(sp)
    8000389e:	e822                	sd	s0,16(sp)
    800038a0:	e426                	sd	s1,8(sp)
    800038a2:	1000                	addi	s0,sp,32
    800038a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038a6:	0001b517          	auipc	a0,0x1b
    800038aa:	6c250513          	addi	a0,a0,1730 # 8001ef68 <itable>
    800038ae:	b7afd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038b2:	4498                	lw	a4,8(s1)
    800038b4:	4785                	li	a5,1
    800038b6:	02f70063          	beq	a4,a5,800038d6 <iput+0x3c>
  ip->ref--;
    800038ba:	449c                	lw	a5,8(s1)
    800038bc:	37fd                	addiw	a5,a5,-1
    800038be:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038c0:	0001b517          	auipc	a0,0x1b
    800038c4:	6a850513          	addi	a0,a0,1704 # 8001ef68 <itable>
    800038c8:	bf4fd0ef          	jal	80000cbc <release>
}
    800038cc:	60e2                	ld	ra,24(sp)
    800038ce:	6442                	ld	s0,16(sp)
    800038d0:	64a2                	ld	s1,8(sp)
    800038d2:	6105                	addi	sp,sp,32
    800038d4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038d6:	40bc                	lw	a5,64(s1)
    800038d8:	d3ed                	beqz	a5,800038ba <iput+0x20>
    800038da:	04a49783          	lh	a5,74(s1)
    800038de:	fff1                	bnez	a5,800038ba <iput+0x20>
    800038e0:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800038e2:	01048793          	addi	a5,s1,16
    800038e6:	893e                	mv	s2,a5
    800038e8:	853e                	mv	a0,a5
    800038ea:	2cf000ef          	jal	800043b8 <acquiresleep>
    release(&itable.lock);
    800038ee:	0001b517          	auipc	a0,0x1b
    800038f2:	67a50513          	addi	a0,a0,1658 # 8001ef68 <itable>
    800038f6:	bc6fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    800038fa:	8526                	mv	a0,s1
    800038fc:	f0bff0ef          	jal	80003806 <itrunc>
    ip->type = 0;
    80003900:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003904:	8526                	mv	a0,s1
    80003906:	d5fff0ef          	jal	80003664 <iupdate>
    ip->valid = 0;
    8000390a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000390e:	854a                	mv	a0,s2
    80003910:	2ef000ef          	jal	800043fe <releasesleep>
    acquire(&itable.lock);
    80003914:	0001b517          	auipc	a0,0x1b
    80003918:	65450513          	addi	a0,a0,1620 # 8001ef68 <itable>
    8000391c:	b0cfd0ef          	jal	80000c28 <acquire>
    80003920:	6902                	ld	s2,0(sp)
    80003922:	bf61                	j	800038ba <iput+0x20>

0000000080003924 <iunlockput>:
{
    80003924:	1101                	addi	sp,sp,-32
    80003926:	ec06                	sd	ra,24(sp)
    80003928:	e822                	sd	s0,16(sp)
    8000392a:	e426                	sd	s1,8(sp)
    8000392c:	1000                	addi	s0,sp,32
    8000392e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003930:	e97ff0ef          	jal	800037c6 <iunlock>
  iput(ip);
    80003934:	8526                	mv	a0,s1
    80003936:	f65ff0ef          	jal	8000389a <iput>
}
    8000393a:	60e2                	ld	ra,24(sp)
    8000393c:	6442                	ld	s0,16(sp)
    8000393e:	64a2                	ld	s1,8(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003944:	0001b717          	auipc	a4,0x1b
    80003948:	61072703          	lw	a4,1552(a4) # 8001ef54 <sb+0xc>
    8000394c:	4785                	li	a5,1
    8000394e:	0ae7fe63          	bgeu	a5,a4,80003a0a <ireclaim+0xc6>
{
    80003952:	7139                	addi	sp,sp,-64
    80003954:	fc06                	sd	ra,56(sp)
    80003956:	f822                	sd	s0,48(sp)
    80003958:	f426                	sd	s1,40(sp)
    8000395a:	f04a                	sd	s2,32(sp)
    8000395c:	ec4e                	sd	s3,24(sp)
    8000395e:	e852                	sd	s4,16(sp)
    80003960:	e456                	sd	s5,8(sp)
    80003962:	e05a                	sd	s6,0(sp)
    80003964:	0080                	addi	s0,sp,64
    80003966:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003968:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000396a:	0001ba17          	auipc	s4,0x1b
    8000396e:	5dea0a13          	addi	s4,s4,1502 # 8001ef48 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003972:	00004b17          	auipc	s6,0x4
    80003976:	b66b0b13          	addi	s6,s6,-1178 # 800074d8 <etext+0x4d8>
    8000397a:	a099                	j	800039c0 <ireclaim+0x7c>
    8000397c:	85ce                	mv	a1,s3
    8000397e:	855a                	mv	a0,s6
    80003980:	b7bfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003984:	85ce                	mv	a1,s3
    80003986:	8556                	mv	a0,s5
    80003988:	b1fff0ef          	jal	800034a6 <iget>
    8000398c:	89aa                	mv	s3,a0
    brelse(bp);
    8000398e:	854a                	mv	a0,s2
    80003990:	ff8ff0ef          	jal	80003188 <brelse>
    if (ip) {
    80003994:	00098f63          	beqz	s3,800039b2 <ireclaim+0x6e>
      begin_op();
    80003998:	78c000ef          	jal	80004124 <begin_op>
      ilock(ip);
    8000399c:	854e                	mv	a0,s3
    8000399e:	d7bff0ef          	jal	80003718 <ilock>
      iunlock(ip);
    800039a2:	854e                	mv	a0,s3
    800039a4:	e23ff0ef          	jal	800037c6 <iunlock>
      iput(ip);
    800039a8:	854e                	mv	a0,s3
    800039aa:	ef1ff0ef          	jal	8000389a <iput>
      end_op();
    800039ae:	7e6000ef          	jal	80004194 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039b2:	0485                	addi	s1,s1,1
    800039b4:	00ca2703          	lw	a4,12(s4)
    800039b8:	0004879b          	sext.w	a5,s1
    800039bc:	02e7fd63          	bgeu	a5,a4,800039f6 <ireclaim+0xb2>
    800039c0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800039c4:	0044d593          	srli	a1,s1,0x4
    800039c8:	018a2783          	lw	a5,24(s4)
    800039cc:	9dbd                	addw	a1,a1,a5
    800039ce:	8556                	mv	a0,s5
    800039d0:	eb0ff0ef          	jal	80003080 <bread>
    800039d4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800039d6:	05850793          	addi	a5,a0,88
    800039da:	00f9f713          	andi	a4,s3,15
    800039de:	071a                	slli	a4,a4,0x6
    800039e0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800039e2:	00079703          	lh	a4,0(a5)
    800039e6:	c701                	beqz	a4,800039ee <ireclaim+0xaa>
    800039e8:	00679783          	lh	a5,6(a5)
    800039ec:	dbc1                	beqz	a5,8000397c <ireclaim+0x38>
    brelse(bp);
    800039ee:	854a                	mv	a0,s2
    800039f0:	f98ff0ef          	jal	80003188 <brelse>
    if (ip) {
    800039f4:	bf7d                	j	800039b2 <ireclaim+0x6e>
}
    800039f6:	70e2                	ld	ra,56(sp)
    800039f8:	7442                	ld	s0,48(sp)
    800039fa:	74a2                	ld	s1,40(sp)
    800039fc:	7902                	ld	s2,32(sp)
    800039fe:	69e2                	ld	s3,24(sp)
    80003a00:	6a42                	ld	s4,16(sp)
    80003a02:	6aa2                	ld	s5,8(sp)
    80003a04:	6b02                	ld	s6,0(sp)
    80003a06:	6121                	addi	sp,sp,64
    80003a08:	8082                	ret
    80003a0a:	8082                	ret

0000000080003a0c <fsinit>:
fsinit(int dev) {
    80003a0c:	1101                	addi	sp,sp,-32
    80003a0e:	ec06                	sd	ra,24(sp)
    80003a10:	e822                	sd	s0,16(sp)
    80003a12:	e426                	sd	s1,8(sp)
    80003a14:	e04a                	sd	s2,0(sp)
    80003a16:	1000                	addi	s0,sp,32
    80003a18:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a1a:	4585                	li	a1,1
    80003a1c:	e64ff0ef          	jal	80003080 <bread>
    80003a20:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a22:	02000613          	li	a2,32
    80003a26:	05850593          	addi	a1,a0,88
    80003a2a:	0001b517          	auipc	a0,0x1b
    80003a2e:	51e50513          	addi	a0,a0,1310 # 8001ef48 <sb>
    80003a32:	b26fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003a36:	8526                	mv	a0,s1
    80003a38:	f50ff0ef          	jal	80003188 <brelse>
  if(sb.magic != FSMAGIC)
    80003a3c:	0001b717          	auipc	a4,0x1b
    80003a40:	50c72703          	lw	a4,1292(a4) # 8001ef48 <sb>
    80003a44:	102037b7          	lui	a5,0x10203
    80003a48:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a4c:	02f71263          	bne	a4,a5,80003a70 <fsinit+0x64>
  initlog(dev, &sb);
    80003a50:	0001b597          	auipc	a1,0x1b
    80003a54:	4f858593          	addi	a1,a1,1272 # 8001ef48 <sb>
    80003a58:	854a                	mv	a0,s2
    80003a5a:	648000ef          	jal	800040a2 <initlog>
  ireclaim(dev);
    80003a5e:	854a                	mv	a0,s2
    80003a60:	ee5ff0ef          	jal	80003944 <ireclaim>
}
    80003a64:	60e2                	ld	ra,24(sp)
    80003a66:	6442                	ld	s0,16(sp)
    80003a68:	64a2                	ld	s1,8(sp)
    80003a6a:	6902                	ld	s2,0(sp)
    80003a6c:	6105                	addi	sp,sp,32
    80003a6e:	8082                	ret
    panic("invalid file system");
    80003a70:	00004517          	auipc	a0,0x4
    80003a74:	a8850513          	addi	a0,a0,-1400 # 800074f8 <etext+0x4f8>
    80003a78:	dadfc0ef          	jal	80000824 <panic>

0000000080003a7c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a7c:	1141                	addi	sp,sp,-16
    80003a7e:	e406                	sd	ra,8(sp)
    80003a80:	e022                	sd	s0,0(sp)
    80003a82:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a84:	411c                	lw	a5,0(a0)
    80003a86:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a88:	415c                	lw	a5,4(a0)
    80003a8a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a8c:	04451783          	lh	a5,68(a0)
    80003a90:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a94:	04a51783          	lh	a5,74(a0)
    80003a98:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a9c:	04c56783          	lwu	a5,76(a0)
    80003aa0:	e99c                	sd	a5,16(a1)
}
    80003aa2:	60a2                	ld	ra,8(sp)
    80003aa4:	6402                	ld	s0,0(sp)
    80003aa6:	0141                	addi	sp,sp,16
    80003aa8:	8082                	ret

0000000080003aaa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aaa:	457c                	lw	a5,76(a0)
    80003aac:	0ed7e663          	bltu	a5,a3,80003b98 <readi+0xee>
{
    80003ab0:	7159                	addi	sp,sp,-112
    80003ab2:	f486                	sd	ra,104(sp)
    80003ab4:	f0a2                	sd	s0,96(sp)
    80003ab6:	eca6                	sd	s1,88(sp)
    80003ab8:	e0d2                	sd	s4,64(sp)
    80003aba:	fc56                	sd	s5,56(sp)
    80003abc:	f85a                	sd	s6,48(sp)
    80003abe:	f45e                	sd	s7,40(sp)
    80003ac0:	1880                	addi	s0,sp,112
    80003ac2:	8b2a                	mv	s6,a0
    80003ac4:	8bae                	mv	s7,a1
    80003ac6:	8a32                	mv	s4,a2
    80003ac8:	84b6                	mv	s1,a3
    80003aca:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003acc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ace:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ad0:	0ad76b63          	bltu	a4,a3,80003b86 <readi+0xdc>
    80003ad4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003ad6:	00e7f463          	bgeu	a5,a4,80003ade <readi+0x34>
    n = ip->size - off;
    80003ada:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ade:	080a8b63          	beqz	s5,80003b74 <readi+0xca>
    80003ae2:	e8ca                	sd	s2,80(sp)
    80003ae4:	f062                	sd	s8,32(sp)
    80003ae6:	ec66                	sd	s9,24(sp)
    80003ae8:	e86a                	sd	s10,16(sp)
    80003aea:	e46e                	sd	s11,8(sp)
    80003aec:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aee:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003af2:	5c7d                	li	s8,-1
    80003af4:	a80d                	j	80003b26 <readi+0x7c>
    80003af6:	020d1d93          	slli	s11,s10,0x20
    80003afa:	020ddd93          	srli	s11,s11,0x20
    80003afe:	05890613          	addi	a2,s2,88
    80003b02:	86ee                	mv	a3,s11
    80003b04:	963e                	add	a2,a2,a5
    80003b06:	85d2                	mv	a1,s4
    80003b08:	855e                	mv	a0,s7
    80003b0a:	bcafe0ef          	jal	80001ed4 <either_copyout>
    80003b0e:	05850363          	beq	a0,s8,80003b54 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b12:	854a                	mv	a0,s2
    80003b14:	e74ff0ef          	jal	80003188 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b18:	013d09bb          	addw	s3,s10,s3
    80003b1c:	009d04bb          	addw	s1,s10,s1
    80003b20:	9a6e                	add	s4,s4,s11
    80003b22:	0559f363          	bgeu	s3,s5,80003b68 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b26:	00a4d59b          	srliw	a1,s1,0xa
    80003b2a:	855a                	mv	a0,s6
    80003b2c:	8bbff0ef          	jal	800033e6 <bmap>
    80003b30:	85aa                	mv	a1,a0
    if(addr == 0)
    80003b32:	c139                	beqz	a0,80003b78 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003b34:	000b2503          	lw	a0,0(s6)
    80003b38:	d48ff0ef          	jal	80003080 <bread>
    80003b3c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b3e:	3ff4f793          	andi	a5,s1,1023
    80003b42:	40fc873b          	subw	a4,s9,a5
    80003b46:	413a86bb          	subw	a3,s5,s3
    80003b4a:	8d3a                	mv	s10,a4
    80003b4c:	fae6f5e3          	bgeu	a3,a4,80003af6 <readi+0x4c>
    80003b50:	8d36                	mv	s10,a3
    80003b52:	b755                	j	80003af6 <readi+0x4c>
      brelse(bp);
    80003b54:	854a                	mv	a0,s2
    80003b56:	e32ff0ef          	jal	80003188 <brelse>
      tot = -1;
    80003b5a:	59fd                	li	s3,-1
      break;
    80003b5c:	6946                	ld	s2,80(sp)
    80003b5e:	7c02                	ld	s8,32(sp)
    80003b60:	6ce2                	ld	s9,24(sp)
    80003b62:	6d42                	ld	s10,16(sp)
    80003b64:	6da2                	ld	s11,8(sp)
    80003b66:	a831                	j	80003b82 <readi+0xd8>
    80003b68:	6946                	ld	s2,80(sp)
    80003b6a:	7c02                	ld	s8,32(sp)
    80003b6c:	6ce2                	ld	s9,24(sp)
    80003b6e:	6d42                	ld	s10,16(sp)
    80003b70:	6da2                	ld	s11,8(sp)
    80003b72:	a801                	j	80003b82 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b74:	89d6                	mv	s3,s5
    80003b76:	a031                	j	80003b82 <readi+0xd8>
    80003b78:	6946                	ld	s2,80(sp)
    80003b7a:	7c02                	ld	s8,32(sp)
    80003b7c:	6ce2                	ld	s9,24(sp)
    80003b7e:	6d42                	ld	s10,16(sp)
    80003b80:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003b82:	854e                	mv	a0,s3
    80003b84:	69a6                	ld	s3,72(sp)
}
    80003b86:	70a6                	ld	ra,104(sp)
    80003b88:	7406                	ld	s0,96(sp)
    80003b8a:	64e6                	ld	s1,88(sp)
    80003b8c:	6a06                	ld	s4,64(sp)
    80003b8e:	7ae2                	ld	s5,56(sp)
    80003b90:	7b42                	ld	s6,48(sp)
    80003b92:	7ba2                	ld	s7,40(sp)
    80003b94:	6165                	addi	sp,sp,112
    80003b96:	8082                	ret
    return 0;
    80003b98:	4501                	li	a0,0
}
    80003b9a:	8082                	ret

0000000080003b9c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b9c:	457c                	lw	a5,76(a0)
    80003b9e:	0ed7eb63          	bltu	a5,a3,80003c94 <writei+0xf8>
{
    80003ba2:	7159                	addi	sp,sp,-112
    80003ba4:	f486                	sd	ra,104(sp)
    80003ba6:	f0a2                	sd	s0,96(sp)
    80003ba8:	e8ca                	sd	s2,80(sp)
    80003baa:	e0d2                	sd	s4,64(sp)
    80003bac:	fc56                	sd	s5,56(sp)
    80003bae:	f85a                	sd	s6,48(sp)
    80003bb0:	f45e                	sd	s7,40(sp)
    80003bb2:	1880                	addi	s0,sp,112
    80003bb4:	8aaa                	mv	s5,a0
    80003bb6:	8bae                	mv	s7,a1
    80003bb8:	8a32                	mv	s4,a2
    80003bba:	8936                	mv	s2,a3
    80003bbc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bbe:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bc2:	00043737          	lui	a4,0x43
    80003bc6:	0cf76963          	bltu	a4,a5,80003c98 <writei+0xfc>
    80003bca:	0cd7e763          	bltu	a5,a3,80003c98 <writei+0xfc>
    80003bce:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd0:	0a0b0a63          	beqz	s6,80003c84 <writei+0xe8>
    80003bd4:	eca6                	sd	s1,88(sp)
    80003bd6:	f062                	sd	s8,32(sp)
    80003bd8:	ec66                	sd	s9,24(sp)
    80003bda:	e86a                	sd	s10,16(sp)
    80003bdc:	e46e                	sd	s11,8(sp)
    80003bde:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003be4:	5c7d                	li	s8,-1
    80003be6:	a825                	j	80003c1e <writei+0x82>
    80003be8:	020d1d93          	slli	s11,s10,0x20
    80003bec:	020ddd93          	srli	s11,s11,0x20
    80003bf0:	05848513          	addi	a0,s1,88
    80003bf4:	86ee                	mv	a3,s11
    80003bf6:	8652                	mv	a2,s4
    80003bf8:	85de                	mv	a1,s7
    80003bfa:	953e                	add	a0,a0,a5
    80003bfc:	b22fe0ef          	jal	80001f1e <either_copyin>
    80003c00:	05850663          	beq	a0,s8,80003c4c <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c04:	8526                	mv	a0,s1
    80003c06:	6b8000ef          	jal	800042be <log_write>
    brelse(bp);
    80003c0a:	8526                	mv	a0,s1
    80003c0c:	d7cff0ef          	jal	80003188 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c10:	013d09bb          	addw	s3,s10,s3
    80003c14:	012d093b          	addw	s2,s10,s2
    80003c18:	9a6e                	add	s4,s4,s11
    80003c1a:	0369fc63          	bgeu	s3,s6,80003c52 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003c1e:	00a9559b          	srliw	a1,s2,0xa
    80003c22:	8556                	mv	a0,s5
    80003c24:	fc2ff0ef          	jal	800033e6 <bmap>
    80003c28:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c2a:	c505                	beqz	a0,80003c52 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003c2c:	000aa503          	lw	a0,0(s5)
    80003c30:	c50ff0ef          	jal	80003080 <bread>
    80003c34:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c36:	3ff97793          	andi	a5,s2,1023
    80003c3a:	40fc873b          	subw	a4,s9,a5
    80003c3e:	413b06bb          	subw	a3,s6,s3
    80003c42:	8d3a                	mv	s10,a4
    80003c44:	fae6f2e3          	bgeu	a3,a4,80003be8 <writei+0x4c>
    80003c48:	8d36                	mv	s10,a3
    80003c4a:	bf79                	j	80003be8 <writei+0x4c>
      brelse(bp);
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	d3aff0ef          	jal	80003188 <brelse>
  }

  if(off > ip->size)
    80003c52:	04caa783          	lw	a5,76(s5)
    80003c56:	0327f963          	bgeu	a5,s2,80003c88 <writei+0xec>
    ip->size = off;
    80003c5a:	052aa623          	sw	s2,76(s5)
    80003c5e:	64e6                	ld	s1,88(sp)
    80003c60:	7c02                	ld	s8,32(sp)
    80003c62:	6ce2                	ld	s9,24(sp)
    80003c64:	6d42                	ld	s10,16(sp)
    80003c66:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c68:	8556                	mv	a0,s5
    80003c6a:	9fbff0ef          	jal	80003664 <iupdate>

  return tot;
    80003c6e:	854e                	mv	a0,s3
    80003c70:	69a6                	ld	s3,72(sp)
}
    80003c72:	70a6                	ld	ra,104(sp)
    80003c74:	7406                	ld	s0,96(sp)
    80003c76:	6946                	ld	s2,80(sp)
    80003c78:	6a06                	ld	s4,64(sp)
    80003c7a:	7ae2                	ld	s5,56(sp)
    80003c7c:	7b42                	ld	s6,48(sp)
    80003c7e:	7ba2                	ld	s7,40(sp)
    80003c80:	6165                	addi	sp,sp,112
    80003c82:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c84:	89da                	mv	s3,s6
    80003c86:	b7cd                	j	80003c68 <writei+0xcc>
    80003c88:	64e6                	ld	s1,88(sp)
    80003c8a:	7c02                	ld	s8,32(sp)
    80003c8c:	6ce2                	ld	s9,24(sp)
    80003c8e:	6d42                	ld	s10,16(sp)
    80003c90:	6da2                	ld	s11,8(sp)
    80003c92:	bfd9                	j	80003c68 <writei+0xcc>
    return -1;
    80003c94:	557d                	li	a0,-1
}
    80003c96:	8082                	ret
    return -1;
    80003c98:	557d                	li	a0,-1
    80003c9a:	bfe1                	j	80003c72 <writei+0xd6>

0000000080003c9c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c9c:	1141                	addi	sp,sp,-16
    80003c9e:	e406                	sd	ra,8(sp)
    80003ca0:	e022                	sd	s0,0(sp)
    80003ca2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ca4:	4639                	li	a2,14
    80003ca6:	926fd0ef          	jal	80000dcc <strncmp>
}
    80003caa:	60a2                	ld	ra,8(sp)
    80003cac:	6402                	ld	s0,0(sp)
    80003cae:	0141                	addi	sp,sp,16
    80003cb0:	8082                	ret

0000000080003cb2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cb2:	711d                	addi	sp,sp,-96
    80003cb4:	ec86                	sd	ra,88(sp)
    80003cb6:	e8a2                	sd	s0,80(sp)
    80003cb8:	e4a6                	sd	s1,72(sp)
    80003cba:	e0ca                	sd	s2,64(sp)
    80003cbc:	fc4e                	sd	s3,56(sp)
    80003cbe:	f852                	sd	s4,48(sp)
    80003cc0:	f456                	sd	s5,40(sp)
    80003cc2:	f05a                	sd	s6,32(sp)
    80003cc4:	ec5e                	sd	s7,24(sp)
    80003cc6:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cc8:	04451703          	lh	a4,68(a0)
    80003ccc:	4785                	li	a5,1
    80003cce:	00f71f63          	bne	a4,a5,80003cec <dirlookup+0x3a>
    80003cd2:	892a                	mv	s2,a0
    80003cd4:	8aae                	mv	s5,a1
    80003cd6:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cd8:	457c                	lw	a5,76(a0)
    80003cda:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cdc:	fa040a13          	addi	s4,s0,-96
    80003ce0:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003ce2:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ce6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce8:	e39d                	bnez	a5,80003d0e <dirlookup+0x5c>
    80003cea:	a8b9                	j	80003d48 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003cec:	00004517          	auipc	a0,0x4
    80003cf0:	82450513          	addi	a0,a0,-2012 # 80007510 <etext+0x510>
    80003cf4:	b31fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003cf8:	00004517          	auipc	a0,0x4
    80003cfc:	83050513          	addi	a0,a0,-2000 # 80007528 <etext+0x528>
    80003d00:	b25fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d04:	24c1                	addiw	s1,s1,16
    80003d06:	04c92783          	lw	a5,76(s2)
    80003d0a:	02f4fe63          	bgeu	s1,a5,80003d46 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d0e:	874e                	mv	a4,s3
    80003d10:	86a6                	mv	a3,s1
    80003d12:	8652                	mv	a2,s4
    80003d14:	4581                	li	a1,0
    80003d16:	854a                	mv	a0,s2
    80003d18:	d93ff0ef          	jal	80003aaa <readi>
    80003d1c:	fd351ee3          	bne	a0,s3,80003cf8 <dirlookup+0x46>
    if(de.inum == 0)
    80003d20:	fa045783          	lhu	a5,-96(s0)
    80003d24:	d3e5                	beqz	a5,80003d04 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003d26:	85da                	mv	a1,s6
    80003d28:	8556                	mv	a0,s5
    80003d2a:	f73ff0ef          	jal	80003c9c <namecmp>
    80003d2e:	f979                	bnez	a0,80003d04 <dirlookup+0x52>
      if(poff)
    80003d30:	000b8463          	beqz	s7,80003d38 <dirlookup+0x86>
        *poff = off;
    80003d34:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003d38:	fa045583          	lhu	a1,-96(s0)
    80003d3c:	00092503          	lw	a0,0(s2)
    80003d40:	f66ff0ef          	jal	800034a6 <iget>
    80003d44:	a011                	j	80003d48 <dirlookup+0x96>
  return 0;
    80003d46:	4501                	li	a0,0
}
    80003d48:	60e6                	ld	ra,88(sp)
    80003d4a:	6446                	ld	s0,80(sp)
    80003d4c:	64a6                	ld	s1,72(sp)
    80003d4e:	6906                	ld	s2,64(sp)
    80003d50:	79e2                	ld	s3,56(sp)
    80003d52:	7a42                	ld	s4,48(sp)
    80003d54:	7aa2                	ld	s5,40(sp)
    80003d56:	7b02                	ld	s6,32(sp)
    80003d58:	6be2                	ld	s7,24(sp)
    80003d5a:	6125                	addi	sp,sp,96
    80003d5c:	8082                	ret

0000000080003d5e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d5e:	711d                	addi	sp,sp,-96
    80003d60:	ec86                	sd	ra,88(sp)
    80003d62:	e8a2                	sd	s0,80(sp)
    80003d64:	e4a6                	sd	s1,72(sp)
    80003d66:	e0ca                	sd	s2,64(sp)
    80003d68:	fc4e                	sd	s3,56(sp)
    80003d6a:	f852                	sd	s4,48(sp)
    80003d6c:	f456                	sd	s5,40(sp)
    80003d6e:	f05a                	sd	s6,32(sp)
    80003d70:	ec5e                	sd	s7,24(sp)
    80003d72:	e862                	sd	s8,16(sp)
    80003d74:	e466                	sd	s9,8(sp)
    80003d76:	e06a                	sd	s10,0(sp)
    80003d78:	1080                	addi	s0,sp,96
    80003d7a:	84aa                	mv	s1,a0
    80003d7c:	8b2e                	mv	s6,a1
    80003d7e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d80:	00054703          	lbu	a4,0(a0)
    80003d84:	02f00793          	li	a5,47
    80003d88:	00f70f63          	beq	a4,a5,80003da6 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d8c:	babfd0ef          	jal	80001936 <myproc>
    80003d90:	17053503          	ld	a0,368(a0)
    80003d94:	94fff0ef          	jal	800036e2 <idup>
    80003d98:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d9a:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003d9e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003da0:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003da2:	4b85                	li	s7,1
    80003da4:	a879                	j	80003e42 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003da6:	4585                	li	a1,1
    80003da8:	852e                	mv	a0,a1
    80003daa:	efcff0ef          	jal	800034a6 <iget>
    80003dae:	8a2a                	mv	s4,a0
    80003db0:	b7ed                	j	80003d9a <namex+0x3c>
      iunlockput(ip);
    80003db2:	8552                	mv	a0,s4
    80003db4:	b71ff0ef          	jal	80003924 <iunlockput>
      return 0;
    80003db8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003dba:	8552                	mv	a0,s4
    80003dbc:	60e6                	ld	ra,88(sp)
    80003dbe:	6446                	ld	s0,80(sp)
    80003dc0:	64a6                	ld	s1,72(sp)
    80003dc2:	6906                	ld	s2,64(sp)
    80003dc4:	79e2                	ld	s3,56(sp)
    80003dc6:	7a42                	ld	s4,48(sp)
    80003dc8:	7aa2                	ld	s5,40(sp)
    80003dca:	7b02                	ld	s6,32(sp)
    80003dcc:	6be2                	ld	s7,24(sp)
    80003dce:	6c42                	ld	s8,16(sp)
    80003dd0:	6ca2                	ld	s9,8(sp)
    80003dd2:	6d02                	ld	s10,0(sp)
    80003dd4:	6125                	addi	sp,sp,96
    80003dd6:	8082                	ret
      iunlock(ip);
    80003dd8:	8552                	mv	a0,s4
    80003dda:	9edff0ef          	jal	800037c6 <iunlock>
      return ip;
    80003dde:	bff1                	j	80003dba <namex+0x5c>
      iunlockput(ip);
    80003de0:	8552                	mv	a0,s4
    80003de2:	b43ff0ef          	jal	80003924 <iunlockput>
      return 0;
    80003de6:	8a4a                	mv	s4,s2
    80003de8:	bfc9                	j	80003dba <namex+0x5c>
  len = path - s;
    80003dea:	40990633          	sub	a2,s2,s1
    80003dee:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003df2:	09ac5463          	bge	s8,s10,80003e7a <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003df6:	8666                	mv	a2,s9
    80003df8:	85a6                	mv	a1,s1
    80003dfa:	8556                	mv	a0,s5
    80003dfc:	f5dfc0ef          	jal	80000d58 <memmove>
    80003e00:	84ca                	mv	s1,s2
  while(*path == '/')
    80003e02:	0004c783          	lbu	a5,0(s1)
    80003e06:	01379763          	bne	a5,s3,80003e14 <namex+0xb6>
    path++;
    80003e0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e0c:	0004c783          	lbu	a5,0(s1)
    80003e10:	ff378de3          	beq	a5,s3,80003e0a <namex+0xac>
    ilock(ip);
    80003e14:	8552                	mv	a0,s4
    80003e16:	903ff0ef          	jal	80003718 <ilock>
    if(ip->type != T_DIR){
    80003e1a:	044a1783          	lh	a5,68(s4)
    80003e1e:	f9779ae3          	bne	a5,s7,80003db2 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003e22:	000b0563          	beqz	s6,80003e2c <namex+0xce>
    80003e26:	0004c783          	lbu	a5,0(s1)
    80003e2a:	d7dd                	beqz	a5,80003dd8 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e2c:	4601                	li	a2,0
    80003e2e:	85d6                	mv	a1,s5
    80003e30:	8552                	mv	a0,s4
    80003e32:	e81ff0ef          	jal	80003cb2 <dirlookup>
    80003e36:	892a                	mv	s2,a0
    80003e38:	d545                	beqz	a0,80003de0 <namex+0x82>
    iunlockput(ip);
    80003e3a:	8552                	mv	a0,s4
    80003e3c:	ae9ff0ef          	jal	80003924 <iunlockput>
    ip = next;
    80003e40:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003e42:	0004c783          	lbu	a5,0(s1)
    80003e46:	01379763          	bne	a5,s3,80003e54 <namex+0xf6>
    path++;
    80003e4a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e4c:	0004c783          	lbu	a5,0(s1)
    80003e50:	ff378de3          	beq	a5,s3,80003e4a <namex+0xec>
  if(*path == 0)
    80003e54:	cf8d                	beqz	a5,80003e8e <namex+0x130>
  while(*path != '/' && *path != 0)
    80003e56:	0004c783          	lbu	a5,0(s1)
    80003e5a:	fd178713          	addi	a4,a5,-47
    80003e5e:	cb19                	beqz	a4,80003e74 <namex+0x116>
    80003e60:	cb91                	beqz	a5,80003e74 <namex+0x116>
    80003e62:	8926                	mv	s2,s1
    path++;
    80003e64:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003e66:	00094783          	lbu	a5,0(s2)
    80003e6a:	fd178713          	addi	a4,a5,-47
    80003e6e:	df35                	beqz	a4,80003dea <namex+0x8c>
    80003e70:	fbf5                	bnez	a5,80003e64 <namex+0x106>
    80003e72:	bfa5                	j	80003dea <namex+0x8c>
    80003e74:	8926                	mv	s2,s1
  len = path - s;
    80003e76:	4d01                	li	s10,0
    80003e78:	4601                	li	a2,0
    memmove(name, s, len);
    80003e7a:	2601                	sext.w	a2,a2
    80003e7c:	85a6                	mv	a1,s1
    80003e7e:	8556                	mv	a0,s5
    80003e80:	ed9fc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003e84:	9d56                	add	s10,s10,s5
    80003e86:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdd3b0>
    80003e8a:	84ca                	mv	s1,s2
    80003e8c:	bf9d                	j	80003e02 <namex+0xa4>
  if(nameiparent){
    80003e8e:	f20b06e3          	beqz	s6,80003dba <namex+0x5c>
    iput(ip);
    80003e92:	8552                	mv	a0,s4
    80003e94:	a07ff0ef          	jal	8000389a <iput>
    return 0;
    80003e98:	4a01                	li	s4,0
    80003e9a:	b705                	j	80003dba <namex+0x5c>

0000000080003e9c <dirlink>:
{
    80003e9c:	715d                	addi	sp,sp,-80
    80003e9e:	e486                	sd	ra,72(sp)
    80003ea0:	e0a2                	sd	s0,64(sp)
    80003ea2:	f84a                	sd	s2,48(sp)
    80003ea4:	ec56                	sd	s5,24(sp)
    80003ea6:	e85a                	sd	s6,16(sp)
    80003ea8:	0880                	addi	s0,sp,80
    80003eaa:	892a                	mv	s2,a0
    80003eac:	8aae                	mv	s5,a1
    80003eae:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003eb0:	4601                	li	a2,0
    80003eb2:	e01ff0ef          	jal	80003cb2 <dirlookup>
    80003eb6:	ed1d                	bnez	a0,80003ef4 <dirlink+0x58>
    80003eb8:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eba:	04c92483          	lw	s1,76(s2)
    80003ebe:	c4b9                	beqz	s1,80003f0c <dirlink+0x70>
    80003ec0:	f44e                	sd	s3,40(sp)
    80003ec2:	f052                	sd	s4,32(sp)
    80003ec4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ec6:	fb040a13          	addi	s4,s0,-80
    80003eca:	49c1                	li	s3,16
    80003ecc:	874e                	mv	a4,s3
    80003ece:	86a6                	mv	a3,s1
    80003ed0:	8652                	mv	a2,s4
    80003ed2:	4581                	li	a1,0
    80003ed4:	854a                	mv	a0,s2
    80003ed6:	bd5ff0ef          	jal	80003aaa <readi>
    80003eda:	03351163          	bne	a0,s3,80003efc <dirlink+0x60>
    if(de.inum == 0)
    80003ede:	fb045783          	lhu	a5,-80(s0)
    80003ee2:	c39d                	beqz	a5,80003f08 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee4:	24c1                	addiw	s1,s1,16
    80003ee6:	04c92783          	lw	a5,76(s2)
    80003eea:	fef4e1e3          	bltu	s1,a5,80003ecc <dirlink+0x30>
    80003eee:	79a2                	ld	s3,40(sp)
    80003ef0:	7a02                	ld	s4,32(sp)
    80003ef2:	a829                	j	80003f0c <dirlink+0x70>
    iput(ip);
    80003ef4:	9a7ff0ef          	jal	8000389a <iput>
    return -1;
    80003ef8:	557d                	li	a0,-1
    80003efa:	a83d                	j	80003f38 <dirlink+0x9c>
      panic("dirlink read");
    80003efc:	00003517          	auipc	a0,0x3
    80003f00:	63c50513          	addi	a0,a0,1596 # 80007538 <etext+0x538>
    80003f04:	921fc0ef          	jal	80000824 <panic>
    80003f08:	79a2                	ld	s3,40(sp)
    80003f0a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003f0c:	4639                	li	a2,14
    80003f0e:	85d6                	mv	a1,s5
    80003f10:	fb240513          	addi	a0,s0,-78
    80003f14:	ef3fc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003f18:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f1c:	4741                	li	a4,16
    80003f1e:	86a6                	mv	a3,s1
    80003f20:	fb040613          	addi	a2,s0,-80
    80003f24:	4581                	li	a1,0
    80003f26:	854a                	mv	a0,s2
    80003f28:	c75ff0ef          	jal	80003b9c <writei>
    80003f2c:	1541                	addi	a0,a0,-16
    80003f2e:	00a03533          	snez	a0,a0
    80003f32:	40a0053b          	negw	a0,a0
    80003f36:	74e2                	ld	s1,56(sp)
}
    80003f38:	60a6                	ld	ra,72(sp)
    80003f3a:	6406                	ld	s0,64(sp)
    80003f3c:	7942                	ld	s2,48(sp)
    80003f3e:	6ae2                	ld	s5,24(sp)
    80003f40:	6b42                	ld	s6,16(sp)
    80003f42:	6161                	addi	sp,sp,80
    80003f44:	8082                	ret

0000000080003f46 <namei>:

struct inode*
namei(char *path)
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f4e:	fe040613          	addi	a2,s0,-32
    80003f52:	4581                	li	a1,0
    80003f54:	e0bff0ef          	jal	80003d5e <namex>
}
    80003f58:	60e2                	ld	ra,24(sp)
    80003f5a:	6442                	ld	s0,16(sp)
    80003f5c:	6105                	addi	sp,sp,32
    80003f5e:	8082                	ret

0000000080003f60 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f60:	1141                	addi	sp,sp,-16
    80003f62:	e406                	sd	ra,8(sp)
    80003f64:	e022                	sd	s0,0(sp)
    80003f66:	0800                	addi	s0,sp,16
    80003f68:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f6a:	4585                	li	a1,1
    80003f6c:	df3ff0ef          	jal	80003d5e <namex>
}
    80003f70:	60a2                	ld	ra,8(sp)
    80003f72:	6402                	ld	s0,0(sp)
    80003f74:	0141                	addi	sp,sp,16
    80003f76:	8082                	ret

0000000080003f78 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f78:	1101                	addi	sp,sp,-32
    80003f7a:	ec06                	sd	ra,24(sp)
    80003f7c:	e822                	sd	s0,16(sp)
    80003f7e:	e426                	sd	s1,8(sp)
    80003f80:	e04a                	sd	s2,0(sp)
    80003f82:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f84:	0001d917          	auipc	s2,0x1d
    80003f88:	a8c90913          	addi	s2,s2,-1396 # 80020a10 <log>
    80003f8c:	01892583          	lw	a1,24(s2)
    80003f90:	02492503          	lw	a0,36(s2)
    80003f94:	8ecff0ef          	jal	80003080 <bread>
    80003f98:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f9a:	02892603          	lw	a2,40(s2)
    80003f9e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fa0:	00c05f63          	blez	a2,80003fbe <write_head+0x46>
    80003fa4:	0001d717          	auipc	a4,0x1d
    80003fa8:	a9870713          	addi	a4,a4,-1384 # 80020a3c <log+0x2c>
    80003fac:	87aa                	mv	a5,a0
    80003fae:	060a                	slli	a2,a2,0x2
    80003fb0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fb2:	4314                	lw	a3,0(a4)
    80003fb4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fb6:	0711                	addi	a4,a4,4
    80003fb8:	0791                	addi	a5,a5,4
    80003fba:	fec79ce3          	bne	a5,a2,80003fb2 <write_head+0x3a>
  }
  bwrite(buf);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	996ff0ef          	jal	80003156 <bwrite>
  brelse(buf);
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	9c2ff0ef          	jal	80003188 <brelse>
}
    80003fca:	60e2                	ld	ra,24(sp)
    80003fcc:	6442                	ld	s0,16(sp)
    80003fce:	64a2                	ld	s1,8(sp)
    80003fd0:	6902                	ld	s2,0(sp)
    80003fd2:	6105                	addi	sp,sp,32
    80003fd4:	8082                	ret

0000000080003fd6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd6:	0001d797          	auipc	a5,0x1d
    80003fda:	a627a783          	lw	a5,-1438(a5) # 80020a38 <log+0x28>
    80003fde:	0cf05163          	blez	a5,800040a0 <install_trans+0xca>
{
    80003fe2:	715d                	addi	sp,sp,-80
    80003fe4:	e486                	sd	ra,72(sp)
    80003fe6:	e0a2                	sd	s0,64(sp)
    80003fe8:	fc26                	sd	s1,56(sp)
    80003fea:	f84a                	sd	s2,48(sp)
    80003fec:	f44e                	sd	s3,40(sp)
    80003fee:	f052                	sd	s4,32(sp)
    80003ff0:	ec56                	sd	s5,24(sp)
    80003ff2:	e85a                	sd	s6,16(sp)
    80003ff4:	e45e                	sd	s7,8(sp)
    80003ff6:	e062                	sd	s8,0(sp)
    80003ff8:	0880                	addi	s0,sp,80
    80003ffa:	8b2a                	mv	s6,a0
    80003ffc:	0001da97          	auipc	s5,0x1d
    80004000:	a40a8a93          	addi	s5,s5,-1472 # 80020a3c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004004:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004006:	00003c17          	auipc	s8,0x3
    8000400a:	542c0c13          	addi	s8,s8,1346 # 80007548 <etext+0x548>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000400e:	0001da17          	auipc	s4,0x1d
    80004012:	a02a0a13          	addi	s4,s4,-1534 # 80020a10 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004016:	40000b93          	li	s7,1024
    8000401a:	a025                	j	80004042 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000401c:	000aa603          	lw	a2,0(s5)
    80004020:	85ce                	mv	a1,s3
    80004022:	8562                	mv	a0,s8
    80004024:	cd6fc0ef          	jal	800004fa <printf>
    80004028:	a839                	j	80004046 <install_trans+0x70>
    brelse(lbuf);
    8000402a:	854a                	mv	a0,s2
    8000402c:	95cff0ef          	jal	80003188 <brelse>
    brelse(dbuf);
    80004030:	8526                	mv	a0,s1
    80004032:	956ff0ef          	jal	80003188 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004036:	2985                	addiw	s3,s3,1
    80004038:	0a91                	addi	s5,s5,4
    8000403a:	028a2783          	lw	a5,40(s4)
    8000403e:	04f9d563          	bge	s3,a5,80004088 <install_trans+0xb2>
    if(recovering) {
    80004042:	fc0b1de3          	bnez	s6,8000401c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004046:	018a2583          	lw	a1,24(s4)
    8000404a:	013585bb          	addw	a1,a1,s3
    8000404e:	2585                	addiw	a1,a1,1
    80004050:	024a2503          	lw	a0,36(s4)
    80004054:	82cff0ef          	jal	80003080 <bread>
    80004058:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000405a:	000aa583          	lw	a1,0(s5)
    8000405e:	024a2503          	lw	a0,36(s4)
    80004062:	81eff0ef          	jal	80003080 <bread>
    80004066:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004068:	865e                	mv	a2,s7
    8000406a:	05890593          	addi	a1,s2,88
    8000406e:	05850513          	addi	a0,a0,88
    80004072:	ce7fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004076:	8526                	mv	a0,s1
    80004078:	8deff0ef          	jal	80003156 <bwrite>
    if(recovering == 0)
    8000407c:	fa0b17e3          	bnez	s6,8000402a <install_trans+0x54>
      bunpin(dbuf);
    80004080:	8526                	mv	a0,s1
    80004082:	9beff0ef          	jal	80003240 <bunpin>
    80004086:	b755                	j	8000402a <install_trans+0x54>
}
    80004088:	60a6                	ld	ra,72(sp)
    8000408a:	6406                	ld	s0,64(sp)
    8000408c:	74e2                	ld	s1,56(sp)
    8000408e:	7942                	ld	s2,48(sp)
    80004090:	79a2                	ld	s3,40(sp)
    80004092:	7a02                	ld	s4,32(sp)
    80004094:	6ae2                	ld	s5,24(sp)
    80004096:	6b42                	ld	s6,16(sp)
    80004098:	6ba2                	ld	s7,8(sp)
    8000409a:	6c02                	ld	s8,0(sp)
    8000409c:	6161                	addi	sp,sp,80
    8000409e:	8082                	ret
    800040a0:	8082                	ret

00000000800040a2 <initlog>:
{
    800040a2:	7179                	addi	sp,sp,-48
    800040a4:	f406                	sd	ra,40(sp)
    800040a6:	f022                	sd	s0,32(sp)
    800040a8:	ec26                	sd	s1,24(sp)
    800040aa:	e84a                	sd	s2,16(sp)
    800040ac:	e44e                	sd	s3,8(sp)
    800040ae:	1800                	addi	s0,sp,48
    800040b0:	84aa                	mv	s1,a0
    800040b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040b4:	0001d917          	auipc	s2,0x1d
    800040b8:	95c90913          	addi	s2,s2,-1700 # 80020a10 <log>
    800040bc:	00003597          	auipc	a1,0x3
    800040c0:	4ac58593          	addi	a1,a1,1196 # 80007568 <etext+0x568>
    800040c4:	854a                	mv	a0,s2
    800040c6:	ad9fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    800040ca:	0149a583          	lw	a1,20(s3)
    800040ce:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800040d2:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800040d6:	8526                	mv	a0,s1
    800040d8:	fa9fe0ef          	jal	80003080 <bread>
  log.lh.n = lh->n;
    800040dc:	4d30                	lw	a2,88(a0)
    800040de:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800040e2:	00c05f63          	blez	a2,80004100 <initlog+0x5e>
    800040e6:	87aa                	mv	a5,a0
    800040e8:	0001d717          	auipc	a4,0x1d
    800040ec:	95470713          	addi	a4,a4,-1708 # 80020a3c <log+0x2c>
    800040f0:	060a                	slli	a2,a2,0x2
    800040f2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040f4:	4ff4                	lw	a3,92(a5)
    800040f6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040f8:	0791                	addi	a5,a5,4
    800040fa:	0711                	addi	a4,a4,4
    800040fc:	fec79ce3          	bne	a5,a2,800040f4 <initlog+0x52>
  brelse(buf);
    80004100:	888ff0ef          	jal	80003188 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004104:	4505                	li	a0,1
    80004106:	ed1ff0ef          	jal	80003fd6 <install_trans>
  log.lh.n = 0;
    8000410a:	0001d797          	auipc	a5,0x1d
    8000410e:	9207a723          	sw	zero,-1746(a5) # 80020a38 <log+0x28>
  write_head(); // clear the log
    80004112:	e67ff0ef          	jal	80003f78 <write_head>
}
    80004116:	70a2                	ld	ra,40(sp)
    80004118:	7402                	ld	s0,32(sp)
    8000411a:	64e2                	ld	s1,24(sp)
    8000411c:	6942                	ld	s2,16(sp)
    8000411e:	69a2                	ld	s3,8(sp)
    80004120:	6145                	addi	sp,sp,48
    80004122:	8082                	ret

0000000080004124 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004124:	1101                	addi	sp,sp,-32
    80004126:	ec06                	sd	ra,24(sp)
    80004128:	e822                	sd	s0,16(sp)
    8000412a:	e426                	sd	s1,8(sp)
    8000412c:	e04a                	sd	s2,0(sp)
    8000412e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004130:	0001d517          	auipc	a0,0x1d
    80004134:	8e050513          	addi	a0,a0,-1824 # 80020a10 <log>
    80004138:	af1fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    8000413c:	0001d497          	auipc	s1,0x1d
    80004140:	8d448493          	addi	s1,s1,-1836 # 80020a10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004144:	4979                	li	s2,30
    80004146:	a029                	j	80004150 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004148:	85a6                	mv	a1,s1
    8000414a:	8526                	mv	a0,s1
    8000414c:	bfbfd0ef          	jal	80001d46 <sleep>
    if(log.committing){
    80004150:	509c                	lw	a5,32(s1)
    80004152:	fbfd                	bnez	a5,80004148 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004154:	4cd8                	lw	a4,28(s1)
    80004156:	2705                	addiw	a4,a4,1
    80004158:	0027179b          	slliw	a5,a4,0x2
    8000415c:	9fb9                	addw	a5,a5,a4
    8000415e:	0017979b          	slliw	a5,a5,0x1
    80004162:	5494                	lw	a3,40(s1)
    80004164:	9fb5                	addw	a5,a5,a3
    80004166:	00f95763          	bge	s2,a5,80004174 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000416a:	85a6                	mv	a1,s1
    8000416c:	8526                	mv	a0,s1
    8000416e:	bd9fd0ef          	jal	80001d46 <sleep>
    80004172:	bff9                	j	80004150 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004174:	0001d797          	auipc	a5,0x1d
    80004178:	8ae7ac23          	sw	a4,-1864(a5) # 80020a2c <log+0x1c>
      release(&log.lock);
    8000417c:	0001d517          	auipc	a0,0x1d
    80004180:	89450513          	addi	a0,a0,-1900 # 80020a10 <log>
    80004184:	b39fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80004188:	60e2                	ld	ra,24(sp)
    8000418a:	6442                	ld	s0,16(sp)
    8000418c:	64a2                	ld	s1,8(sp)
    8000418e:	6902                	ld	s2,0(sp)
    80004190:	6105                	addi	sp,sp,32
    80004192:	8082                	ret

0000000080004194 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004194:	7139                	addi	sp,sp,-64
    80004196:	fc06                	sd	ra,56(sp)
    80004198:	f822                	sd	s0,48(sp)
    8000419a:	f426                	sd	s1,40(sp)
    8000419c:	f04a                	sd	s2,32(sp)
    8000419e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041a0:	0001d497          	auipc	s1,0x1d
    800041a4:	87048493          	addi	s1,s1,-1936 # 80020a10 <log>
    800041a8:	8526                	mv	a0,s1
    800041aa:	a7ffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    800041ae:	4cdc                	lw	a5,28(s1)
    800041b0:	37fd                	addiw	a5,a5,-1
    800041b2:	893e                	mv	s2,a5
    800041b4:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800041b6:	509c                	lw	a5,32(s1)
    800041b8:	e7b1                	bnez	a5,80004204 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    800041ba:	04091e63          	bnez	s2,80004216 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800041be:	0001d497          	auipc	s1,0x1d
    800041c2:	85248493          	addi	s1,s1,-1966 # 80020a10 <log>
    800041c6:	4785                	li	a5,1
    800041c8:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041ca:	8526                	mv	a0,s1
    800041cc:	af1fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041d0:	549c                	lw	a5,40(s1)
    800041d2:	06f04463          	bgtz	a5,8000423a <end_op+0xa6>
    acquire(&log.lock);
    800041d6:	0001d517          	auipc	a0,0x1d
    800041da:	83a50513          	addi	a0,a0,-1990 # 80020a10 <log>
    800041de:	a4bfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    800041e2:	0001d797          	auipc	a5,0x1d
    800041e6:	8407a723          	sw	zero,-1970(a5) # 80020a30 <log+0x20>
    wakeup(&log);
    800041ea:	0001d517          	auipc	a0,0x1d
    800041ee:	82650513          	addi	a0,a0,-2010 # 80020a10 <log>
    800041f2:	a94fe0ef          	jal	80002486 <wakeup>
    release(&log.lock);
    800041f6:	0001d517          	auipc	a0,0x1d
    800041fa:	81a50513          	addi	a0,a0,-2022 # 80020a10 <log>
    800041fe:	abffc0ef          	jal	80000cbc <release>
}
    80004202:	a035                	j	8000422e <end_op+0x9a>
    80004204:	ec4e                	sd	s3,24(sp)
    80004206:	e852                	sd	s4,16(sp)
    80004208:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000420a:	00003517          	auipc	a0,0x3
    8000420e:	36650513          	addi	a0,a0,870 # 80007570 <etext+0x570>
    80004212:	e12fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80004216:	0001c517          	auipc	a0,0x1c
    8000421a:	7fa50513          	addi	a0,a0,2042 # 80020a10 <log>
    8000421e:	a68fe0ef          	jal	80002486 <wakeup>
  release(&log.lock);
    80004222:	0001c517          	auipc	a0,0x1c
    80004226:	7ee50513          	addi	a0,a0,2030 # 80020a10 <log>
    8000422a:	a93fc0ef          	jal	80000cbc <release>
}
    8000422e:	70e2                	ld	ra,56(sp)
    80004230:	7442                	ld	s0,48(sp)
    80004232:	74a2                	ld	s1,40(sp)
    80004234:	7902                	ld	s2,32(sp)
    80004236:	6121                	addi	sp,sp,64
    80004238:	8082                	ret
    8000423a:	ec4e                	sd	s3,24(sp)
    8000423c:	e852                	sd	s4,16(sp)
    8000423e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004240:	0001ca97          	auipc	s5,0x1c
    80004244:	7fca8a93          	addi	s5,s5,2044 # 80020a3c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004248:	0001ca17          	auipc	s4,0x1c
    8000424c:	7c8a0a13          	addi	s4,s4,1992 # 80020a10 <log>
    80004250:	018a2583          	lw	a1,24(s4)
    80004254:	012585bb          	addw	a1,a1,s2
    80004258:	2585                	addiw	a1,a1,1
    8000425a:	024a2503          	lw	a0,36(s4)
    8000425e:	e23fe0ef          	jal	80003080 <bread>
    80004262:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004264:	000aa583          	lw	a1,0(s5)
    80004268:	024a2503          	lw	a0,36(s4)
    8000426c:	e15fe0ef          	jal	80003080 <bread>
    80004270:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004272:	40000613          	li	a2,1024
    80004276:	05850593          	addi	a1,a0,88
    8000427a:	05848513          	addi	a0,s1,88
    8000427e:	adbfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80004282:	8526                	mv	a0,s1
    80004284:	ed3fe0ef          	jal	80003156 <bwrite>
    brelse(from);
    80004288:	854e                	mv	a0,s3
    8000428a:	efffe0ef          	jal	80003188 <brelse>
    brelse(to);
    8000428e:	8526                	mv	a0,s1
    80004290:	ef9fe0ef          	jal	80003188 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004294:	2905                	addiw	s2,s2,1
    80004296:	0a91                	addi	s5,s5,4
    80004298:	028a2783          	lw	a5,40(s4)
    8000429c:	faf94ae3          	blt	s2,a5,80004250 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042a0:	cd9ff0ef          	jal	80003f78 <write_head>
    install_trans(0); // Now install writes to home locations
    800042a4:	4501                	li	a0,0
    800042a6:	d31ff0ef          	jal	80003fd6 <install_trans>
    log.lh.n = 0;
    800042aa:	0001c797          	auipc	a5,0x1c
    800042ae:	7807a723          	sw	zero,1934(a5) # 80020a38 <log+0x28>
    write_head();    // Erase the transaction from the log
    800042b2:	cc7ff0ef          	jal	80003f78 <write_head>
    800042b6:	69e2                	ld	s3,24(sp)
    800042b8:	6a42                	ld	s4,16(sp)
    800042ba:	6aa2                	ld	s5,8(sp)
    800042bc:	bf29                	j	800041d6 <end_op+0x42>

00000000800042be <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042be:	1101                	addi	sp,sp,-32
    800042c0:	ec06                	sd	ra,24(sp)
    800042c2:	e822                	sd	s0,16(sp)
    800042c4:	e426                	sd	s1,8(sp)
    800042c6:	1000                	addi	s0,sp,32
    800042c8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042ca:	0001c517          	auipc	a0,0x1c
    800042ce:	74650513          	addi	a0,a0,1862 # 80020a10 <log>
    800042d2:	957fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800042d6:	0001c617          	auipc	a2,0x1c
    800042da:	76262603          	lw	a2,1890(a2) # 80020a38 <log+0x28>
    800042de:	47f5                	li	a5,29
    800042e0:	04c7cd63          	blt	a5,a2,8000433a <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042e4:	0001c797          	auipc	a5,0x1c
    800042e8:	7487a783          	lw	a5,1864(a5) # 80020a2c <log+0x1c>
    800042ec:	04f05d63          	blez	a5,80004346 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042f0:	4781                	li	a5,0
    800042f2:	06c05063          	blez	a2,80004352 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042f6:	44cc                	lw	a1,12(s1)
    800042f8:	0001c717          	auipc	a4,0x1c
    800042fc:	74470713          	addi	a4,a4,1860 # 80020a3c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004300:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004302:	4314                	lw	a3,0(a4)
    80004304:	04b68763          	beq	a3,a1,80004352 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004308:	2785                	addiw	a5,a5,1
    8000430a:	0711                	addi	a4,a4,4
    8000430c:	fef61be3          	bne	a2,a5,80004302 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004310:	060a                	slli	a2,a2,0x2
    80004312:	02060613          	addi	a2,a2,32
    80004316:	0001c797          	auipc	a5,0x1c
    8000431a:	6fa78793          	addi	a5,a5,1786 # 80020a10 <log>
    8000431e:	97b2                	add	a5,a5,a2
    80004320:	44d8                	lw	a4,12(s1)
    80004322:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004324:	8526                	mv	a0,s1
    80004326:	ee7fe0ef          	jal	8000320c <bpin>
    log.lh.n++;
    8000432a:	0001c717          	auipc	a4,0x1c
    8000432e:	6e670713          	addi	a4,a4,1766 # 80020a10 <log>
    80004332:	571c                	lw	a5,40(a4)
    80004334:	2785                	addiw	a5,a5,1
    80004336:	d71c                	sw	a5,40(a4)
    80004338:	a815                	j	8000436c <log_write+0xae>
    panic("too big a transaction");
    8000433a:	00003517          	auipc	a0,0x3
    8000433e:	24650513          	addi	a0,a0,582 # 80007580 <etext+0x580>
    80004342:	ce2fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80004346:	00003517          	auipc	a0,0x3
    8000434a:	25250513          	addi	a0,a0,594 # 80007598 <etext+0x598>
    8000434e:	cd6fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80004352:	00279693          	slli	a3,a5,0x2
    80004356:	02068693          	addi	a3,a3,32
    8000435a:	0001c717          	auipc	a4,0x1c
    8000435e:	6b670713          	addi	a4,a4,1718 # 80020a10 <log>
    80004362:	9736                	add	a4,a4,a3
    80004364:	44d4                	lw	a3,12(s1)
    80004366:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004368:	faf60ee3          	beq	a2,a5,80004324 <log_write+0x66>
  }
  release(&log.lock);
    8000436c:	0001c517          	auipc	a0,0x1c
    80004370:	6a450513          	addi	a0,a0,1700 # 80020a10 <log>
    80004374:	949fc0ef          	jal	80000cbc <release>
}
    80004378:	60e2                	ld	ra,24(sp)
    8000437a:	6442                	ld	s0,16(sp)
    8000437c:	64a2                	ld	s1,8(sp)
    8000437e:	6105                	addi	sp,sp,32
    80004380:	8082                	ret

0000000080004382 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004382:	1101                	addi	sp,sp,-32
    80004384:	ec06                	sd	ra,24(sp)
    80004386:	e822                	sd	s0,16(sp)
    80004388:	e426                	sd	s1,8(sp)
    8000438a:	e04a                	sd	s2,0(sp)
    8000438c:	1000                	addi	s0,sp,32
    8000438e:	84aa                	mv	s1,a0
    80004390:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004392:	00003597          	auipc	a1,0x3
    80004396:	22658593          	addi	a1,a1,550 # 800075b8 <etext+0x5b8>
    8000439a:	0521                	addi	a0,a0,8
    8000439c:	803fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    800043a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a8:	0204a423          	sw	zero,40(s1)
}
    800043ac:	60e2                	ld	ra,24(sp)
    800043ae:	6442                	ld	s0,16(sp)
    800043b0:	64a2                	ld	s1,8(sp)
    800043b2:	6902                	ld	s2,0(sp)
    800043b4:	6105                	addi	sp,sp,32
    800043b6:	8082                	ret

00000000800043b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043b8:	1101                	addi	sp,sp,-32
    800043ba:	ec06                	sd	ra,24(sp)
    800043bc:	e822                	sd	s0,16(sp)
    800043be:	e426                	sd	s1,8(sp)
    800043c0:	e04a                	sd	s2,0(sp)
    800043c2:	1000                	addi	s0,sp,32
    800043c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c6:	00850913          	addi	s2,a0,8
    800043ca:	854a                	mv	a0,s2
    800043cc:	85dfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800043d0:	409c                	lw	a5,0(s1)
    800043d2:	c799                	beqz	a5,800043e0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800043d4:	85ca                	mv	a1,s2
    800043d6:	8526                	mv	a0,s1
    800043d8:	96ffd0ef          	jal	80001d46 <sleep>
  while (lk->locked) {
    800043dc:	409c                	lw	a5,0(s1)
    800043de:	fbfd                	bnez	a5,800043d4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800043e0:	4785                	li	a5,1
    800043e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043e4:	d52fd0ef          	jal	80001936 <myproc>
    800043e8:	591c                	lw	a5,48(a0)
    800043ea:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ec:	854a                	mv	a0,s2
    800043ee:	8cffc0ef          	jal	80000cbc <release>
}
    800043f2:	60e2                	ld	ra,24(sp)
    800043f4:	6442                	ld	s0,16(sp)
    800043f6:	64a2                	ld	s1,8(sp)
    800043f8:	6902                	ld	s2,0(sp)
    800043fa:	6105                	addi	sp,sp,32
    800043fc:	8082                	ret

00000000800043fe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043fe:	1101                	addi	sp,sp,-32
    80004400:	ec06                	sd	ra,24(sp)
    80004402:	e822                	sd	s0,16(sp)
    80004404:	e426                	sd	s1,8(sp)
    80004406:	e04a                	sd	s2,0(sp)
    80004408:	1000                	addi	s0,sp,32
    8000440a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000440c:	00850913          	addi	s2,a0,8
    80004410:	854a                	mv	a0,s2
    80004412:	817fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004416:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000441a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000441e:	8526                	mv	a0,s1
    80004420:	866fe0ef          	jal	80002486 <wakeup>
  release(&lk->lk);
    80004424:	854a                	mv	a0,s2
    80004426:	897fc0ef          	jal	80000cbc <release>
}
    8000442a:	60e2                	ld	ra,24(sp)
    8000442c:	6442                	ld	s0,16(sp)
    8000442e:	64a2                	ld	s1,8(sp)
    80004430:	6902                	ld	s2,0(sp)
    80004432:	6105                	addi	sp,sp,32
    80004434:	8082                	ret

0000000080004436 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004436:	7179                	addi	sp,sp,-48
    80004438:	f406                	sd	ra,40(sp)
    8000443a:	f022                	sd	s0,32(sp)
    8000443c:	ec26                	sd	s1,24(sp)
    8000443e:	e84a                	sd	s2,16(sp)
    80004440:	1800                	addi	s0,sp,48
    80004442:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004444:	00850913          	addi	s2,a0,8
    80004448:	854a                	mv	a0,s2
    8000444a:	fdefc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000444e:	409c                	lw	a5,0(s1)
    80004450:	ef81                	bnez	a5,80004468 <holdingsleep+0x32>
    80004452:	4481                	li	s1,0
  release(&lk->lk);
    80004454:	854a                	mv	a0,s2
    80004456:	867fc0ef          	jal	80000cbc <release>
  return r;
}
    8000445a:	8526                	mv	a0,s1
    8000445c:	70a2                	ld	ra,40(sp)
    8000445e:	7402                	ld	s0,32(sp)
    80004460:	64e2                	ld	s1,24(sp)
    80004462:	6942                	ld	s2,16(sp)
    80004464:	6145                	addi	sp,sp,48
    80004466:	8082                	ret
    80004468:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000446a:	0284a983          	lw	s3,40(s1)
    8000446e:	cc8fd0ef          	jal	80001936 <myproc>
    80004472:	5904                	lw	s1,48(a0)
    80004474:	413484b3          	sub	s1,s1,s3
    80004478:	0014b493          	seqz	s1,s1
    8000447c:	69a2                	ld	s3,8(sp)
    8000447e:	bfd9                	j	80004454 <holdingsleep+0x1e>

0000000080004480 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004480:	1141                	addi	sp,sp,-16
    80004482:	e406                	sd	ra,8(sp)
    80004484:	e022                	sd	s0,0(sp)
    80004486:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004488:	00003597          	auipc	a1,0x3
    8000448c:	14058593          	addi	a1,a1,320 # 800075c8 <etext+0x5c8>
    80004490:	0001c517          	auipc	a0,0x1c
    80004494:	6c850513          	addi	a0,a0,1736 # 80020b58 <ftable>
    80004498:	f06fc0ef          	jal	80000b9e <initlock>
}
    8000449c:	60a2                	ld	ra,8(sp)
    8000449e:	6402                	ld	s0,0(sp)
    800044a0:	0141                	addi	sp,sp,16
    800044a2:	8082                	ret

00000000800044a4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044a4:	1101                	addi	sp,sp,-32
    800044a6:	ec06                	sd	ra,24(sp)
    800044a8:	e822                	sd	s0,16(sp)
    800044aa:	e426                	sd	s1,8(sp)
    800044ac:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044ae:	0001c517          	auipc	a0,0x1c
    800044b2:	6aa50513          	addi	a0,a0,1706 # 80020b58 <ftable>
    800044b6:	f72fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ba:	0001c497          	auipc	s1,0x1c
    800044be:	6b648493          	addi	s1,s1,1718 # 80020b70 <ftable+0x18>
    800044c2:	0001d717          	auipc	a4,0x1d
    800044c6:	64e70713          	addi	a4,a4,1614 # 80021b10 <disk>
    if(f->ref == 0){
    800044ca:	40dc                	lw	a5,4(s1)
    800044cc:	cf89                	beqz	a5,800044e6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ce:	02848493          	addi	s1,s1,40
    800044d2:	fee49ce3          	bne	s1,a4,800044ca <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044d6:	0001c517          	auipc	a0,0x1c
    800044da:	68250513          	addi	a0,a0,1666 # 80020b58 <ftable>
    800044de:	fdefc0ef          	jal	80000cbc <release>
  return 0;
    800044e2:	4481                	li	s1,0
    800044e4:	a809                	j	800044f6 <filealloc+0x52>
      f->ref = 1;
    800044e6:	4785                	li	a5,1
    800044e8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044ea:	0001c517          	auipc	a0,0x1c
    800044ee:	66e50513          	addi	a0,a0,1646 # 80020b58 <ftable>
    800044f2:	fcafc0ef          	jal	80000cbc <release>
}
    800044f6:	8526                	mv	a0,s1
    800044f8:	60e2                	ld	ra,24(sp)
    800044fa:	6442                	ld	s0,16(sp)
    800044fc:	64a2                	ld	s1,8(sp)
    800044fe:	6105                	addi	sp,sp,32
    80004500:	8082                	ret

0000000080004502 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004502:	1101                	addi	sp,sp,-32
    80004504:	ec06                	sd	ra,24(sp)
    80004506:	e822                	sd	s0,16(sp)
    80004508:	e426                	sd	s1,8(sp)
    8000450a:	1000                	addi	s0,sp,32
    8000450c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000450e:	0001c517          	auipc	a0,0x1c
    80004512:	64a50513          	addi	a0,a0,1610 # 80020b58 <ftable>
    80004516:	f12fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000451a:	40dc                	lw	a5,4(s1)
    8000451c:	02f05063          	blez	a5,8000453c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004520:	2785                	addiw	a5,a5,1
    80004522:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004524:	0001c517          	auipc	a0,0x1c
    80004528:	63450513          	addi	a0,a0,1588 # 80020b58 <ftable>
    8000452c:	f90fc0ef          	jal	80000cbc <release>
  return f;
}
    80004530:	8526                	mv	a0,s1
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret
    panic("filedup");
    8000453c:	00003517          	auipc	a0,0x3
    80004540:	09450513          	addi	a0,a0,148 # 800075d0 <etext+0x5d0>
    80004544:	ae0fc0ef          	jal	80000824 <panic>

0000000080004548 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004548:	7139                	addi	sp,sp,-64
    8000454a:	fc06                	sd	ra,56(sp)
    8000454c:	f822                	sd	s0,48(sp)
    8000454e:	f426                	sd	s1,40(sp)
    80004550:	0080                	addi	s0,sp,64
    80004552:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004554:	0001c517          	auipc	a0,0x1c
    80004558:	60450513          	addi	a0,a0,1540 # 80020b58 <ftable>
    8000455c:	eccfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004560:	40dc                	lw	a5,4(s1)
    80004562:	04f05a63          	blez	a5,800045b6 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004566:	37fd                	addiw	a5,a5,-1
    80004568:	c0dc                	sw	a5,4(s1)
    8000456a:	06f04063          	bgtz	a5,800045ca <fileclose+0x82>
    8000456e:	f04a                	sd	s2,32(sp)
    80004570:	ec4e                	sd	s3,24(sp)
    80004572:	e852                	sd	s4,16(sp)
    80004574:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004576:	0004a903          	lw	s2,0(s1)
    8000457a:	0094c783          	lbu	a5,9(s1)
    8000457e:	89be                	mv	s3,a5
    80004580:	689c                	ld	a5,16(s1)
    80004582:	8a3e                	mv	s4,a5
    80004584:	6c9c                	ld	a5,24(s1)
    80004586:	8abe                	mv	s5,a5
  f->ref = 0;
    80004588:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000458c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004590:	0001c517          	auipc	a0,0x1c
    80004594:	5c850513          	addi	a0,a0,1480 # 80020b58 <ftable>
    80004598:	f24fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    8000459c:	4785                	li	a5,1
    8000459e:	04f90163          	beq	s2,a5,800045e0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045a2:	ffe9079b          	addiw	a5,s2,-2
    800045a6:	4705                	li	a4,1
    800045a8:	04f77563          	bgeu	a4,a5,800045f2 <fileclose+0xaa>
    800045ac:	7902                	ld	s2,32(sp)
    800045ae:	69e2                	ld	s3,24(sp)
    800045b0:	6a42                	ld	s4,16(sp)
    800045b2:	6aa2                	ld	s5,8(sp)
    800045b4:	a00d                	j	800045d6 <fileclose+0x8e>
    800045b6:	f04a                	sd	s2,32(sp)
    800045b8:	ec4e                	sd	s3,24(sp)
    800045ba:	e852                	sd	s4,16(sp)
    800045bc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800045be:	00003517          	auipc	a0,0x3
    800045c2:	01a50513          	addi	a0,a0,26 # 800075d8 <etext+0x5d8>
    800045c6:	a5efc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800045ca:	0001c517          	auipc	a0,0x1c
    800045ce:	58e50513          	addi	a0,a0,1422 # 80020b58 <ftable>
    800045d2:	eeafc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800045d6:	70e2                	ld	ra,56(sp)
    800045d8:	7442                	ld	s0,48(sp)
    800045da:	74a2                	ld	s1,40(sp)
    800045dc:	6121                	addi	sp,sp,64
    800045de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045e0:	85ce                	mv	a1,s3
    800045e2:	8552                	mv	a0,s4
    800045e4:	348000ef          	jal	8000492c <pipeclose>
    800045e8:	7902                	ld	s2,32(sp)
    800045ea:	69e2                	ld	s3,24(sp)
    800045ec:	6a42                	ld	s4,16(sp)
    800045ee:	6aa2                	ld	s5,8(sp)
    800045f0:	b7dd                	j	800045d6 <fileclose+0x8e>
    begin_op();
    800045f2:	b33ff0ef          	jal	80004124 <begin_op>
    iput(ff.ip);
    800045f6:	8556                	mv	a0,s5
    800045f8:	aa2ff0ef          	jal	8000389a <iput>
    end_op();
    800045fc:	b99ff0ef          	jal	80004194 <end_op>
    80004600:	7902                	ld	s2,32(sp)
    80004602:	69e2                	ld	s3,24(sp)
    80004604:	6a42                	ld	s4,16(sp)
    80004606:	6aa2                	ld	s5,8(sp)
    80004608:	b7f9                	j	800045d6 <fileclose+0x8e>

000000008000460a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000460a:	715d                	addi	sp,sp,-80
    8000460c:	e486                	sd	ra,72(sp)
    8000460e:	e0a2                	sd	s0,64(sp)
    80004610:	fc26                	sd	s1,56(sp)
    80004612:	f052                	sd	s4,32(sp)
    80004614:	0880                	addi	s0,sp,80
    80004616:	84aa                	mv	s1,a0
    80004618:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000461a:	b1cfd0ef          	jal	80001936 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000461e:	409c                	lw	a5,0(s1)
    80004620:	37f9                	addiw	a5,a5,-2
    80004622:	4705                	li	a4,1
    80004624:	04f76263          	bltu	a4,a5,80004668 <filestat+0x5e>
    80004628:	f84a                	sd	s2,48(sp)
    8000462a:	f44e                	sd	s3,40(sp)
    8000462c:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000462e:	6c88                	ld	a0,24(s1)
    80004630:	8e8ff0ef          	jal	80003718 <ilock>
    stati(f->ip, &st);
    80004634:	fb840913          	addi	s2,s0,-72
    80004638:	85ca                	mv	a1,s2
    8000463a:	6c88                	ld	a0,24(s1)
    8000463c:	c40ff0ef          	jal	80003a7c <stati>
    iunlock(f->ip);
    80004640:	6c88                	ld	a0,24(s1)
    80004642:	984ff0ef          	jal	800037c6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004646:	46e1                	li	a3,24
    80004648:	864a                	mv	a2,s2
    8000464a:	85d2                	mv	a1,s4
    8000464c:	0709b503          	ld	a0,112(s3)
    80004650:	804fd0ef          	jal	80001654 <copyout>
    80004654:	41f5551b          	sraiw	a0,a0,0x1f
    80004658:	7942                	ld	s2,48(sp)
    8000465a:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000465c:	60a6                	ld	ra,72(sp)
    8000465e:	6406                	ld	s0,64(sp)
    80004660:	74e2                	ld	s1,56(sp)
    80004662:	7a02                	ld	s4,32(sp)
    80004664:	6161                	addi	sp,sp,80
    80004666:	8082                	ret
  return -1;
    80004668:	557d                	li	a0,-1
    8000466a:	bfcd                	j	8000465c <filestat+0x52>

000000008000466c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000466c:	7179                	addi	sp,sp,-48
    8000466e:	f406                	sd	ra,40(sp)
    80004670:	f022                	sd	s0,32(sp)
    80004672:	e84a                	sd	s2,16(sp)
    80004674:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004676:	00854783          	lbu	a5,8(a0)
    8000467a:	cfd1                	beqz	a5,80004716 <fileread+0xaa>
    8000467c:	ec26                	sd	s1,24(sp)
    8000467e:	e44e                	sd	s3,8(sp)
    80004680:	84aa                	mv	s1,a0
    80004682:	892e                	mv	s2,a1
    80004684:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004686:	411c                	lw	a5,0(a0)
    80004688:	4705                	li	a4,1
    8000468a:	04e78363          	beq	a5,a4,800046d0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000468e:	470d                	li	a4,3
    80004690:	04e78763          	beq	a5,a4,800046de <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004694:	4709                	li	a4,2
    80004696:	06e79a63          	bne	a5,a4,8000470a <fileread+0x9e>
    ilock(f->ip);
    8000469a:	6d08                	ld	a0,24(a0)
    8000469c:	87cff0ef          	jal	80003718 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046a0:	874e                	mv	a4,s3
    800046a2:	5094                	lw	a3,32(s1)
    800046a4:	864a                	mv	a2,s2
    800046a6:	4585                	li	a1,1
    800046a8:	6c88                	ld	a0,24(s1)
    800046aa:	c00ff0ef          	jal	80003aaa <readi>
    800046ae:	892a                	mv	s2,a0
    800046b0:	00a05563          	blez	a0,800046ba <fileread+0x4e>
      f->off += r;
    800046b4:	509c                	lw	a5,32(s1)
    800046b6:	9fa9                	addw	a5,a5,a0
    800046b8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046ba:	6c88                	ld	a0,24(s1)
    800046bc:	90aff0ef          	jal	800037c6 <iunlock>
    800046c0:	64e2                	ld	s1,24(sp)
    800046c2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800046c4:	854a                	mv	a0,s2
    800046c6:	70a2                	ld	ra,40(sp)
    800046c8:	7402                	ld	s0,32(sp)
    800046ca:	6942                	ld	s2,16(sp)
    800046cc:	6145                	addi	sp,sp,48
    800046ce:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046d0:	6908                	ld	a0,16(a0)
    800046d2:	3b0000ef          	jal	80004a82 <piperead>
    800046d6:	892a                	mv	s2,a0
    800046d8:	64e2                	ld	s1,24(sp)
    800046da:	69a2                	ld	s3,8(sp)
    800046dc:	b7e5                	j	800046c4 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046de:	02451783          	lh	a5,36(a0)
    800046e2:	03079693          	slli	a3,a5,0x30
    800046e6:	92c1                	srli	a3,a3,0x30
    800046e8:	4725                	li	a4,9
    800046ea:	02d76963          	bltu	a4,a3,8000471c <fileread+0xb0>
    800046ee:	0792                	slli	a5,a5,0x4
    800046f0:	0001c717          	auipc	a4,0x1c
    800046f4:	3c870713          	addi	a4,a4,968 # 80020ab8 <devsw>
    800046f8:	97ba                	add	a5,a5,a4
    800046fa:	639c                	ld	a5,0(a5)
    800046fc:	c78d                	beqz	a5,80004726 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800046fe:	4505                	li	a0,1
    80004700:	9782                	jalr	a5
    80004702:	892a                	mv	s2,a0
    80004704:	64e2                	ld	s1,24(sp)
    80004706:	69a2                	ld	s3,8(sp)
    80004708:	bf75                	j	800046c4 <fileread+0x58>
    panic("fileread");
    8000470a:	00003517          	auipc	a0,0x3
    8000470e:	ede50513          	addi	a0,a0,-290 # 800075e8 <etext+0x5e8>
    80004712:	912fc0ef          	jal	80000824 <panic>
    return -1;
    80004716:	57fd                	li	a5,-1
    80004718:	893e                	mv	s2,a5
    8000471a:	b76d                	j	800046c4 <fileread+0x58>
      return -1;
    8000471c:	57fd                	li	a5,-1
    8000471e:	893e                	mv	s2,a5
    80004720:	64e2                	ld	s1,24(sp)
    80004722:	69a2                	ld	s3,8(sp)
    80004724:	b745                	j	800046c4 <fileread+0x58>
    80004726:	57fd                	li	a5,-1
    80004728:	893e                	mv	s2,a5
    8000472a:	64e2                	ld	s1,24(sp)
    8000472c:	69a2                	ld	s3,8(sp)
    8000472e:	bf59                	j	800046c4 <fileread+0x58>

0000000080004730 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004730:	00954783          	lbu	a5,9(a0)
    80004734:	10078f63          	beqz	a5,80004852 <filewrite+0x122>
{
    80004738:	711d                	addi	sp,sp,-96
    8000473a:	ec86                	sd	ra,88(sp)
    8000473c:	e8a2                	sd	s0,80(sp)
    8000473e:	e0ca                	sd	s2,64(sp)
    80004740:	f456                	sd	s5,40(sp)
    80004742:	f05a                	sd	s6,32(sp)
    80004744:	1080                	addi	s0,sp,96
    80004746:	892a                	mv	s2,a0
    80004748:	8b2e                	mv	s6,a1
    8000474a:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000474c:	411c                	lw	a5,0(a0)
    8000474e:	4705                	li	a4,1
    80004750:	02e78a63          	beq	a5,a4,80004784 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004754:	470d                	li	a4,3
    80004756:	02e78b63          	beq	a5,a4,8000478c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000475a:	4709                	li	a4,2
    8000475c:	0ce79f63          	bne	a5,a4,8000483a <filewrite+0x10a>
    80004760:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004762:	0ac05a63          	blez	a2,80004816 <filewrite+0xe6>
    80004766:	e4a6                	sd	s1,72(sp)
    80004768:	fc4e                	sd	s3,56(sp)
    8000476a:	ec5e                	sd	s7,24(sp)
    8000476c:	e862                	sd	s8,16(sp)
    8000476e:	e466                	sd	s9,8(sp)
    int i = 0;
    80004770:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004772:	6b85                	lui	s7,0x1
    80004774:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004778:	6785                	lui	a5,0x1
    8000477a:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000477e:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004780:	4c05                	li	s8,1
    80004782:	a8ad                	j	800047fc <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004784:	6908                	ld	a0,16(a0)
    80004786:	204000ef          	jal	8000498a <pipewrite>
    8000478a:	a04d                	j	8000482c <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000478c:	02451783          	lh	a5,36(a0)
    80004790:	03079693          	slli	a3,a5,0x30
    80004794:	92c1                	srli	a3,a3,0x30
    80004796:	4725                	li	a4,9
    80004798:	0ad76f63          	bltu	a4,a3,80004856 <filewrite+0x126>
    8000479c:	0792                	slli	a5,a5,0x4
    8000479e:	0001c717          	auipc	a4,0x1c
    800047a2:	31a70713          	addi	a4,a4,794 # 80020ab8 <devsw>
    800047a6:	97ba                	add	a5,a5,a4
    800047a8:	679c                	ld	a5,8(a5)
    800047aa:	cbc5                	beqz	a5,8000485a <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800047ac:	4505                	li	a0,1
    800047ae:	9782                	jalr	a5
    800047b0:	a8b5                	j	8000482c <filewrite+0xfc>
      if(n1 > max)
    800047b2:	2981                	sext.w	s3,s3
      begin_op();
    800047b4:	971ff0ef          	jal	80004124 <begin_op>
      ilock(f->ip);
    800047b8:	01893503          	ld	a0,24(s2)
    800047bc:	f5dfe0ef          	jal	80003718 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047c0:	874e                	mv	a4,s3
    800047c2:	02092683          	lw	a3,32(s2)
    800047c6:	016a0633          	add	a2,s4,s6
    800047ca:	85e2                	mv	a1,s8
    800047cc:	01893503          	ld	a0,24(s2)
    800047d0:	bccff0ef          	jal	80003b9c <writei>
    800047d4:	84aa                	mv	s1,a0
    800047d6:	00a05763          	blez	a0,800047e4 <filewrite+0xb4>
        f->off += r;
    800047da:	02092783          	lw	a5,32(s2)
    800047de:	9fa9                	addw	a5,a5,a0
    800047e0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047e4:	01893503          	ld	a0,24(s2)
    800047e8:	fdffe0ef          	jal	800037c6 <iunlock>
      end_op();
    800047ec:	9a9ff0ef          	jal	80004194 <end_op>

      if(r != n1){
    800047f0:	02999563          	bne	s3,s1,8000481a <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800047f4:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800047f8:	015a5963          	bge	s4,s5,8000480a <filewrite+0xda>
      int n1 = n - i;
    800047fc:	414a87bb          	subw	a5,s5,s4
    80004800:	89be                	mv	s3,a5
      if(n1 > max)
    80004802:	fafbd8e3          	bge	s7,a5,800047b2 <filewrite+0x82>
    80004806:	89e6                	mv	s3,s9
    80004808:	b76d                	j	800047b2 <filewrite+0x82>
    8000480a:	64a6                	ld	s1,72(sp)
    8000480c:	79e2                	ld	s3,56(sp)
    8000480e:	6be2                	ld	s7,24(sp)
    80004810:	6c42                	ld	s8,16(sp)
    80004812:	6ca2                	ld	s9,8(sp)
    80004814:	a801                	j	80004824 <filewrite+0xf4>
    int i = 0;
    80004816:	4a01                	li	s4,0
    80004818:	a031                	j	80004824 <filewrite+0xf4>
    8000481a:	64a6                	ld	s1,72(sp)
    8000481c:	79e2                	ld	s3,56(sp)
    8000481e:	6be2                	ld	s7,24(sp)
    80004820:	6c42                	ld	s8,16(sp)
    80004822:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004824:	034a9d63          	bne	s5,s4,8000485e <filewrite+0x12e>
    80004828:	8556                	mv	a0,s5
    8000482a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000482c:	60e6                	ld	ra,88(sp)
    8000482e:	6446                	ld	s0,80(sp)
    80004830:	6906                	ld	s2,64(sp)
    80004832:	7aa2                	ld	s5,40(sp)
    80004834:	7b02                	ld	s6,32(sp)
    80004836:	6125                	addi	sp,sp,96
    80004838:	8082                	ret
    8000483a:	e4a6                	sd	s1,72(sp)
    8000483c:	fc4e                	sd	s3,56(sp)
    8000483e:	f852                	sd	s4,48(sp)
    80004840:	ec5e                	sd	s7,24(sp)
    80004842:	e862                	sd	s8,16(sp)
    80004844:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004846:	00003517          	auipc	a0,0x3
    8000484a:	db250513          	addi	a0,a0,-590 # 800075f8 <etext+0x5f8>
    8000484e:	fd7fb0ef          	jal	80000824 <panic>
    return -1;
    80004852:	557d                	li	a0,-1
}
    80004854:	8082                	ret
      return -1;
    80004856:	557d                	li	a0,-1
    80004858:	bfd1                	j	8000482c <filewrite+0xfc>
    8000485a:	557d                	li	a0,-1
    8000485c:	bfc1                	j	8000482c <filewrite+0xfc>
    ret = (i == n ? n : -1);
    8000485e:	557d                	li	a0,-1
    80004860:	7a42                	ld	s4,48(sp)
    80004862:	b7e9                	j	8000482c <filewrite+0xfc>

0000000080004864 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004864:	7179                	addi	sp,sp,-48
    80004866:	f406                	sd	ra,40(sp)
    80004868:	f022                	sd	s0,32(sp)
    8000486a:	ec26                	sd	s1,24(sp)
    8000486c:	e052                	sd	s4,0(sp)
    8000486e:	1800                	addi	s0,sp,48
    80004870:	84aa                	mv	s1,a0
    80004872:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004874:	0005b023          	sd	zero,0(a1)
    80004878:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000487c:	c29ff0ef          	jal	800044a4 <filealloc>
    80004880:	e088                	sd	a0,0(s1)
    80004882:	c549                	beqz	a0,8000490c <pipealloc+0xa8>
    80004884:	c21ff0ef          	jal	800044a4 <filealloc>
    80004888:	00aa3023          	sd	a0,0(s4)
    8000488c:	cd25                	beqz	a0,80004904 <pipealloc+0xa0>
    8000488e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004890:	ab4fc0ef          	jal	80000b44 <kalloc>
    80004894:	892a                	mv	s2,a0
    80004896:	c12d                	beqz	a0,800048f8 <pipealloc+0x94>
    80004898:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000489a:	4985                	li	s3,1
    8000489c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048a0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048a4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048a8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048ac:	00003597          	auipc	a1,0x3
    800048b0:	d5c58593          	addi	a1,a1,-676 # 80007608 <etext+0x608>
    800048b4:	aeafc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    800048b8:	609c                	ld	a5,0(s1)
    800048ba:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048be:	609c                	ld	a5,0(s1)
    800048c0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048c4:	609c                	ld	a5,0(s1)
    800048c6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048ca:	609c                	ld	a5,0(s1)
    800048cc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048d0:	000a3783          	ld	a5,0(s4)
    800048d4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048d8:	000a3783          	ld	a5,0(s4)
    800048dc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048e0:	000a3783          	ld	a5,0(s4)
    800048e4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048e8:	000a3783          	ld	a5,0(s4)
    800048ec:	0127b823          	sd	s2,16(a5)
  return 0;
    800048f0:	4501                	li	a0,0
    800048f2:	6942                	ld	s2,16(sp)
    800048f4:	69a2                	ld	s3,8(sp)
    800048f6:	a01d                	j	8000491c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048f8:	6088                	ld	a0,0(s1)
    800048fa:	c119                	beqz	a0,80004900 <pipealloc+0x9c>
    800048fc:	6942                	ld	s2,16(sp)
    800048fe:	a029                	j	80004908 <pipealloc+0xa4>
    80004900:	6942                	ld	s2,16(sp)
    80004902:	a029                	j	8000490c <pipealloc+0xa8>
    80004904:	6088                	ld	a0,0(s1)
    80004906:	c10d                	beqz	a0,80004928 <pipealloc+0xc4>
    fileclose(*f0);
    80004908:	c41ff0ef          	jal	80004548 <fileclose>
  if(*f1)
    8000490c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004910:	557d                	li	a0,-1
  if(*f1)
    80004912:	c789                	beqz	a5,8000491c <pipealloc+0xb8>
    fileclose(*f1);
    80004914:	853e                	mv	a0,a5
    80004916:	c33ff0ef          	jal	80004548 <fileclose>
  return -1;
    8000491a:	557d                	li	a0,-1
}
    8000491c:	70a2                	ld	ra,40(sp)
    8000491e:	7402                	ld	s0,32(sp)
    80004920:	64e2                	ld	s1,24(sp)
    80004922:	6a02                	ld	s4,0(sp)
    80004924:	6145                	addi	sp,sp,48
    80004926:	8082                	ret
  return -1;
    80004928:	557d                	li	a0,-1
    8000492a:	bfcd                	j	8000491c <pipealloc+0xb8>

000000008000492c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000492c:	1101                	addi	sp,sp,-32
    8000492e:	ec06                	sd	ra,24(sp)
    80004930:	e822                	sd	s0,16(sp)
    80004932:	e426                	sd	s1,8(sp)
    80004934:	e04a                	sd	s2,0(sp)
    80004936:	1000                	addi	s0,sp,32
    80004938:	84aa                	mv	s1,a0
    8000493a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000493c:	aecfc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004940:	02090763          	beqz	s2,8000496e <pipeclose+0x42>
    pi->writeopen = 0;
    80004944:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004948:	21848513          	addi	a0,s1,536
    8000494c:	b3bfd0ef          	jal	80002486 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004950:	2204a783          	lw	a5,544(s1)
    80004954:	e781                	bnez	a5,8000495c <pipeclose+0x30>
    80004956:	2244a783          	lw	a5,548(s1)
    8000495a:	c38d                	beqz	a5,8000497c <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000495c:	8526                	mv	a0,s1
    8000495e:	b5efc0ef          	jal	80000cbc <release>
}
    80004962:	60e2                	ld	ra,24(sp)
    80004964:	6442                	ld	s0,16(sp)
    80004966:	64a2                	ld	s1,8(sp)
    80004968:	6902                	ld	s2,0(sp)
    8000496a:	6105                	addi	sp,sp,32
    8000496c:	8082                	ret
    pi->readopen = 0;
    8000496e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004972:	21c48513          	addi	a0,s1,540
    80004976:	b11fd0ef          	jal	80002486 <wakeup>
    8000497a:	bfd9                	j	80004950 <pipeclose+0x24>
    release(&pi->lock);
    8000497c:	8526                	mv	a0,s1
    8000497e:	b3efc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004982:	8526                	mv	a0,s1
    80004984:	8d8fc0ef          	jal	80000a5c <kfree>
    80004988:	bfe9                	j	80004962 <pipeclose+0x36>

000000008000498a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000498a:	7159                	addi	sp,sp,-112
    8000498c:	f486                	sd	ra,104(sp)
    8000498e:	f0a2                	sd	s0,96(sp)
    80004990:	eca6                	sd	s1,88(sp)
    80004992:	e8ca                	sd	s2,80(sp)
    80004994:	e4ce                	sd	s3,72(sp)
    80004996:	e0d2                	sd	s4,64(sp)
    80004998:	fc56                	sd	s5,56(sp)
    8000499a:	1880                	addi	s0,sp,112
    8000499c:	84aa                	mv	s1,a0
    8000499e:	8aae                	mv	s5,a1
    800049a0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049a2:	f95fc0ef          	jal	80001936 <myproc>
    800049a6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049a8:	8526                	mv	a0,s1
    800049aa:	a7efc0ef          	jal	80000c28 <acquire>
  while(i < n){
    800049ae:	0d405263          	blez	s4,80004a72 <pipewrite+0xe8>
    800049b2:	f85a                	sd	s6,48(sp)
    800049b4:	f45e                	sd	s7,40(sp)
    800049b6:	f062                	sd	s8,32(sp)
    800049b8:	ec66                	sd	s9,24(sp)
    800049ba:	e86a                	sd	s10,16(sp)
  int i = 0;
    800049bc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049be:	f9f40c13          	addi	s8,s0,-97
    800049c2:	4b85                	li	s7,1
    800049c4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049c6:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049ca:	21c48c93          	addi	s9,s1,540
    800049ce:	a82d                	j	80004a08 <pipewrite+0x7e>
      release(&pi->lock);
    800049d0:	8526                	mv	a0,s1
    800049d2:	aeafc0ef          	jal	80000cbc <release>
      return -1;
    800049d6:	597d                	li	s2,-1
    800049d8:	7b42                	ld	s6,48(sp)
    800049da:	7ba2                	ld	s7,40(sp)
    800049dc:	7c02                	ld	s8,32(sp)
    800049de:	6ce2                	ld	s9,24(sp)
    800049e0:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049e2:	854a                	mv	a0,s2
    800049e4:	70a6                	ld	ra,104(sp)
    800049e6:	7406                	ld	s0,96(sp)
    800049e8:	64e6                	ld	s1,88(sp)
    800049ea:	6946                	ld	s2,80(sp)
    800049ec:	69a6                	ld	s3,72(sp)
    800049ee:	6a06                	ld	s4,64(sp)
    800049f0:	7ae2                	ld	s5,56(sp)
    800049f2:	6165                	addi	sp,sp,112
    800049f4:	8082                	ret
      wakeup(&pi->nread);
    800049f6:	856a                	mv	a0,s10
    800049f8:	a8ffd0ef          	jal	80002486 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049fc:	85a6                	mv	a1,s1
    800049fe:	8566                	mv	a0,s9
    80004a00:	b46fd0ef          	jal	80001d46 <sleep>
  while(i < n){
    80004a04:	05495a63          	bge	s2,s4,80004a58 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004a08:	2204a783          	lw	a5,544(s1)
    80004a0c:	d3f1                	beqz	a5,800049d0 <pipewrite+0x46>
    80004a0e:	854e                	mv	a0,s3
    80004a10:	ba6fd0ef          	jal	80001db6 <killed>
    80004a14:	fd55                	bnez	a0,800049d0 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a16:	2184a783          	lw	a5,536(s1)
    80004a1a:	21c4a703          	lw	a4,540(s1)
    80004a1e:	2007879b          	addiw	a5,a5,512
    80004a22:	fcf70ae3          	beq	a4,a5,800049f6 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a26:	86de                	mv	a3,s7
    80004a28:	01590633          	add	a2,s2,s5
    80004a2c:	85e2                	mv	a1,s8
    80004a2e:	0709b503          	ld	a0,112(s3)
    80004a32:	ce1fc0ef          	jal	80001712 <copyin>
    80004a36:	05650063          	beq	a0,s6,80004a76 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a3a:	21c4a783          	lw	a5,540(s1)
    80004a3e:	0017871b          	addiw	a4,a5,1
    80004a42:	20e4ae23          	sw	a4,540(s1)
    80004a46:	1ff7f793          	andi	a5,a5,511
    80004a4a:	97a6                	add	a5,a5,s1
    80004a4c:	f9f44703          	lbu	a4,-97(s0)
    80004a50:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a54:	2905                	addiw	s2,s2,1
    80004a56:	b77d                	j	80004a04 <pipewrite+0x7a>
    80004a58:	7b42                	ld	s6,48(sp)
    80004a5a:	7ba2                	ld	s7,40(sp)
    80004a5c:	7c02                	ld	s8,32(sp)
    80004a5e:	6ce2                	ld	s9,24(sp)
    80004a60:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004a62:	21848513          	addi	a0,s1,536
    80004a66:	a21fd0ef          	jal	80002486 <wakeup>
  release(&pi->lock);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	a50fc0ef          	jal	80000cbc <release>
  return i;
    80004a70:	bf8d                	j	800049e2 <pipewrite+0x58>
  int i = 0;
    80004a72:	4901                	li	s2,0
    80004a74:	b7fd                	j	80004a62 <pipewrite+0xd8>
    80004a76:	7b42                	ld	s6,48(sp)
    80004a78:	7ba2                	ld	s7,40(sp)
    80004a7a:	7c02                	ld	s8,32(sp)
    80004a7c:	6ce2                	ld	s9,24(sp)
    80004a7e:	6d42                	ld	s10,16(sp)
    80004a80:	b7cd                	j	80004a62 <pipewrite+0xd8>

0000000080004a82 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a82:	711d                	addi	sp,sp,-96
    80004a84:	ec86                	sd	ra,88(sp)
    80004a86:	e8a2                	sd	s0,80(sp)
    80004a88:	e4a6                	sd	s1,72(sp)
    80004a8a:	e0ca                	sd	s2,64(sp)
    80004a8c:	fc4e                	sd	s3,56(sp)
    80004a8e:	f852                	sd	s4,48(sp)
    80004a90:	f456                	sd	s5,40(sp)
    80004a92:	1080                	addi	s0,sp,96
    80004a94:	84aa                	mv	s1,a0
    80004a96:	892e                	mv	s2,a1
    80004a98:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a9a:	e9dfc0ef          	jal	80001936 <myproc>
    80004a9e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	986fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aa6:	2184a703          	lw	a4,536(s1)
    80004aaa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aae:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ab2:	02f71763          	bne	a4,a5,80004ae0 <piperead+0x5e>
    80004ab6:	2244a783          	lw	a5,548(s1)
    80004aba:	cf85                	beqz	a5,80004af2 <piperead+0x70>
    if(killed(pr)){
    80004abc:	8552                	mv	a0,s4
    80004abe:	af8fd0ef          	jal	80001db6 <killed>
    80004ac2:	e11d                	bnez	a0,80004ae8 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ac4:	85a6                	mv	a1,s1
    80004ac6:	854e                	mv	a0,s3
    80004ac8:	a7efd0ef          	jal	80001d46 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004acc:	2184a703          	lw	a4,536(s1)
    80004ad0:	21c4a783          	lw	a5,540(s1)
    80004ad4:	fef701e3          	beq	a4,a5,80004ab6 <piperead+0x34>
    80004ad8:	f05a                	sd	s6,32(sp)
    80004ada:	ec5e                	sd	s7,24(sp)
    80004adc:	e862                	sd	s8,16(sp)
    80004ade:	a829                	j	80004af8 <piperead+0x76>
    80004ae0:	f05a                	sd	s6,32(sp)
    80004ae2:	ec5e                	sd	s7,24(sp)
    80004ae4:	e862                	sd	s8,16(sp)
    80004ae6:	a809                	j	80004af8 <piperead+0x76>
      release(&pi->lock);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	9d2fc0ef          	jal	80000cbc <release>
      return -1;
    80004aee:	59fd                	li	s3,-1
    80004af0:	a0a5                	j	80004b58 <piperead+0xd6>
    80004af2:	f05a                	sd	s6,32(sp)
    80004af4:	ec5e                	sd	s7,24(sp)
    80004af6:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004af8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004afa:	faf40c13          	addi	s8,s0,-81
    80004afe:	4b85                	li	s7,1
    80004b00:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b02:	05505163          	blez	s5,80004b44 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004b06:	2184a783          	lw	a5,536(s1)
    80004b0a:	21c4a703          	lw	a4,540(s1)
    80004b0e:	02f70b63          	beq	a4,a5,80004b44 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b12:	1ff7f793          	andi	a5,a5,511
    80004b16:	97a6                	add	a5,a5,s1
    80004b18:	0187c783          	lbu	a5,24(a5)
    80004b1c:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b20:	86de                	mv	a3,s7
    80004b22:	8662                	mv	a2,s8
    80004b24:	85ca                	mv	a1,s2
    80004b26:	070a3503          	ld	a0,112(s4)
    80004b2a:	b2bfc0ef          	jal	80001654 <copyout>
    80004b2e:	03650f63          	beq	a0,s6,80004b6c <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004b32:	2184a783          	lw	a5,536(s1)
    80004b36:	2785                	addiw	a5,a5,1
    80004b38:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b3c:	2985                	addiw	s3,s3,1
    80004b3e:	0905                	addi	s2,s2,1
    80004b40:	fd3a93e3          	bne	s5,s3,80004b06 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b44:	21c48513          	addi	a0,s1,540
    80004b48:	93ffd0ef          	jal	80002486 <wakeup>
  release(&pi->lock);
    80004b4c:	8526                	mv	a0,s1
    80004b4e:	96efc0ef          	jal	80000cbc <release>
    80004b52:	7b02                	ld	s6,32(sp)
    80004b54:	6be2                	ld	s7,24(sp)
    80004b56:	6c42                	ld	s8,16(sp)
  return i;
}
    80004b58:	854e                	mv	a0,s3
    80004b5a:	60e6                	ld	ra,88(sp)
    80004b5c:	6446                	ld	s0,80(sp)
    80004b5e:	64a6                	ld	s1,72(sp)
    80004b60:	6906                	ld	s2,64(sp)
    80004b62:	79e2                	ld	s3,56(sp)
    80004b64:	7a42                	ld	s4,48(sp)
    80004b66:	7aa2                	ld	s5,40(sp)
    80004b68:	6125                	addi	sp,sp,96
    80004b6a:	8082                	ret
      if(i == 0)
    80004b6c:	fc099ce3          	bnez	s3,80004b44 <piperead+0xc2>
        i = -1;
    80004b70:	89aa                	mv	s3,a0
    80004b72:	bfc9                	j	80004b44 <piperead+0xc2>

0000000080004b74 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004b74:	1141                	addi	sp,sp,-16
    80004b76:	e406                	sd	ra,8(sp)
    80004b78:	e022                	sd	s0,0(sp)
    80004b7a:	0800                	addi	s0,sp,16
    80004b7c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b7e:	0035151b          	slliw	a0,a0,0x3
    80004b82:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004b84:	8b89                	andi	a5,a5,2
    80004b86:	c399                	beqz	a5,80004b8c <flags2perm+0x18>
      perm |= PTE_W;
    80004b88:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b8c:	60a2                	ld	ra,8(sp)
    80004b8e:	6402                	ld	s0,0(sp)
    80004b90:	0141                	addi	sp,sp,16
    80004b92:	8082                	ret

0000000080004b94 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004b94:	de010113          	addi	sp,sp,-544
    80004b98:	20113c23          	sd	ra,536(sp)
    80004b9c:	20813823          	sd	s0,528(sp)
    80004ba0:	20913423          	sd	s1,520(sp)
    80004ba4:	21213023          	sd	s2,512(sp)
    80004ba8:	1400                	addi	s0,sp,544
    80004baa:	892a                	mv	s2,a0
    80004bac:	dea43823          	sd	a0,-528(s0)
    80004bb0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bb4:	d83fc0ef          	jal	80001936 <myproc>
    80004bb8:	84aa                	mv	s1,a0

  begin_op();
    80004bba:	d6aff0ef          	jal	80004124 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004bbe:	854a                	mv	a0,s2
    80004bc0:	b86ff0ef          	jal	80003f46 <namei>
    80004bc4:	cd21                	beqz	a0,80004c1c <kexec+0x88>
    80004bc6:	fbd2                	sd	s4,496(sp)
    80004bc8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bca:	b4ffe0ef          	jal	80003718 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bce:	04000713          	li	a4,64
    80004bd2:	4681                	li	a3,0
    80004bd4:	e5040613          	addi	a2,s0,-432
    80004bd8:	4581                	li	a1,0
    80004bda:	8552                	mv	a0,s4
    80004bdc:	ecffe0ef          	jal	80003aaa <readi>
    80004be0:	04000793          	li	a5,64
    80004be4:	00f51a63          	bne	a0,a5,80004bf8 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004be8:	e5042703          	lw	a4,-432(s0)
    80004bec:	464c47b7          	lui	a5,0x464c4
    80004bf0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bf4:	02f70863          	beq	a4,a5,80004c24 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bf8:	8552                	mv	a0,s4
    80004bfa:	d2bfe0ef          	jal	80003924 <iunlockput>
    end_op();
    80004bfe:	d96ff0ef          	jal	80004194 <end_op>
  }
  return -1;
    80004c02:	557d                	li	a0,-1
    80004c04:	7a5e                	ld	s4,496(sp)
}
    80004c06:	21813083          	ld	ra,536(sp)
    80004c0a:	21013403          	ld	s0,528(sp)
    80004c0e:	20813483          	ld	s1,520(sp)
    80004c12:	20013903          	ld	s2,512(sp)
    80004c16:	22010113          	addi	sp,sp,544
    80004c1a:	8082                	ret
    end_op();
    80004c1c:	d78ff0ef          	jal	80004194 <end_op>
    return -1;
    80004c20:	557d                	li	a0,-1
    80004c22:	b7d5                	j	80004c06 <kexec+0x72>
    80004c24:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004c26:	8526                	mv	a0,s1
    80004c28:	e19fc0ef          	jal	80001a40 <proc_pagetable>
    80004c2c:	8b2a                	mv	s6,a0
    80004c2e:	26050f63          	beqz	a0,80004eac <kexec+0x318>
    80004c32:	ffce                	sd	s3,504(sp)
    80004c34:	f7d6                	sd	s5,488(sp)
    80004c36:	efde                	sd	s7,472(sp)
    80004c38:	ebe2                	sd	s8,464(sp)
    80004c3a:	e7e6                	sd	s9,456(sp)
    80004c3c:	e3ea                	sd	s10,448(sp)
    80004c3e:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c40:	e8845783          	lhu	a5,-376(s0)
    80004c44:	0e078963          	beqz	a5,80004d36 <kexec+0x1a2>
    80004c48:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c4c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c4e:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c50:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004c54:	6c85                	lui	s9,0x1
    80004c56:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c5a:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c5e:	6a85                	lui	s5,0x1
    80004c60:	a085                	j	80004cc0 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004c62:	00003517          	auipc	a0,0x3
    80004c66:	9ae50513          	addi	a0,a0,-1618 # 80007610 <etext+0x610>
    80004c6a:	bbbfb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004c6e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c70:	874a                	mv	a4,s2
    80004c72:	009b86bb          	addw	a3,s7,s1
    80004c76:	4581                	li	a1,0
    80004c78:	8552                	mv	a0,s4
    80004c7a:	e31fe0ef          	jal	80003aaa <readi>
    80004c7e:	22a91b63          	bne	s2,a0,80004eb4 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004c82:	009a84bb          	addw	s1,s5,s1
    80004c86:	0334f263          	bgeu	s1,s3,80004caa <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004c8a:	02049593          	slli	a1,s1,0x20
    80004c8e:	9181                	srli	a1,a1,0x20
    80004c90:	95e2                	add	a1,a1,s8
    80004c92:	855a                	mv	a0,s6
    80004c94:	b92fc0ef          	jal	80001026 <walkaddr>
    80004c98:	862a                	mv	a2,a0
    if(pa == 0)
    80004c9a:	d561                	beqz	a0,80004c62 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004c9c:	409987bb          	subw	a5,s3,s1
    80004ca0:	893e                	mv	s2,a5
    80004ca2:	fcfcf6e3          	bgeu	s9,a5,80004c6e <kexec+0xda>
    80004ca6:	8956                	mv	s2,s5
    80004ca8:	b7d9                	j	80004c6e <kexec+0xda>
    sz = sz1;
    80004caa:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cae:	2d05                	addiw	s10,s10,1
    80004cb0:	e0843783          	ld	a5,-504(s0)
    80004cb4:	0387869b          	addiw	a3,a5,56
    80004cb8:	e8845783          	lhu	a5,-376(s0)
    80004cbc:	06fd5e63          	bge	s10,a5,80004d38 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cc0:	e0d43423          	sd	a3,-504(s0)
    80004cc4:	876e                	mv	a4,s11
    80004cc6:	e1840613          	addi	a2,s0,-488
    80004cca:	4581                	li	a1,0
    80004ccc:	8552                	mv	a0,s4
    80004cce:	dddfe0ef          	jal	80003aaa <readi>
    80004cd2:	1db51f63          	bne	a0,s11,80004eb0 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004cd6:	e1842783          	lw	a5,-488(s0)
    80004cda:	4705                	li	a4,1
    80004cdc:	fce799e3          	bne	a5,a4,80004cae <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004ce0:	e4043483          	ld	s1,-448(s0)
    80004ce4:	e3843783          	ld	a5,-456(s0)
    80004ce8:	1ef4e463          	bltu	s1,a5,80004ed0 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004cec:	e2843783          	ld	a5,-472(s0)
    80004cf0:	94be                	add	s1,s1,a5
    80004cf2:	1ef4e263          	bltu	s1,a5,80004ed6 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004cf6:	de843703          	ld	a4,-536(s0)
    80004cfa:	8ff9                	and	a5,a5,a4
    80004cfc:	1e079063          	bnez	a5,80004edc <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d00:	e1c42503          	lw	a0,-484(s0)
    80004d04:	e71ff0ef          	jal	80004b74 <flags2perm>
    80004d08:	86aa                	mv	a3,a0
    80004d0a:	8626                	mv	a2,s1
    80004d0c:	85ca                	mv	a1,s2
    80004d0e:	855a                	mv	a0,s6
    80004d10:	decfc0ef          	jal	800012fc <uvmalloc>
    80004d14:	dea43c23          	sd	a0,-520(s0)
    80004d18:	1c050563          	beqz	a0,80004ee2 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d1c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d20:	00098863          	beqz	s3,80004d30 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d24:	e2843c03          	ld	s8,-472(s0)
    80004d28:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d2c:	4481                	li	s1,0
    80004d2e:	bfb1                	j	80004c8a <kexec+0xf6>
    sz = sz1;
    80004d30:	df843903          	ld	s2,-520(s0)
    80004d34:	bfad                	j	80004cae <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d36:	4901                	li	s2,0
  iunlockput(ip);
    80004d38:	8552                	mv	a0,s4
    80004d3a:	bebfe0ef          	jal	80003924 <iunlockput>
  end_op();
    80004d3e:	c56ff0ef          	jal	80004194 <end_op>
  p = myproc();
    80004d42:	bf5fc0ef          	jal	80001936 <myproc>
    80004d46:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d48:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    80004d4c:	6985                	lui	s3,0x1
    80004d4e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d50:	99ca                	add	s3,s3,s2
    80004d52:	77fd                	lui	a5,0xfffff
    80004d54:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004d58:	4691                	li	a3,4
    80004d5a:	6609                	lui	a2,0x2
    80004d5c:	964e                	add	a2,a2,s3
    80004d5e:	85ce                	mv	a1,s3
    80004d60:	855a                	mv	a0,s6
    80004d62:	d9afc0ef          	jal	800012fc <uvmalloc>
    80004d66:	8a2a                	mv	s4,a0
    80004d68:	e105                	bnez	a0,80004d88 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004d6a:	85ce                	mv	a1,s3
    80004d6c:	855a                	mv	a0,s6
    80004d6e:	d57fc0ef          	jal	80001ac4 <proc_freepagetable>
  return -1;
    80004d72:	557d                	li	a0,-1
    80004d74:	79fe                	ld	s3,504(sp)
    80004d76:	7a5e                	ld	s4,496(sp)
    80004d78:	7abe                	ld	s5,488(sp)
    80004d7a:	7b1e                	ld	s6,480(sp)
    80004d7c:	6bfe                	ld	s7,472(sp)
    80004d7e:	6c5e                	ld	s8,464(sp)
    80004d80:	6cbe                	ld	s9,456(sp)
    80004d82:	6d1e                	ld	s10,448(sp)
    80004d84:	7dfa                	ld	s11,440(sp)
    80004d86:	b541                	j	80004c06 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004d88:	75f9                	lui	a1,0xffffe
    80004d8a:	95aa                	add	a1,a1,a0
    80004d8c:	855a                	mv	a0,s6
    80004d8e:	f40fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004d92:	800a0b93          	addi	s7,s4,-2048
    80004d96:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004d9a:	e0043783          	ld	a5,-512(s0)
    80004d9e:	6388                	ld	a0,0(a5)
  sp = sz;
    80004da0:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004da2:	4481                	li	s1,0
    ustack[argc] = sp;
    80004da4:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004da8:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004dac:	cd21                	beqz	a0,80004e04 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004dae:	8d4fc0ef          	jal	80000e82 <strlen>
    80004db2:	0015079b          	addiw	a5,a0,1
    80004db6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dba:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dbe:	13796563          	bltu	s2,s7,80004ee8 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dc2:	e0043d83          	ld	s11,-512(s0)
    80004dc6:	000db983          	ld	s3,0(s11)
    80004dca:	854e                	mv	a0,s3
    80004dcc:	8b6fc0ef          	jal	80000e82 <strlen>
    80004dd0:	0015069b          	addiw	a3,a0,1
    80004dd4:	864e                	mv	a2,s3
    80004dd6:	85ca                	mv	a1,s2
    80004dd8:	855a                	mv	a0,s6
    80004dda:	87bfc0ef          	jal	80001654 <copyout>
    80004dde:	10054763          	bltz	a0,80004eec <kexec+0x358>
    ustack[argc] = sp;
    80004de2:	00349793          	slli	a5,s1,0x3
    80004de6:	97e6                	add	a5,a5,s9
    80004de8:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdd3b0>
  for(argc = 0; argv[argc]; argc++) {
    80004dec:	0485                	addi	s1,s1,1
    80004dee:	008d8793          	addi	a5,s11,8
    80004df2:	e0f43023          	sd	a5,-512(s0)
    80004df6:	008db503          	ld	a0,8(s11)
    80004dfa:	c509                	beqz	a0,80004e04 <kexec+0x270>
    if(argc >= MAXARG)
    80004dfc:	fb8499e3          	bne	s1,s8,80004dae <kexec+0x21a>
  sz = sz1;
    80004e00:	89d2                	mv	s3,s4
    80004e02:	b7a5                	j	80004d6a <kexec+0x1d6>
  ustack[argc] = 0;
    80004e04:	00349793          	slli	a5,s1,0x3
    80004e08:	f9078793          	addi	a5,a5,-112
    80004e0c:	97a2                	add	a5,a5,s0
    80004e0e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e12:	00349693          	slli	a3,s1,0x3
    80004e16:	06a1                	addi	a3,a3,8
    80004e18:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e1c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e20:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004e22:	f57964e3          	bltu	s2,s7,80004d6a <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e26:	e9040613          	addi	a2,s0,-368
    80004e2a:	85ca                	mv	a1,s2
    80004e2c:	855a                	mv	a0,s6
    80004e2e:	827fc0ef          	jal	80001654 <copyout>
    80004e32:	f2054ce3          	bltz	a0,80004d6a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004e36:	078ab783          	ld	a5,120(s5) # 1078 <_entry-0x7fffef88>
    80004e3a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e3e:	df043783          	ld	a5,-528(s0)
    80004e42:	0007c703          	lbu	a4,0(a5)
    80004e46:	cf11                	beqz	a4,80004e62 <kexec+0x2ce>
    80004e48:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e4a:	02f00693          	li	a3,47
    80004e4e:	a029                	j	80004e58 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004e50:	0785                	addi	a5,a5,1
    80004e52:	fff7c703          	lbu	a4,-1(a5)
    80004e56:	c711                	beqz	a4,80004e62 <kexec+0x2ce>
    if(*s == '/')
    80004e58:	fed71ce3          	bne	a4,a3,80004e50 <kexec+0x2bc>
      last = s+1;
    80004e5c:	def43823          	sd	a5,-528(s0)
    80004e60:	bfc5                	j	80004e50 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e62:	4641                	li	a2,16
    80004e64:	df043583          	ld	a1,-528(s0)
    80004e68:	178a8513          	addi	a0,s5,376
    80004e6c:	fe1fb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e70:	070ab503          	ld	a0,112(s5)
  p->pagetable = pagetable;
    80004e74:	076ab823          	sd	s6,112(s5)
  p->sz = sz;
    80004e78:	074ab423          	sd	s4,104(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004e7c:	078ab783          	ld	a5,120(s5)
    80004e80:	e6843703          	ld	a4,-408(s0)
    80004e84:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e86:	078ab783          	ld	a5,120(s5)
    80004e8a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e8e:	85ea                	mv	a1,s10
    80004e90:	c35fc0ef          	jal	80001ac4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e94:	0004851b          	sext.w	a0,s1
    80004e98:	79fe                	ld	s3,504(sp)
    80004e9a:	7a5e                	ld	s4,496(sp)
    80004e9c:	7abe                	ld	s5,488(sp)
    80004e9e:	7b1e                	ld	s6,480(sp)
    80004ea0:	6bfe                	ld	s7,472(sp)
    80004ea2:	6c5e                	ld	s8,464(sp)
    80004ea4:	6cbe                	ld	s9,456(sp)
    80004ea6:	6d1e                	ld	s10,448(sp)
    80004ea8:	7dfa                	ld	s11,440(sp)
    80004eaa:	bbb1                	j	80004c06 <kexec+0x72>
    80004eac:	7b1e                	ld	s6,480(sp)
    80004eae:	b3a9                	j	80004bf8 <kexec+0x64>
    80004eb0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004eb4:	df843583          	ld	a1,-520(s0)
    80004eb8:	855a                	mv	a0,s6
    80004eba:	c0bfc0ef          	jal	80001ac4 <proc_freepagetable>
  if(ip){
    80004ebe:	79fe                	ld	s3,504(sp)
    80004ec0:	7abe                	ld	s5,488(sp)
    80004ec2:	7b1e                	ld	s6,480(sp)
    80004ec4:	6bfe                	ld	s7,472(sp)
    80004ec6:	6c5e                	ld	s8,464(sp)
    80004ec8:	6cbe                	ld	s9,456(sp)
    80004eca:	6d1e                	ld	s10,448(sp)
    80004ecc:	7dfa                	ld	s11,440(sp)
    80004ece:	b32d                	j	80004bf8 <kexec+0x64>
    80004ed0:	df243c23          	sd	s2,-520(s0)
    80004ed4:	b7c5                	j	80004eb4 <kexec+0x320>
    80004ed6:	df243c23          	sd	s2,-520(s0)
    80004eda:	bfe9                	j	80004eb4 <kexec+0x320>
    80004edc:	df243c23          	sd	s2,-520(s0)
    80004ee0:	bfd1                	j	80004eb4 <kexec+0x320>
    80004ee2:	df243c23          	sd	s2,-520(s0)
    80004ee6:	b7f9                	j	80004eb4 <kexec+0x320>
  sz = sz1;
    80004ee8:	89d2                	mv	s3,s4
    80004eea:	b541                	j	80004d6a <kexec+0x1d6>
    80004eec:	89d2                	mv	s3,s4
    80004eee:	bdb5                	j	80004d6a <kexec+0x1d6>

0000000080004ef0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ef0:	7179                	addi	sp,sp,-48
    80004ef2:	f406                	sd	ra,40(sp)
    80004ef4:	f022                	sd	s0,32(sp)
    80004ef6:	ec26                	sd	s1,24(sp)
    80004ef8:	e84a                	sd	s2,16(sp)
    80004efa:	1800                	addi	s0,sp,48
    80004efc:	892e                	mv	s2,a1
    80004efe:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f00:	fdc40593          	addi	a1,s0,-36
    80004f04:	c01fd0ef          	jal	80002b04 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f08:	fdc42703          	lw	a4,-36(s0)
    80004f0c:	47bd                	li	a5,15
    80004f0e:	02e7ea63          	bltu	a5,a4,80004f42 <argfd+0x52>
    80004f12:	a25fc0ef          	jal	80001936 <myproc>
    80004f16:	fdc42703          	lw	a4,-36(s0)
    80004f1a:	00371793          	slli	a5,a4,0x3
    80004f1e:	0f078793          	addi	a5,a5,240
    80004f22:	953e                	add	a0,a0,a5
    80004f24:	611c                	ld	a5,0(a0)
    80004f26:	c385                	beqz	a5,80004f46 <argfd+0x56>
    return -1;
  if(pfd)
    80004f28:	00090463          	beqz	s2,80004f30 <argfd+0x40>
    *pfd = fd;
    80004f2c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f30:	4501                	li	a0,0
  if(pf)
    80004f32:	c091                	beqz	s1,80004f36 <argfd+0x46>
    *pf = f;
    80004f34:	e09c                	sd	a5,0(s1)
}
    80004f36:	70a2                	ld	ra,40(sp)
    80004f38:	7402                	ld	s0,32(sp)
    80004f3a:	64e2                	ld	s1,24(sp)
    80004f3c:	6942                	ld	s2,16(sp)
    80004f3e:	6145                	addi	sp,sp,48
    80004f40:	8082                	ret
    return -1;
    80004f42:	557d                	li	a0,-1
    80004f44:	bfcd                	j	80004f36 <argfd+0x46>
    80004f46:	557d                	li	a0,-1
    80004f48:	b7fd                	j	80004f36 <argfd+0x46>

0000000080004f4a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f4a:	1101                	addi	sp,sp,-32
    80004f4c:	ec06                	sd	ra,24(sp)
    80004f4e:	e822                	sd	s0,16(sp)
    80004f50:	e426                	sd	s1,8(sp)
    80004f52:	1000                	addi	s0,sp,32
    80004f54:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f56:	9e1fc0ef          	jal	80001936 <myproc>
    80004f5a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f5c:	0f050793          	addi	a5,a0,240
    80004f60:	4501                	li	a0,0
    80004f62:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f64:	6398                	ld	a4,0(a5)
    80004f66:	cb19                	beqz	a4,80004f7c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004f68:	2505                	addiw	a0,a0,1
    80004f6a:	07a1                	addi	a5,a5,8
    80004f6c:	fed51ce3          	bne	a0,a3,80004f64 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f70:	557d                	li	a0,-1
}
    80004f72:	60e2                	ld	ra,24(sp)
    80004f74:	6442                	ld	s0,16(sp)
    80004f76:	64a2                	ld	s1,8(sp)
    80004f78:	6105                	addi	sp,sp,32
    80004f7a:	8082                	ret
      p->ofile[fd] = f;
    80004f7c:	00351793          	slli	a5,a0,0x3
    80004f80:	0f078793          	addi	a5,a5,240
    80004f84:	963e                	add	a2,a2,a5
    80004f86:	e204                	sd	s1,0(a2)
      return fd;
    80004f88:	b7ed                	j	80004f72 <fdalloc+0x28>

0000000080004f8a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f8a:	715d                	addi	sp,sp,-80
    80004f8c:	e486                	sd	ra,72(sp)
    80004f8e:	e0a2                	sd	s0,64(sp)
    80004f90:	fc26                	sd	s1,56(sp)
    80004f92:	f84a                	sd	s2,48(sp)
    80004f94:	f44e                	sd	s3,40(sp)
    80004f96:	f052                	sd	s4,32(sp)
    80004f98:	ec56                	sd	s5,24(sp)
    80004f9a:	e85a                	sd	s6,16(sp)
    80004f9c:	0880                	addi	s0,sp,80
    80004f9e:	892e                	mv	s2,a1
    80004fa0:	8a2e                	mv	s4,a1
    80004fa2:	8ab2                	mv	s5,a2
    80004fa4:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fa6:	fb040593          	addi	a1,s0,-80
    80004faa:	fb7fe0ef          	jal	80003f60 <nameiparent>
    80004fae:	84aa                	mv	s1,a0
    80004fb0:	10050763          	beqz	a0,800050be <create+0x134>
    return 0;

  ilock(dp);
    80004fb4:	f64fe0ef          	jal	80003718 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fb8:	4601                	li	a2,0
    80004fba:	fb040593          	addi	a1,s0,-80
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	cf3fe0ef          	jal	80003cb2 <dirlookup>
    80004fc4:	89aa                	mv	s3,a0
    80004fc6:	c131                	beqz	a0,8000500a <create+0x80>
    iunlockput(dp);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	95bfe0ef          	jal	80003924 <iunlockput>
    ilock(ip);
    80004fce:	854e                	mv	a0,s3
    80004fd0:	f48fe0ef          	jal	80003718 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fd4:	4789                	li	a5,2
    80004fd6:	02f91563          	bne	s2,a5,80005000 <create+0x76>
    80004fda:	0449d783          	lhu	a5,68(s3)
    80004fde:	37f9                	addiw	a5,a5,-2
    80004fe0:	17c2                	slli	a5,a5,0x30
    80004fe2:	93c1                	srli	a5,a5,0x30
    80004fe4:	4705                	li	a4,1
    80004fe6:	00f76d63          	bltu	a4,a5,80005000 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004fea:	854e                	mv	a0,s3
    80004fec:	60a6                	ld	ra,72(sp)
    80004fee:	6406                	ld	s0,64(sp)
    80004ff0:	74e2                	ld	s1,56(sp)
    80004ff2:	7942                	ld	s2,48(sp)
    80004ff4:	79a2                	ld	s3,40(sp)
    80004ff6:	7a02                	ld	s4,32(sp)
    80004ff8:	6ae2                	ld	s5,24(sp)
    80004ffa:	6b42                	ld	s6,16(sp)
    80004ffc:	6161                	addi	sp,sp,80
    80004ffe:	8082                	ret
    iunlockput(ip);
    80005000:	854e                	mv	a0,s3
    80005002:	923fe0ef          	jal	80003924 <iunlockput>
    return 0;
    80005006:	4981                	li	s3,0
    80005008:	b7cd                	j	80004fea <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000500a:	85ca                	mv	a1,s2
    8000500c:	4088                	lw	a0,0(s1)
    8000500e:	d9afe0ef          	jal	800035a8 <ialloc>
    80005012:	892a                	mv	s2,a0
    80005014:	cd15                	beqz	a0,80005050 <create+0xc6>
  ilock(ip);
    80005016:	f02fe0ef          	jal	80003718 <ilock>
  ip->major = major;
    8000501a:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    8000501e:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005022:	4785                	li	a5,1
    80005024:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005028:	854a                	mv	a0,s2
    8000502a:	e3afe0ef          	jal	80003664 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000502e:	4705                	li	a4,1
    80005030:	02ea0463          	beq	s4,a4,80005058 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005034:	00492603          	lw	a2,4(s2)
    80005038:	fb040593          	addi	a1,s0,-80
    8000503c:	8526                	mv	a0,s1
    8000503e:	e5ffe0ef          	jal	80003e9c <dirlink>
    80005042:	06054263          	bltz	a0,800050a6 <create+0x11c>
  iunlockput(dp);
    80005046:	8526                	mv	a0,s1
    80005048:	8ddfe0ef          	jal	80003924 <iunlockput>
  return ip;
    8000504c:	89ca                	mv	s3,s2
    8000504e:	bf71                	j	80004fea <create+0x60>
    iunlockput(dp);
    80005050:	8526                	mv	a0,s1
    80005052:	8d3fe0ef          	jal	80003924 <iunlockput>
    return 0;
    80005056:	bf51                	j	80004fea <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005058:	00492603          	lw	a2,4(s2)
    8000505c:	00002597          	auipc	a1,0x2
    80005060:	5d458593          	addi	a1,a1,1492 # 80007630 <etext+0x630>
    80005064:	854a                	mv	a0,s2
    80005066:	e37fe0ef          	jal	80003e9c <dirlink>
    8000506a:	02054e63          	bltz	a0,800050a6 <create+0x11c>
    8000506e:	40d0                	lw	a2,4(s1)
    80005070:	00002597          	auipc	a1,0x2
    80005074:	5c858593          	addi	a1,a1,1480 # 80007638 <etext+0x638>
    80005078:	854a                	mv	a0,s2
    8000507a:	e23fe0ef          	jal	80003e9c <dirlink>
    8000507e:	02054463          	bltz	a0,800050a6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005082:	00492603          	lw	a2,4(s2)
    80005086:	fb040593          	addi	a1,s0,-80
    8000508a:	8526                	mv	a0,s1
    8000508c:	e11fe0ef          	jal	80003e9c <dirlink>
    80005090:	00054b63          	bltz	a0,800050a6 <create+0x11c>
    dp->nlink++;  // for ".."
    80005094:	04a4d783          	lhu	a5,74(s1)
    80005098:	2785                	addiw	a5,a5,1
    8000509a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000509e:	8526                	mv	a0,s1
    800050a0:	dc4fe0ef          	jal	80003664 <iupdate>
    800050a4:	b74d                	j	80005046 <create+0xbc>
  ip->nlink = 0;
    800050a6:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    800050aa:	854a                	mv	a0,s2
    800050ac:	db8fe0ef          	jal	80003664 <iupdate>
  iunlockput(ip);
    800050b0:	854a                	mv	a0,s2
    800050b2:	873fe0ef          	jal	80003924 <iunlockput>
  iunlockput(dp);
    800050b6:	8526                	mv	a0,s1
    800050b8:	86dfe0ef          	jal	80003924 <iunlockput>
  return 0;
    800050bc:	b73d                	j	80004fea <create+0x60>
    return 0;
    800050be:	89aa                	mv	s3,a0
    800050c0:	b72d                	j	80004fea <create+0x60>

00000000800050c2 <sys_dup>:
{
    800050c2:	7179                	addi	sp,sp,-48
    800050c4:	f406                	sd	ra,40(sp)
    800050c6:	f022                	sd	s0,32(sp)
    800050c8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050ca:	fd840613          	addi	a2,s0,-40
    800050ce:	4581                	li	a1,0
    800050d0:	4501                	li	a0,0
    800050d2:	e1fff0ef          	jal	80004ef0 <argfd>
    return -1;
    800050d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050d8:	02054363          	bltz	a0,800050fe <sys_dup+0x3c>
    800050dc:	ec26                	sd	s1,24(sp)
    800050de:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800050e0:	fd843483          	ld	s1,-40(s0)
    800050e4:	8526                	mv	a0,s1
    800050e6:	e65ff0ef          	jal	80004f4a <fdalloc>
    800050ea:	892a                	mv	s2,a0
    return -1;
    800050ec:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050ee:	00054d63          	bltz	a0,80005108 <sys_dup+0x46>
  filedup(f);
    800050f2:	8526                	mv	a0,s1
    800050f4:	c0eff0ef          	jal	80004502 <filedup>
  return fd;
    800050f8:	87ca                	mv	a5,s2
    800050fa:	64e2                	ld	s1,24(sp)
    800050fc:	6942                	ld	s2,16(sp)
}
    800050fe:	853e                	mv	a0,a5
    80005100:	70a2                	ld	ra,40(sp)
    80005102:	7402                	ld	s0,32(sp)
    80005104:	6145                	addi	sp,sp,48
    80005106:	8082                	ret
    80005108:	64e2                	ld	s1,24(sp)
    8000510a:	6942                	ld	s2,16(sp)
    8000510c:	bfcd                	j	800050fe <sys_dup+0x3c>

000000008000510e <sys_read>:
{
    8000510e:	7179                	addi	sp,sp,-48
    80005110:	f406                	sd	ra,40(sp)
    80005112:	f022                	sd	s0,32(sp)
    80005114:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005116:	fd840593          	addi	a1,s0,-40
    8000511a:	4505                	li	a0,1
    8000511c:	a05fd0ef          	jal	80002b20 <argaddr>
  argint(2, &n);
    80005120:	fe440593          	addi	a1,s0,-28
    80005124:	4509                	li	a0,2
    80005126:	9dffd0ef          	jal	80002b04 <argint>
  if(argfd(0, 0, &f) < 0)
    8000512a:	fe840613          	addi	a2,s0,-24
    8000512e:	4581                	li	a1,0
    80005130:	4501                	li	a0,0
    80005132:	dbfff0ef          	jal	80004ef0 <argfd>
    80005136:	87aa                	mv	a5,a0
    return -1;
    80005138:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000513a:	0007ca63          	bltz	a5,8000514e <sys_read+0x40>
  return fileread(f, p, n);
    8000513e:	fe442603          	lw	a2,-28(s0)
    80005142:	fd843583          	ld	a1,-40(s0)
    80005146:	fe843503          	ld	a0,-24(s0)
    8000514a:	d22ff0ef          	jal	8000466c <fileread>
}
    8000514e:	70a2                	ld	ra,40(sp)
    80005150:	7402                	ld	s0,32(sp)
    80005152:	6145                	addi	sp,sp,48
    80005154:	8082                	ret

0000000080005156 <sys_write>:
{
    80005156:	7179                	addi	sp,sp,-48
    80005158:	f406                	sd	ra,40(sp)
    8000515a:	f022                	sd	s0,32(sp)
    8000515c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000515e:	fd840593          	addi	a1,s0,-40
    80005162:	4505                	li	a0,1
    80005164:	9bdfd0ef          	jal	80002b20 <argaddr>
  argint(2, &n);
    80005168:	fe440593          	addi	a1,s0,-28
    8000516c:	4509                	li	a0,2
    8000516e:	997fd0ef          	jal	80002b04 <argint>
  if(argfd(0, 0, &f) < 0)
    80005172:	fe840613          	addi	a2,s0,-24
    80005176:	4581                	li	a1,0
    80005178:	4501                	li	a0,0
    8000517a:	d77ff0ef          	jal	80004ef0 <argfd>
    8000517e:	87aa                	mv	a5,a0
    return -1;
    80005180:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005182:	0007ca63          	bltz	a5,80005196 <sys_write+0x40>
  return filewrite(f, p, n);
    80005186:	fe442603          	lw	a2,-28(s0)
    8000518a:	fd843583          	ld	a1,-40(s0)
    8000518e:	fe843503          	ld	a0,-24(s0)
    80005192:	d9eff0ef          	jal	80004730 <filewrite>
}
    80005196:	70a2                	ld	ra,40(sp)
    80005198:	7402                	ld	s0,32(sp)
    8000519a:	6145                	addi	sp,sp,48
    8000519c:	8082                	ret

000000008000519e <sys_close>:
{
    8000519e:	1101                	addi	sp,sp,-32
    800051a0:	ec06                	sd	ra,24(sp)
    800051a2:	e822                	sd	s0,16(sp)
    800051a4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051a6:	fe040613          	addi	a2,s0,-32
    800051aa:	fec40593          	addi	a1,s0,-20
    800051ae:	4501                	li	a0,0
    800051b0:	d41ff0ef          	jal	80004ef0 <argfd>
    return -1;
    800051b4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051b6:	02054163          	bltz	a0,800051d8 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800051ba:	f7cfc0ef          	jal	80001936 <myproc>
    800051be:	fec42783          	lw	a5,-20(s0)
    800051c2:	078e                	slli	a5,a5,0x3
    800051c4:	0f078793          	addi	a5,a5,240
    800051c8:	953e                	add	a0,a0,a5
    800051ca:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800051ce:	fe043503          	ld	a0,-32(s0)
    800051d2:	b76ff0ef          	jal	80004548 <fileclose>
  return 0;
    800051d6:	4781                	li	a5,0
}
    800051d8:	853e                	mv	a0,a5
    800051da:	60e2                	ld	ra,24(sp)
    800051dc:	6442                	ld	s0,16(sp)
    800051de:	6105                	addi	sp,sp,32
    800051e0:	8082                	ret

00000000800051e2 <sys_fstat>:
{
    800051e2:	1101                	addi	sp,sp,-32
    800051e4:	ec06                	sd	ra,24(sp)
    800051e6:	e822                	sd	s0,16(sp)
    800051e8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800051ea:	fe040593          	addi	a1,s0,-32
    800051ee:	4505                	li	a0,1
    800051f0:	931fd0ef          	jal	80002b20 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800051f4:	fe840613          	addi	a2,s0,-24
    800051f8:	4581                	li	a1,0
    800051fa:	4501                	li	a0,0
    800051fc:	cf5ff0ef          	jal	80004ef0 <argfd>
    80005200:	87aa                	mv	a5,a0
    return -1;
    80005202:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005204:	0007c863          	bltz	a5,80005214 <sys_fstat+0x32>
  return filestat(f, st);
    80005208:	fe043583          	ld	a1,-32(s0)
    8000520c:	fe843503          	ld	a0,-24(s0)
    80005210:	bfaff0ef          	jal	8000460a <filestat>
}
    80005214:	60e2                	ld	ra,24(sp)
    80005216:	6442                	ld	s0,16(sp)
    80005218:	6105                	addi	sp,sp,32
    8000521a:	8082                	ret

000000008000521c <sys_link>:
{
    8000521c:	7169                	addi	sp,sp,-304
    8000521e:	f606                	sd	ra,296(sp)
    80005220:	f222                	sd	s0,288(sp)
    80005222:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005224:	08000613          	li	a2,128
    80005228:	ed040593          	addi	a1,s0,-304
    8000522c:	4501                	li	a0,0
    8000522e:	90ffd0ef          	jal	80002b3c <argstr>
    return -1;
    80005232:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005234:	0c054e63          	bltz	a0,80005310 <sys_link+0xf4>
    80005238:	08000613          	li	a2,128
    8000523c:	f5040593          	addi	a1,s0,-176
    80005240:	4505                	li	a0,1
    80005242:	8fbfd0ef          	jal	80002b3c <argstr>
    return -1;
    80005246:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005248:	0c054463          	bltz	a0,80005310 <sys_link+0xf4>
    8000524c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000524e:	ed7fe0ef          	jal	80004124 <begin_op>
  if((ip = namei(old)) == 0){
    80005252:	ed040513          	addi	a0,s0,-304
    80005256:	cf1fe0ef          	jal	80003f46 <namei>
    8000525a:	84aa                	mv	s1,a0
    8000525c:	c53d                	beqz	a0,800052ca <sys_link+0xae>
  ilock(ip);
    8000525e:	cbafe0ef          	jal	80003718 <ilock>
  if(ip->type == T_DIR){
    80005262:	04449703          	lh	a4,68(s1)
    80005266:	4785                	li	a5,1
    80005268:	06f70663          	beq	a4,a5,800052d4 <sys_link+0xb8>
    8000526c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000526e:	04a4d783          	lhu	a5,74(s1)
    80005272:	2785                	addiw	a5,a5,1
    80005274:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005278:	8526                	mv	a0,s1
    8000527a:	beafe0ef          	jal	80003664 <iupdate>
  iunlock(ip);
    8000527e:	8526                	mv	a0,s1
    80005280:	d46fe0ef          	jal	800037c6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005284:	fd040593          	addi	a1,s0,-48
    80005288:	f5040513          	addi	a0,s0,-176
    8000528c:	cd5fe0ef          	jal	80003f60 <nameiparent>
    80005290:	892a                	mv	s2,a0
    80005292:	cd21                	beqz	a0,800052ea <sys_link+0xce>
  ilock(dp);
    80005294:	c84fe0ef          	jal	80003718 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005298:	854a                	mv	a0,s2
    8000529a:	00092703          	lw	a4,0(s2)
    8000529e:	409c                	lw	a5,0(s1)
    800052a0:	04f71263          	bne	a4,a5,800052e4 <sys_link+0xc8>
    800052a4:	40d0                	lw	a2,4(s1)
    800052a6:	fd040593          	addi	a1,s0,-48
    800052aa:	bf3fe0ef          	jal	80003e9c <dirlink>
    800052ae:	02054b63          	bltz	a0,800052e4 <sys_link+0xc8>
  iunlockput(dp);
    800052b2:	854a                	mv	a0,s2
    800052b4:	e70fe0ef          	jal	80003924 <iunlockput>
  iput(ip);
    800052b8:	8526                	mv	a0,s1
    800052ba:	de0fe0ef          	jal	8000389a <iput>
  end_op();
    800052be:	ed7fe0ef          	jal	80004194 <end_op>
  return 0;
    800052c2:	4781                	li	a5,0
    800052c4:	64f2                	ld	s1,280(sp)
    800052c6:	6952                	ld	s2,272(sp)
    800052c8:	a0a1                	j	80005310 <sys_link+0xf4>
    end_op();
    800052ca:	ecbfe0ef          	jal	80004194 <end_op>
    return -1;
    800052ce:	57fd                	li	a5,-1
    800052d0:	64f2                	ld	s1,280(sp)
    800052d2:	a83d                	j	80005310 <sys_link+0xf4>
    iunlockput(ip);
    800052d4:	8526                	mv	a0,s1
    800052d6:	e4efe0ef          	jal	80003924 <iunlockput>
    end_op();
    800052da:	ebbfe0ef          	jal	80004194 <end_op>
    return -1;
    800052de:	57fd                	li	a5,-1
    800052e0:	64f2                	ld	s1,280(sp)
    800052e2:	a03d                	j	80005310 <sys_link+0xf4>
    iunlockput(dp);
    800052e4:	854a                	mv	a0,s2
    800052e6:	e3efe0ef          	jal	80003924 <iunlockput>
  ilock(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	c2cfe0ef          	jal	80003718 <ilock>
  ip->nlink--;
    800052f0:	04a4d783          	lhu	a5,74(s1)
    800052f4:	37fd                	addiw	a5,a5,-1
    800052f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052fa:	8526                	mv	a0,s1
    800052fc:	b68fe0ef          	jal	80003664 <iupdate>
  iunlockput(ip);
    80005300:	8526                	mv	a0,s1
    80005302:	e22fe0ef          	jal	80003924 <iunlockput>
  end_op();
    80005306:	e8ffe0ef          	jal	80004194 <end_op>
  return -1;
    8000530a:	57fd                	li	a5,-1
    8000530c:	64f2                	ld	s1,280(sp)
    8000530e:	6952                	ld	s2,272(sp)
}
    80005310:	853e                	mv	a0,a5
    80005312:	70b2                	ld	ra,296(sp)
    80005314:	7412                	ld	s0,288(sp)
    80005316:	6155                	addi	sp,sp,304
    80005318:	8082                	ret

000000008000531a <sys_unlink>:
{
    8000531a:	7151                	addi	sp,sp,-240
    8000531c:	f586                	sd	ra,232(sp)
    8000531e:	f1a2                	sd	s0,224(sp)
    80005320:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005322:	08000613          	li	a2,128
    80005326:	f3040593          	addi	a1,s0,-208
    8000532a:	4501                	li	a0,0
    8000532c:	811fd0ef          	jal	80002b3c <argstr>
    80005330:	14054d63          	bltz	a0,8000548a <sys_unlink+0x170>
    80005334:	eda6                	sd	s1,216(sp)
  begin_op();
    80005336:	deffe0ef          	jal	80004124 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000533a:	fb040593          	addi	a1,s0,-80
    8000533e:	f3040513          	addi	a0,s0,-208
    80005342:	c1ffe0ef          	jal	80003f60 <nameiparent>
    80005346:	84aa                	mv	s1,a0
    80005348:	c955                	beqz	a0,800053fc <sys_unlink+0xe2>
  ilock(dp);
    8000534a:	bcefe0ef          	jal	80003718 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000534e:	00002597          	auipc	a1,0x2
    80005352:	2e258593          	addi	a1,a1,738 # 80007630 <etext+0x630>
    80005356:	fb040513          	addi	a0,s0,-80
    8000535a:	943fe0ef          	jal	80003c9c <namecmp>
    8000535e:	10050b63          	beqz	a0,80005474 <sys_unlink+0x15a>
    80005362:	00002597          	auipc	a1,0x2
    80005366:	2d658593          	addi	a1,a1,726 # 80007638 <etext+0x638>
    8000536a:	fb040513          	addi	a0,s0,-80
    8000536e:	92ffe0ef          	jal	80003c9c <namecmp>
    80005372:	10050163          	beqz	a0,80005474 <sys_unlink+0x15a>
    80005376:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005378:	f2c40613          	addi	a2,s0,-212
    8000537c:	fb040593          	addi	a1,s0,-80
    80005380:	8526                	mv	a0,s1
    80005382:	931fe0ef          	jal	80003cb2 <dirlookup>
    80005386:	892a                	mv	s2,a0
    80005388:	0e050563          	beqz	a0,80005472 <sys_unlink+0x158>
    8000538c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000538e:	b8afe0ef          	jal	80003718 <ilock>
  if(ip->nlink < 1)
    80005392:	04a91783          	lh	a5,74(s2)
    80005396:	06f05863          	blez	a5,80005406 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000539a:	04491703          	lh	a4,68(s2)
    8000539e:	4785                	li	a5,1
    800053a0:	06f70963          	beq	a4,a5,80005412 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800053a4:	fc040993          	addi	s3,s0,-64
    800053a8:	4641                	li	a2,16
    800053aa:	4581                	li	a1,0
    800053ac:	854e                	mv	a0,s3
    800053ae:	94bfb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053b2:	4741                	li	a4,16
    800053b4:	f2c42683          	lw	a3,-212(s0)
    800053b8:	864e                	mv	a2,s3
    800053ba:	4581                	li	a1,0
    800053bc:	8526                	mv	a0,s1
    800053be:	fdefe0ef          	jal	80003b9c <writei>
    800053c2:	47c1                	li	a5,16
    800053c4:	08f51863          	bne	a0,a5,80005454 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800053c8:	04491703          	lh	a4,68(s2)
    800053cc:	4785                	li	a5,1
    800053ce:	08f70963          	beq	a4,a5,80005460 <sys_unlink+0x146>
  iunlockput(dp);
    800053d2:	8526                	mv	a0,s1
    800053d4:	d50fe0ef          	jal	80003924 <iunlockput>
  ip->nlink--;
    800053d8:	04a95783          	lhu	a5,74(s2)
    800053dc:	37fd                	addiw	a5,a5,-1
    800053de:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800053e2:	854a                	mv	a0,s2
    800053e4:	a80fe0ef          	jal	80003664 <iupdate>
  iunlockput(ip);
    800053e8:	854a                	mv	a0,s2
    800053ea:	d3afe0ef          	jal	80003924 <iunlockput>
  end_op();
    800053ee:	da7fe0ef          	jal	80004194 <end_op>
  return 0;
    800053f2:	4501                	li	a0,0
    800053f4:	64ee                	ld	s1,216(sp)
    800053f6:	694e                	ld	s2,208(sp)
    800053f8:	69ae                	ld	s3,200(sp)
    800053fa:	a061                	j	80005482 <sys_unlink+0x168>
    end_op();
    800053fc:	d99fe0ef          	jal	80004194 <end_op>
    return -1;
    80005400:	557d                	li	a0,-1
    80005402:	64ee                	ld	s1,216(sp)
    80005404:	a8bd                	j	80005482 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005406:	00002517          	auipc	a0,0x2
    8000540a:	23a50513          	addi	a0,a0,570 # 80007640 <etext+0x640>
    8000540e:	c16fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005412:	04c92703          	lw	a4,76(s2)
    80005416:	02000793          	li	a5,32
    8000541a:	f8e7f5e3          	bgeu	a5,a4,800053a4 <sys_unlink+0x8a>
    8000541e:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005420:	4741                	li	a4,16
    80005422:	86ce                	mv	a3,s3
    80005424:	f1840613          	addi	a2,s0,-232
    80005428:	4581                	li	a1,0
    8000542a:	854a                	mv	a0,s2
    8000542c:	e7efe0ef          	jal	80003aaa <readi>
    80005430:	47c1                	li	a5,16
    80005432:	00f51b63          	bne	a0,a5,80005448 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005436:	f1845783          	lhu	a5,-232(s0)
    8000543a:	ebb1                	bnez	a5,8000548e <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000543c:	29c1                	addiw	s3,s3,16
    8000543e:	04c92783          	lw	a5,76(s2)
    80005442:	fcf9efe3          	bltu	s3,a5,80005420 <sys_unlink+0x106>
    80005446:	bfb9                	j	800053a4 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005448:	00002517          	auipc	a0,0x2
    8000544c:	21050513          	addi	a0,a0,528 # 80007658 <etext+0x658>
    80005450:	bd4fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005454:	00002517          	auipc	a0,0x2
    80005458:	21c50513          	addi	a0,a0,540 # 80007670 <etext+0x670>
    8000545c:	bc8fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005460:	04a4d783          	lhu	a5,74(s1)
    80005464:	37fd                	addiw	a5,a5,-1
    80005466:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000546a:	8526                	mv	a0,s1
    8000546c:	9f8fe0ef          	jal	80003664 <iupdate>
    80005470:	b78d                	j	800053d2 <sys_unlink+0xb8>
    80005472:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005474:	8526                	mv	a0,s1
    80005476:	caefe0ef          	jal	80003924 <iunlockput>
  end_op();
    8000547a:	d1bfe0ef          	jal	80004194 <end_op>
  return -1;
    8000547e:	557d                	li	a0,-1
    80005480:	64ee                	ld	s1,216(sp)
}
    80005482:	70ae                	ld	ra,232(sp)
    80005484:	740e                	ld	s0,224(sp)
    80005486:	616d                	addi	sp,sp,240
    80005488:	8082                	ret
    return -1;
    8000548a:	557d                	li	a0,-1
    8000548c:	bfdd                	j	80005482 <sys_unlink+0x168>
    iunlockput(ip);
    8000548e:	854a                	mv	a0,s2
    80005490:	c94fe0ef          	jal	80003924 <iunlockput>
    goto bad;
    80005494:	694e                	ld	s2,208(sp)
    80005496:	69ae                	ld	s3,200(sp)
    80005498:	bff1                	j	80005474 <sys_unlink+0x15a>

000000008000549a <sys_open>:

uint64
sys_open(void)
{
    8000549a:	7131                	addi	sp,sp,-192
    8000549c:	fd06                	sd	ra,184(sp)
    8000549e:	f922                	sd	s0,176(sp)
    800054a0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800054a2:	f4c40593          	addi	a1,s0,-180
    800054a6:	4505                	li	a0,1
    800054a8:	e5cfd0ef          	jal	80002b04 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800054ac:	08000613          	li	a2,128
    800054b0:	f5040593          	addi	a1,s0,-176
    800054b4:	4501                	li	a0,0
    800054b6:	e86fd0ef          	jal	80002b3c <argstr>
    800054ba:	87aa                	mv	a5,a0
    return -1;
    800054bc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800054be:	0a07c363          	bltz	a5,80005564 <sys_open+0xca>
    800054c2:	f526                	sd	s1,168(sp)

  begin_op();
    800054c4:	c61fe0ef          	jal	80004124 <begin_op>

  if(omode & O_CREATE){
    800054c8:	f4c42783          	lw	a5,-180(s0)
    800054cc:	2007f793          	andi	a5,a5,512
    800054d0:	c3dd                	beqz	a5,80005576 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800054d2:	4681                	li	a3,0
    800054d4:	4601                	li	a2,0
    800054d6:	4589                	li	a1,2
    800054d8:	f5040513          	addi	a0,s0,-176
    800054dc:	aafff0ef          	jal	80004f8a <create>
    800054e0:	84aa                	mv	s1,a0
    if(ip == 0){
    800054e2:	c549                	beqz	a0,8000556c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800054e4:	04449703          	lh	a4,68(s1)
    800054e8:	478d                	li	a5,3
    800054ea:	00f71763          	bne	a4,a5,800054f8 <sys_open+0x5e>
    800054ee:	0464d703          	lhu	a4,70(s1)
    800054f2:	47a5                	li	a5,9
    800054f4:	0ae7ee63          	bltu	a5,a4,800055b0 <sys_open+0x116>
    800054f8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800054fa:	fabfe0ef          	jal	800044a4 <filealloc>
    800054fe:	892a                	mv	s2,a0
    80005500:	c561                	beqz	a0,800055c8 <sys_open+0x12e>
    80005502:	ed4e                	sd	s3,152(sp)
    80005504:	a47ff0ef          	jal	80004f4a <fdalloc>
    80005508:	89aa                	mv	s3,a0
    8000550a:	0a054b63          	bltz	a0,800055c0 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000550e:	04449703          	lh	a4,68(s1)
    80005512:	478d                	li	a5,3
    80005514:	0cf70363          	beq	a4,a5,800055da <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005518:	4789                	li	a5,2
    8000551a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000551e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005522:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005526:	f4c42783          	lw	a5,-180(s0)
    8000552a:	0017f713          	andi	a4,a5,1
    8000552e:	00174713          	xori	a4,a4,1
    80005532:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005536:	0037f713          	andi	a4,a5,3
    8000553a:	00e03733          	snez	a4,a4
    8000553e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005542:	4007f793          	andi	a5,a5,1024
    80005546:	c791                	beqz	a5,80005552 <sys_open+0xb8>
    80005548:	04449703          	lh	a4,68(s1)
    8000554c:	4789                	li	a5,2
    8000554e:	08f70d63          	beq	a4,a5,800055e8 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005552:	8526                	mv	a0,s1
    80005554:	a72fe0ef          	jal	800037c6 <iunlock>
  end_op();
    80005558:	c3dfe0ef          	jal	80004194 <end_op>

  return fd;
    8000555c:	854e                	mv	a0,s3
    8000555e:	74aa                	ld	s1,168(sp)
    80005560:	790a                	ld	s2,160(sp)
    80005562:	69ea                	ld	s3,152(sp)
}
    80005564:	70ea                	ld	ra,184(sp)
    80005566:	744a                	ld	s0,176(sp)
    80005568:	6129                	addi	sp,sp,192
    8000556a:	8082                	ret
      end_op();
    8000556c:	c29fe0ef          	jal	80004194 <end_op>
      return -1;
    80005570:	557d                	li	a0,-1
    80005572:	74aa                	ld	s1,168(sp)
    80005574:	bfc5                	j	80005564 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005576:	f5040513          	addi	a0,s0,-176
    8000557a:	9cdfe0ef          	jal	80003f46 <namei>
    8000557e:	84aa                	mv	s1,a0
    80005580:	c11d                	beqz	a0,800055a6 <sys_open+0x10c>
    ilock(ip);
    80005582:	996fe0ef          	jal	80003718 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005586:	04449703          	lh	a4,68(s1)
    8000558a:	4785                	li	a5,1
    8000558c:	f4f71ce3          	bne	a4,a5,800054e4 <sys_open+0x4a>
    80005590:	f4c42783          	lw	a5,-180(s0)
    80005594:	d3b5                	beqz	a5,800054f8 <sys_open+0x5e>
      iunlockput(ip);
    80005596:	8526                	mv	a0,s1
    80005598:	b8cfe0ef          	jal	80003924 <iunlockput>
      end_op();
    8000559c:	bf9fe0ef          	jal	80004194 <end_op>
      return -1;
    800055a0:	557d                	li	a0,-1
    800055a2:	74aa                	ld	s1,168(sp)
    800055a4:	b7c1                	j	80005564 <sys_open+0xca>
      end_op();
    800055a6:	beffe0ef          	jal	80004194 <end_op>
      return -1;
    800055aa:	557d                	li	a0,-1
    800055ac:	74aa                	ld	s1,168(sp)
    800055ae:	bf5d                	j	80005564 <sys_open+0xca>
    iunlockput(ip);
    800055b0:	8526                	mv	a0,s1
    800055b2:	b72fe0ef          	jal	80003924 <iunlockput>
    end_op();
    800055b6:	bdffe0ef          	jal	80004194 <end_op>
    return -1;
    800055ba:	557d                	li	a0,-1
    800055bc:	74aa                	ld	s1,168(sp)
    800055be:	b75d                	j	80005564 <sys_open+0xca>
      fileclose(f);
    800055c0:	854a                	mv	a0,s2
    800055c2:	f87fe0ef          	jal	80004548 <fileclose>
    800055c6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800055c8:	8526                	mv	a0,s1
    800055ca:	b5afe0ef          	jal	80003924 <iunlockput>
    end_op();
    800055ce:	bc7fe0ef          	jal	80004194 <end_op>
    return -1;
    800055d2:	557d                	li	a0,-1
    800055d4:	74aa                	ld	s1,168(sp)
    800055d6:	790a                	ld	s2,160(sp)
    800055d8:	b771                	j	80005564 <sys_open+0xca>
    f->type = FD_DEVICE;
    800055da:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800055de:	04649783          	lh	a5,70(s1)
    800055e2:	02f91223          	sh	a5,36(s2)
    800055e6:	bf35                	j	80005522 <sys_open+0x88>
    itrunc(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	a1cfe0ef          	jal	80003806 <itrunc>
    800055ee:	b795                	j	80005552 <sys_open+0xb8>

00000000800055f0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800055f0:	7175                	addi	sp,sp,-144
    800055f2:	e506                	sd	ra,136(sp)
    800055f4:	e122                	sd	s0,128(sp)
    800055f6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800055f8:	b2dfe0ef          	jal	80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800055fc:	08000613          	li	a2,128
    80005600:	f7040593          	addi	a1,s0,-144
    80005604:	4501                	li	a0,0
    80005606:	d36fd0ef          	jal	80002b3c <argstr>
    8000560a:	02054363          	bltz	a0,80005630 <sys_mkdir+0x40>
    8000560e:	4681                	li	a3,0
    80005610:	4601                	li	a2,0
    80005612:	4585                	li	a1,1
    80005614:	f7040513          	addi	a0,s0,-144
    80005618:	973ff0ef          	jal	80004f8a <create>
    8000561c:	c911                	beqz	a0,80005630 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000561e:	b06fe0ef          	jal	80003924 <iunlockput>
  end_op();
    80005622:	b73fe0ef          	jal	80004194 <end_op>
  return 0;
    80005626:	4501                	li	a0,0
}
    80005628:	60aa                	ld	ra,136(sp)
    8000562a:	640a                	ld	s0,128(sp)
    8000562c:	6149                	addi	sp,sp,144
    8000562e:	8082                	ret
    end_op();
    80005630:	b65fe0ef          	jal	80004194 <end_op>
    return -1;
    80005634:	557d                	li	a0,-1
    80005636:	bfcd                	j	80005628 <sys_mkdir+0x38>

0000000080005638 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005638:	7135                	addi	sp,sp,-160
    8000563a:	ed06                	sd	ra,152(sp)
    8000563c:	e922                	sd	s0,144(sp)
    8000563e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005640:	ae5fe0ef          	jal	80004124 <begin_op>
  argint(1, &major);
    80005644:	f6c40593          	addi	a1,s0,-148
    80005648:	4505                	li	a0,1
    8000564a:	cbafd0ef          	jal	80002b04 <argint>
  argint(2, &minor);
    8000564e:	f6840593          	addi	a1,s0,-152
    80005652:	4509                	li	a0,2
    80005654:	cb0fd0ef          	jal	80002b04 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005658:	08000613          	li	a2,128
    8000565c:	f7040593          	addi	a1,s0,-144
    80005660:	4501                	li	a0,0
    80005662:	cdafd0ef          	jal	80002b3c <argstr>
    80005666:	02054563          	bltz	a0,80005690 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000566a:	f6841683          	lh	a3,-152(s0)
    8000566e:	f6c41603          	lh	a2,-148(s0)
    80005672:	458d                	li	a1,3
    80005674:	f7040513          	addi	a0,s0,-144
    80005678:	913ff0ef          	jal	80004f8a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000567c:	c911                	beqz	a0,80005690 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000567e:	aa6fe0ef          	jal	80003924 <iunlockput>
  end_op();
    80005682:	b13fe0ef          	jal	80004194 <end_op>
  return 0;
    80005686:	4501                	li	a0,0
}
    80005688:	60ea                	ld	ra,152(sp)
    8000568a:	644a                	ld	s0,144(sp)
    8000568c:	610d                	addi	sp,sp,160
    8000568e:	8082                	ret
    end_op();
    80005690:	b05fe0ef          	jal	80004194 <end_op>
    return -1;
    80005694:	557d                	li	a0,-1
    80005696:	bfcd                	j	80005688 <sys_mknod+0x50>

0000000080005698 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005698:	7135                	addi	sp,sp,-160
    8000569a:	ed06                	sd	ra,152(sp)
    8000569c:	e922                	sd	s0,144(sp)
    8000569e:	e14a                	sd	s2,128(sp)
    800056a0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800056a2:	a94fc0ef          	jal	80001936 <myproc>
    800056a6:	892a                	mv	s2,a0
  
  begin_op();
    800056a8:	a7dfe0ef          	jal	80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800056ac:	08000613          	li	a2,128
    800056b0:	f6040593          	addi	a1,s0,-160
    800056b4:	4501                	li	a0,0
    800056b6:	c86fd0ef          	jal	80002b3c <argstr>
    800056ba:	04054363          	bltz	a0,80005700 <sys_chdir+0x68>
    800056be:	e526                	sd	s1,136(sp)
    800056c0:	f6040513          	addi	a0,s0,-160
    800056c4:	883fe0ef          	jal	80003f46 <namei>
    800056c8:	84aa                	mv	s1,a0
    800056ca:	c915                	beqz	a0,800056fe <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800056cc:	84cfe0ef          	jal	80003718 <ilock>
  if(ip->type != T_DIR){
    800056d0:	04449703          	lh	a4,68(s1)
    800056d4:	4785                	li	a5,1
    800056d6:	02f71963          	bne	a4,a5,80005708 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800056da:	8526                	mv	a0,s1
    800056dc:	8eafe0ef          	jal	800037c6 <iunlock>
  iput(p->cwd);
    800056e0:	17093503          	ld	a0,368(s2)
    800056e4:	9b6fe0ef          	jal	8000389a <iput>
  end_op();
    800056e8:	aadfe0ef          	jal	80004194 <end_op>
  p->cwd = ip;
    800056ec:	16993823          	sd	s1,368(s2)
  return 0;
    800056f0:	4501                	li	a0,0
    800056f2:	64aa                	ld	s1,136(sp)
}
    800056f4:	60ea                	ld	ra,152(sp)
    800056f6:	644a                	ld	s0,144(sp)
    800056f8:	690a                	ld	s2,128(sp)
    800056fa:	610d                	addi	sp,sp,160
    800056fc:	8082                	ret
    800056fe:	64aa                	ld	s1,136(sp)
    end_op();
    80005700:	a95fe0ef          	jal	80004194 <end_op>
    return -1;
    80005704:	557d                	li	a0,-1
    80005706:	b7fd                	j	800056f4 <sys_chdir+0x5c>
    iunlockput(ip);
    80005708:	8526                	mv	a0,s1
    8000570a:	a1afe0ef          	jal	80003924 <iunlockput>
    end_op();
    8000570e:	a87fe0ef          	jal	80004194 <end_op>
    return -1;
    80005712:	557d                	li	a0,-1
    80005714:	64aa                	ld	s1,136(sp)
    80005716:	bff9                	j	800056f4 <sys_chdir+0x5c>

0000000080005718 <sys_exec>:

uint64
sys_exec(void)
{
    80005718:	7105                	addi	sp,sp,-480
    8000571a:	ef86                	sd	ra,472(sp)
    8000571c:	eba2                	sd	s0,464(sp)
    8000571e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005720:	e2840593          	addi	a1,s0,-472
    80005724:	4505                	li	a0,1
    80005726:	bfafd0ef          	jal	80002b20 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000572a:	08000613          	li	a2,128
    8000572e:	f3040593          	addi	a1,s0,-208
    80005732:	4501                	li	a0,0
    80005734:	c08fd0ef          	jal	80002b3c <argstr>
    80005738:	87aa                	mv	a5,a0
    return -1;
    8000573a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000573c:	0e07c063          	bltz	a5,8000581c <sys_exec+0x104>
    80005740:	e7a6                	sd	s1,456(sp)
    80005742:	e3ca                	sd	s2,448(sp)
    80005744:	ff4e                	sd	s3,440(sp)
    80005746:	fb52                	sd	s4,432(sp)
    80005748:	f756                	sd	s5,424(sp)
    8000574a:	f35a                	sd	s6,416(sp)
    8000574c:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000574e:	e3040a13          	addi	s4,s0,-464
    80005752:	10000613          	li	a2,256
    80005756:	4581                	li	a1,0
    80005758:	8552                	mv	a0,s4
    8000575a:	d9efb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000575e:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005760:	89d2                	mv	s3,s4
    80005762:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005764:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005768:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000576a:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000576e:	00391513          	slli	a0,s2,0x3
    80005772:	85d6                	mv	a1,s5
    80005774:	e2843783          	ld	a5,-472(s0)
    80005778:	953e                	add	a0,a0,a5
    8000577a:	b00fd0ef          	jal	80002a7a <fetchaddr>
    8000577e:	02054663          	bltz	a0,800057aa <sys_exec+0x92>
    if(uarg == 0){
    80005782:	e2043783          	ld	a5,-480(s0)
    80005786:	c7a1                	beqz	a5,800057ce <sys_exec+0xb6>
    argv[i] = kalloc();
    80005788:	bbcfb0ef          	jal	80000b44 <kalloc>
    8000578c:	85aa                	mv	a1,a0
    8000578e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005792:	cd01                	beqz	a0,800057aa <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005794:	865a                	mv	a2,s6
    80005796:	e2043503          	ld	a0,-480(s0)
    8000579a:	b2afd0ef          	jal	80002ac4 <fetchstr>
    8000579e:	00054663          	bltz	a0,800057aa <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800057a2:	0905                	addi	s2,s2,1
    800057a4:	09a1                	addi	s3,s3,8
    800057a6:	fd7914e3          	bne	s2,s7,8000576e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057aa:	100a0a13          	addi	s4,s4,256
    800057ae:	6088                	ld	a0,0(s1)
    800057b0:	cd31                	beqz	a0,8000580c <sys_exec+0xf4>
    kfree(argv[i]);
    800057b2:	aaafb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057b6:	04a1                	addi	s1,s1,8
    800057b8:	ff449be3          	bne	s1,s4,800057ae <sys_exec+0x96>
  return -1;
    800057bc:	557d                	li	a0,-1
    800057be:	64be                	ld	s1,456(sp)
    800057c0:	691e                	ld	s2,448(sp)
    800057c2:	79fa                	ld	s3,440(sp)
    800057c4:	7a5a                	ld	s4,432(sp)
    800057c6:	7aba                	ld	s5,424(sp)
    800057c8:	7b1a                	ld	s6,416(sp)
    800057ca:	6bfa                	ld	s7,408(sp)
    800057cc:	a881                	j	8000581c <sys_exec+0x104>
      argv[i] = 0;
    800057ce:	0009079b          	sext.w	a5,s2
    800057d2:	e3040593          	addi	a1,s0,-464
    800057d6:	078e                	slli	a5,a5,0x3
    800057d8:	97ae                	add	a5,a5,a1
    800057da:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800057de:	f3040513          	addi	a0,s0,-208
    800057e2:	bb2ff0ef          	jal	80004b94 <kexec>
    800057e6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057e8:	100a0a13          	addi	s4,s4,256
    800057ec:	6088                	ld	a0,0(s1)
    800057ee:	c511                	beqz	a0,800057fa <sys_exec+0xe2>
    kfree(argv[i]);
    800057f0:	a6cfb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057f4:	04a1                	addi	s1,s1,8
    800057f6:	ff449be3          	bne	s1,s4,800057ec <sys_exec+0xd4>
  return ret;
    800057fa:	854a                	mv	a0,s2
    800057fc:	64be                	ld	s1,456(sp)
    800057fe:	691e                	ld	s2,448(sp)
    80005800:	79fa                	ld	s3,440(sp)
    80005802:	7a5a                	ld	s4,432(sp)
    80005804:	7aba                	ld	s5,424(sp)
    80005806:	7b1a                	ld	s6,416(sp)
    80005808:	6bfa                	ld	s7,408(sp)
    8000580a:	a809                	j	8000581c <sys_exec+0x104>
  return -1;
    8000580c:	557d                	li	a0,-1
    8000580e:	64be                	ld	s1,456(sp)
    80005810:	691e                	ld	s2,448(sp)
    80005812:	79fa                	ld	s3,440(sp)
    80005814:	7a5a                	ld	s4,432(sp)
    80005816:	7aba                	ld	s5,424(sp)
    80005818:	7b1a                	ld	s6,416(sp)
    8000581a:	6bfa                	ld	s7,408(sp)
}
    8000581c:	60fe                	ld	ra,472(sp)
    8000581e:	645e                	ld	s0,464(sp)
    80005820:	613d                	addi	sp,sp,480
    80005822:	8082                	ret

0000000080005824 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005824:	7139                	addi	sp,sp,-64
    80005826:	fc06                	sd	ra,56(sp)
    80005828:	f822                	sd	s0,48(sp)
    8000582a:	f426                	sd	s1,40(sp)
    8000582c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000582e:	908fc0ef          	jal	80001936 <myproc>
    80005832:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005834:	fd840593          	addi	a1,s0,-40
    80005838:	4501                	li	a0,0
    8000583a:	ae6fd0ef          	jal	80002b20 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000583e:	fc840593          	addi	a1,s0,-56
    80005842:	fd040513          	addi	a0,s0,-48
    80005846:	81eff0ef          	jal	80004864 <pipealloc>
    return -1;
    8000584a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000584c:	0a054763          	bltz	a0,800058fa <sys_pipe+0xd6>
  fd0 = -1;
    80005850:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005854:	fd043503          	ld	a0,-48(s0)
    80005858:	ef2ff0ef          	jal	80004f4a <fdalloc>
    8000585c:	fca42223          	sw	a0,-60(s0)
    80005860:	08054463          	bltz	a0,800058e8 <sys_pipe+0xc4>
    80005864:	fc843503          	ld	a0,-56(s0)
    80005868:	ee2ff0ef          	jal	80004f4a <fdalloc>
    8000586c:	fca42023          	sw	a0,-64(s0)
    80005870:	06054263          	bltz	a0,800058d4 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005874:	4691                	li	a3,4
    80005876:	fc440613          	addi	a2,s0,-60
    8000587a:	fd843583          	ld	a1,-40(s0)
    8000587e:	78a8                	ld	a0,112(s1)
    80005880:	dd5fb0ef          	jal	80001654 <copyout>
    80005884:	00054e63          	bltz	a0,800058a0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005888:	4691                	li	a3,4
    8000588a:	fc040613          	addi	a2,s0,-64
    8000588e:	fd843583          	ld	a1,-40(s0)
    80005892:	95b6                	add	a1,a1,a3
    80005894:	78a8                	ld	a0,112(s1)
    80005896:	dbffb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000589a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000589c:	04055f63          	bgez	a0,800058fa <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800058a0:	fc442783          	lw	a5,-60(s0)
    800058a4:	078e                	slli	a5,a5,0x3
    800058a6:	0f078793          	addi	a5,a5,240
    800058aa:	97a6                	add	a5,a5,s1
    800058ac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800058b0:	fc042783          	lw	a5,-64(s0)
    800058b4:	078e                	slli	a5,a5,0x3
    800058b6:	0f078793          	addi	a5,a5,240
    800058ba:	97a6                	add	a5,a5,s1
    800058bc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800058c0:	fd043503          	ld	a0,-48(s0)
    800058c4:	c85fe0ef          	jal	80004548 <fileclose>
    fileclose(wf);
    800058c8:	fc843503          	ld	a0,-56(s0)
    800058cc:	c7dfe0ef          	jal	80004548 <fileclose>
    return -1;
    800058d0:	57fd                	li	a5,-1
    800058d2:	a025                	j	800058fa <sys_pipe+0xd6>
    if(fd0 >= 0)
    800058d4:	fc442783          	lw	a5,-60(s0)
    800058d8:	0007c863          	bltz	a5,800058e8 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800058dc:	078e                	slli	a5,a5,0x3
    800058de:	0f078793          	addi	a5,a5,240
    800058e2:	97a6                	add	a5,a5,s1
    800058e4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800058e8:	fd043503          	ld	a0,-48(s0)
    800058ec:	c5dfe0ef          	jal	80004548 <fileclose>
    fileclose(wf);
    800058f0:	fc843503          	ld	a0,-56(s0)
    800058f4:	c55fe0ef          	jal	80004548 <fileclose>
    return -1;
    800058f8:	57fd                	li	a5,-1
}
    800058fa:	853e                	mv	a0,a5
    800058fc:	70e2                	ld	ra,56(sp)
    800058fe:	7442                	ld	s0,48(sp)
    80005900:	74a2                	ld	s1,40(sp)
    80005902:	6121                	addi	sp,sp,64
    80005904:	8082                	ret
	...

0000000080005910 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005910:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005912:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005914:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005916:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005918:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000591a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000591c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000591e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005920:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005922:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005924:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005926:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005928:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000592a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000592c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000592e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005930:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005932:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005934:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005936:	83afd0ef          	jal	80002970 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000593a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000593c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000593e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005940:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005942:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005944:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005946:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005948:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000594a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000594c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000594e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005950:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005952:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005954:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005956:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005958:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000595a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000595c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000595e:	10200073          	sret
    80005962:	00000013          	nop
    80005966:	00000013          	nop
    8000596a:	00000013          	nop

000000008000596e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000596e:	1141                	addi	sp,sp,-16
    80005970:	e406                	sd	ra,8(sp)
    80005972:	e022                	sd	s0,0(sp)
    80005974:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005976:	0c000737          	lui	a4,0xc000
    8000597a:	4785                	li	a5,1
    8000597c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000597e:	c35c                	sw	a5,4(a4)
}
    80005980:	60a2                	ld	ra,8(sp)
    80005982:	6402                	ld	s0,0(sp)
    80005984:	0141                	addi	sp,sp,16
    80005986:	8082                	ret

0000000080005988 <plicinithart>:

void
plicinithart(void)
{
    80005988:	1141                	addi	sp,sp,-16
    8000598a:	e406                	sd	ra,8(sp)
    8000598c:	e022                	sd	s0,0(sp)
    8000598e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005990:	f73fb0ef          	jal	80001902 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005994:	0085171b          	slliw	a4,a0,0x8
    80005998:	0c0027b7          	lui	a5,0xc002
    8000599c:	97ba                	add	a5,a5,a4
    8000599e:	40200713          	li	a4,1026
    800059a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800059a6:	00d5151b          	slliw	a0,a0,0xd
    800059aa:	0c2017b7          	lui	a5,0xc201
    800059ae:	97aa                	add	a5,a5,a0
    800059b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800059b4:	60a2                	ld	ra,8(sp)
    800059b6:	6402                	ld	s0,0(sp)
    800059b8:	0141                	addi	sp,sp,16
    800059ba:	8082                	ret

00000000800059bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800059bc:	1141                	addi	sp,sp,-16
    800059be:	e406                	sd	ra,8(sp)
    800059c0:	e022                	sd	s0,0(sp)
    800059c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059c4:	f3ffb0ef          	jal	80001902 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800059c8:	00d5151b          	slliw	a0,a0,0xd
    800059cc:	0c2017b7          	lui	a5,0xc201
    800059d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800059d2:	43c8                	lw	a0,4(a5)
    800059d4:	60a2                	ld	ra,8(sp)
    800059d6:	6402                	ld	s0,0(sp)
    800059d8:	0141                	addi	sp,sp,16
    800059da:	8082                	ret

00000000800059dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800059dc:	1101                	addi	sp,sp,-32
    800059de:	ec06                	sd	ra,24(sp)
    800059e0:	e822                	sd	s0,16(sp)
    800059e2:	e426                	sd	s1,8(sp)
    800059e4:	1000                	addi	s0,sp,32
    800059e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800059e8:	f1bfb0ef          	jal	80001902 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800059ec:	00d5179b          	slliw	a5,a0,0xd
    800059f0:	0c201737          	lui	a4,0xc201
    800059f4:	97ba                	add	a5,a5,a4
    800059f6:	c3c4                	sw	s1,4(a5)
}
    800059f8:	60e2                	ld	ra,24(sp)
    800059fa:	6442                	ld	s0,16(sp)
    800059fc:	64a2                	ld	s1,8(sp)
    800059fe:	6105                	addi	sp,sp,32
    80005a00:	8082                	ret

0000000080005a02 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a02:	1141                	addi	sp,sp,-16
    80005a04:	e406                	sd	ra,8(sp)
    80005a06:	e022                	sd	s0,0(sp)
    80005a08:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a0a:	479d                	li	a5,7
    80005a0c:	04a7ca63          	blt	a5,a0,80005a60 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005a10:	0001c797          	auipc	a5,0x1c
    80005a14:	10078793          	addi	a5,a5,256 # 80021b10 <disk>
    80005a18:	97aa                	add	a5,a5,a0
    80005a1a:	0187c783          	lbu	a5,24(a5)
    80005a1e:	e7b9                	bnez	a5,80005a6c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a20:	00451693          	slli	a3,a0,0x4
    80005a24:	0001c797          	auipc	a5,0x1c
    80005a28:	0ec78793          	addi	a5,a5,236 # 80021b10 <disk>
    80005a2c:	6398                	ld	a4,0(a5)
    80005a2e:	9736                	add	a4,a4,a3
    80005a30:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005a34:	6398                	ld	a4,0(a5)
    80005a36:	9736                	add	a4,a4,a3
    80005a38:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005a3c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005a40:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005a44:	97aa                	add	a5,a5,a0
    80005a46:	4705                	li	a4,1
    80005a48:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005a4c:	0001c517          	auipc	a0,0x1c
    80005a50:	0dc50513          	addi	a0,a0,220 # 80021b28 <disk+0x18>
    80005a54:	a33fc0ef          	jal	80002486 <wakeup>
}
    80005a58:	60a2                	ld	ra,8(sp)
    80005a5a:	6402                	ld	s0,0(sp)
    80005a5c:	0141                	addi	sp,sp,16
    80005a5e:	8082                	ret
    panic("free_desc 1");
    80005a60:	00002517          	auipc	a0,0x2
    80005a64:	c2050513          	addi	a0,a0,-992 # 80007680 <etext+0x680>
    80005a68:	dbdfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    80005a6c:	00002517          	auipc	a0,0x2
    80005a70:	c2450513          	addi	a0,a0,-988 # 80007690 <etext+0x690>
    80005a74:	db1fa0ef          	jal	80000824 <panic>

0000000080005a78 <virtio_disk_init>:
{
    80005a78:	1101                	addi	sp,sp,-32
    80005a7a:	ec06                	sd	ra,24(sp)
    80005a7c:	e822                	sd	s0,16(sp)
    80005a7e:	e426                	sd	s1,8(sp)
    80005a80:	e04a                	sd	s2,0(sp)
    80005a82:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005a84:	00002597          	auipc	a1,0x2
    80005a88:	c1c58593          	addi	a1,a1,-996 # 800076a0 <etext+0x6a0>
    80005a8c:	0001c517          	auipc	a0,0x1c
    80005a90:	1ac50513          	addi	a0,a0,428 # 80021c38 <disk+0x128>
    80005a94:	90afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a98:	100017b7          	lui	a5,0x10001
    80005a9c:	4398                	lw	a4,0(a5)
    80005a9e:	2701                	sext.w	a4,a4
    80005aa0:	747277b7          	lui	a5,0x74727
    80005aa4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005aa8:	14f71863          	bne	a4,a5,80005bf8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005aac:	100017b7          	lui	a5,0x10001
    80005ab0:	43dc                	lw	a5,4(a5)
    80005ab2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ab4:	4709                	li	a4,2
    80005ab6:	14e79163          	bne	a5,a4,80005bf8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005aba:	100017b7          	lui	a5,0x10001
    80005abe:	479c                	lw	a5,8(a5)
    80005ac0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ac2:	12e79b63          	bne	a5,a4,80005bf8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005ac6:	100017b7          	lui	a5,0x10001
    80005aca:	47d8                	lw	a4,12(a5)
    80005acc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ace:	554d47b7          	lui	a5,0x554d4
    80005ad2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ad6:	12f71163          	bne	a4,a5,80005bf8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ada:	100017b7          	lui	a5,0x10001
    80005ade:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ae2:	4705                	li	a4,1
    80005ae4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ae6:	470d                	li	a4,3
    80005ae8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005aea:	10001737          	lui	a4,0x10001
    80005aee:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005af0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005af4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdcb0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005af8:	8f75                	and	a4,a4,a3
    80005afa:	100016b7          	lui	a3,0x10001
    80005afe:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b00:	472d                	li	a4,11
    80005b02:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b04:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b08:	439c                	lw	a5,0(a5)
    80005b0a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b0e:	8ba1                	andi	a5,a5,8
    80005b10:	0e078a63          	beqz	a5,80005c04 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b14:	100017b7          	lui	a5,0x10001
    80005b18:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005b1c:	43fc                	lw	a5,68(a5)
    80005b1e:	2781                	sext.w	a5,a5
    80005b20:	0e079863          	bnez	a5,80005c10 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b24:	100017b7          	lui	a5,0x10001
    80005b28:	5bdc                	lw	a5,52(a5)
    80005b2a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005b2c:	0e078863          	beqz	a5,80005c1c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005b30:	471d                	li	a4,7
    80005b32:	0ef77b63          	bgeu	a4,a5,80005c28 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005b36:	80efb0ef          	jal	80000b44 <kalloc>
    80005b3a:	0001c497          	auipc	s1,0x1c
    80005b3e:	fd648493          	addi	s1,s1,-42 # 80021b10 <disk>
    80005b42:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005b44:	800fb0ef          	jal	80000b44 <kalloc>
    80005b48:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005b4a:	ffbfa0ef          	jal	80000b44 <kalloc>
    80005b4e:	87aa                	mv	a5,a0
    80005b50:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005b52:	6088                	ld	a0,0(s1)
    80005b54:	0e050063          	beqz	a0,80005c34 <virtio_disk_init+0x1bc>
    80005b58:	0001c717          	auipc	a4,0x1c
    80005b5c:	fc073703          	ld	a4,-64(a4) # 80021b18 <disk+0x8>
    80005b60:	cb71                	beqz	a4,80005c34 <virtio_disk_init+0x1bc>
    80005b62:	cbe9                	beqz	a5,80005c34 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005b64:	6605                	lui	a2,0x1
    80005b66:	4581                	li	a1,0
    80005b68:	990fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005b6c:	0001c497          	auipc	s1,0x1c
    80005b70:	fa448493          	addi	s1,s1,-92 # 80021b10 <disk>
    80005b74:	6605                	lui	a2,0x1
    80005b76:	4581                	li	a1,0
    80005b78:	6488                	ld	a0,8(s1)
    80005b7a:	97efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005b7e:	6605                	lui	a2,0x1
    80005b80:	4581                	li	a1,0
    80005b82:	6888                	ld	a0,16(s1)
    80005b84:	974fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005b88:	100017b7          	lui	a5,0x10001
    80005b8c:	4721                	li	a4,8
    80005b8e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005b90:	4098                	lw	a4,0(s1)
    80005b92:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005b96:	40d8                	lw	a4,4(s1)
    80005b98:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005b9c:	649c                	ld	a5,8(s1)
    80005b9e:	0007869b          	sext.w	a3,a5
    80005ba2:	10001737          	lui	a4,0x10001
    80005ba6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005baa:	9781                	srai	a5,a5,0x20
    80005bac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005bb0:	689c                	ld	a5,16(s1)
    80005bb2:	0007869b          	sext.w	a3,a5
    80005bb6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005bba:	9781                	srai	a5,a5,0x20
    80005bbc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005bc0:	4785                	li	a5,1
    80005bc2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005bc4:	00f48c23          	sb	a5,24(s1)
    80005bc8:	00f48ca3          	sb	a5,25(s1)
    80005bcc:	00f48d23          	sb	a5,26(s1)
    80005bd0:	00f48da3          	sb	a5,27(s1)
    80005bd4:	00f48e23          	sb	a5,28(s1)
    80005bd8:	00f48ea3          	sb	a5,29(s1)
    80005bdc:	00f48f23          	sb	a5,30(s1)
    80005be0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005be4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005be8:	07272823          	sw	s2,112(a4)
}
    80005bec:	60e2                	ld	ra,24(sp)
    80005bee:	6442                	ld	s0,16(sp)
    80005bf0:	64a2                	ld	s1,8(sp)
    80005bf2:	6902                	ld	s2,0(sp)
    80005bf4:	6105                	addi	sp,sp,32
    80005bf6:	8082                	ret
    panic("could not find virtio disk");
    80005bf8:	00002517          	auipc	a0,0x2
    80005bfc:	ab850513          	addi	a0,a0,-1352 # 800076b0 <etext+0x6b0>
    80005c00:	c25fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c04:	00002517          	auipc	a0,0x2
    80005c08:	acc50513          	addi	a0,a0,-1332 # 800076d0 <etext+0x6d0>
    80005c0c:	c19fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005c10:	00002517          	auipc	a0,0x2
    80005c14:	ae050513          	addi	a0,a0,-1312 # 800076f0 <etext+0x6f0>
    80005c18:	c0dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005c1c:	00002517          	auipc	a0,0x2
    80005c20:	af450513          	addi	a0,a0,-1292 # 80007710 <etext+0x710>
    80005c24:	c01fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005c28:	00002517          	auipc	a0,0x2
    80005c2c:	b0850513          	addi	a0,a0,-1272 # 80007730 <etext+0x730>
    80005c30:	bf5fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005c34:	00002517          	auipc	a0,0x2
    80005c38:	b1c50513          	addi	a0,a0,-1252 # 80007750 <etext+0x750>
    80005c3c:	be9fa0ef          	jal	80000824 <panic>

0000000080005c40 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005c40:	711d                	addi	sp,sp,-96
    80005c42:	ec86                	sd	ra,88(sp)
    80005c44:	e8a2                	sd	s0,80(sp)
    80005c46:	e4a6                	sd	s1,72(sp)
    80005c48:	e0ca                	sd	s2,64(sp)
    80005c4a:	fc4e                	sd	s3,56(sp)
    80005c4c:	f852                	sd	s4,48(sp)
    80005c4e:	f456                	sd	s5,40(sp)
    80005c50:	f05a                	sd	s6,32(sp)
    80005c52:	ec5e                	sd	s7,24(sp)
    80005c54:	e862                	sd	s8,16(sp)
    80005c56:	1080                	addi	s0,sp,96
    80005c58:	89aa                	mv	s3,a0
    80005c5a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005c5c:	00c52b83          	lw	s7,12(a0)
    80005c60:	001b9b9b          	slliw	s7,s7,0x1
    80005c64:	1b82                	slli	s7,s7,0x20
    80005c66:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005c6a:	0001c517          	auipc	a0,0x1c
    80005c6e:	fce50513          	addi	a0,a0,-50 # 80021c38 <disk+0x128>
    80005c72:	fb7fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005c76:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005c78:	0001ca97          	auipc	s5,0x1c
    80005c7c:	e98a8a93          	addi	s5,s5,-360 # 80021b10 <disk>
  for(int i = 0; i < 3; i++){
    80005c80:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005c82:	5c7d                	li	s8,-1
    80005c84:	a095                	j	80005ce8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005c86:	00fa8733          	add	a4,s5,a5
    80005c8a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005c8e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005c90:	0207c563          	bltz	a5,80005cba <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005c94:	2905                	addiw	s2,s2,1
    80005c96:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005c98:	05490c63          	beq	s2,s4,80005cf0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005c9c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005c9e:	0001c717          	auipc	a4,0x1c
    80005ca2:	e7270713          	addi	a4,a4,-398 # 80021b10 <disk>
    80005ca6:	4781                	li	a5,0
    if(disk.free[i]){
    80005ca8:	01874683          	lbu	a3,24(a4)
    80005cac:	fee9                	bnez	a3,80005c86 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005cae:	2785                	addiw	a5,a5,1
    80005cb0:	0705                	addi	a4,a4,1
    80005cb2:	fe979be3          	bne	a5,s1,80005ca8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005cb6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005cba:	01205d63          	blez	s2,80005cd4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005cbe:	fa042503          	lw	a0,-96(s0)
    80005cc2:	d41ff0ef          	jal	80005a02 <free_desc>
      for(int j = 0; j < i; j++)
    80005cc6:	4785                	li	a5,1
    80005cc8:	0127d663          	bge	a5,s2,80005cd4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ccc:	fa442503          	lw	a0,-92(s0)
    80005cd0:	d33ff0ef          	jal	80005a02 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005cd4:	0001c597          	auipc	a1,0x1c
    80005cd8:	f6458593          	addi	a1,a1,-156 # 80021c38 <disk+0x128>
    80005cdc:	0001c517          	auipc	a0,0x1c
    80005ce0:	e4c50513          	addi	a0,a0,-436 # 80021b28 <disk+0x18>
    80005ce4:	862fc0ef          	jal	80001d46 <sleep>
  for(int i = 0; i < 3; i++){
    80005ce8:	fa040613          	addi	a2,s0,-96
    80005cec:	4901                	li	s2,0
    80005cee:	b77d                	j	80005c9c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005cf0:	fa042503          	lw	a0,-96(s0)
    80005cf4:	00451693          	slli	a3,a0,0x4

  if(write)
    80005cf8:	0001c797          	auipc	a5,0x1c
    80005cfc:	e1878793          	addi	a5,a5,-488 # 80021b10 <disk>
    80005d00:	00451713          	slli	a4,a0,0x4
    80005d04:	0a070713          	addi	a4,a4,160
    80005d08:	973e                	add	a4,a4,a5
    80005d0a:	01603633          	snez	a2,s6
    80005d0e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005d10:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005d14:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d18:	6398                	ld	a4,0(a5)
    80005d1a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d1c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005d20:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005d22:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005d24:	6390                	ld	a2,0(a5)
    80005d26:	00d60833          	add	a6,a2,a3
    80005d2a:	4741                	li	a4,16
    80005d2c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005d30:	4585                	li	a1,1
    80005d32:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005d36:	fa442703          	lw	a4,-92(s0)
    80005d3a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005d3e:	0712                	slli	a4,a4,0x4
    80005d40:	963a                	add	a2,a2,a4
    80005d42:	05898813          	addi	a6,s3,88
    80005d46:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005d4a:	0007b883          	ld	a7,0(a5)
    80005d4e:	9746                	add	a4,a4,a7
    80005d50:	40000613          	li	a2,1024
    80005d54:	c710                	sw	a2,8(a4)
  if(write)
    80005d56:	001b3613          	seqz	a2,s6
    80005d5a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005d5e:	8e4d                	or	a2,a2,a1
    80005d60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005d64:	fa842603          	lw	a2,-88(s0)
    80005d68:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005d6c:	00451813          	slli	a6,a0,0x4
    80005d70:	02080813          	addi	a6,a6,32
    80005d74:	983e                	add	a6,a6,a5
    80005d76:	577d                	li	a4,-1
    80005d78:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005d7c:	0612                	slli	a2,a2,0x4
    80005d7e:	98b2                	add	a7,a7,a2
    80005d80:	03068713          	addi	a4,a3,48
    80005d84:	973e                	add	a4,a4,a5
    80005d86:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005d8a:	6398                	ld	a4,0(a5)
    80005d8c:	9732                	add	a4,a4,a2
    80005d8e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005d90:	4689                	li	a3,2
    80005d92:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005d96:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005d9a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005d9e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005da2:	6794                	ld	a3,8(a5)
    80005da4:	0026d703          	lhu	a4,2(a3)
    80005da8:	8b1d                	andi	a4,a4,7
    80005daa:	0706                	slli	a4,a4,0x1
    80005dac:	96ba                	add	a3,a3,a4
    80005dae:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005db2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005db6:	6798                	ld	a4,8(a5)
    80005db8:	00275783          	lhu	a5,2(a4)
    80005dbc:	2785                	addiw	a5,a5,1
    80005dbe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005dc2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005dc6:	100017b7          	lui	a5,0x10001
    80005dca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005dce:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005dd2:	0001c917          	auipc	s2,0x1c
    80005dd6:	e6690913          	addi	s2,s2,-410 # 80021c38 <disk+0x128>
  while(b->disk == 1) {
    80005dda:	84ae                	mv	s1,a1
    80005ddc:	00b79a63          	bne	a5,a1,80005df0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005de0:	85ca                	mv	a1,s2
    80005de2:	854e                	mv	a0,s3
    80005de4:	f63fb0ef          	jal	80001d46 <sleep>
  while(b->disk == 1) {
    80005de8:	0049a783          	lw	a5,4(s3)
    80005dec:	fe978ae3          	beq	a5,s1,80005de0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005df0:	fa042903          	lw	s2,-96(s0)
    80005df4:	00491713          	slli	a4,s2,0x4
    80005df8:	02070713          	addi	a4,a4,32
    80005dfc:	0001c797          	auipc	a5,0x1c
    80005e00:	d1478793          	addi	a5,a5,-748 # 80021b10 <disk>
    80005e04:	97ba                	add	a5,a5,a4
    80005e06:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e0a:	0001c997          	auipc	s3,0x1c
    80005e0e:	d0698993          	addi	s3,s3,-762 # 80021b10 <disk>
    80005e12:	00491713          	slli	a4,s2,0x4
    80005e16:	0009b783          	ld	a5,0(s3)
    80005e1a:	97ba                	add	a5,a5,a4
    80005e1c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005e20:	854a                	mv	a0,s2
    80005e22:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005e26:	bddff0ef          	jal	80005a02 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005e2a:	8885                	andi	s1,s1,1
    80005e2c:	f0fd                	bnez	s1,80005e12 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005e2e:	0001c517          	auipc	a0,0x1c
    80005e32:	e0a50513          	addi	a0,a0,-502 # 80021c38 <disk+0x128>
    80005e36:	e87fa0ef          	jal	80000cbc <release>
}
    80005e3a:	60e6                	ld	ra,88(sp)
    80005e3c:	6446                	ld	s0,80(sp)
    80005e3e:	64a6                	ld	s1,72(sp)
    80005e40:	6906                	ld	s2,64(sp)
    80005e42:	79e2                	ld	s3,56(sp)
    80005e44:	7a42                	ld	s4,48(sp)
    80005e46:	7aa2                	ld	s5,40(sp)
    80005e48:	7b02                	ld	s6,32(sp)
    80005e4a:	6be2                	ld	s7,24(sp)
    80005e4c:	6c42                	ld	s8,16(sp)
    80005e4e:	6125                	addi	sp,sp,96
    80005e50:	8082                	ret

0000000080005e52 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005e52:	1101                	addi	sp,sp,-32
    80005e54:	ec06                	sd	ra,24(sp)
    80005e56:	e822                	sd	s0,16(sp)
    80005e58:	e426                	sd	s1,8(sp)
    80005e5a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005e5c:	0001c497          	auipc	s1,0x1c
    80005e60:	cb448493          	addi	s1,s1,-844 # 80021b10 <disk>
    80005e64:	0001c517          	auipc	a0,0x1c
    80005e68:	dd450513          	addi	a0,a0,-556 # 80021c38 <disk+0x128>
    80005e6c:	dbdfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005e70:	100017b7          	lui	a5,0x10001
    80005e74:	53bc                	lw	a5,96(a5)
    80005e76:	8b8d                	andi	a5,a5,3
    80005e78:	10001737          	lui	a4,0x10001
    80005e7c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005e7e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005e82:	689c                	ld	a5,16(s1)
    80005e84:	0204d703          	lhu	a4,32(s1)
    80005e88:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005e8c:	04f70863          	beq	a4,a5,80005edc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005e90:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005e94:	6898                	ld	a4,16(s1)
    80005e96:	0204d783          	lhu	a5,32(s1)
    80005e9a:	8b9d                	andi	a5,a5,7
    80005e9c:	078e                	slli	a5,a5,0x3
    80005e9e:	97ba                	add	a5,a5,a4
    80005ea0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ea2:	00479713          	slli	a4,a5,0x4
    80005ea6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005eaa:	9726                	add	a4,a4,s1
    80005eac:	01074703          	lbu	a4,16(a4)
    80005eb0:	e329                	bnez	a4,80005ef2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005eb2:	0792                	slli	a5,a5,0x4
    80005eb4:	02078793          	addi	a5,a5,32
    80005eb8:	97a6                	add	a5,a5,s1
    80005eba:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005ebc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005ec0:	dc6fc0ef          	jal	80002486 <wakeup>

    disk.used_idx += 1;
    80005ec4:	0204d783          	lhu	a5,32(s1)
    80005ec8:	2785                	addiw	a5,a5,1
    80005eca:	17c2                	slli	a5,a5,0x30
    80005ecc:	93c1                	srli	a5,a5,0x30
    80005ece:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005ed2:	6898                	ld	a4,16(s1)
    80005ed4:	00275703          	lhu	a4,2(a4)
    80005ed8:	faf71ce3          	bne	a4,a5,80005e90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005edc:	0001c517          	auipc	a0,0x1c
    80005ee0:	d5c50513          	addi	a0,a0,-676 # 80021c38 <disk+0x128>
    80005ee4:	dd9fa0ef          	jal	80000cbc <release>
}
    80005ee8:	60e2                	ld	ra,24(sp)
    80005eea:	6442                	ld	s0,16(sp)
    80005eec:	64a2                	ld	s1,8(sp)
    80005eee:	6105                	addi	sp,sp,32
    80005ef0:	8082                	ret
      panic("virtio_disk_intr status");
    80005ef2:	00002517          	auipc	a0,0x2
    80005ef6:	87650513          	addi	a0,a0,-1930 # 80007768 <etext+0x768>
    80005efa:	92bfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
