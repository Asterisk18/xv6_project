#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NLEVEL 4

struct mlfqinfo {
  int level; 
  int ticks[NLEVEL]; 
  int times_scheduled; 
  int total_syscalls; 
};

void print_stats(char *workload_type, int turnaround_time) {
    struct mlfqinfo info;
    if(getmlfqinfo(getpid(), &info) == 0) {
        printf("\n========================================\n");
        printf("Workload: %s (PID: %d)\n", workload_type, getpid());
        printf("Turnaround Time   : %d ticks\n", turnaround_time);
        printf("Final Queue Level : %d\n", info.level);
        printf("Ticks per Level   : [L0: %d, L1: %d, L2: %d, L3: %d]\n", 
               info.ticks[0], info.ticks[1], info.ticks[2], info.ticks[3]);
        printf("Times Scheduled   : %d\n", info.times_scheduled);
        printf("Total Syscalls    : %d\n", info.total_syscalls);
        printf("========================================\n");
    } else {
        printf("Error fetching info for PID %d\n", getpid());
    }
}

// CPU bound processes. It only has computation, no syscall or memread
void cpu_bound_task() {
    int start_time = uptime();
    volatile int counter = 0;
    for(int j = 0; j < 30; j++) {
        for(int i = 0; i < 200000000; i++) counter++; 
    }
    print_stats("CPU-Bound", uptime() - start_time);
    exit(0);
}

// Interactive, high syscall process
void interactive_task() {
    int start_time = uptime();
    for(int i = 0; i < 100000; i++) {
        getpid(); 
    }
    print_stats("Interactive (Syscall-Heavy)", uptime() - start_time);
    exit(0);
}

// mixed process, first CPU heavy then interactive
void mixed_task_cpu_first() {
    int start_time = uptime();
    volatile int counter = 0;
    for(int j = 0; j < 15; j++) {
        for(int i = 0; i < 200000000; i++) counter++;
    }
    for(int i = 0; i < 50000; i++) getpid();
    print_stats("Mixed (CPU then IO)", uptime() - start_time);
    exit(0);
}

// mixed process, first interactive then CPU heavy
void mixed_task_io_first() {
    int start_time = uptime();
    volatile int counter = 0;
    
    for(int i = 0; i < 50000; i++) getpid(); 
    
    for(int j = 0; j < 15; j++) {  
        for(int i = 0; i < 200000000; i++) counter++;
    }
    print_stats("Mixed (IO then CPU)", uptime() - start_time);
    exit(0);
}

// voluntary yeilding processes
void sleeping_task() {
    int start_time = uptime();
    for(int i = 0; i < 20; i++) {
        pause(1); // voluntarily give up CPU
    }
    print_stats("Voluntary Yielder (Sleep)", uptime() - start_time);
    exit(0);
}

int main() {
    printf("\n--- Starting SC-MLFQ Comprehensive Benchmark ---\n");

    if(fork() == 0) cpu_bound_task();
    if(fork() == 0) cpu_bound_task();
    
    if(fork() == 0) interactive_task();
    if(fork() == 0) interactive_task();
    
    if(fork() == 0) mixed_task_cpu_first();
    if(fork() == 0) mixed_task_io_first();
    
    if(fork() == 0) sleeping_task();

    // Parent waits for all 7 children to finish
    for(int i = 0; i < 7; i++) {
        wait(0);
    }

    printf("\n--- All Benchmarks Completed ---\n");
    exit(0);
}