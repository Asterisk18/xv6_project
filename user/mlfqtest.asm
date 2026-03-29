
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_stats>:
  int ticks[NLEVEL]; 
  int times_scheduled; 
  int total_syscalls; 
};

void print_stats(char *workload_type, int turnaround_time) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
    struct mlfqinfo info;
    if(getmlfqinfo(getpid(), &info) == 0) {
  10:	5f0000ef          	jal	600 <getpid>
  14:	fc040593          	addi	a1,s0,-64
  18:	640000ef          	jal	658 <getmlfqinfo>
  1c:	e951                	bnez	a0,b0 <print_stats+0xb0>
        printf("\n========================================\n");
  1e:	00001517          	auipc	a0,0x1
  22:	b9250513          	addi	a0,a0,-1134 # bb0 <malloc+0xf2>
  26:	1e1000ef          	jal	a06 <printf>
        printf("Workload: %s (PID: %d)\n", workload_type, getpid());
  2a:	5d6000ef          	jal	600 <getpid>
  2e:	862a                	mv	a2,a0
  30:	85ca                	mv	a1,s2
  32:	00001517          	auipc	a0,0x1
  36:	bae50513          	addi	a0,a0,-1106 # be0 <malloc+0x122>
  3a:	1cd000ef          	jal	a06 <printf>
        printf("Turnaround Time   : %d ticks\n", turnaround_time);
  3e:	85a6                	mv	a1,s1
  40:	00001517          	auipc	a0,0x1
  44:	bb850513          	addi	a0,a0,-1096 # bf8 <malloc+0x13a>
  48:	1bf000ef          	jal	a06 <printf>
        printf("Final Queue Level : %d\n", info.level);
  4c:	fc042583          	lw	a1,-64(s0)
  50:	00001517          	auipc	a0,0x1
  54:	bc850513          	addi	a0,a0,-1080 # c18 <malloc+0x15a>
  58:	1af000ef          	jal	a06 <printf>
        printf("Ticks per Level   : [L0: %d, L1: %d, L2: %d, L3: %d]\n", 
  5c:	fd042703          	lw	a4,-48(s0)
  60:	fcc42683          	lw	a3,-52(s0)
  64:	fc842603          	lw	a2,-56(s0)
  68:	fc442583          	lw	a1,-60(s0)
  6c:	00001517          	auipc	a0,0x1
  70:	bc450513          	addi	a0,a0,-1084 # c30 <malloc+0x172>
  74:	193000ef          	jal	a06 <printf>
               info.ticks[0], info.ticks[1], info.ticks[2], info.ticks[3]);
        printf("Times Scheduled   : %d\n", info.times_scheduled);
  78:	fd442583          	lw	a1,-44(s0)
  7c:	00001517          	auipc	a0,0x1
  80:	bec50513          	addi	a0,a0,-1044 # c68 <malloc+0x1aa>
  84:	183000ef          	jal	a06 <printf>
        printf("Total Syscalls    : %d\n", info.total_syscalls);
  88:	fd842583          	lw	a1,-40(s0)
  8c:	00001517          	auipc	a0,0x1
  90:	bf450513          	addi	a0,a0,-1036 # c80 <malloc+0x1c2>
  94:	173000ef          	jal	a06 <printf>
        printf("========================================\n");
  98:	00001517          	auipc	a0,0x1
  9c:	c0050513          	addi	a0,a0,-1024 # c98 <malloc+0x1da>
  a0:	167000ef          	jal	a06 <printf>
    } else {
        printf("Error fetching info for PID %d\n", getpid());
    }
}
  a4:	70e2                	ld	ra,56(sp)
  a6:	7442                	ld	s0,48(sp)
  a8:	74a2                	ld	s1,40(sp)
  aa:	7902                	ld	s2,32(sp)
  ac:	6121                	addi	sp,sp,64
  ae:	8082                	ret
        printf("Error fetching info for PID %d\n", getpid());
  b0:	550000ef          	jal	600 <getpid>
  b4:	85aa                	mv	a1,a0
  b6:	00001517          	auipc	a0,0x1
  ba:	c1250513          	addi	a0,a0,-1006 # cc8 <malloc+0x20a>
  be:	149000ef          	jal	a06 <printf>
}
  c2:	b7cd                	j	a4 <print_stats+0xa4>

00000000000000c4 <cpu_bound_task>:

// CPU bound processes. It only has computation, no syscall or memread
void cpu_bound_task() {
  c4:	7179                	addi	sp,sp,-48
  c6:	f406                	sd	ra,40(sp)
  c8:	f022                	sd	s0,32(sp)
  ca:	ec26                	sd	s1,24(sp)
  cc:	1800                	addi	s0,sp,48
    int start_time = uptime();
  ce:	54a000ef          	jal	618 <uptime>
  d2:	84aa                	mv	s1,a0
    volatile int counter = 0;
  d4:	fc042e23          	sw	zero,-36(s0)
  d8:	46f9                	li	a3,30
void cpu_bound_task() {
  da:	0bebc637          	lui	a2,0xbebc
  de:	20060613          	addi	a2,a2,512 # bebc200 <base+0xbebb1f0>
  e2:	8732                	mv	a4,a2
    for(int j = 0; j < 30; j++) {
        for(int i = 0; i < 200000000; i++) counter++; 
  e4:	fdc42783          	lw	a5,-36(s0)
  e8:	2785                	addiw	a5,a5,1
  ea:	fcf42e23          	sw	a5,-36(s0)
  ee:	377d                	addiw	a4,a4,-1
  f0:	fb75                	bnez	a4,e4 <cpu_bound_task+0x20>
    for(int j = 0; j < 30; j++) {
  f2:	36fd                	addiw	a3,a3,-1
  f4:	f6fd                	bnez	a3,e2 <cpu_bound_task+0x1e>
    }
    print_stats("CPU-Bound", uptime() - start_time);
  f6:	522000ef          	jal	618 <uptime>
  fa:	409505bb          	subw	a1,a0,s1
  fe:	00001517          	auipc	a0,0x1
 102:	bea50513          	addi	a0,a0,-1046 # ce8 <malloc+0x22a>
 106:	efbff0ef          	jal	0 <print_stats>
    exit(0);
 10a:	4501                	li	a0,0
 10c:	474000ef          	jal	580 <exit>

0000000000000110 <interactive_task>:
}

// Interactive, high syscall process
void interactive_task() {
 110:	1101                	addi	sp,sp,-32
 112:	ec06                	sd	ra,24(sp)
 114:	e822                	sd	s0,16(sp)
 116:	e426                	sd	s1,8(sp)
 118:	e04a                	sd	s2,0(sp)
 11a:	1000                	addi	s0,sp,32
    int start_time = uptime();
 11c:	4fc000ef          	jal	618 <uptime>
 120:	892a                	mv	s2,a0
 122:	64e1                	lui	s1,0x18
 124:	6a048493          	addi	s1,s1,1696 # 186a0 <base+0x17690>
    for(int i = 0; i < 100000; i++) {
        getpid(); 
 128:	4d8000ef          	jal	600 <getpid>
    for(int i = 0; i < 100000; i++) {
 12c:	34fd                	addiw	s1,s1,-1
 12e:	fced                	bnez	s1,128 <interactive_task+0x18>
    }
    print_stats("Interactive (Syscall-Heavy)", uptime() - start_time);
 130:	4e8000ef          	jal	618 <uptime>
 134:	412505bb          	subw	a1,a0,s2
 138:	00001517          	auipc	a0,0x1
 13c:	bc050513          	addi	a0,a0,-1088 # cf8 <malloc+0x23a>
 140:	ec1ff0ef          	jal	0 <print_stats>
    exit(0);
 144:	4501                	li	a0,0
 146:	43a000ef          	jal	580 <exit>

000000000000014a <mixed_task_cpu_first>:
}

// mixed process, first CPU heavy then interactive
void mixed_task_cpu_first() {
 14a:	7179                	addi	sp,sp,-48
 14c:	f406                	sd	ra,40(sp)
 14e:	f022                	sd	s0,32(sp)
 150:	ec26                	sd	s1,24(sp)
 152:	e84a                	sd	s2,16(sp)
 154:	1800                	addi	s0,sp,48
    int start_time = uptime();
 156:	4c2000ef          	jal	618 <uptime>
 15a:	892a                	mv	s2,a0
    volatile int counter = 0;
 15c:	fc042e23          	sw	zero,-36(s0)
 160:	46bd                	li	a3,15
void mixed_task_cpu_first() {
 162:	0bebc637          	lui	a2,0xbebc
 166:	20060613          	addi	a2,a2,512 # bebc200 <base+0xbebb1f0>
 16a:	8732                	mv	a4,a2
    for(int j = 0; j < 15; j++) {
        for(int i = 0; i < 200000000; i++) counter++;
 16c:	fdc42783          	lw	a5,-36(s0)
 170:	2785                	addiw	a5,a5,1
 172:	fcf42e23          	sw	a5,-36(s0)
 176:	377d                	addiw	a4,a4,-1
 178:	fb75                	bnez	a4,16c <mixed_task_cpu_first+0x22>
    for(int j = 0; j < 15; j++) {
 17a:	36fd                	addiw	a3,a3,-1
 17c:	f6fd                	bnez	a3,16a <mixed_task_cpu_first+0x20>
 17e:	64b1                	lui	s1,0xc
 180:	35048493          	addi	s1,s1,848 # c350 <base+0xb340>
    }
    for(int i = 0; i < 50000; i++) getpid();
 184:	47c000ef          	jal	600 <getpid>
 188:	34fd                	addiw	s1,s1,-1
 18a:	fced                	bnez	s1,184 <mixed_task_cpu_first+0x3a>
    print_stats("Mixed (CPU then IO)", uptime() - start_time);
 18c:	48c000ef          	jal	618 <uptime>
 190:	412505bb          	subw	a1,a0,s2
 194:	00001517          	auipc	a0,0x1
 198:	b8450513          	addi	a0,a0,-1148 # d18 <malloc+0x25a>
 19c:	e65ff0ef          	jal	0 <print_stats>
    exit(0);
 1a0:	4501                	li	a0,0
 1a2:	3de000ef          	jal	580 <exit>

00000000000001a6 <mixed_task_io_first>:
}

// mixed process, first interactive then CPU heavy
void mixed_task_io_first() {
 1a6:	7179                	addi	sp,sp,-48
 1a8:	f406                	sd	ra,40(sp)
 1aa:	f022                	sd	s0,32(sp)
 1ac:	ec26                	sd	s1,24(sp)
 1ae:	e84a                	sd	s2,16(sp)
 1b0:	1800                	addi	s0,sp,48
    int start_time = uptime();
 1b2:	466000ef          	jal	618 <uptime>
 1b6:	892a                	mv	s2,a0
    volatile int counter = 0;
 1b8:	fc042e23          	sw	zero,-36(s0)
 1bc:	64b1                	lui	s1,0xc
 1be:	35048493          	addi	s1,s1,848 # c350 <base+0xb340>
    
    for(int i = 0; i < 50000; i++) getpid(); 
 1c2:	43e000ef          	jal	600 <getpid>
 1c6:	34fd                	addiw	s1,s1,-1
 1c8:	fced                	bnez	s1,1c2 <mixed_task_io_first+0x1c>
 1ca:	46bd                	li	a3,15
    volatile int counter = 0;
 1cc:	0bebc637          	lui	a2,0xbebc
 1d0:	20060613          	addi	a2,a2,512 # bebc200 <base+0xbebb1f0>
 1d4:	8732                	mv	a4,a2
    
    for(int j = 0; j < 15; j++) {  
        for(int i = 0; i < 200000000; i++) counter++;
 1d6:	fdc42783          	lw	a5,-36(s0)
 1da:	2785                	addiw	a5,a5,1
 1dc:	fcf42e23          	sw	a5,-36(s0)
 1e0:	377d                	addiw	a4,a4,-1
 1e2:	fb75                	bnez	a4,1d6 <mixed_task_io_first+0x30>
    for(int j = 0; j < 15; j++) {  
 1e4:	36fd                	addiw	a3,a3,-1
 1e6:	f6fd                	bnez	a3,1d4 <mixed_task_io_first+0x2e>
    }
    print_stats("Mixed (IO then CPU)", uptime() - start_time);
 1e8:	430000ef          	jal	618 <uptime>
 1ec:	412505bb          	subw	a1,a0,s2
 1f0:	00001517          	auipc	a0,0x1
 1f4:	b4050513          	addi	a0,a0,-1216 # d30 <malloc+0x272>
 1f8:	e09ff0ef          	jal	0 <print_stats>
    exit(0);
 1fc:	4501                	li	a0,0
 1fe:	382000ef          	jal	580 <exit>

0000000000000202 <sleeping_task>:
}

// voluntary yeilding processes
void sleeping_task() {
 202:	7179                	addi	sp,sp,-48
 204:	f406                	sd	ra,40(sp)
 206:	f022                	sd	s0,32(sp)
 208:	ec26                	sd	s1,24(sp)
 20a:	e84a                	sd	s2,16(sp)
 20c:	e44e                	sd	s3,8(sp)
 20e:	1800                	addi	s0,sp,48
    int start_time = uptime();
 210:	408000ef          	jal	618 <uptime>
 214:	89aa                	mv	s3,a0
 216:	44d1                	li	s1,20
    for(int i = 0; i < 20; i++) {
        pause(1); // voluntarily give up CPU
 218:	4905                	li	s2,1
 21a:	854a                	mv	a0,s2
 21c:	3f4000ef          	jal	610 <pause>
    for(int i = 0; i < 20; i++) {
 220:	34fd                	addiw	s1,s1,-1
 222:	fce5                	bnez	s1,21a <sleeping_task+0x18>
    }
    print_stats("Voluntary Yielder (Sleep)", uptime() - start_time);
 224:	3f4000ef          	jal	618 <uptime>
 228:	413505bb          	subw	a1,a0,s3
 22c:	00001517          	auipc	a0,0x1
 230:	b1c50513          	addi	a0,a0,-1252 # d48 <malloc+0x28a>
 234:	dcdff0ef          	jal	0 <print_stats>
    exit(0);
 238:	4501                	li	a0,0
 23a:	346000ef          	jal	580 <exit>

000000000000023e <main>:
}

int main() {
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	1000                	addi	s0,sp,32
    printf("\n--- Starting SC-MLFQ Comprehensive Benchmark ---\n");
 246:	00001517          	auipc	a0,0x1
 24a:	b2250513          	addi	a0,a0,-1246 # d68 <malloc+0x2aa>
 24e:	7b8000ef          	jal	a06 <printf>

    if(fork() == 0) cpu_bound_task();
 252:	326000ef          	jal	578 <fork>
 256:	e501                	bnez	a0,25e <main+0x20>
 258:	e426                	sd	s1,8(sp)
 25a:	e6bff0ef          	jal	c4 <cpu_bound_task>
    if(fork() == 0) cpu_bound_task();
 25e:	31a000ef          	jal	578 <fork>
 262:	e501                	bnez	a0,26a <main+0x2c>
 264:	e426                	sd	s1,8(sp)
 266:	e5fff0ef          	jal	c4 <cpu_bound_task>
    
    if(fork() == 0) interactive_task();
 26a:	30e000ef          	jal	578 <fork>
 26e:	e501                	bnez	a0,276 <main+0x38>
 270:	e426                	sd	s1,8(sp)
 272:	e9fff0ef          	jal	110 <interactive_task>
    if(fork() == 0) interactive_task();
 276:	302000ef          	jal	578 <fork>
 27a:	e501                	bnez	a0,282 <main+0x44>
 27c:	e426                	sd	s1,8(sp)
 27e:	e93ff0ef          	jal	110 <interactive_task>
    
    if(fork() == 0) mixed_task_cpu_first();
 282:	2f6000ef          	jal	578 <fork>
 286:	e501                	bnez	a0,28e <main+0x50>
 288:	e426                	sd	s1,8(sp)
 28a:	ec1ff0ef          	jal	14a <mixed_task_cpu_first>
    if(fork() == 0) mixed_task_io_first();
 28e:	2ea000ef          	jal	578 <fork>
 292:	e501                	bnez	a0,29a <main+0x5c>
 294:	e426                	sd	s1,8(sp)
 296:	f11ff0ef          	jal	1a6 <mixed_task_io_first>
 29a:	e426                	sd	s1,8(sp)
    
    if(fork() == 0) sleeping_task();
 29c:	2dc000ef          	jal	578 <fork>
 2a0:	479d                	li	a5,7
 2a2:	84be                	mv	s1,a5
 2a4:	c10d                	beqz	a0,2c6 <main+0x88>

    // Parent waits for all 7 children to finish
    for(int i = 0; i < 7; i++) {
        wait(0);
 2a6:	4501                	li	a0,0
 2a8:	2e0000ef          	jal	588 <wait>
    for(int i = 0; i < 7; i++) {
 2ac:	fff4879b          	addiw	a5,s1,-1
 2b0:	84be                	mv	s1,a5
 2b2:	fbf5                	bnez	a5,2a6 <main+0x68>
    }

    printf("\n--- All Benchmarks Completed ---\n");
 2b4:	00001517          	auipc	a0,0x1
 2b8:	aec50513          	addi	a0,a0,-1300 # da0 <malloc+0x2e2>
 2bc:	74a000ef          	jal	a06 <printf>
    exit(0);
 2c0:	4501                	li	a0,0
 2c2:	2be000ef          	jal	580 <exit>
    if(fork() == 0) sleeping_task();
 2c6:	f3dff0ef          	jal	202 <sleeping_task>

00000000000002ca <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2d2:	f6dff0ef          	jal	23e <main>
  exit(r);
 2d6:	2aa000ef          	jal	580 <exit>

00000000000002da <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e2:	87aa                	mv	a5,a0
 2e4:	0585                	addi	a1,a1,1
 2e6:	0785                	addi	a5,a5,1
 2e8:	fff5c703          	lbu	a4,-1(a1)
 2ec:	fee78fa3          	sb	a4,-1(a5)
 2f0:	fb75                	bnez	a4,2e4 <strcpy+0xa>
    ;
  return os;
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret

00000000000002fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e406                	sd	ra,8(sp)
 2fe:	e022                	sd	s0,0(sp)
 300:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 302:	00054783          	lbu	a5,0(a0)
 306:	cb91                	beqz	a5,31a <strcmp+0x20>
 308:	0005c703          	lbu	a4,0(a1)
 30c:	00f71763          	bne	a4,a5,31a <strcmp+0x20>
    p++, q++;
 310:	0505                	addi	a0,a0,1
 312:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 314:	00054783          	lbu	a5,0(a0)
 318:	fbe5                	bnez	a5,308 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 31a:	0005c503          	lbu	a0,0(a1)
}
 31e:	40a7853b          	subw	a0,a5,a0
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <strlen>:

uint
strlen(const char *s)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 332:	00054783          	lbu	a5,0(a0)
 336:	cf91                	beqz	a5,352 <strlen+0x28>
 338:	00150793          	addi	a5,a0,1
 33c:	86be                	mv	a3,a5
 33e:	0785                	addi	a5,a5,1
 340:	fff7c703          	lbu	a4,-1(a5)
 344:	ff65                	bnez	a4,33c <strlen+0x12>
 346:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  for(n = 0; s[n]; n++)
 352:	4501                	li	a0,0
 354:	bfdd                	j	34a <strlen+0x20>

0000000000000356 <memset>:

void*
memset(void *dst, int c, uint n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 35e:	ca19                	beqz	a2,374 <memset+0x1e>
 360:	87aa                	mv	a5,a0
 362:	1602                	slli	a2,a2,0x20
 364:	9201                	srli	a2,a2,0x20
 366:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 36a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 36e:	0785                	addi	a5,a5,1
 370:	fee79de3          	bne	a5,a4,36a <memset+0x14>
  }
  return dst;
}
 374:	60a2                	ld	ra,8(sp)
 376:	6402                	ld	s0,0(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <strchr>:

char*
strchr(const char *s, char c)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
  for(; *s; s++)
 384:	00054783          	lbu	a5,0(a0)
 388:	cf81                	beqz	a5,3a0 <strchr+0x24>
    if(*s == c)
 38a:	00f58763          	beq	a1,a5,398 <strchr+0x1c>
  for(; *s; s++)
 38e:	0505                	addi	a0,a0,1
 390:	00054783          	lbu	a5,0(a0)
 394:	fbfd                	bnez	a5,38a <strchr+0xe>
      return (char*)s;
  return 0;
 396:	4501                	li	a0,0
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfdd                	j	398 <strchr+0x1c>

00000000000003a4 <gets>:

char*
gets(char *buf, int max)
{
 3a4:	711d                	addi	sp,sp,-96
 3a6:	ec86                	sd	ra,88(sp)
 3a8:	e8a2                	sd	s0,80(sp)
 3aa:	e4a6                	sd	s1,72(sp)
 3ac:	e0ca                	sd	s2,64(sp)
 3ae:	fc4e                	sd	s3,56(sp)
 3b0:	f852                	sd	s4,48(sp)
 3b2:	f456                	sd	s5,40(sp)
 3b4:	f05a                	sd	s6,32(sp)
 3b6:	ec5e                	sd	s7,24(sp)
 3b8:	e862                	sd	s8,16(sp)
 3ba:	1080                	addi	s0,sp,96
 3bc:	8baa                	mv	s7,a0
 3be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c0:	892a                	mv	s2,a0
 3c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
 3c4:	faf40b13          	addi	s6,s0,-81
 3c8:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 3ca:	8c26                	mv	s8,s1
 3cc:	0014899b          	addiw	s3,s1,1
 3d0:	84ce                	mv	s1,s3
 3d2:	0349d463          	bge	s3,s4,3fa <gets+0x56>
    cc = read(0, &c, 1);
 3d6:	8656                	mv	a2,s5
 3d8:	85da                	mv	a1,s6
 3da:	4501                	li	a0,0
 3dc:	1bc000ef          	jal	598 <read>
    if(cc < 1)
 3e0:	00a05d63          	blez	a0,3fa <gets+0x56>
      break;
    buf[i++] = c;
 3e4:	faf44783          	lbu	a5,-81(s0)
 3e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3ec:	0905                	addi	s2,s2,1
 3ee:	ff678713          	addi	a4,a5,-10
 3f2:	c319                	beqz	a4,3f8 <gets+0x54>
 3f4:	17cd                	addi	a5,a5,-13
 3f6:	fbf1                	bnez	a5,3ca <gets+0x26>
    buf[i++] = c;
 3f8:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 3fa:	9c5e                	add	s8,s8,s7
 3fc:	000c0023          	sb	zero,0(s8)
  return buf;
}
 400:	855e                	mv	a0,s7
 402:	60e6                	ld	ra,88(sp)
 404:	6446                	ld	s0,80(sp)
 406:	64a6                	ld	s1,72(sp)
 408:	6906                	ld	s2,64(sp)
 40a:	79e2                	ld	s3,56(sp)
 40c:	7a42                	ld	s4,48(sp)
 40e:	7aa2                	ld	s5,40(sp)
 410:	7b02                	ld	s6,32(sp)
 412:	6be2                	ld	s7,24(sp)
 414:	6c42                	ld	s8,16(sp)
 416:	6125                	addi	sp,sp,96
 418:	8082                	ret

000000000000041a <stat>:

int
stat(const char *n, struct stat *st)
{
 41a:	1101                	addi	sp,sp,-32
 41c:	ec06                	sd	ra,24(sp)
 41e:	e822                	sd	s0,16(sp)
 420:	e04a                	sd	s2,0(sp)
 422:	1000                	addi	s0,sp,32
 424:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 426:	4581                	li	a1,0
 428:	198000ef          	jal	5c0 <open>
  if(fd < 0)
 42c:	02054263          	bltz	a0,450 <stat+0x36>
 430:	e426                	sd	s1,8(sp)
 432:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 434:	85ca                	mv	a1,s2
 436:	1a2000ef          	jal	5d8 <fstat>
 43a:	892a                	mv	s2,a0
  close(fd);
 43c:	8526                	mv	a0,s1
 43e:	16a000ef          	jal	5a8 <close>
  return r;
 442:	64a2                	ld	s1,8(sp)
}
 444:	854a                	mv	a0,s2
 446:	60e2                	ld	ra,24(sp)
 448:	6442                	ld	s0,16(sp)
 44a:	6902                	ld	s2,0(sp)
 44c:	6105                	addi	sp,sp,32
 44e:	8082                	ret
    return -1;
 450:	57fd                	li	a5,-1
 452:	893e                	mv	s2,a5
 454:	bfc5                	j	444 <stat+0x2a>

0000000000000456 <atoi>:

int
atoi(const char *s)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 45e:	00054683          	lbu	a3,0(a0)
 462:	fd06879b          	addiw	a5,a3,-48
 466:	0ff7f793          	zext.b	a5,a5
 46a:	4625                	li	a2,9
 46c:	02f66963          	bltu	a2,a5,49e <atoi+0x48>
 470:	872a                	mv	a4,a0
  n = 0;
 472:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 474:	0705                	addi	a4,a4,1
 476:	0025179b          	slliw	a5,a0,0x2
 47a:	9fa9                	addw	a5,a5,a0
 47c:	0017979b          	slliw	a5,a5,0x1
 480:	9fb5                	addw	a5,a5,a3
 482:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 486:	00074683          	lbu	a3,0(a4)
 48a:	fd06879b          	addiw	a5,a3,-48
 48e:	0ff7f793          	zext.b	a5,a5
 492:	fef671e3          	bgeu	a2,a5,474 <atoi+0x1e>
  return n;
}
 496:	60a2                	ld	ra,8(sp)
 498:	6402                	ld	s0,0(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret
  n = 0;
 49e:	4501                	li	a0,0
 4a0:	bfdd                	j	496 <atoi+0x40>

00000000000004a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e406                	sd	ra,8(sp)
 4a6:	e022                	sd	s0,0(sp)
 4a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4aa:	02b57563          	bgeu	a0,a1,4d4 <memmove+0x32>
    while(n-- > 0)
 4ae:	00c05f63          	blez	a2,4cc <memmove+0x2a>
 4b2:	1602                	slli	a2,a2,0x20
 4b4:	9201                	srli	a2,a2,0x20
 4b6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4ba:	872a                	mv	a4,a0
      *dst++ = *src++;
 4bc:	0585                	addi	a1,a1,1
 4be:	0705                	addi	a4,a4,1
 4c0:	fff5c683          	lbu	a3,-1(a1)
 4c4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4c8:	fee79ae3          	bne	a5,a4,4bc <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4cc:	60a2                	ld	ra,8(sp)
 4ce:	6402                	ld	s0,0(sp)
 4d0:	0141                	addi	sp,sp,16
 4d2:	8082                	ret
    while(n-- > 0)
 4d4:	fec05ce3          	blez	a2,4cc <memmove+0x2a>
    dst += n;
 4d8:	00c50733          	add	a4,a0,a2
    src += n;
 4dc:	95b2                	add	a1,a1,a2
 4de:	fff6079b          	addiw	a5,a2,-1
 4e2:	1782                	slli	a5,a5,0x20
 4e4:	9381                	srli	a5,a5,0x20
 4e6:	fff7c793          	not	a5,a5
 4ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ec:	15fd                	addi	a1,a1,-1
 4ee:	177d                	addi	a4,a4,-1
 4f0:	0005c683          	lbu	a3,0(a1)
 4f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f8:	fef71ae3          	bne	a4,a5,4ec <memmove+0x4a>
 4fc:	bfc1                	j	4cc <memmove+0x2a>

00000000000004fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4fe:	1141                	addi	sp,sp,-16
 500:	e406                	sd	ra,8(sp)
 502:	e022                	sd	s0,0(sp)
 504:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 506:	c61d                	beqz	a2,534 <memcmp+0x36>
 508:	1602                	slli	a2,a2,0x20
 50a:	9201                	srli	a2,a2,0x20
 50c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 510:	00054783          	lbu	a5,0(a0)
 514:	0005c703          	lbu	a4,0(a1)
 518:	00e79863          	bne	a5,a4,528 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 51c:	0505                	addi	a0,a0,1
    p2++;
 51e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 520:	fed518e3          	bne	a0,a3,510 <memcmp+0x12>
  }
  return 0;
 524:	4501                	li	a0,0
 526:	a019                	j	52c <memcmp+0x2e>
      return *p1 - *p2;
 528:	40e7853b          	subw	a0,a5,a4
}
 52c:	60a2                	ld	ra,8(sp)
 52e:	6402                	ld	s0,0(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret
  return 0;
 534:	4501                	li	a0,0
 536:	bfdd                	j	52c <memcmp+0x2e>

0000000000000538 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 538:	1141                	addi	sp,sp,-16
 53a:	e406                	sd	ra,8(sp)
 53c:	e022                	sd	s0,0(sp)
 53e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 540:	f63ff0ef          	jal	4a2 <memmove>
}
 544:	60a2                	ld	ra,8(sp)
 546:	6402                	ld	s0,0(sp)
 548:	0141                	addi	sp,sp,16
 54a:	8082                	ret

000000000000054c <sbrk>:

char *
sbrk(int n) {
 54c:	1141                	addi	sp,sp,-16
 54e:	e406                	sd	ra,8(sp)
 550:	e022                	sd	s0,0(sp)
 552:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 554:	4585                	li	a1,1
 556:	0b2000ef          	jal	608 <sys_sbrk>
}
 55a:	60a2                	ld	ra,8(sp)
 55c:	6402                	ld	s0,0(sp)
 55e:	0141                	addi	sp,sp,16
 560:	8082                	ret

0000000000000562 <sbrklazy>:

char *
sbrklazy(int n) {
 562:	1141                	addi	sp,sp,-16
 564:	e406                	sd	ra,8(sp)
 566:	e022                	sd	s0,0(sp)
 568:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 56a:	4589                	li	a1,2
 56c:	09c000ef          	jal	608 <sys_sbrk>
}
 570:	60a2                	ld	ra,8(sp)
 572:	6402                	ld	s0,0(sp)
 574:	0141                	addi	sp,sp,16
 576:	8082                	ret

0000000000000578 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 578:	4885                	li	a7,1
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <exit>:
.global exit
exit:
 li a7, SYS_exit
 580:	4889                	li	a7,2
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <wait>:
.global wait
wait:
 li a7, SYS_wait
 588:	488d                	li	a7,3
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 590:	4891                	li	a7,4
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <read>:
.global read
read:
 li a7, SYS_read
 598:	4895                	li	a7,5
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <write>:
.global write
write:
 li a7, SYS_write
 5a0:	48c1                	li	a7,16
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <close>:
.global close
close:
 li a7, SYS_close
 5a8:	48d5                	li	a7,21
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5b0:	4899                	li	a7,6
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5b8:	489d                	li	a7,7
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <open>:
.global open
open:
 li a7, SYS_open
 5c0:	48bd                	li	a7,15
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5c8:	48c5                	li	a7,17
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5d0:	48c9                	li	a7,18
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5d8:	48a1                	li	a7,8
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <link>:
.global link
link:
 li a7, SYS_link
 5e0:	48cd                	li	a7,19
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5e8:	48d1                	li	a7,20
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5f0:	48a5                	li	a7,9
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5f8:	48a9                	li	a7,10
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 600:	48ad                	li	a7,11
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 608:	48b1                	li	a7,12
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <pause>:
.global pause
pause:
 li a7, SYS_pause
 610:	48b5                	li	a7,13
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 618:	48b9                	li	a7,14
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <hello>:
.global hello
hello:
 li a7, SYS_hello
 620:	48d9                	li	a7,22
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <getpid2>:
.global getpid2
getpid2:
 li a7, SYS_getpid2
 628:	48dd                	li	a7,23
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 630:	48e1                	li	a7,24
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <getnumchild>:
.global getnumchild
getnumchild:
 li a7, SYS_getnumchild
 638:	48e5                	li	a7,25
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 640:	48e9                	li	a7,26
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <getchildsyscount>:
.global getchildsyscount
getchildsyscount:
 li a7, SYS_getchildsyscount
 648:	48ed                	li	a7,27
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <getlevel>:
.global getlevel
getlevel:
 li a7, SYS_getlevel
 650:	48f1                	li	a7,28
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <getmlfqinfo>:
.global getmlfqinfo
getmlfqinfo:
 li a7, SYS_getmlfqinfo
 658:	48f5                	li	a7,29
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 660:	1101                	addi	sp,sp,-32
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	1000                	addi	s0,sp,32
 668:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 66c:	4605                	li	a2,1
 66e:	fef40593          	addi	a1,s0,-17
 672:	f2fff0ef          	jal	5a0 <write>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6105                	addi	sp,sp,32
 67c:	8082                	ret

000000000000067e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 67e:	715d                	addi	sp,sp,-80
 680:	e486                	sd	ra,72(sp)
 682:	e0a2                	sd	s0,64(sp)
 684:	f84a                	sd	s2,48(sp)
 686:	f44e                	sd	s3,40(sp)
 688:	0880                	addi	s0,sp,80
 68a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 68c:	c6d1                	beqz	a3,718 <printint+0x9a>
 68e:	0805d563          	bgez	a1,718 <printint+0x9a>
    neg = 1;
    x = -xx;
 692:	40b005b3          	neg	a1,a1
    neg = 1;
 696:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 698:	fb840993          	addi	s3,s0,-72
  neg = 0;
 69c:	86ce                	mv	a3,s3
  i = 0;
 69e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6a0:	00000817          	auipc	a6,0x0
 6a4:	73080813          	addi	a6,a6,1840 # dd0 <digits>
 6a8:	88ba                	mv	a7,a4
 6aa:	0017051b          	addiw	a0,a4,1
 6ae:	872a                	mv	a4,a0
 6b0:	02c5f7b3          	remu	a5,a1,a2
 6b4:	97c2                	add	a5,a5,a6
 6b6:	0007c783          	lbu	a5,0(a5)
 6ba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6be:	87ae                	mv	a5,a1
 6c0:	02c5d5b3          	divu	a1,a1,a2
 6c4:	0685                	addi	a3,a3,1
 6c6:	fec7f1e3          	bgeu	a5,a2,6a8 <printint+0x2a>
  if(neg)
 6ca:	00030c63          	beqz	t1,6e2 <printint+0x64>
    buf[i++] = '-';
 6ce:	fd050793          	addi	a5,a0,-48
 6d2:	00878533          	add	a0,a5,s0
 6d6:	02d00793          	li	a5,45
 6da:	fef50423          	sb	a5,-24(a0)
 6de:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 6e2:	02e05563          	blez	a4,70c <printint+0x8e>
 6e6:	fc26                	sd	s1,56(sp)
 6e8:	377d                	addiw	a4,a4,-1
 6ea:	00e984b3          	add	s1,s3,a4
 6ee:	19fd                	addi	s3,s3,-1
 6f0:	99ba                	add	s3,s3,a4
 6f2:	1702                	slli	a4,a4,0x20
 6f4:	9301                	srli	a4,a4,0x20
 6f6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6fa:	0004c583          	lbu	a1,0(s1)
 6fe:	854a                	mv	a0,s2
 700:	f61ff0ef          	jal	660 <putc>
  while(--i >= 0)
 704:	14fd                	addi	s1,s1,-1
 706:	ff349ae3          	bne	s1,s3,6fa <printint+0x7c>
 70a:	74e2                	ld	s1,56(sp)
}
 70c:	60a6                	ld	ra,72(sp)
 70e:	6406                	ld	s0,64(sp)
 710:	7942                	ld	s2,48(sp)
 712:	79a2                	ld	s3,40(sp)
 714:	6161                	addi	sp,sp,80
 716:	8082                	ret
  neg = 0;
 718:	4301                	li	t1,0
 71a:	bfbd                	j	698 <printint+0x1a>

000000000000071c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71c:	711d                	addi	sp,sp,-96
 71e:	ec86                	sd	ra,88(sp)
 720:	e8a2                	sd	s0,80(sp)
 722:	e4a6                	sd	s1,72(sp)
 724:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 726:	0005c483          	lbu	s1,0(a1)
 72a:	22048363          	beqz	s1,950 <vprintf+0x234>
 72e:	e0ca                	sd	s2,64(sp)
 730:	fc4e                	sd	s3,56(sp)
 732:	f852                	sd	s4,48(sp)
 734:	f456                	sd	s5,40(sp)
 736:	f05a                	sd	s6,32(sp)
 738:	ec5e                	sd	s7,24(sp)
 73a:	e862                	sd	s8,16(sp)
 73c:	8b2a                	mv	s6,a0
 73e:	8a2e                	mv	s4,a1
 740:	8bb2                	mv	s7,a2
  state = 0;
 742:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 744:	4901                	li	s2,0
 746:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 748:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 74c:	06400c13          	li	s8,100
 750:	a00d                	j	772 <vprintf+0x56>
        putc(fd, c0);
 752:	85a6                	mv	a1,s1
 754:	855a                	mv	a0,s6
 756:	f0bff0ef          	jal	660 <putc>
 75a:	a019                	j	760 <vprintf+0x44>
    } else if(state == '%'){
 75c:	03598363          	beq	s3,s5,782 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 760:	0019079b          	addiw	a5,s2,1
 764:	893e                	mv	s2,a5
 766:	873e                	mv	a4,a5
 768:	97d2                	add	a5,a5,s4
 76a:	0007c483          	lbu	s1,0(a5)
 76e:	1c048a63          	beqz	s1,942 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 772:	0004879b          	sext.w	a5,s1
    if(state == 0){
 776:	fe0993e3          	bnez	s3,75c <vprintf+0x40>
      if(c0 == '%'){
 77a:	fd579ce3          	bne	a5,s5,752 <vprintf+0x36>
        state = '%';
 77e:	89be                	mv	s3,a5
 780:	b7c5                	j	760 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 782:	00ea06b3          	add	a3,s4,a4
 786:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 78a:	1c060863          	beqz	a2,95a <vprintf+0x23e>
      if(c0 == 'd'){
 78e:	03878763          	beq	a5,s8,7bc <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 792:	f9478693          	addi	a3,a5,-108
 796:	0016b693          	seqz	a3,a3
 79a:	f9c60593          	addi	a1,a2,-100
 79e:	e99d                	bnez	a1,7d4 <vprintf+0xb8>
 7a0:	ca95                	beqz	a3,7d4 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a2:	008b8493          	addi	s1,s7,8
 7a6:	4685                	li	a3,1
 7a8:	4629                	li	a2,10
 7aa:	000bb583          	ld	a1,0(s7)
 7ae:	855a                	mv	a0,s6
 7b0:	ecfff0ef          	jal	67e <printint>
        i += 1;
 7b4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b75d                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 7bc:	008b8493          	addi	s1,s7,8
 7c0:	4685                	li	a3,1
 7c2:	4629                	li	a2,10
 7c4:	000ba583          	lw	a1,0(s7)
 7c8:	855a                	mv	a0,s6
 7ca:	eb5ff0ef          	jal	67e <printint>
 7ce:	8ba6                	mv	s7,s1
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b779                	j	760 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 7d4:	9752                	add	a4,a4,s4
 7d6:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7da:	f9460713          	addi	a4,a2,-108
 7de:	00173713          	seqz	a4,a4
 7e2:	8f75                	and	a4,a4,a3
 7e4:	f9c58513          	addi	a0,a1,-100
 7e8:	18051363          	bnez	a0,96e <vprintf+0x252>
 7ec:	18070163          	beqz	a4,96e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7f0:	008b8493          	addi	s1,s7,8
 7f4:	4685                	li	a3,1
 7f6:	4629                	li	a2,10
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	e81ff0ef          	jal	67e <printint>
        i += 2;
 802:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 804:	8ba6                	mv	s7,s1
      state = 0;
 806:	4981                	li	s3,0
        i += 2;
 808:	bfa1                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 80a:	008b8493          	addi	s1,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000be583          	lwu	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	e67ff0ef          	jal	67e <printint>
 81c:	8ba6                	mv	s7,s1
      state = 0;
 81e:	4981                	li	s3,0
 820:	b781                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 822:	008b8493          	addi	s1,s7,8
 826:	4681                	li	a3,0
 828:	4629                	li	a2,10
 82a:	000bb583          	ld	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	e4fff0ef          	jal	67e <printint>
        i += 1;
 834:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	8ba6                	mv	s7,s1
      state = 0;
 838:	4981                	li	s3,0
 83a:	b71d                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83c:	008b8493          	addi	s1,s7,8
 840:	4681                	li	a3,0
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	e35ff0ef          	jal	67e <printint>
        i += 2;
 84e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	8ba6                	mv	s7,s1
      state = 0;
 852:	4981                	li	s3,0
        i += 2;
 854:	b731                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 856:	008b8493          	addi	s1,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000be583          	lwu	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	e1bff0ef          	jal	67e <printint>
 868:	8ba6                	mv	s7,s1
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bdd5                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86e:	008b8493          	addi	s1,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	e03ff0ef          	jal	67e <printint>
        i += 1;
 880:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	8ba6                	mv	s7,s1
      state = 0;
 884:	4981                	li	s3,0
 886:	bde9                	j	760 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 888:	008b8493          	addi	s1,s7,8
 88c:	4681                	li	a3,0
 88e:	4641                	li	a2,16
 890:	000bb583          	ld	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	de9ff0ef          	jal	67e <printint>
        i += 2;
 89a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 89c:	8ba6                	mv	s7,s1
      state = 0;
 89e:	4981                	li	s3,0
        i += 2;
 8a0:	b5c1                	j	760 <vprintf+0x44>
 8a2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 8a4:	008b8793          	addi	a5,s7,8
 8a8:	8cbe                	mv	s9,a5
 8aa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8ae:	03000593          	li	a1,48
 8b2:	855a                	mv	a0,s6
 8b4:	dadff0ef          	jal	660 <putc>
  putc(fd, 'x');
 8b8:	07800593          	li	a1,120
 8bc:	855a                	mv	a0,s6
 8be:	da3ff0ef          	jal	660 <putc>
 8c2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8c4:	00000b97          	auipc	s7,0x0
 8c8:	50cb8b93          	addi	s7,s7,1292 # dd0 <digits>
 8cc:	03c9d793          	srli	a5,s3,0x3c
 8d0:	97de                	add	a5,a5,s7
 8d2:	0007c583          	lbu	a1,0(a5)
 8d6:	855a                	mv	a0,s6
 8d8:	d89ff0ef          	jal	660 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8dc:	0992                	slli	s3,s3,0x4
 8de:	34fd                	addiw	s1,s1,-1
 8e0:	f4f5                	bnez	s1,8cc <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 8e2:	8be6                	mv	s7,s9
      state = 0;
 8e4:	4981                	li	s3,0
 8e6:	6ca2                	ld	s9,8(sp)
 8e8:	bda5                	j	760 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 8ea:	008b8493          	addi	s1,s7,8
 8ee:	000bc583          	lbu	a1,0(s7)
 8f2:	855a                	mv	a0,s6
 8f4:	d6dff0ef          	jal	660 <putc>
 8f8:	8ba6                	mv	s7,s1
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	b595                	j	760 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 8fe:	008b8993          	addi	s3,s7,8
 902:	000bb483          	ld	s1,0(s7)
 906:	cc91                	beqz	s1,922 <vprintf+0x206>
        for(; *s; s++)
 908:	0004c583          	lbu	a1,0(s1)
 90c:	c985                	beqz	a1,93c <vprintf+0x220>
          putc(fd, *s);
 90e:	855a                	mv	a0,s6
 910:	d51ff0ef          	jal	660 <putc>
        for(; *s; s++)
 914:	0485                	addi	s1,s1,1
 916:	0004c583          	lbu	a1,0(s1)
 91a:	f9f5                	bnez	a1,90e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 91c:	8bce                	mv	s7,s3
      state = 0;
 91e:	4981                	li	s3,0
 920:	b581                	j	760 <vprintf+0x44>
          s = "(null)";
 922:	00000497          	auipc	s1,0x0
 926:	4a648493          	addi	s1,s1,1190 # dc8 <malloc+0x30a>
        for(; *s; s++)
 92a:	02800593          	li	a1,40
 92e:	b7c5                	j	90e <vprintf+0x1f2>
        putc(fd, '%');
 930:	85be                	mv	a1,a5
 932:	855a                	mv	a0,s6
 934:	d2dff0ef          	jal	660 <putc>
      state = 0;
 938:	4981                	li	s3,0
 93a:	b51d                	j	760 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 93c:	8bce                	mv	s7,s3
      state = 0;
 93e:	4981                	li	s3,0
 940:	b505                	j	760 <vprintf+0x44>
 942:	6906                	ld	s2,64(sp)
 944:	79e2                	ld	s3,56(sp)
 946:	7a42                	ld	s4,48(sp)
 948:	7aa2                	ld	s5,40(sp)
 94a:	7b02                	ld	s6,32(sp)
 94c:	6be2                	ld	s7,24(sp)
 94e:	6c42                	ld	s8,16(sp)
    }
  }
}
 950:	60e6                	ld	ra,88(sp)
 952:	6446                	ld	s0,80(sp)
 954:	64a6                	ld	s1,72(sp)
 956:	6125                	addi	sp,sp,96
 958:	8082                	ret
      if(c0 == 'd'){
 95a:	06400713          	li	a4,100
 95e:	e4e78fe3          	beq	a5,a4,7bc <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 962:	f9478693          	addi	a3,a5,-108
 966:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 96a:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 96c:	4701                	li	a4,0
      } else if(c0 == 'u'){
 96e:	07500513          	li	a0,117
 972:	e8a78ce3          	beq	a5,a0,80a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 976:	f8b60513          	addi	a0,a2,-117
 97a:	e119                	bnez	a0,980 <vprintf+0x264>
 97c:	ea0693e3          	bnez	a3,822 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 980:	f8b58513          	addi	a0,a1,-117
 984:	e119                	bnez	a0,98a <vprintf+0x26e>
 986:	ea071be3          	bnez	a4,83c <vprintf+0x120>
      } else if(c0 == 'x'){
 98a:	07800513          	li	a0,120
 98e:	eca784e3          	beq	a5,a0,856 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 992:	f8860613          	addi	a2,a2,-120
 996:	e219                	bnez	a2,99c <vprintf+0x280>
 998:	ec069be3          	bnez	a3,86e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 99c:	f8858593          	addi	a1,a1,-120
 9a0:	e199                	bnez	a1,9a6 <vprintf+0x28a>
 9a2:	ee0713e3          	bnez	a4,888 <vprintf+0x16c>
      } else if(c0 == 'p'){
 9a6:	07000713          	li	a4,112
 9aa:	eee78ce3          	beq	a5,a4,8a2 <vprintf+0x186>
      } else if(c0 == 'c'){
 9ae:	06300713          	li	a4,99
 9b2:	f2e78ce3          	beq	a5,a4,8ea <vprintf+0x1ce>
      } else if(c0 == 's'){
 9b6:	07300713          	li	a4,115
 9ba:	f4e782e3          	beq	a5,a4,8fe <vprintf+0x1e2>
      } else if(c0 == '%'){
 9be:	02500713          	li	a4,37
 9c2:	f6e787e3          	beq	a5,a4,930 <vprintf+0x214>
        putc(fd, '%');
 9c6:	02500593          	li	a1,37
 9ca:	855a                	mv	a0,s6
 9cc:	c95ff0ef          	jal	660 <putc>
        putc(fd, c0);
 9d0:	85a6                	mv	a1,s1
 9d2:	855a                	mv	a0,s6
 9d4:	c8dff0ef          	jal	660 <putc>
      state = 0;
 9d8:	4981                	li	s3,0
 9da:	b359                	j	760 <vprintf+0x44>

00000000000009dc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9dc:	715d                	addi	sp,sp,-80
 9de:	ec06                	sd	ra,24(sp)
 9e0:	e822                	sd	s0,16(sp)
 9e2:	1000                	addi	s0,sp,32
 9e4:	e010                	sd	a2,0(s0)
 9e6:	e414                	sd	a3,8(s0)
 9e8:	e818                	sd	a4,16(s0)
 9ea:	ec1c                	sd	a5,24(s0)
 9ec:	03043023          	sd	a6,32(s0)
 9f0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9f4:	8622                	mv	a2,s0
 9f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9fa:	d23ff0ef          	jal	71c <vprintf>
}
 9fe:	60e2                	ld	ra,24(sp)
 a00:	6442                	ld	s0,16(sp)
 a02:	6161                	addi	sp,sp,80
 a04:	8082                	ret

0000000000000a06 <printf>:

void
printf(const char *fmt, ...)
{
 a06:	711d                	addi	sp,sp,-96
 a08:	ec06                	sd	ra,24(sp)
 a0a:	e822                	sd	s0,16(sp)
 a0c:	1000                	addi	s0,sp,32
 a0e:	e40c                	sd	a1,8(s0)
 a10:	e810                	sd	a2,16(s0)
 a12:	ec14                	sd	a3,24(s0)
 a14:	f018                	sd	a4,32(s0)
 a16:	f41c                	sd	a5,40(s0)
 a18:	03043823          	sd	a6,48(s0)
 a1c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a20:	00840613          	addi	a2,s0,8
 a24:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a28:	85aa                	mv	a1,a0
 a2a:	4505                	li	a0,1
 a2c:	cf1ff0ef          	jal	71c <vprintf>
}
 a30:	60e2                	ld	ra,24(sp)
 a32:	6442                	ld	s0,16(sp)
 a34:	6125                	addi	sp,sp,96
 a36:	8082                	ret

0000000000000a38 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a38:	1141                	addi	sp,sp,-16
 a3a:	e406                	sd	ra,8(sp)
 a3c:	e022                	sd	s0,0(sp)
 a3e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a40:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a44:	00000797          	auipc	a5,0x0
 a48:	5bc7b783          	ld	a5,1468(a5) # 1000 <freep>
 a4c:	a039                	j	a5a <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a4e:	6398                	ld	a4,0(a5)
 a50:	00e7e463          	bltu	a5,a4,a58 <free+0x20>
 a54:	00e6ea63          	bltu	a3,a4,a68 <free+0x30>
{
 a58:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a5a:	fed7fae3          	bgeu	a5,a3,a4e <free+0x16>
 a5e:	6398                	ld	a4,0(a5)
 a60:	00e6e463          	bltu	a3,a4,a68 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a64:	fee7eae3          	bltu	a5,a4,a58 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a68:	ff852583          	lw	a1,-8(a0)
 a6c:	6390                	ld	a2,0(a5)
 a6e:	02059813          	slli	a6,a1,0x20
 a72:	01c85713          	srli	a4,a6,0x1c
 a76:	9736                	add	a4,a4,a3
 a78:	02e60563          	beq	a2,a4,aa2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a7c:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 a80:	4790                	lw	a2,8(a5)
 a82:	02061593          	slli	a1,a2,0x20
 a86:	01c5d713          	srli	a4,a1,0x1c
 a8a:	973e                	add	a4,a4,a5
 a8c:	02e68263          	beq	a3,a4,ab0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a90:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a92:	00000717          	auipc	a4,0x0
 a96:	56f73723          	sd	a5,1390(a4) # 1000 <freep>
}
 a9a:	60a2                	ld	ra,8(sp)
 a9c:	6402                	ld	s0,0(sp)
 a9e:	0141                	addi	sp,sp,16
 aa0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 aa2:	4618                	lw	a4,8(a2)
 aa4:	9f2d                	addw	a4,a4,a1
 aa6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 aaa:	6398                	ld	a4,0(a5)
 aac:	6310                	ld	a2,0(a4)
 aae:	b7f9                	j	a7c <free+0x44>
    p->s.size += bp->s.size;
 ab0:	ff852703          	lw	a4,-8(a0)
 ab4:	9f31                	addw	a4,a4,a2
 ab6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ab8:	ff053683          	ld	a3,-16(a0)
 abc:	bfd1                	j	a90 <free+0x58>

0000000000000abe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 abe:	7139                	addi	sp,sp,-64
 ac0:	fc06                	sd	ra,56(sp)
 ac2:	f822                	sd	s0,48(sp)
 ac4:	f04a                	sd	s2,32(sp)
 ac6:	ec4e                	sd	s3,24(sp)
 ac8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aca:	02051993          	slli	s3,a0,0x20
 ace:	0209d993          	srli	s3,s3,0x20
 ad2:	09bd                	addi	s3,s3,15
 ad4:	0049d993          	srli	s3,s3,0x4
 ad8:	2985                	addiw	s3,s3,1
 ada:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 adc:	00000517          	auipc	a0,0x0
 ae0:	52453503          	ld	a0,1316(a0) # 1000 <freep>
 ae4:	c905                	beqz	a0,b14 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae8:	4798                	lw	a4,8(a5)
 aea:	09377663          	bgeu	a4,s3,b76 <malloc+0xb8>
 aee:	f426                	sd	s1,40(sp)
 af0:	e852                	sd	s4,16(sp)
 af2:	e456                	sd	s5,8(sp)
 af4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 af6:	8a4e                	mv	s4,s3
 af8:	6705                	lui	a4,0x1
 afa:	00e9f363          	bgeu	s3,a4,b00 <malloc+0x42>
 afe:	6a05                	lui	s4,0x1
 b00:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b04:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b08:	00000497          	auipc	s1,0x0
 b0c:	4f848493          	addi	s1,s1,1272 # 1000 <freep>
  if(p == SBRK_ERROR)
 b10:	5afd                	li	s5,-1
 b12:	a83d                	j	b50 <malloc+0x92>
 b14:	f426                	sd	s1,40(sp)
 b16:	e852                	sd	s4,16(sp)
 b18:	e456                	sd	s5,8(sp)
 b1a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b1c:	00000797          	auipc	a5,0x0
 b20:	4f478793          	addi	a5,a5,1268 # 1010 <base>
 b24:	00000717          	auipc	a4,0x0
 b28:	4cf73e23          	sd	a5,1244(a4) # 1000 <freep>
 b2c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b2e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b32:	b7d1                	j	af6 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 b34:	6398                	ld	a4,0(a5)
 b36:	e118                	sd	a4,0(a0)
 b38:	a899                	j	b8e <malloc+0xd0>
  hp->s.size = nu;
 b3a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b3e:	0541                	addi	a0,a0,16
 b40:	ef9ff0ef          	jal	a38 <free>
  return freep;
 b44:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 b46:	c125                	beqz	a0,ba6 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b48:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b4a:	4798                	lw	a4,8(a5)
 b4c:	03277163          	bgeu	a4,s2,b6e <malloc+0xb0>
    if(p == freep)
 b50:	6098                	ld	a4,0(s1)
 b52:	853e                	mv	a0,a5
 b54:	fef71ae3          	bne	a4,a5,b48 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 b58:	8552                	mv	a0,s4
 b5a:	9f3ff0ef          	jal	54c <sbrk>
  if(p == SBRK_ERROR)
 b5e:	fd551ee3          	bne	a0,s5,b3a <malloc+0x7c>
        return 0;
 b62:	4501                	li	a0,0
 b64:	74a2                	ld	s1,40(sp)
 b66:	6a42                	ld	s4,16(sp)
 b68:	6aa2                	ld	s5,8(sp)
 b6a:	6b02                	ld	s6,0(sp)
 b6c:	a03d                	j	b9a <malloc+0xdc>
 b6e:	74a2                	ld	s1,40(sp)
 b70:	6a42                	ld	s4,16(sp)
 b72:	6aa2                	ld	s5,8(sp)
 b74:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b76:	fae90fe3          	beq	s2,a4,b34 <malloc+0x76>
        p->s.size -= nunits;
 b7a:	4137073b          	subw	a4,a4,s3
 b7e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b80:	02071693          	slli	a3,a4,0x20
 b84:	01c6d713          	srli	a4,a3,0x1c
 b88:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b8a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b8e:	00000717          	auipc	a4,0x0
 b92:	46a73923          	sd	a0,1138(a4) # 1000 <freep>
      return (void*)(p + 1);
 b96:	01078513          	addi	a0,a5,16
  }
}
 b9a:	70e2                	ld	ra,56(sp)
 b9c:	7442                	ld	s0,48(sp)
 b9e:	7902                	ld	s2,32(sp)
 ba0:	69e2                	ld	s3,24(sp)
 ba2:	6121                	addi	sp,sp,64
 ba4:	8082                	ret
 ba6:	74a2                	ld	s1,40(sp)
 ba8:	6a42                	ld	s4,16(sp)
 baa:	6aa2                	ld	s5,8(sp)
 bac:	6b02                	ld	s6,0(sp)
 bae:	b7f5                	j	b9a <malloc+0xdc>
