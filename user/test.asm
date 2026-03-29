
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_getnumchild>:
    int pid1 = getpid();
    int pid2 = getpid2();
    ASSERT(pid1 == pid2, "getpid2() matches standard getpid()");
}

void test_getnumchild(char *s) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
    printf("\nTesting getnumchild...\n");
   e:	00001517          	auipc	a0,0x1
  12:	f0250513          	addi	a0,a0,-254 # f10 <malloc+0xfa>
  16:	549000ef          	jal	d5e <printf>

    int parent_pid = getpid();
  1a:	13f000ef          	jal	958 <getpid>
  1e:	89aa                	mv	s3,a0
    int initial = getnumchild();
  20:	171000ef          	jal	990 <getnumchild>
  24:	84aa                	mv	s1,a0
    printf("Initial children count: %d\n", initial); 
  26:	85aa                	mv	a1,a0
  28:	00001517          	auipc	a0,0x1
  2c:	f0850513          	addi	a0,a0,-248 # f30 <malloc+0x11a>
  30:	52f000ef          	jal	d5e <printf>
    
    int ret = fork();
  34:	09d000ef          	jal	8d0 <fork>
    if (ret == 0) {
  38:	ed05                	bnez	a0,70 <test_getnumchild+0x70>
        int ppid = getppid();
  3a:	14f000ef          	jal	988 <getppid>
  3e:	85aa                	mv	a1,a0
        if (ppid == parent_pid) {
  40:	00a98c63          	beq	s3,a0,58 <test_getnumchild+0x58>
            printf("PASSED: Child correctly identified parent PID %d\n", ppid);
        } else {
            printf("FAILED: Child thought parent was %d, actual is %d\n", ppid, parent_pid);
  44:	864e                	mv	a2,s3
  46:	00001517          	auipc	a0,0x1
  4a:	f4250513          	addi	a0,a0,-190 # f88 <malloc+0x172>
  4e:	511000ef          	jal	d5e <printf>
            exit(1);
  52:	4505                	li	a0,1
  54:	085000ef          	jal	8d8 <exit>
            printf("PASSED: Child correctly identified parent PID %d\n", ppid);
  58:	00001517          	auipc	a0,0x1
  5c:	ef850513          	addi	a0,a0,-264 # f50 <malloc+0x13a>
  60:	4ff000ef          	jal	d5e <printf>
        }
        pause(10); // Keep child alive so parent can count it
  64:	4529                	li	a0,10
  66:	103000ef          	jal	968 <pause>
        exit(0);
  6a:	4501                	li	a0,0
  6c:	06d000ef          	jal	8d8 <exit>
  70:	892a                	mv	s2,a0
    } else {
        pause(5); // Wait for child to stabilize
  72:	4515                	li	a0,5
  74:	0f5000ef          	jal	968 <pause>
        
        int new_count = getnumchild();
  78:	119000ef          	jal	990 <getnumchild>
        ASSERT(new_count == initial + 1, "getnumchild() increments for active child");
  7c:	0014879b          	addiw	a5,s1,1
  80:	04a79763          	bne	a5,a0,ce <test_getnumchild+0xce>
  84:	00001597          	auipc	a1,0x1
  88:	f3c58593          	addi	a1,a1,-196 # fc0 <malloc+0x1aa>
  8c:	00001517          	auipc	a0,0x1
  90:	f7c50513          	addi	a0,a0,-132 # 1008 <malloc+0x1f2>
  94:	4cb000ef          	jal	d5e <printf>

        kill(ret);
  98:	854a                	mv	a0,s2
  9a:	06f000ef          	jal	908 <kill>
        wait(0);
  9e:	4501                	li	a0,0
  a0:	041000ef          	jal	8e0 <wait>

        ASSERT(getnumchild() == initial, "getnumchild() decrements after wait()");
  a4:	0ed000ef          	jal	990 <getnumchild>
  a8:	04951263          	bne	a0,s1,ec <test_getnumchild+0xec>
  ac:	00001597          	auipc	a1,0x1
  b0:	f6c58593          	addi	a1,a1,-148 # 1018 <malloc+0x202>
  b4:	00001517          	auipc	a0,0x1
  b8:	f5450513          	addi	a0,a0,-172 # 1008 <malloc+0x1f2>
  bc:	4a3000ef          	jal	d5e <printf>
    }
}
  c0:	70a2                	ld	ra,40(sp)
  c2:	7402                	ld	s0,32(sp)
  c4:	64e2                	ld	s1,24(sp)
  c6:	6942                	ld	s2,16(sp)
  c8:	69a2                	ld	s3,8(sp)
  ca:	6145                	addi	sp,sp,48
  cc:	8082                	ret
        ASSERT(new_count == initial + 1, "getnumchild() increments for active child");
  ce:	03600613          	li	a2,54
  d2:	00001597          	auipc	a1,0x1
  d6:	eee58593          	addi	a1,a1,-274 # fc0 <malloc+0x1aa>
  da:	00001517          	auipc	a0,0x1
  de:	f1650513          	addi	a0,a0,-234 # ff0 <malloc+0x1da>
  e2:	47d000ef          	jal	d5e <printf>
  e6:	4505                	li	a0,1
  e8:	7f0000ef          	jal	8d8 <exit>
        ASSERT(getnumchild() == initial, "getnumchild() decrements after wait()");
  ec:	03b00613          	li	a2,59
  f0:	00001597          	auipc	a1,0x1
  f4:	f2858593          	addi	a1,a1,-216 # 1018 <malloc+0x202>
  f8:	00001517          	auipc	a0,0x1
  fc:	ef850513          	addi	a0,a0,-264 # ff0 <malloc+0x1da>
 100:	45f000ef          	jal	d5e <printf>
 104:	4505                	li	a0,1
 106:	7d2000ef          	jal	8d8 <exit>

