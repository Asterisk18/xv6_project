
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	fd250a13          	addi	s4,a0,-46
  1a:	001a3a13          	seqz	s4,s4
    if(matchhere(re, text))
  1e:	85a6                	mv	a1,s1
  20:	854e                	mv	a0,s3
  22:	02a000ef          	jal	4c <matchhere>
  26:	e911                	bnez	a0,3a <matchstar+0x3a>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb81                	beqz	a5,3c <matchstar+0x3c>
  2e:	0485                	addi	s1,s1,1
  30:	ff2787e3          	beq	a5,s2,1e <matchstar+0x1e>
  34:	fe0a15e3          	bnez	s4,1e <matchstar+0x1e>
  38:	a011                	j	3c <matchstar+0x3c>
      return 1;
  3a:	4505                	li	a0,1
  return 0;
}
  3c:	70a2                	ld	ra,40(sp)
  3e:	7402                	ld	s0,32(sp)
  40:	64e2                	ld	s1,24(sp)
  42:	6942                	ld	s2,16(sp)
  44:	69a2                	ld	s3,8(sp)
  46:	6a02                	ld	s4,0(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret

000000000000004c <matchhere>:
  if(re[0] == '\0')
  4c:	00054703          	lbu	a4,0(a0)
  50:	cf39                	beqz	a4,ae <matchhere+0x62>
{
  52:	1141                	addi	sp,sp,-16
  54:	e406                	sd	ra,8(sp)
  56:	e022                	sd	s0,0(sp)
  58:	0800                	addi	s0,sp,16
  5a:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5c:	00154683          	lbu	a3,1(a0)
  60:	02a00613          	li	a2,42
  64:	02c68363          	beq	a3,a2,8a <matchhere+0x3e>
  if(re[0] == '$' && re[1] == '\0')
  68:	e681                	bnez	a3,70 <matchhere+0x24>
  6a:	fdc70693          	addi	a3,a4,-36
  6e:	c68d                	beqz	a3,98 <matchhere+0x4c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  70:	0005c683          	lbu	a3,0(a1)
  return 0;
  74:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  76:	c691                	beqz	a3,82 <matchhere+0x36>
  78:	02d70563          	beq	a4,a3,a2 <matchhere+0x56>
  7c:	fd270713          	addi	a4,a4,-46
  80:	c30d                	beqz	a4,a2 <matchhere+0x56>
}
  82:	60a2                	ld	ra,8(sp)
  84:	6402                	ld	s0,0(sp)
  86:	0141                	addi	sp,sp,16
  88:	8082                	ret
    return matchstar(re[0], re+2, text);
  8a:	862e                	mv	a2,a1
  8c:	00250593          	addi	a1,a0,2
  90:	853a                	mv	a0,a4
  92:	f6fff0ef          	jal	0 <matchstar>
  96:	b7f5                	j	82 <matchhere+0x36>
    return *text == '\0';
  98:	0005c503          	lbu	a0,0(a1)
  9c:	00153513          	seqz	a0,a0
  a0:	b7cd                	j	82 <matchhere+0x36>
    return matchhere(re+1, text+1);
  a2:	0585                	addi	a1,a1,1
  a4:	00178513          	addi	a0,a5,1
  a8:	fa5ff0ef          	jal	4c <matchhere>
  ac:	bfd9                	j	82 <matchhere+0x36>
    return 1;
  ae:	4505                	li	a0,1
}
  b0:	8082                	ret

00000000000000b2 <match>:
{
  b2:	1101                	addi	sp,sp,-32
  b4:	ec06                	sd	ra,24(sp)
  b6:	e822                	sd	s0,16(sp)
  b8:	e426                	sd	s1,8(sp)
  ba:	e04a                	sd	s2,0(sp)
  bc:	1000                	addi	s0,sp,32
  be:	892a                	mv	s2,a0
  c0:	84ae                	mv	s1,a1
  if(re[0] == '^')
  c2:	00054703          	lbu	a4,0(a0)
  c6:	05e00793          	li	a5,94
  ca:	00f70c63          	beq	a4,a5,e2 <match+0x30>
    if(matchhere(re, text))
  ce:	85a6                	mv	a1,s1
  d0:	854a                	mv	a0,s2
  d2:	f7bff0ef          	jal	4c <matchhere>
  d6:	e911                	bnez	a0,ea <match+0x38>
  }while(*text++ != '\0');
  d8:	0485                	addi	s1,s1,1
  da:	fff4c783          	lbu	a5,-1(s1)
  de:	fbe5                	bnez	a5,ce <match+0x1c>
  e0:	a031                	j	ec <match+0x3a>
    return matchhere(re+1, text);
  e2:	0505                	addi	a0,a0,1
  e4:	f69ff0ef          	jal	4c <matchhere>
  e8:	a011                	j	ec <match+0x3a>
      return 1;
  ea:	4505                	li	a0,1
}
  ec:	60e2                	ld	ra,24(sp)
  ee:	6442                	ld	s0,16(sp)
  f0:	64a2                	ld	s1,8(sp)
  f2:	6902                	ld	s2,0(sp)
  f4:	6105                	addi	sp,sp,32
  f6:	8082                	ret

