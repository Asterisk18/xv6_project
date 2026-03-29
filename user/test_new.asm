
user/_test_new:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <basic_test>:


#include "kernel/types.h"
#include "user/user.h"

void basic_test(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    printf("---- BASIC TEST ----\n");
   a:	00001517          	auipc	a0,0x1
   e:	ad650513          	addi	a0,a0,-1322 # ae0 <malloc+0xf2>
  12:	125000ef          	jal	936 <printf>

    hello();
  16:	53a000ef          	jal	550 <hello>

    int pid1 = getpid();
  1a:	516000ef          	jal	530 <getpid>
  1e:	84aa                	mv	s1,a0
    int pid2 = getpid2();
  20:	538000ef          	jal	558 <getpid2>

    if(pid1 == pid2)
  24:	02a48763          	beq	s1,a0,52 <basic_test+0x52>
        printf("getpid2() correct\n");
    else
        printf("getpid2() WRONG\n");
  28:	00001517          	auipc	a0,0x1
  2c:	af050513          	addi	a0,a0,-1296 # b18 <malloc+0x12a>
  30:	107000ef          	jal	936 <printf>

    int ppid = getppid();
  34:	52c000ef          	jal	560 <getppid>
  38:	862a                	mv	a2,a0
    printf("PID: %d  PPID: %d\n", pid1, ppid);
  3a:	85a6                	mv	a1,s1
  3c:	00001517          	auipc	a0,0x1
  40:	af450513          	addi	a0,a0,-1292 # b30 <malloc+0x142>
  44:	0f3000ef          	jal	936 <printf>

    // exit(0);
    return;
}
  48:	60e2                	ld	ra,24(sp)
  4a:	6442                	ld	s0,16(sp)
  4c:	64a2                	ld	s1,8(sp)
  4e:	6105                	addi	sp,sp,32
  50:	8082                	ret
        printf("getpid2() correct\n");
  52:	00001517          	auipc	a0,0x1
  56:	aae50513          	addi	a0,a0,-1362 # b00 <malloc+0x112>
  5a:	0dd000ef          	jal	936 <printf>
  5e:	bfd9                	j	34 <basic_test+0x34>

0000000000000060 <test_child>:

