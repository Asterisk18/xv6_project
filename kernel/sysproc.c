#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) { // eagerly allocate memory
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// kills the current process
uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


// a
uint64
sys_hello(void)
{
  printf("Hello from the kernel!\n");
  return 0;
}

uint64
sys_getpid2(void)
{
  return myproc()->pid;
}

// since we want to use this lock from the global scope and update it here,
// but dont want to make a seperate header for this
extern struct spinlock wait_lock;
extern struct proc proc[NPROC];

uint64
sys_getppid(void)
{
  struct proc* p = myproc();
  int ppid;

  acquire(&wait_lock);
  if(p->parent){
    ppid = p->parent->pid;
  }
  else{
    ppid = -1;
  }
  release(&wait_lock);

  return ppid;
}

uint64
sys_getnumchild(void)
{
  struct proc* p = myproc();
  int count = 0;
  struct proc* it;

  // in parent-child iteration, always lock before starting the loop. 
  // This things mitigates the possibility of parent/child state changing while current function is running
  acquire(&wait_lock); 

  for(it = proc; it < &proc[NPROC]; it++){
    if(it->parent == p && it->state != ZOMBIE){
      count++;
    }
  }

  release(&wait_lock);

  return count;
}

uint64
sys_getsyscount(void)
{
  struct proc* p = myproc();
  int syscount;

  // since the syscount value is not changed or read 
  // by anyother process other that the one which it belongs to, 
  // hence we dont need to employ locks here
  if(p) syscount = p->syscount;
  else syscount = -1;

  return syscount;
}

uint64
sys_getchildsyscount(void)
{
  int pid;
  argint(0, &pid);

  struct proc* p = myproc();
  struct proc* it;
  int syscount = -1;

  acquire(&wait_lock);
  for(it=proc; it<&proc[NPROC]; it++){
    if(it->parent == p && it->pid == pid){ // we are considering zombie children also
      
      acquire(&it->lock);
      syscount = it->syscount;
      release(&it->lock);
      break;
    }
  }
  release(&wait_lock);

  return syscount;
}

uint64
sys_getlevel(void)
{
  struct proc * p = myproc();
  return p->level;
}

uint64
sys_getmlfqinfo(void)
{
  int pid;
  uint64 mlfq_ptr;
  argint(0, &pid);
  argaddr(1, &mlfq_ptr);

  struct proc* it;
  for(it = proc; it<&proc[NPROC]; it++){

    acquire(&it->lock);
    if(it->pid == pid  && it->state != UNUSED){
      struct mlfqinfo info;
      info.level = it->level;
      info.total_syscalls = it->syscount;
      for(int i=0;i<NLEVEL;i++) info.ticks[i] = it->ticks[i];
      info.times_scheduled = it->times_scheduled;

      release(&it->lock);
      return copyout(myproc()->pagetable ,mlfq_ptr, (char*)&info, sizeof(struct mlfqinfo));
    }
    release(&it->lock);
  }

  return -1; // process with given pid not found
}