00000000000000f8 <grep>:
{
  f8:	711d                	addi	sp,sp,-96
  fa:	ec86                	sd	ra,88(sp)
  fc:	e8a2                	sd	s0,80(sp)
  fe:	e4a6                	sd	s1,72(sp)
 100:	e0ca                	sd	s2,64(sp)
 102:	fc4e                	sd	s3,56(sp)
 104:	f852                	sd	s4,48(sp)
 106:	f456                	sd	s5,40(sp)
 108:	f05a                	sd	s6,32(sp)
 10a:	ec5e                	sd	s7,24(sp)
 10c:	e862                	sd	s8,16(sp)
 10e:	e466                	sd	s9,8(sp)
 110:	e06a                	sd	s10,0(sp)
 112:	1080                	addi	s0,sp,96
 114:	8aaa                	mv	s5,a0
 116:	8cae                	mv	s9,a1
  m = 0;
 118:	4b01                	li	s6,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 11a:	3ff00d13          	li	s10,1023
 11e:	00001b97          	auipc	s7,0x1
 122:	ef2b8b93          	addi	s7,s7,-270 # 1010 <buf>
    while((q = strchr(p, '\n')) != 0){
 126:	49a9                	li	s3,10
        write(1, p, q+1 - p);
 128:	4c05                	li	s8,1
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 12a:	a82d                	j	164 <grep+0x6c>
      p = q+1;
 12c:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 130:	85ce                	mv	a1,s3
 132:	854a                	mv	a0,s2
 134:	1da000ef          	jal	30e <strchr>
 138:	84aa                	mv	s1,a0
 13a:	c11d                	beqz	a0,160 <grep+0x68>
      *q = 0;
 13c:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 140:	85ca                	mv	a1,s2
 142:	8556                	mv	a0,s5
 144:	f6fff0ef          	jal	b2 <match>
 148:	d175                	beqz	a0,12c <grep+0x34>
        *q = '\n';
 14a:	01348023          	sb	s3,0(s1)
        write(1, p, q+1 - p);
 14e:	00148613          	addi	a2,s1,1
 152:	4126063b          	subw	a2,a2,s2
 156:	85ca                	mv	a1,s2
 158:	8562                	mv	a0,s8
 15a:	3d8000ef          	jal	532 <write>
 15e:	b7f9                	j	12c <grep+0x34>
    if(m > 0){
 160:	03604463          	bgtz	s6,188 <grep+0x90>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 164:	416d063b          	subw	a2,s10,s6
 168:	016b85b3          	add	a1,s7,s6
 16c:	8566                	mv	a0,s9
 16e:	3bc000ef          	jal	52a <read>
 172:	02a05c63          	blez	a0,1aa <grep+0xb2>
    m += n;
 176:	00ab0a3b          	addw	s4,s6,a0
 17a:	8b52                	mv	s6,s4
    buf[m] = '\0';
 17c:	014b87b3          	add	a5,s7,s4
 180:	00078023          	sb	zero,0(a5)
    p = buf;
 184:	895e                	mv	s2,s7
    while((q = strchr(p, '\n')) != 0){
 186:	b76d                	j	130 <grep+0x38>
      m -= p - buf;
 188:	00001797          	auipc	a5,0x1
 18c:	e8878793          	addi	a5,a5,-376 # 1010 <buf>
 190:	40f907b3          	sub	a5,s2,a5
 194:	40fa063b          	subw	a2,s4,a5
 198:	8b32                	mv	s6,a2
      memmove(buf, p, m);
 19a:	85ca                	mv	a1,s2
 19c:	00001517          	auipc	a0,0x1
 1a0:	e7450513          	addi	a0,a0,-396 # 1010 <buf>
 1a4:	290000ef          	jal	434 <memmove>
 1a8:	bf75                	j	164 <grep+0x6c>
}
 1aa:	60e6                	ld	ra,88(sp)
 1ac:	6446                	ld	s0,80(sp)
 1ae:	64a6                	ld	s1,72(sp)
 1b0:	6906                	ld	s2,64(sp)
 1b2:	79e2                	ld	s3,56(sp)
 1b4:	7a42                	ld	s4,48(sp)
 1b6:	7aa2                	ld	s5,40(sp)
 1b8:	7b02                	ld	s6,32(sp)
 1ba:	6be2                	ld	s7,24(sp)
 1bc:	6c42                	ld	s8,16(sp)
 1be:	6ca2                	ld	s9,8(sp)
 1c0:	6d02                	ld	s10,0(sp)
 1c2:	6125                	addi	sp,sp,96
 1c4:	8082                	ret

00000000000001c6 <main>:
{
 1c6:	7179                	addi	sp,sp,-48
 1c8:	f406                	sd	ra,40(sp)
 1ca:	f022                	sd	s0,32(sp)
 1cc:	ec26                	sd	s1,24(sp)
 1ce:	e84a                	sd	s2,16(sp)
 1d0:	e44e                	sd	s3,8(sp)
 1d2:	e052                	sd	s4,0(sp)
 1d4:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1d6:	4785                	li	a5,1
 1d8:	04a7d663          	bge	a5,a0,224 <main+0x5e>
  pattern = argv[1];
 1dc:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1e0:	4789                	li	a5,2
 1e2:	04a7db63          	bge	a5,a0,238 <main+0x72>
 1e6:	01058913          	addi	s2,a1,16
 1ea:	ffd5099b          	addiw	s3,a0,-3
 1ee:	02099793          	slli	a5,s3,0x20
 1f2:	01d7d993          	srli	s3,a5,0x1d
 1f6:	05e1                	addi	a1,a1,24
 1f8:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1fa:	4581                	li	a1,0
 1fc:	00093503          	ld	a0,0(s2)
 200:	352000ef          	jal	552 <open>
 204:	84aa                	mv	s1,a0
 206:	04054063          	bltz	a0,246 <main+0x80>
    grep(pattern, fd);
 20a:	85aa                	mv	a1,a0
 20c:	8552                	mv	a0,s4
 20e:	eebff0ef          	jal	f8 <grep>
    close(fd);
 212:	8526                	mv	a0,s1
 214:	326000ef          	jal	53a <close>
  for(i = 2; i < argc; i++){
 218:	0921                	addi	s2,s2,8
 21a:	ff3910e3          	bne	s2,s3,1fa <main+0x34>
  exit(0);
 21e:	4501                	li	a0,0
 220:	2f2000ef          	jal	512 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 224:	00001597          	auipc	a1,0x1
 228:	92c58593          	addi	a1,a1,-1748 # b50 <malloc+0x100>
 22c:	4509                	li	a0,2
 22e:	740000ef          	jal	96e <fprintf>
    exit(1);
 232:	4505                	li	a0,1
 234:	2de000ef          	jal	512 <exit>
    grep(pattern, 0);
 238:	4581                	li	a1,0
 23a:	8552                	mv	a0,s4
 23c:	ebdff0ef          	jal	f8 <grep>
    exit(0);
 240:	4501                	li	a0,0
 242:	2d0000ef          	jal	512 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 246:	00093583          	ld	a1,0(s2)
 24a:	00001517          	auipc	a0,0x1
 24e:	92650513          	addi	a0,a0,-1754 # b70 <malloc+0x120>
 252:	746000ef          	jal	998 <printf>
      exit(1);
 256:	4505                	li	a0,1
 258:	2ba000ef          	jal	512 <exit>

000000000000025c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 264:	f63ff0ef          	jal	1c6 <main>
  exit(r);
 268:	2aa000ef          	jal	512 <exit>

000000000000026c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 274:	87aa                	mv	a5,a0
 276:	0585                	addi	a1,a1,1
 278:	0785                	addi	a5,a5,1
 27a:	fff5c703          	lbu	a4,-1(a1)
 27e:	fee78fa3          	sb	a4,-1(a5)
 282:	fb75                	bnez	a4,276 <strcpy+0xa>
    ;
  return os;
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb91                	beqz	a5,2ac <strcmp+0x20>
 29a:	0005c703          	lbu	a4,0(a1)
 29e:	00f71763          	bne	a4,a5,2ac <strcmp+0x20>
    p++, q++;
 2a2:	0505                	addi	a0,a0,1
 2a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	fbe5                	bnez	a5,29a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 2ac:	0005c503          	lbu	a0,0(a1)
}
 2b0:	40a7853b          	subw	a0,a5,a0
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <strlen>:

uint
strlen(const char *s)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e406                	sd	ra,8(sp)
 2c0:	e022                	sd	s0,0(sp)
 2c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c4:	00054783          	lbu	a5,0(a0)
 2c8:	cf91                	beqz	a5,2e4 <strlen+0x28>
 2ca:	00150793          	addi	a5,a0,1
 2ce:	86be                	mv	a3,a5
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff7c703          	lbu	a4,-1(a5)
 2d6:	ff65                	bnez	a4,2ce <strlen+0x12>
 2d8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  for(n = 0; s[n]; n++)
 2e4:	4501                	li	a0,0
 2e6:	bfdd                	j	2dc <strlen+0x20>

00000000000002e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1e>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x14>
  }
  return dst;
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cf81                	beqz	a5,332 <strchr+0x24>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1c>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xe>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfdd                	j	32a <strchr+0x1c>

0000000000000336 <gets>:

char*
gets(char *buf, int max)
{
 336:	711d                	addi	sp,sp,-96
 338:	ec86                	sd	ra,88(sp)
 33a:	e8a2                	sd	s0,80(sp)
 33c:	e4a6                	sd	s1,72(sp)
 33e:	e0ca                	sd	s2,64(sp)
 340:	fc4e                	sd	s3,56(sp)
 342:	f852                	sd	s4,48(sp)
 344:	f456                	sd	s5,40(sp)
 346:	f05a                	sd	s6,32(sp)
 348:	ec5e                	sd	s7,24(sp)
 34a:	e862                	sd	s8,16(sp)
 34c:	1080                	addi	s0,sp,96
 34e:	8baa                	mv	s7,a0
 350:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 352:	892a                	mv	s2,a0
 354:	4481                	li	s1,0
    cc = read(0, &c, 1);
 356:	faf40b13          	addi	s6,s0,-81
 35a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 35c:	8c26                	mv	s8,s1
 35e:	0014899b          	addiw	s3,s1,1
 362:	84ce                	mv	s1,s3
 364:	0349d463          	bge	s3,s4,38c <gets+0x56>
    cc = read(0, &c, 1);
 368:	8656                	mv	a2,s5
 36a:	85da                	mv	a1,s6
 36c:	4501                	li	a0,0
 36e:	1bc000ef          	jal	52a <read>
    if(cc < 1)
 372:	00a05d63          	blez	a0,38c <gets+0x56>
      break;
    buf[i++] = c;
 376:	faf44783          	lbu	a5,-81(s0)
 37a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 37e:	0905                	addi	s2,s2,1
 380:	ff678713          	addi	a4,a5,-10
 384:	c319                	beqz	a4,38a <gets+0x54>
 386:	17cd                	addi	a5,a5,-13
 388:	fbf1                	bnez	a5,35c <gets+0x26>
    buf[i++] = c;
 38a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 38c:	9c5e                	add	s8,s8,s7
 38e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 392:	855e                	mv	a0,s7
 394:	60e6                	ld	ra,88(sp)
 396:	6446                	ld	s0,80(sp)
 398:	64a6                	ld	s1,72(sp)
 39a:	6906                	ld	s2,64(sp)
 39c:	79e2                	ld	s3,56(sp)
 39e:	7a42                	ld	s4,48(sp)
 3a0:	7aa2                	ld	s5,40(sp)
 3a2:	7b02                	ld	s6,32(sp)
 3a4:	6be2                	ld	s7,24(sp)
 3a6:	6c42                	ld	s8,16(sp)
 3a8:	6125                	addi	sp,sp,96
 3aa:	8082                	ret

00000000000003ac <stat>:

int
stat(const char *n, struct stat *st)
{
 3ac:	1101                	addi	sp,sp,-32
 3ae:	ec06                	sd	ra,24(sp)
 3b0:	e822                	sd	s0,16(sp)
 3b2:	e04a                	sd	s2,0(sp)
 3b4:	1000                	addi	s0,sp,32
 3b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b8:	4581                	li	a1,0
 3ba:	198000ef          	jal	552 <open>
  if(fd < 0)
 3be:	02054263          	bltz	a0,3e2 <stat+0x36>
 3c2:	e426                	sd	s1,8(sp)
 3c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c6:	85ca                	mv	a1,s2
 3c8:	1a2000ef          	jal	56a <fstat>
 3cc:	892a                	mv	s2,a0
  close(fd);
 3ce:	8526                	mv	a0,s1
 3d0:	16a000ef          	jal	53a <close>
  return r;
 3d4:	64a2                	ld	s1,8(sp)
}
 3d6:	854a                	mv	a0,s2
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6902                	ld	s2,0(sp)
 3de:	6105                	addi	sp,sp,32
 3e0:	8082                	ret
    return -1;
 3e2:	57fd                	li	a5,-1
 3e4:	893e                	mv	s2,a5
 3e6:	bfc5                	j	3d6 <stat+0x2a>

00000000000003e8 <atoi>:

int
atoi(const char *s)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f0:	00054683          	lbu	a3,0(a0)
 3f4:	fd06879b          	addiw	a5,a3,-48
 3f8:	0ff7f793          	zext.b	a5,a5
 3fc:	4625                	li	a2,9
 3fe:	02f66963          	bltu	a2,a5,430 <atoi+0x48>
 402:	872a                	mv	a4,a0
  n = 0;
 404:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 406:	0705                	addi	a4,a4,1
 408:	0025179b          	slliw	a5,a0,0x2
 40c:	9fa9                	addw	a5,a5,a0
 40e:	0017979b          	slliw	a5,a5,0x1
 412:	9fb5                	addw	a5,a5,a3
 414:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 418:	00074683          	lbu	a3,0(a4)
 41c:	fd06879b          	addiw	a5,a3,-48
 420:	0ff7f793          	zext.b	a5,a5
 424:	fef671e3          	bgeu	a2,a5,406 <atoi+0x1e>
  return n;
}
 428:	60a2                	ld	ra,8(sp)
 42a:	6402                	ld	s0,0(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
  n = 0;
 430:	4501                	li	a0,0
 432:	bfdd                	j	428 <atoi+0x40>

0000000000000434 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e406                	sd	ra,8(sp)
 438:	e022                	sd	s0,0(sp)
 43a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43c:	02b57563          	bgeu	a0,a1,466 <memmove+0x32>
    while(n-- > 0)
 440:	00c05f63          	blez	a2,45e <memmove+0x2a>
 444:	1602                	slli	a2,a2,0x20
 446:	9201                	srli	a2,a2,0x20
 448:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 44c:	872a                	mv	a4,a0
      *dst++ = *src++;
 44e:	0585                	addi	a1,a1,1
 450:	0705                	addi	a4,a4,1
 452:	fff5c683          	lbu	a3,-1(a1)
 456:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 45a:	fee79ae3          	bne	a5,a4,44e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45e:	60a2                	ld	ra,8(sp)
 460:	6402                	ld	s0,0(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
    while(n-- > 0)
 466:	fec05ce3          	blez	a2,45e <memmove+0x2a>
    dst += n;
 46a:	00c50733          	add	a4,a0,a2
    src += n;
 46e:	95b2                	add	a1,a1,a2
 470:	fff6079b          	addiw	a5,a2,-1
 474:	1782                	slli	a5,a5,0x20
 476:	9381                	srli	a5,a5,0x20
 478:	fff7c793          	not	a5,a5
 47c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47e:	15fd                	addi	a1,a1,-1
 480:	177d                	addi	a4,a4,-1
 482:	0005c683          	lbu	a3,0(a1)
 486:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48a:	fef71ae3          	bne	a4,a5,47e <memmove+0x4a>
 48e:	bfc1                	j	45e <memmove+0x2a>

0000000000000490 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 498:	c61d                	beqz	a2,4c6 <memcmp+0x36>
 49a:	1602                	slli	a2,a2,0x20
 49c:	9201                	srli	a2,a2,0x20
 49e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 4a2:	00054783          	lbu	a5,0(a0)
 4a6:	0005c703          	lbu	a4,0(a1)
 4aa:	00e79863          	bne	a5,a4,4ba <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 4ae:	0505                	addi	a0,a0,1
    p2++;
 4b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b2:	fed518e3          	bne	a0,a3,4a2 <memcmp+0x12>
  }
  return 0;
 4b6:	4501                	li	a0,0
 4b8:	a019                	j	4be <memcmp+0x2e>
      return *p1 - *p2;
 4ba:	40e7853b          	subw	a0,a5,a4
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	bfdd                	j	4be <memcmp+0x2e>

00000000000004ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d2:	f63ff0ef          	jal	434 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <sbrk>:

char *
sbrk(int n) {
 4de:	1141                	addi	sp,sp,-16
 4e0:	e406                	sd	ra,8(sp)
 4e2:	e022                	sd	s0,0(sp)
 4e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4e6:	4585                	li	a1,1
 4e8:	0b2000ef          	jal	59a <sys_sbrk>
}
 4ec:	60a2                	ld	ra,8(sp)
 4ee:	6402                	ld	s0,0(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <sbrklazy>:

char *
sbrklazy(int n) {
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e406                	sd	ra,8(sp)
 4f8:	e022                	sd	s0,0(sp)
 4fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4fc:	4589                	li	a1,2
 4fe:	09c000ef          	jal	59a <sys_sbrk>
}
 502:	60a2                	ld	ra,8(sp)
 504:	6402                	ld	s0,0(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 50a:	4885                	li	a7,1
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <exit>:
.global exit
exit:
 li a7, SYS_exit
 512:	4889                	li	a7,2
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <wait>:
.global wait
wait:
 li a7, SYS_wait
 51a:	488d                	li	a7,3
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 522:	4891                	li	a7,4
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <read>:
.global read
read:
 li a7, SYS_read
 52a:	4895                	li	a7,5
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <write>:
.global write
write:
 li a7, SYS_write
 532:	48c1                	li	a7,16
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <close>:
.global close
close:
 li a7, SYS_close
 53a:	48d5                	li	a7,21
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <kill>:
.global kill
kill:
 li a7, SYS_kill
 542:	4899                	li	a7,6
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <exec>:
.global exec
exec:
 li a7, SYS_exec
 54a:	489d                	li	a7,7
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <open>:
.global open
open:
 li a7, SYS_open
 552:	48bd                	li	a7,15
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 55a:	48c5                	li	a7,17
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 562:	48c9                	li	a7,18
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 56a:	48a1                	li	a7,8
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <link>:
.global link
link:
 li a7, SYS_link
 572:	48cd                	li	a7,19
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 57a:	48d1                	li	a7,20
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 582:	48a5                	li	a7,9
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <dup>:
.global dup
dup:
 li a7, SYS_dup
 58a:	48a9                	li	a7,10
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 592:	48ad                	li	a7,11
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 59a:	48b1                	li	a7,12
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5a2:	48b5                	li	a7,13
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5aa:	48b9                	li	a7,14
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <hello>:
.global hello
hello:
 li a7, SYS_hello
 5b2:	48d9                	li	a7,22
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <getpid2>:
.global getpid2
getpid2:
 li a7, SYS_getpid2
 5ba:	48dd                	li	a7,23
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5c2:	48e1                	li	a7,24
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <getnumchild>:
.global getnumchild
getnumchild:
 li a7, SYS_getnumchild
 5ca:	48e5                	li	a7,25
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 5d2:	48e9                	li	a7,26
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <getchildsyscount>:
.global getchildsyscount
getchildsyscount:
 li a7, SYS_getchildsyscount
 5da:	48ed                	li	a7,27
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <getlevel>:
.global getlevel
getlevel:
 li a7, SYS_getlevel
 5e2:	48f1                	li	a7,28
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <getmlfqinfo>:
.global getmlfqinfo
getmlfqinfo:
 li a7, SYS_getmlfqinfo
 5ea:	48f5                	li	a7,29
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f2:	1101                	addi	sp,sp,-32
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fe:	4605                	li	a2,1
 600:	fef40593          	addi	a1,s0,-17
 604:	f2fff0ef          	jal	532 <write>
}
 608:	60e2                	ld	ra,24(sp)
 60a:	6442                	ld	s0,16(sp)
 60c:	6105                	addi	sp,sp,32
 60e:	8082                	ret

0000000000000610 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 610:	715d                	addi	sp,sp,-80
 612:	e486                	sd	ra,72(sp)
 614:	e0a2                	sd	s0,64(sp)
 616:	f84a                	sd	s2,48(sp)
 618:	f44e                	sd	s3,40(sp)
 61a:	0880                	addi	s0,sp,80
 61c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 61e:	c6d1                	beqz	a3,6aa <printint+0x9a>
 620:	0805d563          	bgez	a1,6aa <printint+0x9a>
    neg = 1;
    x = -xx;
 624:	40b005b3          	neg	a1,a1
    neg = 1;
 628:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 62a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 62e:	86ce                	mv	a3,s3
  i = 0;
 630:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 632:	00000817          	auipc	a6,0x0
 636:	55e80813          	addi	a6,a6,1374 # b90 <digits>
 63a:	88ba                	mv	a7,a4
 63c:	0017051b          	addiw	a0,a4,1
 640:	872a                	mv	a4,a0
 642:	02c5f7b3          	remu	a5,a1,a2
 646:	97c2                	add	a5,a5,a6
 648:	0007c783          	lbu	a5,0(a5)
 64c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 650:	87ae                	mv	a5,a1
 652:	02c5d5b3          	divu	a1,a1,a2
 656:	0685                	addi	a3,a3,1
 658:	fec7f1e3          	bgeu	a5,a2,63a <printint+0x2a>
  if(neg)
 65c:	00030c63          	beqz	t1,674 <printint+0x64>
    buf[i++] = '-';
 660:	fd050793          	addi	a5,a0,-48
 664:	00878533          	add	a0,a5,s0
 668:	02d00793          	li	a5,45
 66c:	fef50423          	sb	a5,-24(a0)
 670:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 674:	02e05563          	blez	a4,69e <printint+0x8e>
 678:	fc26                	sd	s1,56(sp)
 67a:	377d                	addiw	a4,a4,-1
 67c:	00e984b3          	add	s1,s3,a4
 680:	19fd                	addi	s3,s3,-1
 682:	99ba                	add	s3,s3,a4
 684:	1702                	slli	a4,a4,0x20
 686:	9301                	srli	a4,a4,0x20
 688:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 68c:	0004c583          	lbu	a1,0(s1)
 690:	854a                	mv	a0,s2
 692:	f61ff0ef          	jal	5f2 <putc>
  while(--i >= 0)
 696:	14fd                	addi	s1,s1,-1
 698:	ff349ae3          	bne	s1,s3,68c <printint+0x7c>
 69c:	74e2                	ld	s1,56(sp)
}
 69e:	60a6                	ld	ra,72(sp)
 6a0:	6406                	ld	s0,64(sp)
 6a2:	7942                	ld	s2,48(sp)
 6a4:	79a2                	ld	s3,40(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret
  neg = 0;
 6aa:	4301                	li	t1,0
 6ac:	bfbd                	j	62a <printint+0x1a>

00000000000006ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ae:	711d                	addi	sp,sp,-96
 6b0:	ec86                	sd	ra,88(sp)
 6b2:	e8a2                	sd	s0,80(sp)
 6b4:	e4a6                	sd	s1,72(sp)
 6b6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6b8:	0005c483          	lbu	s1,0(a1)
 6bc:	22048363          	beqz	s1,8e2 <vprintf+0x234>
 6c0:	e0ca                	sd	s2,64(sp)
 6c2:	fc4e                	sd	s3,56(sp)
 6c4:	f852                	sd	s4,48(sp)
 6c6:	f456                	sd	s5,40(sp)
 6c8:	f05a                	sd	s6,32(sp)
 6ca:	ec5e                	sd	s7,24(sp)
 6cc:	e862                	sd	s8,16(sp)
 6ce:	8b2a                	mv	s6,a0
 6d0:	8a2e                	mv	s4,a1
 6d2:	8bb2                	mv	s7,a2
  state = 0;
 6d4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6d6:	4901                	li	s2,0
 6d8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6da:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6de:	06400c13          	li	s8,100
 6e2:	a00d                	j	704 <vprintf+0x56>
        putc(fd, c0);
 6e4:	85a6                	mv	a1,s1
 6e6:	855a                	mv	a0,s6
 6e8:	f0bff0ef          	jal	5f2 <putc>
 6ec:	a019                	j	6f2 <vprintf+0x44>
    } else if(state == '%'){
 6ee:	03598363          	beq	s3,s5,714 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 6f2:	0019079b          	addiw	a5,s2,1
 6f6:	893e                	mv	s2,a5
 6f8:	873e                	mv	a4,a5
 6fa:	97d2                	add	a5,a5,s4
 6fc:	0007c483          	lbu	s1,0(a5)
 700:	1c048a63          	beqz	s1,8d4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 704:	0004879b          	sext.w	a5,s1
    if(state == 0){
 708:	fe0993e3          	bnez	s3,6ee <vprintf+0x40>
      if(c0 == '%'){
 70c:	fd579ce3          	bne	a5,s5,6e4 <vprintf+0x36>
        state = '%';
 710:	89be                	mv	s3,a5
 712:	b7c5                	j	6f2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 714:	00ea06b3          	add	a3,s4,a4
 718:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 71c:	1c060863          	beqz	a2,8ec <vprintf+0x23e>
      if(c0 == 'd'){
 720:	03878763          	beq	a5,s8,74e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 724:	f9478693          	addi	a3,a5,-108
 728:	0016b693          	seqz	a3,a3
 72c:	f9c60593          	addi	a1,a2,-100
 730:	e99d                	bnez	a1,766 <vprintf+0xb8>
 732:	ca95                	beqz	a3,766 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 734:	008b8493          	addi	s1,s7,8
 738:	4685                	li	a3,1
 73a:	4629                	li	a2,10
 73c:	000bb583          	ld	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	ecfff0ef          	jal	610 <printint>
        i += 1;
 746:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 74a:	4981                	li	s3,0
 74c:	b75d                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 74e:	008b8493          	addi	s1,s7,8
 752:	4685                	li	a3,1
 754:	4629                	li	a2,10
 756:	000ba583          	lw	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	eb5ff0ef          	jal	610 <printint>
 760:	8ba6                	mv	s7,s1
      state = 0;
 762:	4981                	li	s3,0
 764:	b779                	j	6f2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 766:	9752                	add	a4,a4,s4
 768:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 76c:	f9460713          	addi	a4,a2,-108
 770:	00173713          	seqz	a4,a4
 774:	8f75                	and	a4,a4,a3
 776:	f9c58513          	addi	a0,a1,-100
 77a:	18051363          	bnez	a0,900 <vprintf+0x252>
 77e:	18070163          	beqz	a4,900 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 782:	008b8493          	addi	s1,s7,8
 786:	4685                	li	a3,1
 788:	4629                	li	a2,10
 78a:	000bb583          	ld	a1,0(s7)
 78e:	855a                	mv	a0,s6
 790:	e81ff0ef          	jal	610 <printint>
        i += 2;
 794:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 796:	8ba6                	mv	s7,s1
      state = 0;
 798:	4981                	li	s3,0
        i += 2;
 79a:	bfa1                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 79c:	008b8493          	addi	s1,s7,8
 7a0:	4681                	li	a3,0
 7a2:	4629                	li	a2,10
 7a4:	000be583          	lwu	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	e67ff0ef          	jal	610 <printint>
 7ae:	8ba6                	mv	s7,s1
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b781                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b4:	008b8493          	addi	s1,s7,8
 7b8:	4681                	li	a3,0
 7ba:	4629                	li	a2,10
 7bc:	000bb583          	ld	a1,0(s7)
 7c0:	855a                	mv	a0,s6
 7c2:	e4fff0ef          	jal	610 <printint>
        i += 1;
 7c6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c8:	8ba6                	mv	s7,s1
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b71d                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ce:	008b8493          	addi	s1,s7,8
 7d2:	4681                	li	a3,0
 7d4:	4629                	li	a2,10
 7d6:	000bb583          	ld	a1,0(s7)
 7da:	855a                	mv	a0,s6
 7dc:	e35ff0ef          	jal	610 <printint>
        i += 2;
 7e0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e2:	8ba6                	mv	s7,s1
      state = 0;
 7e4:	4981                	li	s3,0
        i += 2;
 7e6:	b731                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7e8:	008b8493          	addi	s1,s7,8
 7ec:	4681                	li	a3,0
 7ee:	4641                	li	a2,16
 7f0:	000be583          	lwu	a1,0(s7)
 7f4:	855a                	mv	a0,s6
 7f6:	e1bff0ef          	jal	610 <printint>
 7fa:	8ba6                	mv	s7,s1
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	bdd5                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 800:	008b8493          	addi	s1,s7,8
 804:	4681                	li	a3,0
 806:	4641                	li	a2,16
 808:	000bb583          	ld	a1,0(s7)
 80c:	855a                	mv	a0,s6
 80e:	e03ff0ef          	jal	610 <printint>
        i += 1;
 812:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 814:	8ba6                	mv	s7,s1
      state = 0;
 816:	4981                	li	s3,0
 818:	bde9                	j	6f2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81a:	008b8493          	addi	s1,s7,8
 81e:	4681                	li	a3,0
 820:	4641                	li	a2,16
 822:	000bb583          	ld	a1,0(s7)
 826:	855a                	mv	a0,s6
 828:	de9ff0ef          	jal	610 <printint>
        i += 2;
 82c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 82e:	8ba6                	mv	s7,s1
      state = 0;
 830:	4981                	li	s3,0
        i += 2;
 832:	b5c1                	j	6f2 <vprintf+0x44>
 834:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 836:	008b8793          	addi	a5,s7,8
 83a:	8cbe                	mv	s9,a5
 83c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 840:	03000593          	li	a1,48
 844:	855a                	mv	a0,s6
 846:	dadff0ef          	jal	5f2 <putc>
  putc(fd, 'x');
 84a:	07800593          	li	a1,120
 84e:	855a                	mv	a0,s6
 850:	da3ff0ef          	jal	5f2 <putc>
 854:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 856:	00000b97          	auipc	s7,0x0
 85a:	33ab8b93          	addi	s7,s7,826 # b90 <digits>
 85e:	03c9d793          	srli	a5,s3,0x3c
 862:	97de                	add	a5,a5,s7
 864:	0007c583          	lbu	a1,0(a5)
 868:	855a                	mv	a0,s6
 86a:	d89ff0ef          	jal	5f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 86e:	0992                	slli	s3,s3,0x4
 870:	34fd                	addiw	s1,s1,-1
 872:	f4f5                	bnez	s1,85e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 874:	8be6                	mv	s7,s9
      state = 0;
 876:	4981                	li	s3,0
 878:	6ca2                	ld	s9,8(sp)
 87a:	bda5                	j	6f2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 87c:	008b8493          	addi	s1,s7,8
 880:	000bc583          	lbu	a1,0(s7)
 884:	855a                	mv	a0,s6
 886:	d6dff0ef          	jal	5f2 <putc>
 88a:	8ba6                	mv	s7,s1
      state = 0;
 88c:	4981                	li	s3,0
 88e:	b595                	j	6f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 890:	008b8993          	addi	s3,s7,8
 894:	000bb483          	ld	s1,0(s7)
 898:	cc91                	beqz	s1,8b4 <vprintf+0x206>
        for(; *s; s++)
 89a:	0004c583          	lbu	a1,0(s1)
 89e:	c985                	beqz	a1,8ce <vprintf+0x220>
          putc(fd, *s);
 8a0:	855a                	mv	a0,s6
 8a2:	d51ff0ef          	jal	5f2 <putc>
        for(; *s; s++)
 8a6:	0485                	addi	s1,s1,1
 8a8:	0004c583          	lbu	a1,0(s1)
 8ac:	f9f5                	bnez	a1,8a0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 8ae:	8bce                	mv	s7,s3
      state = 0;
 8b0:	4981                	li	s3,0
 8b2:	b581                	j	6f2 <vprintf+0x44>
          s = "(null)";
 8b4:	00000497          	auipc	s1,0x0
 8b8:	2d448493          	addi	s1,s1,724 # b88 <malloc+0x138>
        for(; *s; s++)
 8bc:	02800593          	li	a1,40
 8c0:	b7c5                	j	8a0 <vprintf+0x1f2>
        putc(fd, '%');
 8c2:	85be                	mv	a1,a5
 8c4:	855a                	mv	a0,s6
 8c6:	d2dff0ef          	jal	5f2 <putc>
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	b51d                	j	6f2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 8ce:	8bce                	mv	s7,s3
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	b505                	j	6f2 <vprintf+0x44>
 8d4:	6906                	ld	s2,64(sp)
 8d6:	79e2                	ld	s3,56(sp)
 8d8:	7a42                	ld	s4,48(sp)
 8da:	7aa2                	ld	s5,40(sp)
 8dc:	7b02                	ld	s6,32(sp)
 8de:	6be2                	ld	s7,24(sp)
 8e0:	6c42                	ld	s8,16(sp)
    }
  }
}
 8e2:	60e6                	ld	ra,88(sp)
 8e4:	6446                	ld	s0,80(sp)
 8e6:	64a6                	ld	s1,72(sp)
 8e8:	6125                	addi	sp,sp,96
 8ea:	8082                	ret
      if(c0 == 'd'){
 8ec:	06400713          	li	a4,100
 8f0:	e4e78fe3          	beq	a5,a4,74e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 8f4:	f9478693          	addi	a3,a5,-108
 8f8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8fc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8fe:	4701                	li	a4,0
      } else if(c0 == 'u'){
 900:	07500513          	li	a0,117
 904:	e8a78ce3          	beq	a5,a0,79c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 908:	f8b60513          	addi	a0,a2,-117
 90c:	e119                	bnez	a0,912 <vprintf+0x264>
 90e:	ea0693e3          	bnez	a3,7b4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 912:	f8b58513          	addi	a0,a1,-117
 916:	e119                	bnez	a0,91c <vprintf+0x26e>
 918:	ea071be3          	bnez	a4,7ce <vprintf+0x120>
      } else if(c0 == 'x'){
 91c:	07800513          	li	a0,120
 920:	eca784e3          	beq	a5,a0,7e8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 924:	f8860613          	addi	a2,a2,-120
 928:	e219                	bnez	a2,92e <vprintf+0x280>
 92a:	ec069be3          	bnez	a3,800 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 92e:	f8858593          	addi	a1,a1,-120
 932:	e199                	bnez	a1,938 <vprintf+0x28a>
 934:	ee0713e3          	bnez	a4,81a <vprintf+0x16c>
      } else if(c0 == 'p'){
 938:	07000713          	li	a4,112
 93c:	eee78ce3          	beq	a5,a4,834 <vprintf+0x186>
      } else if(c0 == 'c'){
 940:	06300713          	li	a4,99
 944:	f2e78ce3          	beq	a5,a4,87c <vprintf+0x1ce>
      } else if(c0 == 's'){
 948:	07300713          	li	a4,115
 94c:	f4e782e3          	beq	a5,a4,890 <vprintf+0x1e2>
      } else if(c0 == '%'){
 950:	02500713          	li	a4,37
 954:	f6e787e3          	beq	a5,a4,8c2 <vprintf+0x214>
        putc(fd, '%');
 958:	02500593          	li	a1,37
 95c:	855a                	mv	a0,s6
 95e:	c95ff0ef          	jal	5f2 <putc>
        putc(fd, c0);
 962:	85a6                	mv	a1,s1
 964:	855a                	mv	a0,s6
 966:	c8dff0ef          	jal	5f2 <putc>
      state = 0;
 96a:	4981                	li	s3,0
 96c:	b359                	j	6f2 <vprintf+0x44>

000000000000096e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 96e:	715d                	addi	sp,sp,-80
 970:	ec06                	sd	ra,24(sp)
 972:	e822                	sd	s0,16(sp)
 974:	1000                	addi	s0,sp,32
 976:	e010                	sd	a2,0(s0)
 978:	e414                	sd	a3,8(s0)
 97a:	e818                	sd	a4,16(s0)
 97c:	ec1c                	sd	a5,24(s0)
 97e:	03043023          	sd	a6,32(s0)
 982:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 986:	8622                	mv	a2,s0
 988:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 98c:	d23ff0ef          	jal	6ae <vprintf>
}
 990:	60e2                	ld	ra,24(sp)
 992:	6442                	ld	s0,16(sp)
 994:	6161                	addi	sp,sp,80
 996:	8082                	ret

0000000000000998 <printf>:

void
printf(const char *fmt, ...)
{
 998:	711d                	addi	sp,sp,-96
 99a:	ec06                	sd	ra,24(sp)
 99c:	e822                	sd	s0,16(sp)
 99e:	1000                	addi	s0,sp,32
 9a0:	e40c                	sd	a1,8(s0)
 9a2:	e810                	sd	a2,16(s0)
 9a4:	ec14                	sd	a3,24(s0)
 9a6:	f018                	sd	a4,32(s0)
 9a8:	f41c                	sd	a5,40(s0)
 9aa:	03043823          	sd	a6,48(s0)
 9ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9b2:	00840613          	addi	a2,s0,8
 9b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ba:	85aa                	mv	a1,a0
 9bc:	4505                	li	a0,1
 9be:	cf1ff0ef          	jal	6ae <vprintf>
}
 9c2:	60e2                	ld	ra,24(sp)
 9c4:	6442                	ld	s0,16(sp)
 9c6:	6125                	addi	sp,sp,96
 9c8:	8082                	ret

00000000000009ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9ca:	1141                	addi	sp,sp,-16
 9cc:	e406                	sd	ra,8(sp)
 9ce:	e022                	sd	s0,0(sp)
 9d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d6:	00000797          	auipc	a5,0x0
 9da:	62a7b783          	ld	a5,1578(a5) # 1000 <freep>
 9de:	a039                	j	9ec <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e0:	6398                	ld	a4,0(a5)
 9e2:	00e7e463          	bltu	a5,a4,9ea <free+0x20>
 9e6:	00e6ea63          	bltu	a3,a4,9fa <free+0x30>
{
 9ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ec:	fed7fae3          	bgeu	a5,a3,9e0 <free+0x16>
 9f0:	6398                	ld	a4,0(a5)
 9f2:	00e6e463          	bltu	a3,a4,9fa <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f6:	fee7eae3          	bltu	a5,a4,9ea <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9fa:	ff852583          	lw	a1,-8(a0)
 9fe:	6390                	ld	a2,0(a5)
 a00:	02059813          	slli	a6,a1,0x20
 a04:	01c85713          	srli	a4,a6,0x1c
 a08:	9736                	add	a4,a4,a3
 a0a:	02e60563          	beq	a2,a4,a34 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 a0e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 a12:	4790                	lw	a2,8(a5)
 a14:	02061593          	slli	a1,a2,0x20
 a18:	01c5d713          	srli	a4,a1,0x1c
 a1c:	973e                	add	a4,a4,a5
 a1e:	02e68263          	beq	a3,a4,a42 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 a22:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a24:	00000717          	auipc	a4,0x0
 a28:	5cf73e23          	sd	a5,1500(a4) # 1000 <freep>
}
 a2c:	60a2                	ld	ra,8(sp)
 a2e:	6402                	ld	s0,0(sp)
 a30:	0141                	addi	sp,sp,16
 a32:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 a34:	4618                	lw	a4,8(a2)
 a36:	9f2d                	addw	a4,a4,a1
 a38:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a3c:	6398                	ld	a4,0(a5)
 a3e:	6310                	ld	a2,0(a4)
 a40:	b7f9                	j	a0e <free+0x44>
    p->s.size += bp->s.size;
 a42:	ff852703          	lw	a4,-8(a0)
 a46:	9f31                	addw	a4,a4,a2
 a48:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a4a:	ff053683          	ld	a3,-16(a0)
 a4e:	bfd1                	j	a22 <free+0x58>

0000000000000a50 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a50:	7139                	addi	sp,sp,-64
 a52:	fc06                	sd	ra,56(sp)
 a54:	f822                	sd	s0,48(sp)
 a56:	f04a                	sd	s2,32(sp)
 a58:	ec4e                	sd	s3,24(sp)
 a5a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a5c:	02051993          	slli	s3,a0,0x20
 a60:	0209d993          	srli	s3,s3,0x20
 a64:	09bd                	addi	s3,s3,15
 a66:	0049d993          	srli	s3,s3,0x4
 a6a:	2985                	addiw	s3,s3,1
 a6c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a6e:	00000517          	auipc	a0,0x0
 a72:	59253503          	ld	a0,1426(a0) # 1000 <freep>
 a76:	c905                	beqz	a0,aa6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	09377663          	bgeu	a4,s3,b08 <malloc+0xb8>
 a80:	f426                	sd	s1,40(sp)
 a82:	e852                	sd	s4,16(sp)
 a84:	e456                	sd	s5,8(sp)
 a86:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a88:	8a4e                	mv	s4,s3
 a8a:	6705                	lui	a4,0x1
 a8c:	00e9f363          	bgeu	s3,a4,a92 <malloc+0x42>
 a90:	6a05                	lui	s4,0x1
 a92:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a96:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a9a:	00000497          	auipc	s1,0x0
 a9e:	56648493          	addi	s1,s1,1382 # 1000 <freep>
  if(p == SBRK_ERROR)
 aa2:	5afd                	li	s5,-1
 aa4:	a83d                	j	ae2 <malloc+0x92>
 aa6:	f426                	sd	s1,40(sp)
 aa8:	e852                	sd	s4,16(sp)
 aaa:	e456                	sd	s5,8(sp)
 aac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 aae:	00001797          	auipc	a5,0x1
 ab2:	96278793          	addi	a5,a5,-1694 # 1410 <base>
 ab6:	00000717          	auipc	a4,0x0
 aba:	54f73523          	sd	a5,1354(a4) # 1000 <freep>
 abe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ac0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ac4:	b7d1                	j	a88 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 ac6:	6398                	ld	a4,0(a5)
 ac8:	e118                	sd	a4,0(a0)
 aca:	a899                	j	b20 <malloc+0xd0>
  hp->s.size = nu;
 acc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ad0:	0541                	addi	a0,a0,16
 ad2:	ef9ff0ef          	jal	9ca <free>
  return freep;
 ad6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 ad8:	c125                	beqz	a0,b38 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ada:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 adc:	4798                	lw	a4,8(a5)
 ade:	03277163          	bgeu	a4,s2,b00 <malloc+0xb0>
    if(p == freep)
 ae2:	6098                	ld	a4,0(s1)
 ae4:	853e                	mv	a0,a5
 ae6:	fef71ae3          	bne	a4,a5,ada <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 aea:	8552                	mv	a0,s4
 aec:	9f3ff0ef          	jal	4de <sbrk>
  if(p == SBRK_ERROR)
 af0:	fd551ee3          	bne	a0,s5,acc <malloc+0x7c>
        return 0;
 af4:	4501                	li	a0,0
 af6:	74a2                	ld	s1,40(sp)
 af8:	6a42                	ld	s4,16(sp)
 afa:	6aa2                	ld	s5,8(sp)
 afc:	6b02                	ld	s6,0(sp)
 afe:	a03d                	j	b2c <malloc+0xdc>
 b00:	74a2                	ld	s1,40(sp)
 b02:	6a42                	ld	s4,16(sp)
 b04:	6aa2                	ld	s5,8(sp)
 b06:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b08:	fae90fe3          	beq	s2,a4,ac6 <malloc+0x76>
        p->s.size -= nunits;
 b0c:	4137073b          	subw	a4,a4,s3
 b10:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b12:	02071693          	slli	a3,a4,0x20
 b16:	01c6d713          	srli	a4,a3,0x1c
 b1a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b1c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b20:	00000717          	auipc	a4,0x0
 b24:	4ea73023          	sd	a0,1248(a4) # 1000 <freep>
      return (void*)(p + 1);
 b28:	01078513          	addi	a0,a5,16
  }
}
 b2c:	70e2                	ld	ra,56(sp)
 b2e:	7442                	ld	s0,48(sp)
 b30:	7902                	ld	s2,32(sp)
 b32:	69e2                	ld	s3,24(sp)
 b34:	6121                	addi	sp,sp,64
 b36:	8082                	ret
 b38:	74a2                	ld	s1,40(sp)
 b3a:	6a42                	ld	s4,16(sp)
 b3c:	6aa2                	ld	s5,8(sp)
 b3e:	6b02                	ld	s6,0(sp)
 b40:	b7f5                	j	b2c <malloc+0xdc>