void test_child(){
  60:	1101                	addi	sp,sp,-32
  62:	ec06                	sd	ra,24(sp)
  64:	e822                	sd	s0,16(sp)
  66:	e426                	sd	s1,8(sp)
  68:	1000                	addi	s0,sp,32
    printf("---- CHILD TEST ----\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	ade50513          	addi	a0,a0,-1314 # b48 <malloc+0x15a>
  72:	0c5000ef          	jal	936 <printf>

    // int parent = getpid();

    int pid1 = fork();
  76:	432000ef          	jal	4a8 <fork>
    if(pid1 == 0){
  7a:	c93d                	beqz	a0,f0 <test_child+0x90>
  7c:	84aa                	mv	s1,a0
        pause(10);
        exit(0);
    }

    int pid2 = fork();
  7e:	42a000ef          	jal	4a8 <fork>
    if(pid2 == 0){
  82:	cd2d                	beqz	a0,fc <test_child+0x9c>
        pause(20);
        exit(0);
    }

    pause(5);
  84:	4515                	li	a0,5
  86:	4ba000ef          	jal	540 <pause>

    int n = getnumchild();
  8a:	4de000ef          	jal	568 <getnumchild>
  8e:	85aa                	mv	a1,a0
    printf("Number of children (expected 2): %d\n", n);
  90:	00001517          	auipc	a0,0x1
  94:	ad050513          	addi	a0,a0,-1328 # b60 <malloc+0x172>
  98:	09f000ef          	jal	936 <printf>

    int sc = getchildsyscount(pid1);
  9c:	8526                	mv	a0,s1
  9e:	4da000ef          	jal	578 <getchildsyscount>
  a2:	85aa                	mv	a1,a0
    printf("Child syscall count (valid child): %d\n", sc);
  a4:	00001517          	auipc	a0,0x1
  a8:	ae450513          	addi	a0,a0,-1308 # b88 <malloc+0x19a>
  ac:	08b000ef          	jal	936 <printf>

    int invalid = getchildsyscount(9999);
  b0:	6509                	lui	a0,0x2
  b2:	70f50513          	addi	a0,a0,1807 # 270f <base+0x16ff>
  b6:	4c2000ef          	jal	578 <getchildsyscount>
  ba:	85aa                	mv	a1,a0
    printf("Invalid child syscall (expected -1): %d\n", invalid);
  bc:	00001517          	auipc	a0,0x1
  c0:	af450513          	addi	a0,a0,-1292 # bb0 <malloc+0x1c2>
  c4:	073000ef          	jal	936 <printf>

    wait(0);
  c8:	4501                	li	a0,0
  ca:	3ee000ef          	jal	4b8 <wait>
    wait(0);
  ce:	4501                	li	a0,0
  d0:	3e8000ef          	jal	4b8 <wait>

    int n2 = getnumchild();
  d4:	494000ef          	jal	568 <getnumchild>
  d8:	85aa                	mv	a1,a0
    printf("Number of children after wait (expected 0): %d\n", n2);
  da:	00001517          	auipc	a0,0x1
  de:	b0650513          	addi	a0,a0,-1274 # be0 <malloc+0x1f2>
  e2:	055000ef          	jal	936 <printf>

    // exit(0);
    return;
}
  e6:	60e2                	ld	ra,24(sp)
  e8:	6442                	ld	s0,16(sp)
  ea:	64a2                	ld	s1,8(sp)
  ec:	6105                	addi	sp,sp,32
  ee:	8082                	ret
        pause(10);
  f0:	4529                	li	a0,10
  f2:	44e000ef          	jal	540 <pause>
        exit(0);
  f6:	4501                	li	a0,0
  f8:	3b8000ef          	jal	4b0 <exit>
        pause(20);
  fc:	4551                	li	a0,20
  fe:	442000ef          	jal	540 <pause>
        exit(0);
 102:	4501                	li	a0,0
 104:	3ac000ef          	jal	4b0 <exit>

0000000000000108 <test_fork>:

void test_fork(){
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
    printf("---- FORK SYSCALL TEST ----\n");
 110:	00001517          	auipc	a0,0x1
 114:	b0050513          	addi	a0,a0,-1280 # c10 <malloc+0x222>
 118:	01f000ef          	jal	936 <printf>

    int pid = fork();
 11c:	38c000ef          	jal	4a8 <fork>

    if(pid == 0){
 120:	c10d                	beqz	a0,142 <test_fork+0x3a>
        int c = getsyscount();
        printf("Child syscall count: %d\n", c);
        exit(0);
    }
    else{
        wait(0);
 122:	4501                	li	a0,0
 124:	394000ef          	jal	4b8 <wait>
        int p = getsyscount();
 128:	448000ef          	jal	570 <getsyscount>
 12c:	85aa                	mv	a1,a0
        printf("Parent syscall count: %d\n", p);
 12e:	00001517          	auipc	a0,0x1
 132:	b2a50513          	addi	a0,a0,-1238 # c58 <malloc+0x26a>
 136:	001000ef          	jal	936 <printf>
    }

    // exit(0);
    return;
}
 13a:	60a2                	ld	ra,8(sp)
 13c:	6402                	ld	s0,0(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
        printf("hello\n");
 142:	00001517          	auipc	a0,0x1
 146:	aee50513          	addi	a0,a0,-1298 # c30 <malloc+0x242>
 14a:	7ec000ef          	jal	936 <printf>
        int c = getsyscount();
 14e:	422000ef          	jal	570 <getsyscount>
 152:	85aa                	mv	a1,a0
        printf("Child syscall count: %d\n", c);
 154:	00001517          	auipc	a0,0x1
 158:	ae450513          	addi	a0,a0,-1308 # c38 <malloc+0x24a>
 15c:	7da000ef          	jal	936 <printf>
        exit(0);
 160:	4501                	li	a0,0
 162:	34e000ef          	jal	4b0 <exit>

0000000000000166 <test_syscallcount>:

void test_syscallcount(){
 166:	1101                	addi	sp,sp,-32
 168:	ec06                	sd	ra,24(sp)
 16a:	e822                	sd	s0,16(sp)
 16c:	e426                	sd	s1,8(sp)
 16e:	e04a                	sd	s2,0(sp)
 170:	1000                	addi	s0,sp,32
    printf("---- SYSCALL COUNT TEST ----\n");
 172:	00001517          	auipc	a0,0x1
 176:	b0650513          	addi	a0,a0,-1274 # c78 <malloc+0x28a>
 17a:	7bc000ef          	jal	936 <printf>

    int before = getsyscount();
 17e:	3f2000ef          	jal	570 <getsyscount>
 182:	84aa                	mv	s1,a0
    printf("Initial syscall count: %d\n", before);
 184:	85aa                	mv	a1,a0
 186:	00001517          	auipc	a0,0x1
 18a:	b1250513          	addi	a0,a0,-1262 # c98 <malloc+0x2aa>
 18e:	7a8000ef          	jal	936 <printf>

    // Make known number of syscalls
    getpid();
 192:	39e000ef          	jal	530 <getpid>
    getpid();
 196:	39a000ef          	jal	530 <getpid>
    pause(1);
 19a:	4505                	li	a0,1
 19c:	3a4000ef          	jal	540 <pause>
    getpid();
 1a0:	390000ef          	jal	530 <getpid>

    int after = getsyscount();
 1a4:	3cc000ef          	jal	570 <getsyscount>
 1a8:	892a                	mv	s2,a0
    printf("After syscalls: %d\n", after);
 1aa:	85aa                	mv	a1,a0
 1ac:	00001517          	auipc	a0,0x1
 1b0:	b0c50513          	addi	a0,a0,-1268 # cb8 <malloc+0x2ca>
 1b4:	782000ef          	jal	936 <printf>

    if(after >= before + 4)
 1b8:	248d                	addiw	s1,s1,3
 1ba:	0124de63          	bge	s1,s2,1d6 <test_syscallcount+0x70>
        printf("Syscall counter working\n");
 1be:	00001517          	auipc	a0,0x1
 1c2:	b1250513          	addi	a0,a0,-1262 # cd0 <malloc+0x2e2>
 1c6:	770000ef          	jal	936 <printf>
    else
        printf("Syscall counter WRONG\n");

    // exit(0);
    return;
}
 1ca:	60e2                	ld	ra,24(sp)
 1cc:	6442                	ld	s0,16(sp)
 1ce:	64a2                	ld	s1,8(sp)
 1d0:	6902                	ld	s2,0(sp)
 1d2:	6105                	addi	sp,sp,32
 1d4:	8082                	ret
        printf("Syscall counter WRONG\n");
 1d6:	00001517          	auipc	a0,0x1
 1da:	b1a50513          	addi	a0,a0,-1254 # cf0 <malloc+0x302>
 1de:	758000ef          	jal	936 <printf>
    return;
 1e2:	b7e5                	j	1ca <test_syscallcount+0x64>

00000000000001e4 <main>:

int
main()
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e406                	sd	ra,8(sp)
 1e8:	e022                	sd	s0,0(sp)
 1ea:	0800                	addi	s0,sp,16
    // basic_test();
    // test_child();
    test_fork();
 1ec:	f1dff0ef          	jal	108 <test_fork>
    // test_syscallcount();

 1f0:	4501                	li	a0,0
 1f2:	60a2                	ld	ra,8(sp)
 1f4:	6402                	ld	s0,0(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e406                	sd	ra,8(sp)
 1fe:	e022                	sd	s0,0(sp)
 200:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 202:	fe3ff0ef          	jal	1e4 <main>
  exit(r);
 206:	2aa000ef          	jal	4b0 <exit>

000000000000020a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e406                	sd	ra,8(sp)
 20e:	e022                	sd	s0,0(sp)
 210:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 212:	87aa                	mv	a5,a0
 214:	0585                	addi	a1,a1,1
 216:	0785                	addi	a5,a5,1
 218:	fff5c703          	lbu	a4,-1(a1)
 21c:	fee78fa3          	sb	a4,-1(a5)
 220:	fb75                	bnez	a4,214 <strcpy+0xa>
    ;
  return os;
}
 222:	60a2                	ld	ra,8(sp)
 224:	6402                	ld	s0,0(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e406                	sd	ra,8(sp)
 22e:	e022                	sd	s0,0(sp)
 230:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 232:	00054783          	lbu	a5,0(a0)
 236:	cb91                	beqz	a5,24a <strcmp+0x20>
 238:	0005c703          	lbu	a4,0(a1)
 23c:	00f71763          	bne	a4,a5,24a <strcmp+0x20>
    p++, q++;
 240:	0505                	addi	a0,a0,1
 242:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 244:	00054783          	lbu	a5,0(a0)
 248:	fbe5                	bnez	a5,238 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 24a:	0005c503          	lbu	a0,0(a1)
}
 24e:	40a7853b          	subw	a0,a5,a0
 252:	60a2                	ld	ra,8(sp)
 254:	6402                	ld	s0,0(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strlen>:

uint
strlen(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 262:	00054783          	lbu	a5,0(a0)
 266:	cf91                	beqz	a5,282 <strlen+0x28>
 268:	00150793          	addi	a5,a0,1
 26c:	86be                	mv	a3,a5
 26e:	0785                	addi	a5,a5,1
 270:	fff7c703          	lbu	a4,-1(a5)
 274:	ff65                	bnez	a4,26c <strlen+0x12>
 276:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 27a:	60a2                	ld	ra,8(sp)
 27c:	6402                	ld	s0,0(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  for(n = 0; s[n]; n++)
 282:	4501                	li	a0,0
 284:	bfdd                	j	27a <strlen+0x20>

0000000000000286 <memset>:

void*
memset(void *dst, int c, uint n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28e:	ca19                	beqz	a2,2a4 <memset+0x1e>
 290:	87aa                	mv	a5,a0
 292:	1602                	slli	a2,a2,0x20
 294:	9201                	srli	a2,a2,0x20
 296:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 29a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29e:	0785                	addi	a5,a5,1
 2a0:	fee79de3          	bne	a5,a4,29a <memset+0x14>
  }
  return dst;
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <strchr>:

char*
strchr(const char *s, char c)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	cf81                	beqz	a5,2d0 <strchr+0x24>
    if(*s == c)
 2ba:	00f58763          	beq	a1,a5,2c8 <strchr+0x1c>
  for(; *s; s++)
 2be:	0505                	addi	a0,a0,1
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	fbfd                	bnez	a5,2ba <strchr+0xe>
      return (char*)s;
  return 0;
 2c6:	4501                	li	a0,0
}
 2c8:	60a2                	ld	ra,8(sp)
 2ca:	6402                	ld	s0,0(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	bfdd                	j	2c8 <strchr+0x1c>

00000000000002d4 <gets>:

char*
gets(char *buf, int max)
{
 2d4:	711d                	addi	sp,sp,-96
 2d6:	ec86                	sd	ra,88(sp)
 2d8:	e8a2                	sd	s0,80(sp)
 2da:	e4a6                	sd	s1,72(sp)
 2dc:	e0ca                	sd	s2,64(sp)
 2de:	fc4e                	sd	s3,56(sp)
 2e0:	f852                	sd	s4,48(sp)
 2e2:	f456                	sd	s5,40(sp)
 2e4:	f05a                	sd	s6,32(sp)
 2e6:	ec5e                	sd	s7,24(sp)
 2e8:	e862                	sd	s8,16(sp)
 2ea:	1080                	addi	s0,sp,96
 2ec:	8baa                	mv	s7,a0
 2ee:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f0:	892a                	mv	s2,a0
 2f2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2f4:	faf40b13          	addi	s6,s0,-81
 2f8:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2fa:	8c26                	mv	s8,s1
 2fc:	0014899b          	addiw	s3,s1,1
 300:	84ce                	mv	s1,s3
 302:	0349d463          	bge	s3,s4,32a <gets+0x56>
    cc = read(0, &c, 1);
 306:	8656                	mv	a2,s5
 308:	85da                	mv	a1,s6
 30a:	4501                	li	a0,0
 30c:	1bc000ef          	jal	4c8 <read>
    if(cc < 1)
 310:	00a05d63          	blez	a0,32a <gets+0x56>
      break;
    buf[i++] = c;
 314:	faf44783          	lbu	a5,-81(s0)
 318:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 31c:	0905                	addi	s2,s2,1
 31e:	ff678713          	addi	a4,a5,-10
 322:	c319                	beqz	a4,328 <gets+0x54>
 324:	17cd                	addi	a5,a5,-13
 326:	fbf1                	bnez	a5,2fa <gets+0x26>
    buf[i++] = c;
 328:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 32a:	9c5e                	add	s8,s8,s7
 32c:	000c0023          	sb	zero,0(s8)
  return buf;
}
 330:	855e                	mv	a0,s7
 332:	60e6                	ld	ra,88(sp)
 334:	6446                	ld	s0,80(sp)
 336:	64a6                	ld	s1,72(sp)
 338:	6906                	ld	s2,64(sp)
 33a:	79e2                	ld	s3,56(sp)
 33c:	7a42                	ld	s4,48(sp)
 33e:	7aa2                	ld	s5,40(sp)
 340:	7b02                	ld	s6,32(sp)
 342:	6be2                	ld	s7,24(sp)
 344:	6c42                	ld	s8,16(sp)
 346:	6125                	addi	sp,sp,96
 348:	8082                	ret

000000000000034a <stat>:

int
stat(const char *n, struct stat *st)
{
 34a:	1101                	addi	sp,sp,-32
 34c:	ec06                	sd	ra,24(sp)
 34e:	e822                	sd	s0,16(sp)
 350:	e04a                	sd	s2,0(sp)
 352:	1000                	addi	s0,sp,32
 354:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 356:	4581                	li	a1,0
 358:	198000ef          	jal	4f0 <open>
  if(fd < 0)
 35c:	02054263          	bltz	a0,380 <stat+0x36>
 360:	e426                	sd	s1,8(sp)
 362:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 364:	85ca                	mv	a1,s2
 366:	1a2000ef          	jal	508 <fstat>
 36a:	892a                	mv	s2,a0
  close(fd);
 36c:	8526                	mv	a0,s1
 36e:	16a000ef          	jal	4d8 <close>
  return r;
 372:	64a2                	ld	s1,8(sp)
}
 374:	854a                	mv	a0,s2
 376:	60e2                	ld	ra,24(sp)
 378:	6442                	ld	s0,16(sp)
 37a:	6902                	ld	s2,0(sp)
 37c:	6105                	addi	sp,sp,32
 37e:	8082                	ret
    return -1;
 380:	57fd                	li	a5,-1
 382:	893e                	mv	s2,a5
 384:	bfc5                	j	374 <stat+0x2a>

0000000000000386 <atoi>:

int
atoi(const char *s)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38e:	00054683          	lbu	a3,0(a0)
 392:	fd06879b          	addiw	a5,a3,-48
 396:	0ff7f793          	zext.b	a5,a5
 39a:	4625                	li	a2,9
 39c:	02f66963          	bltu	a2,a5,3ce <atoi+0x48>
 3a0:	872a                	mv	a4,a0
  n = 0;
 3a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3a4:	0705                	addi	a4,a4,1
 3a6:	0025179b          	slliw	a5,a0,0x2
 3aa:	9fa9                	addw	a5,a5,a0
 3ac:	0017979b          	slliw	a5,a5,0x1
 3b0:	9fb5                	addw	a5,a5,a3
 3b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b6:	00074683          	lbu	a3,0(a4)
 3ba:	fd06879b          	addiw	a5,a3,-48
 3be:	0ff7f793          	zext.b	a5,a5
 3c2:	fef671e3          	bgeu	a2,a5,3a4 <atoi+0x1e>
  return n;
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  n = 0;
 3ce:	4501                	li	a0,0
 3d0:	bfdd                	j	3c6 <atoi+0x40>

00000000000003d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3da:	02b57563          	bgeu	a0,a1,404 <memmove+0x32>
    while(n-- > 0)
 3de:	00c05f63          	blez	a2,3fc <memmove+0x2a>
 3e2:	1602                	slli	a2,a2,0x20
 3e4:	9201                	srli	a2,a2,0x20
 3e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ec:	0585                	addi	a1,a1,1
 3ee:	0705                	addi	a4,a4,1
 3f0:	fff5c683          	lbu	a3,-1(a1)
 3f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f8:	fee79ae3          	bne	a5,a4,3ec <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fc:	60a2                	ld	ra,8(sp)
 3fe:	6402                	ld	s0,0(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
    while(n-- > 0)
 404:	fec05ce3          	blez	a2,3fc <memmove+0x2a>
    dst += n;
 408:	00c50733          	add	a4,a0,a2
    src += n;
 40c:	95b2                	add	a1,a1,a2
 40e:	fff6079b          	addiw	a5,a2,-1
 412:	1782                	slli	a5,a5,0x20
 414:	9381                	srli	a5,a5,0x20
 416:	fff7c793          	not	a5,a5
 41a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41c:	15fd                	addi	a1,a1,-1
 41e:	177d                	addi	a4,a4,-1
 420:	0005c683          	lbu	a3,0(a1)
 424:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 428:	fef71ae3          	bne	a4,a5,41c <memmove+0x4a>
 42c:	bfc1                	j	3fc <memmove+0x2a>

000000000000042e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e406                	sd	ra,8(sp)
 432:	e022                	sd	s0,0(sp)
 434:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 436:	c61d                	beqz	a2,464 <memcmp+0x36>
 438:	1602                	slli	a2,a2,0x20
 43a:	9201                	srli	a2,a2,0x20
 43c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 440:	00054783          	lbu	a5,0(a0)
 444:	0005c703          	lbu	a4,0(a1)
 448:	00e79863          	bne	a5,a4,458 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 44c:	0505                	addi	a0,a0,1
    p2++;
 44e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 450:	fed518e3          	bne	a0,a3,440 <memcmp+0x12>
  }
  return 0;
 454:	4501                	li	a0,0
 456:	a019                	j	45c <memcmp+0x2e>
      return *p1 - *p2;
 458:	40e7853b          	subw	a0,a5,a4
}
 45c:	60a2                	ld	ra,8(sp)
 45e:	6402                	ld	s0,0(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret
  return 0;
 464:	4501                	li	a0,0
 466:	bfdd                	j	45c <memcmp+0x2e>

0000000000000468 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 468:	1141                	addi	sp,sp,-16
 46a:	e406                	sd	ra,8(sp)
 46c:	e022                	sd	s0,0(sp)
 46e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 470:	f63ff0ef          	jal	3d2 <memmove>
}
 474:	60a2                	ld	ra,8(sp)
 476:	6402                	ld	s0,0(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret

000000000000047c <sbrk>:

char *
sbrk(int n) {
 47c:	1141                	addi	sp,sp,-16
 47e:	e406                	sd	ra,8(sp)
 480:	e022                	sd	s0,0(sp)
 482:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 484:	4585                	li	a1,1
 486:	0b2000ef          	jal	538 <sys_sbrk>
}
 48a:	60a2                	ld	ra,8(sp)
 48c:	6402                	ld	s0,0(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret

0000000000000492 <sbrklazy>:

char *
sbrklazy(int n) {
 492:	1141                	addi	sp,sp,-16
 494:	e406                	sd	ra,8(sp)
 496:	e022                	sd	s0,0(sp)
 498:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 49a:	4589                	li	a1,2
 49c:	09c000ef          	jal	538 <sys_sbrk>
}
 4a0:	60a2                	ld	ra,8(sp)
 4a2:	6402                	ld	s0,0(sp)
 4a4:	0141                	addi	sp,sp,16
 4a6:	8082                	ret

00000000000004a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a8:	4885                	li	a7,1
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b0:	4889                	li	a7,2
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b8:	488d                	li	a7,3
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c0:	4891                	li	a7,4
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <read>:
.global read
read:
 li a7, SYS_read
 4c8:	4895                	li	a7,5
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <write>:
.global write
write:
 li a7, SYS_write
 4d0:	48c1                	li	a7,16
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <close>:
.global close
close:
 li a7, SYS_close
 4d8:	48d5                	li	a7,21
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e0:	4899                	li	a7,6
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e8:	489d                	li	a7,7
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <open>:
.global open
open:
 li a7, SYS_open
 4f0:	48bd                	li	a7,15
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f8:	48c5                	li	a7,17
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 500:	48c9                	li	a7,18
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 508:	48a1                	li	a7,8
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <link>:
.global link
link:
 li a7, SYS_link
 510:	48cd                	li	a7,19
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 518:	48d1                	li	a7,20
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 520:	48a5                	li	a7,9
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <dup>:
.global dup
dup:
 li a7, SYS_dup
 528:	48a9                	li	a7,10
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 530:	48ad                	li	a7,11
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 538:	48b1                	li	a7,12
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <pause>:
.global pause
pause:
 li a7, SYS_pause
 540:	48b5                	li	a7,13
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 548:	48b9                	li	a7,14
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <hello>:
.global hello
hello:
 li a7, SYS_hello
 550:	48d9                	li	a7,22
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <getpid2>:
.global getpid2
getpid2:
 li a7, SYS_getpid2
 558:	48dd                	li	a7,23
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 560:	48e1                	li	a7,24
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <getnumchild>:
.global getnumchild
getnumchild:
 li a7, SYS_getnumchild
 568:	48e5                	li	a7,25
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 570:	48e9                	li	a7,26
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <getchildsyscount>:
.global getchildsyscount
getchildsyscount:
 li a7, SYS_getchildsyscount
 578:	48ed                	li	a7,27
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getlevel>:
.global getlevel
getlevel:
 li a7, SYS_getlevel
 580:	48f1                	li	a7,28
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <getmlfqinfo>:
.global getmlfqinfo
getmlfqinfo:
 li a7, SYS_getmlfqinfo
 588:	48f5                	li	a7,29
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 590:	1101                	addi	sp,sp,-32
 592:	ec06                	sd	ra,24(sp)
 594:	e822                	sd	s0,16(sp)
 596:	1000                	addi	s0,sp,32
 598:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 59c:	4605                	li	a2,1
 59e:	fef40593          	addi	a1,s0,-17
 5a2:	f2fff0ef          	jal	4d0 <write>
}
 5a6:	60e2                	ld	ra,24(sp)
 5a8:	6442                	ld	s0,16(sp)
 5aa:	6105                	addi	sp,sp,32
 5ac:	8082                	ret

00000000000005ae <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5ae:	715d                	addi	sp,sp,-80
 5b0:	e486                	sd	ra,72(sp)
 5b2:	e0a2                	sd	s0,64(sp)
 5b4:	f84a                	sd	s2,48(sp)
 5b6:	f44e                	sd	s3,40(sp)
 5b8:	0880                	addi	s0,sp,80
 5ba:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5bc:	c6d1                	beqz	a3,648 <printint+0x9a>
 5be:	0805d563          	bgez	a1,648 <printint+0x9a>
    neg = 1;
    x = -xx;
 5c2:	40b005b3          	neg	a1,a1
    neg = 1;
 5c6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5c8:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5cc:	86ce                	mv	a3,s3
  i = 0;
 5ce:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5d0:	00000817          	auipc	a6,0x0
 5d4:	74080813          	addi	a6,a6,1856 # d10 <digits>
 5d8:	88ba                	mv	a7,a4
 5da:	0017051b          	addiw	a0,a4,1
 5de:	872a                	mv	a4,a0
 5e0:	02c5f7b3          	remu	a5,a1,a2
 5e4:	97c2                	add	a5,a5,a6
 5e6:	0007c783          	lbu	a5,0(a5)
 5ea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ee:	87ae                	mv	a5,a1
 5f0:	02c5d5b3          	divu	a1,a1,a2
 5f4:	0685                	addi	a3,a3,1
 5f6:	fec7f1e3          	bgeu	a5,a2,5d8 <printint+0x2a>
  if(neg)
 5fa:	00030c63          	beqz	t1,612 <printint+0x64>
    buf[i++] = '-';
 5fe:	fd050793          	addi	a5,a0,-48
 602:	00878533          	add	a0,a5,s0
 606:	02d00793          	li	a5,45
 60a:	fef50423          	sb	a5,-24(a0)
 60e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 612:	02e05563          	blez	a4,63c <printint+0x8e>
 616:	fc26                	sd	s1,56(sp)
 618:	377d                	addiw	a4,a4,-1
 61a:	00e984b3          	add	s1,s3,a4
 61e:	19fd                	addi	s3,s3,-1
 620:	99ba                	add	s3,s3,a4
 622:	1702                	slli	a4,a4,0x20
 624:	9301                	srli	a4,a4,0x20
 626:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 62a:	0004c583          	lbu	a1,0(s1)
 62e:	854a                	mv	a0,s2
 630:	f61ff0ef          	jal	590 <putc>
  while(--i >= 0)
 634:	14fd                	addi	s1,s1,-1
 636:	ff349ae3          	bne	s1,s3,62a <printint+0x7c>
 63a:	74e2                	ld	s1,56(sp)
}
 63c:	60a6                	ld	ra,72(sp)
 63e:	6406                	ld	s0,64(sp)
 640:	7942                	ld	s2,48(sp)
 642:	79a2                	ld	s3,40(sp)
 644:	6161                	addi	sp,sp,80
 646:	8082                	ret
  neg = 0;
 648:	4301                	li	t1,0
 64a:	bfbd                	j	5c8 <printint+0x1a>

000000000000064c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 64c:	711d                	addi	sp,sp,-96
 64e:	ec86                	sd	ra,88(sp)
 650:	e8a2                	sd	s0,80(sp)
 652:	e4a6                	sd	s1,72(sp)
 654:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 656:	0005c483          	lbu	s1,0(a1)
 65a:	22048363          	beqz	s1,880 <vprintf+0x234>
 65e:	e0ca                	sd	s2,64(sp)
 660:	fc4e                	sd	s3,56(sp)
 662:	f852                	sd	s4,48(sp)
 664:	f456                	sd	s5,40(sp)
 666:	f05a                	sd	s6,32(sp)
 668:	ec5e                	sd	s7,24(sp)
 66a:	e862                	sd	s8,16(sp)
 66c:	8b2a                	mv	s6,a0
 66e:	8a2e                	mv	s4,a1
 670:	8bb2                	mv	s7,a2
  state = 0;
 672:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 674:	4901                	li	s2,0
 676:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 678:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 67c:	06400c13          	li	s8,100
 680:	a00d                	j	6a2 <vprintf+0x56>
        putc(fd, c0);
 682:	85a6                	mv	a1,s1
 684:	855a                	mv	a0,s6
 686:	f0bff0ef          	jal	590 <putc>
 68a:	a019                	j	690 <vprintf+0x44>
    } else if(state == '%'){
 68c:	03598363          	beq	s3,s5,6b2 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 690:	0019079b          	addiw	a5,s2,1
 694:	893e                	mv	s2,a5
 696:	873e                	mv	a4,a5
 698:	97d2                	add	a5,a5,s4
 69a:	0007c483          	lbu	s1,0(a5)
 69e:	1c048a63          	beqz	s1,872 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6a2:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6a6:	fe0993e3          	bnez	s3,68c <vprintf+0x40>
      if(c0 == '%'){
 6aa:	fd579ce3          	bne	a5,s5,682 <vprintf+0x36>
        state = '%';
 6ae:	89be                	mv	s3,a5
 6b0:	b7c5                	j	690 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6b2:	00ea06b3          	add	a3,s4,a4
 6b6:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6ba:	1c060863          	beqz	a2,88a <vprintf+0x23e>
      if(c0 == 'd'){
 6be:	03878763          	beq	a5,s8,6ec <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6c2:	f9478693          	addi	a3,a5,-108
 6c6:	0016b693          	seqz	a3,a3
 6ca:	f9c60593          	addi	a1,a2,-100
 6ce:	e99d                	bnez	a1,704 <vprintf+0xb8>
 6d0:	ca95                	beqz	a3,704 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	008b8493          	addi	s1,s7,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	ecfff0ef          	jal	5ae <printint>
        i += 1;
 6e4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b75d                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6ec:	008b8493          	addi	s1,s7,8
 6f0:	4685                	li	a3,1
 6f2:	4629                	li	a2,10
 6f4:	000ba583          	lw	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	eb5ff0ef          	jal	5ae <printint>
 6fe:	8ba6                	mv	s7,s1
      state = 0;
 700:	4981                	li	s3,0
 702:	b779                	j	690 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 704:	9752                	add	a4,a4,s4
 706:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 70a:	f9460713          	addi	a4,a2,-108
 70e:	00173713          	seqz	a4,a4
 712:	8f75                	and	a4,a4,a3
 714:	f9c58513          	addi	a0,a1,-100
 718:	18051363          	bnez	a0,89e <vprintf+0x252>
 71c:	18070163          	beqz	a4,89e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 720:	008b8493          	addi	s1,s7,8
 724:	4685                	li	a3,1
 726:	4629                	li	a2,10
 728:	000bb583          	ld	a1,0(s7)
 72c:	855a                	mv	a0,s6
 72e:	e81ff0ef          	jal	5ae <printint>
        i += 2;
 732:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 734:	8ba6                	mv	s7,s1
      state = 0;
 736:	4981                	li	s3,0
        i += 2;
 738:	bfa1                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 73a:	008b8493          	addi	s1,s7,8
 73e:	4681                	li	a3,0
 740:	4629                	li	a2,10
 742:	000be583          	lwu	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	e67ff0ef          	jal	5ae <printint>
 74c:	8ba6                	mv	s7,s1
      state = 0;
 74e:	4981                	li	s3,0
 750:	b781                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 752:	008b8493          	addi	s1,s7,8
 756:	4681                	li	a3,0
 758:	4629                	li	a2,10
 75a:	000bb583          	ld	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	e4fff0ef          	jal	5ae <printint>
        i += 1;
 764:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 766:	8ba6                	mv	s7,s1
      state = 0;
 768:	4981                	li	s3,0
 76a:	b71d                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 76c:	008b8493          	addi	s1,s7,8
 770:	4681                	li	a3,0
 772:	4629                	li	a2,10
 774:	000bb583          	ld	a1,0(s7)
 778:	855a                	mv	a0,s6
 77a:	e35ff0ef          	jal	5ae <printint>
        i += 2;
 77e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 780:	8ba6                	mv	s7,s1
      state = 0;
 782:	4981                	li	s3,0
        i += 2;
 784:	b731                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 786:	008b8493          	addi	s1,s7,8
 78a:	4681                	li	a3,0
 78c:	4641                	li	a2,16
 78e:	000be583          	lwu	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	e1bff0ef          	jal	5ae <printint>
 798:	8ba6                	mv	s7,s1
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bdd5                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 79e:	008b8493          	addi	s1,s7,8
 7a2:	4681                	li	a3,0
 7a4:	4641                	li	a2,16
 7a6:	000bb583          	ld	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	e03ff0ef          	jal	5ae <printint>
        i += 1;
 7b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b2:	8ba6                	mv	s7,s1
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	bde9                	j	690 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b8:	008b8493          	addi	s1,s7,8
 7bc:	4681                	li	a3,0
 7be:	4641                	li	a2,16
 7c0:	000bb583          	ld	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	de9ff0ef          	jal	5ae <printint>
        i += 2;
 7ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7cc:	8ba6                	mv	s7,s1
      state = 0;
 7ce:	4981                	li	s3,0
        i += 2;
 7d0:	b5c1                	j	690 <vprintf+0x44>
 7d2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7d4:	008b8793          	addi	a5,s7,8
 7d8:	8cbe                	mv	s9,a5
 7da:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7de:	03000593          	li	a1,48
 7e2:	855a                	mv	a0,s6
 7e4:	dadff0ef          	jal	590 <putc>
  putc(fd, 'x');
 7e8:	07800593          	li	a1,120
 7ec:	855a                	mv	a0,s6
 7ee:	da3ff0ef          	jal	590 <putc>
 7f2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f4:	00000b97          	auipc	s7,0x0
 7f8:	51cb8b93          	addi	s7,s7,1308 # d10 <digits>
 7fc:	03c9d793          	srli	a5,s3,0x3c
 800:	97de                	add	a5,a5,s7
 802:	0007c583          	lbu	a1,0(a5)
 806:	855a                	mv	a0,s6
 808:	d89ff0ef          	jal	590 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 80c:	0992                	slli	s3,s3,0x4
 80e:	34fd                	addiw	s1,s1,-1
 810:	f4f5                	bnez	s1,7fc <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 812:	8be6                	mv	s7,s9
      state = 0;
 814:	4981                	li	s3,0
 816:	6ca2                	ld	s9,8(sp)
 818:	bda5                	j	690 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 81a:	008b8493          	addi	s1,s7,8
 81e:	000bc583          	lbu	a1,0(s7)
 822:	855a                	mv	a0,s6
 824:	d6dff0ef          	jal	590 <putc>
 828:	8ba6                	mv	s7,s1
      state = 0;
 82a:	4981                	li	s3,0
 82c:	b595                	j	690 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 82e:	008b8993          	addi	s3,s7,8
 832:	000bb483          	ld	s1,0(s7)
 836:	cc91                	beqz	s1,852 <vprintf+0x206>
        for(; *s; s++)
 838:	0004c583          	lbu	a1,0(s1)
 83c:	c985                	beqz	a1,86c <vprintf+0x220>
          putc(fd, *s);
 83e:	855a                	mv	a0,s6
 840:	d51ff0ef          	jal	590 <putc>
        for(; *s; s++)
 844:	0485                	addi	s1,s1,1
 846:	0004c583          	lbu	a1,0(s1)
 84a:	f9f5                	bnez	a1,83e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 84c:	8bce                	mv	s7,s3
      state = 0;
 84e:	4981                	li	s3,0
 850:	b581                	j	690 <vprintf+0x44>
          s = "(null)";
 852:	00000497          	auipc	s1,0x0
 856:	4b648493          	addi	s1,s1,1206 # d08 <malloc+0x31a>
        for(; *s; s++)
 85a:	02800593          	li	a1,40
 85e:	b7c5                	j	83e <vprintf+0x1f2>
        putc(fd, '%');
 860:	85be                	mv	a1,a5
 862:	855a                	mv	a0,s6
 864:	d2dff0ef          	jal	590 <putc>
      state = 0;
 868:	4981                	li	s3,0
 86a:	b51d                	j	690 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 86c:	8bce                	mv	s7,s3
      state = 0;
 86e:	4981                	li	s3,0
 870:	b505                	j	690 <vprintf+0x44>
 872:	6906                	ld	s2,64(sp)
 874:	79e2                	ld	s3,56(sp)
 876:	7a42                	ld	s4,48(sp)
 878:	7aa2                	ld	s5,40(sp)
 87a:	7b02                	ld	s6,32(sp)
 87c:	6be2                	ld	s7,24(sp)
 87e:	6c42                	ld	s8,16(sp)
    }
  }
}
 880:	60e6                	ld	ra,88(sp)
 882:	6446                	ld	s0,80(sp)
 884:	64a6                	ld	s1,72(sp)
 886:	6125                	addi	sp,sp,96
 888:	8082                	ret
      if(c0 == 'd'){
 88a:	06400713          	li	a4,100
 88e:	e4e78fe3          	beq	a5,a4,6ec <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 892:	f9478693          	addi	a3,a5,-108
 896:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 89a:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 89c:	4701                	li	a4,0
      } else if(c0 == 'u'){
 89e:	07500513          	li	a0,117
 8a2:	e8a78ce3          	beq	a5,a0,73a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8a6:	f8b60513          	addi	a0,a2,-117
 8aa:	e119                	bnez	a0,8b0 <vprintf+0x264>
 8ac:	ea0693e3          	bnez	a3,752 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8b0:	f8b58513          	addi	a0,a1,-117
 8b4:	e119                	bnez	a0,8ba <vprintf+0x26e>
 8b6:	ea071be3          	bnez	a4,76c <vprintf+0x120>
      } else if(c0 == 'x'){
 8ba:	07800513          	li	a0,120
 8be:	eca784e3          	beq	a5,a0,786 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8c2:	f8860613          	addi	a2,a2,-120
 8c6:	e219                	bnez	a2,8cc <vprintf+0x280>
 8c8:	ec069be3          	bnez	a3,79e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8cc:	f8858593          	addi	a1,a1,-120
 8d0:	e199                	bnez	a1,8d6 <vprintf+0x28a>
 8d2:	ee0713e3          	bnez	a4,7b8 <vprintf+0x16c>
      } else if(c0 == 'p'){
 8d6:	07000713          	li	a4,112
 8da:	eee78ce3          	beq	a5,a4,7d2 <vprintf+0x186>
      } else if(c0 == 'c'){
 8de:	06300713          	li	a4,99
 8e2:	f2e78ce3          	beq	a5,a4,81a <vprintf+0x1ce>
      } else if(c0 == 's'){
 8e6:	07300713          	li	a4,115
 8ea:	f4e782e3          	beq	a5,a4,82e <vprintf+0x1e2>
      } else if(c0 == '%'){
 8ee:	02500713          	li	a4,37
 8f2:	f6e787e3          	beq	a5,a4,860 <vprintf+0x214>
        putc(fd, '%');
 8f6:	02500593          	li	a1,37
 8fa:	855a                	mv	a0,s6
 8fc:	c95ff0ef          	jal	590 <putc>
        putc(fd, c0);
 900:	85a6                	mv	a1,s1
 902:	855a                	mv	a0,s6
 904:	c8dff0ef          	jal	590 <putc>
      state = 0;
 908:	4981                	li	s3,0
 90a:	b359                	j	690 <vprintf+0x44>

000000000000090c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90c:	715d                	addi	sp,sp,-80
 90e:	ec06                	sd	ra,24(sp)
 910:	e822                	sd	s0,16(sp)
 912:	1000                	addi	s0,sp,32
 914:	e010                	sd	a2,0(s0)
 916:	e414                	sd	a3,8(s0)
 918:	e818                	sd	a4,16(s0)
 91a:	ec1c                	sd	a5,24(s0)
 91c:	03043023          	sd	a6,32(s0)
 920:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	8622                	mv	a2,s0
 926:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 92a:	d23ff0ef          	jal	64c <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6161                	addi	sp,sp,80
 934:	8082                	ret

0000000000000936 <printf>:

void
printf(const char *fmt, ...)
{
 936:	711d                	addi	sp,sp,-96
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e40c                	sd	a1,8(s0)
 940:	e810                	sd	a2,16(s0)
 942:	ec14                	sd	a3,24(s0)
 944:	f018                	sd	a4,32(s0)
 946:	f41c                	sd	a5,40(s0)
 948:	03043823          	sd	a6,48(s0)
 94c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	00840613          	addi	a2,s0,8
 954:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 958:	85aa                	mv	a1,a0
 95a:	4505                	li	a0,1
 95c:	cf1ff0ef          	jal	64c <vprintf>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6125                	addi	sp,sp,96
 966:	8082                	ret

0000000000000968 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 968:	1141                	addi	sp,sp,-16
 96a:	e406                	sd	ra,8(sp)
 96c:	e022                	sd	s0,0(sp)
 96e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 970:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 974:	00000797          	auipc	a5,0x0
 978:	68c7b783          	ld	a5,1676(a5) # 1000 <freep>
 97c:	a039                	j	98a <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97e:	6398                	ld	a4,0(a5)
 980:	00e7e463          	bltu	a5,a4,988 <free+0x20>
 984:	00e6ea63          	bltu	a3,a4,998 <free+0x30>
{
 988:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 98a:	fed7fae3          	bgeu	a5,a3,97e <free+0x16>
 98e:	6398                	ld	a4,0(a5)
 990:	00e6e463          	bltu	a3,a4,998 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 994:	fee7eae3          	bltu	a5,a4,988 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 998:	ff852583          	lw	a1,-8(a0)
 99c:	6390                	ld	a2,0(a5)
 99e:	02059813          	slli	a6,a1,0x20
 9a2:	01c85713          	srli	a4,a6,0x1c
 9a6:	9736                	add	a4,a4,a3
 9a8:	02e60563          	beq	a2,a4,9d2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9ac:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9b0:	4790                	lw	a2,8(a5)
 9b2:	02061593          	slli	a1,a2,0x20
 9b6:	01c5d713          	srli	a4,a1,0x1c
 9ba:	973e                	add	a4,a4,a5
 9bc:	02e68263          	beq	a3,a4,9e0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9c0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9c2:	00000717          	auipc	a4,0x0
 9c6:	62f73f23          	sd	a5,1598(a4) # 1000 <freep>
}
 9ca:	60a2                	ld	ra,8(sp)
 9cc:	6402                	ld	s0,0(sp)
 9ce:	0141                	addi	sp,sp,16
 9d0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9d2:	4618                	lw	a4,8(a2)
 9d4:	9f2d                	addw	a4,a4,a1
 9d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9da:	6398                	ld	a4,0(a5)
 9dc:	6310                	ld	a2,0(a4)
 9de:	b7f9                	j	9ac <free+0x44>
    p->s.size += bp->s.size;
 9e0:	ff852703          	lw	a4,-8(a0)
 9e4:	9f31                	addw	a4,a4,a2
 9e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9e8:	ff053683          	ld	a3,-16(a0)
 9ec:	bfd1                	j	9c0 <free+0x58>

00000000000009ee <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ee:	7139                	addi	sp,sp,-64
 9f0:	fc06                	sd	ra,56(sp)
 9f2:	f822                	sd	s0,48(sp)
 9f4:	f04a                	sd	s2,32(sp)
 9f6:	ec4e                	sd	s3,24(sp)
 9f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9fa:	02051993          	slli	s3,a0,0x20
 9fe:	0209d993          	srli	s3,s3,0x20
 a02:	09bd                	addi	s3,s3,15
 a04:	0049d993          	srli	s3,s3,0x4
 a08:	2985                	addiw	s3,s3,1
 a0a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a0c:	00000517          	auipc	a0,0x0
 a10:	5f453503          	ld	a0,1524(a0) # 1000 <freep>
 a14:	c905                	beqz	a0,a44 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a18:	4798                	lw	a4,8(a5)
 a1a:	09377663          	bgeu	a4,s3,aa6 <malloc+0xb8>
 a1e:	f426                	sd	s1,40(sp)
 a20:	e852                	sd	s4,16(sp)
 a22:	e456                	sd	s5,8(sp)
 a24:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a26:	8a4e                	mv	s4,s3
 a28:	6705                	lui	a4,0x1
 a2a:	00e9f363          	bgeu	s3,a4,a30 <malloc+0x42>
 a2e:	6a05                	lui	s4,0x1
 a30:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a34:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a38:	00000497          	auipc	s1,0x0
 a3c:	5c848493          	addi	s1,s1,1480 # 1000 <freep>
  if(p == SBRK_ERROR)
 a40:	5afd                	li	s5,-1
 a42:	a83d                	j	a80 <malloc+0x92>
 a44:	f426                	sd	s1,40(sp)
 a46:	e852                	sd	s4,16(sp)
 a48:	e456                	sd	s5,8(sp)
 a4a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a4c:	00000797          	auipc	a5,0x0
 a50:	5c478793          	addi	a5,a5,1476 # 1010 <base>
 a54:	00000717          	auipc	a4,0x0
 a58:	5af73623          	sd	a5,1452(a4) # 1000 <freep>
 a5c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a62:	b7d1                	j	a26 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a64:	6398                	ld	a4,0(a5)
 a66:	e118                	sd	a4,0(a0)
 a68:	a899                	j	abe <malloc+0xd0>
  hp->s.size = nu;
 a6a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6e:	0541                	addi	a0,a0,16
 a70:	ef9ff0ef          	jal	968 <free>
  return freep;
 a74:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a76:	c125                	beqz	a0,ad6 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	03277163          	bgeu	a4,s2,a9e <malloc+0xb0>
    if(p == freep)
 a80:	6098                	ld	a4,0(s1)
 a82:	853e                	mv	a0,a5
 a84:	fef71ae3          	bne	a4,a5,a78 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a88:	8552                	mv	a0,s4
 a8a:	9f3ff0ef          	jal	47c <sbrk>
  if(p == SBRK_ERROR)
 a8e:	fd551ee3          	bne	a0,s5,a6a <malloc+0x7c>
        return 0;
 a92:	4501                	li	a0,0
 a94:	74a2                	ld	s1,40(sp)
 a96:	6a42                	ld	s4,16(sp)
 a98:	6aa2                	ld	s5,8(sp)
 a9a:	6b02                	ld	s6,0(sp)
 a9c:	a03d                	j	aca <malloc+0xdc>
 a9e:	74a2                	ld	s1,40(sp)
 aa0:	6a42                	ld	s4,16(sp)
 aa2:	6aa2                	ld	s5,8(sp)
 aa4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa6:	fae90fe3          	beq	s2,a4,a64 <malloc+0x76>
        p->s.size -= nunits;
 aaa:	4137073b          	subw	a4,a4,s3
 aae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab0:	02071693          	slli	a3,a4,0x20
 ab4:	01c6d713          	srli	a4,a3,0x1c
 ab8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 abe:	00000717          	auipc	a4,0x0
 ac2:	54a73123          	sd	a0,1346(a4) # 1000 <freep>
      return (void*)(p + 1);
 ac6:	01078513          	addi	a0,a5,16
  }
}
 aca:	70e2                	ld	ra,56(sp)
 acc:	7442                	ld	s0,48(sp)
 ace:	7902                	ld	s2,32(sp)
 ad0:	69e2                	ld	s3,24(sp)
 ad2:	6121                	addi	sp,sp,64
 ad4:	8082                	ret
 ad6:	74a2                	ld	s1,40(sp)
 ad8:	6a42                	ld	s4,16(sp)
 ada:	6aa2                	ld	s5,8(sp)
 adc:	6b02                	ld	s6,0(sp)
 ade:	b7f5                	j	aca <malloc+0xdc>
