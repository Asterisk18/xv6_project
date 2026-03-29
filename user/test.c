#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define ASSERT(c, msg) if (!(c)) { \
    printf("FAILURE: %s (line %d)\n", msg, __LINE__); \
    exit(1); \
} else { \
    printf("PASSED: %s\n", msg); \
}

void error(char *msg) {
  printf("FAILURE: %s\n", msg);
  exit(1);
}

void test_getpid2(char *s) {
    printf("\nTesting getpid2...\n");

    if (hello() == 0) {
        printf("PASSED: hello() returned 0\n");
    } else {
        error("hello() returned non-zero");
    }

    int pid1 = getpid();
    int pid2 = getpid2();
    ASSERT(pid1 == pid2, "getpid2() matches standard getpid()");
}

void test_getnumchild(char *s) {
    printf("\nTesting getnumchild...\n");

    int parent_pid = getpid();
    int initial = getnumchild();
    printf("Initial children count: %d\n", initial); 
    
    int ret = fork();
    if (ret == 0) {
        int ppid = getppid();
        if (ppid == parent_pid) {
            printf("PASSED: Child correctly identified parent PID %d\n", ppid);
        } else {
            printf("FAILED: Child thought parent was %d, actual is %d\n", ppid, parent_pid);
            exit(1);
        }
        pause(10); // Keep child alive so parent can count it
        exit(0);
    } else {
        pause(5); // Wait for child to stabilize
        
        int new_count = getnumchild();
        ASSERT(new_count == initial + 1, "getnumchild() increments for active child");

        kill(ret);
        wait(0);

        ASSERT(getnumchild() == initial, "getnumchild() decrements after wait()");
    }
}

void test_zombie_invariant(char *s) {
    printf("\nTesting zombie invariant...\n");
    
    int pid = fork();
    if(pid == 0) {
        exit(0); // Immediately transition to ZOMBIE state
    }

    pause(10); // Ensure child has fully exited

    int nc = getnumchild();
    if(nc != 0) {
        printf("getnumchild returned %d\n", nc);
        error("Zombie process was incorrectly counted as alive");
    } else {
        printf("PASSED: Zombie process correctly ignored\n");
    }

    wait(0);
}

void test_adoption(char *s) {
    printf("\nTesting adoption...\n");

    int pid = fork();
    if(pid < 0) error("fork failed");

    if(pid == 0){
        int pid2 = fork();
        if(pid2 < 0) error("fork failed");
        
        if(pid2 == 0) {
            pause(10); // Wait for parent to exit so reparenting happens
            
            int new_pp = getppid();
            if(new_pp != 1) {
                printf("Expected parent 1 (init), got %d\n", new_pp);
                error("Adoption failed: getppid() did not update to 1");
            } else {
                printf("PASSED: Orphan correctly adopted by init\n");
            }
            exit(0);
        }
        else
            pause(5); // Let grandchild start before parent exits
        
        exit(0);
    }

    wait(0);
    pause(15); // Wait for grandchild verification logic
}

void test_syscount(char *s) {
    printf("\nTesting syscount...\n");

    int start = getsyscount();
    getpid(); getpid(); getpid();
    int end = getsyscount();
    
    // Expect +4 because getsyscount() itself is a syscall
    if (end >= start + 4) {
        printf("PASSED: getsyscount() tracks local syscalls (Diff: %d)\n", end - start);
    } else {
        error("getsyscount() failed to track local calls");
    }

    if(getchildsyscount(1) == -1 && getchildsyscount(99999) == -1) {
        printf("PASSED: getchildsyscount() handles invalid/non-child PIDs\n");
    } else {
        error("getchildsyscount() did not return -1 for invalid PIDs");
    }
}

void test_isolation(char *s) {
    printf("\nTesting isolation...\n");

    int p1 = fork();
    if(p1 == 0) {
        pause(100);
        exit(0);
    }

    int p2 = fork();
    if(p2 == 0) {
        int count = getchildsyscount(p1); // Should fail: p1 is a sibling, not a child
        if(count != -1) {
           printf("Sibling 2 read stats of Sibling 1 (PID %d) -> %d\n", p1, count);
           error("Privacy violation: getchildsyscount allowed reading non-child");
        } else {
            printf("PASSED: Sibling blocked from reading non-child stats\n");
        }
        exit(0);
    }

    int status;
    wait(&status);
    wait(&status);
    kill(p1);
    wait(0);
}

void test_stress_count(char *s) {
    printf("\nTesting High-Volume Syscall Stress...\n");

    int start = getsyscount();
    int LOOPS = 5000;
    
    for(int i = 0; i < LOOPS; i++) {
        getpid();
    }

    int end = getsyscount();
    int actual = end - start;
    
    if(actual < LOOPS) {
        printf("Expected > %d syscalls, counted %d\n", LOOPS, actual);
        error("Syscall accounting missed events under stress");
    } else {
        printf("PASSED: Accounted %d calls correctly under stress\n", actual);
    }
}

void test_concurrent_children(char *s) {
    printf("\nTesting Multiple Concurrent Children...\n");
    
    int children_pids[5];
    int i;

    for(i = 0; i < 5; i++) {
        int pid = fork();
        if(pid == 0) {
            for(int j = 0; j < 50; j++) getpid(); 
            pause(20);
            exit(0);
        }
        children_pids[i] = pid;
    }

    pause(5); // Ensure all children are active

    int active_children = getnumchild();
    if (active_children < 5) {
        error("getnumchild() failed to count all concurrent children");
    }
    printf("PASSED: Detected %d active concurrent children\n", active_children);

    int count = getchildsyscount(children_pids[2]);
    if (count < 50) {
        error("getchildsyscount() read invalid stats from concurrent child");
    }
    printf("PASSED: Concurrent child stats read successfully (%d)\n", count);

    for(i = 0; i < 5; i++) kill(children_pids[i]);
    for(i = 0; i < 5; i++) wait(0);
}

void run_test(void (*func)(char *), char *name) {
    int pid, xstatus;
    
    // Fork each test to isolate crashes
    pid = fork();
    if(pid < 0) {
        printf("fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
        func(name);
        exit(0);
    } else {
        wait(&xstatus);
        if(xstatus != 0) {
            printf("\n>>> FAILED: %s <<<\n\n", name);
            exit(1);
        }
    }
}

int main(int argc, char *argv[]) {
    printf("running testing script\n");
    
    run_test(test_getpid2,            "Testing getpid2");
    run_test(test_getnumchild,     "Testing getnumchild");
    run_test(test_syscount,     "Testing syscount");
    
    run_test(test_zombie_invariant, "Testing Zombie Invariant");
    run_test(test_adoption,         "Testing Orphan Adoption");
    run_test(test_isolation,        "Testing Security/Isolation");
    
    run_test(test_stress_count,     "Testing locking discpline: Stress Test");
    run_test(test_concurrent_children, "Testing locking discpline: Multi-Process");

    printf("\nALL TESTS PASSED SUCCESSFULLY.\n");
    exit(0);
}