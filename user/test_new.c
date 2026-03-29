// #include "kernel/types.h"
// #include "user/user.h"

// int
// main()
// {
//     printf("---- BASIC TEST ----\n");

//     hello();

//     int pid1 = getpid();
//     int pid2 = getpid2();

//     if(pid1 == pid2)
//         printf("getpid2() correct\n");
//     else
//         printf("getpid2() WRONG\n");

//     int ppid = getppid();
//     printf("PID: %d  PPID: %d\n", pid1, ppid);

//     exit(0);
// }



// #include "kernel/types.h"
// #include "user/user.h"

// int
// main()
// {
//     printf("---- CHILD TEST ----\n");

//     // int parent = getpid();

//     int pid1 = fork();
//     if(pid1 == 0){
//         pause(10);
//         exit(0);
//     }

//     int pid2 = fork();
//     if(pid2 == 0){
//         pause(20);
//         exit(0);
//     }

//     pause(5);

//     int n = getnumchild();
//     printf("Number of children (expected 2): %d\n", n);

//     int sc = getchildsyscount(pid1);
//     printf("Child syscall count (valid child): %d\n", sc);

//     int invalid = getchildsyscount(9999);
//     printf("Invalid child syscall (expected -1): %d\n", invalid);

//     wait(0);
//     wait(0);

//     int n2 = getnumchild();
//     printf("Number of children after wait (expected 0): %d\n", n2);

//     exit(0);
// }

// #include "kernel/types.h"
// #include "user/user.h"

// int
// main()
// {
//     printf("---- SYSCALL COUNT TEST ----\n");

//     int before = getsyscount();
//     printf("Initial syscall count: %d\n", before);

//     // Make known number of syscalls
//     getpid();
//     getpid();
//     pause(1);
//     getpid();

//     int after = getsyscount();
//     printf("After syscalls: %d\n", after);

//     if(after >= before + 4)
//         printf("Syscall counter working\n");
//     else
//         printf("Syscall counter WRONG\n");

//     exit(0);
// }

// #include "kernel/types.h"
// #include "user/user.h"

// int
// main()
// {
//     printf("---- FORK SYSCALL TEST ----\n");

//     int pid = fork();

//     if(pid == 0){
//         int c = getsyscount();
//         printf("Child syscall count: %d\n", c);
//         exit(0);
//     }
//     else{
//         wait(0);
//         int p = getsyscount();
//         printf("Parent syscall count: %d\n", p);
//     }

//     exit(0);
// }






#include "kernel/types.h"
#include "user/user.h"

void basic_test(){
    printf("---- BASIC TEST ----\n");

    hello();

    int pid1 = getpid();
    int pid2 = getpid2();

    if(pid1 == pid2)
        printf("getpid2() correct\n");
    else
        printf("getpid2() WRONG\n");

    int ppid = getppid();
    printf("PID: %d  PPID: %d\n", pid1, ppid);

    // exit(0);
    return;
}

void test_child(){
    printf("---- CHILD TEST ----\n");

    // int parent = getpid();

    int pid1 = fork();
    if(pid1 == 0){
        pause(10);
        exit(0);
    }

    int pid2 = fork();
    if(pid2 == 0){
        pause(20);
        exit(0);
    }

    pause(5);

    int n = getnumchild();
    printf("Number of children (expected 2): %d\n", n);

    int sc = getchildsyscount(pid1);
    printf("Child syscall count (valid child): %d\n", sc);

    int invalid = getchildsyscount(9999);
    printf("Invalid child syscall (expected -1): %d\n", invalid);

    wait(0);
    wait(0);

    int n2 = getnumchild();
    printf("Number of children after wait (expected 0): %d\n", n2);

    // exit(0);
    return;
}

void test_fork(){
    printf("---- FORK SYSCALL TEST ----\n");

    int pid = fork();

    if(pid == 0){
        printf("hello\n");
        int c = getsyscount();
        printf("Child syscall count: %d\n", c);
        exit(0);
    }
    else{
        wait(0);
        int p = getsyscount();
        printf("Parent syscall count: %d\n", p);
    }

    // exit(0);
    return;
}

void test_syscallcount(){
    printf("---- SYSCALL COUNT TEST ----\n");

    int before = getsyscount();
    printf("Initial syscall count: %d\n", before);

    // Make known number of syscalls
    getpid();
    getpid();
    pause(1);
    getpid();

    int after = getsyscount();
    printf("After syscalls: %d\n", after);

    if(after >= before + 4)
        printf("Syscall counter working\n");
    else
        printf("Syscall counter WRONG\n");

    // exit(0);
    return;
}

int
main()
{
    // basic_test();
    // test_child();
    test_fork();
    // test_syscallcount();

}