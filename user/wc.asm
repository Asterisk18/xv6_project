
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	20000d93          	li	s11,512
  32:	00001d17          	auipc	s10,0x1
  36:	fded0d13          	addi	s10,s10,-34 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  3a:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  3c:	00001a17          	auipc	s4,0x1
  40:	a14a0a13          	addi	s4,s4,-1516 # a50 <malloc+0x100>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  44:	a035                	j	70 <wc+0x70>
      if(strchr(" \r\t\n\v", buf[i]))
  46:	8552                	mv	a0,s4
  48:	1c6000ef          	jal	20e <strchr>
  4c:	c919                	beqz	a0,62 <wc+0x62>
        inword = 0;
  4e:	4901                	li	s2,0
    for(i=0; i<n; i++){
  50:	0485                	addi	s1,s1,1
  52:	01348d63          	beq	s1,s3,6c <wc+0x6c>
      if(buf[i] == '\n')
  56:	0004c583          	lbu	a1,0(s1)
  5a:	ff5596e3          	bne	a1,s5,46 <wc+0x46>
        l++;
  5e:	2b85                	addiw	s7,s7,1
  60:	b7dd                	j	46 <wc+0x46>
      else if(!inword){
  62:	fe0917e3          	bnez	s2,50 <wc+0x50>
        w++;
  66:	2c05                	addiw	s8,s8,1
        inword = 1;
  68:	4905                	li	s2,1
  6a:	b7dd                	j	50 <wc+0x50>
  6c:	019b0cbb          	addw	s9,s6,s9
  while((n = read(fd, buf, sizeof(buf))) > 0){
  70:	866e                	mv	a2,s11
  72:	85ea                	mv	a1,s10
  74:	f8843503          	ld	a0,-120(s0)
  78:	3b2000ef          	jal	42a <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009b09b3          	add	s3,s6,s1
  8e:	b7e1                	j	56 <wc+0x56>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86e6                	mv	a3,s9
  9a:	8662                	mv	a2,s8
  9c:	85de                	mv	a1,s7
  9e:	00001517          	auipc	a0,0x1
  a2:	9d250513          	addi	a0,a0,-1582 # a70 <malloc+0x120>
  a6:	7f2000ef          	jal	898 <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	99850513          	addi	a0,a0,-1640 # a60 <malloc+0x110>
  d0:	7c8000ef          	jal	898 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	33c000ef          	jal	412 <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	34a000ef          	jal	452 <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	31e000ef          	jal	43a <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2ea000ef          	jal	412 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	92658593          	addi	a1,a1,-1754 # a58 <malloc+0x108>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2d0000ef          	jal	412 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	93650513          	addi	a0,a0,-1738 # a80 <malloc+0x130>
 152:	746000ef          	jal	898 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	2ba000ef          	jal	412 <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 164:	f77ff0ef          	jal	da <main>
  exit(r);
 168:	2aa000ef          	jal	412 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e406                	sd	ra,8(sp)
 170:	e022                	sd	s0,0(sp)
 172:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 174:	87aa                	mv	a5,a0
 176:	0585                	addi	a1,a1,1
 178:	0785                	addi	a5,a5,1
 17a:	fff5c703          	lbu	a4,-1(a1)
 17e:	fee78fa3          	sb	a4,-1(a5)
 182:	fb75                	bnez	a4,176 <strcpy+0xa>
    ;
  return os;
}
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret

000000000000018c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x20>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x20>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	60a2                	ld	ra,8(sp)
 1b6:	6402                	ld	s0,0(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strlen>:

uint
strlen(const char *s)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	cf91                	beqz	a5,1e4 <strlen+0x28>
 1ca:	00150793          	addi	a5,a0,1
 1ce:	86be                	mv	a3,a5
 1d0:	0785                	addi	a5,a5,1
 1d2:	fff7c703          	lbu	a4,-1(a5)
 1d6:	ff65                	bnez	a4,1ce <strlen+0x12>
 1d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1dc:	60a2                	ld	ra,8(sp)
 1de:	6402                	ld	s0,0(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  for(n = 0; s[n]; n++)
 1e4:	4501                	li	a0,0
 1e6:	bfdd                	j	1dc <strlen+0x20>

00000000000001e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f0:	ca19                	beqz	a2,206 <memset+0x1e>
 1f2:	87aa                	mv	a5,a0
 1f4:	1602                	slli	a2,a2,0x20
 1f6:	9201                	srli	a2,a2,0x20
 1f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 200:	0785                	addi	a5,a5,1
 202:	fee79de3          	bne	a5,a4,1fc <memset+0x14>
  }
  return dst;
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strchr>:

char*
strchr(const char *s, char c)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e406                	sd	ra,8(sp)
 212:	e022                	sd	s0,0(sp)
 214:	0800                	addi	s0,sp,16
  for(; *s; s++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cf81                	beqz	a5,232 <strchr+0x24>
    if(*s == c)
 21c:	00f58763          	beq	a1,a5,22a <strchr+0x1c>
  for(; *s; s++)
 220:	0505                	addi	a0,a0,1
 222:	00054783          	lbu	a5,0(a0)
 226:	fbfd                	bnez	a5,21c <strchr+0xe>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	60a2                	ld	ra,8(sp)
 22c:	6402                	ld	s0,0(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  return 0;
 232:	4501                	li	a0,0
 234:	bfdd                	j	22a <strchr+0x1c>

0000000000000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	711d                	addi	sp,sp,-96
 238:	ec86                	sd	ra,88(sp)
 23a:	e8a2                	sd	s0,80(sp)
 23c:	e4a6                	sd	s1,72(sp)
 23e:	e0ca                	sd	s2,64(sp)
 240:	fc4e                	sd	s3,56(sp)
 242:	f852                	sd	s4,48(sp)
 244:	f456                	sd	s5,40(sp)
 246:	f05a                	sd	s6,32(sp)
 248:	ec5e                	sd	s7,24(sp)
 24a:	e862                	sd	s8,16(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
 256:	faf40b13          	addi	s6,s0,-81
 25a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 25c:	8c26                	mv	s8,s1
 25e:	0014899b          	addiw	s3,s1,1
 262:	84ce                	mv	s1,s3
 264:	0349d463          	bge	s3,s4,28c <gets+0x56>
    cc = read(0, &c, 1);
 268:	8656                	mv	a2,s5
 26a:	85da                	mv	a1,s6
 26c:	4501                	li	a0,0
 26e:	1bc000ef          	jal	42a <read>
    if(cc < 1)
 272:	00a05d63          	blez	a0,28c <gets+0x56>
      break;
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	0905                	addi	s2,s2,1
 280:	ff678713          	addi	a4,a5,-10
 284:	c319                	beqz	a4,28a <gets+0x54>
 286:	17cd                	addi	a5,a5,-13
 288:	fbf1                	bnez	a5,25c <gets+0x26>
    buf[i++] = c;
 28a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 28c:	9c5e                	add	s8,s8,s7
 28e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6c42                	ld	s8,16(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	198000ef          	jal	452 <open>
  if(fd < 0)
 2be:	02054263          	bltz	a0,2e2 <stat+0x36>
 2c2:	e426                	sd	s1,8(sp)
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	1a2000ef          	jal	46a <fstat>
 2cc:	892a                	mv	s2,a0
  close(fd);
 2ce:	8526                	mv	a0,s1
 2d0:	16a000ef          	jal	43a <close>
  return r;
 2d4:	64a2                	ld	s1,8(sp)
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	57fd                	li	a5,-1
 2e4:	893e                	mv	s2,a5
 2e6:	bfc5                	j	2d6 <stat+0x2a>

00000000000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f0:	00054683          	lbu	a3,0(a0)
 2f4:	fd06879b          	addiw	a5,a3,-48
 2f8:	0ff7f793          	zext.b	a5,a5
 2fc:	4625                	li	a2,9
 2fe:	02f66963          	bltu	a2,a5,330 <atoi+0x48>
 302:	872a                	mv	a4,a0
  n = 0;
 304:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 306:	0705                	addi	a4,a4,1
 308:	0025179b          	slliw	a5,a0,0x2
 30c:	9fa9                	addw	a5,a5,a0
 30e:	0017979b          	slliw	a5,a5,0x1
 312:	9fb5                	addw	a5,a5,a3
 314:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 318:	00074683          	lbu	a3,0(a4)
 31c:	fd06879b          	addiw	a5,a3,-48
 320:	0ff7f793          	zext.b	a5,a5
 324:	fef671e3          	bgeu	a2,a5,306 <atoi+0x1e>
  return n;
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  n = 0;
 330:	4501                	li	a0,0
 332:	bfdd                	j	328 <atoi+0x40>

0000000000000334 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33c:	02b57563          	bgeu	a0,a1,366 <memmove+0x32>
    while(n-- > 0)
 340:	00c05f63          	blez	a2,35e <memmove+0x2a>
 344:	1602                	slli	a2,a2,0x20
 346:	9201                	srli	a2,a2,0x20
 348:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
    while(n-- > 0)
 366:	fec05ce3          	blez	a2,35e <memmove+0x2a>
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
 370:	fff6079b          	addiw	a5,a2,-1
 374:	1782                	slli	a5,a5,0x20
 376:	9381                	srli	a5,a5,0x20
 378:	fff7c793          	not	a5,a5
 37c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37e:	15fd                	addi	a1,a1,-1
 380:	177d                	addi	a4,a4,-1
 382:	0005c683          	lbu	a3,0(a1)
 386:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38a:	fef71ae3          	bne	a4,a5,37e <memmove+0x4a>
 38e:	bfc1                	j	35e <memmove+0x2a>

0000000000000390 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e406                	sd	ra,8(sp)
 394:	e022                	sd	s0,0(sp)
 396:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 398:	c61d                	beqz	a2,3c6 <memcmp+0x36>
 39a:	1602                	slli	a2,a2,0x20
 39c:	9201                	srli	a2,a2,0x20
 39e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x12>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x2e>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfdd                	j	3be <memcmp+0x2e>

00000000000003ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e406                	sd	ra,8(sp)
 3ce:	e022                	sd	s0,0(sp)
 3d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d2:	f63ff0ef          	jal	334 <memmove>
}
 3d6:	60a2                	ld	ra,8(sp)
 3d8:	6402                	ld	s0,0(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <sbrk>:

char *
sbrk(int n) {
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e6:	4585                	li	a1,1
 3e8:	0b2000ef          	jal	49a <sys_sbrk>
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret

00000000000003f4 <sbrklazy>:

char *
sbrklazy(int n) {
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3fc:	4589                	li	a1,2
 3fe:	09c000ef          	jal	49a <sys_sbrk>
}
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40a:	4885                	li	a7,1
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exit>:
.global exit
exit:
 li a7, SYS_exit
 412:	4889                	li	a7,2
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <wait>:
.global wait
wait:
 li a7, SYS_wait
 41a:	488d                	li	a7,3
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 422:	4891                	li	a7,4
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <read>:
.global read
read:
 li a7, SYS_read
 42a:	4895                	li	a7,5
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <write>:
.global write
write:
 li a7, SYS_write
 432:	48c1                	li	a7,16
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <close>:
.global close
close:
 li a7, SYS_close
 43a:	48d5                	li	a7,21
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <kill>:
.global kill
kill:
 li a7, SYS_kill
 442:	4899                	li	a7,6
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exec>:
.global exec
exec:
 li a7, SYS_exec
 44a:	489d                	li	a7,7
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <open>:
.global open
open:
 li a7, SYS_open
 452:	48bd                	li	a7,15
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45a:	48c5                	li	a7,17
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 462:	48c9                	li	a7,18
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46a:	48a1                	li	a7,8
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <link>:
.global link
link:
 li a7, SYS_link
 472:	48cd                	li	a7,19
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47a:	48d1                	li	a7,20
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 482:	48a5                	li	a7,9
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <dup>:
.global dup
dup:
 li a7, SYS_dup
 48a:	48a9                	li	a7,10
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 492:	48ad                	li	a7,11
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 49a:	48b1                	li	a7,12
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4a2:	48b5                	li	a7,13
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4aa:	48b9                	li	a7,14
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <hello>:
.global hello
hello:
 li a7, SYS_hello
 4b2:	48d9                	li	a7,22
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <getpid2>:
.global getpid2
getpid2:
 li a7, SYS_getpid2
 4ba:	48dd                	li	a7,23
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4c2:	48e1                	li	a7,24
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <getnumchild>:
.global getnumchild
getnumchild:
 li a7, SYS_getnumchild
 4ca:	48e5                	li	a7,25
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 4d2:	48e9                	li	a7,26
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getchildsyscount>:
.global getchildsyscount
getchildsyscount:
 li a7, SYS_getchildsyscount
 4da:	48ed                	li	a7,27
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <getlevel>:
.global getlevel
getlevel:
 li a7, SYS_getlevel
 4e2:	48f1                	li	a7,28
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <getmlfqinfo>:
.global getmlfqinfo
getmlfqinfo:
 li a7, SYS_getmlfqinfo
 4ea:	48f5                	li	a7,29
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f2:	1101                	addi	sp,sp,-32
 4f4:	ec06                	sd	ra,24(sp)
 4f6:	e822                	sd	s0,16(sp)
 4f8:	1000                	addi	s0,sp,32
 4fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fe:	4605                	li	a2,1
 500:	fef40593          	addi	a1,s0,-17
 504:	f2fff0ef          	jal	432 <write>
}
 508:	60e2                	ld	ra,24(sp)
 50a:	6442                	ld	s0,16(sp)
 50c:	6105                	addi	sp,sp,32
 50e:	8082                	ret

0000000000000510 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 510:	715d                	addi	sp,sp,-80
 512:	e486                	sd	ra,72(sp)
 514:	e0a2                	sd	s0,64(sp)
 516:	f84a                	sd	s2,48(sp)
 518:	f44e                	sd	s3,40(sp)
 51a:	0880                	addi	s0,sp,80
 51c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 51e:	c6d1                	beqz	a3,5aa <printint+0x9a>
 520:	0805d563          	bgez	a1,5aa <printint+0x9a>
    neg = 1;
    x = -xx;
 524:	40b005b3          	neg	a1,a1
    neg = 1;
 528:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 52a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 52e:	86ce                	mv	a3,s3
  i = 0;
 530:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 532:	00000817          	auipc	a6,0x0
 536:	56e80813          	addi	a6,a6,1390 # aa0 <digits>
 53a:	88ba                	mv	a7,a4
 53c:	0017051b          	addiw	a0,a4,1
 540:	872a                	mv	a4,a0
 542:	02c5f7b3          	remu	a5,a1,a2
 546:	97c2                	add	a5,a5,a6
 548:	0007c783          	lbu	a5,0(a5)
 54c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 550:	87ae                	mv	a5,a1
 552:	02c5d5b3          	divu	a1,a1,a2
 556:	0685                	addi	a3,a3,1
 558:	fec7f1e3          	bgeu	a5,a2,53a <printint+0x2a>
  if(neg)
 55c:	00030c63          	beqz	t1,574 <printint+0x64>
    buf[i++] = '-';
 560:	fd050793          	addi	a5,a0,-48
 564:	00878533          	add	a0,a5,s0
 568:	02d00793          	li	a5,45
 56c:	fef50423          	sb	a5,-24(a0)
 570:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 574:	02e05563          	blez	a4,59e <printint+0x8e>
 578:	fc26                	sd	s1,56(sp)
 57a:	377d                	addiw	a4,a4,-1
 57c:	00e984b3          	add	s1,s3,a4
 580:	19fd                	addi	s3,s3,-1
 582:	99ba                	add	s3,s3,a4
 584:	1702                	slli	a4,a4,0x20
 586:	9301                	srli	a4,a4,0x20
 588:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 58c:	0004c583          	lbu	a1,0(s1)
 590:	854a                	mv	a0,s2
 592:	f61ff0ef          	jal	4f2 <putc>
  while(--i >= 0)
 596:	14fd                	addi	s1,s1,-1
 598:	ff349ae3          	bne	s1,s3,58c <printint+0x7c>
 59c:	74e2                	ld	s1,56(sp)
}
 59e:	60a6                	ld	ra,72(sp)
 5a0:	6406                	ld	s0,64(sp)
 5a2:	7942                	ld	s2,48(sp)
 5a4:	79a2                	ld	s3,40(sp)
 5a6:	6161                	addi	sp,sp,80
 5a8:	8082                	ret
  neg = 0;
 5aa:	4301                	li	t1,0
 5ac:	bfbd                	j	52a <printint+0x1a>

00000000000005ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ae:	711d                	addi	sp,sp,-96
 5b0:	ec86                	sd	ra,88(sp)
 5b2:	e8a2                	sd	s0,80(sp)
 5b4:	e4a6                	sd	s1,72(sp)
 5b6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b8:	0005c483          	lbu	s1,0(a1)
 5bc:	22048363          	beqz	s1,7e2 <vprintf+0x234>
 5c0:	e0ca                	sd	s2,64(sp)
 5c2:	fc4e                	sd	s3,56(sp)
 5c4:	f852                	sd	s4,48(sp)
 5c6:	f456                	sd	s5,40(sp)
 5c8:	f05a                	sd	s6,32(sp)
 5ca:	ec5e                	sd	s7,24(sp)
 5cc:	e862                	sd	s8,16(sp)
 5ce:	8b2a                	mv	s6,a0
 5d0:	8a2e                	mv	s4,a1
 5d2:	8bb2                	mv	s7,a2
  state = 0;
 5d4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5d6:	4901                	li	s2,0
 5d8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5da:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5de:	06400c13          	li	s8,100
 5e2:	a00d                	j	604 <vprintf+0x56>
        putc(fd, c0);
 5e4:	85a6                	mv	a1,s1
 5e6:	855a                	mv	a0,s6
 5e8:	f0bff0ef          	jal	4f2 <putc>
 5ec:	a019                	j	5f2 <vprintf+0x44>
    } else if(state == '%'){
 5ee:	03598363          	beq	s3,s5,614 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5f2:	0019079b          	addiw	a5,s2,1
 5f6:	893e                	mv	s2,a5
 5f8:	873e                	mv	a4,a5
 5fa:	97d2                	add	a5,a5,s4
 5fc:	0007c483          	lbu	s1,0(a5)
 600:	1c048a63          	beqz	s1,7d4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 604:	0004879b          	sext.w	a5,s1
    if(state == 0){
 608:	fe0993e3          	bnez	s3,5ee <vprintf+0x40>
      if(c0 == '%'){
 60c:	fd579ce3          	bne	a5,s5,5e4 <vprintf+0x36>
        state = '%';
 610:	89be                	mv	s3,a5
 612:	b7c5                	j	5f2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 614:	00ea06b3          	add	a3,s4,a4
 618:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 61c:	1c060863          	beqz	a2,7ec <vprintf+0x23e>
      if(c0 == 'd'){
 620:	03878763          	beq	a5,s8,64e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 624:	f9478693          	addi	a3,a5,-108
 628:	0016b693          	seqz	a3,a3
 62c:	f9c60593          	addi	a1,a2,-100
 630:	e99d                	bnez	a1,666 <vprintf+0xb8>
 632:	ca95                	beqz	a3,666 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 634:	008b8493          	addi	s1,s7,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	ecfff0ef          	jal	510 <printint>
        i += 1;
 646:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 64a:	4981                	li	s3,0
 64c:	b75d                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 64e:	008b8493          	addi	s1,s7,8
 652:	4685                	li	a3,1
 654:	4629                	li	a2,10
 656:	000ba583          	lw	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	eb5ff0ef          	jal	510 <printint>
 660:	8ba6                	mv	s7,s1
      state = 0;
 662:	4981                	li	s3,0
 664:	b779                	j	5f2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 666:	9752                	add	a4,a4,s4
 668:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66c:	f9460713          	addi	a4,a2,-108
 670:	00173713          	seqz	a4,a4
 674:	8f75                	and	a4,a4,a3
 676:	f9c58513          	addi	a0,a1,-100
 67a:	18051363          	bnez	a0,800 <vprintf+0x252>
 67e:	18070163          	beqz	a4,800 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 682:	008b8493          	addi	s1,s7,8
 686:	4685                	li	a3,1
 688:	4629                	li	a2,10
 68a:	000bb583          	ld	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	e81ff0ef          	jal	510 <printint>
        i += 2;
 694:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	8ba6                	mv	s7,s1
      state = 0;
 698:	4981                	li	s3,0
        i += 2;
 69a:	bfa1                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69c:	008b8493          	addi	s1,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4629                	li	a2,10
 6a4:	000be583          	lwu	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	e67ff0ef          	jal	510 <printint>
 6ae:	8ba6                	mv	s7,s1
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b781                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b4:	008b8493          	addi	s1,s7,8
 6b8:	4681                	li	a3,0
 6ba:	4629                	li	a2,10
 6bc:	000bb583          	ld	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	e4fff0ef          	jal	510 <printint>
        i += 1;
 6c6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c8:	8ba6                	mv	s7,s1
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b71d                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ce:	008b8493          	addi	s1,s7,8
 6d2:	4681                	li	a3,0
 6d4:	4629                	li	a2,10
 6d6:	000bb583          	ld	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	e35ff0ef          	jal	510 <printint>
        i += 2;
 6e0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e2:	8ba6                	mv	s7,s1
      state = 0;
 6e4:	4981                	li	s3,0
        i += 2;
 6e6:	b731                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e8:	008b8493          	addi	s1,s7,8
 6ec:	4681                	li	a3,0
 6ee:	4641                	li	a2,16
 6f0:	000be583          	lwu	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	e1bff0ef          	jal	510 <printint>
 6fa:	8ba6                	mv	s7,s1
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bdd5                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 700:	008b8493          	addi	s1,s7,8
 704:	4681                	li	a3,0
 706:	4641                	li	a2,16
 708:	000bb583          	ld	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	e03ff0ef          	jal	510 <printint>
        i += 1;
 712:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 714:	8ba6                	mv	s7,s1
      state = 0;
 716:	4981                	li	s3,0
 718:	bde9                	j	5f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 71a:	008b8493          	addi	s1,s7,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000bb583          	ld	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	de9ff0ef          	jal	510 <printint>
        i += 2;
 72c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72e:	8ba6                	mv	s7,s1
      state = 0;
 730:	4981                	li	s3,0
        i += 2;
 732:	b5c1                	j	5f2 <vprintf+0x44>
 734:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 736:	008b8793          	addi	a5,s7,8
 73a:	8cbe                	mv	s9,a5
 73c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 740:	03000593          	li	a1,48
 744:	855a                	mv	a0,s6
 746:	dadff0ef          	jal	4f2 <putc>
  putc(fd, 'x');
 74a:	07800593          	li	a1,120
 74e:	855a                	mv	a0,s6
 750:	da3ff0ef          	jal	4f2 <putc>
 754:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 756:	00000b97          	auipc	s7,0x0
 75a:	34ab8b93          	addi	s7,s7,842 # aa0 <digits>
 75e:	03c9d793          	srli	a5,s3,0x3c
 762:	97de                	add	a5,a5,s7
 764:	0007c583          	lbu	a1,0(a5)
 768:	855a                	mv	a0,s6
 76a:	d89ff0ef          	jal	4f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 76e:	0992                	slli	s3,s3,0x4
 770:	34fd                	addiw	s1,s1,-1
 772:	f4f5                	bnez	s1,75e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 774:	8be6                	mv	s7,s9
      state = 0;
 776:	4981                	li	s3,0
 778:	6ca2                	ld	s9,8(sp)
 77a:	bda5                	j	5f2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 77c:	008b8493          	addi	s1,s7,8
 780:	000bc583          	lbu	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	d6dff0ef          	jal	4f2 <putc>
 78a:	8ba6                	mv	s7,s1
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b595                	j	5f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 790:	008b8993          	addi	s3,s7,8
 794:	000bb483          	ld	s1,0(s7)
 798:	cc91                	beqz	s1,7b4 <vprintf+0x206>
        for(; *s; s++)
 79a:	0004c583          	lbu	a1,0(s1)
 79e:	c985                	beqz	a1,7ce <vprintf+0x220>
          putc(fd, *s);
 7a0:	855a                	mv	a0,s6
 7a2:	d51ff0ef          	jal	4f2 <putc>
        for(; *s; s++)
 7a6:	0485                	addi	s1,s1,1
 7a8:	0004c583          	lbu	a1,0(s1)
 7ac:	f9f5                	bnez	a1,7a0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7ae:	8bce                	mv	s7,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b581                	j	5f2 <vprintf+0x44>
          s = "(null)";
 7b4:	00000497          	auipc	s1,0x0
 7b8:	2e448493          	addi	s1,s1,740 # a98 <malloc+0x148>
        for(; *s; s++)
 7bc:	02800593          	li	a1,40
 7c0:	b7c5                	j	7a0 <vprintf+0x1f2>
        putc(fd, '%');
 7c2:	85be                	mv	a1,a5
 7c4:	855a                	mv	a0,s6
 7c6:	d2dff0ef          	jal	4f2 <putc>
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b51d                	j	5f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7ce:	8bce                	mv	s7,s3
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b505                	j	5f2 <vprintf+0x44>
 7d4:	6906                	ld	s2,64(sp)
 7d6:	79e2                	ld	s3,56(sp)
 7d8:	7a42                	ld	s4,48(sp)
 7da:	7aa2                	ld	s5,40(sp)
 7dc:	7b02                	ld	s6,32(sp)
 7de:	6be2                	ld	s7,24(sp)
 7e0:	6c42                	ld	s8,16(sp)
    }
  }
}
 7e2:	60e6                	ld	ra,88(sp)
 7e4:	6446                	ld	s0,80(sp)
 7e6:	64a6                	ld	s1,72(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret
      if(c0 == 'd'){
 7ec:	06400713          	li	a4,100
 7f0:	e4e78fe3          	beq	a5,a4,64e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7f4:	f9478693          	addi	a3,a5,-108
 7f8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7fc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7fe:	4701                	li	a4,0
      } else if(c0 == 'u'){
 800:	07500513          	li	a0,117
 804:	e8a78ce3          	beq	a5,a0,69c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 808:	f8b60513          	addi	a0,a2,-117
 80c:	e119                	bnez	a0,812 <vprintf+0x264>
 80e:	ea0693e3          	bnez	a3,6b4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 812:	f8b58513          	addi	a0,a1,-117
 816:	e119                	bnez	a0,81c <vprintf+0x26e>
 818:	ea071be3          	bnez	a4,6ce <vprintf+0x120>
      } else if(c0 == 'x'){
 81c:	07800513          	li	a0,120
 820:	eca784e3          	beq	a5,a0,6e8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 824:	f8860613          	addi	a2,a2,-120
 828:	e219                	bnez	a2,82e <vprintf+0x280>
 82a:	ec069be3          	bnez	a3,700 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 82e:	f8858593          	addi	a1,a1,-120
 832:	e199                	bnez	a1,838 <vprintf+0x28a>
 834:	ee0713e3          	bnez	a4,71a <vprintf+0x16c>
      } else if(c0 == 'p'){
 838:	07000713          	li	a4,112
 83c:	eee78ce3          	beq	a5,a4,734 <vprintf+0x186>
      } else if(c0 == 'c'){
 840:	06300713          	li	a4,99
 844:	f2e78ce3          	beq	a5,a4,77c <vprintf+0x1ce>
      } else if(c0 == 's'){
 848:	07300713          	li	a4,115
 84c:	f4e782e3          	beq	a5,a4,790 <vprintf+0x1e2>
      } else if(c0 == '%'){
 850:	02500713          	li	a4,37
 854:	f6e787e3          	beq	a5,a4,7c2 <vprintf+0x214>
        putc(fd, '%');
 858:	02500593          	li	a1,37
 85c:	855a                	mv	a0,s6
 85e:	c95ff0ef          	jal	4f2 <putc>
        putc(fd, c0);
 862:	85a6                	mv	a1,s1
 864:	855a                	mv	a0,s6
 866:	c8dff0ef          	jal	4f2 <putc>
      state = 0;
 86a:	4981                	li	s3,0
 86c:	b359                	j	5f2 <vprintf+0x44>

000000000000086e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 86e:	715d                	addi	sp,sp,-80
 870:	ec06                	sd	ra,24(sp)
 872:	e822                	sd	s0,16(sp)
 874:	1000                	addi	s0,sp,32
 876:	e010                	sd	a2,0(s0)
 878:	e414                	sd	a3,8(s0)
 87a:	e818                	sd	a4,16(s0)
 87c:	ec1c                	sd	a5,24(s0)
 87e:	03043023          	sd	a6,32(s0)
 882:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 886:	8622                	mv	a2,s0
 888:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 88c:	d23ff0ef          	jal	5ae <vprintf>
}
 890:	60e2                	ld	ra,24(sp)
 892:	6442                	ld	s0,16(sp)
 894:	6161                	addi	sp,sp,80
 896:	8082                	ret

0000000000000898 <printf>:

void
printf(const char *fmt, ...)
{
 898:	711d                	addi	sp,sp,-96
 89a:	ec06                	sd	ra,24(sp)
 89c:	e822                	sd	s0,16(sp)
 89e:	1000                	addi	s0,sp,32
 8a0:	e40c                	sd	a1,8(s0)
 8a2:	e810                	sd	a2,16(s0)
 8a4:	ec14                	sd	a3,24(s0)
 8a6:	f018                	sd	a4,32(s0)
 8a8:	f41c                	sd	a5,40(s0)
 8aa:	03043823          	sd	a6,48(s0)
 8ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8b2:	00840613          	addi	a2,s0,8
 8b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ba:	85aa                	mv	a1,a0
 8bc:	4505                	li	a0,1
 8be:	cf1ff0ef          	jal	5ae <vprintf>
}
 8c2:	60e2                	ld	ra,24(sp)
 8c4:	6442                	ld	s0,16(sp)
 8c6:	6125                	addi	sp,sp,96
 8c8:	8082                	ret

00000000000008ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ca:	1141                	addi	sp,sp,-16
 8cc:	e406                	sd	ra,8(sp)
 8ce:	e022                	sd	s0,0(sp)
 8d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d6:	00000797          	auipc	a5,0x0
 8da:	72a7b783          	ld	a5,1834(a5) # 1000 <freep>
 8de:	a039                	j	8ec <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e0:	6398                	ld	a4,0(a5)
 8e2:	00e7e463          	bltu	a5,a4,8ea <free+0x20>
 8e6:	00e6ea63          	bltu	a3,a4,8fa <free+0x30>
{
 8ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	fed7fae3          	bgeu	a5,a3,8e0 <free+0x16>
 8f0:	6398                	ld	a4,0(a5)
 8f2:	00e6e463          	bltu	a3,a4,8fa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	fee7eae3          	bltu	a5,a4,8ea <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8fa:	ff852583          	lw	a1,-8(a0)
 8fe:	6390                	ld	a2,0(a5)
 900:	02059813          	slli	a6,a1,0x20
 904:	01c85713          	srli	a4,a6,0x1c
 908:	9736                	add	a4,a4,a3
 90a:	02e60563          	beq	a2,a4,934 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 90e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 912:	4790                	lw	a2,8(a5)
 914:	02061593          	slli	a1,a2,0x20
 918:	01c5d713          	srli	a4,a1,0x1c
 91c:	973e                	add	a4,a4,a5
 91e:	02e68263          	beq	a3,a4,942 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 922:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 924:	00000717          	auipc	a4,0x0
 928:	6cf73e23          	sd	a5,1756(a4) # 1000 <freep>
}
 92c:	60a2                	ld	ra,8(sp)
 92e:	6402                	ld	s0,0(sp)
 930:	0141                	addi	sp,sp,16
 932:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 934:	4618                	lw	a4,8(a2)
 936:	9f2d                	addw	a4,a4,a1
 938:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 93c:	6398                	ld	a4,0(a5)
 93e:	6310                	ld	a2,0(a4)
 940:	b7f9                	j	90e <free+0x44>
    p->s.size += bp->s.size;
 942:	ff852703          	lw	a4,-8(a0)
 946:	9f31                	addw	a4,a4,a2
 948:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 94a:	ff053683          	ld	a3,-16(a0)
 94e:	bfd1                	j	922 <free+0x58>

0000000000000950 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 950:	7139                	addi	sp,sp,-64
 952:	fc06                	sd	ra,56(sp)
 954:	f822                	sd	s0,48(sp)
 956:	f04a                	sd	s2,32(sp)
 958:	ec4e                	sd	s3,24(sp)
 95a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95c:	02051993          	slli	s3,a0,0x20
 960:	0209d993          	srli	s3,s3,0x20
 964:	09bd                	addi	s3,s3,15
 966:	0049d993          	srli	s3,s3,0x4
 96a:	2985                	addiw	s3,s3,1
 96c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 96e:	00000517          	auipc	a0,0x0
 972:	69253503          	ld	a0,1682(a0) # 1000 <freep>
 976:	c905                	beqz	a0,9a6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 978:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97a:	4798                	lw	a4,8(a5)
 97c:	09377663          	bgeu	a4,s3,a08 <malloc+0xb8>
 980:	f426                	sd	s1,40(sp)
 982:	e852                	sd	s4,16(sp)
 984:	e456                	sd	s5,8(sp)
 986:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 988:	8a4e                	mv	s4,s3
 98a:	6705                	lui	a4,0x1
 98c:	00e9f363          	bgeu	s3,a4,992 <malloc+0x42>
 990:	6a05                	lui	s4,0x1
 992:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 996:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 99a:	00000497          	auipc	s1,0x0
 99e:	66648493          	addi	s1,s1,1638 # 1000 <freep>
  if(p == SBRK_ERROR)
 9a2:	5afd                	li	s5,-1
 9a4:	a83d                	j	9e2 <malloc+0x92>
 9a6:	f426                	sd	s1,40(sp)
 9a8:	e852                	sd	s4,16(sp)
 9aa:	e456                	sd	s5,8(sp)
 9ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9ae:	00001797          	auipc	a5,0x1
 9b2:	86278793          	addi	a5,a5,-1950 # 1210 <base>
 9b6:	00000717          	auipc	a4,0x0
 9ba:	64f73523          	sd	a5,1610(a4) # 1000 <freep>
 9be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c4:	b7d1                	j	988 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9c6:	6398                	ld	a4,0(a5)
 9c8:	e118                	sd	a4,0(a0)
 9ca:	a899                	j	a20 <malloc+0xd0>
  hp->s.size = nu;
 9cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d0:	0541                	addi	a0,a0,16
 9d2:	ef9ff0ef          	jal	8ca <free>
  return freep;
 9d6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9d8:	c125                	beqz	a0,a38 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9dc:	4798                	lw	a4,8(a5)
 9de:	03277163          	bgeu	a4,s2,a00 <malloc+0xb0>
    if(p == freep)
 9e2:	6098                	ld	a4,0(s1)
 9e4:	853e                	mv	a0,a5
 9e6:	fef71ae3          	bne	a4,a5,9da <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9ea:	8552                	mv	a0,s4
 9ec:	9f3ff0ef          	jal	3de <sbrk>
  if(p == SBRK_ERROR)
 9f0:	fd551ee3          	bne	a0,s5,9cc <malloc+0x7c>
        return 0;
 9f4:	4501                	li	a0,0
 9f6:	74a2                	ld	s1,40(sp)
 9f8:	6a42                	ld	s4,16(sp)
 9fa:	6aa2                	ld	s5,8(sp)
 9fc:	6b02                	ld	s6,0(sp)
 9fe:	a03d                	j	a2c <malloc+0xdc>
 a00:	74a2                	ld	s1,40(sp)
 a02:	6a42                	ld	s4,16(sp)
 a04:	6aa2                	ld	s5,8(sp)
 a06:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a08:	fae90fe3          	beq	s2,a4,9c6 <malloc+0x76>
        p->s.size -= nunits;
 a0c:	4137073b          	subw	a4,a4,s3
 a10:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a12:	02071693          	slli	a3,a4,0x20
 a16:	01c6d713          	srli	a4,a3,0x1c
 a1a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a1c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a20:	00000717          	auipc	a4,0x0
 a24:	5ea73023          	sd	a0,1504(a4) # 1000 <freep>
      return (void*)(p + 1);
 a28:	01078513          	addi	a0,a5,16
  }
}
 a2c:	70e2                	ld	ra,56(sp)
 a2e:	7442                	ld	s0,48(sp)
 a30:	7902                	ld	s2,32(sp)
 a32:	69e2                	ld	s3,24(sp)
 a34:	6121                	addi	sp,sp,64
 a36:	8082                	ret
 a38:	74a2                	ld	s1,40(sp)
 a3a:	6a42                	ld	s4,16(sp)
 a3c:	6aa2                	ld	s5,8(sp)
 a3e:	6b02                	ld	s6,0(sp)
 a40:	b7f5                	j	a2c <malloc+0xdc>