000000000000010a <error>:
void error(char *msg) {
 10a:	1141                	addi	sp,sp,-16
 10c:	e406                	sd	ra,8(sp)
 10e:	e022                	sd	s0,0(sp)
 110:	0800                	addi	s0,sp,16
 112:	85aa                	mv	a1,a0
  printf("FAILURE: %s\n", msg);
 114:	00001517          	auipc	a0,0x1
 118:	f2c50513          	addi	a0,a0,-212 # 1040 <malloc+0x22a>
 11c:	443000ef          	jal	d5e <printf>
  exit(1);
 120:	4505                	li	a0,1
 122:	7b6000ef          	jal	8d8 <exit>

0000000000000126 <test_getpid2>:
void test_getpid2(char *s) {
 126:	1101                	addi	sp,sp,-32
 128:	ec06                	sd	ra,24(sp)
 12a:	e822                	sd	s0,16(sp)
 12c:	e426                	sd	s1,8(sp)
 12e:	1000                	addi	s0,sp,32
    printf("\nTesting getpid2...\n");
 130:	00001517          	auipc	a0,0x1
 134:	f2050513          	addi	a0,a0,-224 # 1050 <malloc+0x23a>
 138:	427000ef          	jal	d5e <printf>
    if (hello() == 0) {
 13c:	03d000ef          	jal	978 <hello>
 140:	ed0d                	bnez	a0,17a <test_getpid2+0x54>
        printf("PASSED: hello() returned 0\n");
 142:	00001517          	auipc	a0,0x1
 146:	f2650513          	addi	a0,a0,-218 # 1068 <malloc+0x252>
 14a:	415000ef          	jal	d5e <printf>
    int pid1 = getpid();
 14e:	00b000ef          	jal	958 <getpid>
 152:	84aa                	mv	s1,a0
    int pid2 = getpid2();
 154:	02d000ef          	jal	980 <getpid2>
    ASSERT(pid1 == pid2, "getpid2() matches standard getpid()");
 158:	02a49763          	bne	s1,a0,186 <test_getpid2+0x60>
 15c:	00001597          	auipc	a1,0x1
 160:	f4c58593          	addi	a1,a1,-180 # 10a8 <malloc+0x292>
 164:	00001517          	auipc	a0,0x1
 168:	ea450513          	addi	a0,a0,-348 # 1008 <malloc+0x1f2>
 16c:	3f3000ef          	jal	d5e <printf>
}
 170:	60e2                	ld	ra,24(sp)
 172:	6442                	ld	s0,16(sp)
 174:	64a2                	ld	s1,8(sp)
 176:	6105                	addi	sp,sp,32
 178:	8082                	ret
        error("hello() returned non-zero");
 17a:	00001517          	auipc	a0,0x1
 17e:	f0e50513          	addi	a0,a0,-242 # 1088 <malloc+0x272>
 182:	f89ff0ef          	jal	10a <error>
    ASSERT(pid1 == pid2, "getpid2() matches standard getpid()");
 186:	4675                	li	a2,29
 188:	00001597          	auipc	a1,0x1
 18c:	f2058593          	addi	a1,a1,-224 # 10a8 <malloc+0x292>
 190:	00001517          	auipc	a0,0x1
 194:	e6050513          	addi	a0,a0,-416 # ff0 <malloc+0x1da>
 198:	3c7000ef          	jal	d5e <printf>
 19c:	4505                	li	a0,1
 19e:	73a000ef          	jal	8d8 <exit>

00000000000001a2 <test_zombie_invariant>:

void test_zombie_invariant(char *s) {
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e406                	sd	ra,8(sp)
 1a6:	e022                	sd	s0,0(sp)
 1a8:	0800                	addi	s0,sp,16
    printf("\nTesting zombie invariant...\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	f2650513          	addi	a0,a0,-218 # 10d0 <malloc+0x2ba>
 1b2:	3ad000ef          	jal	d5e <printf>
    
    int pid = fork();
 1b6:	71a000ef          	jal	8d0 <fork>
    if(pid == 0) {
 1ba:	c505                	beqz	a0,1e2 <test_zombie_invariant+0x40>
        exit(0); // Immediately transition to ZOMBIE state
    }

    pause(10); // Ensure child has fully exited
 1bc:	4529                	li	a0,10
 1be:	7aa000ef          	jal	968 <pause>

    int nc = getnumchild();
 1c2:	7ce000ef          	jal	990 <getnumchild>
    if(nc != 0) {
 1c6:	e105                	bnez	a0,1e6 <test_zombie_invariant+0x44>
        printf("getnumchild returned %d\n", nc);
        error("Zombie process was incorrectly counted as alive");
    } else {
        printf("PASSED: Zombie process correctly ignored\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	f7850513          	addi	a0,a0,-136 # 1140 <malloc+0x32a>
 1d0:	38f000ef          	jal	d5e <printf>
    }

    wait(0);
 1d4:	4501                	li	a0,0
 1d6:	70a000ef          	jal	8e0 <wait>
}
 1da:	60a2                	ld	ra,8(sp)
 1dc:	6402                	ld	s0,0(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
        exit(0); // Immediately transition to ZOMBIE state
 1e2:	6f6000ef          	jal	8d8 <exit>
        printf("getnumchild returned %d\n", nc);
 1e6:	85aa                	mv	a1,a0
 1e8:	00001517          	auipc	a0,0x1
 1ec:	f0850513          	addi	a0,a0,-248 # 10f0 <malloc+0x2da>
 1f0:	36f000ef          	jal	d5e <printf>
        error("Zombie process was incorrectly counted as alive");
 1f4:	00001517          	auipc	a0,0x1
 1f8:	f1c50513          	addi	a0,a0,-228 # 1110 <malloc+0x2fa>
 1fc:	f0fff0ef          	jal	10a <error>

0000000000000200 <test_adoption>:

void test_adoption(char *s) {
 200:	1141                	addi	sp,sp,-16
 202:	e406                	sd	ra,8(sp)
 204:	e022                	sd	s0,0(sp)
 206:	0800                	addi	s0,sp,16
    printf("\nTesting adoption...\n");
 208:	00001517          	auipc	a0,0x1
 20c:	f6850513          	addi	a0,a0,-152 # 1170 <malloc+0x35a>
 210:	34f000ef          	jal	d5e <printf>

    int pid = fork();
 214:	6bc000ef          	jal	8d0 <fork>
    if(pid < 0) error("fork failed");
 218:	02054d63          	bltz	a0,252 <test_adoption+0x52>

    if(pid == 0){
 21c:	e535                	bnez	a0,288 <test_adoption+0x88>
        int pid2 = fork();
 21e:	6b2000ef          	jal	8d0 <fork>
        if(pid2 < 0) error("fork failed");
 222:	02054e63          	bltz	a0,25e <test_adoption+0x5e>
        
        if(pid2 == 0) {
 226:	e939                	bnez	a0,27c <test_adoption+0x7c>
            pause(10); // Wait for parent to exit so reparenting happens
 228:	4529                	li	a0,10
 22a:	73e000ef          	jal	968 <pause>
            
            int new_pp = getppid();
 22e:	75a000ef          	jal	988 <getppid>
 232:	85aa                	mv	a1,a0
            if(new_pp != 1) {
 234:	4785                	li	a5,1
 236:	02f50a63          	beq	a0,a5,26a <test_adoption+0x6a>
                printf("Expected parent 1 (init), got %d\n", new_pp);
 23a:	00001517          	auipc	a0,0x1
 23e:	f5e50513          	addi	a0,a0,-162 # 1198 <malloc+0x382>
 242:	31d000ef          	jal	d5e <printf>
                error("Adoption failed: getppid() did not update to 1");
 246:	00001517          	auipc	a0,0x1
 24a:	f7a50513          	addi	a0,a0,-134 # 11c0 <malloc+0x3aa>
 24e:	ebdff0ef          	jal	10a <error>
    if(pid < 0) error("fork failed");
 252:	00001517          	auipc	a0,0x1
 256:	f3650513          	addi	a0,a0,-202 # 1188 <malloc+0x372>
 25a:	eb1ff0ef          	jal	10a <error>
        if(pid2 < 0) error("fork failed");
 25e:	00001517          	auipc	a0,0x1
 262:	f2a50513          	addi	a0,a0,-214 # 1188 <malloc+0x372>
 266:	ea5ff0ef          	jal	10a <error>
            } else {
                printf("PASSED: Orphan correctly adopted by init\n");
 26a:	00001517          	auipc	a0,0x1
 26e:	f8650513          	addi	a0,a0,-122 # 11f0 <malloc+0x3da>
 272:	2ed000ef          	jal	d5e <printf>
            }
            exit(0);
 276:	4501                	li	a0,0
 278:	660000ef          	jal	8d8 <exit>
        }
        else
            pause(5); // Let grandchild start before parent exits
 27c:	4515                	li	a0,5
 27e:	6ea000ef          	jal	968 <pause>
        
        exit(0);
 282:	4501                	li	a0,0
 284:	654000ef          	jal	8d8 <exit>
    }

    wait(0);
 288:	4501                	li	a0,0
 28a:	656000ef          	jal	8e0 <wait>
    pause(15); // Wait for grandchild verification logic
 28e:	453d                	li	a0,15
 290:	6d8000ef          	jal	968 <pause>
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret

000000000000029c <test_syscount>:

void test_syscount(char *s) {
 29c:	1101                	addi	sp,sp,-32
 29e:	ec06                	sd	ra,24(sp)
 2a0:	e822                	sd	s0,16(sp)
 2a2:	e426                	sd	s1,8(sp)
 2a4:	1000                	addi	s0,sp,32
    printf("\nTesting syscount...\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	f7a50513          	addi	a0,a0,-134 # 1220 <malloc+0x40a>
 2ae:	2b1000ef          	jal	d5e <printf>

    int start = getsyscount();
 2b2:	6e6000ef          	jal	998 <getsyscount>
 2b6:	84aa                	mv	s1,a0
    getpid(); getpid(); getpid();
 2b8:	6a0000ef          	jal	958 <getpid>
 2bc:	69c000ef          	jal	958 <getpid>
 2c0:	698000ef          	jal	958 <getpid>
    int end = getsyscount();
 2c4:	6d4000ef          	jal	998 <getsyscount>
    
    // Expect +4 because getsyscount() itself is a syscall
    if (end >= start + 4) {
 2c8:	0034879b          	addiw	a5,s1,3
 2cc:	04a7d363          	bge	a5,a0,312 <test_syscount+0x76>
        printf("PASSED: getsyscount() tracks local syscalls (Diff: %d)\n", end - start);
 2d0:	409505bb          	subw	a1,a0,s1
 2d4:	00001517          	auipc	a0,0x1
 2d8:	f6450513          	addi	a0,a0,-156 # 1238 <malloc+0x422>
 2dc:	283000ef          	jal	d5e <printf>
    } else {
        error("getsyscount() failed to track local calls");
    }

    if(getchildsyscount(1) == -1 && getchildsyscount(99999) == -1) {
 2e0:	4505                	li	a0,1
 2e2:	6be000ef          	jal	9a0 <getchildsyscount>
 2e6:	57fd                	li	a5,-1
 2e8:	02f51b63          	bne	a0,a5,31e <test_syscount+0x82>
 2ec:	6561                	lui	a0,0x18
 2ee:	69f50513          	addi	a0,a0,1695 # 1869f <base+0x1668f>
 2f2:	6ae000ef          	jal	9a0 <getchildsyscount>
 2f6:	57fd                	li	a5,-1
 2f8:	02f51363          	bne	a0,a5,31e <test_syscount+0x82>
        printf("PASSED: getchildsyscount() handles invalid/non-child PIDs\n");
 2fc:	00001517          	auipc	a0,0x1
 300:	fa450513          	addi	a0,a0,-92 # 12a0 <malloc+0x48a>
 304:	25b000ef          	jal	d5e <printf>
    } else {
        error("getchildsyscount() did not return -1 for invalid PIDs");
    }
}
 308:	60e2                	ld	ra,24(sp)
 30a:	6442                	ld	s0,16(sp)
 30c:	64a2                	ld	s1,8(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret
        error("getsyscount() failed to track local calls");
 312:	00001517          	auipc	a0,0x1
 316:	f5e50513          	addi	a0,a0,-162 # 1270 <malloc+0x45a>
 31a:	df1ff0ef          	jal	10a <error>
        error("getchildsyscount() did not return -1 for invalid PIDs");
 31e:	00001517          	auipc	a0,0x1
 322:	fc250513          	addi	a0,a0,-62 # 12e0 <malloc+0x4ca>
 326:	de5ff0ef          	jal	10a <error>

000000000000032a <test_isolation>:

void test_isolation(char *s) {
 32a:	7179                	addi	sp,sp,-48
 32c:	f406                	sd	ra,40(sp)
 32e:	f022                	sd	s0,32(sp)
 330:	ec26                	sd	s1,24(sp)
 332:	1800                	addi	s0,sp,48
    printf("\nTesting isolation...\n");
 334:	00001517          	auipc	a0,0x1
 338:	fe450513          	addi	a0,a0,-28 # 1318 <malloc+0x502>
 33c:	223000ef          	jal	d5e <printf>

    int p1 = fork();
 340:	590000ef          	jal	8d0 <fork>
    if(p1 == 0) {
 344:	c90d                	beqz	a0,376 <test_isolation+0x4c>
 346:	84aa                	mv	s1,a0
        pause(100);
        exit(0);
    }

    int p2 = fork();
 348:	588000ef          	jal	8d0 <fork>
    if(p2 == 0) {
 34c:	e529                	bnez	a0,396 <test_isolation+0x6c>
        int count = getchildsyscount(p1); // Should fail: p1 is a sibling, not a child
 34e:	8526                	mv	a0,s1
 350:	650000ef          	jal	9a0 <getchildsyscount>
 354:	862a                	mv	a2,a0
        if(count != -1) {
 356:	57fd                	li	a5,-1
 358:	02f50663          	beq	a0,a5,384 <test_isolation+0x5a>
           printf("Sibling 2 read stats of Sibling 1 (PID %d) -> %d\n", p1, count);
 35c:	85a6                	mv	a1,s1
 35e:	00001517          	auipc	a0,0x1
 362:	fd250513          	addi	a0,a0,-46 # 1330 <malloc+0x51a>
 366:	1f9000ef          	jal	d5e <printf>
           error("Privacy violation: getchildsyscount allowed reading non-child");
 36a:	00001517          	auipc	a0,0x1
 36e:	ffe50513          	addi	a0,a0,-2 # 1368 <malloc+0x552>
 372:	d99ff0ef          	jal	10a <error>
        pause(100);
 376:	06400513          	li	a0,100
 37a:	5ee000ef          	jal	968 <pause>
        exit(0);
 37e:	4501                	li	a0,0
 380:	558000ef          	jal	8d8 <exit>
        } else {
            printf("PASSED: Sibling blocked from reading non-child stats\n");
 384:	00001517          	auipc	a0,0x1
 388:	02450513          	addi	a0,a0,36 # 13a8 <malloc+0x592>
 38c:	1d3000ef          	jal	d5e <printf>
        }
        exit(0);
 390:	4501                	li	a0,0
 392:	546000ef          	jal	8d8 <exit>
    }

    int status;
    wait(&status);
 396:	fdc40513          	addi	a0,s0,-36
 39a:	546000ef          	jal	8e0 <wait>
    wait(&status);
 39e:	fdc40513          	addi	a0,s0,-36
 3a2:	53e000ef          	jal	8e0 <wait>
    kill(p1);
 3a6:	8526                	mv	a0,s1
 3a8:	560000ef          	jal	908 <kill>
    wait(0);
 3ac:	4501                	li	a0,0
 3ae:	532000ef          	jal	8e0 <wait>
}
 3b2:	70a2                	ld	ra,40(sp)
 3b4:	7402                	ld	s0,32(sp)
 3b6:	64e2                	ld	s1,24(sp)
 3b8:	6145                	addi	sp,sp,48
 3ba:	8082                	ret

00000000000003bc <test_stress_count>:

void test_stress_count(char *s) {
 3bc:	1101                	addi	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	e426                	sd	s1,8(sp)
 3c4:	e04a                	sd	s2,0(sp)
 3c6:	1000                	addi	s0,sp,32
    printf("\nTesting High-Volume Syscall Stress...\n");
 3c8:	00001517          	auipc	a0,0x1
 3cc:	01850513          	addi	a0,a0,24 # 13e0 <malloc+0x5ca>
 3d0:	18f000ef          	jal	d5e <printf>

    int start = getsyscount();
 3d4:	5c4000ef          	jal	998 <getsyscount>
 3d8:	892a                	mv	s2,a0
 3da:	6485                	lui	s1,0x1
 3dc:	38848493          	addi	s1,s1,904 # 1388 <malloc+0x572>
    int LOOPS = 5000;
    
    for(int i = 0; i < LOOPS; i++) {
        getpid();
 3e0:	578000ef          	jal	958 <getpid>
    for(int i = 0; i < LOOPS; i++) {
 3e4:	34fd                	addiw	s1,s1,-1
 3e6:	fced                	bnez	s1,3e0 <test_stress_count+0x24>
    }

    int end = getsyscount();
 3e8:	5b0000ef          	jal	998 <getsyscount>
    int actual = end - start;
 3ec:	412505bb          	subw	a1,a0,s2
    
    if(actual < LOOPS) {
 3f0:	6785                	lui	a5,0x1
 3f2:	38778793          	addi	a5,a5,903 # 1387 <malloc+0x571>
 3f6:	00b7de63          	bge	a5,a1,412 <test_stress_count+0x56>
        printf("Expected > %d syscalls, counted %d\n", LOOPS, actual);
        error("Syscall accounting missed events under stress");
    } else {
        printf("PASSED: Accounted %d calls correctly under stress\n", actual);
 3fa:	00001517          	auipc	a0,0x1
 3fe:	06650513          	addi	a0,a0,102 # 1460 <malloc+0x64a>
 402:	15d000ef          	jal	d5e <printf>
    }
}
 406:	60e2                	ld	ra,24(sp)
 408:	6442                	ld	s0,16(sp)
 40a:	64a2                	ld	s1,8(sp)
 40c:	6902                	ld	s2,0(sp)
 40e:	6105                	addi	sp,sp,32
 410:	8082                	ret
        printf("Expected > %d syscalls, counted %d\n", LOOPS, actual);
 412:	862e                	mv	a2,a1
 414:	6585                	lui	a1,0x1
 416:	38858593          	addi	a1,a1,904 # 1388 <malloc+0x572>
 41a:	00001517          	auipc	a0,0x1
 41e:	fee50513          	addi	a0,a0,-18 # 1408 <malloc+0x5f2>
 422:	13d000ef          	jal	d5e <printf>
        error("Syscall accounting missed events under stress");
 426:	00001517          	auipc	a0,0x1
 42a:	00a50513          	addi	a0,a0,10 # 1430 <malloc+0x61a>
 42e:	cddff0ef          	jal	10a <error>

0000000000000432 <test_concurrent_children>:

void test_concurrent_children(char *s) {
 432:	715d                	addi	sp,sp,-80
 434:	e486                	sd	ra,72(sp)
 436:	e0a2                	sd	s0,64(sp)
 438:	fc26                	sd	s1,56(sp)
 43a:	f84a                	sd	s2,48(sp)
 43c:	f44e                	sd	s3,40(sp)
 43e:	0880                	addi	s0,sp,80
    printf("\nTesting Multiple Concurrent Children...\n");
 440:	00001517          	auipc	a0,0x1
 444:	05850513          	addi	a0,a0,88 # 1498 <malloc+0x682>
 448:	117000ef          	jal	d5e <printf>
    
    int children_pids[5];
    int i;

    for(i = 0; i < 5; i++) {
 44c:	fb840493          	addi	s1,s0,-72
 450:	fcc40993          	addi	s3,s0,-52
    printf("\nTesting Multiple Concurrent Children...\n");
 454:	8926                	mv	s2,s1
        int pid = fork();
 456:	47a000ef          	jal	8d0 <fork>
        if(pid == 0) {
 45a:	c53d                	beqz	a0,4c8 <test_concurrent_children+0x96>
            for(int j = 0; j < 50; j++) getpid(); 
            pause(20);
            exit(0);
        }
        children_pids[i] = pid;
 45c:	00a92023          	sw	a0,0(s2)
    for(i = 0; i < 5; i++) {
 460:	0911                	addi	s2,s2,4
 462:	ff391ae3          	bne	s2,s3,456 <test_concurrent_children+0x24>
    }

    pause(5); // Ensure all children are active
 466:	4515                	li	a0,5
 468:	500000ef          	jal	968 <pause>

    int active_children = getnumchild();
 46c:	524000ef          	jal	990 <getnumchild>
 470:	85aa                	mv	a1,a0
    if (active_children < 5) {
 472:	4791                	li	a5,4
 474:	06a7d663          	bge	a5,a0,4e0 <test_concurrent_children+0xae>
        error("getnumchild() failed to count all concurrent children");
    }
    printf("PASSED: Detected %d active concurrent children\n", active_children);
 478:	00001517          	auipc	a0,0x1
 47c:	08850513          	addi	a0,a0,136 # 1500 <malloc+0x6ea>
 480:	0df000ef          	jal	d5e <printf>

    int count = getchildsyscount(children_pids[2]);
 484:	fc042503          	lw	a0,-64(s0)
 488:	518000ef          	jal	9a0 <getchildsyscount>
 48c:	85aa                	mv	a1,a0
    if (count < 50) {
 48e:	03100793          	li	a5,49
 492:	04a7dd63          	bge	a5,a0,4ec <test_concurrent_children+0xba>
        error("getchildsyscount() read invalid stats from concurrent child");
    }
    printf("PASSED: Concurrent child stats read successfully (%d)\n", count);
 496:	00001517          	auipc	a0,0x1
 49a:	0da50513          	addi	a0,a0,218 # 1570 <malloc+0x75a>
 49e:	0c1000ef          	jal	d5e <printf>

    for(i = 0; i < 5; i++) kill(children_pids[i]);
 4a2:	4088                	lw	a0,0(s1)
 4a4:	464000ef          	jal	908 <kill>
 4a8:	0491                	addi	s1,s1,4
 4aa:	ff349ce3          	bne	s1,s3,4a2 <test_concurrent_children+0x70>
 4ae:	4495                	li	s1,5
    for(i = 0; i < 5; i++) wait(0);
 4b0:	4501                	li	a0,0
 4b2:	42e000ef          	jal	8e0 <wait>
 4b6:	34fd                	addiw	s1,s1,-1
 4b8:	fce5                	bnez	s1,4b0 <test_concurrent_children+0x7e>
}
 4ba:	60a6                	ld	ra,72(sp)
 4bc:	6406                	ld	s0,64(sp)
 4be:	74e2                	ld	s1,56(sp)
 4c0:	7942                	ld	s2,48(sp)
 4c2:	79a2                	ld	s3,40(sp)
 4c4:	6161                	addi	sp,sp,80
 4c6:	8082                	ret
 4c8:	03200493          	li	s1,50
            for(int j = 0; j < 50; j++) getpid(); 
 4cc:	48c000ef          	jal	958 <getpid>
 4d0:	34fd                	addiw	s1,s1,-1
 4d2:	fced                	bnez	s1,4cc <test_concurrent_children+0x9a>
            pause(20);
 4d4:	4551                	li	a0,20
 4d6:	492000ef          	jal	968 <pause>
            exit(0);
 4da:	4501                	li	a0,0
 4dc:	3fc000ef          	jal	8d8 <exit>
        error("getnumchild() failed to count all concurrent children");
 4e0:	00001517          	auipc	a0,0x1
 4e4:	fe850513          	addi	a0,a0,-24 # 14c8 <malloc+0x6b2>
 4e8:	c23ff0ef          	jal	10a <error>
        error("getchildsyscount() read invalid stats from concurrent child");
 4ec:	00001517          	auipc	a0,0x1
 4f0:	04450513          	addi	a0,a0,68 # 1530 <malloc+0x71a>
 4f4:	c17ff0ef          	jal	10a <error>

00000000000004f8 <run_test>:

void run_test(void (*func)(char *), char *name) {
 4f8:	7179                	addi	sp,sp,-48
 4fa:	f406                	sd	ra,40(sp)
 4fc:	f022                	sd	s0,32(sp)
 4fe:	ec26                	sd	s1,24(sp)
 500:	e84a                	sd	s2,16(sp)
 502:	1800                	addi	s0,sp,48
 504:	892a                	mv	s2,a0
 506:	84ae                	mv	s1,a1
    int pid, xstatus;
    
    // Fork each test to isolate crashes
    pid = fork();
 508:	3c8000ef          	jal	8d0 <fork>
    if(pid < 0) {
 50c:	02054063          	bltz	a0,52c <run_test+0x34>
        printf("fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
 510:	c51d                	beqz	a0,53e <run_test+0x46>
        func(name);
        exit(0);
    } else {
        wait(&xstatus);
 512:	fdc40513          	addi	a0,s0,-36
 516:	3ca000ef          	jal	8e0 <wait>
        if(xstatus != 0) {
 51a:	fdc42783          	lw	a5,-36(s0)
 51e:	e78d                	bnez	a5,548 <run_test+0x50>
            printf("\n>>> FAILED: %s <<<\n\n", name);
            exit(1);
        }
    }
}
 520:	70a2                	ld	ra,40(sp)
 522:	7402                	ld	s0,32(sp)
 524:	64e2                	ld	s1,24(sp)
 526:	6942                	ld	s2,16(sp)
 528:	6145                	addi	sp,sp,48
 52a:	8082                	ret
        printf("fork failed\n");
 52c:	00001517          	auipc	a0,0x1
 530:	07c50513          	addi	a0,a0,124 # 15a8 <malloc+0x792>
 534:	02b000ef          	jal	d5e <printf>
        exit(1);
 538:	4505                	li	a0,1
 53a:	39e000ef          	jal	8d8 <exit>
        func(name);
 53e:	8526                	mv	a0,s1
 540:	9902                	jalr	s2
        exit(0);
 542:	4501                	li	a0,0
 544:	394000ef          	jal	8d8 <exit>
            printf("\n>>> FAILED: %s <<<\n\n", name);
 548:	85a6                	mv	a1,s1
 54a:	00001517          	auipc	a0,0x1
 54e:	06e50513          	addi	a0,a0,110 # 15b8 <malloc+0x7a2>
 552:	00d000ef          	jal	d5e <printf>
            exit(1);
 556:	4505                	li	a0,1
 558:	380000ef          	jal	8d8 <exit>

000000000000055c <main>:

int main(int argc, char *argv[]) {
 55c:	1141                	addi	sp,sp,-16
 55e:	e406                	sd	ra,8(sp)
 560:	e022                	sd	s0,0(sp)
 562:	0800                	addi	s0,sp,16
    printf("running testing script\n");
 564:	00001517          	auipc	a0,0x1
 568:	06c50513          	addi	a0,a0,108 # 15d0 <malloc+0x7ba>
 56c:	7f2000ef          	jal	d5e <printf>
    
    run_test(test_getpid2,            "Testing getpid2");
 570:	00001597          	auipc	a1,0x1
 574:	07858593          	addi	a1,a1,120 # 15e8 <malloc+0x7d2>
 578:	00000517          	auipc	a0,0x0
 57c:	bae50513          	addi	a0,a0,-1106 # 126 <test_getpid2>
 580:	f79ff0ef          	jal	4f8 <run_test>
    run_test(test_getnumchild,     "Testing getnumchild");
 584:	00001597          	auipc	a1,0x1
 588:	07458593          	addi	a1,a1,116 # 15f8 <malloc+0x7e2>
 58c:	00000517          	auipc	a0,0x0
 590:	a7450513          	addi	a0,a0,-1420 # 0 <test_getnumchild>
 594:	f65ff0ef          	jal	4f8 <run_test>
    run_test(test_syscount,     "Testing syscount");
 598:	00001597          	auipc	a1,0x1
 59c:	07858593          	addi	a1,a1,120 # 1610 <malloc+0x7fa>
 5a0:	00000517          	auipc	a0,0x0
 5a4:	cfc50513          	addi	a0,a0,-772 # 29c <test_syscount>
 5a8:	f51ff0ef          	jal	4f8 <run_test>
    
    run_test(test_zombie_invariant, "Testing Zombie Invariant");
 5ac:	00001597          	auipc	a1,0x1
 5b0:	07c58593          	addi	a1,a1,124 # 1628 <malloc+0x812>
 5b4:	00000517          	auipc	a0,0x0
 5b8:	bee50513          	addi	a0,a0,-1042 # 1a2 <test_zombie_invariant>
 5bc:	f3dff0ef          	jal	4f8 <run_test>
    run_test(test_adoption,         "Testing Orphan Adoption");
 5c0:	00001597          	auipc	a1,0x1
 5c4:	08858593          	addi	a1,a1,136 # 1648 <malloc+0x832>
 5c8:	00000517          	auipc	a0,0x0
 5cc:	c3850513          	addi	a0,a0,-968 # 200 <test_adoption>
 5d0:	f29ff0ef          	jal	4f8 <run_test>
    run_test(test_isolation,        "Testing Security/Isolation");
 5d4:	00001597          	auipc	a1,0x1
 5d8:	08c58593          	addi	a1,a1,140 # 1660 <malloc+0x84a>
 5dc:	00000517          	auipc	a0,0x0
 5e0:	d4e50513          	addi	a0,a0,-690 # 32a <test_isolation>
 5e4:	f15ff0ef          	jal	4f8 <run_test>
    
    run_test(test_stress_count,     "Testing locking discpline: Stress Test");
 5e8:	00001597          	auipc	a1,0x1
 5ec:	09858593          	addi	a1,a1,152 # 1680 <malloc+0x86a>
 5f0:	00000517          	auipc	a0,0x0
 5f4:	dcc50513          	addi	a0,a0,-564 # 3bc <test_stress_count>
 5f8:	f01ff0ef          	jal	4f8 <run_test>
    run_test(test_concurrent_children, "Testing locking discpline: Multi-Process");
 5fc:	00001597          	auipc	a1,0x1
 600:	0ac58593          	addi	a1,a1,172 # 16a8 <malloc+0x892>
 604:	00000517          	auipc	a0,0x0
 608:	e2e50513          	addi	a0,a0,-466 # 432 <test_concurrent_children>
 60c:	eedff0ef          	jal	4f8 <run_test>

    printf("\nALL TESTS PASSED SUCCESSFULLY.\n");
 610:	00001517          	auipc	a0,0x1
 614:	0c850513          	addi	a0,a0,200 # 16d8 <malloc+0x8c2>
 618:	746000ef          	jal	d5e <printf>
    exit(0);
 61c:	4501                	li	a0,0
 61e:	2ba000ef          	jal	8d8 <exit>

0000000000000622 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 622:	1141                	addi	sp,sp,-16
 624:	e406                	sd	ra,8(sp)
 626:	e022                	sd	s0,0(sp)
 628:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 62a:	f33ff0ef          	jal	55c <main>
  exit(r);
 62e:	2aa000ef          	jal	8d8 <exit>

0000000000000632 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 632:	1141                	addi	sp,sp,-16
 634:	e406                	sd	ra,8(sp)
 636:	e022                	sd	s0,0(sp)
 638:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 63a:	87aa                	mv	a5,a0
 63c:	0585                	addi	a1,a1,1
 63e:	0785                	addi	a5,a5,1
 640:	fff5c703          	lbu	a4,-1(a1)
 644:	fee78fa3          	sb	a4,-1(a5)
 648:	fb75                	bnez	a4,63c <strcpy+0xa>
    ;
  return os;
}
 64a:	60a2                	ld	ra,8(sp)
 64c:	6402                	ld	s0,0(sp)
 64e:	0141                	addi	sp,sp,16
 650:	8082                	ret

0000000000000652 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 652:	1141                	addi	sp,sp,-16
 654:	e406                	sd	ra,8(sp)
 656:	e022                	sd	s0,0(sp)
 658:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 65a:	00054783          	lbu	a5,0(a0)
 65e:	cb91                	beqz	a5,672 <strcmp+0x20>
 660:	0005c703          	lbu	a4,0(a1)
 664:	00f71763          	bne	a4,a5,672 <strcmp+0x20>
    p++, q++;
 668:	0505                	addi	a0,a0,1
 66a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 66c:	00054783          	lbu	a5,0(a0)
 670:	fbe5                	bnez	a5,660 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 672:	0005c503          	lbu	a0,0(a1)
}
 676:	40a7853b          	subw	a0,a5,a0
 67a:	60a2                	ld	ra,8(sp)
 67c:	6402                	ld	s0,0(sp)
 67e:	0141                	addi	sp,sp,16
 680:	8082                	ret

0000000000000682 <strlen>:

uint
strlen(const char *s)
{
 682:	1141                	addi	sp,sp,-16
 684:	e406                	sd	ra,8(sp)
 686:	e022                	sd	s0,0(sp)
 688:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 68a:	00054783          	lbu	a5,0(a0)
 68e:	cf91                	beqz	a5,6aa <strlen+0x28>
 690:	00150793          	addi	a5,a0,1
 694:	86be                	mv	a3,a5
 696:	0785                	addi	a5,a5,1
 698:	fff7c703          	lbu	a4,-1(a5)
 69c:	ff65                	bnez	a4,694 <strlen+0x12>
 69e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 6a2:	60a2                	ld	ra,8(sp)
 6a4:	6402                	ld	s0,0(sp)
 6a6:	0141                	addi	sp,sp,16
 6a8:	8082                	ret
  for(n = 0; s[n]; n++)
 6aa:	4501                	li	a0,0
 6ac:	bfdd                	j	6a2 <strlen+0x20>

00000000000006ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 6ae:	1141                	addi	sp,sp,-16
 6b0:	e406                	sd	ra,8(sp)
 6b2:	e022                	sd	s0,0(sp)
 6b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 6b6:	ca19                	beqz	a2,6cc <memset+0x1e>
 6b8:	87aa                	mv	a5,a0
 6ba:	1602                	slli	a2,a2,0x20
 6bc:	9201                	srli	a2,a2,0x20
 6be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 6c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 6c6:	0785                	addi	a5,a5,1
 6c8:	fee79de3          	bne	a5,a4,6c2 <memset+0x14>
  }
  return dst;
}
 6cc:	60a2                	ld	ra,8(sp)
 6ce:	6402                	ld	s0,0(sp)
 6d0:	0141                	addi	sp,sp,16
 6d2:	8082                	ret

00000000000006d4 <strchr>:

char*
strchr(const char *s, char c)
{
 6d4:	1141                	addi	sp,sp,-16
 6d6:	e406                	sd	ra,8(sp)
 6d8:	e022                	sd	s0,0(sp)
 6da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 6dc:	00054783          	lbu	a5,0(a0)
 6e0:	cf81                	beqz	a5,6f8 <strchr+0x24>
    if(*s == c)
 6e2:	00f58763          	beq	a1,a5,6f0 <strchr+0x1c>
  for(; *s; s++)
 6e6:	0505                	addi	a0,a0,1
 6e8:	00054783          	lbu	a5,0(a0)
 6ec:	fbfd                	bnez	a5,6e2 <strchr+0xe>
      return (char*)s;
  return 0;
 6ee:	4501                	li	a0,0
}
 6f0:	60a2                	ld	ra,8(sp)
 6f2:	6402                	ld	s0,0(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret
  return 0;
 6f8:	4501                	li	a0,0
 6fa:	bfdd                	j	6f0 <strchr+0x1c>

00000000000006fc <gets>:

char*
gets(char *buf, int max)
{
 6fc:	711d                	addi	sp,sp,-96
 6fe:	ec86                	sd	ra,88(sp)
 700:	e8a2                	sd	s0,80(sp)
 702:	e4a6                	sd	s1,72(sp)
 704:	e0ca                	sd	s2,64(sp)
 706:	fc4e                	sd	s3,56(sp)
 708:	f852                	sd	s4,48(sp)
 70a:	f456                	sd	s5,40(sp)
 70c:	f05a                	sd	s6,32(sp)
 70e:	ec5e                	sd	s7,24(sp)
 710:	e862                	sd	s8,16(sp)
 712:	1080                	addi	s0,sp,96
 714:	8baa                	mv	s7,a0
 716:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 718:	892a                	mv	s2,a0
 71a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 71c:	faf40b13          	addi	s6,s0,-81
 720:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 722:	8c26                	mv	s8,s1
 724:	0014899b          	addiw	s3,s1,1
 728:	84ce                	mv	s1,s3
 72a:	0349d463          	bge	s3,s4,752 <gets+0x56>
    cc = read(0, &c, 1);
 72e:	8656                	mv	a2,s5
 730:	85da                	mv	a1,s6
 732:	4501                	li	a0,0
 734:	1bc000ef          	jal	8f0 <read>
    if(cc < 1)
 738:	00a05d63          	blez	a0,752 <gets+0x56>
      break;
    buf[i++] = c;
 73c:	faf44783          	lbu	a5,-81(s0)
 740:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 744:	0905                	addi	s2,s2,1
 746:	ff678713          	addi	a4,a5,-10
 74a:	c319                	beqz	a4,750 <gets+0x54>
 74c:	17cd                	addi	a5,a5,-13
 74e:	fbf1                	bnez	a5,722 <gets+0x26>
    buf[i++] = c;
 750:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 752:	9c5e                	add	s8,s8,s7
 754:	000c0023          	sb	zero,0(s8)
  return buf;
}
 758:	855e                	mv	a0,s7
 75a:	60e6                	ld	ra,88(sp)
 75c:	6446                	ld	s0,80(sp)
 75e:	64a6                	ld	s1,72(sp)
 760:	6906                	ld	s2,64(sp)
 762:	79e2                	ld	s3,56(sp)
 764:	7a42                	ld	s4,48(sp)
 766:	7aa2                	ld	s5,40(sp)
 768:	7b02                	ld	s6,32(sp)
 76a:	6be2                	ld	s7,24(sp)
 76c:	6c42                	ld	s8,16(sp)
 76e:	6125                	addi	sp,sp,96
 770:	8082                	ret

0000000000000772 <stat>:

int
stat(const char *n, struct stat *st)
{
 772:	1101                	addi	sp,sp,-32
 774:	ec06                	sd	ra,24(sp)
 776:	e822                	sd	s0,16(sp)
 778:	e04a                	sd	s2,0(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 77e:	4581                	li	a1,0
 780:	198000ef          	jal	918 <open>
  if(fd < 0)
 784:	02054263          	bltz	a0,7a8 <stat+0x36>
 788:	e426                	sd	s1,8(sp)
 78a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 78c:	85ca                	mv	a1,s2
 78e:	1a2000ef          	jal	930 <fstat>
 792:	892a                	mv	s2,a0
  close(fd);
 794:	8526                	mv	a0,s1
 796:	16a000ef          	jal	900 <close>
  return r;
 79a:	64a2                	ld	s1,8(sp)
}
 79c:	854a                	mv	a0,s2
 79e:	60e2                	ld	ra,24(sp)
 7a0:	6442                	ld	s0,16(sp)
 7a2:	6902                	ld	s2,0(sp)
 7a4:	6105                	addi	sp,sp,32
 7a6:	8082                	ret
    return -1;
 7a8:	57fd                	li	a5,-1
 7aa:	893e                	mv	s2,a5
 7ac:	bfc5                	j	79c <stat+0x2a>

00000000000007ae <atoi>:

int
atoi(const char *s)
{
 7ae:	1141                	addi	sp,sp,-16
 7b0:	e406                	sd	ra,8(sp)
 7b2:	e022                	sd	s0,0(sp)
 7b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7b6:	00054683          	lbu	a3,0(a0)
 7ba:	fd06879b          	addiw	a5,a3,-48
 7be:	0ff7f793          	zext.b	a5,a5
 7c2:	4625                	li	a2,9
 7c4:	02f66963          	bltu	a2,a5,7f6 <atoi+0x48>
 7c8:	872a                	mv	a4,a0
  n = 0;
 7ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 7cc:	0705                	addi	a4,a4,1
 7ce:	0025179b          	slliw	a5,a0,0x2
 7d2:	9fa9                	addw	a5,a5,a0
 7d4:	0017979b          	slliw	a5,a5,0x1
 7d8:	9fb5                	addw	a5,a5,a3
 7da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 7de:	00074683          	lbu	a3,0(a4)
 7e2:	fd06879b          	addiw	a5,a3,-48
 7e6:	0ff7f793          	zext.b	a5,a5
 7ea:	fef671e3          	bgeu	a2,a5,7cc <atoi+0x1e>
  return n;
}
 7ee:	60a2                	ld	ra,8(sp)
 7f0:	6402                	ld	s0,0(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret
  n = 0;
 7f6:	4501                	li	a0,0
 7f8:	bfdd                	j	7ee <atoi+0x40>

00000000000007fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 7fa:	1141                	addi	sp,sp,-16
 7fc:	e406                	sd	ra,8(sp)
 7fe:	e022                	sd	s0,0(sp)
 800:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 802:	02b57563          	bgeu	a0,a1,82c <memmove+0x32>
    while(n-- > 0)
 806:	00c05f63          	blez	a2,824 <memmove+0x2a>
 80a:	1602                	slli	a2,a2,0x20
 80c:	9201                	srli	a2,a2,0x20
 80e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 812:	872a                	mv	a4,a0
      *dst++ = *src++;
 814:	0585                	addi	a1,a1,1
 816:	0705                	addi	a4,a4,1
 818:	fff5c683          	lbu	a3,-1(a1)
 81c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 820:	fee79ae3          	bne	a5,a4,814 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 824:	60a2                	ld	ra,8(sp)
 826:	6402                	ld	s0,0(sp)
 828:	0141                	addi	sp,sp,16
 82a:	8082                	ret
    while(n-- > 0)
 82c:	fec05ce3          	blez	a2,824 <memmove+0x2a>
    dst += n;
 830:	00c50733          	add	a4,a0,a2
    src += n;
 834:	95b2                	add	a1,a1,a2
 836:	fff6079b          	addiw	a5,a2,-1
 83a:	1782                	slli	a5,a5,0x20
 83c:	9381                	srli	a5,a5,0x20
 83e:	fff7c793          	not	a5,a5
 842:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 844:	15fd                	addi	a1,a1,-1
 846:	177d                	addi	a4,a4,-1
 848:	0005c683          	lbu	a3,0(a1)
 84c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 850:	fef71ae3          	bne	a4,a5,844 <memmove+0x4a>
 854:	bfc1                	j	824 <memmove+0x2a>

0000000000000856 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 856:	1141                	addi	sp,sp,-16
 858:	e406                	sd	ra,8(sp)
 85a:	e022                	sd	s0,0(sp)
 85c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 85e:	c61d                	beqz	a2,88c <memcmp+0x36>
 860:	1602                	slli	a2,a2,0x20
 862:	9201                	srli	a2,a2,0x20
 864:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 868:	00054783          	lbu	a5,0(a0)
 86c:	0005c703          	lbu	a4,0(a1)
 870:	00e79863          	bne	a5,a4,880 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 874:	0505                	addi	a0,a0,1
    p2++;
 876:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 878:	fed518e3          	bne	a0,a3,868 <memcmp+0x12>
  }
  return 0;
 87c:	4501                	li	a0,0
 87e:	a019                	j	884 <memcmp+0x2e>
      return *p1 - *p2;
 880:	40e7853b          	subw	a0,a5,a4
}
 884:	60a2                	ld	ra,8(sp)
 886:	6402                	ld	s0,0(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret
  return 0;
 88c:	4501                	li	a0,0
 88e:	bfdd                	j	884 <memcmp+0x2e>

0000000000000890 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 890:	1141                	addi	sp,sp,-16
 892:	e406                	sd	ra,8(sp)
 894:	e022                	sd	s0,0(sp)
 896:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 898:	f63ff0ef          	jal	7fa <memmove>
}
 89c:	60a2                	ld	ra,8(sp)
 89e:	6402                	ld	s0,0(sp)
 8a0:	0141                	addi	sp,sp,16
 8a2:	8082                	ret

00000000000008a4 <sbrk>:

char *
sbrk(int n) {
 8a4:	1141                	addi	sp,sp,-16
 8a6:	e406                	sd	ra,8(sp)
 8a8:	e022                	sd	s0,0(sp)
 8aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 8ac:	4585                	li	a1,1
 8ae:	0b2000ef          	jal	960 <sys_sbrk>
}
 8b2:	60a2                	ld	ra,8(sp)
 8b4:	6402                	ld	s0,0(sp)
 8b6:	0141                	addi	sp,sp,16
 8b8:	8082                	ret

00000000000008ba <sbrklazy>:

char *
sbrklazy(int n) {
 8ba:	1141                	addi	sp,sp,-16
 8bc:	e406                	sd	ra,8(sp)
 8be:	e022                	sd	s0,0(sp)
 8c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 8c2:	4589                	li	a1,2
 8c4:	09c000ef          	jal	960 <sys_sbrk>
}
 8c8:	60a2                	ld	ra,8(sp)
 8ca:	6402                	ld	s0,0(sp)
 8cc:	0141                	addi	sp,sp,16
 8ce:	8082                	ret

00000000000008d0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8d0:	4885                	li	a7,1
 ecall
 8d2:	00000073          	ecall
 ret
 8d6:	8082                	ret

00000000000008d8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 8d8:	4889                	li	a7,2
 ecall
 8da:	00000073          	ecall
 ret
 8de:	8082                	ret

00000000000008e0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 8e0:	488d                	li	a7,3
 ecall
 8e2:	00000073          	ecall
 ret
 8e6:	8082                	ret

00000000000008e8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 8e8:	4891                	li	a7,4
 ecall
 8ea:	00000073          	ecall
 ret
 8ee:	8082                	ret

00000000000008f0 <read>:
.global read
read:
 li a7, SYS_read
 8f0:	4895                	li	a7,5
 ecall
 8f2:	00000073          	ecall
 ret
 8f6:	8082                	ret

00000000000008f8 <write>:
.global write
write:
 li a7, SYS_write
 8f8:	48c1                	li	a7,16
 ecall
 8fa:	00000073          	ecall
 ret
 8fe:	8082                	ret

0000000000000900 <close>:
.global close
close:
 li a7, SYS_close
 900:	48d5                	li	a7,21
 ecall
 902:	00000073          	ecall
 ret
 906:	8082                	ret

0000000000000908 <kill>:
.global kill
kill:
 li a7, SYS_kill
 908:	4899                	li	a7,6
 ecall
 90a:	00000073          	ecall
 ret
 90e:	8082                	ret

0000000000000910 <exec>:
.global exec
exec:
 li a7, SYS_exec
 910:	489d                	li	a7,7
 ecall
 912:	00000073          	ecall
 ret
 916:	8082                	ret

0000000000000918 <open>:
.global open
open:
 li a7, SYS_open
 918:	48bd                	li	a7,15
 ecall
 91a:	00000073          	ecall
 ret
 91e:	8082                	ret

0000000000000920 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 920:	48c5                	li	a7,17
 ecall
 922:	00000073          	ecall
 ret
 926:	8082                	ret

0000000000000928 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 928:	48c9                	li	a7,18
 ecall
 92a:	00000073          	ecall
 ret
 92e:	8082                	ret

0000000000000930 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 930:	48a1                	li	a7,8
 ecall
 932:	00000073          	ecall
 ret
 936:	8082                	ret

0000000000000938 <link>:
.global link
link:
 li a7, SYS_link
 938:	48cd                	li	a7,19
 ecall
 93a:	00000073          	ecall
 ret
 93e:	8082                	ret

0000000000000940 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 940:	48d1                	li	a7,20
 ecall
 942:	00000073          	ecall
 ret
 946:	8082                	ret

0000000000000948 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 948:	48a5                	li	a7,9
 ecall
 94a:	00000073          	ecall
 ret
 94e:	8082                	ret

0000000000000950 <dup>:
.global dup
dup:
 li a7, SYS_dup
 950:	48a9                	li	a7,10
 ecall
 952:	00000073          	ecall
 ret
 956:	8082                	ret

0000000000000958 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 958:	48ad                	li	a7,11
 ecall
 95a:	00000073          	ecall
 ret
 95e:	8082                	ret

0000000000000960 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 960:	48b1                	li	a7,12
 ecall
 962:	00000073          	ecall
 ret
 966:	8082                	ret

0000000000000968 <pause>:
.global pause
pause:
 li a7, SYS_pause
 968:	48b5                	li	a7,13
 ecall
 96a:	00000073          	ecall
 ret
 96e:	8082                	ret

0000000000000970 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 970:	48b9                	li	a7,14
 ecall
 972:	00000073          	ecall
 ret
 976:	8082                	ret

0000000000000978 <hello>:
.global hello
hello:
 li a7, SYS_hello
 978:	48d9                	li	a7,22
 ecall
 97a:	00000073          	ecall
 ret
 97e:	8082                	ret

0000000000000980 <getpid2>:
.global getpid2
getpid2:
 li a7, SYS_getpid2
 980:	48dd                	li	a7,23
 ecall
 982:	00000073          	ecall
 ret
 986:	8082                	ret

0000000000000988 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 988:	48e1                	li	a7,24
 ecall
 98a:	00000073          	ecall
 ret
 98e:	8082                	ret

0000000000000990 <getnumchild>:
.global getnumchild
getnumchild:
 li a7, SYS_getnumchild
 990:	48e5                	li	a7,25
 ecall
 992:	00000073          	ecall
 ret
 996:	8082                	ret

0000000000000998 <getsyscount>:
.global getsyscount
getsyscount:
 li a7, SYS_getsyscount
 998:	48e9                	li	a7,26
 ecall
 99a:	00000073          	ecall
 ret
 99e:	8082                	ret

00000000000009a0 <getchildsyscount>:
.global getchildsyscount
getchildsyscount:
 li a7, SYS_getchildsyscount
 9a0:	48ed                	li	a7,27
 ecall
 9a2:	00000073          	ecall
 ret
 9a6:	8082                	ret

00000000000009a8 <getlevel>:
.global getlevel
getlevel:
 li a7, SYS_getlevel
 9a8:	48f1                	li	a7,28
 ecall
 9aa:	00000073          	ecall
 ret
 9ae:	8082                	ret

00000000000009b0 <getmlfqinfo>:
.global getmlfqinfo
getmlfqinfo:
 li a7, SYS_getmlfqinfo
 9b0:	48f5                	li	a7,29
 ecall
 9b2:	00000073          	ecall
 ret
 9b6:	8082                	ret

00000000000009b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9b8:	1101                	addi	sp,sp,-32
 9ba:	ec06                	sd	ra,24(sp)
 9bc:	e822                	sd	s0,16(sp)
 9be:	1000                	addi	s0,sp,32
 9c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9c4:	4605                	li	a2,1
 9c6:	fef40593          	addi	a1,s0,-17
 9ca:	f2fff0ef          	jal	8f8 <write>
}
 9ce:	60e2                	ld	ra,24(sp)
 9d0:	6442                	ld	s0,16(sp)
 9d2:	6105                	addi	sp,sp,32
 9d4:	8082                	ret

00000000000009d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 9d6:	715d                	addi	sp,sp,-80
 9d8:	e486                	sd	ra,72(sp)
 9da:	e0a2                	sd	s0,64(sp)
 9dc:	f84a                	sd	s2,48(sp)
 9de:	f44e                	sd	s3,40(sp)
 9e0:	0880                	addi	s0,sp,80
 9e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 9e4:	c6d1                	beqz	a3,a70 <printint+0x9a>
 9e6:	0805d563          	bgez	a1,a70 <printint+0x9a>
    neg = 1;
    x = -xx;
 9ea:	40b005b3          	neg	a1,a1
    neg = 1;
 9ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 9f0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 9f4:	86ce                	mv	a3,s3
  i = 0;
 9f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 9f8:	00001817          	auipc	a6,0x1
 9fc:	d1080813          	addi	a6,a6,-752 # 1708 <digits>
 a00:	88ba                	mv	a7,a4
 a02:	0017051b          	addiw	a0,a4,1
 a06:	872a                	mv	a4,a0
 a08:	02c5f7b3          	remu	a5,a1,a2
 a0c:	97c2                	add	a5,a5,a6
 a0e:	0007c783          	lbu	a5,0(a5)
 a12:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a16:	87ae                	mv	a5,a1
 a18:	02c5d5b3          	divu	a1,a1,a2
 a1c:	0685                	addi	a3,a3,1
 a1e:	fec7f1e3          	bgeu	a5,a2,a00 <printint+0x2a>
  if(neg)
 a22:	00030c63          	beqz	t1,a3a <printint+0x64>
    buf[i++] = '-';
 a26:	fd050793          	addi	a5,a0,-48
 a2a:	00878533          	add	a0,a5,s0
 a2e:	02d00793          	li	a5,45
 a32:	fef50423          	sb	a5,-24(a0)
 a36:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 a3a:	02e05563          	blez	a4,a64 <printint+0x8e>
 a3e:	fc26                	sd	s1,56(sp)
 a40:	377d                	addiw	a4,a4,-1
 a42:	00e984b3          	add	s1,s3,a4
 a46:	19fd                	addi	s3,s3,-1
 a48:	99ba                	add	s3,s3,a4
 a4a:	1702                	slli	a4,a4,0x20
 a4c:	9301                	srli	a4,a4,0x20
 a4e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a52:	0004c583          	lbu	a1,0(s1)
 a56:	854a                	mv	a0,s2
 a58:	f61ff0ef          	jal	9b8 <putc>
  while(--i >= 0)
 a5c:	14fd                	addi	s1,s1,-1
 a5e:	ff349ae3          	bne	s1,s3,a52 <printint+0x7c>
 a62:	74e2                	ld	s1,56(sp)
}
 a64:	60a6                	ld	ra,72(sp)
 a66:	6406                	ld	s0,64(sp)
 a68:	7942                	ld	s2,48(sp)
 a6a:	79a2                	ld	s3,40(sp)
 a6c:	6161                	addi	sp,sp,80
 a6e:	8082                	ret
  neg = 0;
 a70:	4301                	li	t1,0
 a72:	bfbd                	j	9f0 <printint+0x1a>

0000000000000a74 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a74:	711d                	addi	sp,sp,-96
 a76:	ec86                	sd	ra,88(sp)
 a78:	e8a2                	sd	s0,80(sp)
 a7a:	e4a6                	sd	s1,72(sp)
 a7c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 a7e:	0005c483          	lbu	s1,0(a1)
 a82:	22048363          	beqz	s1,ca8 <vprintf+0x234>
 a86:	e0ca                	sd	s2,64(sp)
 a88:	fc4e                	sd	s3,56(sp)
 a8a:	f852                	sd	s4,48(sp)
 a8c:	f456                	sd	s5,40(sp)
 a8e:	f05a                	sd	s6,32(sp)
 a90:	ec5e                	sd	s7,24(sp)
 a92:	e862                	sd	s8,16(sp)
 a94:	8b2a                	mv	s6,a0
 a96:	8a2e                	mv	s4,a1
 a98:	8bb2                	mv	s7,a2
  state = 0;
 a9a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 a9c:	4901                	li	s2,0
 a9e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 aa0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 aa4:	06400c13          	li	s8,100
 aa8:	a00d                	j	aca <vprintf+0x56>
        putc(fd, c0);
 aaa:	85a6                	mv	a1,s1
 aac:	855a                	mv	a0,s6
 aae:	f0bff0ef          	jal	9b8 <putc>
 ab2:	a019                	j	ab8 <vprintf+0x44>
    } else if(state == '%'){
 ab4:	03598363          	beq	s3,s5,ada <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 ab8:	0019079b          	addiw	a5,s2,1
 abc:	893e                	mv	s2,a5
 abe:	873e                	mv	a4,a5
 ac0:	97d2                	add	a5,a5,s4
 ac2:	0007c483          	lbu	s1,0(a5)
 ac6:	1c048a63          	beqz	s1,c9a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 aca:	0004879b          	sext.w	a5,s1
    if(state == 0){
 ace:	fe0993e3          	bnez	s3,ab4 <vprintf+0x40>
      if(c0 == '%'){
 ad2:	fd579ce3          	bne	a5,s5,aaa <vprintf+0x36>
        state = '%';
 ad6:	89be                	mv	s3,a5
 ad8:	b7c5                	j	ab8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 ada:	00ea06b3          	add	a3,s4,a4
 ade:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 ae2:	1c060863          	beqz	a2,cb2 <vprintf+0x23e>
      if(c0 == 'd'){
 ae6:	03878763          	beq	a5,s8,b14 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 aea:	f9478693          	addi	a3,a5,-108
 aee:	0016b693          	seqz	a3,a3
 af2:	f9c60593          	addi	a1,a2,-100
 af6:	e99d                	bnez	a1,b2c <vprintf+0xb8>
 af8:	ca95                	beqz	a3,b2c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 afa:	008b8493          	addi	s1,s7,8
 afe:	4685                	li	a3,1
 b00:	4629                	li	a2,10
 b02:	000bb583          	ld	a1,0(s7)
 b06:	855a                	mv	a0,s6
 b08:	ecfff0ef          	jal	9d6 <printint>
        i += 1;
 b0c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 b0e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 b10:	4981                	li	s3,0
 b12:	b75d                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 b14:	008b8493          	addi	s1,s7,8
 b18:	4685                	li	a3,1
 b1a:	4629                	li	a2,10
 b1c:	000ba583          	lw	a1,0(s7)
 b20:	855a                	mv	a0,s6
 b22:	eb5ff0ef          	jal	9d6 <printint>
 b26:	8ba6                	mv	s7,s1
      state = 0;
 b28:	4981                	li	s3,0
 b2a:	b779                	j	ab8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 b2c:	9752                	add	a4,a4,s4
 b2e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 b32:	f9460713          	addi	a4,a2,-108
 b36:	00173713          	seqz	a4,a4
 b3a:	8f75                	and	a4,a4,a3
 b3c:	f9c58513          	addi	a0,a1,-100
 b40:	18051363          	bnez	a0,cc6 <vprintf+0x252>
 b44:	18070163          	beqz	a4,cc6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 b48:	008b8493          	addi	s1,s7,8
 b4c:	4685                	li	a3,1
 b4e:	4629                	li	a2,10
 b50:	000bb583          	ld	a1,0(s7)
 b54:	855a                	mv	a0,s6
 b56:	e81ff0ef          	jal	9d6 <printint>
        i += 2;
 b5a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 b5c:	8ba6                	mv	s7,s1
      state = 0;
 b5e:	4981                	li	s3,0
        i += 2;
 b60:	bfa1                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 b62:	008b8493          	addi	s1,s7,8
 b66:	4681                	li	a3,0
 b68:	4629                	li	a2,10
 b6a:	000be583          	lwu	a1,0(s7)
 b6e:	855a                	mv	a0,s6
 b70:	e67ff0ef          	jal	9d6 <printint>
 b74:	8ba6                	mv	s7,s1
      state = 0;
 b76:	4981                	li	s3,0
 b78:	b781                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b7a:	008b8493          	addi	s1,s7,8
 b7e:	4681                	li	a3,0
 b80:	4629                	li	a2,10
 b82:	000bb583          	ld	a1,0(s7)
 b86:	855a                	mv	a0,s6
 b88:	e4fff0ef          	jal	9d6 <printint>
        i += 1;
 b8c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 b8e:	8ba6                	mv	s7,s1
      state = 0;
 b90:	4981                	li	s3,0
 b92:	b71d                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b94:	008b8493          	addi	s1,s7,8
 b98:	4681                	li	a3,0
 b9a:	4629                	li	a2,10
 b9c:	000bb583          	ld	a1,0(s7)
 ba0:	855a                	mv	a0,s6
 ba2:	e35ff0ef          	jal	9d6 <printint>
        i += 2;
 ba6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 ba8:	8ba6                	mv	s7,s1
      state = 0;
 baa:	4981                	li	s3,0
        i += 2;
 bac:	b731                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 bae:	008b8493          	addi	s1,s7,8
 bb2:	4681                	li	a3,0
 bb4:	4641                	li	a2,16
 bb6:	000be583          	lwu	a1,0(s7)
 bba:	855a                	mv	a0,s6
 bbc:	e1bff0ef          	jal	9d6 <printint>
 bc0:	8ba6                	mv	s7,s1
      state = 0;
 bc2:	4981                	li	s3,0
 bc4:	bdd5                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 bc6:	008b8493          	addi	s1,s7,8
 bca:	4681                	li	a3,0
 bcc:	4641                	li	a2,16
 bce:	000bb583          	ld	a1,0(s7)
 bd2:	855a                	mv	a0,s6
 bd4:	e03ff0ef          	jal	9d6 <printint>
        i += 1;
 bd8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 bda:	8ba6                	mv	s7,s1
      state = 0;
 bdc:	4981                	li	s3,0
 bde:	bde9                	j	ab8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 be0:	008b8493          	addi	s1,s7,8
 be4:	4681                	li	a3,0
 be6:	4641                	li	a2,16
 be8:	000bb583          	ld	a1,0(s7)
 bec:	855a                	mv	a0,s6
 bee:	de9ff0ef          	jal	9d6 <printint>
        i += 2;
 bf2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 bf4:	8ba6                	mv	s7,s1
      state = 0;
 bf6:	4981                	li	s3,0
        i += 2;
 bf8:	b5c1                	j	ab8 <vprintf+0x44>
 bfa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 bfc:	008b8793          	addi	a5,s7,8
 c00:	8cbe                	mv	s9,a5
 c02:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 c06:	03000593          	li	a1,48
 c0a:	855a                	mv	a0,s6
 c0c:	dadff0ef          	jal	9b8 <putc>
  putc(fd, 'x');
 c10:	07800593          	li	a1,120
 c14:	855a                	mv	a0,s6
 c16:	da3ff0ef          	jal	9b8 <putc>
 c1a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c1c:	00001b97          	auipc	s7,0x1
 c20:	aecb8b93          	addi	s7,s7,-1300 # 1708 <digits>
 c24:	03c9d793          	srli	a5,s3,0x3c
 c28:	97de                	add	a5,a5,s7
 c2a:	0007c583          	lbu	a1,0(a5)
 c2e:	855a                	mv	a0,s6
 c30:	d89ff0ef          	jal	9b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 c34:	0992                	slli	s3,s3,0x4
 c36:	34fd                	addiw	s1,s1,-1
 c38:	f4f5                	bnez	s1,c24 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 c3a:	8be6                	mv	s7,s9
      state = 0;
 c3c:	4981                	li	s3,0
 c3e:	6ca2                	ld	s9,8(sp)
 c40:	bda5                	j	ab8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 c42:	008b8493          	addi	s1,s7,8
 c46:	000bc583          	lbu	a1,0(s7)
 c4a:	855a                	mv	a0,s6
 c4c:	d6dff0ef          	jal	9b8 <putc>
 c50:	8ba6                	mv	s7,s1
      state = 0;
 c52:	4981                	li	s3,0
 c54:	b595                	j	ab8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 c56:	008b8993          	addi	s3,s7,8
 c5a:	000bb483          	ld	s1,0(s7)
 c5e:	cc91                	beqz	s1,c7a <vprintf+0x206>
        for(; *s; s++)
 c60:	0004c583          	lbu	a1,0(s1)
 c64:	c985                	beqz	a1,c94 <vprintf+0x220>
          putc(fd, *s);
 c66:	855a                	mv	a0,s6
 c68:	d51ff0ef          	jal	9b8 <putc>
        for(; *s; s++)
 c6c:	0485                	addi	s1,s1,1
 c6e:	0004c583          	lbu	a1,0(s1)
 c72:	f9f5                	bnez	a1,c66 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 c74:	8bce                	mv	s7,s3
      state = 0;
 c76:	4981                	li	s3,0
 c78:	b581                	j	ab8 <vprintf+0x44>
          s = "(null)";
 c7a:	00001497          	auipc	s1,0x1
 c7e:	a8648493          	addi	s1,s1,-1402 # 1700 <malloc+0x8ea>
        for(; *s; s++)
 c82:	02800593          	li	a1,40
 c86:	b7c5                	j	c66 <vprintf+0x1f2>
        putc(fd, '%');
 c88:	85be                	mv	a1,a5
 c8a:	855a                	mv	a0,s6
 c8c:	d2dff0ef          	jal	9b8 <putc>
      state = 0;
 c90:	4981                	li	s3,0
 c92:	b51d                	j	ab8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 c94:	8bce                	mv	s7,s3
      state = 0;
 c96:	4981                	li	s3,0
 c98:	b505                	j	ab8 <vprintf+0x44>
 c9a:	6906                	ld	s2,64(sp)
 c9c:	79e2                	ld	s3,56(sp)
 c9e:	7a42                	ld	s4,48(sp)
 ca0:	7aa2                	ld	s5,40(sp)
 ca2:	7b02                	ld	s6,32(sp)
 ca4:	6be2                	ld	s7,24(sp)
 ca6:	6c42                	ld	s8,16(sp)
    }
  }
}
 ca8:	60e6                	ld	ra,88(sp)
 caa:	6446                	ld	s0,80(sp)
 cac:	64a6                	ld	s1,72(sp)
 cae:	6125                	addi	sp,sp,96
 cb0:	8082                	ret
      if(c0 == 'd'){
 cb2:	06400713          	li	a4,100
 cb6:	e4e78fe3          	beq	a5,a4,b14 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 cba:	f9478693          	addi	a3,a5,-108
 cbe:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 cc2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 cc4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 cc6:	07500513          	li	a0,117
 cca:	e8a78ce3          	beq	a5,a0,b62 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 cce:	f8b60513          	addi	a0,a2,-117
 cd2:	e119                	bnez	a0,cd8 <vprintf+0x264>
 cd4:	ea0693e3          	bnez	a3,b7a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 cd8:	f8b58513          	addi	a0,a1,-117
 cdc:	e119                	bnez	a0,ce2 <vprintf+0x26e>
 cde:	ea071be3          	bnez	a4,b94 <vprintf+0x120>
      } else if(c0 == 'x'){
 ce2:	07800513          	li	a0,120
 ce6:	eca784e3          	beq	a5,a0,bae <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 cea:	f8860613          	addi	a2,a2,-120
 cee:	e219                	bnez	a2,cf4 <vprintf+0x280>
 cf0:	ec069be3          	bnez	a3,bc6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 cf4:	f8858593          	addi	a1,a1,-120
 cf8:	e199                	bnez	a1,cfe <vprintf+0x28a>
 cfa:	ee0713e3          	bnez	a4,be0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 cfe:	07000713          	li	a4,112
 d02:	eee78ce3          	beq	a5,a4,bfa <vprintf+0x186>
      } else if(c0 == 'c'){
 d06:	06300713          	li	a4,99
 d0a:	f2e78ce3          	beq	a5,a4,c42 <vprintf+0x1ce>
      } else if(c0 == 's'){
 d0e:	07300713          	li	a4,115
 d12:	f4e782e3          	beq	a5,a4,c56 <vprintf+0x1e2>
      } else if(c0 == '%'){
 d16:	02500713          	li	a4,37
 d1a:	f6e787e3          	beq	a5,a4,c88 <vprintf+0x214>
        putc(fd, '%');
 d1e:	02500593          	li	a1,37
 d22:	855a                	mv	a0,s6
 d24:	c95ff0ef          	jal	9b8 <putc>
        putc(fd, c0);
 d28:	85a6                	mv	a1,s1
 d2a:	855a                	mv	a0,s6
 d2c:	c8dff0ef          	jal	9b8 <putc>
      state = 0;
 d30:	4981                	li	s3,0
 d32:	b359                	j	ab8 <vprintf+0x44>

0000000000000d34 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d34:	715d                	addi	sp,sp,-80
 d36:	ec06                	sd	ra,24(sp)
 d38:	e822                	sd	s0,16(sp)
 d3a:	1000                	addi	s0,sp,32
 d3c:	e010                	sd	a2,0(s0)
 d3e:	e414                	sd	a3,8(s0)
 d40:	e818                	sd	a4,16(s0)
 d42:	ec1c                	sd	a5,24(s0)
 d44:	03043023          	sd	a6,32(s0)
 d48:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d4c:	8622                	mv	a2,s0
 d4e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d52:	d23ff0ef          	jal	a74 <vprintf>
}
 d56:	60e2                	ld	ra,24(sp)
 d58:	6442                	ld	s0,16(sp)
 d5a:	6161                	addi	sp,sp,80
 d5c:	8082                	ret

0000000000000d5e <printf>:

void
printf(const char *fmt, ...)
{
 d5e:	711d                	addi	sp,sp,-96
 d60:	ec06                	sd	ra,24(sp)
 d62:	e822                	sd	s0,16(sp)
 d64:	1000                	addi	s0,sp,32
 d66:	e40c                	sd	a1,8(s0)
 d68:	e810                	sd	a2,16(s0)
 d6a:	ec14                	sd	a3,24(s0)
 d6c:	f018                	sd	a4,32(s0)
 d6e:	f41c                	sd	a5,40(s0)
 d70:	03043823          	sd	a6,48(s0)
 d74:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d78:	00840613          	addi	a2,s0,8
 d7c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d80:	85aa                	mv	a1,a0
 d82:	4505                	li	a0,1
 d84:	cf1ff0ef          	jal	a74 <vprintf>
}
 d88:	60e2                	ld	ra,24(sp)
 d8a:	6442                	ld	s0,16(sp)
 d8c:	6125                	addi	sp,sp,96
 d8e:	8082                	ret

0000000000000d90 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d90:	1141                	addi	sp,sp,-16
 d92:	e406                	sd	ra,8(sp)
 d94:	e022                	sd	s0,0(sp)
 d96:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d98:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d9c:	00001797          	auipc	a5,0x1
 da0:	2647b783          	ld	a5,612(a5) # 2000 <freep>
 da4:	a039                	j	db2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 da6:	6398                	ld	a4,0(a5)
 da8:	00e7e463          	bltu	a5,a4,db0 <free+0x20>
 dac:	00e6ea63          	bltu	a3,a4,dc0 <free+0x30>
{
 db0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 db2:	fed7fae3          	bgeu	a5,a3,da6 <free+0x16>
 db6:	6398                	ld	a4,0(a5)
 db8:	00e6e463          	bltu	a3,a4,dc0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dbc:	fee7eae3          	bltu	a5,a4,db0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 dc0:	ff852583          	lw	a1,-8(a0)
 dc4:	6390                	ld	a2,0(a5)
 dc6:	02059813          	slli	a6,a1,0x20
 dca:	01c85713          	srli	a4,a6,0x1c
 dce:	9736                	add	a4,a4,a3
 dd0:	02e60563          	beq	a2,a4,dfa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 dd4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 dd8:	4790                	lw	a2,8(a5)
 dda:	02061593          	slli	a1,a2,0x20
 dde:	01c5d713          	srli	a4,a1,0x1c
 de2:	973e                	add	a4,a4,a5
 de4:	02e68263          	beq	a3,a4,e08 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 de8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 dea:	00001717          	auipc	a4,0x1
 dee:	20f73b23          	sd	a5,534(a4) # 2000 <freep>
}
 df2:	60a2                	ld	ra,8(sp)
 df4:	6402                	ld	s0,0(sp)
 df6:	0141                	addi	sp,sp,16
 df8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 dfa:	4618                	lw	a4,8(a2)
 dfc:	9f2d                	addw	a4,a4,a1
 dfe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e02:	6398                	ld	a4,0(a5)
 e04:	6310                	ld	a2,0(a4)
 e06:	b7f9                	j	dd4 <free+0x44>
    p->s.size += bp->s.size;
 e08:	ff852703          	lw	a4,-8(a0)
 e0c:	9f31                	addw	a4,a4,a2
 e0e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 e10:	ff053683          	ld	a3,-16(a0)
 e14:	bfd1                	j	de8 <free+0x58>

0000000000000e16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e16:	7139                	addi	sp,sp,-64
 e18:	fc06                	sd	ra,56(sp)
 e1a:	f822                	sd	s0,48(sp)
 e1c:	f04a                	sd	s2,32(sp)
 e1e:	ec4e                	sd	s3,24(sp)
 e20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e22:	02051993          	slli	s3,a0,0x20
 e26:	0209d993          	srli	s3,s3,0x20
 e2a:	09bd                	addi	s3,s3,15
 e2c:	0049d993          	srli	s3,s3,0x4
 e30:	2985                	addiw	s3,s3,1
 e32:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 e34:	00001517          	auipc	a0,0x1
 e38:	1cc53503          	ld	a0,460(a0) # 2000 <freep>
 e3c:	c905                	beqz	a0,e6c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e40:	4798                	lw	a4,8(a5)
 e42:	09377663          	bgeu	a4,s3,ece <malloc+0xb8>
 e46:	f426                	sd	s1,40(sp)
 e48:	e852                	sd	s4,16(sp)
 e4a:	e456                	sd	s5,8(sp)
 e4c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 e4e:	8a4e                	mv	s4,s3
 e50:	6705                	lui	a4,0x1
 e52:	00e9f363          	bgeu	s3,a4,e58 <malloc+0x42>
 e56:	6a05                	lui	s4,0x1
 e58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e5c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e60:	00001497          	auipc	s1,0x1
 e64:	1a048493          	addi	s1,s1,416 # 2000 <freep>
  if(p == SBRK_ERROR)
 e68:	5afd                	li	s5,-1
 e6a:	a83d                	j	ea8 <malloc+0x92>
 e6c:	f426                	sd	s1,40(sp)
 e6e:	e852                	sd	s4,16(sp)
 e70:	e456                	sd	s5,8(sp)
 e72:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 e74:	00001797          	auipc	a5,0x1
 e78:	19c78793          	addi	a5,a5,412 # 2010 <base>
 e7c:	00001717          	auipc	a4,0x1
 e80:	18f73223          	sd	a5,388(a4) # 2000 <freep>
 e84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e86:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e8a:	b7d1                	j	e4e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 e8c:	6398                	ld	a4,0(a5)
 e8e:	e118                	sd	a4,0(a0)
 e90:	a899                	j	ee6 <malloc+0xd0>
  hp->s.size = nu;
 e92:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e96:	0541                	addi	a0,a0,16
 e98:	ef9ff0ef          	jal	d90 <free>
  return freep;
 e9c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 e9e:	c125                	beqz	a0,efe <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ea0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ea2:	4798                	lw	a4,8(a5)
 ea4:	03277163          	bgeu	a4,s2,ec6 <malloc+0xb0>
    if(p == freep)
 ea8:	6098                	ld	a4,0(s1)
 eaa:	853e                	mv	a0,a5
 eac:	fef71ae3          	bne	a4,a5,ea0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 eb0:	8552                	mv	a0,s4
 eb2:	9f3ff0ef          	jal	8a4 <sbrk>
  if(p == SBRK_ERROR)
 eb6:	fd551ee3          	bne	a0,s5,e92 <malloc+0x7c>
        return 0;
 eba:	4501                	li	a0,0
 ebc:	74a2                	ld	s1,40(sp)
 ebe:	6a42                	ld	s4,16(sp)
 ec0:	6aa2                	ld	s5,8(sp)
 ec2:	6b02                	ld	s6,0(sp)
 ec4:	a03d                	j	ef2 <malloc+0xdc>
 ec6:	74a2                	ld	s1,40(sp)
 ec8:	6a42                	ld	s4,16(sp)
 eca:	6aa2                	ld	s5,8(sp)
 ecc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ece:	fae90fe3          	beq	s2,a4,e8c <malloc+0x76>
        p->s.size -= nunits;
 ed2:	4137073b          	subw	a4,a4,s3
 ed6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ed8:	02071693          	slli	a3,a4,0x20
 edc:	01c6d713          	srli	a4,a3,0x1c
 ee0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ee2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ee6:	00001717          	auipc	a4,0x1
 eea:	10a73d23          	sd	a0,282(a4) # 2000 <freep>
      return (void*)(p + 1);
 eee:	01078513          	addi	a0,a5,16
  }
}
 ef2:	70e2                	ld	ra,56(sp)
 ef4:	7442                	ld	s0,48(sp)
 ef6:	7902                	ld	s2,32(sp)
 ef8:	69e2                	ld	s3,24(sp)
 efa:	6121                	addi	sp,sp,64
 efc:	8082                	ret
 efe:	74a2                	ld	s1,40(sp)
 f00:	6a42                	ld	s4,16(sp)
 f02:	6aa2                	ld	s5,8(sp)
 f04:	6b02                	ld	s6,0(sp)
 f06:	b7f5                	j	ef2 <malloc+0xdc>
