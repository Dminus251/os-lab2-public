#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "debug.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_exit2(void) 
{
  //struct proc *curproc = myproc();
  int status;

  argint(0, &status);
   
  exit2(status); 
  return 0; //eax에 리턴해야하니까
}  

int
sys_wait(void)
{
  return wait();
}


//********************************
//*********new sys_waiat**********
//********************************

int
sys_wait2(int *status)
{



  // argptr() 함수를 사용하여 첫 번째 인자(인덱스 0)로 전달된
  // 사용자 공간 포인터의 유효성을 검증하고, 해당 포인터를 가져옵니다.
  if(argptr(0, (void*)&status, sizeof(*status)) < 0)
    return -1;  // 인자가 유효하지 않은 경우, 에러 코드를 반환합니다.

  // wait2() 함수를 호출하고, 자식 프로세스의 종료 상태를
  // 사용자 공간의 status 포인터가 가리키는 곳에 저장합니다.
  return wait2(status);}

//********************************
//*********new sys_waiat**********
//********************************


int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
