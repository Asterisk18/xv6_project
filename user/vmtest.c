#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

struct vmstats {
  int page_faults;
  int pages_evicted;
  int pages_swapped_in;
  int pages_swapped_out;
  int resident_pages;
};

int main() {
    printf("--- Starting PA3 VM Stress Test ---\n");
    
    int num_children = 4;
    int alloc_size = 35 * 1024 * 1024; // 35 MB per child -> 140MB total (Exceeds 128MB RAM)

    for (int i = 0; i < num_children; i++) {
        int pid = fork();
        if (pid == 0) {
            // ----- CHILD PROCESS -----
            int mypid = getpid();
            
            // 1. DROP MLFQ PRIORITY
            // We do a heavy CPU loop so your PA2 scheduler demotes this process to Level 2 or 3.
            // This proves the "Scheduler-Aware" PA3 requirement!
            for(volatile int j = 0; j < 50000000; j++); 
            
            printf("[Child %d] Priority Level is now: %d. Starting allocation...\n", mypid, getlevel());

            // 2. LAZY ALLOCATION
            char *mem = sbrk(alloc_size);
            if (mem == (char*)-1) {
                printf("[Child %d] sbrk failed!\n", mypid);
                exit(1);
            }

            // 3. FORCE PAGE FAULTS (WRITE)
            // Touching every page forces vmfault() to allocate physical frames.
            // Eventually, memory will fill up, and kalloc() will start evicting!
            for (int k = 0; k < alloc_size; k += 4096) {
                mem[k] = 'A' + i;
            }
            
            printf("[Child %d] Finished writing. Now reading back to trigger swap-ins...\n", mypid);

            // 4. FORCE SWAP-INS (READ)
            // If this process had pages evicted to swap, reading them will cause a page fault
            // and force vmfault() to bring them back from the swap_space array.
            int dummy_sum = 0;
            for (int k = 0; k < alloc_size; k += 4096) {
                dummy_sum += mem[k];
            }

            // 5. FETCH AND PRINT PA3 STATISTICS
            struct vmstats st;
            if(getvmstats(mypid, &st) == 0) {
                printf("\n--- STATS FOR PID %d (Level %d) ---\n", mypid, getlevel());
                printf("Page Faults:       %d\n", st.page_faults);
                printf("Pages Evicted:     %d\n", st.pages_evicted);
                printf("Pages Swapped Out: %d\n", st.pages_swapped_out);
                printf("Pages Swapped In:  %d\n", st.pages_swapped_in);
                printf("Resident Pages:    %d\n", st.resident_pages);
                printf("----------------------------------\n\n");
            }

            exit(0);
        }
    }

    // ----- PARENT PROCESS -----
    // Wait for all children to finish their memory chaos
    for (int i = 0; i < num_children; i++) {
        wait(0);
    }

    printf("--- VM Stress Test Complete ---\n");
    exit(0);
}