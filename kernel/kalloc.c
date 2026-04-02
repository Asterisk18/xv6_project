// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

// a
#include "proc.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

// a
static int clock_ptr = 0;

// Frame table declared in the same scope as page table, as they get used together only
struct frame{
  int currently_used;
  struct proc* p;
  uint64 va;
  int reference_bit;
}; 

struct spinlock frametablelock;
struct frame frame_table[(PHYSTOP-KERNBASE)/PGSIZE];

void init_frametable(){
  initlock(&frametablelock, "frametable");
  for(int i = 0; i < (PHYSTOP-KERNBASE)/PGSIZE; i++){
    frame_table[i].currently_used = 0;
    frame_table[i].p = 0;
    frame_table[i].va = 0;
    frame_table[i].reference_bit = 0;
  }
}

// swap space
// #define MAX_SWAP_PAGES 1024

struct spinlock swaplock;
char swap_space[MAX_SWAP_PAGES][PGSIZE];
int swap_slots_free[MAX_SWAP_PAGES]; // 1 = free, 0 = used


void init_swap(){
  initlock(&swaplock, "swap");
  for(int i=0;i<MAX_SWAP_PAGES;i++) swap_slots_free[i] = 1;

}


// swap page in the memory
void swap_in(){
  
}

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
  init_frametable(); // sets up the frame table
  init_swap(); // initialise swap
}

// it initialises our main memory by repeatadly calling 
// kfree() which allocates and adds a new page everytime
// thus the initial freelist of all pages is created
void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");


  uint64 pa_page = ((uint64)pa - KERNBASE) / PGSIZE;
  if((uint64)pa >= KERNBASE && (uint64)pa < PHYSTOP) { // pa is in allowed memory
    acquire(&frametablelock);
    if(frame_table[pa_page].p != 0) {
      frame_table[pa_page].p->resident_pages--; // update process stats
    }
    release(&frametablelock);
  }


  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;
  
  //adding new address at the start of free list
  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r==0){ // no free space, swap out a page
    int level = -1;
    struct frame* selected = 0;
    int passes = 0;

    while(1) { // it loops until it finds a victim
      // checking p!=0 as kernel initial booting will also have page entries in the memory, 
      // but these entries wont have a process(null). p->pagetable, gives null pointer dereferencing error 
      if(frame_table[clock_ptr].currently_used && frame_table[clock_ptr].p != 0){
        pte_t* pte = walk(frame_table[clock_ptr].p->pagetable, frame_table[clock_ptr].va, 0);
        if(*pte & PTE_A) { // if access bit 1, make it 0
          *pte &= ~PTE_A;
        } 
        else { // selecting for victim, look at level also
          if(frame_table[clock_ptr].p->level > level){
            level = frame_table[clock_ptr].p->level;
            selected = &frame_table[clock_ptr];

            if(passes){ // if its the second pass, directly select the first appearing page
              break;
            }
          }
        }
      }
      clock_ptr = (clock_ptr + 1) % ((PHYSTOP-KERNBASE)/PGSIZE);

      if(clock_ptr == 0) {
        if(level>=2){ // if process in last two queue, remove that page
          break;
        }
        passes++;
        level = -1;
      }

      if(passes>7){ //if multiple passes, then no possible eviction possible, all are kernel pages
        // panic("out of memory, no eviction posiible");
        return 0; // returning 0 to vmfault() automatically kills some process to free space
      }

    }

    // page pointed by 'selected' is our victim
    int i=0; // will point to frame in swap
    acquire(&swaplock);
    for(;i<MAX_SWAP_PAGES;i++){
      if(swap_slots_free[i]) {
        swap_slots_free[i] = 0; // swap frame not free anymore
        break;
      }
    }
    release(&swaplock);

    if(i==MAX_SWAP_PAGES){ // swap space full, kill some process

    }


    pte_t* pte = walk(selected->p->pagetable, selected->va, 0);
    uint64 pa = PTE2PA(*pte); // this is the address of page being freed

    memmove(swap_space[i], (void*)pa, PGSIZE); // moving the page data to swap

    // *pte = 0; // removing the entry from Page table
    *pte &= ~PTE_V; // set valid bit 0 
    *pte |= PTE_S; // set swap bit 1, i.e. the page is in swap space
    *pte = ((*pte & 0x3ff) | (i<<10)); // adding swap frame index to pte

    // removing frametable entry
    acquire(&frametablelock);
    frame_table[(uint64)pa].currently_used = 0;
    frame_table[(uint64)pa].p = 0;
    frame_table[(uint64)pa].reference_bit = 0;
    frame_table[(uint64)pa].va = 0;
    release(&frametablelock);


    // updating process stats
    myproc()->pages_evicted++;
    myproc()->pages_swapped_out++;
    myproc()->resident_pages--;

    r = (struct run*)pa; // returning pa of the freed page to the process which asked for space

  }

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}