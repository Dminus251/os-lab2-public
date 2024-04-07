
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
80100010:	66 b8 10 00          	mov    $0x10,%ax
80100014:	8e d8                	mov    %eax,%ds
80100016:	8e c0                	mov    %eax,%es
80100018:	8e d0                	mov    %eax,%ss
8010001a:	66 b8 00 00          	mov    $0x0,%ax
8010001e:	8e e0                	mov    %eax,%fs
80100020:	8e e8                	mov    %eax,%gs
80100022:	0f 20 c0             	mov    %cr0,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
8010002a:	0f 22 c0             	mov    %eax,%cr0
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
80100032:	0f 22 d8             	mov    %eax,%cr3
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
8010003a:	0f 32                	rdmsr  
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
80100041:	0f 30                	wrmsr  
80100043:	0f 20 e0             	mov    %cr4,%eax
80100046:	83 c8 10             	or     $0x10,%eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
8010004c:	0f 22 e0             	mov    %eax,%cr4
8010004f:	0f 20 c0             	mov    %cr0,%eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
80100057:	0f 22 c0             	mov    %eax,%cr0
8010005a:	bc 80 80 19 80       	mov    $0x80198080,%esp
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 80 a2 10 80       	push   $0x8010a280
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 fd 48 00 00       	call   8010497b <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 87 a2 10 80       	push   $0x8010a287
801000c2:	50                   	push   %eax
801000c3:	e8 56 47 00 00       	call   8010481e <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 97 48 00 00       	call   8010499d <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 c6 48 00 00       	call   80104a0b <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 03 47 00 00       	call   8010485a <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 45 48 00 00       	call   80104a0b <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 82 46 00 00       	call   8010485a <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 8e a2 10 80       	push   $0x8010a28e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 5a 9f 00 00       	call   8010a18c <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 bd 46 00 00       	call   8010490c <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a2 10 80       	push   $0x8010a29f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 0f 9f 00 00       	call   8010a18c <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 74 46 00 00       	call   8010490c <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a2 10 80       	push   $0x8010a2a6
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 03 46 00 00       	call   801048be <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 d2 46 00 00       	call   8010499d <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 d0 46 00 00       	call   80104a0b <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 88 45 00 00       	call   8010499d <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 ad a2 10 80       	push   $0x8010a2ad
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec b6 a2 10 80 	movl   $0x8010a2b6,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 68 44 00 00       	call   80104a0b <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 bd a2 10 80       	push   $0x8010a2bd
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 d1 a2 10 80       	push   $0x8010a2d1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 5a 44 00 00       	call   80104a5d <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 d3 a2 10 80       	push   $0x8010a2d3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 3e 7a 00 00       	call   801080e3 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 eb 79 00 00       	call   801080e3 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 f2 79 00 00       	call   8010814e <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 c2 5d 00 00       	call   8010655a <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 b5 5d 00 00       	call   8010655a <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 a8 5d 00 00       	call   8010655a <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 98 5d 00 00       	call   8010655a <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 ad 41 00 00       	call   8010499d <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 25 3d 00 00       	call   80104669 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 a4 40 00 00       	call   80104a0b <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 af 3d 00 00       	call   80104724 <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 fe 3f 00 00       	call   8010499d <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 4b 40 00 00       	call   80104a0b <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 95 3b 00 00       	call   80104582 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 a0 3f 00 00       	call   80104a0b <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 f6 3e 00 00       	call   8010499d <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 22 3f 00 00       	call   80104a0b <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 d7 a2 10 80       	push   $0x8010a2d7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 5a 3e 00 00       	call   8010497b <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 df a2 10 80 	movl   $0x8010a2df,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 f5 a2 10 80       	push   $0x8010a2f5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 40 69 00 00       	call   80107556 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 93 6c 00 00       	call   8010794f <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 80 6b 00 00       	call   80107882 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 de 6b 00 00       	call   8010794f <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 1c 6e 00 00       	call   80107bb1 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 93 40 00 00       	call   80104e61 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 66 40 00 00       	call   80104e61 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 2f 6f 00 00       	call   80107d50 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 93 6e 00 00       	call   80107d50 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 0b 3f 00 00       	call   80104e16 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 25 67 00 00       	call   80107673 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 bc 6b 00 00       	call   80107b18 <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 7c 6b 00 00       	call   80107b18 <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 01 a3 10 80       	push   $0x8010a301
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 a4 39 00 00       	call   8010497b <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 ad 39 00 00       	call   8010499d <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 ee 39 00 00       	call   80104a0b <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 cb 39 00 00       	call   80104a0b <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 40 39 00 00       	call   8010499d <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 08 a3 10 80       	push   $0x8010a308
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 78 39 00 00       	call   80104a0b <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 ef 38 00 00       	call   8010499d <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 10 a3 10 80       	push   $0x8010a310
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 1d 39 00 00       	call   80104a0b <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 cf 38 00 00       	call   80104a0b <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 1a a3 10 80       	push   $0x8010a31a
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 23 a3 10 80       	push   $0x8010a323
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 33 a3 10 80       	push   $0x8010a333
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 d6 38 00 00       	call   80104cd2 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 d1 37 00 00       	call   80104c13 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 40 a3 10 80       	push   $0x8010a340
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 56 a3 10 80       	push   $0x8010a356
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 69 a3 10 80       	push   $0x8010a369
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 e1 32 00 00       	call   8010497b <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 70 a3 10 80       	push   $0x8010a370
801016c6:	50                   	push   %eax
801016c7:	e8 52 31 00 00       	call   8010481e <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 78 a3 10 80       	push   $0x8010a378
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 75 34 00 00       	call   80104c13 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 cb a3 10 80       	push   $0x8010a3cb
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 26 34 00 00       	call   80104cd2 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 bc 30 00 00       	call   8010499d <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 dc 30 00 00       	call   80104a0b <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 dd a3 10 80       	push   $0x8010a3dd
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 63 30 00 00       	call   80104a0b <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 da 2f 00 00       	call   8010499d <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 29 30 00 00       	call   80104a0b <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 ed a3 10 80       	push   $0x8010a3ed
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 3e 2e 00 00       	call   8010485a <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 0c 32 00 00       	call   80104cd2 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 f3 a3 10 80       	push   $0x8010a3f3
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 f4 2d 00 00       	call   8010490c <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 02 a4 10 80       	push   $0x8010a402
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 79 2d 00 00       	call   801048be <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 fa 2c 00 00       	call   8010485a <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 17 2e 00 00       	call   8010499d <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 6c 2e 00 00       	call   80104a0b <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 d8 2c 00 00       	call   801048be <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 a7 2d 00 00       	call   8010499d <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 f6 2d 00 00       	call   80104a0b <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 0a a4 10 80       	push   $0x8010a40a
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 db 2c 00 00       	call   80104cd2 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 8b 2b 00 00       	call   80104cd2 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 a1 2b 00 00       	call   80104d68 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 1d a4 10 80       	push   $0x8010a41d
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 2f a4 10 80       	push   $0x8010a42f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 3e a4 10 80       	push   $0x8010a43e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 98 2a 00 00       	call   80104dbe <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 4b a4 10 80       	push   $0x8010a44b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 0e 29 00 00       	call   80104cd2 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 f7 28 00 00       	call   80104cd2 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 54 a4 10 80       	push   $0x8010a454
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 86 a4 10 80       	push   $0x8010a486
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 f8 22 00 00       	call   8010497b <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 8b a4 10 80       	push   $0x8010a48b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 c4 24 00 00       	call   80104c13 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 35 22 00 00       	call   8010499d <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 71 22 00 00       	call   80104a0b <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 e1 21 00 00       	call   8010499d <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 1e 22 00 00       	call   80104a0b <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 63 1f 00 00       	call   80104c7a <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 91 a4 10 80       	push   $0x8010a491
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 46 1b 00 00       	call   8010497b <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 f2 1d 00 00       	call   80104cd2 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 4e 19 00 00       	call   8010499d <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 15 15 00 00       	call   80104582 <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 e0 14 00 00       	call   80104582 <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 4a 19 00 00       	call   80104a0b <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 bb 18 00 00       	call   8010499d <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 95 a4 10 80       	push   $0x8010a495
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 38 15 00 00       	call   80104669 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 ca 18 00 00       	call   80104a0b <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 41 18 00 00       	call   8010499d <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 f3 14 00 00       	call   80104669 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 85 18 00 00       	call   80104a0b <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 d0 1a 00 00       	call   80104cd2 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 a4 a4 10 80       	push   $0x8010a4a4
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 ba a4 10 80       	push   $0x8010a4ba
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 d6 16 00 00       	call   8010499d <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 c6 16 00 00       	call   80104a0b <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 ad 4c 00 00       	call   80108028 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 ad 42 00 00       	call   80107642 <kvmalloc>
  mpinit_uefi();
80103395:	e8 54 4a 00 00       	call   80107dee <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 36 3d 00 00       	call   801070da <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 bb 30 00 00       	call   80106473 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 82 2c 00 00       	call   80106044 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 98 6d 00 00       	call   8010a169 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 91 4e 00 00       	call   80108281 <pci_init>
  arp_scan();
801033f0:	e8 c8 5b 00 00       	call   80108fbd <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 63 07 00 00       	call   80103b5d <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 50 42 00 00       	call   8010765a <switchkvm>
  seginit();
8010340a:	e8 cb 3c 00 00       	call   801070da <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 d5 a4 10 80       	push   $0x8010a4d5
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 77 2d 00 00       	call   801061ba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 31 0f 00 00       	call   80104391 <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 4f 18 00 00       	call   80104cd2 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103508:	a1 40 6d 19 80       	mov    0x80196d40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 e9 a4 10 80       	push   $0x8010a4e9
8010360c:	50                   	push   %eax
8010360d:	e8 69 13 00 00       	call   8010497b <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 cc 12 00 00       	call   8010499d <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 71 0f 00 00       	call   80104669 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 4e 0f 00 00       	call   80104669 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 c7 12 00 00       	call   80104a0b <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 a8 12 00 00       	call   80104a0b <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 20 12 00 00       	call   8010499d <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 5a 12 00 00       	call   80104a0b <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 9a 0e 00 00       	call   80104669 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 9a 0d 00 00       	call   80104582 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 17 0e 00 00       	call   80104669 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 aa 11 00 00       	call   80104a0b <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 1f 11 00 00       	call   8010499d <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 70 11 00 00       	call   80104a0b <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 c4 0c 00 00       	call   80104582 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 18 0d 00 00       	call   80104669 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 ab 10 00 00       	call   80104a0b <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 f0 a4 10 80       	push   $0x8010a4f0
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 e4 0f 00 00       	call   8010497b <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 f8 a4 10 80       	push   $0x8010a4f8
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 1e a5 10 80       	push   $0x8010a51e
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 cd 10 00 00       	call   80104b08 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 01 11 00 00       	call   80104b55 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 31 0f 00 00       	call   8010499d <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a86:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 6f 0f 00 00       	call   80104a0b <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 b2 00 00 00       	jmp    80103b5b <allocproc+0x102>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac8:	83 ec 0c             	sub    $0xc,%esp
80103acb:	68 00 42 19 80       	push   $0x80194200
80103ad0:	e8 36 0f 00 00       	call   80104a0b <release>
80103ad5:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad8:	e8 c3 ec ff ff       	call   801027a0 <kalloc>
80103add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae0:	89 42 08             	mov    %eax,0x8(%edx)
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	8b 40 08             	mov    0x8(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	75 11                	jne    80103afe <allocproc+0xa5>
    p->state = UNUSED;
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af7:	b8 00 00 00 00       	mov    $0x0,%eax
80103afc:	eb 5d                	jmp    80103b5b <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b01:	8b 40 08             	mov    0x8(%eax),%eax
80103b04:	05 00 10 00 00       	add    $0x1000,%eax
80103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b16:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b19:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1d:	ba fe 5f 10 80       	mov    $0x80105ffe,%edx
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b27:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b31:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 14                	push   $0x14
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 cc 10 00 00       	call   80104c13 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba 3c 45 10 80       	mov    $0x8010453c,%edx
80103b55:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5b:	c9                   	leave  
80103b5c:	c3                   	ret    

80103b5d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b63:	e8 f1 fe ff ff       	call   80103a59 <allocproc>
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 de 39 00 00       	call   80107556 <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 2e a5 10 80       	push   $0x8010a52e
80103b90:	e8 14 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b95:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ba0:	83 ec 04             	sub    $0x4,%esp
80103ba3:	52                   	push   %edx
80103ba4:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba9:	50                   	push   %eax
80103baa:	e8 63 3c 00 00       	call   80107812 <inituvm>
80103baf:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 18             	mov    0x18(%eax),%eax
80103bc1:	83 ec 04             	sub    $0x4,%esp
80103bc4:	6a 4c                	push   $0x4c
80103bc6:	6a 00                	push   $0x0
80103bc8:	50                   	push   %eax
80103bc9:	e8 45 10 00 00       	call   80104c13 <memset>
80103bce:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	8b 40 18             	mov    0x18(%eax),%eax
80103bd7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 18             	mov    0x18(%eax),%eax
80103be3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	8b 50 18             	mov    0x18(%eax),%edx
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	8b 40 18             	mov    0x18(%eax),%eax
80103bf5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 50 18             	mov    0x18(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 18             	mov    0x18(%eax),%eax
80103c09:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	83 c0 6c             	add    $0x6c,%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	6a 10                	push   $0x10
80103c43:	68 47 a5 10 80       	push   $0x8010a547
80103c48:	50                   	push   %eax
80103c49:	e8 c8 11 00 00       	call   80104e16 <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 50 a5 10 80       	push   $0x8010a550
80103c59:	e8 bf e8 ff ff       	call   8010251d <namei>
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c64:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 00 42 19 80       	push   $0x80194200
80103c6f:	e8 29 0d 00 00       	call   8010499d <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 7d 0d 00 00       	call   80104a0b <release>
80103c8e:	83 c4 10             	add    $0x10,%esp
}
80103c91:	90                   	nop
80103c92:	c9                   	leave  
80103c93:	c3                   	ret    

80103c94 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c94:	55                   	push   %ebp
80103c95:	89 e5                	mov    %esp,%ebp
80103c97:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9a:	e8 91 fd ff ff       	call   80103a30 <myproc>
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca5:	8b 00                	mov    (%eax),%eax
80103ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cae:	7e 2e                	jle    80103cde <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	01 c2                	add    %eax,%edx
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	8b 40 04             	mov    0x4(%eax),%eax
80103cbe:	83 ec 04             	sub    $0x4,%esp
80103cc1:	52                   	push   %edx
80103cc2:	ff 75 f4             	push   -0xc(%ebp)
80103cc5:	50                   	push   %eax
80103cc6:	e8 84 3c 00 00       	call   8010794f <allocuvm>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd5:	75 3b                	jne    80103d12 <growproc+0x7e>
      return -1;
80103cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdc:	eb 4f                	jmp    80103d2d <growproc+0x99>
  } else if(n < 0){
80103cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce2:	79 2e                	jns    80103d12 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	01 c2                	add    %eax,%edx
80103cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cef:	8b 40 04             	mov    0x4(%eax),%eax
80103cf2:	83 ec 04             	sub    $0x4,%esp
80103cf5:	52                   	push   %edx
80103cf6:	ff 75 f4             	push   -0xc(%ebp)
80103cf9:	50                   	push   %eax
80103cfa:	e8 55 3d 00 00       	call   80107a54 <deallocuvm>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d09:	75 07                	jne    80103d12 <growproc+0x7e>
      return -1;
80103d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d10:	eb 1b                	jmp    80103d2d <growproc+0x99>
  }
  curproc->sz = sz;
80103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1a:	83 ec 0c             	sub    $0xc,%esp
80103d1d:	ff 75 f0             	push   -0x10(%ebp)
80103d20:	e8 4e 39 00 00       	call   80107673 <switchuvm>
80103d25:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2d:	c9                   	leave  
80103d2e:	c3                   	ret    

80103d2f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	57                   	push   %edi
80103d33:	56                   	push   %esi
80103d34:	53                   	push   %ebx
80103d35:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d38:	e8 f3 fc ff ff       	call   80103a30 <myproc>
80103d3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d40:	e8 14 fd ff ff       	call   80103a59 <allocproc>
80103d45:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4c:	75 0a                	jne    80103d58 <fork+0x29>
    return -1;
80103d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d53:	e9 48 01 00 00       	jmp    80103ea0 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 10                	mov    (%eax),%edx
80103d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d60:	8b 40 04             	mov    0x4(%eax),%eax
80103d63:	83 ec 08             	sub    $0x8,%esp
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 85 3e 00 00       	call   80107bf2 <copyuvm>
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d73:	89 42 04             	mov    %eax,0x4(%edx)
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 04             	mov    0x4(%eax),%eax
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 30                	jne    80103db0 <fork+0x81>
    kfree(np->kstack);
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 08             	mov    0x8(%eax),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 77 e9 ff ff       	call   80102706 <kfree>
80103d8f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	e9 f0 00 00 00       	jmp    80103ea0 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db3:	8b 10                	mov    (%eax),%edx
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc6:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcc:	8b 40 18             	mov    0x18(%eax),%eax
80103dcf:	89 c2                	mov    %eax,%edx
80103dd1:	89 cb                	mov    %ecx,%ebx
80103dd3:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd8:	89 d7                	mov    %edx,%edi
80103dda:	89 de                	mov    %ebx,%esi
80103ddc:	89 c1                	mov    %eax,%ecx
80103dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de3:	8b 40 18             	mov    0x18(%eax),%eax
80103de6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df4:	eb 3b                	jmp    80103e31 <fork+0x102>
    if(curproc->ofile[i])
80103df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfc:	83 c2 08             	add    $0x8,%edx
80103dff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e03:	85 c0                	test   %eax,%eax
80103e05:	74 26                	je     80103e2d <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0d:	83 c2 08             	add    $0x8,%edx
80103e10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	50                   	push   %eax
80103e18:	e8 2d d2 ff ff       	call   8010104a <filedup>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e26:	83 c1 08             	add    $0x8,%ecx
80103e29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e35:	7e bf                	jle    80103df6 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3a:	8b 40 68             	mov    0x68(%eax),%eax
80103e3d:	83 ec 0c             	sub    $0xc,%esp
80103e40:	50                   	push   %eax
80103e41:	e8 6a db ff ff       	call   801019b0 <idup>
80103e46:	83 c4 10             	add    $0x10,%esp
80103e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e52:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e58:	83 c0 6c             	add    $0x6c,%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	6a 10                	push   $0x10
80103e60:	52                   	push   %edx
80103e61:	50                   	push   %eax
80103e62:	e8 af 0f 00 00       	call   80104e16 <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 1d 0b 00 00       	call   8010499d <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 71 0b 00 00       	call   80104a0b <release>
80103e9a:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea3:	5b                   	pop    %ebx
80103ea4:	5e                   	pop    %esi
80103ea5:	5f                   	pop    %edi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret    

80103ea8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eae:	e8 7d fb ff ff       	call   80103a30 <myproc>
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb6:	a1 34 62 19 80       	mov    0x80196234,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 52 a5 10 80       	push   $0x8010a552
80103ec8:	e8 dc c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ecd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed4:	eb 3f                	jmp    80103f15 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edc:	83 c2 08             	add    $0x8,%edx
80103edf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee3:	85 c0                	test   %eax,%eax
80103ee5:	74 2a                	je     80103f11 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eed:	83 c2 08             	add    $0x8,%edx
80103ef0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 9e d1 ff ff       	call   8010109b <fileclose>
80103efd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f06:	83 c2 08             	add    $0x8,%edx
80103f09:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f10:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f15:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f19:	7e bb                	jle    80103ed6 <exit+0x2e>
    }
  }

  begin_op();
80103f1b:	e8 1c f1 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f23:	8b 40 68             	mov    0x68(%eax),%eax
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	50                   	push   %eax
80103f2a:	e8 1c dc ff ff       	call   80101b4b <iput>
80103f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f32:	e8 91 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 00 42 19 80       	push   $0x80194200
80103f49:	e8 4f 0a 00 00       	call   8010499d <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 c9 06 00 00       	call   80104629 <wakeup1>
80103f60:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f63:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6a:	eb 37                	jmp    80103fa3 <exit+0xfb>
    if(p->parent == curproc){
80103f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6f:	8b 40 14             	mov    0x14(%eax),%eax
80103f72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f75:	75 28                	jne    80103f9f <exit+0xf7>
      p->parent = initproc;
80103f77:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 8d 06 00 00       	call   80104629 <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103fa3:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103faa:	72 c0                	jb     80103f6c <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb6:	e8 8e 04 00 00       	call   80104449 <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 5f a5 10 80       	push   $0x8010a55f
80103fc3:	e8 e1 c5 ff ff       	call   801005a9 <panic>

80103fc8 <exit2>:
//******************************************
//************   new  **********************
//************ eixt2() *********************
//******************************************
void
exit2(int status){
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;
 
  //***********새로 추가된 부분. Copy status to xstate**********
  curproc->xstate = status;
80103fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd9:	8b 55 08             	mov    0x8(%ebp),%edx
80103fdc:	89 50 7c             	mov    %edx,0x7c(%eax)
  int test =curproc->xstate;
80103fdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe2:	8b 40 7c             	mov    0x7c(%eax),%eax
80103fe5:	89 45 e8             	mov    %eax,-0x18(%ebp)

  cprintf("%d\n", test);
80103fe8:	83 ec 08             	sub    $0x8,%esp
80103feb:	ff 75 e8             	push   -0x18(%ebp)
80103fee:	68 6b a5 10 80       	push   $0x8010a56b
80103ff3:	e8 fc c3 ff ff       	call   801003f4 <cprintf>
80103ff8:	83 c4 10             	add    $0x10,%esp

  if(curproc == initproc)
80103ffb:	a1 34 62 19 80       	mov    0x80196234,%eax
80104000:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104003:	75 0d                	jne    80104012 <exit2+0x4a>
    panic("init exiting");
80104005:	83 ec 0c             	sub    $0xc,%esp
80104008:	68 52 a5 10 80       	push   $0x8010a552
8010400d:	e8 97 c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104012:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104019:	eb 3f                	jmp    8010405a <exit2+0x92>
    if(curproc->ofile[fd]){
8010401b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010401e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104021:	83 c2 08             	add    $0x8,%edx
80104024:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104028:	85 c0                	test   %eax,%eax
8010402a:	74 2a                	je     80104056 <exit2+0x8e>
      fileclose(curproc->ofile[fd]);
8010402c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010402f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104032:	83 c2 08             	add    $0x8,%edx
80104035:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104039:	83 ec 0c             	sub    $0xc,%esp
8010403c:	50                   	push   %eax
8010403d:	e8 59 d0 ff ff       	call   8010109b <fileclose>
80104042:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104045:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104048:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010404b:	83 c2 08             	add    $0x8,%edx
8010404e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104055:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104056:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010405a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010405e:	7e bb                	jle    8010401b <exit2+0x53>
    }
  }

  begin_op();
80104060:	e8 d7 ef ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80104065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104068:	8b 40 68             	mov    0x68(%eax),%eax
8010406b:	83 ec 0c             	sub    $0xc,%esp
8010406e:	50                   	push   %eax
8010406f:	e8 d7 da ff ff       	call   80101b4b <iput>
80104074:	83 c4 10             	add    $0x10,%esp
  end_op();
80104077:	e8 4c f0 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
8010407c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010407f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104086:	83 ec 0c             	sub    $0xc,%esp
80104089:	68 00 42 19 80       	push   $0x80194200
8010408e:	e8 0a 09 00 00       	call   8010499d <acquire>
80104093:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104096:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104099:	8b 40 14             	mov    0x14(%eax),%eax
8010409c:	83 ec 0c             	sub    $0xc,%esp
8010409f:	50                   	push   %eax
801040a0:	e8 84 05 00 00       	call   80104629 <wakeup1>
801040a5:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040a8:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801040af:	eb 37                	jmp    801040e8 <exit2+0x120>
    if(p->parent == curproc){
801040b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b4:	8b 40 14             	mov    0x14(%eax),%eax
801040b7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040ba:	75 28                	jne    801040e4 <exit2+0x11c>
      p->parent = initproc;
801040bc:	8b 15 34 62 19 80    	mov    0x80196234,%edx
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	8b 40 0c             	mov    0xc(%eax),%eax
801040ce:	83 f8 05             	cmp    $0x5,%eax
801040d1:	75 11                	jne    801040e4 <exit2+0x11c>
        wakeup1(initproc);
801040d3:	a1 34 62 19 80       	mov    0x80196234,%eax
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	50                   	push   %eax
801040dc:	e8 48 05 00 00       	call   80104629 <wakeup1>
801040e1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040e4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801040e8:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801040ef:	72 c0                	jb     801040b1 <exit2+0xe9>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f4:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801040fb:	e8 49 03 00 00       	call   80104449 <sched>
  panic("zombie exit");
80104100:	83 ec 0c             	sub    $0xc,%esp
80104103:	68 5f a5 10 80       	push   $0x8010a55f
80104108:	e8 9c c4 ff ff       	call   801005a9 <panic>

8010410d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010410d:	55                   	push   %ebp
8010410e:	89 e5                	mov    %esp,%ebp
80104110:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104113:	e8 18 f9 ff ff       	call   80103a30 <myproc>
80104118:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010411b:	83 ec 0c             	sub    $0xc,%esp
8010411e:	68 00 42 19 80       	push   $0x80194200
80104123:	e8 75 08 00 00       	call   8010499d <acquire>
80104128:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010412b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104132:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104139:	e9 a1 00 00 00       	jmp    801041df <wait+0xd2>
      if(p->parent != curproc)
8010413e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104141:	8b 40 14             	mov    0x14(%eax),%eax
80104144:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104147:	0f 85 8d 00 00 00    	jne    801041da <wait+0xcd>
        continue;
      havekids = 1;
8010414d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104157:	8b 40 0c             	mov    0xc(%eax),%eax
8010415a:	83 f8 05             	cmp    $0x5,%eax
8010415d:	75 7c                	jne    801041db <wait+0xce>
        // Found one.
        pid = p->pid;
8010415f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104162:	8b 40 10             	mov    0x10(%eax),%eax
80104165:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416b:	8b 40 08             	mov    0x8(%eax),%eax
8010416e:	83 ec 0c             	sub    $0xc,%esp
80104171:	50                   	push   %eax
80104172:	e8 8f e5 ff ff       	call   80102706 <kfree>
80104177:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010417a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104187:	8b 40 04             	mov    0x4(%eax),%eax
8010418a:	83 ec 0c             	sub    $0xc,%esp
8010418d:	50                   	push   %eax
8010418e:	e8 85 39 00 00       	call   80107b18 <freevm>
80104193:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104199:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801041aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ad:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801041b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801041bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801041c5:	83 ec 0c             	sub    $0xc,%esp
801041c8:	68 00 42 19 80       	push   $0x80194200
801041cd:	e8 39 08 00 00       	call   80104a0b <release>
801041d2:	83 c4 10             	add    $0x10,%esp
        return pid;
801041d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041d8:	eb 51                	jmp    8010422b <wait+0x11e>
        continue;
801041da:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041db:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041df:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801041e6:	0f 82 52 ff ff ff    	jb     8010413e <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801041ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041f0:	74 0a                	je     801041fc <wait+0xef>
801041f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f5:	8b 40 24             	mov    0x24(%eax),%eax
801041f8:	85 c0                	test   %eax,%eax
801041fa:	74 17                	je     80104213 <wait+0x106>
      release(&ptable.lock);
801041fc:	83 ec 0c             	sub    $0xc,%esp
801041ff:	68 00 42 19 80       	push   $0x80194200
80104204:	e8 02 08 00 00       	call   80104a0b <release>
80104209:	83 c4 10             	add    $0x10,%esp
      return -1;
8010420c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104211:	eb 18                	jmp    8010422b <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104213:	83 ec 08             	sub    $0x8,%esp
80104216:	68 00 42 19 80       	push   $0x80194200
8010421b:	ff 75 ec             	push   -0x14(%ebp)
8010421e:	e8 5f 03 00 00       	call   80104582 <sleep>
80104223:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104226:	e9 00 ff ff ff       	jmp    8010412b <wait+0x1e>
  }
}
8010422b:	c9                   	leave  
8010422c:	c3                   	ret    

8010422d <wait2>:
//******************************************
//************   new  **********************
//************ wait2() *********************
//******************************************
int
wait2(int *status){
8010422d:	55                   	push   %ebp
8010422e:	89 e5                	mov    %esp,%ebp
80104230:	83 ec 18             	sub    $0x18,%esp

struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104233:	e8 f8 f7 ff ff       	call   80103a30 <myproc>
80104238:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
8010423b:	83 ec 0c             	sub    $0xc,%esp
8010423e:	68 00 42 19 80       	push   $0x80194200
80104243:	e8 55 07 00 00       	call   8010499d <acquire>
80104248:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // 모든 프로세스를 스캔하여 자식 프로세스가 있는지 확인
    havekids = 0;
8010424b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104252:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104259:	e9 e5 00 00 00       	jmp    80104343 <wait2+0x116>
      if(p->parent != curproc)
8010425e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104261:	8b 40 14             	mov    0x14(%eax),%eax
80104264:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104267:	0f 85 d1 00 00 00    	jne    8010433e <wait2+0x111>
        continue;
      havekids = 1;
8010426d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
80104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104277:	8b 40 0c             	mov    0xc(%eax),%eax
8010427a:	83 f8 05             	cmp    $0x5,%eax
8010427d:	0f 85 bc 00 00 00    	jne    8010433f <wait2+0x112>
        // 종료된 자식 프로세스 찾기
        pid = p->pid;
80104283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104286:	8b 40 10             	mov    0x10(%eax),%eax
80104289:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 여기에서 자식 프로세스의 xstate 값을 사용자 공간으로 복사
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &(p->xstate), sizeof(p->xstate)) < 0) {
8010428c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104290:	74 3a                	je     801042cc <wait2+0x9f>
80104292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104295:	8d 48 7c             	lea    0x7c(%eax),%ecx
80104298:	8b 55 08             	mov    0x8(%ebp),%edx
8010429b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010429e:	8b 40 04             	mov    0x4(%eax),%eax
801042a1:	6a 04                	push   $0x4
801042a3:	51                   	push   %ecx
801042a4:	52                   	push   %edx
801042a5:	50                   	push   %eax
801042a6:	e8 a5 3a 00 00       	call   80107d50 <copyout>
801042ab:	83 c4 10             	add    $0x10,%esp
801042ae:	85 c0                	test   %eax,%eax
801042b0:	79 1a                	jns    801042cc <wait2+0x9f>
          // copyout 실패시 -1 반환
          release(&ptable.lock);
801042b2:	83 ec 0c             	sub    $0xc,%esp
801042b5:	68 00 42 19 80       	push   $0x80194200
801042ba:	e8 4c 07 00 00       	call   80104a0b <release>
801042bf:	83 c4 10             	add    $0x10,%esp
          return -1;
801042c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c7:	e9 c3 00 00 00       	jmp    8010438f <wait2+0x162>
        }
        // 자식 프로세스 자원 회수
        kfree(p->kstack);
801042cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cf:	8b 40 08             	mov    0x8(%eax),%eax
801042d2:	83 ec 0c             	sub    $0xc,%esp
801042d5:	50                   	push   %eax
801042d6:	e8 2b e4 ff ff       	call   80102706 <kfree>
801042db:	83 c4 10             	add    $0x10,%esp
        freevm(p->pgdir);
801042de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e1:	8b 40 04             	mov    0x4(%eax),%eax
801042e4:	83 ec 0c             	sub    $0xc,%esp
801042e7:	50                   	push   %eax
801042e8:	e8 2b 38 00 00       	call   80107b18 <freevm>
801042ed:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801042f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        p->pid = 0;
801042fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104307:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010430e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104311:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104318:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104329:	83 ec 0c             	sub    $0xc,%esp
8010432c:	68 00 42 19 80       	push   $0x80194200
80104331:	e8 d5 06 00 00       	call   80104a0b <release>
80104336:	83 c4 10             	add    $0x10,%esp
        return pid;
80104339:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010433c:	eb 51                	jmp    8010438f <wait2+0x162>
        continue;
8010433e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010433f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104343:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010434a:	0f 82 0e ff ff ff    	jb     8010425e <wait2+0x31>
      }
    }

    // 자식 프로세스가 없다면
    if (!havekids || curproc->killed) {
80104350:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104354:	74 0a                	je     80104360 <wait2+0x133>
80104356:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104359:	8b 40 24             	mov    0x24(%eax),%eax
8010435c:	85 c0                	test   %eax,%eax
8010435e:	74 17                	je     80104377 <wait2+0x14a>
      release(&ptable.lock);
80104360:	83 ec 0c             	sub    $0xc,%esp
80104363:	68 00 42 19 80       	push   $0x80194200
80104368:	e8 9e 06 00 00       	call   80104a0b <release>
8010436d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104375:	eb 18                	jmp    8010438f <wait2+0x162>
    }

    // 자식 프로세스의 종료를 대기
    sleep(curproc, &ptable.lock);  // sleep은 ptable.lock을 해제하고 재획득합니다.
80104377:	83 ec 08             	sub    $0x8,%esp
8010437a:	68 00 42 19 80       	push   $0x80194200
8010437f:	ff 75 ec             	push   -0x14(%ebp)
80104382:	e8 fb 01 00 00       	call   80104582 <sleep>
80104387:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010438a:	e9 bc fe ff ff       	jmp    8010424b <wait2+0x1e>
  }

}
8010438f:	c9                   	leave  
80104390:	c3                   	ret    

80104391 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104391:	55                   	push   %ebp
80104392:	89 e5                	mov    %esp,%ebp
80104394:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104397:	e8 1c f6 ff ff       	call   801039b8 <mycpu>
8010439c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010439f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043a9:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801043ac:	e8 c7 f5 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	68 00 42 19 80       	push   $0x80194200
801043b9:	e8 df 05 00 00       	call   8010499d <acquire>
801043be:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043c1:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801043c8:	eb 61                	jmp    8010442b <scheduler+0x9a>
      if(p->state != RUNNABLE)
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	8b 40 0c             	mov    0xc(%eax),%eax
801043d0:	83 f8 03             	cmp    $0x3,%eax
801043d3:	75 51                	jne    80104426 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801043d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043db:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801043e1:	83 ec 0c             	sub    $0xc,%esp
801043e4:	ff 75 f4             	push   -0xc(%ebp)
801043e7:	e8 87 32 00 00       	call   80107673 <switchuvm>
801043ec:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801043ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fc:	8b 40 1c             	mov    0x1c(%eax),%eax
801043ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104402:	83 c2 04             	add    $0x4,%edx
80104405:	83 ec 08             	sub    $0x8,%esp
80104408:	50                   	push   %eax
80104409:	52                   	push   %edx
8010440a:	e8 79 0a 00 00       	call   80104e88 <swtch>
8010440f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104412:	e8 43 32 00 00       	call   8010765a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104421:	00 00 00 
80104424:	eb 01                	jmp    80104427 <scheduler+0x96>
        continue;
80104426:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104427:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010442b:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104432:	72 96                	jb     801043ca <scheduler+0x39>
    }
    release(&ptable.lock);
80104434:	83 ec 0c             	sub    $0xc,%esp
80104437:	68 00 42 19 80       	push   $0x80194200
8010443c:	e8 ca 05 00 00       	call   80104a0b <release>
80104441:	83 c4 10             	add    $0x10,%esp
    sti();
80104444:	e9 63 ff ff ff       	jmp    801043ac <scheduler+0x1b>

80104449 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104449:	55                   	push   %ebp
8010444a:	89 e5                	mov    %esp,%ebp
8010444c:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010444f:	e8 dc f5 ff ff       	call   80103a30 <myproc>
80104454:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104457:	83 ec 0c             	sub    $0xc,%esp
8010445a:	68 00 42 19 80       	push   $0x80194200
8010445f:	e8 74 06 00 00       	call   80104ad8 <holding>
80104464:	83 c4 10             	add    $0x10,%esp
80104467:	85 c0                	test   %eax,%eax
80104469:	75 0d                	jne    80104478 <sched+0x2f>
    panic("sched ptable.lock");
8010446b:	83 ec 0c             	sub    $0xc,%esp
8010446e:	68 6f a5 10 80       	push   $0x8010a56f
80104473:	e8 31 c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104478:	e8 3b f5 ff ff       	call   801039b8 <mycpu>
8010447d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104483:	83 f8 01             	cmp    $0x1,%eax
80104486:	74 0d                	je     80104495 <sched+0x4c>
    panic("sched locks");
80104488:	83 ec 0c             	sub    $0xc,%esp
8010448b:	68 81 a5 10 80       	push   $0x8010a581
80104490:	e8 14 c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	8b 40 0c             	mov    0xc(%eax),%eax
8010449b:	83 f8 04             	cmp    $0x4,%eax
8010449e:	75 0d                	jne    801044ad <sched+0x64>
    panic("sched running");
801044a0:	83 ec 0c             	sub    $0xc,%esp
801044a3:	68 8d a5 10 80       	push   $0x8010a58d
801044a8:	e8 fc c0 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801044ad:	e8 b6 f4 ff ff       	call   80103968 <readeflags>
801044b2:	25 00 02 00 00       	and    $0x200,%eax
801044b7:	85 c0                	test   %eax,%eax
801044b9:	74 0d                	je     801044c8 <sched+0x7f>
    panic("sched interruptible");
801044bb:	83 ec 0c             	sub    $0xc,%esp
801044be:	68 9b a5 10 80       	push   $0x8010a59b
801044c3:	e8 e1 c0 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801044c8:	e8 eb f4 ff ff       	call   801039b8 <mycpu>
801044cd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801044d6:	e8 dd f4 ff ff       	call   801039b8 <mycpu>
801044db:	8b 40 04             	mov    0x4(%eax),%eax
801044de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e1:	83 c2 1c             	add    $0x1c,%edx
801044e4:	83 ec 08             	sub    $0x8,%esp
801044e7:	50                   	push   %eax
801044e8:	52                   	push   %edx
801044e9:	e8 9a 09 00 00       	call   80104e88 <swtch>
801044ee:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044f1:	e8 c2 f4 ff ff       	call   801039b8 <mycpu>
801044f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044f9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044ff:	90                   	nop
80104500:	c9                   	leave  
80104501:	c3                   	ret    

80104502 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104502:	55                   	push   %ebp
80104503:	89 e5                	mov    %esp,%ebp
80104505:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104508:	83 ec 0c             	sub    $0xc,%esp
8010450b:	68 00 42 19 80       	push   $0x80194200
80104510:	e8 88 04 00 00       	call   8010499d <acquire>
80104515:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104518:	e8 13 f5 ff ff       	call   80103a30 <myproc>
8010451d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104524:	e8 20 ff ff ff       	call   80104449 <sched>
  release(&ptable.lock);
80104529:	83 ec 0c             	sub    $0xc,%esp
8010452c:	68 00 42 19 80       	push   $0x80194200
80104531:	e8 d5 04 00 00       	call   80104a0b <release>
80104536:	83 c4 10             	add    $0x10,%esp
}
80104539:	90                   	nop
8010453a:	c9                   	leave  
8010453b:	c3                   	ret    

8010453c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010453c:	55                   	push   %ebp
8010453d:	89 e5                	mov    %esp,%ebp
8010453f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104542:	83 ec 0c             	sub    $0xc,%esp
80104545:	68 00 42 19 80       	push   $0x80194200
8010454a:	e8 bc 04 00 00       	call   80104a0b <release>
8010454f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104552:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104557:	85 c0                	test   %eax,%eax
80104559:	74 24                	je     8010457f <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010455b:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104562:	00 00 00 
    iinit(ROOTDEV);
80104565:	83 ec 0c             	sub    $0xc,%esp
80104568:	6a 01                	push   $0x1
8010456a:	e8 09 d1 ff ff       	call   80101678 <iinit>
8010456f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104572:	83 ec 0c             	sub    $0xc,%esp
80104575:	6a 01                	push   $0x1
80104577:	e8 a1 e8 ff ff       	call   80102e1d <initlog>
8010457c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010457f:	90                   	nop
80104580:	c9                   	leave  
80104581:	c3                   	ret    

80104582 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104582:	55                   	push   %ebp
80104583:	89 e5                	mov    %esp,%ebp
80104585:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104588:	e8 a3 f4 ff ff       	call   80103a30 <myproc>
8010458d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104590:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104594:	75 0d                	jne    801045a3 <sleep+0x21>
    panic("sleep");
80104596:	83 ec 0c             	sub    $0xc,%esp
80104599:	68 af a5 10 80       	push   $0x8010a5af
8010459e:	e8 06 c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801045a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801045a7:	75 0d                	jne    801045b6 <sleep+0x34>
    panic("sleep without lk");
801045a9:	83 ec 0c             	sub    $0xc,%esp
801045ac:	68 b5 a5 10 80       	push   $0x8010a5b5
801045b1:	e8 f3 bf ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801045b6:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801045bd:	74 1e                	je     801045dd <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801045bf:	83 ec 0c             	sub    $0xc,%esp
801045c2:	68 00 42 19 80       	push   $0x80194200
801045c7:	e8 d1 03 00 00       	call   8010499d <acquire>
801045cc:	83 c4 10             	add    $0x10,%esp
    release(lk);
801045cf:	83 ec 0c             	sub    $0xc,%esp
801045d2:	ff 75 0c             	push   0xc(%ebp)
801045d5:	e8 31 04 00 00       	call   80104a0b <release>
801045da:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	8b 55 08             	mov    0x8(%ebp),%edx
801045e3:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e9:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045f0:	e8 54 fe ff ff       	call   80104449 <sched>

  // Tidy up.
  p->chan = 0;
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045ff:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104606:	74 1e                	je     80104626 <sleep+0xa4>
    release(&ptable.lock);
80104608:	83 ec 0c             	sub    $0xc,%esp
8010460b:	68 00 42 19 80       	push   $0x80194200
80104610:	e8 f6 03 00 00       	call   80104a0b <release>
80104615:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104618:	83 ec 0c             	sub    $0xc,%esp
8010461b:	ff 75 0c             	push   0xc(%ebp)
8010461e:	e8 7a 03 00 00       	call   8010499d <acquire>
80104623:	83 c4 10             	add    $0x10,%esp
  }
}
80104626:	90                   	nop
80104627:	c9                   	leave  
80104628:	c3                   	ret    

80104629 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104629:	55                   	push   %ebp
8010462a:	89 e5                	mov    %esp,%ebp
8010462c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010462f:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104636:	eb 24                	jmp    8010465c <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104638:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010463b:	8b 40 0c             	mov    0xc(%eax),%eax
8010463e:	83 f8 02             	cmp    $0x2,%eax
80104641:	75 15                	jne    80104658 <wakeup1+0x2f>
80104643:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104646:	8b 40 20             	mov    0x20(%eax),%eax
80104649:	39 45 08             	cmp    %eax,0x8(%ebp)
8010464c:	75 0a                	jne    80104658 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010464e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104651:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104658:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
8010465c:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
80104663:	72 d3                	jb     80104638 <wakeup1+0xf>
}
80104665:	90                   	nop
80104666:	90                   	nop
80104667:	c9                   	leave  
80104668:	c3                   	ret    

80104669 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104669:	55                   	push   %ebp
8010466a:	89 e5                	mov    %esp,%ebp
8010466c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	68 00 42 19 80       	push   $0x80194200
80104677:	e8 21 03 00 00       	call   8010499d <acquire>
8010467c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	ff 75 08             	push   0x8(%ebp)
80104685:	e8 9f ff ff ff       	call   80104629 <wakeup1>
8010468a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	68 00 42 19 80       	push   $0x80194200
80104695:	e8 71 03 00 00       	call   80104a0b <release>
8010469a:	83 c4 10             	add    $0x10,%esp
}
8010469d:	90                   	nop
8010469e:	c9                   	leave  
8010469f:	c3                   	ret    

801046a0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801046a0:	55                   	push   %ebp
801046a1:	89 e5                	mov    %esp,%ebp
801046a3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801046a6:	83 ec 0c             	sub    $0xc,%esp
801046a9:	68 00 42 19 80       	push   $0x80194200
801046ae:	e8 ea 02 00 00       	call   8010499d <acquire>
801046b3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046b6:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801046bd:	eb 45                	jmp    80104704 <kill+0x64>
    if(p->pid == pid){
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	8b 40 10             	mov    0x10(%eax),%eax
801046c5:	39 45 08             	cmp    %eax,0x8(%ebp)
801046c8:	75 36                	jne    80104700 <kill+0x60>
      p->killed = 1;
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	8b 40 0c             	mov    0xc(%eax),%eax
801046da:	83 f8 02             	cmp    $0x2,%eax
801046dd:	75 0a                	jne    801046e9 <kill+0x49>
        p->state = RUNNABLE;
801046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046e9:	83 ec 0c             	sub    $0xc,%esp
801046ec:	68 00 42 19 80       	push   $0x80194200
801046f1:	e8 15 03 00 00       	call   80104a0b <release>
801046f6:	83 c4 10             	add    $0x10,%esp
      return 0;
801046f9:	b8 00 00 00 00       	mov    $0x0,%eax
801046fe:	eb 22                	jmp    80104722 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104700:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104704:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010470b:	72 b2                	jb     801046bf <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010470d:	83 ec 0c             	sub    $0xc,%esp
80104710:	68 00 42 19 80       	push   $0x80194200
80104715:	e8 f1 02 00 00       	call   80104a0b <release>
8010471a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010471d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104722:	c9                   	leave  
80104723:	c3                   	ret    

80104724 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104724:	55                   	push   %ebp
80104725:	89 e5                	mov    %esp,%ebp
80104727:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010472a:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104731:	e9 d7 00 00 00       	jmp    8010480d <procdump+0xe9>
    if(p->state == UNUSED)
80104736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104739:	8b 40 0c             	mov    0xc(%eax),%eax
8010473c:	85 c0                	test   %eax,%eax
8010473e:	0f 84 c4 00 00 00    	je     80104808 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104744:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104747:	8b 40 0c             	mov    0xc(%eax),%eax
8010474a:	83 f8 05             	cmp    $0x5,%eax
8010474d:	77 23                	ja     80104772 <procdump+0x4e>
8010474f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104752:	8b 40 0c             	mov    0xc(%eax),%eax
80104755:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010475c:	85 c0                	test   %eax,%eax
8010475e:	74 12                	je     80104772 <procdump+0x4e>
      state = states[p->state];
80104760:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104763:	8b 40 0c             	mov    0xc(%eax),%eax
80104766:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010476d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104770:	eb 07                	jmp    80104779 <procdump+0x55>
    else
      state = "???";
80104772:	c7 45 ec c6 a5 10 80 	movl   $0x8010a5c6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010477c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010477f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104782:	8b 40 10             	mov    0x10(%eax),%eax
80104785:	52                   	push   %edx
80104786:	ff 75 ec             	push   -0x14(%ebp)
80104789:	50                   	push   %eax
8010478a:	68 ca a5 10 80       	push   $0x8010a5ca
8010478f:	e8 60 bc ff ff       	call   801003f4 <cprintf>
80104794:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010479a:	8b 40 0c             	mov    0xc(%eax),%eax
8010479d:	83 f8 02             	cmp    $0x2,%eax
801047a0:	75 54                	jne    801047f6 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801047a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047a5:	8b 40 1c             	mov    0x1c(%eax),%eax
801047a8:	8b 40 0c             	mov    0xc(%eax),%eax
801047ab:	83 c0 08             	add    $0x8,%eax
801047ae:	89 c2                	mov    %eax,%edx
801047b0:	83 ec 08             	sub    $0x8,%esp
801047b3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047b6:	50                   	push   %eax
801047b7:	52                   	push   %edx
801047b8:	e8 a0 02 00 00       	call   80104a5d <getcallerpcs>
801047bd:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047c7:	eb 1c                	jmp    801047e5 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047d0:	83 ec 08             	sub    $0x8,%esp
801047d3:	50                   	push   %eax
801047d4:	68 d3 a5 10 80       	push   $0x8010a5d3
801047d9:	e8 16 bc ff ff       	call   801003f4 <cprintf>
801047de:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047e5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047e9:	7f 0b                	jg     801047f6 <procdump+0xd2>
801047eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ee:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047f2:	85 c0                	test   %eax,%eax
801047f4:	75 d3                	jne    801047c9 <procdump+0xa5>
    }
    cprintf("\n");
801047f6:	83 ec 0c             	sub    $0xc,%esp
801047f9:	68 d7 a5 10 80       	push   $0x8010a5d7
801047fe:	e8 f1 bb ff ff       	call   801003f4 <cprintf>
80104803:	83 c4 10             	add    $0x10,%esp
80104806:	eb 01                	jmp    80104809 <procdump+0xe5>
      continue;
80104808:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104809:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
8010480d:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
80104814:	0f 82 1c ff ff ff    	jb     80104736 <procdump+0x12>
  }
}
8010481a:	90                   	nop
8010481b:	90                   	nop
8010481c:	c9                   	leave  
8010481d:	c3                   	ret    

8010481e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010481e:	55                   	push   %ebp
8010481f:	89 e5                	mov    %esp,%ebp
80104821:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104824:	8b 45 08             	mov    0x8(%ebp),%eax
80104827:	83 c0 04             	add    $0x4,%eax
8010482a:	83 ec 08             	sub    $0x8,%esp
8010482d:	68 03 a6 10 80       	push   $0x8010a603
80104832:	50                   	push   %eax
80104833:	e8 43 01 00 00       	call   8010497b <initlock>
80104838:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010483b:	8b 45 08             	mov    0x8(%ebp),%eax
8010483e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104841:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104844:	8b 45 08             	mov    0x8(%ebp),%eax
80104847:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010484d:	8b 45 08             	mov    0x8(%ebp),%eax
80104850:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104857:	90                   	nop
80104858:	c9                   	leave  
80104859:	c3                   	ret    

8010485a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010485a:	55                   	push   %ebp
8010485b:	89 e5                	mov    %esp,%ebp
8010485d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104860:	8b 45 08             	mov    0x8(%ebp),%eax
80104863:	83 c0 04             	add    $0x4,%eax
80104866:	83 ec 0c             	sub    $0xc,%esp
80104869:	50                   	push   %eax
8010486a:	e8 2e 01 00 00       	call   8010499d <acquire>
8010486f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104872:	eb 15                	jmp    80104889 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104874:	8b 45 08             	mov    0x8(%ebp),%eax
80104877:	83 c0 04             	add    $0x4,%eax
8010487a:	83 ec 08             	sub    $0x8,%esp
8010487d:	50                   	push   %eax
8010487e:	ff 75 08             	push   0x8(%ebp)
80104881:	e8 fc fc ff ff       	call   80104582 <sleep>
80104886:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104889:	8b 45 08             	mov    0x8(%ebp),%eax
8010488c:	8b 00                	mov    (%eax),%eax
8010488e:	85 c0                	test   %eax,%eax
80104890:	75 e2                	jne    80104874 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104892:	8b 45 08             	mov    0x8(%ebp),%eax
80104895:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010489b:	e8 90 f1 ff ff       	call   80103a30 <myproc>
801048a0:	8b 50 10             	mov    0x10(%eax),%edx
801048a3:	8b 45 08             	mov    0x8(%ebp),%eax
801048a6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801048a9:	8b 45 08             	mov    0x8(%ebp),%eax
801048ac:	83 c0 04             	add    $0x4,%eax
801048af:	83 ec 0c             	sub    $0xc,%esp
801048b2:	50                   	push   %eax
801048b3:	e8 53 01 00 00       	call   80104a0b <release>
801048b8:	83 c4 10             	add    $0x10,%esp
}
801048bb:	90                   	nop
801048bc:	c9                   	leave  
801048bd:	c3                   	ret    

801048be <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801048be:	55                   	push   %ebp
801048bf:	89 e5                	mov    %esp,%ebp
801048c1:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801048c4:	8b 45 08             	mov    0x8(%ebp),%eax
801048c7:	83 c0 04             	add    $0x4,%eax
801048ca:	83 ec 0c             	sub    $0xc,%esp
801048cd:	50                   	push   %eax
801048ce:	e8 ca 00 00 00       	call   8010499d <acquire>
801048d3:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801048d6:	8b 45 08             	mov    0x8(%ebp),%eax
801048d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801048df:	8b 45 08             	mov    0x8(%ebp),%eax
801048e2:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801048e9:	83 ec 0c             	sub    $0xc,%esp
801048ec:	ff 75 08             	push   0x8(%ebp)
801048ef:	e8 75 fd ff ff       	call   80104669 <wakeup>
801048f4:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801048f7:	8b 45 08             	mov    0x8(%ebp),%eax
801048fa:	83 c0 04             	add    $0x4,%eax
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	50                   	push   %eax
80104901:	e8 05 01 00 00       	call   80104a0b <release>
80104906:	83 c4 10             	add    $0x10,%esp
}
80104909:	90                   	nop
8010490a:	c9                   	leave  
8010490b:	c3                   	ret    

8010490c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104912:	8b 45 08             	mov    0x8(%ebp),%eax
80104915:	83 c0 04             	add    $0x4,%eax
80104918:	83 ec 0c             	sub    $0xc,%esp
8010491b:	50                   	push   %eax
8010491c:	e8 7c 00 00 00       	call   8010499d <acquire>
80104921:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104924:	8b 45 08             	mov    0x8(%ebp),%eax
80104927:	8b 00                	mov    (%eax),%eax
80104929:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010492c:	8b 45 08             	mov    0x8(%ebp),%eax
8010492f:	83 c0 04             	add    $0x4,%eax
80104932:	83 ec 0c             	sub    $0xc,%esp
80104935:	50                   	push   %eax
80104936:	e8 d0 00 00 00       	call   80104a0b <release>
8010493b:	83 c4 10             	add    $0x10,%esp
  return r;
8010493e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104941:	c9                   	leave  
80104942:	c3                   	ret    

80104943 <readeflags>:
{
80104943:	55                   	push   %ebp
80104944:	89 e5                	mov    %esp,%ebp
80104946:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104949:	9c                   	pushf  
8010494a:	58                   	pop    %eax
8010494b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010494e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104951:	c9                   	leave  
80104952:	c3                   	ret    

80104953 <cli>:
{
80104953:	55                   	push   %ebp
80104954:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104956:	fa                   	cli    
}
80104957:	90                   	nop
80104958:	5d                   	pop    %ebp
80104959:	c3                   	ret    

8010495a <sti>:
{
8010495a:	55                   	push   %ebp
8010495b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010495d:	fb                   	sti    
}
8010495e:	90                   	nop
8010495f:	5d                   	pop    %ebp
80104960:	c3                   	ret    

80104961 <xchg>:
{
80104961:	55                   	push   %ebp
80104962:	89 e5                	mov    %esp,%ebp
80104964:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104967:	8b 55 08             	mov    0x8(%ebp),%edx
8010496a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104970:	f0 87 02             	lock xchg %eax,(%edx)
80104973:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104976:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104979:	c9                   	leave  
8010497a:	c3                   	ret    

8010497b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010497b:	55                   	push   %ebp
8010497c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010497e:	8b 45 08             	mov    0x8(%ebp),%eax
80104981:	8b 55 0c             	mov    0xc(%ebp),%edx
80104984:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104987:	8b 45 08             	mov    0x8(%ebp),%eax
8010498a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104990:	8b 45 08             	mov    0x8(%ebp),%eax
80104993:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010499a:	90                   	nop
8010499b:	5d                   	pop    %ebp
8010499c:	c3                   	ret    

8010499d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010499d:	55                   	push   %ebp
8010499e:	89 e5                	mov    %esp,%ebp
801049a0:	53                   	push   %ebx
801049a1:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801049a4:	e8 5f 01 00 00       	call   80104b08 <pushcli>
  if(holding(lk)){
801049a9:	8b 45 08             	mov    0x8(%ebp),%eax
801049ac:	83 ec 0c             	sub    $0xc,%esp
801049af:	50                   	push   %eax
801049b0:	e8 23 01 00 00       	call   80104ad8 <holding>
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	85 c0                	test   %eax,%eax
801049ba:	74 0d                	je     801049c9 <acquire+0x2c>
    panic("acquire");
801049bc:	83 ec 0c             	sub    $0xc,%esp
801049bf:	68 0e a6 10 80       	push   $0x8010a60e
801049c4:	e8 e0 bb ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801049c9:	90                   	nop
801049ca:	8b 45 08             	mov    0x8(%ebp),%eax
801049cd:	83 ec 08             	sub    $0x8,%esp
801049d0:	6a 01                	push   $0x1
801049d2:	50                   	push   %eax
801049d3:	e8 89 ff ff ff       	call   80104961 <xchg>
801049d8:	83 c4 10             	add    $0x10,%esp
801049db:	85 c0                	test   %eax,%eax
801049dd:	75 eb                	jne    801049ca <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801049df:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801049e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
801049e7:	e8 cc ef ff ff       	call   801039b8 <mycpu>
801049ec:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801049ef:	8b 45 08             	mov    0x8(%ebp),%eax
801049f2:	83 c0 0c             	add    $0xc,%eax
801049f5:	83 ec 08             	sub    $0x8,%esp
801049f8:	50                   	push   %eax
801049f9:	8d 45 08             	lea    0x8(%ebp),%eax
801049fc:	50                   	push   %eax
801049fd:	e8 5b 00 00 00       	call   80104a5d <getcallerpcs>
80104a02:	83 c4 10             	add    $0x10,%esp
}
80104a05:	90                   	nop
80104a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a09:	c9                   	leave  
80104a0a:	c3                   	ret    

80104a0b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104a0b:	55                   	push   %ebp
80104a0c:	89 e5                	mov    %esp,%ebp
80104a0e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104a11:	83 ec 0c             	sub    $0xc,%esp
80104a14:	ff 75 08             	push   0x8(%ebp)
80104a17:	e8 bc 00 00 00       	call   80104ad8 <holding>
80104a1c:	83 c4 10             	add    $0x10,%esp
80104a1f:	85 c0                	test   %eax,%eax
80104a21:	75 0d                	jne    80104a30 <release+0x25>
    panic("release");
80104a23:	83 ec 0c             	sub    $0xc,%esp
80104a26:	68 16 a6 10 80       	push   $0x8010a616
80104a2b:	e8 79 bb ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104a30:	8b 45 08             	mov    0x8(%ebp),%eax
80104a33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104a44:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104a49:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4c:	8b 55 08             	mov    0x8(%ebp),%edx
80104a4f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104a55:	e8 fb 00 00 00       	call   80104b55 <popcli>
}
80104a5a:	90                   	nop
80104a5b:	c9                   	leave  
80104a5c:	c3                   	ret    

80104a5d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104a5d:	55                   	push   %ebp
80104a5e:	89 e5                	mov    %esp,%ebp
80104a60:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104a63:	8b 45 08             	mov    0x8(%ebp),%eax
80104a66:	83 e8 08             	sub    $0x8,%eax
80104a69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a6c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104a73:	eb 38                	jmp    80104aad <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a75:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104a79:	74 53                	je     80104ace <getcallerpcs+0x71>
80104a7b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104a82:	76 4a                	jbe    80104ace <getcallerpcs+0x71>
80104a84:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104a88:	74 44                	je     80104ace <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104a8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a97:	01 c2                	add    %eax,%edx
80104a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a9c:	8b 40 04             	mov    0x4(%eax),%eax
80104a9f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104aa4:	8b 00                	mov    (%eax),%eax
80104aa6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104aa9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104aad:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ab1:	7e c2                	jle    80104a75 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104ab3:	eb 19                	jmp    80104ace <getcallerpcs+0x71>
    pcs[i] = 0;
80104ab5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ab8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104abf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ac2:	01 d0                	add    %edx,%eax
80104ac4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104aca:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ace:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ad2:	7e e1                	jle    80104ab5 <getcallerpcs+0x58>
}
80104ad4:	90                   	nop
80104ad5:	90                   	nop
80104ad6:	c9                   	leave  
80104ad7:	c3                   	ret    

80104ad8 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104ad8:	55                   	push   %ebp
80104ad9:	89 e5                	mov    %esp,%ebp
80104adb:	53                   	push   %ebx
80104adc:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104adf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae2:	8b 00                	mov    (%eax),%eax
80104ae4:	85 c0                	test   %eax,%eax
80104ae6:	74 16                	je     80104afe <holding+0x26>
80104ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80104aeb:	8b 58 08             	mov    0x8(%eax),%ebx
80104aee:	e8 c5 ee ff ff       	call   801039b8 <mycpu>
80104af3:	39 c3                	cmp    %eax,%ebx
80104af5:	75 07                	jne    80104afe <holding+0x26>
80104af7:	b8 01 00 00 00       	mov    $0x1,%eax
80104afc:	eb 05                	jmp    80104b03 <holding+0x2b>
80104afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b06:	c9                   	leave  
80104b07:	c3                   	ret    

80104b08 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104b08:	55                   	push   %ebp
80104b09:	89 e5                	mov    %esp,%ebp
80104b0b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104b0e:	e8 30 fe ff ff       	call   80104943 <readeflags>
80104b13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104b16:	e8 38 fe ff ff       	call   80104953 <cli>
  if(mycpu()->ncli == 0)
80104b1b:	e8 98 ee ff ff       	call   801039b8 <mycpu>
80104b20:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b26:	85 c0                	test   %eax,%eax
80104b28:	75 14                	jne    80104b3e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104b2a:	e8 89 ee ff ff       	call   801039b8 <mycpu>
80104b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b32:	81 e2 00 02 00 00    	and    $0x200,%edx
80104b38:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104b3e:	e8 75 ee ff ff       	call   801039b8 <mycpu>
80104b43:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104b49:	83 c2 01             	add    $0x1,%edx
80104b4c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104b52:	90                   	nop
80104b53:	c9                   	leave  
80104b54:	c3                   	ret    

80104b55 <popcli>:

void
popcli(void)
{
80104b55:	55                   	push   %ebp
80104b56:	89 e5                	mov    %esp,%ebp
80104b58:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104b5b:	e8 e3 fd ff ff       	call   80104943 <readeflags>
80104b60:	25 00 02 00 00       	and    $0x200,%eax
80104b65:	85 c0                	test   %eax,%eax
80104b67:	74 0d                	je     80104b76 <popcli+0x21>
    panic("popcli - interruptible");
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	68 1e a6 10 80       	push   $0x8010a61e
80104b71:	e8 33 ba ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104b76:	e8 3d ee ff ff       	call   801039b8 <mycpu>
80104b7b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104b81:	83 ea 01             	sub    $0x1,%edx
80104b84:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104b8a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b90:	85 c0                	test   %eax,%eax
80104b92:	79 0d                	jns    80104ba1 <popcli+0x4c>
    panic("popcli");
80104b94:	83 ec 0c             	sub    $0xc,%esp
80104b97:	68 35 a6 10 80       	push   $0x8010a635
80104b9c:	e8 08 ba ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ba1:	e8 12 ee ff ff       	call   801039b8 <mycpu>
80104ba6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104bac:	85 c0                	test   %eax,%eax
80104bae:	75 14                	jne    80104bc4 <popcli+0x6f>
80104bb0:	e8 03 ee ff ff       	call   801039b8 <mycpu>
80104bb5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104bbb:	85 c0                	test   %eax,%eax
80104bbd:	74 05                	je     80104bc4 <popcli+0x6f>
    sti();
80104bbf:	e8 96 fd ff ff       	call   8010495a <sti>
}
80104bc4:	90                   	nop
80104bc5:	c9                   	leave  
80104bc6:	c3                   	ret    

80104bc7 <stosb>:
80104bc7:	55                   	push   %ebp
80104bc8:	89 e5                	mov    %esp,%ebp
80104bca:	57                   	push   %edi
80104bcb:	53                   	push   %ebx
80104bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bcf:	8b 55 10             	mov    0x10(%ebp),%edx
80104bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd5:	89 cb                	mov    %ecx,%ebx
80104bd7:	89 df                	mov    %ebx,%edi
80104bd9:	89 d1                	mov    %edx,%ecx
80104bdb:	fc                   	cld    
80104bdc:	f3 aa                	rep stos %al,%es:(%edi)
80104bde:	89 ca                	mov    %ecx,%edx
80104be0:	89 fb                	mov    %edi,%ebx
80104be2:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104be5:	89 55 10             	mov    %edx,0x10(%ebp)
80104be8:	90                   	nop
80104be9:	5b                   	pop    %ebx
80104bea:	5f                   	pop    %edi
80104beb:	5d                   	pop    %ebp
80104bec:	c3                   	ret    

80104bed <stosl>:
80104bed:	55                   	push   %ebp
80104bee:	89 e5                	mov    %esp,%ebp
80104bf0:	57                   	push   %edi
80104bf1:	53                   	push   %ebx
80104bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bf5:	8b 55 10             	mov    0x10(%ebp),%edx
80104bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bfb:	89 cb                	mov    %ecx,%ebx
80104bfd:	89 df                	mov    %ebx,%edi
80104bff:	89 d1                	mov    %edx,%ecx
80104c01:	fc                   	cld    
80104c02:	f3 ab                	rep stos %eax,%es:(%edi)
80104c04:	89 ca                	mov    %ecx,%edx
80104c06:	89 fb                	mov    %edi,%ebx
80104c08:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104c0b:	89 55 10             	mov    %edx,0x10(%ebp)
80104c0e:	90                   	nop
80104c0f:	5b                   	pop    %ebx
80104c10:	5f                   	pop    %edi
80104c11:	5d                   	pop    %ebp
80104c12:	c3                   	ret    

80104c13 <memset>:
80104c13:	55                   	push   %ebp
80104c14:	89 e5                	mov    %esp,%ebp
80104c16:	8b 45 08             	mov    0x8(%ebp),%eax
80104c19:	83 e0 03             	and    $0x3,%eax
80104c1c:	85 c0                	test   %eax,%eax
80104c1e:	75 43                	jne    80104c63 <memset+0x50>
80104c20:	8b 45 10             	mov    0x10(%ebp),%eax
80104c23:	83 e0 03             	and    $0x3,%eax
80104c26:	85 c0                	test   %eax,%eax
80104c28:	75 39                	jne    80104c63 <memset+0x50>
80104c2a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
80104c31:	8b 45 10             	mov    0x10(%ebp),%eax
80104c34:	c1 e8 02             	shr    $0x2,%eax
80104c37:	89 c2                	mov    %eax,%edx
80104c39:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3c:	c1 e0 18             	shl    $0x18,%eax
80104c3f:	89 c1                	mov    %eax,%ecx
80104c41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c44:	c1 e0 10             	shl    $0x10,%eax
80104c47:	09 c1                	or     %eax,%ecx
80104c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4c:	c1 e0 08             	shl    $0x8,%eax
80104c4f:	09 c8                	or     %ecx,%eax
80104c51:	0b 45 0c             	or     0xc(%ebp),%eax
80104c54:	52                   	push   %edx
80104c55:	50                   	push   %eax
80104c56:	ff 75 08             	push   0x8(%ebp)
80104c59:	e8 8f ff ff ff       	call   80104bed <stosl>
80104c5e:	83 c4 0c             	add    $0xc,%esp
80104c61:	eb 12                	jmp    80104c75 <memset+0x62>
80104c63:	8b 45 10             	mov    0x10(%ebp),%eax
80104c66:	50                   	push   %eax
80104c67:	ff 75 0c             	push   0xc(%ebp)
80104c6a:	ff 75 08             	push   0x8(%ebp)
80104c6d:	e8 55 ff ff ff       	call   80104bc7 <stosb>
80104c72:	83 c4 0c             	add    $0xc,%esp
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	c9                   	leave  
80104c79:	c3                   	ret    

80104c7a <memcmp>:
80104c7a:	55                   	push   %ebp
80104c7b:	89 e5                	mov    %esp,%ebp
80104c7d:	83 ec 10             	sub    $0x10,%esp
80104c80:	8b 45 08             	mov    0x8(%ebp),%eax
80104c83:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c89:	89 45 f8             	mov    %eax,-0x8(%ebp)
80104c8c:	eb 30                	jmp    80104cbe <memcmp+0x44>
80104c8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c91:	0f b6 10             	movzbl (%eax),%edx
80104c94:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c97:	0f b6 00             	movzbl (%eax),%eax
80104c9a:	38 c2                	cmp    %al,%dl
80104c9c:	74 18                	je     80104cb6 <memcmp+0x3c>
80104c9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca1:	0f b6 00             	movzbl (%eax),%eax
80104ca4:	0f b6 d0             	movzbl %al,%edx
80104ca7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104caa:	0f b6 00             	movzbl (%eax),%eax
80104cad:	0f b6 c8             	movzbl %al,%ecx
80104cb0:	89 d0                	mov    %edx,%eax
80104cb2:	29 c8                	sub    %ecx,%eax
80104cb4:	eb 1a                	jmp    80104cd0 <memcmp+0x56>
80104cb6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104cba:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cbe:	8b 45 10             	mov    0x10(%ebp),%eax
80104cc1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cc4:	89 55 10             	mov    %edx,0x10(%ebp)
80104cc7:	85 c0                	test   %eax,%eax
80104cc9:	75 c3                	jne    80104c8e <memcmp+0x14>
80104ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80104cd0:	c9                   	leave  
80104cd1:	c3                   	ret    

80104cd2 <memmove>:
80104cd2:	55                   	push   %ebp
80104cd3:	89 e5                	mov    %esp,%ebp
80104cd5:	83 ec 10             	sub    $0x10,%esp
80104cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cdb:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	89 45 f8             	mov    %eax,-0x8(%ebp)
80104ce4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104cea:	73 54                	jae    80104d40 <memmove+0x6e>
80104cec:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104cef:	8b 45 10             	mov    0x10(%ebp),%eax
80104cf2:	01 d0                	add    %edx,%eax
80104cf4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104cf7:	73 47                	jae    80104d40 <memmove+0x6e>
80104cf9:	8b 45 10             	mov    0x10(%ebp),%eax
80104cfc:	01 45 fc             	add    %eax,-0x4(%ebp)
80104cff:	8b 45 10             	mov    0x10(%ebp),%eax
80104d02:	01 45 f8             	add    %eax,-0x8(%ebp)
80104d05:	eb 13                	jmp    80104d1a <memmove+0x48>
80104d07:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104d0b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104d0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d12:	0f b6 10             	movzbl (%eax),%edx
80104d15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d18:	88 10                	mov    %dl,(%eax)
80104d1a:	8b 45 10             	mov    0x10(%ebp),%eax
80104d1d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d20:	89 55 10             	mov    %edx,0x10(%ebp)
80104d23:	85 c0                	test   %eax,%eax
80104d25:	75 e0                	jne    80104d07 <memmove+0x35>
80104d27:	eb 24                	jmp    80104d4d <memmove+0x7b>
80104d29:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d2c:	8d 42 01             	lea    0x1(%edx),%eax
80104d2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104d32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d35:	8d 48 01             	lea    0x1(%eax),%ecx
80104d38:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104d3b:	0f b6 12             	movzbl (%edx),%edx
80104d3e:	88 10                	mov    %dl,(%eax)
80104d40:	8b 45 10             	mov    0x10(%ebp),%eax
80104d43:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d46:	89 55 10             	mov    %edx,0x10(%ebp)
80104d49:	85 c0                	test   %eax,%eax
80104d4b:	75 dc                	jne    80104d29 <memmove+0x57>
80104d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d50:	c9                   	leave  
80104d51:	c3                   	ret    

80104d52 <memcpy>:
80104d52:	55                   	push   %ebp
80104d53:	89 e5                	mov    %esp,%ebp
80104d55:	ff 75 10             	push   0x10(%ebp)
80104d58:	ff 75 0c             	push   0xc(%ebp)
80104d5b:	ff 75 08             	push   0x8(%ebp)
80104d5e:	e8 6f ff ff ff       	call   80104cd2 <memmove>
80104d63:	83 c4 0c             	add    $0xc,%esp
80104d66:	c9                   	leave  
80104d67:	c3                   	ret    

80104d68 <strncmp>:
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	eb 0c                	jmp    80104d79 <strncmp+0x11>
80104d6d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d71:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104d75:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104d79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d7d:	74 1a                	je     80104d99 <strncmp+0x31>
80104d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d82:	0f b6 00             	movzbl (%eax),%eax
80104d85:	84 c0                	test   %al,%al
80104d87:	74 10                	je     80104d99 <strncmp+0x31>
80104d89:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8c:	0f b6 10             	movzbl (%eax),%edx
80104d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d92:	0f b6 00             	movzbl (%eax),%eax
80104d95:	38 c2                	cmp    %al,%dl
80104d97:	74 d4                	je     80104d6d <strncmp+0x5>
80104d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d9d:	75 07                	jne    80104da6 <strncmp+0x3e>
80104d9f:	b8 00 00 00 00       	mov    $0x0,%eax
80104da4:	eb 16                	jmp    80104dbc <strncmp+0x54>
80104da6:	8b 45 08             	mov    0x8(%ebp),%eax
80104da9:	0f b6 00             	movzbl (%eax),%eax
80104dac:	0f b6 d0             	movzbl %al,%edx
80104daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db2:	0f b6 00             	movzbl (%eax),%eax
80104db5:	0f b6 c8             	movzbl %al,%ecx
80104db8:	89 d0                	mov    %edx,%eax
80104dba:	29 c8                	sub    %ecx,%eax
80104dbc:	5d                   	pop    %ebp
80104dbd:	c3                   	ret    

80104dbe <strncpy>:
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
80104dc1:	83 ec 10             	sub    $0x10,%esp
80104dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc7:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104dca:	90                   	nop
80104dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80104dce:	8d 50 ff             	lea    -0x1(%eax),%edx
80104dd1:	89 55 10             	mov    %edx,0x10(%ebp)
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	7e 2c                	jle    80104e04 <strncpy+0x46>
80104dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ddb:	8d 42 01             	lea    0x1(%edx),%eax
80104dde:	89 45 0c             	mov    %eax,0xc(%ebp)
80104de1:	8b 45 08             	mov    0x8(%ebp),%eax
80104de4:	8d 48 01             	lea    0x1(%eax),%ecx
80104de7:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104dea:	0f b6 12             	movzbl (%edx),%edx
80104ded:	88 10                	mov    %dl,(%eax)
80104def:	0f b6 00             	movzbl (%eax),%eax
80104df2:	84 c0                	test   %al,%al
80104df4:	75 d5                	jne    80104dcb <strncpy+0xd>
80104df6:	eb 0c                	jmp    80104e04 <strncpy+0x46>
80104df8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfb:	8d 50 01             	lea    0x1(%eax),%edx
80104dfe:	89 55 08             	mov    %edx,0x8(%ebp)
80104e01:	c6 00 00             	movb   $0x0,(%eax)
80104e04:	8b 45 10             	mov    0x10(%ebp),%eax
80104e07:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e0a:	89 55 10             	mov    %edx,0x10(%ebp)
80104e0d:	85 c0                	test   %eax,%eax
80104e0f:	7f e7                	jg     80104df8 <strncpy+0x3a>
80104e11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e14:	c9                   	leave  
80104e15:	c3                   	ret    

80104e16 <safestrcpy>:
80104e16:	55                   	push   %ebp
80104e17:	89 e5                	mov    %esp,%ebp
80104e19:	83 ec 10             	sub    $0x10,%esp
80104e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e26:	7f 05                	jg     80104e2d <safestrcpy+0x17>
80104e28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2b:	eb 32                	jmp    80104e5f <safestrcpy+0x49>
80104e2d:	90                   	nop
80104e2e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e36:	7e 1e                	jle    80104e56 <safestrcpy+0x40>
80104e38:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e3b:	8d 42 01             	lea    0x1(%edx),%eax
80104e3e:	89 45 0c             	mov    %eax,0xc(%ebp)
80104e41:	8b 45 08             	mov    0x8(%ebp),%eax
80104e44:	8d 48 01             	lea    0x1(%eax),%ecx
80104e47:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104e4a:	0f b6 12             	movzbl (%edx),%edx
80104e4d:	88 10                	mov    %dl,(%eax)
80104e4f:	0f b6 00             	movzbl (%eax),%eax
80104e52:	84 c0                	test   %al,%al
80104e54:	75 d8                	jne    80104e2e <safestrcpy+0x18>
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	c6 00 00             	movb   $0x0,(%eax)
80104e5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5f:	c9                   	leave  
80104e60:	c3                   	ret    

80104e61 <strlen>:
80104e61:	55                   	push   %ebp
80104e62:	89 e5                	mov    %esp,%ebp
80104e64:	83 ec 10             	sub    $0x10,%esp
80104e67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104e6e:	eb 04                	jmp    80104e74 <strlen+0x13>
80104e70:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e74:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e77:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7a:	01 d0                	add    %edx,%eax
80104e7c:	0f b6 00             	movzbl (%eax),%eax
80104e7f:	84 c0                	test   %al,%al
80104e81:	75 ed                	jne    80104e70 <strlen+0xf>
80104e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e86:	c9                   	leave  
80104e87:	c3                   	ret    

80104e88 <swtch>:
80104e88:	8b 44 24 04          	mov    0x4(%esp),%eax
80104e8c:	8b 54 24 08          	mov    0x8(%esp),%edx
80104e90:	55                   	push   %ebp
80104e91:	53                   	push   %ebx
80104e92:	56                   	push   %esi
80104e93:	57                   	push   %edi
80104e94:	89 20                	mov    %esp,(%eax)
80104e96:	89 d4                	mov    %edx,%esp
80104e98:	5f                   	pop    %edi
80104e99:	5e                   	pop    %esi
80104e9a:	5b                   	pop    %ebx
80104e9b:	5d                   	pop    %ebp
80104e9c:	c3                   	ret    

80104e9d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e9d:	55                   	push   %ebp
80104e9e:	89 e5                	mov    %esp,%ebp
80104ea0:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104ea3:	e8 88 eb ff ff       	call   80103a30 <myproc>
80104ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eae:	8b 00                	mov    (%eax),%eax
80104eb0:	39 45 08             	cmp    %eax,0x8(%ebp)
80104eb3:	73 0f                	jae    80104ec4 <fetchint+0x27>
80104eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb8:	8d 50 04             	lea    0x4(%eax),%edx
80104ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebe:	8b 00                	mov    (%eax),%eax
80104ec0:	39 c2                	cmp    %eax,%edx
80104ec2:	76 07                	jbe    80104ecb <fetchint+0x2e>
    return -1;
80104ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec9:	eb 0f                	jmp    80104eda <fetchint+0x3d>
  *ip = *(int*)(addr);
80104ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ece:	8b 10                	mov    (%eax),%edx
80104ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed3:	89 10                	mov    %edx,(%eax)
  return 0;
80104ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104eda:	c9                   	leave  
80104edb:	c3                   	ret    

80104edc <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104edc:	55                   	push   %ebp
80104edd:	89 e5                	mov    %esp,%ebp
80104edf:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104ee2:	e8 49 eb ff ff       	call   80103a30 <myproc>
80104ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eed:	8b 00                	mov    (%eax),%eax
80104eef:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ef2:	72 07                	jb     80104efb <fetchstr+0x1f>
    return -1;
80104ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef9:	eb 41                	jmp    80104f3c <fetchstr+0x60>
  *pp = (char*)addr;
80104efb:	8b 55 08             	mov    0x8(%ebp),%edx
80104efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f01:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	8b 00                	mov    (%eax),%eax
80104f08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f0e:	8b 00                	mov    (%eax),%eax
80104f10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f13:	eb 1a                	jmp    80104f2f <fetchstr+0x53>
    if(*s == 0)
80104f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f18:	0f b6 00             	movzbl (%eax),%eax
80104f1b:	84 c0                	test   %al,%al
80104f1d:	75 0c                	jne    80104f2b <fetchstr+0x4f>
      return s - *pp;
80104f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f22:	8b 10                	mov    (%eax),%edx
80104f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f27:	29 d0                	sub    %edx,%eax
80104f29:	eb 11                	jmp    80104f3c <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f32:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104f35:	72 de                	jb     80104f15 <fetchstr+0x39>
  }
  return -1;
80104f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f3c:	c9                   	leave  
80104f3d:	c3                   	ret    

80104f3e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104f3e:	55                   	push   %ebp
80104f3f:	89 e5                	mov    %esp,%ebp
80104f41:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f44:	e8 e7 ea ff ff       	call   80103a30 <myproc>
80104f49:	8b 40 18             	mov    0x18(%eax),%eax
80104f4c:	8b 50 44             	mov    0x44(%eax),%edx
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	c1 e0 02             	shl    $0x2,%eax
80104f55:	01 d0                	add    %edx,%eax
80104f57:	83 c0 04             	add    $0x4,%eax
80104f5a:	83 ec 08             	sub    $0x8,%esp
80104f5d:	ff 75 0c             	push   0xc(%ebp)
80104f60:	50                   	push   %eax
80104f61:	e8 37 ff ff ff       	call   80104e9d <fetchint>
80104f66:	83 c4 10             	add    $0x10,%esp
}
80104f69:	c9                   	leave  
80104f6a:	c3                   	ret    

80104f6b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f6b:	55                   	push   %ebp
80104f6c:	89 e5                	mov    %esp,%ebp
80104f6e:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104f71:	e8 ba ea ff ff       	call   80103a30 <myproc>
80104f76:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104f79:	83 ec 08             	sub    $0x8,%esp
80104f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f7f:	50                   	push   %eax
80104f80:	ff 75 08             	push   0x8(%ebp)
80104f83:	e8 b6 ff ff ff       	call   80104f3e <argint>
80104f88:	83 c4 10             	add    $0x10,%esp
80104f8b:	85 c0                	test   %eax,%eax
80104f8d:	79 07                	jns    80104f96 <argptr+0x2b>
    return -1;
80104f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f94:	eb 3b                	jmp    80104fd1 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f9a:	78 1f                	js     80104fbb <argptr+0x50>
80104f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9f:	8b 00                	mov    (%eax),%eax
80104fa1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fa4:	39 d0                	cmp    %edx,%eax
80104fa6:	76 13                	jbe    80104fbb <argptr+0x50>
80104fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fab:	89 c2                	mov    %eax,%edx
80104fad:	8b 45 10             	mov    0x10(%ebp),%eax
80104fb0:	01 c2                	add    %eax,%edx
80104fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb5:	8b 00                	mov    (%eax),%eax
80104fb7:	39 c2                	cmp    %eax,%edx
80104fb9:	76 07                	jbe    80104fc2 <argptr+0x57>
    return -1;
80104fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc0:	eb 0f                	jmp    80104fd1 <argptr+0x66>
  *pp = (char*)i;
80104fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc5:	89 c2                	mov    %eax,%edx
80104fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fca:	89 10                	mov    %edx,(%eax)
  return 0;
80104fcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fd1:	c9                   	leave  
80104fd2:	c3                   	ret    

80104fd3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104fd3:	55                   	push   %ebp
80104fd4:	89 e5                	mov    %esp,%ebp
80104fd6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104fd9:	83 ec 08             	sub    $0x8,%esp
80104fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fdf:	50                   	push   %eax
80104fe0:	ff 75 08             	push   0x8(%ebp)
80104fe3:	e8 56 ff ff ff       	call   80104f3e <argint>
80104fe8:	83 c4 10             	add    $0x10,%esp
80104feb:	85 c0                	test   %eax,%eax
80104fed:	79 07                	jns    80104ff6 <argstr+0x23>
    return -1;
80104fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff4:	eb 12                	jmp    80105008 <argstr+0x35>
  return fetchstr(addr, pp);
80104ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff9:	83 ec 08             	sub    $0x8,%esp
80104ffc:	ff 75 0c             	push   0xc(%ebp)
80104fff:	50                   	push   %eax
80105000:	e8 d7 fe ff ff       	call   80104edc <fetchstr>
80105005:	83 c4 10             	add    $0x10,%esp
}
80105008:	c9                   	leave  
80105009:	c3                   	ret    

8010500a <syscall>:
[SYS_wait2]   sys_wait2,
};

void
syscall(void)
{
8010500a:	55                   	push   %ebp
8010500b:	89 e5                	mov    %esp,%ebp
8010500d:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105010:	e8 1b ea ff ff       	call   80103a30 <myproc>
80105015:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501b:	8b 40 18             	mov    0x18(%eax),%eax
8010501e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105021:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105024:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105028:	7e 2f                	jle    80105059 <syscall+0x4f>
8010502a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502d:	83 f8 17             	cmp    $0x17,%eax
80105030:	77 27                	ja     80105059 <syscall+0x4f>
80105032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105035:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010503c:	85 c0                	test   %eax,%eax
8010503e:	74 19                	je     80105059 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105040:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105043:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010504a:	ff d0                	call   *%eax
8010504c:	89 c2                	mov    %eax,%edx
8010504e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105051:	8b 40 18             	mov    0x18(%eax),%eax
80105054:	89 50 1c             	mov    %edx,0x1c(%eax)
80105057:	eb 2c                	jmp    80105085 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010505f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105062:	8b 40 10             	mov    0x10(%eax),%eax
80105065:	ff 75 f0             	push   -0x10(%ebp)
80105068:	52                   	push   %edx
80105069:	50                   	push   %eax
8010506a:	68 3c a6 10 80       	push   $0x8010a63c
8010506f:	e8 80 b3 ff ff       	call   801003f4 <cprintf>
80105074:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010507a:	8b 40 18             	mov    0x18(%eax),%eax
8010507d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105084:	90                   	nop
80105085:	90                   	nop
80105086:	c9                   	leave  
80105087:	c3                   	ret    

80105088 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010508e:	83 ec 08             	sub    $0x8,%esp
80105091:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105094:	50                   	push   %eax
80105095:	ff 75 08             	push   0x8(%ebp)
80105098:	e8 a1 fe ff ff       	call   80104f3e <argint>
8010509d:	83 c4 10             	add    $0x10,%esp
801050a0:	85 c0                	test   %eax,%eax
801050a2:	79 07                	jns    801050ab <argfd+0x23>
    return -1;
801050a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a9:	eb 4f                	jmp    801050fa <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801050ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ae:	85 c0                	test   %eax,%eax
801050b0:	78 20                	js     801050d2 <argfd+0x4a>
801050b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b5:	83 f8 0f             	cmp    $0xf,%eax
801050b8:	7f 18                	jg     801050d2 <argfd+0x4a>
801050ba:	e8 71 e9 ff ff       	call   80103a30 <myproc>
801050bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050c2:	83 c2 08             	add    $0x8,%edx
801050c5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050d0:	75 07                	jne    801050d9 <argfd+0x51>
    return -1;
801050d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d7:	eb 21                	jmp    801050fa <argfd+0x72>
  if(pfd)
801050d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050dd:	74 08                	je     801050e7 <argfd+0x5f>
    *pfd = fd;
801050df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e5:	89 10                	mov    %edx,(%eax)
  if(pf)
801050e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050eb:	74 08                	je     801050f5 <argfd+0x6d>
    *pf = f;
801050ed:	8b 45 10             	mov    0x10(%ebp),%eax
801050f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f3:	89 10                	mov    %edx,(%eax)
  return 0;
801050f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105102:	e8 29 e9 ff ff       	call   80103a30 <myproc>
80105107:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010510a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105111:	eb 2a                	jmp    8010513d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105116:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105119:	83 c2 08             	add    $0x8,%edx
8010511c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105120:	85 c0                	test   %eax,%eax
80105122:	75 15                	jne    80105139 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105127:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010512a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010512d:	8b 55 08             	mov    0x8(%ebp),%edx
80105130:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105137:	eb 0f                	jmp    80105148 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105139:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010513d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105141:	7e d0                	jle    80105113 <fdalloc+0x17>
    }
  }
  return -1;
80105143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <sys_dup>:

int
sys_dup(void)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
8010514d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105150:	83 ec 04             	sub    $0x4,%esp
80105153:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105156:	50                   	push   %eax
80105157:	6a 00                	push   $0x0
80105159:	6a 00                	push   $0x0
8010515b:	e8 28 ff ff ff       	call   80105088 <argfd>
80105160:	83 c4 10             	add    $0x10,%esp
80105163:	85 c0                	test   %eax,%eax
80105165:	79 07                	jns    8010516e <sys_dup+0x24>
    return -1;
80105167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516c:	eb 31                	jmp    8010519f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010516e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105171:	83 ec 0c             	sub    $0xc,%esp
80105174:	50                   	push   %eax
80105175:	e8 82 ff ff ff       	call   801050fc <fdalloc>
8010517a:	83 c4 10             	add    $0x10,%esp
8010517d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105180:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105184:	79 07                	jns    8010518d <sys_dup+0x43>
    return -1;
80105186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518b:	eb 12                	jmp    8010519f <sys_dup+0x55>
  filedup(f);
8010518d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105190:	83 ec 0c             	sub    $0xc,%esp
80105193:	50                   	push   %eax
80105194:	e8 b1 be ff ff       	call   8010104a <filedup>
80105199:	83 c4 10             	add    $0x10,%esp
  return fd;
8010519c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010519f:	c9                   	leave  
801051a0:	c3                   	ret    

801051a1 <sys_read>:

int
sys_read(void)
{
801051a1:	55                   	push   %ebp
801051a2:	89 e5                	mov    %esp,%ebp
801051a4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051a7:	83 ec 04             	sub    $0x4,%esp
801051aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051ad:	50                   	push   %eax
801051ae:	6a 00                	push   $0x0
801051b0:	6a 00                	push   $0x0
801051b2:	e8 d1 fe ff ff       	call   80105088 <argfd>
801051b7:	83 c4 10             	add    $0x10,%esp
801051ba:	85 c0                	test   %eax,%eax
801051bc:	78 2e                	js     801051ec <sys_read+0x4b>
801051be:	83 ec 08             	sub    $0x8,%esp
801051c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051c4:	50                   	push   %eax
801051c5:	6a 02                	push   $0x2
801051c7:	e8 72 fd ff ff       	call   80104f3e <argint>
801051cc:	83 c4 10             	add    $0x10,%esp
801051cf:	85 c0                	test   %eax,%eax
801051d1:	78 19                	js     801051ec <sys_read+0x4b>
801051d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d6:	83 ec 04             	sub    $0x4,%esp
801051d9:	50                   	push   %eax
801051da:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051dd:	50                   	push   %eax
801051de:	6a 01                	push   $0x1
801051e0:	e8 86 fd ff ff       	call   80104f6b <argptr>
801051e5:	83 c4 10             	add    $0x10,%esp
801051e8:	85 c0                	test   %eax,%eax
801051ea:	79 07                	jns    801051f3 <sys_read+0x52>
    return -1;
801051ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f1:	eb 17                	jmp    8010520a <sys_read+0x69>
  return fileread(f, p, n);
801051f3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fc:	83 ec 04             	sub    $0x4,%esp
801051ff:	51                   	push   %ecx
80105200:	52                   	push   %edx
80105201:	50                   	push   %eax
80105202:	e8 d3 bf ff ff       	call   801011da <fileread>
80105207:	83 c4 10             	add    $0x10,%esp
}
8010520a:	c9                   	leave  
8010520b:	c3                   	ret    

8010520c <sys_write>:

int
sys_write(void)
{
8010520c:	55                   	push   %ebp
8010520d:	89 e5                	mov    %esp,%ebp
8010520f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105212:	83 ec 04             	sub    $0x4,%esp
80105215:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105218:	50                   	push   %eax
80105219:	6a 00                	push   $0x0
8010521b:	6a 00                	push   $0x0
8010521d:	e8 66 fe ff ff       	call   80105088 <argfd>
80105222:	83 c4 10             	add    $0x10,%esp
80105225:	85 c0                	test   %eax,%eax
80105227:	78 2e                	js     80105257 <sys_write+0x4b>
80105229:	83 ec 08             	sub    $0x8,%esp
8010522c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010522f:	50                   	push   %eax
80105230:	6a 02                	push   $0x2
80105232:	e8 07 fd ff ff       	call   80104f3e <argint>
80105237:	83 c4 10             	add    $0x10,%esp
8010523a:	85 c0                	test   %eax,%eax
8010523c:	78 19                	js     80105257 <sys_write+0x4b>
8010523e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105241:	83 ec 04             	sub    $0x4,%esp
80105244:	50                   	push   %eax
80105245:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105248:	50                   	push   %eax
80105249:	6a 01                	push   $0x1
8010524b:	e8 1b fd ff ff       	call   80104f6b <argptr>
80105250:	83 c4 10             	add    $0x10,%esp
80105253:	85 c0                	test   %eax,%eax
80105255:	79 07                	jns    8010525e <sys_write+0x52>
    return -1;
80105257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525c:	eb 17                	jmp    80105275 <sys_write+0x69>
  return filewrite(f, p, n);
8010525e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105261:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105267:	83 ec 04             	sub    $0x4,%esp
8010526a:	51                   	push   %ecx
8010526b:	52                   	push   %edx
8010526c:	50                   	push   %eax
8010526d:	e8 20 c0 ff ff       	call   80101292 <filewrite>
80105272:	83 c4 10             	add    $0x10,%esp
}
80105275:	c9                   	leave  
80105276:	c3                   	ret    

80105277 <sys_close>:

int
sys_close(void)
{
80105277:	55                   	push   %ebp
80105278:	89 e5                	mov    %esp,%ebp
8010527a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010527d:	83 ec 04             	sub    $0x4,%esp
80105280:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105283:	50                   	push   %eax
80105284:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105287:	50                   	push   %eax
80105288:	6a 00                	push   $0x0
8010528a:	e8 f9 fd ff ff       	call   80105088 <argfd>
8010528f:	83 c4 10             	add    $0x10,%esp
80105292:	85 c0                	test   %eax,%eax
80105294:	79 07                	jns    8010529d <sys_close+0x26>
    return -1;
80105296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529b:	eb 27                	jmp    801052c4 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010529d:	e8 8e e7 ff ff       	call   80103a30 <myproc>
801052a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a5:	83 c2 08             	add    $0x8,%edx
801052a8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801052af:	00 
  fileclose(f);
801052b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b3:	83 ec 0c             	sub    $0xc,%esp
801052b6:	50                   	push   %eax
801052b7:	e8 df bd ff ff       	call   8010109b <fileclose>
801052bc:	83 c4 10             	add    $0x10,%esp
  return 0;
801052bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052c4:	c9                   	leave  
801052c5:	c3                   	ret    

801052c6 <sys_fstat>:

int
sys_fstat(void)
{
801052c6:	55                   	push   %ebp
801052c7:	89 e5                	mov    %esp,%ebp
801052c9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801052cc:	83 ec 04             	sub    $0x4,%esp
801052cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052d2:	50                   	push   %eax
801052d3:	6a 00                	push   $0x0
801052d5:	6a 00                	push   $0x0
801052d7:	e8 ac fd ff ff       	call   80105088 <argfd>
801052dc:	83 c4 10             	add    $0x10,%esp
801052df:	85 c0                	test   %eax,%eax
801052e1:	78 17                	js     801052fa <sys_fstat+0x34>
801052e3:	83 ec 04             	sub    $0x4,%esp
801052e6:	6a 14                	push   $0x14
801052e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052eb:	50                   	push   %eax
801052ec:	6a 01                	push   $0x1
801052ee:	e8 78 fc ff ff       	call   80104f6b <argptr>
801052f3:	83 c4 10             	add    $0x10,%esp
801052f6:	85 c0                	test   %eax,%eax
801052f8:	79 07                	jns    80105301 <sys_fstat+0x3b>
    return -1;
801052fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ff:	eb 13                	jmp    80105314 <sys_fstat+0x4e>
  return filestat(f, st);
80105301:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105307:	83 ec 08             	sub    $0x8,%esp
8010530a:	52                   	push   %edx
8010530b:	50                   	push   %eax
8010530c:	e8 72 be ff ff       	call   80101183 <filestat>
80105311:	83 c4 10             	add    $0x10,%esp
}
80105314:	c9                   	leave  
80105315:	c3                   	ret    

80105316 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105316:	55                   	push   %ebp
80105317:	89 e5                	mov    %esp,%ebp
80105319:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010531c:	83 ec 08             	sub    $0x8,%esp
8010531f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105322:	50                   	push   %eax
80105323:	6a 00                	push   $0x0
80105325:	e8 a9 fc ff ff       	call   80104fd3 <argstr>
8010532a:	83 c4 10             	add    $0x10,%esp
8010532d:	85 c0                	test   %eax,%eax
8010532f:	78 15                	js     80105346 <sys_link+0x30>
80105331:	83 ec 08             	sub    $0x8,%esp
80105334:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105337:	50                   	push   %eax
80105338:	6a 01                	push   $0x1
8010533a:	e8 94 fc ff ff       	call   80104fd3 <argstr>
8010533f:	83 c4 10             	add    $0x10,%esp
80105342:	85 c0                	test   %eax,%eax
80105344:	79 0a                	jns    80105350 <sys_link+0x3a>
    return -1;
80105346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010534b:	e9 68 01 00 00       	jmp    801054b8 <sys_link+0x1a2>

  begin_op();
80105350:	e8 e7 dc ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
80105355:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105358:	83 ec 0c             	sub    $0xc,%esp
8010535b:	50                   	push   %eax
8010535c:	e8 bc d1 ff ff       	call   8010251d <namei>
80105361:	83 c4 10             	add    $0x10,%esp
80105364:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105367:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010536b:	75 0f                	jne    8010537c <sys_link+0x66>
    end_op();
8010536d:	e8 56 dd ff ff       	call   801030c8 <end_op>
    return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	e9 3c 01 00 00       	jmp    801054b8 <sys_link+0x1a2>
  }

  ilock(ip);
8010537c:	83 ec 0c             	sub    $0xc,%esp
8010537f:	ff 75 f4             	push   -0xc(%ebp)
80105382:	e8 63 c6 ff ff       	call   801019ea <ilock>
80105387:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010538a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105391:	66 83 f8 01          	cmp    $0x1,%ax
80105395:	75 1d                	jne    801053b4 <sys_link+0x9e>
    iunlockput(ip);
80105397:	83 ec 0c             	sub    $0xc,%esp
8010539a:	ff 75 f4             	push   -0xc(%ebp)
8010539d:	e8 79 c8 ff ff       	call   80101c1b <iunlockput>
801053a2:	83 c4 10             	add    $0x10,%esp
    end_op();
801053a5:	e8 1e dd ff ff       	call   801030c8 <end_op>
    return -1;
801053aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053af:	e9 04 01 00 00       	jmp    801054b8 <sys_link+0x1a2>
  }

  ip->nlink++;
801053b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053bb:	83 c0 01             	add    $0x1,%eax
801053be:	89 c2                	mov    %eax,%edx
801053c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801053c7:	83 ec 0c             	sub    $0xc,%esp
801053ca:	ff 75 f4             	push   -0xc(%ebp)
801053cd:	e8 3b c4 ff ff       	call   8010180d <iupdate>
801053d2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801053d5:	83 ec 0c             	sub    $0xc,%esp
801053d8:	ff 75 f4             	push   -0xc(%ebp)
801053db:	e8 1d c7 ff ff       	call   80101afd <iunlock>
801053e0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801053e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801053e6:	83 ec 08             	sub    $0x8,%esp
801053e9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801053ec:	52                   	push   %edx
801053ed:	50                   	push   %eax
801053ee:	e8 46 d1 ff ff       	call   80102539 <nameiparent>
801053f3:	83 c4 10             	add    $0x10,%esp
801053f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053fd:	74 71                	je     80105470 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801053ff:	83 ec 0c             	sub    $0xc,%esp
80105402:	ff 75 f0             	push   -0x10(%ebp)
80105405:	e8 e0 c5 ff ff       	call   801019ea <ilock>
8010540a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010540d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105410:	8b 10                	mov    (%eax),%edx
80105412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105415:	8b 00                	mov    (%eax),%eax
80105417:	39 c2                	cmp    %eax,%edx
80105419:	75 1d                	jne    80105438 <sys_link+0x122>
8010541b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541e:	8b 40 04             	mov    0x4(%eax),%eax
80105421:	83 ec 04             	sub    $0x4,%esp
80105424:	50                   	push   %eax
80105425:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105428:	50                   	push   %eax
80105429:	ff 75 f0             	push   -0x10(%ebp)
8010542c:	e8 55 ce ff ff       	call   80102286 <dirlink>
80105431:	83 c4 10             	add    $0x10,%esp
80105434:	85 c0                	test   %eax,%eax
80105436:	79 10                	jns    80105448 <sys_link+0x132>
    iunlockput(dp);
80105438:	83 ec 0c             	sub    $0xc,%esp
8010543b:	ff 75 f0             	push   -0x10(%ebp)
8010543e:	e8 d8 c7 ff ff       	call   80101c1b <iunlockput>
80105443:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105446:	eb 29                	jmp    80105471 <sys_link+0x15b>
  }
  iunlockput(dp);
80105448:	83 ec 0c             	sub    $0xc,%esp
8010544b:	ff 75 f0             	push   -0x10(%ebp)
8010544e:	e8 c8 c7 ff ff       	call   80101c1b <iunlockput>
80105453:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105456:	83 ec 0c             	sub    $0xc,%esp
80105459:	ff 75 f4             	push   -0xc(%ebp)
8010545c:	e8 ea c6 ff ff       	call   80101b4b <iput>
80105461:	83 c4 10             	add    $0x10,%esp

  end_op();
80105464:	e8 5f dc ff ff       	call   801030c8 <end_op>

  return 0;
80105469:	b8 00 00 00 00       	mov    $0x0,%eax
8010546e:	eb 48                	jmp    801054b8 <sys_link+0x1a2>
    goto bad;
80105470:	90                   	nop

bad:
  ilock(ip);
80105471:	83 ec 0c             	sub    $0xc,%esp
80105474:	ff 75 f4             	push   -0xc(%ebp)
80105477:	e8 6e c5 ff ff       	call   801019ea <ilock>
8010547c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010547f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105482:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105486:	83 e8 01             	sub    $0x1,%eax
80105489:	89 c2                	mov    %eax,%edx
8010548b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010548e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105492:	83 ec 0c             	sub    $0xc,%esp
80105495:	ff 75 f4             	push   -0xc(%ebp)
80105498:	e8 70 c3 ff ff       	call   8010180d <iupdate>
8010549d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801054a0:	83 ec 0c             	sub    $0xc,%esp
801054a3:	ff 75 f4             	push   -0xc(%ebp)
801054a6:	e8 70 c7 ff ff       	call   80101c1b <iunlockput>
801054ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801054ae:	e8 15 dc ff ff       	call   801030c8 <end_op>
  return -1;
801054b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054b8:	c9                   	leave  
801054b9:	c3                   	ret    

801054ba <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801054ba:	55                   	push   %ebp
801054bb:	89 e5                	mov    %esp,%ebp
801054bd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054c0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801054c7:	eb 40                	jmp    80105509 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cc:	6a 10                	push   $0x10
801054ce:	50                   	push   %eax
801054cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801054d2:	50                   	push   %eax
801054d3:	ff 75 08             	push   0x8(%ebp)
801054d6:	e8 fb c9 ff ff       	call   80101ed6 <readi>
801054db:	83 c4 10             	add    $0x10,%esp
801054de:	83 f8 10             	cmp    $0x10,%eax
801054e1:	74 0d                	je     801054f0 <isdirempty+0x36>
      panic("isdirempty: readi");
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	68 58 a6 10 80       	push   $0x8010a658
801054eb:	e8 b9 b0 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801054f0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801054f4:	66 85 c0             	test   %ax,%ax
801054f7:	74 07                	je     80105500 <isdirempty+0x46>
      return 0;
801054f9:	b8 00 00 00 00       	mov    $0x0,%eax
801054fe:	eb 1b                	jmp    8010551b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105503:	83 c0 10             	add    $0x10,%eax
80105506:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105509:	8b 45 08             	mov    0x8(%ebp),%eax
8010550c:	8b 50 58             	mov    0x58(%eax),%edx
8010550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105512:	39 c2                	cmp    %eax,%edx
80105514:	77 b3                	ja     801054c9 <isdirempty+0xf>
  }
  return 1;
80105516:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010551b:	c9                   	leave  
8010551c:	c3                   	ret    

8010551d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010551d:	55                   	push   %ebp
8010551e:	89 e5                	mov    %esp,%ebp
80105520:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105523:	83 ec 08             	sub    $0x8,%esp
80105526:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105529:	50                   	push   %eax
8010552a:	6a 00                	push   $0x0
8010552c:	e8 a2 fa ff ff       	call   80104fd3 <argstr>
80105531:	83 c4 10             	add    $0x10,%esp
80105534:	85 c0                	test   %eax,%eax
80105536:	79 0a                	jns    80105542 <sys_unlink+0x25>
    return -1;
80105538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553d:	e9 bf 01 00 00       	jmp    80105701 <sys_unlink+0x1e4>

  begin_op();
80105542:	e8 f5 da ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105547:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010554a:	83 ec 08             	sub    $0x8,%esp
8010554d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105550:	52                   	push   %edx
80105551:	50                   	push   %eax
80105552:	e8 e2 cf ff ff       	call   80102539 <nameiparent>
80105557:	83 c4 10             	add    $0x10,%esp
8010555a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010555d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105561:	75 0f                	jne    80105572 <sys_unlink+0x55>
    end_op();
80105563:	e8 60 db ff ff       	call   801030c8 <end_op>
    return -1;
80105568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556d:	e9 8f 01 00 00       	jmp    80105701 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105572:	83 ec 0c             	sub    $0xc,%esp
80105575:	ff 75 f4             	push   -0xc(%ebp)
80105578:	e8 6d c4 ff ff       	call   801019ea <ilock>
8010557d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105580:	83 ec 08             	sub    $0x8,%esp
80105583:	68 6a a6 10 80       	push   $0x8010a66a
80105588:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010558b:	50                   	push   %eax
8010558c:	e8 20 cc ff ff       	call   801021b1 <namecmp>
80105591:	83 c4 10             	add    $0x10,%esp
80105594:	85 c0                	test   %eax,%eax
80105596:	0f 84 49 01 00 00    	je     801056e5 <sys_unlink+0x1c8>
8010559c:	83 ec 08             	sub    $0x8,%esp
8010559f:	68 6c a6 10 80       	push   $0x8010a66c
801055a4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801055a7:	50                   	push   %eax
801055a8:	e8 04 cc ff ff       	call   801021b1 <namecmp>
801055ad:	83 c4 10             	add    $0x10,%esp
801055b0:	85 c0                	test   %eax,%eax
801055b2:	0f 84 2d 01 00 00    	je     801056e5 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801055b8:	83 ec 04             	sub    $0x4,%esp
801055bb:	8d 45 c8             	lea    -0x38(%ebp),%eax
801055be:	50                   	push   %eax
801055bf:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801055c2:	50                   	push   %eax
801055c3:	ff 75 f4             	push   -0xc(%ebp)
801055c6:	e8 01 cc ff ff       	call   801021cc <dirlookup>
801055cb:	83 c4 10             	add    $0x10,%esp
801055ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055d5:	0f 84 0d 01 00 00    	je     801056e8 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801055db:	83 ec 0c             	sub    $0xc,%esp
801055de:	ff 75 f0             	push   -0x10(%ebp)
801055e1:	e8 04 c4 ff ff       	call   801019ea <ilock>
801055e6:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801055e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ec:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055f0:	66 85 c0             	test   %ax,%ax
801055f3:	7f 0d                	jg     80105602 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801055f5:	83 ec 0c             	sub    $0xc,%esp
801055f8:	68 6f a6 10 80       	push   $0x8010a66f
801055fd:	e8 a7 af ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105605:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105609:	66 83 f8 01          	cmp    $0x1,%ax
8010560d:	75 25                	jne    80105634 <sys_unlink+0x117>
8010560f:	83 ec 0c             	sub    $0xc,%esp
80105612:	ff 75 f0             	push   -0x10(%ebp)
80105615:	e8 a0 fe ff ff       	call   801054ba <isdirempty>
8010561a:	83 c4 10             	add    $0x10,%esp
8010561d:	85 c0                	test   %eax,%eax
8010561f:	75 13                	jne    80105634 <sys_unlink+0x117>
    iunlockput(ip);
80105621:	83 ec 0c             	sub    $0xc,%esp
80105624:	ff 75 f0             	push   -0x10(%ebp)
80105627:	e8 ef c5 ff ff       	call   80101c1b <iunlockput>
8010562c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010562f:	e9 b5 00 00 00       	jmp    801056e9 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105634:	83 ec 04             	sub    $0x4,%esp
80105637:	6a 10                	push   $0x10
80105639:	6a 00                	push   $0x0
8010563b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010563e:	50                   	push   %eax
8010563f:	e8 cf f5 ff ff       	call   80104c13 <memset>
80105644:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105647:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010564a:	6a 10                	push   $0x10
8010564c:	50                   	push   %eax
8010564d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105650:	50                   	push   %eax
80105651:	ff 75 f4             	push   -0xc(%ebp)
80105654:	e8 d2 c9 ff ff       	call   8010202b <writei>
80105659:	83 c4 10             	add    $0x10,%esp
8010565c:	83 f8 10             	cmp    $0x10,%eax
8010565f:	74 0d                	je     8010566e <sys_unlink+0x151>
    panic("unlink: writei");
80105661:	83 ec 0c             	sub    $0xc,%esp
80105664:	68 81 a6 10 80       	push   $0x8010a681
80105669:	e8 3b af ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010566e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105671:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105675:	66 83 f8 01          	cmp    $0x1,%ax
80105679:	75 21                	jne    8010569c <sys_unlink+0x17f>
    dp->nlink--;
8010567b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105682:	83 e8 01             	sub    $0x1,%eax
80105685:	89 c2                	mov    %eax,%edx
80105687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010568e:	83 ec 0c             	sub    $0xc,%esp
80105691:	ff 75 f4             	push   -0xc(%ebp)
80105694:	e8 74 c1 ff ff       	call   8010180d <iupdate>
80105699:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010569c:	83 ec 0c             	sub    $0xc,%esp
8010569f:	ff 75 f4             	push   -0xc(%ebp)
801056a2:	e8 74 c5 ff ff       	call   80101c1b <iunlockput>
801056a7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801056aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ad:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056b1:	83 e8 01             	sub    $0x1,%eax
801056b4:	89 c2                	mov    %eax,%edx
801056b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056bd:	83 ec 0c             	sub    $0xc,%esp
801056c0:	ff 75 f0             	push   -0x10(%ebp)
801056c3:	e8 45 c1 ff ff       	call   8010180d <iupdate>
801056c8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056cb:	83 ec 0c             	sub    $0xc,%esp
801056ce:	ff 75 f0             	push   -0x10(%ebp)
801056d1:	e8 45 c5 ff ff       	call   80101c1b <iunlockput>
801056d6:	83 c4 10             	add    $0x10,%esp

  end_op();
801056d9:	e8 ea d9 ff ff       	call   801030c8 <end_op>

  return 0;
801056de:	b8 00 00 00 00       	mov    $0x0,%eax
801056e3:	eb 1c                	jmp    80105701 <sys_unlink+0x1e4>
    goto bad;
801056e5:	90                   	nop
801056e6:	eb 01                	jmp    801056e9 <sys_unlink+0x1cc>
    goto bad;
801056e8:	90                   	nop

bad:
  iunlockput(dp);
801056e9:	83 ec 0c             	sub    $0xc,%esp
801056ec:	ff 75 f4             	push   -0xc(%ebp)
801056ef:	e8 27 c5 ff ff       	call   80101c1b <iunlockput>
801056f4:	83 c4 10             	add    $0x10,%esp
  end_op();
801056f7:	e8 cc d9 ff ff       	call   801030c8 <end_op>
  return -1;
801056fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105701:	c9                   	leave  
80105702:	c3                   	ret    

80105703 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105703:	55                   	push   %ebp
80105704:	89 e5                	mov    %esp,%ebp
80105706:	83 ec 38             	sub    $0x38,%esp
80105709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010570c:	8b 55 10             	mov    0x10(%ebp),%edx
8010570f:	8b 45 14             	mov    0x14(%ebp),%eax
80105712:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105716:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010571a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010571e:	83 ec 08             	sub    $0x8,%esp
80105721:	8d 45 de             	lea    -0x22(%ebp),%eax
80105724:	50                   	push   %eax
80105725:	ff 75 08             	push   0x8(%ebp)
80105728:	e8 0c ce ff ff       	call   80102539 <nameiparent>
8010572d:	83 c4 10             	add    $0x10,%esp
80105730:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105733:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105737:	75 0a                	jne    80105743 <create+0x40>
    return 0;
80105739:	b8 00 00 00 00       	mov    $0x0,%eax
8010573e:	e9 90 01 00 00       	jmp    801058d3 <create+0x1d0>
  ilock(dp);
80105743:	83 ec 0c             	sub    $0xc,%esp
80105746:	ff 75 f4             	push   -0xc(%ebp)
80105749:	e8 9c c2 ff ff       	call   801019ea <ilock>
8010574e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105751:	83 ec 04             	sub    $0x4,%esp
80105754:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105757:	50                   	push   %eax
80105758:	8d 45 de             	lea    -0x22(%ebp),%eax
8010575b:	50                   	push   %eax
8010575c:	ff 75 f4             	push   -0xc(%ebp)
8010575f:	e8 68 ca ff ff       	call   801021cc <dirlookup>
80105764:	83 c4 10             	add    $0x10,%esp
80105767:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010576a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010576e:	74 50                	je     801057c0 <create+0xbd>
    iunlockput(dp);
80105770:	83 ec 0c             	sub    $0xc,%esp
80105773:	ff 75 f4             	push   -0xc(%ebp)
80105776:	e8 a0 c4 ff ff       	call   80101c1b <iunlockput>
8010577b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010577e:	83 ec 0c             	sub    $0xc,%esp
80105781:	ff 75 f0             	push   -0x10(%ebp)
80105784:	e8 61 c2 ff ff       	call   801019ea <ilock>
80105789:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010578c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105791:	75 15                	jne    801057a8 <create+0xa5>
80105793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105796:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010579a:	66 83 f8 02          	cmp    $0x2,%ax
8010579e:	75 08                	jne    801057a8 <create+0xa5>
      return ip;
801057a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a3:	e9 2b 01 00 00       	jmp    801058d3 <create+0x1d0>
    iunlockput(ip);
801057a8:	83 ec 0c             	sub    $0xc,%esp
801057ab:	ff 75 f0             	push   -0x10(%ebp)
801057ae:	e8 68 c4 ff ff       	call   80101c1b <iunlockput>
801057b3:	83 c4 10             	add    $0x10,%esp
    return 0;
801057b6:	b8 00 00 00 00       	mov    $0x0,%eax
801057bb:	e9 13 01 00 00       	jmp    801058d3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801057c0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801057c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c7:	8b 00                	mov    (%eax),%eax
801057c9:	83 ec 08             	sub    $0x8,%esp
801057cc:	52                   	push   %edx
801057cd:	50                   	push   %eax
801057ce:	e8 63 bf ff ff       	call   80101736 <ialloc>
801057d3:	83 c4 10             	add    $0x10,%esp
801057d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057dd:	75 0d                	jne    801057ec <create+0xe9>
    panic("create: ialloc");
801057df:	83 ec 0c             	sub    $0xc,%esp
801057e2:	68 90 a6 10 80       	push   $0x8010a690
801057e7:	e8 bd ad ff ff       	call   801005a9 <panic>

  ilock(ip);
801057ec:	83 ec 0c             	sub    $0xc,%esp
801057ef:	ff 75 f0             	push   -0x10(%ebp)
801057f2:	e8 f3 c1 ff ff       	call   801019ea <ilock>
801057f7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801057fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105801:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010580c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105813:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105819:	83 ec 0c             	sub    $0xc,%esp
8010581c:	ff 75 f0             	push   -0x10(%ebp)
8010581f:	e8 e9 bf ff ff       	call   8010180d <iupdate>
80105824:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105827:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010582c:	75 6a                	jne    80105898 <create+0x195>
    dp->nlink++;  // for ".."
8010582e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105831:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105835:	83 c0 01             	add    $0x1,%eax
80105838:	89 c2                	mov    %eax,%edx
8010583a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105841:	83 ec 0c             	sub    $0xc,%esp
80105844:	ff 75 f4             	push   -0xc(%ebp)
80105847:	e8 c1 bf ff ff       	call   8010180d <iupdate>
8010584c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010584f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105852:	8b 40 04             	mov    0x4(%eax),%eax
80105855:	83 ec 04             	sub    $0x4,%esp
80105858:	50                   	push   %eax
80105859:	68 6a a6 10 80       	push   $0x8010a66a
8010585e:	ff 75 f0             	push   -0x10(%ebp)
80105861:	e8 20 ca ff ff       	call   80102286 <dirlink>
80105866:	83 c4 10             	add    $0x10,%esp
80105869:	85 c0                	test   %eax,%eax
8010586b:	78 1e                	js     8010588b <create+0x188>
8010586d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105870:	8b 40 04             	mov    0x4(%eax),%eax
80105873:	83 ec 04             	sub    $0x4,%esp
80105876:	50                   	push   %eax
80105877:	68 6c a6 10 80       	push   $0x8010a66c
8010587c:	ff 75 f0             	push   -0x10(%ebp)
8010587f:	e8 02 ca ff ff       	call   80102286 <dirlink>
80105884:	83 c4 10             	add    $0x10,%esp
80105887:	85 c0                	test   %eax,%eax
80105889:	79 0d                	jns    80105898 <create+0x195>
      panic("create dots");
8010588b:	83 ec 0c             	sub    $0xc,%esp
8010588e:	68 9f a6 10 80       	push   $0x8010a69f
80105893:	e8 11 ad ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589b:	8b 40 04             	mov    0x4(%eax),%eax
8010589e:	83 ec 04             	sub    $0x4,%esp
801058a1:	50                   	push   %eax
801058a2:	8d 45 de             	lea    -0x22(%ebp),%eax
801058a5:	50                   	push   %eax
801058a6:	ff 75 f4             	push   -0xc(%ebp)
801058a9:	e8 d8 c9 ff ff       	call   80102286 <dirlink>
801058ae:	83 c4 10             	add    $0x10,%esp
801058b1:	85 c0                	test   %eax,%eax
801058b3:	79 0d                	jns    801058c2 <create+0x1bf>
    panic("create: dirlink");
801058b5:	83 ec 0c             	sub    $0xc,%esp
801058b8:	68 ab a6 10 80       	push   $0x8010a6ab
801058bd:	e8 e7 ac ff ff       	call   801005a9 <panic>

  iunlockput(dp);
801058c2:	83 ec 0c             	sub    $0xc,%esp
801058c5:	ff 75 f4             	push   -0xc(%ebp)
801058c8:	e8 4e c3 ff ff       	call   80101c1b <iunlockput>
801058cd:	83 c4 10             	add    $0x10,%esp

  return ip;
801058d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801058d3:	c9                   	leave  
801058d4:	c3                   	ret    

801058d5 <sys_open>:

int
sys_open(void)
{
801058d5:	55                   	push   %ebp
801058d6:	89 e5                	mov    %esp,%ebp
801058d8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801058db:	83 ec 08             	sub    $0x8,%esp
801058de:	8d 45 e8             	lea    -0x18(%ebp),%eax
801058e1:	50                   	push   %eax
801058e2:	6a 00                	push   $0x0
801058e4:	e8 ea f6 ff ff       	call   80104fd3 <argstr>
801058e9:	83 c4 10             	add    $0x10,%esp
801058ec:	85 c0                	test   %eax,%eax
801058ee:	78 15                	js     80105905 <sys_open+0x30>
801058f0:	83 ec 08             	sub    $0x8,%esp
801058f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058f6:	50                   	push   %eax
801058f7:	6a 01                	push   $0x1
801058f9:	e8 40 f6 ff ff       	call   80104f3e <argint>
801058fe:	83 c4 10             	add    $0x10,%esp
80105901:	85 c0                	test   %eax,%eax
80105903:	79 0a                	jns    8010590f <sys_open+0x3a>
    return -1;
80105905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590a:	e9 61 01 00 00       	jmp    80105a70 <sys_open+0x19b>

  begin_op();
8010590f:	e8 28 d7 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105917:	25 00 02 00 00       	and    $0x200,%eax
8010591c:	85 c0                	test   %eax,%eax
8010591e:	74 2a                	je     8010594a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105920:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105923:	6a 00                	push   $0x0
80105925:	6a 00                	push   $0x0
80105927:	6a 02                	push   $0x2
80105929:	50                   	push   %eax
8010592a:	e8 d4 fd ff ff       	call   80105703 <create>
8010592f:	83 c4 10             	add    $0x10,%esp
80105932:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105935:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105939:	75 75                	jne    801059b0 <sys_open+0xdb>
      end_op();
8010593b:	e8 88 d7 ff ff       	call   801030c8 <end_op>
      return -1;
80105940:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105945:	e9 26 01 00 00       	jmp    80105a70 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010594a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	50                   	push   %eax
80105951:	e8 c7 cb ff ff       	call   8010251d <namei>
80105956:	83 c4 10             	add    $0x10,%esp
80105959:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010595c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105960:	75 0f                	jne    80105971 <sys_open+0x9c>
      end_op();
80105962:	e8 61 d7 ff ff       	call   801030c8 <end_op>
      return -1;
80105967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596c:	e9 ff 00 00 00       	jmp    80105a70 <sys_open+0x19b>
    }
    ilock(ip);
80105971:	83 ec 0c             	sub    $0xc,%esp
80105974:	ff 75 f4             	push   -0xc(%ebp)
80105977:	e8 6e c0 ff ff       	call   801019ea <ilock>
8010597c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010597f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105982:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105986:	66 83 f8 01          	cmp    $0x1,%ax
8010598a:	75 24                	jne    801059b0 <sys_open+0xdb>
8010598c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010598f:	85 c0                	test   %eax,%eax
80105991:	74 1d                	je     801059b0 <sys_open+0xdb>
      iunlockput(ip);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	ff 75 f4             	push   -0xc(%ebp)
80105999:	e8 7d c2 ff ff       	call   80101c1b <iunlockput>
8010599e:	83 c4 10             	add    $0x10,%esp
      end_op();
801059a1:	e8 22 d7 ff ff       	call   801030c8 <end_op>
      return -1;
801059a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ab:	e9 c0 00 00 00       	jmp    80105a70 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801059b0:	e8 28 b6 ff ff       	call   80100fdd <filealloc>
801059b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059bc:	74 17                	je     801059d5 <sys_open+0x100>
801059be:	83 ec 0c             	sub    $0xc,%esp
801059c1:	ff 75 f0             	push   -0x10(%ebp)
801059c4:	e8 33 f7 ff ff       	call   801050fc <fdalloc>
801059c9:	83 c4 10             	add    $0x10,%esp
801059cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801059cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801059d3:	79 2e                	jns    80105a03 <sys_open+0x12e>
    if(f)
801059d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d9:	74 0e                	je     801059e9 <sys_open+0x114>
      fileclose(f);
801059db:	83 ec 0c             	sub    $0xc,%esp
801059de:	ff 75 f0             	push   -0x10(%ebp)
801059e1:	e8 b5 b6 ff ff       	call   8010109b <fileclose>
801059e6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801059e9:	83 ec 0c             	sub    $0xc,%esp
801059ec:	ff 75 f4             	push   -0xc(%ebp)
801059ef:	e8 27 c2 ff ff       	call   80101c1b <iunlockput>
801059f4:	83 c4 10             	add    $0x10,%esp
    end_op();
801059f7:	e8 cc d6 ff ff       	call   801030c8 <end_op>
    return -1;
801059fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a01:	eb 6d                	jmp    80105a70 <sys_open+0x19b>
  }
  iunlock(ip);
80105a03:	83 ec 0c             	sub    $0xc,%esp
80105a06:	ff 75 f4             	push   -0xc(%ebp)
80105a09:	e8 ef c0 ff ff       	call   80101afd <iunlock>
80105a0e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a11:	e8 b2 d6 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a19:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a25:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105a32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a35:	83 e0 01             	and    $0x1,%eax
80105a38:	85 c0                	test   %eax,%eax
80105a3a:	0f 94 c0             	sete   %al
80105a3d:	89 c2                	mov    %eax,%edx
80105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a42:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a48:	83 e0 01             	and    $0x1,%eax
80105a4b:	85 c0                	test   %eax,%eax
80105a4d:	75 0a                	jne    80105a59 <sys_open+0x184>
80105a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a52:	83 e0 02             	and    $0x2,%eax
80105a55:	85 c0                	test   %eax,%eax
80105a57:	74 07                	je     80105a60 <sys_open+0x18b>
80105a59:	b8 01 00 00 00       	mov    $0x1,%eax
80105a5e:	eb 05                	jmp    80105a65 <sys_open+0x190>
80105a60:	b8 00 00 00 00       	mov    $0x0,%eax
80105a65:	89 c2                	mov    %eax,%edx
80105a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a70:	c9                   	leave  
80105a71:	c3                   	ret    

80105a72 <sys_mkdir>:

int
sys_mkdir(void)
{
80105a72:	55                   	push   %ebp
80105a73:	89 e5                	mov    %esp,%ebp
80105a75:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a78:	e8 bf d5 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a7d:	83 ec 08             	sub    $0x8,%esp
80105a80:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a83:	50                   	push   %eax
80105a84:	6a 00                	push   $0x0
80105a86:	e8 48 f5 ff ff       	call   80104fd3 <argstr>
80105a8b:	83 c4 10             	add    $0x10,%esp
80105a8e:	85 c0                	test   %eax,%eax
80105a90:	78 1b                	js     80105aad <sys_mkdir+0x3b>
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	6a 00                	push   $0x0
80105a97:	6a 00                	push   $0x0
80105a99:	6a 01                	push   $0x1
80105a9b:	50                   	push   %eax
80105a9c:	e8 62 fc ff ff       	call   80105703 <create>
80105aa1:	83 c4 10             	add    $0x10,%esp
80105aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aab:	75 0c                	jne    80105ab9 <sys_mkdir+0x47>
    end_op();
80105aad:	e8 16 d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105ab2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab7:	eb 18                	jmp    80105ad1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105ab9:	83 ec 0c             	sub    $0xc,%esp
80105abc:	ff 75 f4             	push   -0xc(%ebp)
80105abf:	e8 57 c1 ff ff       	call   80101c1b <iunlockput>
80105ac4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ac7:	e8 fc d5 ff ff       	call   801030c8 <end_op>
  return 0;
80105acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ad1:	c9                   	leave  
80105ad2:	c3                   	ret    

80105ad3 <sys_mknod>:

int
sys_mknod(void)
{
80105ad3:	55                   	push   %ebp
80105ad4:	89 e5                	mov    %esp,%ebp
80105ad6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ad9:	e8 5e d5 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ade:	83 ec 08             	sub    $0x8,%esp
80105ae1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ae4:	50                   	push   %eax
80105ae5:	6a 00                	push   $0x0
80105ae7:	e8 e7 f4 ff ff       	call   80104fd3 <argstr>
80105aec:	83 c4 10             	add    $0x10,%esp
80105aef:	85 c0                	test   %eax,%eax
80105af1:	78 4f                	js     80105b42 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105af3:	83 ec 08             	sub    $0x8,%esp
80105af6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105af9:	50                   	push   %eax
80105afa:	6a 01                	push   $0x1
80105afc:	e8 3d f4 ff ff       	call   80104f3e <argint>
80105b01:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105b04:	85 c0                	test   %eax,%eax
80105b06:	78 3a                	js     80105b42 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105b08:	83 ec 08             	sub    $0x8,%esp
80105b0b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b0e:	50                   	push   %eax
80105b0f:	6a 02                	push   $0x2
80105b11:	e8 28 f4 ff ff       	call   80104f3e <argint>
80105b16:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105b19:	85 c0                	test   %eax,%eax
80105b1b:	78 25                	js     80105b42 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b20:	0f bf c8             	movswl %ax,%ecx
80105b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b26:	0f bf d0             	movswl %ax,%edx
80105b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2c:	51                   	push   %ecx
80105b2d:	52                   	push   %edx
80105b2e:	6a 03                	push   $0x3
80105b30:	50                   	push   %eax
80105b31:	e8 cd fb ff ff       	call   80105703 <create>
80105b36:	83 c4 10             	add    $0x10,%esp
80105b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105b3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b40:	75 0c                	jne    80105b4e <sys_mknod+0x7b>
    end_op();
80105b42:	e8 81 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4c:	eb 18                	jmp    80105b66 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105b4e:	83 ec 0c             	sub    $0xc,%esp
80105b51:	ff 75 f4             	push   -0xc(%ebp)
80105b54:	e8 c2 c0 ff ff       	call   80101c1b <iunlockput>
80105b59:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b5c:	e8 67 d5 ff ff       	call   801030c8 <end_op>
  return 0;
80105b61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b66:	c9                   	leave  
80105b67:	c3                   	ret    

80105b68 <sys_chdir>:

int
sys_chdir(void)
{
80105b68:	55                   	push   %ebp
80105b69:	89 e5                	mov    %esp,%ebp
80105b6b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b6e:	e8 bd de ff ff       	call   80103a30 <myproc>
80105b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b76:	e8 c1 d4 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b7b:	83 ec 08             	sub    $0x8,%esp
80105b7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b81:	50                   	push   %eax
80105b82:	6a 00                	push   $0x0
80105b84:	e8 4a f4 ff ff       	call   80104fd3 <argstr>
80105b89:	83 c4 10             	add    $0x10,%esp
80105b8c:	85 c0                	test   %eax,%eax
80105b8e:	78 18                	js     80105ba8 <sys_chdir+0x40>
80105b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b93:	83 ec 0c             	sub    $0xc,%esp
80105b96:	50                   	push   %eax
80105b97:	e8 81 c9 ff ff       	call   8010251d <namei>
80105b9c:	83 c4 10             	add    $0x10,%esp
80105b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ba2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ba6:	75 0c                	jne    80105bb4 <sys_chdir+0x4c>
    end_op();
80105ba8:	e8 1b d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb2:	eb 68                	jmp    80105c1c <sys_chdir+0xb4>
  }
  ilock(ip);
80105bb4:	83 ec 0c             	sub    $0xc,%esp
80105bb7:	ff 75 f0             	push   -0x10(%ebp)
80105bba:	e8 2b be ff ff       	call   801019ea <ilock>
80105bbf:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bc9:	66 83 f8 01          	cmp    $0x1,%ax
80105bcd:	74 1a                	je     80105be9 <sys_chdir+0x81>
    iunlockput(ip);
80105bcf:	83 ec 0c             	sub    $0xc,%esp
80105bd2:	ff 75 f0             	push   -0x10(%ebp)
80105bd5:	e8 41 c0 ff ff       	call   80101c1b <iunlockput>
80105bda:	83 c4 10             	add    $0x10,%esp
    end_op();
80105bdd:	e8 e6 d4 ff ff       	call   801030c8 <end_op>
    return -1;
80105be2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be7:	eb 33                	jmp    80105c1c <sys_chdir+0xb4>
  }
  iunlock(ip);
80105be9:	83 ec 0c             	sub    $0xc,%esp
80105bec:	ff 75 f0             	push   -0x10(%ebp)
80105bef:	e8 09 bf ff ff       	call   80101afd <iunlock>
80105bf4:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfa:	8b 40 68             	mov    0x68(%eax),%eax
80105bfd:	83 ec 0c             	sub    $0xc,%esp
80105c00:	50                   	push   %eax
80105c01:	e8 45 bf ff ff       	call   80101b4b <iput>
80105c06:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c09:	e8 ba d4 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c14:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c1c:	c9                   	leave  
80105c1d:	c3                   	ret    

80105c1e <sys_exec>:

int
sys_exec(void)
{
80105c1e:	55                   	push   %ebp
80105c1f:	89 e5                	mov    %esp,%ebp
80105c21:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105c27:	83 ec 08             	sub    $0x8,%esp
80105c2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c2d:	50                   	push   %eax
80105c2e:	6a 00                	push   $0x0
80105c30:	e8 9e f3 ff ff       	call   80104fd3 <argstr>
80105c35:	83 c4 10             	add    $0x10,%esp
80105c38:	85 c0                	test   %eax,%eax
80105c3a:	78 18                	js     80105c54 <sys_exec+0x36>
80105c3c:	83 ec 08             	sub    $0x8,%esp
80105c3f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105c45:	50                   	push   %eax
80105c46:	6a 01                	push   $0x1
80105c48:	e8 f1 f2 ff ff       	call   80104f3e <argint>
80105c4d:	83 c4 10             	add    $0x10,%esp
80105c50:	85 c0                	test   %eax,%eax
80105c52:	79 0a                	jns    80105c5e <sys_exec+0x40>
    return -1;
80105c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c59:	e9 c6 00 00 00       	jmp    80105d24 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105c5e:	83 ec 04             	sub    $0x4,%esp
80105c61:	68 80 00 00 00       	push   $0x80
80105c66:	6a 00                	push   $0x0
80105c68:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c6e:	50                   	push   %eax
80105c6f:	e8 9f ef ff ff       	call   80104c13 <memset>
80105c74:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c81:	83 f8 1f             	cmp    $0x1f,%eax
80105c84:	76 0a                	jbe    80105c90 <sys_exec+0x72>
      return -1;
80105c86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8b:	e9 94 00 00 00       	jmp    80105d24 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c93:	c1 e0 02             	shl    $0x2,%eax
80105c96:	89 c2                	mov    %eax,%edx
80105c98:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c9e:	01 c2                	add    %eax,%edx
80105ca0:	83 ec 08             	sub    $0x8,%esp
80105ca3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ca9:	50                   	push   %eax
80105caa:	52                   	push   %edx
80105cab:	e8 ed f1 ff ff       	call   80104e9d <fetchint>
80105cb0:	83 c4 10             	add    $0x10,%esp
80105cb3:	85 c0                	test   %eax,%eax
80105cb5:	79 07                	jns    80105cbe <sys_exec+0xa0>
      return -1;
80105cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cbc:	eb 66                	jmp    80105d24 <sys_exec+0x106>
    if(uarg == 0){
80105cbe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105cc4:	85 c0                	test   %eax,%eax
80105cc6:	75 27                	jne    80105cef <sys_exec+0xd1>
      argv[i] = 0;
80105cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105cd2:	00 00 00 00 
      break;
80105cd6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cda:	83 ec 08             	sub    $0x8,%esp
80105cdd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ce3:	52                   	push   %edx
80105ce4:	50                   	push   %eax
80105ce5:	e8 96 ae ff ff       	call   80100b80 <exec>
80105cea:	83 c4 10             	add    $0x10,%esp
80105ced:	eb 35                	jmp    80105d24 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105cef:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf8:	c1 e0 02             	shl    $0x2,%eax
80105cfb:	01 c2                	add    %eax,%edx
80105cfd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105d03:	83 ec 08             	sub    $0x8,%esp
80105d06:	52                   	push   %edx
80105d07:	50                   	push   %eax
80105d08:	e8 cf f1 ff ff       	call   80104edc <fetchstr>
80105d0d:	83 c4 10             	add    $0x10,%esp
80105d10:	85 c0                	test   %eax,%eax
80105d12:	79 07                	jns    80105d1b <sys_exec+0xfd>
      return -1;
80105d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d19:	eb 09                	jmp    80105d24 <sys_exec+0x106>
  for(i=0;; i++){
80105d1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d1f:	e9 5a ff ff ff       	jmp    80105c7e <sys_exec+0x60>
}
80105d24:	c9                   	leave  
80105d25:	c3                   	ret    

80105d26 <sys_pipe>:

int
sys_pipe(void)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
80105d29:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d2c:	83 ec 04             	sub    $0x4,%esp
80105d2f:	6a 08                	push   $0x8
80105d31:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d34:	50                   	push   %eax
80105d35:	6a 00                	push   $0x0
80105d37:	e8 2f f2 ff ff       	call   80104f6b <argptr>
80105d3c:	83 c4 10             	add    $0x10,%esp
80105d3f:	85 c0                	test   %eax,%eax
80105d41:	79 0a                	jns    80105d4d <sys_pipe+0x27>
    return -1;
80105d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d48:	e9 ae 00 00 00       	jmp    80105dfb <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105d4d:	83 ec 08             	sub    $0x8,%esp
80105d50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d53:	50                   	push   %eax
80105d54:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d57:	50                   	push   %eax
80105d58:	e8 10 d8 ff ff       	call   8010356d <pipealloc>
80105d5d:	83 c4 10             	add    $0x10,%esp
80105d60:	85 c0                	test   %eax,%eax
80105d62:	79 0a                	jns    80105d6e <sys_pipe+0x48>
    return -1;
80105d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d69:	e9 8d 00 00 00       	jmp    80105dfb <sys_pipe+0xd5>
  fd0 = -1;
80105d6e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	50                   	push   %eax
80105d7c:	e8 7b f3 ff ff       	call   801050fc <fdalloc>
80105d81:	83 c4 10             	add    $0x10,%esp
80105d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d8b:	78 18                	js     80105da5 <sys_pipe+0x7f>
80105d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	50                   	push   %eax
80105d94:	e8 63 f3 ff ff       	call   801050fc <fdalloc>
80105d99:	83 c4 10             	add    $0x10,%esp
80105d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da3:	79 3e                	jns    80105de3 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105da5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105da9:	78 13                	js     80105dbe <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105dab:	e8 80 dc ff ff       	call   80103a30 <myproc>
80105db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db3:	83 c2 08             	add    $0x8,%edx
80105db6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105dbd:	00 
    fileclose(rf);
80105dbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dc1:	83 ec 0c             	sub    $0xc,%esp
80105dc4:	50                   	push   %eax
80105dc5:	e8 d1 b2 ff ff       	call   8010109b <fileclose>
80105dca:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dd0:	83 ec 0c             	sub    $0xc,%esp
80105dd3:	50                   	push   %eax
80105dd4:	e8 c2 b2 ff ff       	call   8010109b <fileclose>
80105dd9:	83 c4 10             	add    $0x10,%esp
    return -1;
80105ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de1:	eb 18                	jmp    80105dfb <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105de9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dee:	8d 50 04             	lea    0x4(%eax),%edx
80105df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df4:	89 02                	mov    %eax,(%edx)
  return 0;
80105df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dfb:	c9                   	leave  
80105dfc:	c3                   	ret    

80105dfd <sys_fork>:
#include "spinlock.h"
#include "debug.h"

int
sys_fork(void)
{
80105dfd:	55                   	push   %ebp
80105dfe:	89 e5                	mov    %esp,%ebp
80105e00:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105e03:	e8 27 df ff ff       	call   80103d2f <fork>
}
80105e08:	c9                   	leave  
80105e09:	c3                   	ret    

80105e0a <sys_exit>:

int
sys_exit(void)
{
80105e0a:	55                   	push   %ebp
80105e0b:	89 e5                	mov    %esp,%ebp
80105e0d:	83 ec 08             	sub    $0x8,%esp
  exit();
80105e10:	e8 93 e0 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105e15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e1a:	c9                   	leave  
80105e1b:	c3                   	ret    

80105e1c <sys_exit2>:

int
sys_exit2(void) 
{
80105e1c:	55                   	push   %ebp
80105e1d:	89 e5                	mov    %esp,%ebp
80105e1f:	83 ec 18             	sub    $0x18,%esp
  //struct proc *curproc = myproc();
  int status;

  argint(0, &status);
80105e22:	83 ec 08             	sub    $0x8,%esp
80105e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e28:	50                   	push   %eax
80105e29:	6a 00                	push   $0x0
80105e2b:	e8 0e f1 ff ff       	call   80104f3e <argint>
80105e30:	83 c4 10             	add    $0x10,%esp
   
  exit2(status); 
80105e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e36:	83 ec 0c             	sub    $0xc,%esp
80105e39:	50                   	push   %eax
80105e3a:	e8 89 e1 ff ff       	call   80103fc8 <exit2>
80105e3f:	83 c4 10             	add    $0x10,%esp
  return 0; //eax에 리턴해야하니까
80105e42:	b8 00 00 00 00       	mov    $0x0,%eax
}  
80105e47:	c9                   	leave  
80105e48:	c3                   	ret    

80105e49 <sys_wait>:

int
sys_wait(void)
{
80105e49:	55                   	push   %ebp
80105e4a:	89 e5                	mov    %esp,%ebp
80105e4c:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105e4f:	e8 b9 e2 ff ff       	call   8010410d <wait>
}
80105e54:	c9                   	leave  
80105e55:	c3                   	ret    

80105e56 <sys_wait2>:
//*********new sys_waiat**********
//********************************

int
sys_wait2(int *status)
{
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
80105e59:	83 ec 08             	sub    $0x8,%esp



  // argptr() 함수를 사용하여 첫 번째 인자(인덱스 0)로 전달된
  // 사용자 공간 포인터의 유효성을 검증하고, 해당 포인터를 가져옵니다.
  if(argptr(0, (void*)&status, sizeof(*status)) < 0)
80105e5c:	83 ec 04             	sub    $0x4,%esp
80105e5f:	6a 04                	push   $0x4
80105e61:	8d 45 08             	lea    0x8(%ebp),%eax
80105e64:	50                   	push   %eax
80105e65:	6a 00                	push   $0x0
80105e67:	e8 ff f0 ff ff       	call   80104f6b <argptr>
80105e6c:	83 c4 10             	add    $0x10,%esp
80105e6f:	85 c0                	test   %eax,%eax
80105e71:	79 07                	jns    80105e7a <sys_wait2+0x24>
    return -1;  // 인자가 유효하지 않은 경우, 에러 코드를 반환합니다.
80105e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e78:	eb 0f                	jmp    80105e89 <sys_wait2+0x33>

  // wait2() 함수를 호출하고, 자식 프로세스의 종료 상태를
  // 사용자 공간의 status 포인터가 가리키는 곳에 저장합니다.
  return wait2(status);}
80105e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e7d:	83 ec 0c             	sub    $0xc,%esp
80105e80:	50                   	push   %eax
80105e81:	e8 a7 e3 ff ff       	call   8010422d <wait2>
80105e86:	83 c4 10             	add    $0x10,%esp
80105e89:	c9                   	leave  
80105e8a:	c3                   	ret    

80105e8b <sys_kill>:
//********************************


int
sys_kill(void)
{
80105e8b:	55                   	push   %ebp
80105e8c:	89 e5                	mov    %esp,%ebp
80105e8e:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105e91:	83 ec 08             	sub    $0x8,%esp
80105e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e97:	50                   	push   %eax
80105e98:	6a 00                	push   $0x0
80105e9a:	e8 9f f0 ff ff       	call   80104f3e <argint>
80105e9f:	83 c4 10             	add    $0x10,%esp
80105ea2:	85 c0                	test   %eax,%eax
80105ea4:	79 07                	jns    80105ead <sys_kill+0x22>
    return -1;
80105ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eab:	eb 0f                	jmp    80105ebc <sys_kill+0x31>
  return kill(pid);
80105ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb0:	83 ec 0c             	sub    $0xc,%esp
80105eb3:	50                   	push   %eax
80105eb4:	e8 e7 e7 ff ff       	call   801046a0 <kill>
80105eb9:	83 c4 10             	add    $0x10,%esp
}
80105ebc:	c9                   	leave  
80105ebd:	c3                   	ret    

80105ebe <sys_getpid>:

int
sys_getpid(void)
{
80105ebe:	55                   	push   %ebp
80105ebf:	89 e5                	mov    %esp,%ebp
80105ec1:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ec4:	e8 67 db ff ff       	call   80103a30 <myproc>
80105ec9:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ecc:	c9                   	leave  
80105ecd:	c3                   	ret    

80105ece <sys_sbrk>:

int
sys_sbrk(void)
{
80105ece:	55                   	push   %ebp
80105ecf:	89 e5                	mov    %esp,%ebp
80105ed1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ed4:	83 ec 08             	sub    $0x8,%esp
80105ed7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eda:	50                   	push   %eax
80105edb:	6a 00                	push   $0x0
80105edd:	e8 5c f0 ff ff       	call   80104f3e <argint>
80105ee2:	83 c4 10             	add    $0x10,%esp
80105ee5:	85 c0                	test   %eax,%eax
80105ee7:	79 07                	jns    80105ef0 <sys_sbrk+0x22>
    return -1;
80105ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eee:	eb 27                	jmp    80105f17 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105ef0:	e8 3b db ff ff       	call   80103a30 <myproc>
80105ef5:	8b 00                	mov    (%eax),%eax
80105ef7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efd:	83 ec 0c             	sub    $0xc,%esp
80105f00:	50                   	push   %eax
80105f01:	e8 8e dd ff ff       	call   80103c94 <growproc>
80105f06:	83 c4 10             	add    $0x10,%esp
80105f09:	85 c0                	test   %eax,%eax
80105f0b:	79 07                	jns    80105f14 <sys_sbrk+0x46>
    return -1;
80105f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f12:	eb 03                	jmp    80105f17 <sys_sbrk+0x49>
  return addr;
80105f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f17:	c9                   	leave  
80105f18:	c3                   	ret    

80105f19 <sys_sleep>:

int
sys_sleep(void)
{
80105f19:	55                   	push   %ebp
80105f1a:	89 e5                	mov    %esp,%ebp
80105f1c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105f1f:	83 ec 08             	sub    $0x8,%esp
80105f22:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f25:	50                   	push   %eax
80105f26:	6a 00                	push   $0x0
80105f28:	e8 11 f0 ff ff       	call   80104f3e <argint>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	85 c0                	test   %eax,%eax
80105f32:	79 07                	jns    80105f3b <sys_sleep+0x22>
    return -1;
80105f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f39:	eb 76                	jmp    80105fb1 <sys_sleep+0x98>
  acquire(&tickslock);
80105f3b:	83 ec 0c             	sub    $0xc,%esp
80105f3e:	68 40 6a 19 80       	push   $0x80196a40
80105f43:	e8 55 ea ff ff       	call   8010499d <acquire>
80105f48:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105f4b:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105f50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105f53:	eb 38                	jmp    80105f8d <sys_sleep+0x74>
    if(myproc()->killed){
80105f55:	e8 d6 da ff ff       	call   80103a30 <myproc>
80105f5a:	8b 40 24             	mov    0x24(%eax),%eax
80105f5d:	85 c0                	test   %eax,%eax
80105f5f:	74 17                	je     80105f78 <sys_sleep+0x5f>
      release(&tickslock);
80105f61:	83 ec 0c             	sub    $0xc,%esp
80105f64:	68 40 6a 19 80       	push   $0x80196a40
80105f69:	e8 9d ea ff ff       	call   80104a0b <release>
80105f6e:	83 c4 10             	add    $0x10,%esp
      return -1;
80105f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f76:	eb 39                	jmp    80105fb1 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105f78:	83 ec 08             	sub    $0x8,%esp
80105f7b:	68 40 6a 19 80       	push   $0x80196a40
80105f80:	68 74 6a 19 80       	push   $0x80196a74
80105f85:	e8 f8 e5 ff ff       	call   80104582 <sleep>
80105f8a:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105f8d:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105f92:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105f95:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f98:	39 d0                	cmp    %edx,%eax
80105f9a:	72 b9                	jb     80105f55 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	68 40 6a 19 80       	push   $0x80196a40
80105fa4:	e8 62 ea ff ff       	call   80104a0b <release>
80105fa9:	83 c4 10             	add    $0x10,%esp
  return 0;
80105fac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fb1:	c9                   	leave  
80105fb2:	c3                   	ret    

80105fb3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105fb3:	55                   	push   %ebp
80105fb4:	89 e5                	mov    %esp,%ebp
80105fb6:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105fb9:	83 ec 0c             	sub    $0xc,%esp
80105fbc:	68 40 6a 19 80       	push   $0x80196a40
80105fc1:	e8 d7 e9 ff ff       	call   8010499d <acquire>
80105fc6:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105fc9:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105fd1:	83 ec 0c             	sub    $0xc,%esp
80105fd4:	68 40 6a 19 80       	push   $0x80196a40
80105fd9:	e8 2d ea ff ff       	call   80104a0b <release>
80105fde:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fe4:	c9                   	leave  
80105fe5:	c3                   	ret    

80105fe6 <alltraps>:
80105fe6:	1e                   	push   %ds
80105fe7:	06                   	push   %es
80105fe8:	0f a0                	push   %fs
80105fea:	0f a8                	push   %gs
80105fec:	60                   	pusha  
80105fed:	66 b8 10 00          	mov    $0x10,%ax
80105ff1:	8e d8                	mov    %eax,%ds
80105ff3:	8e c0                	mov    %eax,%es
80105ff5:	54                   	push   %esp
80105ff6:	e8 d7 01 00 00       	call   801061d2 <trap>
80105ffb:	83 c4 04             	add    $0x4,%esp

80105ffe <trapret>:
80105ffe:	61                   	popa   
80105fff:	0f a9                	pop    %gs
80106001:	0f a1                	pop    %fs
80106003:	07                   	pop    %es
80106004:	1f                   	pop    %ds
80106005:	83 c4 08             	add    $0x8,%esp
80106008:	cf                   	iret   

80106009 <lidt>:
{
80106009:	55                   	push   %ebp
8010600a:	89 e5                	mov    %esp,%ebp
8010600c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010600f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106012:	83 e8 01             	sub    $0x1,%eax
80106015:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106019:	8b 45 08             	mov    0x8(%ebp),%eax
8010601c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106020:	8b 45 08             	mov    0x8(%ebp),%eax
80106023:	c1 e8 10             	shr    $0x10,%eax
80106026:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010602a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010602d:	0f 01 18             	lidtl  (%eax)
}
80106030:	90                   	nop
80106031:	c9                   	leave  
80106032:	c3                   	ret    

80106033 <rcr2>:

static inline uint
rcr2(void)
{
80106033:	55                   	push   %ebp
80106034:	89 e5                	mov    %esp,%ebp
80106036:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106039:	0f 20 d0             	mov    %cr2,%eax
8010603c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010603f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106042:	c9                   	leave  
80106043:	c3                   	ret    

80106044 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106044:	55                   	push   %ebp
80106045:	89 e5                	mov    %esp,%ebp
80106047:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010604a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106051:	e9 c3 00 00 00       	jmp    80106119 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106059:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106060:	89 c2                	mov    %eax,%edx
80106062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106065:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
8010606c:	80 
8010606d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106070:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80106077:	80 08 00 
8010607a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607d:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80106084:	80 
80106085:	83 e2 e0             	and    $0xffffffe0,%edx
80106088:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
8010608f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106092:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80106099:	80 
8010609a:	83 e2 1f             	and    $0x1f,%edx
8010609d:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
801060a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a7:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060ae:	80 
801060af:	83 e2 f0             	and    $0xfffffff0,%edx
801060b2:	83 ca 0e             	or     $0xe,%edx
801060b5:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bf:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060c6:	80 
801060c7:	83 e2 ef             	and    $0xffffffef,%edx
801060ca:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d4:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060db:	80 
801060dc:	83 e2 9f             	and    $0xffffff9f,%edx
801060df:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e9:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060f0:	80 
801060f1:	83 ca 80             	or     $0xffffff80,%edx
801060f4:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fe:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106105:	c1 e8 10             	shr    $0x10,%eax
80106108:	89 c2                	mov    %eax,%edx
8010610a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610d:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80106114:	80 
  for(i = 0; i < 256; i++)
80106115:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106119:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106120:	0f 8e 30 ff ff ff    	jle    80106056 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106126:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010612b:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80106131:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80106138:	08 00 
8010613a:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80106141:	83 e0 e0             	and    $0xffffffe0,%eax
80106144:	a2 44 64 19 80       	mov    %al,0x80196444
80106149:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80106150:	83 e0 1f             	and    $0x1f,%eax
80106153:	a2 44 64 19 80       	mov    %al,0x80196444
80106158:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010615f:	83 c8 0f             	or     $0xf,%eax
80106162:	a2 45 64 19 80       	mov    %al,0x80196445
80106167:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010616e:	83 e0 ef             	and    $0xffffffef,%eax
80106171:	a2 45 64 19 80       	mov    %al,0x80196445
80106176:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010617d:	83 c8 60             	or     $0x60,%eax
80106180:	a2 45 64 19 80       	mov    %al,0x80196445
80106185:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010618c:	83 c8 80             	or     $0xffffff80,%eax
8010618f:	a2 45 64 19 80       	mov    %al,0x80196445
80106194:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106199:	c1 e8 10             	shr    $0x10,%eax
8010619c:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
801061a2:	83 ec 08             	sub    $0x8,%esp
801061a5:	68 bc a6 10 80       	push   $0x8010a6bc
801061aa:	68 40 6a 19 80       	push   $0x80196a40
801061af:	e8 c7 e7 ff ff       	call   8010497b <initlock>
801061b4:	83 c4 10             	add    $0x10,%esp
}
801061b7:	90                   	nop
801061b8:	c9                   	leave  
801061b9:	c3                   	ret    

801061ba <idtinit>:

void
idtinit(void)
{
801061ba:	55                   	push   %ebp
801061bb:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801061bd:	68 00 08 00 00       	push   $0x800
801061c2:	68 40 62 19 80       	push   $0x80196240
801061c7:	e8 3d fe ff ff       	call   80106009 <lidt>
801061cc:	83 c4 08             	add    $0x8,%esp
}
801061cf:	90                   	nop
801061d0:	c9                   	leave  
801061d1:	c3                   	ret    

801061d2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801061d2:	55                   	push   %ebp
801061d3:	89 e5                	mov    %esp,%ebp
801061d5:	57                   	push   %edi
801061d6:	56                   	push   %esi
801061d7:	53                   	push   %ebx
801061d8:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801061db:	8b 45 08             	mov    0x8(%ebp),%eax
801061de:	8b 40 30             	mov    0x30(%eax),%eax
801061e1:	83 f8 40             	cmp    $0x40,%eax
801061e4:	75 3b                	jne    80106221 <trap+0x4f>
    if(myproc()->killed)
801061e6:	e8 45 d8 ff ff       	call   80103a30 <myproc>
801061eb:	8b 40 24             	mov    0x24(%eax),%eax
801061ee:	85 c0                	test   %eax,%eax
801061f0:	74 05                	je     801061f7 <trap+0x25>
      exit();
801061f2:	e8 b1 dc ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
801061f7:	e8 34 d8 ff ff       	call   80103a30 <myproc>
801061fc:	8b 55 08             	mov    0x8(%ebp),%edx
801061ff:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106202:	e8 03 ee ff ff       	call   8010500a <syscall>
    if(myproc()->killed)
80106207:	e8 24 d8 ff ff       	call   80103a30 <myproc>
8010620c:	8b 40 24             	mov    0x24(%eax),%eax
8010620f:	85 c0                	test   %eax,%eax
80106211:	0f 84 15 02 00 00    	je     8010642c <trap+0x25a>
      exit();
80106217:	e8 8c dc ff ff       	call   80103ea8 <exit>
    return;
8010621c:	e9 0b 02 00 00       	jmp    8010642c <trap+0x25a>
  }

  switch(tf->trapno){
80106221:	8b 45 08             	mov    0x8(%ebp),%eax
80106224:	8b 40 30             	mov    0x30(%eax),%eax
80106227:	83 e8 20             	sub    $0x20,%eax
8010622a:	83 f8 1f             	cmp    $0x1f,%eax
8010622d:	0f 87 c4 00 00 00    	ja     801062f7 <trap+0x125>
80106233:	8b 04 85 64 a7 10 80 	mov    -0x7fef589c(,%eax,4),%eax
8010623a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010623c:	e8 5c d7 ff ff       	call   8010399d <cpuid>
80106241:	85 c0                	test   %eax,%eax
80106243:	75 3d                	jne    80106282 <trap+0xb0>
      acquire(&tickslock);
80106245:	83 ec 0c             	sub    $0xc,%esp
80106248:	68 40 6a 19 80       	push   $0x80196a40
8010624d:	e8 4b e7 ff ff       	call   8010499d <acquire>
80106252:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106255:	a1 74 6a 19 80       	mov    0x80196a74,%eax
8010625a:	83 c0 01             	add    $0x1,%eax
8010625d:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	68 74 6a 19 80       	push   $0x80196a74
8010626a:	e8 fa e3 ff ff       	call   80104669 <wakeup>
8010626f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106272:	83 ec 0c             	sub    $0xc,%esp
80106275:	68 40 6a 19 80       	push   $0x80196a40
8010627a:	e8 8c e7 ff ff       	call   80104a0b <release>
8010627f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106282:	e8 95 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106287:	e9 20 01 00 00       	jmp    801063ac <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010628c:	e8 f5 3e 00 00       	call   8010a186 <ideintr>
    lapiceoi();
80106291:	e8 86 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106296:	e9 11 01 00 00       	jmp    801063ac <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010629b:	e8 c1 c6 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
801062a0:	e8 77 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
801062a5:	e9 02 01 00 00       	jmp    801063ac <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801062aa:	e8 53 03 00 00       	call   80106602 <uartintr>
    lapiceoi();
801062af:	e8 68 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
801062b4:	e9 f3 00 00 00       	jmp    801063ac <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
801062b9:	e8 7b 2b 00 00       	call   80108e39 <i8254_intr>
    lapiceoi();
801062be:	e8 59 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
801062c3:	e9 e4 00 00 00       	jmp    801063ac <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801062c8:	8b 45 08             	mov    0x8(%ebp),%eax
801062cb:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801062ce:	8b 45 08             	mov    0x8(%ebp),%eax
801062d1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801062d5:	0f b7 d8             	movzwl %ax,%ebx
801062d8:	e8 c0 d6 ff ff       	call   8010399d <cpuid>
801062dd:	56                   	push   %esi
801062de:	53                   	push   %ebx
801062df:	50                   	push   %eax
801062e0:	68 c4 a6 10 80       	push   $0x8010a6c4
801062e5:	e8 0a a1 ff ff       	call   801003f4 <cprintf>
801062ea:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801062ed:	e8 2a c8 ff ff       	call   80102b1c <lapiceoi>
    break;
801062f2:	e9 b5 00 00 00       	jmp    801063ac <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801062f7:	e8 34 d7 ff ff       	call   80103a30 <myproc>
801062fc:	85 c0                	test   %eax,%eax
801062fe:	74 11                	je     80106311 <trap+0x13f>
80106300:	8b 45 08             	mov    0x8(%ebp),%eax
80106303:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106307:	0f b7 c0             	movzwl %ax,%eax
8010630a:	83 e0 03             	and    $0x3,%eax
8010630d:	85 c0                	test   %eax,%eax
8010630f:	75 39                	jne    8010634a <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106311:	e8 1d fd ff ff       	call   80106033 <rcr2>
80106316:	89 c3                	mov    %eax,%ebx
80106318:	8b 45 08             	mov    0x8(%ebp),%eax
8010631b:	8b 70 38             	mov    0x38(%eax),%esi
8010631e:	e8 7a d6 ff ff       	call   8010399d <cpuid>
80106323:	8b 55 08             	mov    0x8(%ebp),%edx
80106326:	8b 52 30             	mov    0x30(%edx),%edx
80106329:	83 ec 0c             	sub    $0xc,%esp
8010632c:	53                   	push   %ebx
8010632d:	56                   	push   %esi
8010632e:	50                   	push   %eax
8010632f:	52                   	push   %edx
80106330:	68 e8 a6 10 80       	push   $0x8010a6e8
80106335:	e8 ba a0 ff ff       	call   801003f4 <cprintf>
8010633a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010633d:	83 ec 0c             	sub    $0xc,%esp
80106340:	68 1a a7 10 80       	push   $0x8010a71a
80106345:	e8 5f a2 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010634a:	e8 e4 fc ff ff       	call   80106033 <rcr2>
8010634f:	89 c6                	mov    %eax,%esi
80106351:	8b 45 08             	mov    0x8(%ebp),%eax
80106354:	8b 40 38             	mov    0x38(%eax),%eax
80106357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010635a:	e8 3e d6 ff ff       	call   8010399d <cpuid>
8010635f:	89 c3                	mov    %eax,%ebx
80106361:	8b 45 08             	mov    0x8(%ebp),%eax
80106364:	8b 48 34             	mov    0x34(%eax),%ecx
80106367:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010636a:	8b 45 08             	mov    0x8(%ebp),%eax
8010636d:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106370:	e8 bb d6 ff ff       	call   80103a30 <myproc>
80106375:	8d 50 6c             	lea    0x6c(%eax),%edx
80106378:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010637b:	e8 b0 d6 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106380:	8b 40 10             	mov    0x10(%eax),%eax
80106383:	56                   	push   %esi
80106384:	ff 75 e4             	push   -0x1c(%ebp)
80106387:	53                   	push   %ebx
80106388:	ff 75 e0             	push   -0x20(%ebp)
8010638b:	57                   	push   %edi
8010638c:	ff 75 dc             	push   -0x24(%ebp)
8010638f:	50                   	push   %eax
80106390:	68 20 a7 10 80       	push   $0x8010a720
80106395:	e8 5a a0 ff ff       	call   801003f4 <cprintf>
8010639a:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010639d:	e8 8e d6 ff ff       	call   80103a30 <myproc>
801063a2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801063a9:	eb 01                	jmp    801063ac <trap+0x1da>
    break;
801063ab:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063ac:	e8 7f d6 ff ff       	call   80103a30 <myproc>
801063b1:	85 c0                	test   %eax,%eax
801063b3:	74 23                	je     801063d8 <trap+0x206>
801063b5:	e8 76 d6 ff ff       	call   80103a30 <myproc>
801063ba:	8b 40 24             	mov    0x24(%eax),%eax
801063bd:	85 c0                	test   %eax,%eax
801063bf:	74 17                	je     801063d8 <trap+0x206>
801063c1:	8b 45 08             	mov    0x8(%ebp),%eax
801063c4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063c8:	0f b7 c0             	movzwl %ax,%eax
801063cb:	83 e0 03             	and    $0x3,%eax
801063ce:	83 f8 03             	cmp    $0x3,%eax
801063d1:	75 05                	jne    801063d8 <trap+0x206>
    exit();
801063d3:	e8 d0 da ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801063d8:	e8 53 d6 ff ff       	call   80103a30 <myproc>
801063dd:	85 c0                	test   %eax,%eax
801063df:	74 1d                	je     801063fe <trap+0x22c>
801063e1:	e8 4a d6 ff ff       	call   80103a30 <myproc>
801063e6:	8b 40 0c             	mov    0xc(%eax),%eax
801063e9:	83 f8 04             	cmp    $0x4,%eax
801063ec:	75 10                	jne    801063fe <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801063ee:	8b 45 08             	mov    0x8(%ebp),%eax
801063f1:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801063f4:	83 f8 20             	cmp    $0x20,%eax
801063f7:	75 05                	jne    801063fe <trap+0x22c>
    yield();
801063f9:	e8 04 e1 ff ff       	call   80104502 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063fe:	e8 2d d6 ff ff       	call   80103a30 <myproc>
80106403:	85 c0                	test   %eax,%eax
80106405:	74 26                	je     8010642d <trap+0x25b>
80106407:	e8 24 d6 ff ff       	call   80103a30 <myproc>
8010640c:	8b 40 24             	mov    0x24(%eax),%eax
8010640f:	85 c0                	test   %eax,%eax
80106411:	74 1a                	je     8010642d <trap+0x25b>
80106413:	8b 45 08             	mov    0x8(%ebp),%eax
80106416:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010641a:	0f b7 c0             	movzwl %ax,%eax
8010641d:	83 e0 03             	and    $0x3,%eax
80106420:	83 f8 03             	cmp    $0x3,%eax
80106423:	75 08                	jne    8010642d <trap+0x25b>
    exit();
80106425:	e8 7e da ff ff       	call   80103ea8 <exit>
8010642a:	eb 01                	jmp    8010642d <trap+0x25b>
    return;
8010642c:	90                   	nop
}
8010642d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106430:	5b                   	pop    %ebx
80106431:	5e                   	pop    %esi
80106432:	5f                   	pop    %edi
80106433:	5d                   	pop    %ebp
80106434:	c3                   	ret    

80106435 <inb>:
{
80106435:	55                   	push   %ebp
80106436:	89 e5                	mov    %esp,%ebp
80106438:	83 ec 14             	sub    $0x14,%esp
8010643b:	8b 45 08             	mov    0x8(%ebp),%eax
8010643e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106442:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106446:	89 c2                	mov    %eax,%edx
80106448:	ec                   	in     (%dx),%al
80106449:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010644c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106450:	c9                   	leave  
80106451:	c3                   	ret    

80106452 <outb>:
{
80106452:	55                   	push   %ebp
80106453:	89 e5                	mov    %esp,%ebp
80106455:	83 ec 08             	sub    $0x8,%esp
80106458:	8b 45 08             	mov    0x8(%ebp),%eax
8010645b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010645e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106462:	89 d0                	mov    %edx,%eax
80106464:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106467:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010646b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010646f:	ee                   	out    %al,(%dx)
}
80106470:	90                   	nop
80106471:	c9                   	leave  
80106472:	c3                   	ret    

80106473 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106473:	55                   	push   %ebp
80106474:	89 e5                	mov    %esp,%ebp
80106476:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106479:	6a 00                	push   $0x0
8010647b:	68 fa 03 00 00       	push   $0x3fa
80106480:	e8 cd ff ff ff       	call   80106452 <outb>
80106485:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106488:	68 80 00 00 00       	push   $0x80
8010648d:	68 fb 03 00 00       	push   $0x3fb
80106492:	e8 bb ff ff ff       	call   80106452 <outb>
80106497:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010649a:	6a 0c                	push   $0xc
8010649c:	68 f8 03 00 00       	push   $0x3f8
801064a1:	e8 ac ff ff ff       	call   80106452 <outb>
801064a6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801064a9:	6a 00                	push   $0x0
801064ab:	68 f9 03 00 00       	push   $0x3f9
801064b0:	e8 9d ff ff ff       	call   80106452 <outb>
801064b5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801064b8:	6a 03                	push   $0x3
801064ba:	68 fb 03 00 00       	push   $0x3fb
801064bf:	e8 8e ff ff ff       	call   80106452 <outb>
801064c4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801064c7:	6a 00                	push   $0x0
801064c9:	68 fc 03 00 00       	push   $0x3fc
801064ce:	e8 7f ff ff ff       	call   80106452 <outb>
801064d3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801064d6:	6a 01                	push   $0x1
801064d8:	68 f9 03 00 00       	push   $0x3f9
801064dd:	e8 70 ff ff ff       	call   80106452 <outb>
801064e2:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801064e5:	68 fd 03 00 00       	push   $0x3fd
801064ea:	e8 46 ff ff ff       	call   80106435 <inb>
801064ef:	83 c4 04             	add    $0x4,%esp
801064f2:	3c ff                	cmp    $0xff,%al
801064f4:	74 61                	je     80106557 <uartinit+0xe4>
    return;
  uart = 1;
801064f6:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
801064fd:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106500:	68 fa 03 00 00       	push   $0x3fa
80106505:	e8 2b ff ff ff       	call   80106435 <inb>
8010650a:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010650d:	68 f8 03 00 00       	push   $0x3f8
80106512:	e8 1e ff ff ff       	call   80106435 <inb>
80106517:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	6a 00                	push   $0x0
8010651f:	6a 04                	push   $0x4
80106521:	e8 08 c1 ff ff       	call   8010262e <ioapicenable>
80106526:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106529:	c7 45 f4 e4 a7 10 80 	movl   $0x8010a7e4,-0xc(%ebp)
80106530:	eb 19                	jmp    8010654b <uartinit+0xd8>
    uartputc(*p);
80106532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106535:	0f b6 00             	movzbl (%eax),%eax
80106538:	0f be c0             	movsbl %al,%eax
8010653b:	83 ec 0c             	sub    $0xc,%esp
8010653e:	50                   	push   %eax
8010653f:	e8 16 00 00 00       	call   8010655a <uartputc>
80106544:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106547:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010654b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654e:	0f b6 00             	movzbl (%eax),%eax
80106551:	84 c0                	test   %al,%al
80106553:	75 dd                	jne    80106532 <uartinit+0xbf>
80106555:	eb 01                	jmp    80106558 <uartinit+0xe5>
    return;
80106557:	90                   	nop
}
80106558:	c9                   	leave  
80106559:	c3                   	ret    

8010655a <uartputc>:

void
uartputc(int c)
{
8010655a:	55                   	push   %ebp
8010655b:	89 e5                	mov    %esp,%ebp
8010655d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106560:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106565:	85 c0                	test   %eax,%eax
80106567:	74 53                	je     801065bc <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106570:	eb 11                	jmp    80106583 <uartputc+0x29>
    microdelay(10);
80106572:	83 ec 0c             	sub    $0xc,%esp
80106575:	6a 0a                	push   $0xa
80106577:	e8 bb c5 ff ff       	call   80102b37 <microdelay>
8010657c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010657f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106583:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106587:	7f 1a                	jg     801065a3 <uartputc+0x49>
80106589:	83 ec 0c             	sub    $0xc,%esp
8010658c:	68 fd 03 00 00       	push   $0x3fd
80106591:	e8 9f fe ff ff       	call   80106435 <inb>
80106596:	83 c4 10             	add    $0x10,%esp
80106599:	0f b6 c0             	movzbl %al,%eax
8010659c:	83 e0 20             	and    $0x20,%eax
8010659f:	85 c0                	test   %eax,%eax
801065a1:	74 cf                	je     80106572 <uartputc+0x18>
  outb(COM1+0, c);
801065a3:	8b 45 08             	mov    0x8(%ebp),%eax
801065a6:	0f b6 c0             	movzbl %al,%eax
801065a9:	83 ec 08             	sub    $0x8,%esp
801065ac:	50                   	push   %eax
801065ad:	68 f8 03 00 00       	push   $0x3f8
801065b2:	e8 9b fe ff ff       	call   80106452 <outb>
801065b7:	83 c4 10             	add    $0x10,%esp
801065ba:	eb 01                	jmp    801065bd <uartputc+0x63>
    return;
801065bc:	90                   	nop
}
801065bd:	c9                   	leave  
801065be:	c3                   	ret    

801065bf <uartgetc>:

static int
uartgetc(void)
{
801065bf:	55                   	push   %ebp
801065c0:	89 e5                	mov    %esp,%ebp
  if(!uart)
801065c2:	a1 78 6a 19 80       	mov    0x80196a78,%eax
801065c7:	85 c0                	test   %eax,%eax
801065c9:	75 07                	jne    801065d2 <uartgetc+0x13>
    return -1;
801065cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d0:	eb 2e                	jmp    80106600 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801065d2:	68 fd 03 00 00       	push   $0x3fd
801065d7:	e8 59 fe ff ff       	call   80106435 <inb>
801065dc:	83 c4 04             	add    $0x4,%esp
801065df:	0f b6 c0             	movzbl %al,%eax
801065e2:	83 e0 01             	and    $0x1,%eax
801065e5:	85 c0                	test   %eax,%eax
801065e7:	75 07                	jne    801065f0 <uartgetc+0x31>
    return -1;
801065e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ee:	eb 10                	jmp    80106600 <uartgetc+0x41>
  return inb(COM1+0);
801065f0:	68 f8 03 00 00       	push   $0x3f8
801065f5:	e8 3b fe ff ff       	call   80106435 <inb>
801065fa:	83 c4 04             	add    $0x4,%esp
801065fd:	0f b6 c0             	movzbl %al,%eax
}
80106600:	c9                   	leave  
80106601:	c3                   	ret    

80106602 <uartintr>:

void
uartintr(void)
{
80106602:	55                   	push   %ebp
80106603:	89 e5                	mov    %esp,%ebp
80106605:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	68 bf 65 10 80       	push   $0x801065bf
80106610:	e8 c1 a1 ff ff       	call   801007d6 <consoleintr>
80106615:	83 c4 10             	add    $0x10,%esp
}
80106618:	90                   	nop
80106619:	c9                   	leave  
8010661a:	c3                   	ret    

8010661b <vector0>:
8010661b:	6a 00                	push   $0x0
8010661d:	6a 00                	push   $0x0
8010661f:	e9 c2 f9 ff ff       	jmp    80105fe6 <alltraps>

80106624 <vector1>:
80106624:	6a 00                	push   $0x0
80106626:	6a 01                	push   $0x1
80106628:	e9 b9 f9 ff ff       	jmp    80105fe6 <alltraps>

8010662d <vector2>:
8010662d:	6a 00                	push   $0x0
8010662f:	6a 02                	push   $0x2
80106631:	e9 b0 f9 ff ff       	jmp    80105fe6 <alltraps>

80106636 <vector3>:
80106636:	6a 00                	push   $0x0
80106638:	6a 03                	push   $0x3
8010663a:	e9 a7 f9 ff ff       	jmp    80105fe6 <alltraps>

8010663f <vector4>:
8010663f:	6a 00                	push   $0x0
80106641:	6a 04                	push   $0x4
80106643:	e9 9e f9 ff ff       	jmp    80105fe6 <alltraps>

80106648 <vector5>:
80106648:	6a 00                	push   $0x0
8010664a:	6a 05                	push   $0x5
8010664c:	e9 95 f9 ff ff       	jmp    80105fe6 <alltraps>

80106651 <vector6>:
80106651:	6a 00                	push   $0x0
80106653:	6a 06                	push   $0x6
80106655:	e9 8c f9 ff ff       	jmp    80105fe6 <alltraps>

8010665a <vector7>:
8010665a:	6a 00                	push   $0x0
8010665c:	6a 07                	push   $0x7
8010665e:	e9 83 f9 ff ff       	jmp    80105fe6 <alltraps>

80106663 <vector8>:
80106663:	6a 08                	push   $0x8
80106665:	e9 7c f9 ff ff       	jmp    80105fe6 <alltraps>

8010666a <vector9>:
8010666a:	6a 00                	push   $0x0
8010666c:	6a 09                	push   $0x9
8010666e:	e9 73 f9 ff ff       	jmp    80105fe6 <alltraps>

80106673 <vector10>:
80106673:	6a 0a                	push   $0xa
80106675:	e9 6c f9 ff ff       	jmp    80105fe6 <alltraps>

8010667a <vector11>:
8010667a:	6a 0b                	push   $0xb
8010667c:	e9 65 f9 ff ff       	jmp    80105fe6 <alltraps>

80106681 <vector12>:
80106681:	6a 0c                	push   $0xc
80106683:	e9 5e f9 ff ff       	jmp    80105fe6 <alltraps>

80106688 <vector13>:
80106688:	6a 0d                	push   $0xd
8010668a:	e9 57 f9 ff ff       	jmp    80105fe6 <alltraps>

8010668f <vector14>:
8010668f:	6a 0e                	push   $0xe
80106691:	e9 50 f9 ff ff       	jmp    80105fe6 <alltraps>

80106696 <vector15>:
80106696:	6a 00                	push   $0x0
80106698:	6a 0f                	push   $0xf
8010669a:	e9 47 f9 ff ff       	jmp    80105fe6 <alltraps>

8010669f <vector16>:
8010669f:	6a 00                	push   $0x0
801066a1:	6a 10                	push   $0x10
801066a3:	e9 3e f9 ff ff       	jmp    80105fe6 <alltraps>

801066a8 <vector17>:
801066a8:	6a 11                	push   $0x11
801066aa:	e9 37 f9 ff ff       	jmp    80105fe6 <alltraps>

801066af <vector18>:
801066af:	6a 00                	push   $0x0
801066b1:	6a 12                	push   $0x12
801066b3:	e9 2e f9 ff ff       	jmp    80105fe6 <alltraps>

801066b8 <vector19>:
801066b8:	6a 00                	push   $0x0
801066ba:	6a 13                	push   $0x13
801066bc:	e9 25 f9 ff ff       	jmp    80105fe6 <alltraps>

801066c1 <vector20>:
801066c1:	6a 00                	push   $0x0
801066c3:	6a 14                	push   $0x14
801066c5:	e9 1c f9 ff ff       	jmp    80105fe6 <alltraps>

801066ca <vector21>:
801066ca:	6a 00                	push   $0x0
801066cc:	6a 15                	push   $0x15
801066ce:	e9 13 f9 ff ff       	jmp    80105fe6 <alltraps>

801066d3 <vector22>:
801066d3:	6a 00                	push   $0x0
801066d5:	6a 16                	push   $0x16
801066d7:	e9 0a f9 ff ff       	jmp    80105fe6 <alltraps>

801066dc <vector23>:
801066dc:	6a 00                	push   $0x0
801066de:	6a 17                	push   $0x17
801066e0:	e9 01 f9 ff ff       	jmp    80105fe6 <alltraps>

801066e5 <vector24>:
801066e5:	6a 00                	push   $0x0
801066e7:	6a 18                	push   $0x18
801066e9:	e9 f8 f8 ff ff       	jmp    80105fe6 <alltraps>

801066ee <vector25>:
801066ee:	6a 00                	push   $0x0
801066f0:	6a 19                	push   $0x19
801066f2:	e9 ef f8 ff ff       	jmp    80105fe6 <alltraps>

801066f7 <vector26>:
801066f7:	6a 00                	push   $0x0
801066f9:	6a 1a                	push   $0x1a
801066fb:	e9 e6 f8 ff ff       	jmp    80105fe6 <alltraps>

80106700 <vector27>:
80106700:	6a 00                	push   $0x0
80106702:	6a 1b                	push   $0x1b
80106704:	e9 dd f8 ff ff       	jmp    80105fe6 <alltraps>

80106709 <vector28>:
80106709:	6a 00                	push   $0x0
8010670b:	6a 1c                	push   $0x1c
8010670d:	e9 d4 f8 ff ff       	jmp    80105fe6 <alltraps>

80106712 <vector29>:
80106712:	6a 00                	push   $0x0
80106714:	6a 1d                	push   $0x1d
80106716:	e9 cb f8 ff ff       	jmp    80105fe6 <alltraps>

8010671b <vector30>:
8010671b:	6a 00                	push   $0x0
8010671d:	6a 1e                	push   $0x1e
8010671f:	e9 c2 f8 ff ff       	jmp    80105fe6 <alltraps>

80106724 <vector31>:
80106724:	6a 00                	push   $0x0
80106726:	6a 1f                	push   $0x1f
80106728:	e9 b9 f8 ff ff       	jmp    80105fe6 <alltraps>

8010672d <vector32>:
8010672d:	6a 00                	push   $0x0
8010672f:	6a 20                	push   $0x20
80106731:	e9 b0 f8 ff ff       	jmp    80105fe6 <alltraps>

80106736 <vector33>:
80106736:	6a 00                	push   $0x0
80106738:	6a 21                	push   $0x21
8010673a:	e9 a7 f8 ff ff       	jmp    80105fe6 <alltraps>

8010673f <vector34>:
8010673f:	6a 00                	push   $0x0
80106741:	6a 22                	push   $0x22
80106743:	e9 9e f8 ff ff       	jmp    80105fe6 <alltraps>

80106748 <vector35>:
80106748:	6a 00                	push   $0x0
8010674a:	6a 23                	push   $0x23
8010674c:	e9 95 f8 ff ff       	jmp    80105fe6 <alltraps>

80106751 <vector36>:
80106751:	6a 00                	push   $0x0
80106753:	6a 24                	push   $0x24
80106755:	e9 8c f8 ff ff       	jmp    80105fe6 <alltraps>

8010675a <vector37>:
8010675a:	6a 00                	push   $0x0
8010675c:	6a 25                	push   $0x25
8010675e:	e9 83 f8 ff ff       	jmp    80105fe6 <alltraps>

80106763 <vector38>:
80106763:	6a 00                	push   $0x0
80106765:	6a 26                	push   $0x26
80106767:	e9 7a f8 ff ff       	jmp    80105fe6 <alltraps>

8010676c <vector39>:
8010676c:	6a 00                	push   $0x0
8010676e:	6a 27                	push   $0x27
80106770:	e9 71 f8 ff ff       	jmp    80105fe6 <alltraps>

80106775 <vector40>:
80106775:	6a 00                	push   $0x0
80106777:	6a 28                	push   $0x28
80106779:	e9 68 f8 ff ff       	jmp    80105fe6 <alltraps>

8010677e <vector41>:
8010677e:	6a 00                	push   $0x0
80106780:	6a 29                	push   $0x29
80106782:	e9 5f f8 ff ff       	jmp    80105fe6 <alltraps>

80106787 <vector42>:
80106787:	6a 00                	push   $0x0
80106789:	6a 2a                	push   $0x2a
8010678b:	e9 56 f8 ff ff       	jmp    80105fe6 <alltraps>

80106790 <vector43>:
80106790:	6a 00                	push   $0x0
80106792:	6a 2b                	push   $0x2b
80106794:	e9 4d f8 ff ff       	jmp    80105fe6 <alltraps>

80106799 <vector44>:
80106799:	6a 00                	push   $0x0
8010679b:	6a 2c                	push   $0x2c
8010679d:	e9 44 f8 ff ff       	jmp    80105fe6 <alltraps>

801067a2 <vector45>:
801067a2:	6a 00                	push   $0x0
801067a4:	6a 2d                	push   $0x2d
801067a6:	e9 3b f8 ff ff       	jmp    80105fe6 <alltraps>

801067ab <vector46>:
801067ab:	6a 00                	push   $0x0
801067ad:	6a 2e                	push   $0x2e
801067af:	e9 32 f8 ff ff       	jmp    80105fe6 <alltraps>

801067b4 <vector47>:
801067b4:	6a 00                	push   $0x0
801067b6:	6a 2f                	push   $0x2f
801067b8:	e9 29 f8 ff ff       	jmp    80105fe6 <alltraps>

801067bd <vector48>:
801067bd:	6a 00                	push   $0x0
801067bf:	6a 30                	push   $0x30
801067c1:	e9 20 f8 ff ff       	jmp    80105fe6 <alltraps>

801067c6 <vector49>:
801067c6:	6a 00                	push   $0x0
801067c8:	6a 31                	push   $0x31
801067ca:	e9 17 f8 ff ff       	jmp    80105fe6 <alltraps>

801067cf <vector50>:
801067cf:	6a 00                	push   $0x0
801067d1:	6a 32                	push   $0x32
801067d3:	e9 0e f8 ff ff       	jmp    80105fe6 <alltraps>

801067d8 <vector51>:
801067d8:	6a 00                	push   $0x0
801067da:	6a 33                	push   $0x33
801067dc:	e9 05 f8 ff ff       	jmp    80105fe6 <alltraps>

801067e1 <vector52>:
801067e1:	6a 00                	push   $0x0
801067e3:	6a 34                	push   $0x34
801067e5:	e9 fc f7 ff ff       	jmp    80105fe6 <alltraps>

801067ea <vector53>:
801067ea:	6a 00                	push   $0x0
801067ec:	6a 35                	push   $0x35
801067ee:	e9 f3 f7 ff ff       	jmp    80105fe6 <alltraps>

801067f3 <vector54>:
801067f3:	6a 00                	push   $0x0
801067f5:	6a 36                	push   $0x36
801067f7:	e9 ea f7 ff ff       	jmp    80105fe6 <alltraps>

801067fc <vector55>:
801067fc:	6a 00                	push   $0x0
801067fe:	6a 37                	push   $0x37
80106800:	e9 e1 f7 ff ff       	jmp    80105fe6 <alltraps>

80106805 <vector56>:
80106805:	6a 00                	push   $0x0
80106807:	6a 38                	push   $0x38
80106809:	e9 d8 f7 ff ff       	jmp    80105fe6 <alltraps>

8010680e <vector57>:
8010680e:	6a 00                	push   $0x0
80106810:	6a 39                	push   $0x39
80106812:	e9 cf f7 ff ff       	jmp    80105fe6 <alltraps>

80106817 <vector58>:
80106817:	6a 00                	push   $0x0
80106819:	6a 3a                	push   $0x3a
8010681b:	e9 c6 f7 ff ff       	jmp    80105fe6 <alltraps>

80106820 <vector59>:
80106820:	6a 00                	push   $0x0
80106822:	6a 3b                	push   $0x3b
80106824:	e9 bd f7 ff ff       	jmp    80105fe6 <alltraps>

80106829 <vector60>:
80106829:	6a 00                	push   $0x0
8010682b:	6a 3c                	push   $0x3c
8010682d:	e9 b4 f7 ff ff       	jmp    80105fe6 <alltraps>

80106832 <vector61>:
80106832:	6a 00                	push   $0x0
80106834:	6a 3d                	push   $0x3d
80106836:	e9 ab f7 ff ff       	jmp    80105fe6 <alltraps>

8010683b <vector62>:
8010683b:	6a 00                	push   $0x0
8010683d:	6a 3e                	push   $0x3e
8010683f:	e9 a2 f7 ff ff       	jmp    80105fe6 <alltraps>

80106844 <vector63>:
80106844:	6a 00                	push   $0x0
80106846:	6a 3f                	push   $0x3f
80106848:	e9 99 f7 ff ff       	jmp    80105fe6 <alltraps>

8010684d <vector64>:
8010684d:	6a 00                	push   $0x0
8010684f:	6a 40                	push   $0x40
80106851:	e9 90 f7 ff ff       	jmp    80105fe6 <alltraps>

80106856 <vector65>:
80106856:	6a 00                	push   $0x0
80106858:	6a 41                	push   $0x41
8010685a:	e9 87 f7 ff ff       	jmp    80105fe6 <alltraps>

8010685f <vector66>:
8010685f:	6a 00                	push   $0x0
80106861:	6a 42                	push   $0x42
80106863:	e9 7e f7 ff ff       	jmp    80105fe6 <alltraps>

80106868 <vector67>:
80106868:	6a 00                	push   $0x0
8010686a:	6a 43                	push   $0x43
8010686c:	e9 75 f7 ff ff       	jmp    80105fe6 <alltraps>

80106871 <vector68>:
80106871:	6a 00                	push   $0x0
80106873:	6a 44                	push   $0x44
80106875:	e9 6c f7 ff ff       	jmp    80105fe6 <alltraps>

8010687a <vector69>:
8010687a:	6a 00                	push   $0x0
8010687c:	6a 45                	push   $0x45
8010687e:	e9 63 f7 ff ff       	jmp    80105fe6 <alltraps>

80106883 <vector70>:
80106883:	6a 00                	push   $0x0
80106885:	6a 46                	push   $0x46
80106887:	e9 5a f7 ff ff       	jmp    80105fe6 <alltraps>

8010688c <vector71>:
8010688c:	6a 00                	push   $0x0
8010688e:	6a 47                	push   $0x47
80106890:	e9 51 f7 ff ff       	jmp    80105fe6 <alltraps>

80106895 <vector72>:
80106895:	6a 00                	push   $0x0
80106897:	6a 48                	push   $0x48
80106899:	e9 48 f7 ff ff       	jmp    80105fe6 <alltraps>

8010689e <vector73>:
8010689e:	6a 00                	push   $0x0
801068a0:	6a 49                	push   $0x49
801068a2:	e9 3f f7 ff ff       	jmp    80105fe6 <alltraps>

801068a7 <vector74>:
801068a7:	6a 00                	push   $0x0
801068a9:	6a 4a                	push   $0x4a
801068ab:	e9 36 f7 ff ff       	jmp    80105fe6 <alltraps>

801068b0 <vector75>:
801068b0:	6a 00                	push   $0x0
801068b2:	6a 4b                	push   $0x4b
801068b4:	e9 2d f7 ff ff       	jmp    80105fe6 <alltraps>

801068b9 <vector76>:
801068b9:	6a 00                	push   $0x0
801068bb:	6a 4c                	push   $0x4c
801068bd:	e9 24 f7 ff ff       	jmp    80105fe6 <alltraps>

801068c2 <vector77>:
801068c2:	6a 00                	push   $0x0
801068c4:	6a 4d                	push   $0x4d
801068c6:	e9 1b f7 ff ff       	jmp    80105fe6 <alltraps>

801068cb <vector78>:
801068cb:	6a 00                	push   $0x0
801068cd:	6a 4e                	push   $0x4e
801068cf:	e9 12 f7 ff ff       	jmp    80105fe6 <alltraps>

801068d4 <vector79>:
801068d4:	6a 00                	push   $0x0
801068d6:	6a 4f                	push   $0x4f
801068d8:	e9 09 f7 ff ff       	jmp    80105fe6 <alltraps>

801068dd <vector80>:
801068dd:	6a 00                	push   $0x0
801068df:	6a 50                	push   $0x50
801068e1:	e9 00 f7 ff ff       	jmp    80105fe6 <alltraps>

801068e6 <vector81>:
801068e6:	6a 00                	push   $0x0
801068e8:	6a 51                	push   $0x51
801068ea:	e9 f7 f6 ff ff       	jmp    80105fe6 <alltraps>

801068ef <vector82>:
801068ef:	6a 00                	push   $0x0
801068f1:	6a 52                	push   $0x52
801068f3:	e9 ee f6 ff ff       	jmp    80105fe6 <alltraps>

801068f8 <vector83>:
801068f8:	6a 00                	push   $0x0
801068fa:	6a 53                	push   $0x53
801068fc:	e9 e5 f6 ff ff       	jmp    80105fe6 <alltraps>

80106901 <vector84>:
80106901:	6a 00                	push   $0x0
80106903:	6a 54                	push   $0x54
80106905:	e9 dc f6 ff ff       	jmp    80105fe6 <alltraps>

8010690a <vector85>:
8010690a:	6a 00                	push   $0x0
8010690c:	6a 55                	push   $0x55
8010690e:	e9 d3 f6 ff ff       	jmp    80105fe6 <alltraps>

80106913 <vector86>:
80106913:	6a 00                	push   $0x0
80106915:	6a 56                	push   $0x56
80106917:	e9 ca f6 ff ff       	jmp    80105fe6 <alltraps>

8010691c <vector87>:
8010691c:	6a 00                	push   $0x0
8010691e:	6a 57                	push   $0x57
80106920:	e9 c1 f6 ff ff       	jmp    80105fe6 <alltraps>

80106925 <vector88>:
80106925:	6a 00                	push   $0x0
80106927:	6a 58                	push   $0x58
80106929:	e9 b8 f6 ff ff       	jmp    80105fe6 <alltraps>

8010692e <vector89>:
8010692e:	6a 00                	push   $0x0
80106930:	6a 59                	push   $0x59
80106932:	e9 af f6 ff ff       	jmp    80105fe6 <alltraps>

80106937 <vector90>:
80106937:	6a 00                	push   $0x0
80106939:	6a 5a                	push   $0x5a
8010693b:	e9 a6 f6 ff ff       	jmp    80105fe6 <alltraps>

80106940 <vector91>:
80106940:	6a 00                	push   $0x0
80106942:	6a 5b                	push   $0x5b
80106944:	e9 9d f6 ff ff       	jmp    80105fe6 <alltraps>

80106949 <vector92>:
80106949:	6a 00                	push   $0x0
8010694b:	6a 5c                	push   $0x5c
8010694d:	e9 94 f6 ff ff       	jmp    80105fe6 <alltraps>

80106952 <vector93>:
80106952:	6a 00                	push   $0x0
80106954:	6a 5d                	push   $0x5d
80106956:	e9 8b f6 ff ff       	jmp    80105fe6 <alltraps>

8010695b <vector94>:
8010695b:	6a 00                	push   $0x0
8010695d:	6a 5e                	push   $0x5e
8010695f:	e9 82 f6 ff ff       	jmp    80105fe6 <alltraps>

80106964 <vector95>:
80106964:	6a 00                	push   $0x0
80106966:	6a 5f                	push   $0x5f
80106968:	e9 79 f6 ff ff       	jmp    80105fe6 <alltraps>

8010696d <vector96>:
8010696d:	6a 00                	push   $0x0
8010696f:	6a 60                	push   $0x60
80106971:	e9 70 f6 ff ff       	jmp    80105fe6 <alltraps>

80106976 <vector97>:
80106976:	6a 00                	push   $0x0
80106978:	6a 61                	push   $0x61
8010697a:	e9 67 f6 ff ff       	jmp    80105fe6 <alltraps>

8010697f <vector98>:
8010697f:	6a 00                	push   $0x0
80106981:	6a 62                	push   $0x62
80106983:	e9 5e f6 ff ff       	jmp    80105fe6 <alltraps>

80106988 <vector99>:
80106988:	6a 00                	push   $0x0
8010698a:	6a 63                	push   $0x63
8010698c:	e9 55 f6 ff ff       	jmp    80105fe6 <alltraps>

80106991 <vector100>:
80106991:	6a 00                	push   $0x0
80106993:	6a 64                	push   $0x64
80106995:	e9 4c f6 ff ff       	jmp    80105fe6 <alltraps>

8010699a <vector101>:
8010699a:	6a 00                	push   $0x0
8010699c:	6a 65                	push   $0x65
8010699e:	e9 43 f6 ff ff       	jmp    80105fe6 <alltraps>

801069a3 <vector102>:
801069a3:	6a 00                	push   $0x0
801069a5:	6a 66                	push   $0x66
801069a7:	e9 3a f6 ff ff       	jmp    80105fe6 <alltraps>

801069ac <vector103>:
801069ac:	6a 00                	push   $0x0
801069ae:	6a 67                	push   $0x67
801069b0:	e9 31 f6 ff ff       	jmp    80105fe6 <alltraps>

801069b5 <vector104>:
801069b5:	6a 00                	push   $0x0
801069b7:	6a 68                	push   $0x68
801069b9:	e9 28 f6 ff ff       	jmp    80105fe6 <alltraps>

801069be <vector105>:
801069be:	6a 00                	push   $0x0
801069c0:	6a 69                	push   $0x69
801069c2:	e9 1f f6 ff ff       	jmp    80105fe6 <alltraps>

801069c7 <vector106>:
801069c7:	6a 00                	push   $0x0
801069c9:	6a 6a                	push   $0x6a
801069cb:	e9 16 f6 ff ff       	jmp    80105fe6 <alltraps>

801069d0 <vector107>:
801069d0:	6a 00                	push   $0x0
801069d2:	6a 6b                	push   $0x6b
801069d4:	e9 0d f6 ff ff       	jmp    80105fe6 <alltraps>

801069d9 <vector108>:
801069d9:	6a 00                	push   $0x0
801069db:	6a 6c                	push   $0x6c
801069dd:	e9 04 f6 ff ff       	jmp    80105fe6 <alltraps>

801069e2 <vector109>:
801069e2:	6a 00                	push   $0x0
801069e4:	6a 6d                	push   $0x6d
801069e6:	e9 fb f5 ff ff       	jmp    80105fe6 <alltraps>

801069eb <vector110>:
801069eb:	6a 00                	push   $0x0
801069ed:	6a 6e                	push   $0x6e
801069ef:	e9 f2 f5 ff ff       	jmp    80105fe6 <alltraps>

801069f4 <vector111>:
801069f4:	6a 00                	push   $0x0
801069f6:	6a 6f                	push   $0x6f
801069f8:	e9 e9 f5 ff ff       	jmp    80105fe6 <alltraps>

801069fd <vector112>:
801069fd:	6a 00                	push   $0x0
801069ff:	6a 70                	push   $0x70
80106a01:	e9 e0 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a06 <vector113>:
80106a06:	6a 00                	push   $0x0
80106a08:	6a 71                	push   $0x71
80106a0a:	e9 d7 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a0f <vector114>:
80106a0f:	6a 00                	push   $0x0
80106a11:	6a 72                	push   $0x72
80106a13:	e9 ce f5 ff ff       	jmp    80105fe6 <alltraps>

80106a18 <vector115>:
80106a18:	6a 00                	push   $0x0
80106a1a:	6a 73                	push   $0x73
80106a1c:	e9 c5 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a21 <vector116>:
80106a21:	6a 00                	push   $0x0
80106a23:	6a 74                	push   $0x74
80106a25:	e9 bc f5 ff ff       	jmp    80105fe6 <alltraps>

80106a2a <vector117>:
80106a2a:	6a 00                	push   $0x0
80106a2c:	6a 75                	push   $0x75
80106a2e:	e9 b3 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a33 <vector118>:
80106a33:	6a 00                	push   $0x0
80106a35:	6a 76                	push   $0x76
80106a37:	e9 aa f5 ff ff       	jmp    80105fe6 <alltraps>

80106a3c <vector119>:
80106a3c:	6a 00                	push   $0x0
80106a3e:	6a 77                	push   $0x77
80106a40:	e9 a1 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a45 <vector120>:
80106a45:	6a 00                	push   $0x0
80106a47:	6a 78                	push   $0x78
80106a49:	e9 98 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a4e <vector121>:
80106a4e:	6a 00                	push   $0x0
80106a50:	6a 79                	push   $0x79
80106a52:	e9 8f f5 ff ff       	jmp    80105fe6 <alltraps>

80106a57 <vector122>:
80106a57:	6a 00                	push   $0x0
80106a59:	6a 7a                	push   $0x7a
80106a5b:	e9 86 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a60 <vector123>:
80106a60:	6a 00                	push   $0x0
80106a62:	6a 7b                	push   $0x7b
80106a64:	e9 7d f5 ff ff       	jmp    80105fe6 <alltraps>

80106a69 <vector124>:
80106a69:	6a 00                	push   $0x0
80106a6b:	6a 7c                	push   $0x7c
80106a6d:	e9 74 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a72 <vector125>:
80106a72:	6a 00                	push   $0x0
80106a74:	6a 7d                	push   $0x7d
80106a76:	e9 6b f5 ff ff       	jmp    80105fe6 <alltraps>

80106a7b <vector126>:
80106a7b:	6a 00                	push   $0x0
80106a7d:	6a 7e                	push   $0x7e
80106a7f:	e9 62 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a84 <vector127>:
80106a84:	6a 00                	push   $0x0
80106a86:	6a 7f                	push   $0x7f
80106a88:	e9 59 f5 ff ff       	jmp    80105fe6 <alltraps>

80106a8d <vector128>:
80106a8d:	6a 00                	push   $0x0
80106a8f:	68 80 00 00 00       	push   $0x80
80106a94:	e9 4d f5 ff ff       	jmp    80105fe6 <alltraps>

80106a99 <vector129>:
80106a99:	6a 00                	push   $0x0
80106a9b:	68 81 00 00 00       	push   $0x81
80106aa0:	e9 41 f5 ff ff       	jmp    80105fe6 <alltraps>

80106aa5 <vector130>:
80106aa5:	6a 00                	push   $0x0
80106aa7:	68 82 00 00 00       	push   $0x82
80106aac:	e9 35 f5 ff ff       	jmp    80105fe6 <alltraps>

80106ab1 <vector131>:
80106ab1:	6a 00                	push   $0x0
80106ab3:	68 83 00 00 00       	push   $0x83
80106ab8:	e9 29 f5 ff ff       	jmp    80105fe6 <alltraps>

80106abd <vector132>:
80106abd:	6a 00                	push   $0x0
80106abf:	68 84 00 00 00       	push   $0x84
80106ac4:	e9 1d f5 ff ff       	jmp    80105fe6 <alltraps>

80106ac9 <vector133>:
80106ac9:	6a 00                	push   $0x0
80106acb:	68 85 00 00 00       	push   $0x85
80106ad0:	e9 11 f5 ff ff       	jmp    80105fe6 <alltraps>

80106ad5 <vector134>:
80106ad5:	6a 00                	push   $0x0
80106ad7:	68 86 00 00 00       	push   $0x86
80106adc:	e9 05 f5 ff ff       	jmp    80105fe6 <alltraps>

80106ae1 <vector135>:
80106ae1:	6a 00                	push   $0x0
80106ae3:	68 87 00 00 00       	push   $0x87
80106ae8:	e9 f9 f4 ff ff       	jmp    80105fe6 <alltraps>

80106aed <vector136>:
80106aed:	6a 00                	push   $0x0
80106aef:	68 88 00 00 00       	push   $0x88
80106af4:	e9 ed f4 ff ff       	jmp    80105fe6 <alltraps>

80106af9 <vector137>:
80106af9:	6a 00                	push   $0x0
80106afb:	68 89 00 00 00       	push   $0x89
80106b00:	e9 e1 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b05 <vector138>:
80106b05:	6a 00                	push   $0x0
80106b07:	68 8a 00 00 00       	push   $0x8a
80106b0c:	e9 d5 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b11 <vector139>:
80106b11:	6a 00                	push   $0x0
80106b13:	68 8b 00 00 00       	push   $0x8b
80106b18:	e9 c9 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b1d <vector140>:
80106b1d:	6a 00                	push   $0x0
80106b1f:	68 8c 00 00 00       	push   $0x8c
80106b24:	e9 bd f4 ff ff       	jmp    80105fe6 <alltraps>

80106b29 <vector141>:
80106b29:	6a 00                	push   $0x0
80106b2b:	68 8d 00 00 00       	push   $0x8d
80106b30:	e9 b1 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b35 <vector142>:
80106b35:	6a 00                	push   $0x0
80106b37:	68 8e 00 00 00       	push   $0x8e
80106b3c:	e9 a5 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b41 <vector143>:
80106b41:	6a 00                	push   $0x0
80106b43:	68 8f 00 00 00       	push   $0x8f
80106b48:	e9 99 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b4d <vector144>:
80106b4d:	6a 00                	push   $0x0
80106b4f:	68 90 00 00 00       	push   $0x90
80106b54:	e9 8d f4 ff ff       	jmp    80105fe6 <alltraps>

80106b59 <vector145>:
80106b59:	6a 00                	push   $0x0
80106b5b:	68 91 00 00 00       	push   $0x91
80106b60:	e9 81 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b65 <vector146>:
80106b65:	6a 00                	push   $0x0
80106b67:	68 92 00 00 00       	push   $0x92
80106b6c:	e9 75 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b71 <vector147>:
80106b71:	6a 00                	push   $0x0
80106b73:	68 93 00 00 00       	push   $0x93
80106b78:	e9 69 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b7d <vector148>:
80106b7d:	6a 00                	push   $0x0
80106b7f:	68 94 00 00 00       	push   $0x94
80106b84:	e9 5d f4 ff ff       	jmp    80105fe6 <alltraps>

80106b89 <vector149>:
80106b89:	6a 00                	push   $0x0
80106b8b:	68 95 00 00 00       	push   $0x95
80106b90:	e9 51 f4 ff ff       	jmp    80105fe6 <alltraps>

80106b95 <vector150>:
80106b95:	6a 00                	push   $0x0
80106b97:	68 96 00 00 00       	push   $0x96
80106b9c:	e9 45 f4 ff ff       	jmp    80105fe6 <alltraps>

80106ba1 <vector151>:
80106ba1:	6a 00                	push   $0x0
80106ba3:	68 97 00 00 00       	push   $0x97
80106ba8:	e9 39 f4 ff ff       	jmp    80105fe6 <alltraps>

80106bad <vector152>:
80106bad:	6a 00                	push   $0x0
80106baf:	68 98 00 00 00       	push   $0x98
80106bb4:	e9 2d f4 ff ff       	jmp    80105fe6 <alltraps>

80106bb9 <vector153>:
80106bb9:	6a 00                	push   $0x0
80106bbb:	68 99 00 00 00       	push   $0x99
80106bc0:	e9 21 f4 ff ff       	jmp    80105fe6 <alltraps>

80106bc5 <vector154>:
80106bc5:	6a 00                	push   $0x0
80106bc7:	68 9a 00 00 00       	push   $0x9a
80106bcc:	e9 15 f4 ff ff       	jmp    80105fe6 <alltraps>

80106bd1 <vector155>:
80106bd1:	6a 00                	push   $0x0
80106bd3:	68 9b 00 00 00       	push   $0x9b
80106bd8:	e9 09 f4 ff ff       	jmp    80105fe6 <alltraps>

80106bdd <vector156>:
80106bdd:	6a 00                	push   $0x0
80106bdf:	68 9c 00 00 00       	push   $0x9c
80106be4:	e9 fd f3 ff ff       	jmp    80105fe6 <alltraps>

80106be9 <vector157>:
80106be9:	6a 00                	push   $0x0
80106beb:	68 9d 00 00 00       	push   $0x9d
80106bf0:	e9 f1 f3 ff ff       	jmp    80105fe6 <alltraps>

80106bf5 <vector158>:
80106bf5:	6a 00                	push   $0x0
80106bf7:	68 9e 00 00 00       	push   $0x9e
80106bfc:	e9 e5 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c01 <vector159>:
80106c01:	6a 00                	push   $0x0
80106c03:	68 9f 00 00 00       	push   $0x9f
80106c08:	e9 d9 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c0d <vector160>:
80106c0d:	6a 00                	push   $0x0
80106c0f:	68 a0 00 00 00       	push   $0xa0
80106c14:	e9 cd f3 ff ff       	jmp    80105fe6 <alltraps>

80106c19 <vector161>:
80106c19:	6a 00                	push   $0x0
80106c1b:	68 a1 00 00 00       	push   $0xa1
80106c20:	e9 c1 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c25 <vector162>:
80106c25:	6a 00                	push   $0x0
80106c27:	68 a2 00 00 00       	push   $0xa2
80106c2c:	e9 b5 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c31 <vector163>:
80106c31:	6a 00                	push   $0x0
80106c33:	68 a3 00 00 00       	push   $0xa3
80106c38:	e9 a9 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c3d <vector164>:
80106c3d:	6a 00                	push   $0x0
80106c3f:	68 a4 00 00 00       	push   $0xa4
80106c44:	e9 9d f3 ff ff       	jmp    80105fe6 <alltraps>

80106c49 <vector165>:
80106c49:	6a 00                	push   $0x0
80106c4b:	68 a5 00 00 00       	push   $0xa5
80106c50:	e9 91 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c55 <vector166>:
80106c55:	6a 00                	push   $0x0
80106c57:	68 a6 00 00 00       	push   $0xa6
80106c5c:	e9 85 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c61 <vector167>:
80106c61:	6a 00                	push   $0x0
80106c63:	68 a7 00 00 00       	push   $0xa7
80106c68:	e9 79 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c6d <vector168>:
80106c6d:	6a 00                	push   $0x0
80106c6f:	68 a8 00 00 00       	push   $0xa8
80106c74:	e9 6d f3 ff ff       	jmp    80105fe6 <alltraps>

80106c79 <vector169>:
80106c79:	6a 00                	push   $0x0
80106c7b:	68 a9 00 00 00       	push   $0xa9
80106c80:	e9 61 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c85 <vector170>:
80106c85:	6a 00                	push   $0x0
80106c87:	68 aa 00 00 00       	push   $0xaa
80106c8c:	e9 55 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c91 <vector171>:
80106c91:	6a 00                	push   $0x0
80106c93:	68 ab 00 00 00       	push   $0xab
80106c98:	e9 49 f3 ff ff       	jmp    80105fe6 <alltraps>

80106c9d <vector172>:
80106c9d:	6a 00                	push   $0x0
80106c9f:	68 ac 00 00 00       	push   $0xac
80106ca4:	e9 3d f3 ff ff       	jmp    80105fe6 <alltraps>

80106ca9 <vector173>:
80106ca9:	6a 00                	push   $0x0
80106cab:	68 ad 00 00 00       	push   $0xad
80106cb0:	e9 31 f3 ff ff       	jmp    80105fe6 <alltraps>

80106cb5 <vector174>:
80106cb5:	6a 00                	push   $0x0
80106cb7:	68 ae 00 00 00       	push   $0xae
80106cbc:	e9 25 f3 ff ff       	jmp    80105fe6 <alltraps>

80106cc1 <vector175>:
80106cc1:	6a 00                	push   $0x0
80106cc3:	68 af 00 00 00       	push   $0xaf
80106cc8:	e9 19 f3 ff ff       	jmp    80105fe6 <alltraps>

80106ccd <vector176>:
80106ccd:	6a 00                	push   $0x0
80106ccf:	68 b0 00 00 00       	push   $0xb0
80106cd4:	e9 0d f3 ff ff       	jmp    80105fe6 <alltraps>

80106cd9 <vector177>:
80106cd9:	6a 00                	push   $0x0
80106cdb:	68 b1 00 00 00       	push   $0xb1
80106ce0:	e9 01 f3 ff ff       	jmp    80105fe6 <alltraps>

80106ce5 <vector178>:
80106ce5:	6a 00                	push   $0x0
80106ce7:	68 b2 00 00 00       	push   $0xb2
80106cec:	e9 f5 f2 ff ff       	jmp    80105fe6 <alltraps>

80106cf1 <vector179>:
80106cf1:	6a 00                	push   $0x0
80106cf3:	68 b3 00 00 00       	push   $0xb3
80106cf8:	e9 e9 f2 ff ff       	jmp    80105fe6 <alltraps>

80106cfd <vector180>:
80106cfd:	6a 00                	push   $0x0
80106cff:	68 b4 00 00 00       	push   $0xb4
80106d04:	e9 dd f2 ff ff       	jmp    80105fe6 <alltraps>

80106d09 <vector181>:
80106d09:	6a 00                	push   $0x0
80106d0b:	68 b5 00 00 00       	push   $0xb5
80106d10:	e9 d1 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d15 <vector182>:
80106d15:	6a 00                	push   $0x0
80106d17:	68 b6 00 00 00       	push   $0xb6
80106d1c:	e9 c5 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d21 <vector183>:
80106d21:	6a 00                	push   $0x0
80106d23:	68 b7 00 00 00       	push   $0xb7
80106d28:	e9 b9 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d2d <vector184>:
80106d2d:	6a 00                	push   $0x0
80106d2f:	68 b8 00 00 00       	push   $0xb8
80106d34:	e9 ad f2 ff ff       	jmp    80105fe6 <alltraps>

80106d39 <vector185>:
80106d39:	6a 00                	push   $0x0
80106d3b:	68 b9 00 00 00       	push   $0xb9
80106d40:	e9 a1 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d45 <vector186>:
80106d45:	6a 00                	push   $0x0
80106d47:	68 ba 00 00 00       	push   $0xba
80106d4c:	e9 95 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d51 <vector187>:
80106d51:	6a 00                	push   $0x0
80106d53:	68 bb 00 00 00       	push   $0xbb
80106d58:	e9 89 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d5d <vector188>:
80106d5d:	6a 00                	push   $0x0
80106d5f:	68 bc 00 00 00       	push   $0xbc
80106d64:	e9 7d f2 ff ff       	jmp    80105fe6 <alltraps>

80106d69 <vector189>:
80106d69:	6a 00                	push   $0x0
80106d6b:	68 bd 00 00 00       	push   $0xbd
80106d70:	e9 71 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d75 <vector190>:
80106d75:	6a 00                	push   $0x0
80106d77:	68 be 00 00 00       	push   $0xbe
80106d7c:	e9 65 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d81 <vector191>:
80106d81:	6a 00                	push   $0x0
80106d83:	68 bf 00 00 00       	push   $0xbf
80106d88:	e9 59 f2 ff ff       	jmp    80105fe6 <alltraps>

80106d8d <vector192>:
80106d8d:	6a 00                	push   $0x0
80106d8f:	68 c0 00 00 00       	push   $0xc0
80106d94:	e9 4d f2 ff ff       	jmp    80105fe6 <alltraps>

80106d99 <vector193>:
80106d99:	6a 00                	push   $0x0
80106d9b:	68 c1 00 00 00       	push   $0xc1
80106da0:	e9 41 f2 ff ff       	jmp    80105fe6 <alltraps>

80106da5 <vector194>:
80106da5:	6a 00                	push   $0x0
80106da7:	68 c2 00 00 00       	push   $0xc2
80106dac:	e9 35 f2 ff ff       	jmp    80105fe6 <alltraps>

80106db1 <vector195>:
80106db1:	6a 00                	push   $0x0
80106db3:	68 c3 00 00 00       	push   $0xc3
80106db8:	e9 29 f2 ff ff       	jmp    80105fe6 <alltraps>

80106dbd <vector196>:
80106dbd:	6a 00                	push   $0x0
80106dbf:	68 c4 00 00 00       	push   $0xc4
80106dc4:	e9 1d f2 ff ff       	jmp    80105fe6 <alltraps>

80106dc9 <vector197>:
80106dc9:	6a 00                	push   $0x0
80106dcb:	68 c5 00 00 00       	push   $0xc5
80106dd0:	e9 11 f2 ff ff       	jmp    80105fe6 <alltraps>

80106dd5 <vector198>:
80106dd5:	6a 00                	push   $0x0
80106dd7:	68 c6 00 00 00       	push   $0xc6
80106ddc:	e9 05 f2 ff ff       	jmp    80105fe6 <alltraps>

80106de1 <vector199>:
80106de1:	6a 00                	push   $0x0
80106de3:	68 c7 00 00 00       	push   $0xc7
80106de8:	e9 f9 f1 ff ff       	jmp    80105fe6 <alltraps>

80106ded <vector200>:
80106ded:	6a 00                	push   $0x0
80106def:	68 c8 00 00 00       	push   $0xc8
80106df4:	e9 ed f1 ff ff       	jmp    80105fe6 <alltraps>

80106df9 <vector201>:
80106df9:	6a 00                	push   $0x0
80106dfb:	68 c9 00 00 00       	push   $0xc9
80106e00:	e9 e1 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e05 <vector202>:
80106e05:	6a 00                	push   $0x0
80106e07:	68 ca 00 00 00       	push   $0xca
80106e0c:	e9 d5 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e11 <vector203>:
80106e11:	6a 00                	push   $0x0
80106e13:	68 cb 00 00 00       	push   $0xcb
80106e18:	e9 c9 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e1d <vector204>:
80106e1d:	6a 00                	push   $0x0
80106e1f:	68 cc 00 00 00       	push   $0xcc
80106e24:	e9 bd f1 ff ff       	jmp    80105fe6 <alltraps>

80106e29 <vector205>:
80106e29:	6a 00                	push   $0x0
80106e2b:	68 cd 00 00 00       	push   $0xcd
80106e30:	e9 b1 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e35 <vector206>:
80106e35:	6a 00                	push   $0x0
80106e37:	68 ce 00 00 00       	push   $0xce
80106e3c:	e9 a5 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e41 <vector207>:
80106e41:	6a 00                	push   $0x0
80106e43:	68 cf 00 00 00       	push   $0xcf
80106e48:	e9 99 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e4d <vector208>:
80106e4d:	6a 00                	push   $0x0
80106e4f:	68 d0 00 00 00       	push   $0xd0
80106e54:	e9 8d f1 ff ff       	jmp    80105fe6 <alltraps>

80106e59 <vector209>:
80106e59:	6a 00                	push   $0x0
80106e5b:	68 d1 00 00 00       	push   $0xd1
80106e60:	e9 81 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e65 <vector210>:
80106e65:	6a 00                	push   $0x0
80106e67:	68 d2 00 00 00       	push   $0xd2
80106e6c:	e9 75 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e71 <vector211>:
80106e71:	6a 00                	push   $0x0
80106e73:	68 d3 00 00 00       	push   $0xd3
80106e78:	e9 69 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e7d <vector212>:
80106e7d:	6a 00                	push   $0x0
80106e7f:	68 d4 00 00 00       	push   $0xd4
80106e84:	e9 5d f1 ff ff       	jmp    80105fe6 <alltraps>

80106e89 <vector213>:
80106e89:	6a 00                	push   $0x0
80106e8b:	68 d5 00 00 00       	push   $0xd5
80106e90:	e9 51 f1 ff ff       	jmp    80105fe6 <alltraps>

80106e95 <vector214>:
80106e95:	6a 00                	push   $0x0
80106e97:	68 d6 00 00 00       	push   $0xd6
80106e9c:	e9 45 f1 ff ff       	jmp    80105fe6 <alltraps>

80106ea1 <vector215>:
80106ea1:	6a 00                	push   $0x0
80106ea3:	68 d7 00 00 00       	push   $0xd7
80106ea8:	e9 39 f1 ff ff       	jmp    80105fe6 <alltraps>

80106ead <vector216>:
80106ead:	6a 00                	push   $0x0
80106eaf:	68 d8 00 00 00       	push   $0xd8
80106eb4:	e9 2d f1 ff ff       	jmp    80105fe6 <alltraps>

80106eb9 <vector217>:
80106eb9:	6a 00                	push   $0x0
80106ebb:	68 d9 00 00 00       	push   $0xd9
80106ec0:	e9 21 f1 ff ff       	jmp    80105fe6 <alltraps>

80106ec5 <vector218>:
80106ec5:	6a 00                	push   $0x0
80106ec7:	68 da 00 00 00       	push   $0xda
80106ecc:	e9 15 f1 ff ff       	jmp    80105fe6 <alltraps>

80106ed1 <vector219>:
80106ed1:	6a 00                	push   $0x0
80106ed3:	68 db 00 00 00       	push   $0xdb
80106ed8:	e9 09 f1 ff ff       	jmp    80105fe6 <alltraps>

80106edd <vector220>:
80106edd:	6a 00                	push   $0x0
80106edf:	68 dc 00 00 00       	push   $0xdc
80106ee4:	e9 fd f0 ff ff       	jmp    80105fe6 <alltraps>

80106ee9 <vector221>:
80106ee9:	6a 00                	push   $0x0
80106eeb:	68 dd 00 00 00       	push   $0xdd
80106ef0:	e9 f1 f0 ff ff       	jmp    80105fe6 <alltraps>

80106ef5 <vector222>:
80106ef5:	6a 00                	push   $0x0
80106ef7:	68 de 00 00 00       	push   $0xde
80106efc:	e9 e5 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f01 <vector223>:
80106f01:	6a 00                	push   $0x0
80106f03:	68 df 00 00 00       	push   $0xdf
80106f08:	e9 d9 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f0d <vector224>:
80106f0d:	6a 00                	push   $0x0
80106f0f:	68 e0 00 00 00       	push   $0xe0
80106f14:	e9 cd f0 ff ff       	jmp    80105fe6 <alltraps>

80106f19 <vector225>:
80106f19:	6a 00                	push   $0x0
80106f1b:	68 e1 00 00 00       	push   $0xe1
80106f20:	e9 c1 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f25 <vector226>:
80106f25:	6a 00                	push   $0x0
80106f27:	68 e2 00 00 00       	push   $0xe2
80106f2c:	e9 b5 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f31 <vector227>:
80106f31:	6a 00                	push   $0x0
80106f33:	68 e3 00 00 00       	push   $0xe3
80106f38:	e9 a9 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f3d <vector228>:
80106f3d:	6a 00                	push   $0x0
80106f3f:	68 e4 00 00 00       	push   $0xe4
80106f44:	e9 9d f0 ff ff       	jmp    80105fe6 <alltraps>

80106f49 <vector229>:
80106f49:	6a 00                	push   $0x0
80106f4b:	68 e5 00 00 00       	push   $0xe5
80106f50:	e9 91 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f55 <vector230>:
80106f55:	6a 00                	push   $0x0
80106f57:	68 e6 00 00 00       	push   $0xe6
80106f5c:	e9 85 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f61 <vector231>:
80106f61:	6a 00                	push   $0x0
80106f63:	68 e7 00 00 00       	push   $0xe7
80106f68:	e9 79 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f6d <vector232>:
80106f6d:	6a 00                	push   $0x0
80106f6f:	68 e8 00 00 00       	push   $0xe8
80106f74:	e9 6d f0 ff ff       	jmp    80105fe6 <alltraps>

80106f79 <vector233>:
80106f79:	6a 00                	push   $0x0
80106f7b:	68 e9 00 00 00       	push   $0xe9
80106f80:	e9 61 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f85 <vector234>:
80106f85:	6a 00                	push   $0x0
80106f87:	68 ea 00 00 00       	push   $0xea
80106f8c:	e9 55 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f91 <vector235>:
80106f91:	6a 00                	push   $0x0
80106f93:	68 eb 00 00 00       	push   $0xeb
80106f98:	e9 49 f0 ff ff       	jmp    80105fe6 <alltraps>

80106f9d <vector236>:
80106f9d:	6a 00                	push   $0x0
80106f9f:	68 ec 00 00 00       	push   $0xec
80106fa4:	e9 3d f0 ff ff       	jmp    80105fe6 <alltraps>

80106fa9 <vector237>:
80106fa9:	6a 00                	push   $0x0
80106fab:	68 ed 00 00 00       	push   $0xed
80106fb0:	e9 31 f0 ff ff       	jmp    80105fe6 <alltraps>

80106fb5 <vector238>:
80106fb5:	6a 00                	push   $0x0
80106fb7:	68 ee 00 00 00       	push   $0xee
80106fbc:	e9 25 f0 ff ff       	jmp    80105fe6 <alltraps>

80106fc1 <vector239>:
80106fc1:	6a 00                	push   $0x0
80106fc3:	68 ef 00 00 00       	push   $0xef
80106fc8:	e9 19 f0 ff ff       	jmp    80105fe6 <alltraps>

80106fcd <vector240>:
80106fcd:	6a 00                	push   $0x0
80106fcf:	68 f0 00 00 00       	push   $0xf0
80106fd4:	e9 0d f0 ff ff       	jmp    80105fe6 <alltraps>

80106fd9 <vector241>:
80106fd9:	6a 00                	push   $0x0
80106fdb:	68 f1 00 00 00       	push   $0xf1
80106fe0:	e9 01 f0 ff ff       	jmp    80105fe6 <alltraps>

80106fe5 <vector242>:
80106fe5:	6a 00                	push   $0x0
80106fe7:	68 f2 00 00 00       	push   $0xf2
80106fec:	e9 f5 ef ff ff       	jmp    80105fe6 <alltraps>

80106ff1 <vector243>:
80106ff1:	6a 00                	push   $0x0
80106ff3:	68 f3 00 00 00       	push   $0xf3
80106ff8:	e9 e9 ef ff ff       	jmp    80105fe6 <alltraps>

80106ffd <vector244>:
80106ffd:	6a 00                	push   $0x0
80106fff:	68 f4 00 00 00       	push   $0xf4
80107004:	e9 dd ef ff ff       	jmp    80105fe6 <alltraps>

80107009 <vector245>:
80107009:	6a 00                	push   $0x0
8010700b:	68 f5 00 00 00       	push   $0xf5
80107010:	e9 d1 ef ff ff       	jmp    80105fe6 <alltraps>

80107015 <vector246>:
80107015:	6a 00                	push   $0x0
80107017:	68 f6 00 00 00       	push   $0xf6
8010701c:	e9 c5 ef ff ff       	jmp    80105fe6 <alltraps>

80107021 <vector247>:
80107021:	6a 00                	push   $0x0
80107023:	68 f7 00 00 00       	push   $0xf7
80107028:	e9 b9 ef ff ff       	jmp    80105fe6 <alltraps>

8010702d <vector248>:
8010702d:	6a 00                	push   $0x0
8010702f:	68 f8 00 00 00       	push   $0xf8
80107034:	e9 ad ef ff ff       	jmp    80105fe6 <alltraps>

80107039 <vector249>:
80107039:	6a 00                	push   $0x0
8010703b:	68 f9 00 00 00       	push   $0xf9
80107040:	e9 a1 ef ff ff       	jmp    80105fe6 <alltraps>

80107045 <vector250>:
80107045:	6a 00                	push   $0x0
80107047:	68 fa 00 00 00       	push   $0xfa
8010704c:	e9 95 ef ff ff       	jmp    80105fe6 <alltraps>

80107051 <vector251>:
80107051:	6a 00                	push   $0x0
80107053:	68 fb 00 00 00       	push   $0xfb
80107058:	e9 89 ef ff ff       	jmp    80105fe6 <alltraps>

8010705d <vector252>:
8010705d:	6a 00                	push   $0x0
8010705f:	68 fc 00 00 00       	push   $0xfc
80107064:	e9 7d ef ff ff       	jmp    80105fe6 <alltraps>

80107069 <vector253>:
80107069:	6a 00                	push   $0x0
8010706b:	68 fd 00 00 00       	push   $0xfd
80107070:	e9 71 ef ff ff       	jmp    80105fe6 <alltraps>

80107075 <vector254>:
80107075:	6a 00                	push   $0x0
80107077:	68 fe 00 00 00       	push   $0xfe
8010707c:	e9 65 ef ff ff       	jmp    80105fe6 <alltraps>

80107081 <vector255>:
80107081:	6a 00                	push   $0x0
80107083:	68 ff 00 00 00       	push   $0xff
80107088:	e9 59 ef ff ff       	jmp    80105fe6 <alltraps>

8010708d <lgdt>:
{
8010708d:	55                   	push   %ebp
8010708e:	89 e5                	mov    %esp,%ebp
80107090:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107093:	8b 45 0c             	mov    0xc(%ebp),%eax
80107096:	83 e8 01             	sub    $0x1,%eax
80107099:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010709d:	8b 45 08             	mov    0x8(%ebp),%eax
801070a0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801070a4:	8b 45 08             	mov    0x8(%ebp),%eax
801070a7:	c1 e8 10             	shr    $0x10,%eax
801070aa:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801070ae:	8d 45 fa             	lea    -0x6(%ebp),%eax
801070b1:	0f 01 10             	lgdtl  (%eax)
}
801070b4:	90                   	nop
801070b5:	c9                   	leave  
801070b6:	c3                   	ret    

801070b7 <ltr>:
{
801070b7:	55                   	push   %ebp
801070b8:	89 e5                	mov    %esp,%ebp
801070ba:	83 ec 04             	sub    $0x4,%esp
801070bd:	8b 45 08             	mov    0x8(%ebp),%eax
801070c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801070c4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801070c8:	0f 00 d8             	ltr    %ax
}
801070cb:	90                   	nop
801070cc:	c9                   	leave  
801070cd:	c3                   	ret    

801070ce <lcr3>:

static inline void
lcr3(uint val)
{
801070ce:	55                   	push   %ebp
801070cf:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801070d1:	8b 45 08             	mov    0x8(%ebp),%eax
801070d4:	0f 22 d8             	mov    %eax,%cr3
}
801070d7:	90                   	nop
801070d8:	5d                   	pop    %ebp
801070d9:	c3                   	ret    

801070da <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801070da:	55                   	push   %ebp
801070db:	89 e5                	mov    %esp,%ebp
801070dd:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801070e0:	e8 b8 c8 ff ff       	call   8010399d <cpuid>
801070e5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801070eb:	05 80 6a 19 80       	add    $0x80196a80,%eax
801070f0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801070f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ff:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107108:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010710c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107113:	83 e2 f0             	and    $0xfffffff0,%edx
80107116:	83 ca 0a             	or     $0xa,%edx
80107119:	88 50 7d             	mov    %dl,0x7d(%eax)
8010711c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107123:	83 ca 10             	or     $0x10,%edx
80107126:	88 50 7d             	mov    %dl,0x7d(%eax)
80107129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107130:	83 e2 9f             	and    $0xffffff9f,%edx
80107133:	88 50 7d             	mov    %dl,0x7d(%eax)
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010713d:	83 ca 80             	or     $0xffffff80,%edx
80107140:	88 50 7d             	mov    %dl,0x7d(%eax)
80107143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107146:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010714a:	83 ca 0f             	or     $0xf,%edx
8010714d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107153:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107157:	83 e2 ef             	and    $0xffffffef,%edx
8010715a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010715d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107160:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107164:	83 e2 df             	and    $0xffffffdf,%edx
80107167:	88 50 7e             	mov    %dl,0x7e(%eax)
8010716a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107171:	83 ca 40             	or     $0x40,%edx
80107174:	88 50 7e             	mov    %dl,0x7e(%eax)
80107177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010717e:	83 ca 80             	or     $0xffffff80,%edx
80107181:	88 50 7e             	mov    %dl,0x7e(%eax)
80107184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107187:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010718b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107195:	ff ff 
80107197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801071a1:	00 00 
801071a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801071ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071b7:	83 e2 f0             	and    $0xfffffff0,%edx
801071ba:	83 ca 02             	or     $0x2,%edx
801071bd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071cd:	83 ca 10             	or     $0x10,%edx
801071d0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071e0:	83 e2 9f             	and    $0xffffff9f,%edx
801071e3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ec:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071f3:	83 ca 80             	or     $0xffffff80,%edx
801071f6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107206:	83 ca 0f             	or     $0xf,%edx
80107209:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107219:	83 e2 ef             	and    $0xffffffef,%edx
8010721c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010722c:	83 e2 df             	and    $0xffffffdf,%edx
8010722f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107238:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010723f:	83 ca 40             	or     $0x40,%edx
80107242:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107252:	83 ca 80             	or     $0xffffff80,%edx
80107255:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107268:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010726f:	ff ff 
80107271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107274:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010727b:	00 00 
8010727d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107280:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107291:	83 e2 f0             	and    $0xfffffff0,%edx
80107294:	83 ca 0a             	or     $0xa,%edx
80107297:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010729d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072a7:	83 ca 10             	or     $0x10,%edx
801072aa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072ba:	83 ca 60             	or     $0x60,%edx
801072bd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801072cd:	83 ca 80             	or     $0xffffff80,%edx
801072d0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801072d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072e0:	83 ca 0f             	or     $0xf,%edx
801072e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072f3:	83 e2 ef             	and    $0xffffffef,%edx
801072f6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107306:	83 e2 df             	and    $0xffffffdf,%edx
80107309:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010730f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107312:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107319:	83 ca 40             	or     $0x40,%edx
8010731c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107325:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010732c:	83 ca 80             	or     $0xffffff80,%edx
8010732f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107338:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010733f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107342:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107349:	ff ff 
8010734b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107355:	00 00 
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107364:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010736b:	83 e2 f0             	and    $0xfffffff0,%edx
8010736e:	83 ca 02             	or     $0x2,%edx
80107371:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107381:	83 ca 10             	or     $0x10,%edx
80107384:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010738a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107394:	83 ca 60             	or     $0x60,%edx
80107397:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010739d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801073a7:	83 ca 80             	or     $0xffffff80,%edx
801073aa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801073b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073ba:	83 ca 0f             	or     $0xf,%edx
801073bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073cd:	83 e2 ef             	and    $0xffffffef,%edx
801073d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073e0:	83 e2 df             	and    $0xffffffdf,%edx
801073e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073f3:	83 ca 40             	or     $0x40,%edx
801073f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107406:	83 ca 80             	or     $0xffffff80,%edx
80107409:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741c:	83 c0 70             	add    $0x70,%eax
8010741f:	83 ec 08             	sub    $0x8,%esp
80107422:	6a 30                	push   $0x30
80107424:	50                   	push   %eax
80107425:	e8 63 fc ff ff       	call   8010708d <lgdt>
8010742a:	83 c4 10             	add    $0x10,%esp
}
8010742d:	90                   	nop
8010742e:	c9                   	leave  
8010742f:	c3                   	ret    

80107430 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107430:	55                   	push   %ebp
80107431:	89 e5                	mov    %esp,%ebp
80107433:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107436:	8b 45 0c             	mov    0xc(%ebp),%eax
80107439:	c1 e8 16             	shr    $0x16,%eax
8010743c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107443:	8b 45 08             	mov    0x8(%ebp),%eax
80107446:	01 d0                	add    %edx,%eax
80107448:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010744b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010744e:	8b 00                	mov    (%eax),%eax
80107450:	83 e0 01             	and    $0x1,%eax
80107453:	85 c0                	test   %eax,%eax
80107455:	74 14                	je     8010746b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010745a:	8b 00                	mov    (%eax),%eax
8010745c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107461:	05 00 00 00 80       	add    $0x80000000,%eax
80107466:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107469:	eb 42                	jmp    801074ad <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010746b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010746f:	74 0e                	je     8010747f <walkpgdir+0x4f>
80107471:	e8 2a b3 ff ff       	call   801027a0 <kalloc>
80107476:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107479:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010747d:	75 07                	jne    80107486 <walkpgdir+0x56>
      return 0;
8010747f:	b8 00 00 00 00       	mov    $0x0,%eax
80107484:	eb 3e                	jmp    801074c4 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107486:	83 ec 04             	sub    $0x4,%esp
80107489:	68 00 10 00 00       	push   $0x1000
8010748e:	6a 00                	push   $0x0
80107490:	ff 75 f4             	push   -0xc(%ebp)
80107493:	e8 7b d7 ff ff       	call   80104c13 <memset>
80107498:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010749b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749e:	05 00 00 00 80       	add    $0x80000000,%eax
801074a3:	83 c8 07             	or     $0x7,%eax
801074a6:	89 c2                	mov    %eax,%edx
801074a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074ab:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801074ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801074b0:	c1 e8 0c             	shr    $0xc,%eax
801074b3:	25 ff 03 00 00       	and    $0x3ff,%eax
801074b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801074bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c2:	01 d0                	add    %edx,%eax
}
801074c4:	c9                   	leave  
801074c5:	c3                   	ret    

801074c6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801074c6:	55                   	push   %ebp
801074c7:	89 e5                	mov    %esp,%ebp
801074c9:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801074cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801074cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801074d7:	8b 55 0c             	mov    0xc(%ebp),%edx
801074da:	8b 45 10             	mov    0x10(%ebp),%eax
801074dd:	01 d0                	add    %edx,%eax
801074df:	83 e8 01             	sub    $0x1,%eax
801074e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801074ea:	83 ec 04             	sub    $0x4,%esp
801074ed:	6a 01                	push   $0x1
801074ef:	ff 75 f4             	push   -0xc(%ebp)
801074f2:	ff 75 08             	push   0x8(%ebp)
801074f5:	e8 36 ff ff ff       	call   80107430 <walkpgdir>
801074fa:	83 c4 10             	add    $0x10,%esp
801074fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107500:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107504:	75 07                	jne    8010750d <mappages+0x47>
      return -1;
80107506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010750b:	eb 47                	jmp    80107554 <mappages+0x8e>
    if(*pte & PTE_P)
8010750d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107510:	8b 00                	mov    (%eax),%eax
80107512:	83 e0 01             	and    $0x1,%eax
80107515:	85 c0                	test   %eax,%eax
80107517:	74 0d                	je     80107526 <mappages+0x60>
      panic("remap");
80107519:	83 ec 0c             	sub    $0xc,%esp
8010751c:	68 ec a7 10 80       	push   $0x8010a7ec
80107521:	e8 83 90 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107526:	8b 45 18             	mov    0x18(%ebp),%eax
80107529:	0b 45 14             	or     0x14(%ebp),%eax
8010752c:	83 c8 01             	or     $0x1,%eax
8010752f:	89 c2                	mov    %eax,%edx
80107531:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107534:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107539:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010753c:	74 10                	je     8010754e <mappages+0x88>
      break;
    a += PGSIZE;
8010753e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107545:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010754c:	eb 9c                	jmp    801074ea <mappages+0x24>
      break;
8010754e:	90                   	nop
  }
  return 0;
8010754f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107554:	c9                   	leave  
80107555:	c3                   	ret    

80107556 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107556:	55                   	push   %ebp
80107557:	89 e5                	mov    %esp,%ebp
80107559:	53                   	push   %ebx
8010755a:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010755d:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107564:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
8010756a:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010756f:	29 d0                	sub    %edx,%eax
80107571:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107574:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010757c:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
80107582:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107587:	01 d0                	add    %edx,%eax
80107589:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010758c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107596:	83 c0 30             	add    $0x30,%eax
80107599:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010759c:	89 10                	mov    %edx,(%eax)
8010759e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801075a1:	89 50 04             	mov    %edx,0x4(%eax)
801075a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801075a7:	89 50 08             	mov    %edx,0x8(%eax)
801075aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801075ad:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801075b0:	e8 eb b1 ff ff       	call   801027a0 <kalloc>
801075b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801075b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801075bc:	75 07                	jne    801075c5 <setupkvm+0x6f>
    return 0;
801075be:	b8 00 00 00 00       	mov    $0x0,%eax
801075c3:	eb 78                	jmp    8010763d <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
801075c5:	83 ec 04             	sub    $0x4,%esp
801075c8:	68 00 10 00 00       	push   $0x1000
801075cd:	6a 00                	push   $0x0
801075cf:	ff 75 f0             	push   -0x10(%ebp)
801075d2:	e8 3c d6 ff ff       	call   80104c13 <memset>
801075d7:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801075da:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801075e1:	eb 4e                	jmp    80107631 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801075e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ec:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	8b 58 08             	mov    0x8(%eax),%ebx
801075f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f8:	8b 40 04             	mov    0x4(%eax),%eax
801075fb:	29 c3                	sub    %eax,%ebx
801075fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107600:	8b 00                	mov    (%eax),%eax
80107602:	83 ec 0c             	sub    $0xc,%esp
80107605:	51                   	push   %ecx
80107606:	52                   	push   %edx
80107607:	53                   	push   %ebx
80107608:	50                   	push   %eax
80107609:	ff 75 f0             	push   -0x10(%ebp)
8010760c:	e8 b5 fe ff ff       	call   801074c6 <mappages>
80107611:	83 c4 20             	add    $0x20,%esp
80107614:	85 c0                	test   %eax,%eax
80107616:	79 15                	jns    8010762d <setupkvm+0xd7>
      freevm(pgdir);
80107618:	83 ec 0c             	sub    $0xc,%esp
8010761b:	ff 75 f0             	push   -0x10(%ebp)
8010761e:	e8 f5 04 00 00       	call   80107b18 <freevm>
80107623:	83 c4 10             	add    $0x10,%esp
      return 0;
80107626:	b8 00 00 00 00       	mov    $0x0,%eax
8010762b:	eb 10                	jmp    8010763d <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010762d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107631:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107638:	72 a9                	jb     801075e3 <setupkvm+0x8d>
    }
  return pgdir;
8010763a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010763d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107640:	c9                   	leave  
80107641:	c3                   	ret    

80107642 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107642:	55                   	push   %ebp
80107643:	89 e5                	mov    %esp,%ebp
80107645:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107648:	e8 09 ff ff ff       	call   80107556 <setupkvm>
8010764d:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
80107652:	e8 03 00 00 00       	call   8010765a <switchkvm>
}
80107657:	90                   	nop
80107658:	c9                   	leave  
80107659:	c3                   	ret    

8010765a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010765a:	55                   	push   %ebp
8010765b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010765d:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
80107662:	05 00 00 00 80       	add    $0x80000000,%eax
80107667:	50                   	push   %eax
80107668:	e8 61 fa ff ff       	call   801070ce <lcr3>
8010766d:	83 c4 04             	add    $0x4,%esp
}
80107670:	90                   	nop
80107671:	c9                   	leave  
80107672:	c3                   	ret    

80107673 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107673:	55                   	push   %ebp
80107674:	89 e5                	mov    %esp,%ebp
80107676:	56                   	push   %esi
80107677:	53                   	push   %ebx
80107678:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010767b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010767f:	75 0d                	jne    8010768e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107681:	83 ec 0c             	sub    $0xc,%esp
80107684:	68 f2 a7 10 80       	push   $0x8010a7f2
80107689:	e8 1b 8f ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010768e:	8b 45 08             	mov    0x8(%ebp),%eax
80107691:	8b 40 08             	mov    0x8(%eax),%eax
80107694:	85 c0                	test   %eax,%eax
80107696:	75 0d                	jne    801076a5 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107698:	83 ec 0c             	sub    $0xc,%esp
8010769b:	68 08 a8 10 80       	push   $0x8010a808
801076a0:	e8 04 8f ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
801076a5:	8b 45 08             	mov    0x8(%ebp),%eax
801076a8:	8b 40 04             	mov    0x4(%eax),%eax
801076ab:	85 c0                	test   %eax,%eax
801076ad:	75 0d                	jne    801076bc <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801076af:	83 ec 0c             	sub    $0xc,%esp
801076b2:	68 1d a8 10 80       	push   $0x8010a81d
801076b7:	e8 ed 8e ff ff       	call   801005a9 <panic>

  pushcli();
801076bc:	e8 47 d4 ff ff       	call   80104b08 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801076c1:	e8 f2 c2 ff ff       	call   801039b8 <mycpu>
801076c6:	89 c3                	mov    %eax,%ebx
801076c8:	e8 eb c2 ff ff       	call   801039b8 <mycpu>
801076cd:	83 c0 08             	add    $0x8,%eax
801076d0:	89 c6                	mov    %eax,%esi
801076d2:	e8 e1 c2 ff ff       	call   801039b8 <mycpu>
801076d7:	83 c0 08             	add    $0x8,%eax
801076da:	c1 e8 10             	shr    $0x10,%eax
801076dd:	88 45 f7             	mov    %al,-0x9(%ebp)
801076e0:	e8 d3 c2 ff ff       	call   801039b8 <mycpu>
801076e5:	83 c0 08             	add    $0x8,%eax
801076e8:	c1 e8 18             	shr    $0x18,%eax
801076eb:	89 c2                	mov    %eax,%edx
801076ed:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801076f4:	67 00 
801076f6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801076fd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107701:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107707:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010770e:	83 e0 f0             	and    $0xfffffff0,%eax
80107711:	83 c8 09             	or     $0x9,%eax
80107714:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010771a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107721:	83 c8 10             	or     $0x10,%eax
80107724:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010772a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107731:	83 e0 9f             	and    $0xffffff9f,%eax
80107734:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010773a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107741:	83 c8 80             	or     $0xffffff80,%eax
80107744:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010774a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107751:	83 e0 f0             	and    $0xfffffff0,%eax
80107754:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010775a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107761:	83 e0 ef             	and    $0xffffffef,%eax
80107764:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010776a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107771:	83 e0 df             	and    $0xffffffdf,%eax
80107774:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010777a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107781:	83 c8 40             	or     $0x40,%eax
80107784:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010778a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107791:	83 e0 7f             	and    $0x7f,%eax
80107794:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010779a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801077a0:	e8 13 c2 ff ff       	call   801039b8 <mycpu>
801077a5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801077ac:	83 e2 ef             	and    $0xffffffef,%edx
801077af:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801077b5:	e8 fe c1 ff ff       	call   801039b8 <mycpu>
801077ba:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801077c0:	8b 45 08             	mov    0x8(%ebp),%eax
801077c3:	8b 40 08             	mov    0x8(%eax),%eax
801077c6:	89 c3                	mov    %eax,%ebx
801077c8:	e8 eb c1 ff ff       	call   801039b8 <mycpu>
801077cd:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801077d3:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801077d6:	e8 dd c1 ff ff       	call   801039b8 <mycpu>
801077db:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801077e1:	83 ec 0c             	sub    $0xc,%esp
801077e4:	6a 28                	push   $0x28
801077e6:	e8 cc f8 ff ff       	call   801070b7 <ltr>
801077eb:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801077ee:	8b 45 08             	mov    0x8(%ebp),%eax
801077f1:	8b 40 04             	mov    0x4(%eax),%eax
801077f4:	05 00 00 00 80       	add    $0x80000000,%eax
801077f9:	83 ec 0c             	sub    $0xc,%esp
801077fc:	50                   	push   %eax
801077fd:	e8 cc f8 ff ff       	call   801070ce <lcr3>
80107802:	83 c4 10             	add    $0x10,%esp
  popcli();
80107805:	e8 4b d3 ff ff       	call   80104b55 <popcli>
}
8010780a:	90                   	nop
8010780b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010780e:	5b                   	pop    %ebx
8010780f:	5e                   	pop    %esi
80107810:	5d                   	pop    %ebp
80107811:	c3                   	ret    

80107812 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107812:	55                   	push   %ebp
80107813:	89 e5                	mov    %esp,%ebp
80107815:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107818:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010781f:	76 0d                	jbe    8010782e <inituvm+0x1c>
    panic("inituvm: more than a page");
80107821:	83 ec 0c             	sub    $0xc,%esp
80107824:	68 31 a8 10 80       	push   $0x8010a831
80107829:	e8 7b 8d ff ff       	call   801005a9 <panic>
  mem = kalloc();
8010782e:	e8 6d af ff ff       	call   801027a0 <kalloc>
80107833:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107836:	83 ec 04             	sub    $0x4,%esp
80107839:	68 00 10 00 00       	push   $0x1000
8010783e:	6a 00                	push   $0x0
80107840:	ff 75 f4             	push   -0xc(%ebp)
80107843:	e8 cb d3 ff ff       	call   80104c13 <memset>
80107848:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	05 00 00 00 80       	add    $0x80000000,%eax
80107853:	83 ec 0c             	sub    $0xc,%esp
80107856:	6a 06                	push   $0x6
80107858:	50                   	push   %eax
80107859:	68 00 10 00 00       	push   $0x1000
8010785e:	6a 00                	push   $0x0
80107860:	ff 75 08             	push   0x8(%ebp)
80107863:	e8 5e fc ff ff       	call   801074c6 <mappages>
80107868:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010786b:	83 ec 04             	sub    $0x4,%esp
8010786e:	ff 75 10             	push   0x10(%ebp)
80107871:	ff 75 0c             	push   0xc(%ebp)
80107874:	ff 75 f4             	push   -0xc(%ebp)
80107877:	e8 56 d4 ff ff       	call   80104cd2 <memmove>
8010787c:	83 c4 10             	add    $0x10,%esp
}
8010787f:	90                   	nop
80107880:	c9                   	leave  
80107881:	c3                   	ret    

80107882 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107882:	55                   	push   %ebp
80107883:	89 e5                	mov    %esp,%ebp
80107885:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010788b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107890:	85 c0                	test   %eax,%eax
80107892:	74 0d                	je     801078a1 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107894:	83 ec 0c             	sub    $0xc,%esp
80107897:	68 4c a8 10 80       	push   $0x8010a84c
8010789c:	e8 08 8d ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801078a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078a8:	e9 8f 00 00 00       	jmp    8010793c <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801078ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	01 d0                	add    %edx,%eax
801078b5:	83 ec 04             	sub    $0x4,%esp
801078b8:	6a 00                	push   $0x0
801078ba:	50                   	push   %eax
801078bb:	ff 75 08             	push   0x8(%ebp)
801078be:	e8 6d fb ff ff       	call   80107430 <walkpgdir>
801078c3:	83 c4 10             	add    $0x10,%esp
801078c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078cd:	75 0d                	jne    801078dc <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801078cf:	83 ec 0c             	sub    $0xc,%esp
801078d2:	68 6f a8 10 80       	push   $0x8010a86f
801078d7:	e8 cd 8c ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801078dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078df:	8b 00                	mov    (%eax),%eax
801078e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801078e9:	8b 45 18             	mov    0x18(%ebp),%eax
801078ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078ef:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801078f4:	77 0b                	ja     80107901 <loaduvm+0x7f>
      n = sz - i;
801078f6:	8b 45 18             	mov    0x18(%ebp),%eax
801078f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078ff:	eb 07                	jmp    80107908 <loaduvm+0x86>
    else
      n = PGSIZE;
80107901:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107908:	8b 55 14             	mov    0x14(%ebp),%edx
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	01 d0                	add    %edx,%eax
80107910:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107913:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107919:	ff 75 f0             	push   -0x10(%ebp)
8010791c:	50                   	push   %eax
8010791d:	52                   	push   %edx
8010791e:	ff 75 10             	push   0x10(%ebp)
80107921:	e8 b0 a5 ff ff       	call   80101ed6 <readi>
80107926:	83 c4 10             	add    $0x10,%esp
80107929:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010792c:	74 07                	je     80107935 <loaduvm+0xb3>
      return -1;
8010792e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107933:	eb 18                	jmp    8010794d <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107935:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010793c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793f:	3b 45 18             	cmp    0x18(%ebp),%eax
80107942:	0f 82 65 ff ff ff    	jb     801078ad <loaduvm+0x2b>
  }
  return 0;
80107948:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010794d:	c9                   	leave  
8010794e:	c3                   	ret    

8010794f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010794f:	55                   	push   %ebp
80107950:	89 e5                	mov    %esp,%ebp
80107952:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107955:	8b 45 10             	mov    0x10(%ebp),%eax
80107958:	85 c0                	test   %eax,%eax
8010795a:	79 0a                	jns    80107966 <allocuvm+0x17>
    return 0;
8010795c:	b8 00 00 00 00       	mov    $0x0,%eax
80107961:	e9 ec 00 00 00       	jmp    80107a52 <allocuvm+0x103>
  if(newsz < oldsz)
80107966:	8b 45 10             	mov    0x10(%ebp),%eax
80107969:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010796c:	73 08                	jae    80107976 <allocuvm+0x27>
    return oldsz;
8010796e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107971:	e9 dc 00 00 00       	jmp    80107a52 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107976:	8b 45 0c             	mov    0xc(%ebp),%eax
80107979:	05 ff 0f 00 00       	add    $0xfff,%eax
8010797e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107983:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107986:	e9 b8 00 00 00       	jmp    80107a43 <allocuvm+0xf4>
    mem = kalloc();
8010798b:	e8 10 ae ff ff       	call   801027a0 <kalloc>
80107990:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107993:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107997:	75 2e                	jne    801079c7 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107999:	83 ec 0c             	sub    $0xc,%esp
8010799c:	68 8d a8 10 80       	push   $0x8010a88d
801079a1:	e8 4e 8a ff ff       	call   801003f4 <cprintf>
801079a6:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801079a9:	83 ec 04             	sub    $0x4,%esp
801079ac:	ff 75 0c             	push   0xc(%ebp)
801079af:	ff 75 10             	push   0x10(%ebp)
801079b2:	ff 75 08             	push   0x8(%ebp)
801079b5:	e8 9a 00 00 00       	call   80107a54 <deallocuvm>
801079ba:	83 c4 10             	add    $0x10,%esp
      return 0;
801079bd:	b8 00 00 00 00       	mov    $0x0,%eax
801079c2:	e9 8b 00 00 00       	jmp    80107a52 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801079c7:	83 ec 04             	sub    $0x4,%esp
801079ca:	68 00 10 00 00       	push   $0x1000
801079cf:	6a 00                	push   $0x0
801079d1:	ff 75 f0             	push   -0x10(%ebp)
801079d4:	e8 3a d2 ff ff       	call   80104c13 <memset>
801079d9:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801079dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079df:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	83 ec 0c             	sub    $0xc,%esp
801079eb:	6a 06                	push   $0x6
801079ed:	52                   	push   %edx
801079ee:	68 00 10 00 00       	push   $0x1000
801079f3:	50                   	push   %eax
801079f4:	ff 75 08             	push   0x8(%ebp)
801079f7:	e8 ca fa ff ff       	call   801074c6 <mappages>
801079fc:	83 c4 20             	add    $0x20,%esp
801079ff:	85 c0                	test   %eax,%eax
80107a01:	79 39                	jns    80107a3c <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107a03:	83 ec 0c             	sub    $0xc,%esp
80107a06:	68 a5 a8 10 80       	push   $0x8010a8a5
80107a0b:	e8 e4 89 ff ff       	call   801003f4 <cprintf>
80107a10:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107a13:	83 ec 04             	sub    $0x4,%esp
80107a16:	ff 75 0c             	push   0xc(%ebp)
80107a19:	ff 75 10             	push   0x10(%ebp)
80107a1c:	ff 75 08             	push   0x8(%ebp)
80107a1f:	e8 30 00 00 00       	call   80107a54 <deallocuvm>
80107a24:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107a27:	83 ec 0c             	sub    $0xc,%esp
80107a2a:	ff 75 f0             	push   -0x10(%ebp)
80107a2d:	e8 d4 ac ff ff       	call   80102706 <kfree>
80107a32:	83 c4 10             	add    $0x10,%esp
      return 0;
80107a35:	b8 00 00 00 00       	mov    $0x0,%eax
80107a3a:	eb 16                	jmp    80107a52 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107a3c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	3b 45 10             	cmp    0x10(%ebp),%eax
80107a49:	0f 82 3c ff ff ff    	jb     8010798b <allocuvm+0x3c>
    }
  }
  return newsz;
80107a4f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a52:	c9                   	leave  
80107a53:	c3                   	ret    

80107a54 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a54:	55                   	push   %ebp
80107a55:	89 e5                	mov    %esp,%ebp
80107a57:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107a5a:	8b 45 10             	mov    0x10(%ebp),%eax
80107a5d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a60:	72 08                	jb     80107a6a <deallocuvm+0x16>
    return oldsz;
80107a62:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a65:	e9 ac 00 00 00       	jmp    80107b16 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107a6a:	8b 45 10             	mov    0x10(%ebp),%eax
80107a6d:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107a7a:	e9 88 00 00 00       	jmp    80107b07 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a82:	83 ec 04             	sub    $0x4,%esp
80107a85:	6a 00                	push   $0x0
80107a87:	50                   	push   %eax
80107a88:	ff 75 08             	push   0x8(%ebp)
80107a8b:	e8 a0 f9 ff ff       	call   80107430 <walkpgdir>
80107a90:	83 c4 10             	add    $0x10,%esp
80107a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107a96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a9a:	75 16                	jne    80107ab2 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9f:	c1 e8 16             	shr    $0x16,%eax
80107aa2:	83 c0 01             	add    $0x1,%eax
80107aa5:	c1 e0 16             	shl    $0x16,%eax
80107aa8:	2d 00 10 00 00       	sub    $0x1000,%eax
80107aad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ab0:	eb 4e                	jmp    80107b00 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab5:	8b 00                	mov    (%eax),%eax
80107ab7:	83 e0 01             	and    $0x1,%eax
80107aba:	85 c0                	test   %eax,%eax
80107abc:	74 42                	je     80107b00 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac1:	8b 00                	mov    (%eax),%eax
80107ac3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107acb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107acf:	75 0d                	jne    80107ade <deallocuvm+0x8a>
        panic("kfree");
80107ad1:	83 ec 0c             	sub    $0xc,%esp
80107ad4:	68 c1 a8 10 80       	push   $0x8010a8c1
80107ad9:	e8 cb 8a ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ae1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107ae9:	83 ec 0c             	sub    $0xc,%esp
80107aec:	ff 75 e8             	push   -0x18(%ebp)
80107aef:	e8 12 ac ff ff       	call   80102706 <kfree>
80107af4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107afa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107b00:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b0d:	0f 82 6c ff ff ff    	jb     80107a7f <deallocuvm+0x2b>
    }
  }
  return newsz;
80107b13:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b16:	c9                   	leave  
80107b17:	c3                   	ret    

80107b18 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107b18:	55                   	push   %ebp
80107b19:	89 e5                	mov    %esp,%ebp
80107b1b:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107b1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b22:	75 0d                	jne    80107b31 <freevm+0x19>
    panic("freevm: no pgdir");
80107b24:	83 ec 0c             	sub    $0xc,%esp
80107b27:	68 c7 a8 10 80       	push   $0x8010a8c7
80107b2c:	e8 78 8a ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107b31:	83 ec 04             	sub    $0x4,%esp
80107b34:	6a 00                	push   $0x0
80107b36:	68 00 00 00 80       	push   $0x80000000
80107b3b:	ff 75 08             	push   0x8(%ebp)
80107b3e:	e8 11 ff ff ff       	call   80107a54 <deallocuvm>
80107b43:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b4d:	eb 48                	jmp    80107b97 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b59:	8b 45 08             	mov    0x8(%ebp),%eax
80107b5c:	01 d0                	add    %edx,%eax
80107b5e:	8b 00                	mov    (%eax),%eax
80107b60:	83 e0 01             	and    $0x1,%eax
80107b63:	85 c0                	test   %eax,%eax
80107b65:	74 2c                	je     80107b93 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b71:	8b 45 08             	mov    0x8(%ebp),%eax
80107b74:	01 d0                	add    %edx,%eax
80107b76:	8b 00                	mov    (%eax),%eax
80107b78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b7d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107b85:	83 ec 0c             	sub    $0xc,%esp
80107b88:	ff 75 f0             	push   -0x10(%ebp)
80107b8b:	e8 76 ab ff ff       	call   80102706 <kfree>
80107b90:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b97:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107b9e:	76 af                	jbe    80107b4f <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107ba0:	83 ec 0c             	sub    $0xc,%esp
80107ba3:	ff 75 08             	push   0x8(%ebp)
80107ba6:	e8 5b ab ff ff       	call   80102706 <kfree>
80107bab:	83 c4 10             	add    $0x10,%esp
}
80107bae:	90                   	nop
80107baf:	c9                   	leave  
80107bb0:	c3                   	ret    

80107bb1 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107bb1:	55                   	push   %ebp
80107bb2:	89 e5                	mov    %esp,%ebp
80107bb4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107bb7:	83 ec 04             	sub    $0x4,%esp
80107bba:	6a 00                	push   $0x0
80107bbc:	ff 75 0c             	push   0xc(%ebp)
80107bbf:	ff 75 08             	push   0x8(%ebp)
80107bc2:	e8 69 f8 ff ff       	call   80107430 <walkpgdir>
80107bc7:	83 c4 10             	add    $0x10,%esp
80107bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107bcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bd1:	75 0d                	jne    80107be0 <clearpteu+0x2f>
    panic("clearpteu");
80107bd3:	83 ec 0c             	sub    $0xc,%esp
80107bd6:	68 d8 a8 10 80       	push   $0x8010a8d8
80107bdb:	e8 c9 89 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be3:	8b 00                	mov    (%eax),%eax
80107be5:	83 e0 fb             	and    $0xfffffffb,%eax
80107be8:	89 c2                	mov    %eax,%edx
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	89 10                	mov    %edx,(%eax)
}
80107bef:	90                   	nop
80107bf0:	c9                   	leave  
80107bf1:	c3                   	ret    

80107bf2 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107bf2:	55                   	push   %ebp
80107bf3:	89 e5                	mov    %esp,%ebp
80107bf5:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107bf8:	e8 59 f9 ff ff       	call   80107556 <setupkvm>
80107bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c04:	75 0a                	jne    80107c10 <copyuvm+0x1e>
    return 0;
80107c06:	b8 00 00 00 00       	mov    $0x0,%eax
80107c0b:	e9 eb 00 00 00       	jmp    80107cfb <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c17:	e9 b7 00 00 00       	jmp    80107cd3 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1f:	83 ec 04             	sub    $0x4,%esp
80107c22:	6a 00                	push   $0x0
80107c24:	50                   	push   %eax
80107c25:	ff 75 08             	push   0x8(%ebp)
80107c28:	e8 03 f8 ff ff       	call   80107430 <walkpgdir>
80107c2d:	83 c4 10             	add    $0x10,%esp
80107c30:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c37:	75 0d                	jne    80107c46 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107c39:	83 ec 0c             	sub    $0xc,%esp
80107c3c:	68 e2 a8 10 80       	push   $0x8010a8e2
80107c41:	e8 63 89 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c49:	8b 00                	mov    (%eax),%eax
80107c4b:	83 e0 01             	and    $0x1,%eax
80107c4e:	85 c0                	test   %eax,%eax
80107c50:	75 0d                	jne    80107c5f <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107c52:	83 ec 0c             	sub    $0xc,%esp
80107c55:	68 fc a8 10 80       	push   $0x8010a8fc
80107c5a:	e8 4a 89 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c62:	8b 00                	mov    (%eax),%eax
80107c64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c69:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c6f:	8b 00                	mov    (%eax),%eax
80107c71:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107c79:	e8 22 ab ff ff       	call   801027a0 <kalloc>
80107c7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107c85:	74 5d                	je     80107ce4 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c8a:	05 00 00 00 80       	add    $0x80000000,%eax
80107c8f:	83 ec 04             	sub    $0x4,%esp
80107c92:	68 00 10 00 00       	push   $0x1000
80107c97:	50                   	push   %eax
80107c98:	ff 75 e0             	push   -0x20(%ebp)
80107c9b:	e8 32 d0 ff ff       	call   80104cd2 <memmove>
80107ca0:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ca3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107ca6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107ca9:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb2:	83 ec 0c             	sub    $0xc,%esp
80107cb5:	52                   	push   %edx
80107cb6:	51                   	push   %ecx
80107cb7:	68 00 10 00 00       	push   $0x1000
80107cbc:	50                   	push   %eax
80107cbd:	ff 75 f0             	push   -0x10(%ebp)
80107cc0:	e8 01 f8 ff ff       	call   801074c6 <mappages>
80107cc5:	83 c4 20             	add    $0x20,%esp
80107cc8:	85 c0                	test   %eax,%eax
80107cca:	78 1b                	js     80107ce7 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107ccc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cd9:	0f 82 3d ff ff ff    	jb     80107c1c <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ce2:	eb 17                	jmp    80107cfb <copyuvm+0x109>
      goto bad;
80107ce4:	90                   	nop
80107ce5:	eb 01                	jmp    80107ce8 <copyuvm+0xf6>
      goto bad;
80107ce7:	90                   	nop

bad:
  freevm(d);
80107ce8:	83 ec 0c             	sub    $0xc,%esp
80107ceb:	ff 75 f0             	push   -0x10(%ebp)
80107cee:	e8 25 fe ff ff       	call   80107b18 <freevm>
80107cf3:	83 c4 10             	add    $0x10,%esp
  return 0;
80107cf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cfb:	c9                   	leave  
80107cfc:	c3                   	ret    

80107cfd <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107cfd:	55                   	push   %ebp
80107cfe:	89 e5                	mov    %esp,%ebp
80107d00:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107d03:	83 ec 04             	sub    $0x4,%esp
80107d06:	6a 00                	push   $0x0
80107d08:	ff 75 0c             	push   0xc(%ebp)
80107d0b:	ff 75 08             	push   0x8(%ebp)
80107d0e:	e8 1d f7 ff ff       	call   80107430 <walkpgdir>
80107d13:	83 c4 10             	add    $0x10,%esp
80107d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1c:	8b 00                	mov    (%eax),%eax
80107d1e:	83 e0 01             	and    $0x1,%eax
80107d21:	85 c0                	test   %eax,%eax
80107d23:	75 07                	jne    80107d2c <uva2ka+0x2f>
    return 0;
80107d25:	b8 00 00 00 00       	mov    $0x0,%eax
80107d2a:	eb 22                	jmp    80107d4e <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2f:	8b 00                	mov    (%eax),%eax
80107d31:	83 e0 04             	and    $0x4,%eax
80107d34:	85 c0                	test   %eax,%eax
80107d36:	75 07                	jne    80107d3f <uva2ka+0x42>
    return 0;
80107d38:	b8 00 00 00 00       	mov    $0x0,%eax
80107d3d:	eb 0f                	jmp    80107d4e <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	8b 00                	mov    (%eax),%eax
80107d44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d49:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107d4e:	c9                   	leave  
80107d4f:	c3                   	ret    

80107d50 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107d50:	55                   	push   %ebp
80107d51:	89 e5                	mov    %esp,%ebp
80107d53:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107d56:	8b 45 10             	mov    0x10(%ebp),%eax
80107d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107d5c:	eb 7f                	jmp    80107ddd <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d66:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107d69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d6c:	83 ec 08             	sub    $0x8,%esp
80107d6f:	50                   	push   %eax
80107d70:	ff 75 08             	push   0x8(%ebp)
80107d73:	e8 85 ff ff ff       	call   80107cfd <uva2ka>
80107d78:	83 c4 10             	add    $0x10,%esp
80107d7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107d7e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107d82:	75 07                	jne    80107d8b <copyout+0x3b>
      return -1;
80107d84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d89:	eb 61                	jmp    80107dec <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d8e:	2b 45 0c             	sub    0xc(%ebp),%eax
80107d91:	05 00 10 00 00       	add    $0x1000,%eax
80107d96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d9c:	3b 45 14             	cmp    0x14(%ebp),%eax
80107d9f:	76 06                	jbe    80107da7 <copyout+0x57>
      n = len;
80107da1:	8b 45 14             	mov    0x14(%ebp),%eax
80107da4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107da7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107daa:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107dad:	89 c2                	mov    %eax,%edx
80107daf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107db2:	01 d0                	add    %edx,%eax
80107db4:	83 ec 04             	sub    $0x4,%esp
80107db7:	ff 75 f0             	push   -0x10(%ebp)
80107dba:	ff 75 f4             	push   -0xc(%ebp)
80107dbd:	50                   	push   %eax
80107dbe:	e8 0f cf ff ff       	call   80104cd2 <memmove>
80107dc3:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dc9:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcf:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107dd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dd5:	05 00 10 00 00       	add    $0x1000,%eax
80107dda:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107ddd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107de1:	0f 85 77 ff ff ff    	jne    80107d5e <copyout+0xe>
  }
  return 0;
80107de7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dec:	c9                   	leave  
80107ded:	c3                   	ret    

80107dee <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107dee:	55                   	push   %ebp
80107def:	89 e5                	mov    %esp,%ebp
80107df1:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107df4:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107dfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107dfe:	8b 40 08             	mov    0x8(%eax),%eax
80107e01:	05 00 00 00 80       	add    $0x80000000,%eax
80107e06:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107e09:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e13:	8b 40 24             	mov    0x24(%eax),%eax
80107e16:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107e1b:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107e22:	00 00 00 

  while(i<madt->len){
80107e25:	90                   	nop
80107e26:	e9 bd 00 00 00       	jmp    80107ee8 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e31:	01 d0                	add    %edx,%eax
80107e33:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e39:	0f b6 00             	movzbl (%eax),%eax
80107e3c:	0f b6 c0             	movzbl %al,%eax
80107e3f:	83 f8 05             	cmp    $0x5,%eax
80107e42:	0f 87 a0 00 00 00    	ja     80107ee8 <mpinit_uefi+0xfa>
80107e48:	8b 04 85 18 a9 10 80 	mov    -0x7fef56e8(,%eax,4),%eax
80107e4f:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e54:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107e57:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107e5c:	83 f8 03             	cmp    $0x3,%eax
80107e5f:	7f 28                	jg     80107e89 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107e61:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e6a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107e6e:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107e74:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107e7a:	88 02                	mov    %al,(%edx)
          ncpu++;
80107e7c:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107e81:	83 c0 01             	add    $0x1,%eax
80107e84:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107e89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e8c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e90:	0f b6 c0             	movzbl %al,%eax
80107e93:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e96:	eb 50                	jmp    80107ee8 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ea1:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107ea5:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ead:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107eb1:	0f b6 c0             	movzbl %al,%eax
80107eb4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107eb7:	eb 2f                	jmp    80107ee8 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107ebf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ec2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ec6:	0f b6 c0             	movzbl %al,%eax
80107ec9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ecc:	eb 1a                	jmp    80107ee8 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ed7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107edb:	0f b6 c0             	movzbl %al,%eax
80107ede:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ee1:	eb 05                	jmp    80107ee8 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107ee3:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107ee7:	90                   	nop
  while(i<madt->len){
80107ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eeb:	8b 40 04             	mov    0x4(%eax),%eax
80107eee:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107ef1:	0f 82 34 ff ff ff    	jb     80107e2b <mpinit_uefi+0x3d>
    }
  }

}
80107ef7:	90                   	nop
80107ef8:	90                   	nop
80107ef9:	c9                   	leave  
80107efa:	c3                   	ret    

80107efb <inb>:
{
80107efb:	55                   	push   %ebp
80107efc:	89 e5                	mov    %esp,%ebp
80107efe:	83 ec 14             	sub    $0x14,%esp
80107f01:	8b 45 08             	mov    0x8(%ebp),%eax
80107f04:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107f08:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107f0c:	89 c2                	mov    %eax,%edx
80107f0e:	ec                   	in     (%dx),%al
80107f0f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107f12:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107f16:	c9                   	leave  
80107f17:	c3                   	ret    

80107f18 <outb>:
{
80107f18:	55                   	push   %ebp
80107f19:	89 e5                	mov    %esp,%ebp
80107f1b:	83 ec 08             	sub    $0x8,%esp
80107f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80107f21:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107f28:	89 d0                	mov    %edx,%eax
80107f2a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107f2d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107f31:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107f35:	ee                   	out    %al,(%dx)
}
80107f36:	90                   	nop
80107f37:	c9                   	leave  
80107f38:	c3                   	ret    

80107f39 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107f39:	55                   	push   %ebp
80107f3a:	89 e5                	mov    %esp,%ebp
80107f3c:	83 ec 28             	sub    $0x28,%esp
80107f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80107f42:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107f45:	6a 00                	push   $0x0
80107f47:	68 fa 03 00 00       	push   $0x3fa
80107f4c:	e8 c7 ff ff ff       	call   80107f18 <outb>
80107f51:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107f54:	68 80 00 00 00       	push   $0x80
80107f59:	68 fb 03 00 00       	push   $0x3fb
80107f5e:	e8 b5 ff ff ff       	call   80107f18 <outb>
80107f63:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107f66:	6a 0c                	push   $0xc
80107f68:	68 f8 03 00 00       	push   $0x3f8
80107f6d:	e8 a6 ff ff ff       	call   80107f18 <outb>
80107f72:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107f75:	6a 00                	push   $0x0
80107f77:	68 f9 03 00 00       	push   $0x3f9
80107f7c:	e8 97 ff ff ff       	call   80107f18 <outb>
80107f81:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107f84:	6a 03                	push   $0x3
80107f86:	68 fb 03 00 00       	push   $0x3fb
80107f8b:	e8 88 ff ff ff       	call   80107f18 <outb>
80107f90:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107f93:	6a 00                	push   $0x0
80107f95:	68 fc 03 00 00       	push   $0x3fc
80107f9a:	e8 79 ff ff ff       	call   80107f18 <outb>
80107f9f:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107fa2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fa9:	eb 11                	jmp    80107fbc <uart_debug+0x83>
80107fab:	83 ec 0c             	sub    $0xc,%esp
80107fae:	6a 0a                	push   $0xa
80107fb0:	e8 82 ab ff ff       	call   80102b37 <microdelay>
80107fb5:	83 c4 10             	add    $0x10,%esp
80107fb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fbc:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107fc0:	7f 1a                	jg     80107fdc <uart_debug+0xa3>
80107fc2:	83 ec 0c             	sub    $0xc,%esp
80107fc5:	68 fd 03 00 00       	push   $0x3fd
80107fca:	e8 2c ff ff ff       	call   80107efb <inb>
80107fcf:	83 c4 10             	add    $0x10,%esp
80107fd2:	0f b6 c0             	movzbl %al,%eax
80107fd5:	83 e0 20             	and    $0x20,%eax
80107fd8:	85 c0                	test   %eax,%eax
80107fda:	74 cf                	je     80107fab <uart_debug+0x72>
  outb(COM1+0, p);
80107fdc:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107fe0:	0f b6 c0             	movzbl %al,%eax
80107fe3:	83 ec 08             	sub    $0x8,%esp
80107fe6:	50                   	push   %eax
80107fe7:	68 f8 03 00 00       	push   $0x3f8
80107fec:	e8 27 ff ff ff       	call   80107f18 <outb>
80107ff1:	83 c4 10             	add    $0x10,%esp
}
80107ff4:	90                   	nop
80107ff5:	c9                   	leave  
80107ff6:	c3                   	ret    

80107ff7 <uart_debugs>:

void uart_debugs(char *p){
80107ff7:	55                   	push   %ebp
80107ff8:	89 e5                	mov    %esp,%ebp
80107ffa:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107ffd:	eb 1b                	jmp    8010801a <uart_debugs+0x23>
    uart_debug(*p++);
80107fff:	8b 45 08             	mov    0x8(%ebp),%eax
80108002:	8d 50 01             	lea    0x1(%eax),%edx
80108005:	89 55 08             	mov    %edx,0x8(%ebp)
80108008:	0f b6 00             	movzbl (%eax),%eax
8010800b:	0f be c0             	movsbl %al,%eax
8010800e:	83 ec 0c             	sub    $0xc,%esp
80108011:	50                   	push   %eax
80108012:	e8 22 ff ff ff       	call   80107f39 <uart_debug>
80108017:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010801a:	8b 45 08             	mov    0x8(%ebp),%eax
8010801d:	0f b6 00             	movzbl (%eax),%eax
80108020:	84 c0                	test   %al,%al
80108022:	75 db                	jne    80107fff <uart_debugs+0x8>
  }
}
80108024:	90                   	nop
80108025:	90                   	nop
80108026:	c9                   	leave  
80108027:	c3                   	ret    

80108028 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108028:	55                   	push   %ebp
80108029:	89 e5                	mov    %esp,%ebp
8010802b:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010802e:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108035:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108038:	8b 50 14             	mov    0x14(%eax),%edx
8010803b:	8b 40 10             	mov    0x10(%eax),%eax
8010803e:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108043:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108046:	8b 50 1c             	mov    0x1c(%eax),%edx
80108049:	8b 40 18             	mov    0x18(%eax),%eax
8010804c:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108051:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80108057:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010805c:	29 d0                	sub    %edx,%eax
8010805e:	a3 4c 6d 19 80       	mov    %eax,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108063:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108066:	8b 50 24             	mov    0x24(%eax),%edx
80108069:	8b 40 20             	mov    0x20(%eax),%eax
8010806c:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108071:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108074:	8b 50 2c             	mov    0x2c(%eax),%edx
80108077:	8b 40 28             	mov    0x28(%eax),%eax
8010807a:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010807f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108082:	8b 50 34             	mov    0x34(%eax),%edx
80108085:	8b 40 30             	mov    0x30(%eax),%eax
80108088:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
8010808d:	90                   	nop
8010808e:	c9                   	leave  
8010808f:	c3                   	ret    

80108090 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108090:	55                   	push   %ebp
80108091:	89 e5                	mov    %esp,%ebp
80108093:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108096:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
8010809c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010809f:	0f af d0             	imul   %eax,%edx
801080a2:	8b 45 08             	mov    0x8(%ebp),%eax
801080a5:	01 d0                	add    %edx,%eax
801080a7:	c1 e0 02             	shl    $0x2,%eax
801080aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801080ad:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
801080b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080b6:	01 d0                	add    %edx,%eax
801080b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801080bb:	8b 45 10             	mov    0x10(%ebp),%eax
801080be:	0f b6 10             	movzbl (%eax),%edx
801080c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080c4:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801080c6:	8b 45 10             	mov    0x10(%ebp),%eax
801080c9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801080cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080d0:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801080d3:	8b 45 10             	mov    0x10(%ebp),%eax
801080d6:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801080da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080dd:	88 50 02             	mov    %dl,0x2(%eax)
}
801080e0:	90                   	nop
801080e1:	c9                   	leave  
801080e2:	c3                   	ret    

801080e3 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801080e3:	55                   	push   %ebp
801080e4:	89 e5                	mov    %esp,%ebp
801080e6:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801080e9:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
801080ef:	8b 45 08             	mov    0x8(%ebp),%eax
801080f2:	0f af c2             	imul   %edx,%eax
801080f5:	c1 e0 02             	shl    $0x2,%eax
801080f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801080fb:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80108100:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108103:	29 d0                	sub    %edx,%eax
80108105:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
8010810b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010810e:	01 ca                	add    %ecx,%edx
80108110:	89 d1                	mov    %edx,%ecx
80108112:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80108118:	83 ec 04             	sub    $0x4,%esp
8010811b:	50                   	push   %eax
8010811c:	51                   	push   %ecx
8010811d:	52                   	push   %edx
8010811e:	e8 af cb ff ff       	call   80104cd2 <memmove>
80108123:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108129:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
8010812f:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80108135:	01 ca                	add    %ecx,%edx
80108137:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010813a:	29 ca                	sub    %ecx,%edx
8010813c:	83 ec 04             	sub    $0x4,%esp
8010813f:	50                   	push   %eax
80108140:	6a 00                	push   $0x0
80108142:	52                   	push   %edx
80108143:	e8 cb ca ff ff       	call   80104c13 <memset>
80108148:	83 c4 10             	add    $0x10,%esp
}
8010814b:	90                   	nop
8010814c:	c9                   	leave  
8010814d:	c3                   	ret    

8010814e <font_render>:
8010814e:	55                   	push   %ebp
8010814f:	89 e5                	mov    %esp,%ebp
80108151:	53                   	push   %ebx
80108152:	83 ec 14             	sub    $0x14,%esp
80108155:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010815c:	e9 b1 00 00 00       	jmp    80108212 <font_render+0xc4>
80108161:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108168:	e9 97 00 00 00       	jmp    80108204 <font_render+0xb6>
8010816d:	8b 45 10             	mov    0x10(%ebp),%eax
80108170:	83 e8 20             	sub    $0x20,%eax
80108173:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108179:	01 d0                	add    %edx,%eax
8010817b:	0f b7 84 00 40 a9 10 	movzwl -0x7fef56c0(%eax,%eax,1),%eax
80108182:	80 
80108183:	0f b7 d0             	movzwl %ax,%edx
80108186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108189:	bb 01 00 00 00       	mov    $0x1,%ebx
8010818e:	89 c1                	mov    %eax,%ecx
80108190:	d3 e3                	shl    %cl,%ebx
80108192:	89 d8                	mov    %ebx,%eax
80108194:	21 d0                	and    %edx,%eax
80108196:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010819c:	ba 01 00 00 00       	mov    $0x1,%edx
801081a1:	89 c1                	mov    %eax,%ecx
801081a3:	d3 e2                	shl    %cl,%edx
801081a5:	89 d0                	mov    %edx,%eax
801081a7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801081aa:	75 2b                	jne    801081d7 <font_render+0x89>
801081ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801081af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b2:	01 c2                	add    %eax,%edx
801081b4:	b8 0e 00 00 00       	mov    $0xe,%eax
801081b9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081bc:	89 c1                	mov    %eax,%ecx
801081be:	8b 45 08             	mov    0x8(%ebp),%eax
801081c1:	01 c8                	add    %ecx,%eax
801081c3:	83 ec 04             	sub    $0x4,%esp
801081c6:	68 e0 f4 10 80       	push   $0x8010f4e0
801081cb:	52                   	push   %edx
801081cc:	50                   	push   %eax
801081cd:	e8 be fe ff ff       	call   80108090 <graphic_draw_pixel>
801081d2:	83 c4 10             	add    $0x10,%esp
801081d5:	eb 29                	jmp    80108200 <font_render+0xb2>
801081d7:	8b 55 0c             	mov    0xc(%ebp),%edx
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	01 c2                	add    %eax,%edx
801081df:	b8 0e 00 00 00       	mov    $0xe,%eax
801081e4:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081e7:	89 c1                	mov    %eax,%ecx
801081e9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ec:	01 c8                	add    %ecx,%eax
801081ee:	83 ec 04             	sub    $0x4,%esp
801081f1:	68 60 6d 19 80       	push   $0x80196d60
801081f6:	52                   	push   %edx
801081f7:	50                   	push   %eax
801081f8:	e8 93 fe ff ff       	call   80108090 <graphic_draw_pixel>
801081fd:	83 c4 10             	add    $0x10,%esp
80108200:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108204:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108208:	0f 89 5f ff ff ff    	jns    8010816d <font_render+0x1f>
8010820e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108212:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108216:	0f 8e 45 ff ff ff    	jle    80108161 <font_render+0x13>
8010821c:	90                   	nop
8010821d:	90                   	nop
8010821e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108221:	c9                   	leave  
80108222:	c3                   	ret    

80108223 <font_render_string>:
80108223:	55                   	push   %ebp
80108224:	89 e5                	mov    %esp,%ebp
80108226:	53                   	push   %ebx
80108227:	83 ec 14             	sub    $0x14,%esp
8010822a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108231:	eb 33                	jmp    80108266 <font_render_string+0x43>
80108233:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108236:	8b 45 08             	mov    0x8(%ebp),%eax
80108239:	01 d0                	add    %edx,%eax
8010823b:	0f b6 00             	movzbl (%eax),%eax
8010823e:	0f be c8             	movsbl %al,%ecx
80108241:	8b 45 0c             	mov    0xc(%ebp),%eax
80108244:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108247:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010824a:	89 d8                	mov    %ebx,%eax
8010824c:	c1 e0 04             	shl    $0x4,%eax
8010824f:	29 d8                	sub    %ebx,%eax
80108251:	83 c0 02             	add    $0x2,%eax
80108254:	83 ec 04             	sub    $0x4,%esp
80108257:	51                   	push   %ecx
80108258:	52                   	push   %edx
80108259:	50                   	push   %eax
8010825a:	e8 ef fe ff ff       	call   8010814e <font_render>
8010825f:	83 c4 10             	add    $0x10,%esp
80108262:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108266:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108269:	8b 45 08             	mov    0x8(%ebp),%eax
8010826c:	01 d0                	add    %edx,%eax
8010826e:	0f b6 00             	movzbl (%eax),%eax
80108271:	84 c0                	test   %al,%al
80108273:	74 06                	je     8010827b <font_render_string+0x58>
80108275:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108279:	7e b8                	jle    80108233 <font_render_string+0x10>
8010827b:	90                   	nop
8010827c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010827f:	c9                   	leave  
80108280:	c3                   	ret    

80108281 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108281:	55                   	push   %ebp
80108282:	89 e5                	mov    %esp,%ebp
80108284:	53                   	push   %ebx
80108285:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108288:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010828f:	eb 6b                	jmp    801082fc <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108291:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108298:	eb 58                	jmp    801082f2 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010829a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801082a1:	eb 45                	jmp    801082e8 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801082a3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ac:	83 ec 0c             	sub    $0xc,%esp
801082af:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801082b2:	53                   	push   %ebx
801082b3:	6a 00                	push   $0x0
801082b5:	51                   	push   %ecx
801082b6:	52                   	push   %edx
801082b7:	50                   	push   %eax
801082b8:	e8 b0 00 00 00       	call   8010836d <pci_access_config>
801082bd:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801082c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082c3:	0f b7 c0             	movzwl %ax,%eax
801082c6:	3d ff ff 00 00       	cmp    $0xffff,%eax
801082cb:	74 17                	je     801082e4 <pci_init+0x63>
        pci_init_device(i,j,k);
801082cd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d6:	83 ec 04             	sub    $0x4,%esp
801082d9:	51                   	push   %ecx
801082da:	52                   	push   %edx
801082db:	50                   	push   %eax
801082dc:	e8 37 01 00 00       	call   80108418 <pci_init_device>
801082e1:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801082e4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801082e8:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801082ec:	7e b5                	jle    801082a3 <pci_init+0x22>
    for(int j=0;j<32;j++){
801082ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801082f2:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801082f6:	7e a2                	jle    8010829a <pci_init+0x19>
  for(int i=0;i<256;i++){
801082f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082fc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108303:	7e 8c                	jle    80108291 <pci_init+0x10>
      }
      }
    }
  }
}
80108305:	90                   	nop
80108306:	90                   	nop
80108307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010830a:	c9                   	leave  
8010830b:	c3                   	ret    

8010830c <pci_write_config>:

void pci_write_config(uint config){
8010830c:	55                   	push   %ebp
8010830d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010830f:	8b 45 08             	mov    0x8(%ebp),%eax
80108312:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108317:	89 c0                	mov    %eax,%eax
80108319:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010831a:	90                   	nop
8010831b:	5d                   	pop    %ebp
8010831c:	c3                   	ret    

8010831d <pci_write_data>:

void pci_write_data(uint config){
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108320:	8b 45 08             	mov    0x8(%ebp),%eax
80108323:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108328:	89 c0                	mov    %eax,%eax
8010832a:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010832b:	90                   	nop
8010832c:	5d                   	pop    %ebp
8010832d:	c3                   	ret    

8010832e <pci_read_config>:
uint pci_read_config(){
8010832e:	55                   	push   %ebp
8010832f:	89 e5                	mov    %esp,%ebp
80108331:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108334:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108339:	ed                   	in     (%dx),%eax
8010833a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010833d:	83 ec 0c             	sub    $0xc,%esp
80108340:	68 c8 00 00 00       	push   $0xc8
80108345:	e8 ed a7 ff ff       	call   80102b37 <microdelay>
8010834a:	83 c4 10             	add    $0x10,%esp
  return data;
8010834d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108350:	c9                   	leave  
80108351:	c3                   	ret    

80108352 <pci_test>:


void pci_test(){
80108352:	55                   	push   %ebp
80108353:	89 e5                	mov    %esp,%ebp
80108355:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108358:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010835f:	ff 75 fc             	push   -0x4(%ebp)
80108362:	e8 a5 ff ff ff       	call   8010830c <pci_write_config>
80108367:	83 c4 04             	add    $0x4,%esp
}
8010836a:	90                   	nop
8010836b:	c9                   	leave  
8010836c:	c3                   	ret    

8010836d <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010836d:	55                   	push   %ebp
8010836e:	89 e5                	mov    %esp,%ebp
80108370:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108373:	8b 45 08             	mov    0x8(%ebp),%eax
80108376:	c1 e0 10             	shl    $0x10,%eax
80108379:	25 00 00 ff 00       	and    $0xff0000,%eax
8010837e:	89 c2                	mov    %eax,%edx
80108380:	8b 45 0c             	mov    0xc(%ebp),%eax
80108383:	c1 e0 0b             	shl    $0xb,%eax
80108386:	0f b7 c0             	movzwl %ax,%eax
80108389:	09 c2                	or     %eax,%edx
8010838b:	8b 45 10             	mov    0x10(%ebp),%eax
8010838e:	c1 e0 08             	shl    $0x8,%eax
80108391:	25 00 07 00 00       	and    $0x700,%eax
80108396:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108398:	8b 45 14             	mov    0x14(%ebp),%eax
8010839b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083a0:	09 d0                	or     %edx,%eax
801083a2:	0d 00 00 00 80       	or     $0x80000000,%eax
801083a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801083aa:	ff 75 f4             	push   -0xc(%ebp)
801083ad:	e8 5a ff ff ff       	call   8010830c <pci_write_config>
801083b2:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801083b5:	e8 74 ff ff ff       	call   8010832e <pci_read_config>
801083ba:	8b 55 18             	mov    0x18(%ebp),%edx
801083bd:	89 02                	mov    %eax,(%edx)
}
801083bf:	90                   	nop
801083c0:	c9                   	leave  
801083c1:	c3                   	ret    

801083c2 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801083c2:	55                   	push   %ebp
801083c3:	89 e5                	mov    %esp,%ebp
801083c5:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083c8:	8b 45 08             	mov    0x8(%ebp),%eax
801083cb:	c1 e0 10             	shl    $0x10,%eax
801083ce:	25 00 00 ff 00       	and    $0xff0000,%eax
801083d3:	89 c2                	mov    %eax,%edx
801083d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d8:	c1 e0 0b             	shl    $0xb,%eax
801083db:	0f b7 c0             	movzwl %ax,%eax
801083de:	09 c2                	or     %eax,%edx
801083e0:	8b 45 10             	mov    0x10(%ebp),%eax
801083e3:	c1 e0 08             	shl    $0x8,%eax
801083e6:	25 00 07 00 00       	and    $0x700,%eax
801083eb:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083ed:	8b 45 14             	mov    0x14(%ebp),%eax
801083f0:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083f5:	09 d0                	or     %edx,%eax
801083f7:	0d 00 00 00 80       	or     $0x80000000,%eax
801083fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801083ff:	ff 75 fc             	push   -0x4(%ebp)
80108402:	e8 05 ff ff ff       	call   8010830c <pci_write_config>
80108407:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010840a:	ff 75 18             	push   0x18(%ebp)
8010840d:	e8 0b ff ff ff       	call   8010831d <pci_write_data>
80108412:	83 c4 04             	add    $0x4,%esp
}
80108415:	90                   	nop
80108416:	c9                   	leave  
80108417:	c3                   	ret    

80108418 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108418:	55                   	push   %ebp
80108419:	89 e5                	mov    %esp,%ebp
8010841b:	53                   	push   %ebx
8010841c:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010841f:	8b 45 08             	mov    0x8(%ebp),%eax
80108422:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
80108427:	8b 45 0c             	mov    0xc(%ebp),%eax
8010842a:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
8010842f:	8b 45 10             	mov    0x10(%ebp),%eax
80108432:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108437:	ff 75 10             	push   0x10(%ebp)
8010843a:	ff 75 0c             	push   0xc(%ebp)
8010843d:	ff 75 08             	push   0x8(%ebp)
80108440:	68 84 bf 10 80       	push   $0x8010bf84
80108445:	e8 aa 7f ff ff       	call   801003f4 <cprintf>
8010844a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010844d:	83 ec 0c             	sub    $0xc,%esp
80108450:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108453:	50                   	push   %eax
80108454:	6a 00                	push   $0x0
80108456:	ff 75 10             	push   0x10(%ebp)
80108459:	ff 75 0c             	push   0xc(%ebp)
8010845c:	ff 75 08             	push   0x8(%ebp)
8010845f:	e8 09 ff ff ff       	call   8010836d <pci_access_config>
80108464:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010846a:	c1 e8 10             	shr    $0x10,%eax
8010846d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108470:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108473:	25 ff ff 00 00       	and    $0xffff,%eax
80108478:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010847b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847e:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
80108483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108486:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010848b:	83 ec 04             	sub    $0x4,%esp
8010848e:	ff 75 f0             	push   -0x10(%ebp)
80108491:	ff 75 f4             	push   -0xc(%ebp)
80108494:	68 b8 bf 10 80       	push   $0x8010bfb8
80108499:	e8 56 7f ff ff       	call   801003f4 <cprintf>
8010849e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801084a1:	83 ec 0c             	sub    $0xc,%esp
801084a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084a7:	50                   	push   %eax
801084a8:	6a 08                	push   $0x8
801084aa:	ff 75 10             	push   0x10(%ebp)
801084ad:	ff 75 0c             	push   0xc(%ebp)
801084b0:	ff 75 08             	push   0x8(%ebp)
801084b3:	e8 b5 fe ff ff       	call   8010836d <pci_access_config>
801084b8:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084be:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c4:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084c7:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084cd:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084d0:	0f b6 c0             	movzbl %al,%eax
801084d3:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084d6:	c1 eb 18             	shr    $0x18,%ebx
801084d9:	83 ec 0c             	sub    $0xc,%esp
801084dc:	51                   	push   %ecx
801084dd:	52                   	push   %edx
801084de:	50                   	push   %eax
801084df:	53                   	push   %ebx
801084e0:	68 dc bf 10 80       	push   $0x8010bfdc
801084e5:	e8 0a 7f ff ff       	call   801003f4 <cprintf>
801084ea:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801084ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f0:	c1 e8 18             	shr    $0x18,%eax
801084f3:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
801084f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084fb:	c1 e8 10             	shr    $0x10,%eax
801084fe:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
80108503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108506:	c1 e8 08             	shr    $0x8,%eax
80108509:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
8010850e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108511:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108516:	83 ec 0c             	sub    $0xc,%esp
80108519:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010851c:	50                   	push   %eax
8010851d:	6a 10                	push   $0x10
8010851f:	ff 75 10             	push   0x10(%ebp)
80108522:	ff 75 0c             	push   0xc(%ebp)
80108525:	ff 75 08             	push   0x8(%ebp)
80108528:	e8 40 fe ff ff       	call   8010836d <pci_access_config>
8010852d:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108533:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108538:	83 ec 0c             	sub    $0xc,%esp
8010853b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010853e:	50                   	push   %eax
8010853f:	6a 14                	push   $0x14
80108541:	ff 75 10             	push   0x10(%ebp)
80108544:	ff 75 0c             	push   0xc(%ebp)
80108547:	ff 75 08             	push   0x8(%ebp)
8010854a:	e8 1e fe ff ff       	call   8010836d <pci_access_config>
8010854f:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108552:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108555:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010855a:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108561:	75 5a                	jne    801085bd <pci_init_device+0x1a5>
80108563:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010856a:	75 51                	jne    801085bd <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
8010856c:	83 ec 0c             	sub    $0xc,%esp
8010856f:	68 21 c0 10 80       	push   $0x8010c021
80108574:	e8 7b 7e ff ff       	call   801003f4 <cprintf>
80108579:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010857c:	83 ec 0c             	sub    $0xc,%esp
8010857f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108582:	50                   	push   %eax
80108583:	68 f0 00 00 00       	push   $0xf0
80108588:	ff 75 10             	push   0x10(%ebp)
8010858b:	ff 75 0c             	push   0xc(%ebp)
8010858e:	ff 75 08             	push   0x8(%ebp)
80108591:	e8 d7 fd ff ff       	call   8010836d <pci_access_config>
80108596:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108599:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010859c:	83 ec 08             	sub    $0x8,%esp
8010859f:	50                   	push   %eax
801085a0:	68 3b c0 10 80       	push   $0x8010c03b
801085a5:	e8 4a 7e ff ff       	call   801003f4 <cprintf>
801085aa:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801085ad:	83 ec 0c             	sub    $0xc,%esp
801085b0:	68 64 6d 19 80       	push   $0x80196d64
801085b5:	e8 09 00 00 00       	call   801085c3 <i8254_init>
801085ba:	83 c4 10             	add    $0x10,%esp
  }
}
801085bd:	90                   	nop
801085be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085c1:	c9                   	leave  
801085c2:	c3                   	ret    

801085c3 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801085c3:	55                   	push   %ebp
801085c4:	89 e5                	mov    %esp,%ebp
801085c6:	53                   	push   %ebx
801085c7:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801085ca:	8b 45 08             	mov    0x8(%ebp),%eax
801085cd:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801085d1:	0f b6 c8             	movzbl %al,%ecx
801085d4:	8b 45 08             	mov    0x8(%ebp),%eax
801085d7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085db:	0f b6 d0             	movzbl %al,%edx
801085de:	8b 45 08             	mov    0x8(%ebp),%eax
801085e1:	0f b6 00             	movzbl (%eax),%eax
801085e4:	0f b6 c0             	movzbl %al,%eax
801085e7:	83 ec 0c             	sub    $0xc,%esp
801085ea:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801085ed:	53                   	push   %ebx
801085ee:	6a 04                	push   $0x4
801085f0:	51                   	push   %ecx
801085f1:	52                   	push   %edx
801085f2:	50                   	push   %eax
801085f3:	e8 75 fd ff ff       	call   8010836d <pci_access_config>
801085f8:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801085fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085fe:	83 c8 04             	or     $0x4,%eax
80108601:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108604:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108607:	8b 45 08             	mov    0x8(%ebp),%eax
8010860a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010860e:	0f b6 c8             	movzbl %al,%ecx
80108611:	8b 45 08             	mov    0x8(%ebp),%eax
80108614:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108618:	0f b6 d0             	movzbl %al,%edx
8010861b:	8b 45 08             	mov    0x8(%ebp),%eax
8010861e:	0f b6 00             	movzbl (%eax),%eax
80108621:	0f b6 c0             	movzbl %al,%eax
80108624:	83 ec 0c             	sub    $0xc,%esp
80108627:	53                   	push   %ebx
80108628:	6a 04                	push   $0x4
8010862a:	51                   	push   %ecx
8010862b:	52                   	push   %edx
8010862c:	50                   	push   %eax
8010862d:	e8 90 fd ff ff       	call   801083c2 <pci_write_config_register>
80108632:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108635:	8b 45 08             	mov    0x8(%ebp),%eax
80108638:	8b 40 10             	mov    0x10(%eax),%eax
8010863b:	05 00 00 00 40       	add    $0x40000000,%eax
80108640:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
80108645:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010864a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010864d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108652:	05 d8 00 00 00       	add    $0xd8,%eax
80108657:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010865a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010865d:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108666:	8b 00                	mov    (%eax),%eax
80108668:	0d 00 00 00 04       	or     $0x4000000,%eax
8010866d:	89 c2                	mov    %eax,%edx
8010866f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108672:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108677:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010867d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108680:	8b 00                	mov    (%eax),%eax
80108682:	83 c8 40             	or     $0x40,%eax
80108685:	89 c2                	mov    %eax,%edx
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	8b 10                	mov    (%eax),%edx
80108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108694:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108696:	83 ec 0c             	sub    $0xc,%esp
80108699:	68 50 c0 10 80       	push   $0x8010c050
8010869e:	e8 51 7d ff ff       	call   801003f4 <cprintf>
801086a3:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801086a6:	e8 f5 a0 ff ff       	call   801027a0 <kalloc>
801086ab:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
801086b0:	a1 88 6d 19 80       	mov    0x80196d88,%eax
801086b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801086bb:	a1 88 6d 19 80       	mov    0x80196d88,%eax
801086c0:	83 ec 08             	sub    $0x8,%esp
801086c3:	50                   	push   %eax
801086c4:	68 72 c0 10 80       	push   $0x8010c072
801086c9:	e8 26 7d ff ff       	call   801003f4 <cprintf>
801086ce:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801086d1:	e8 50 00 00 00       	call   80108726 <i8254_init_recv>
  i8254_init_send();
801086d6:	e8 69 03 00 00       	call   80108a44 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801086db:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086e2:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801086e5:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086ec:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801086ef:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086f6:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801086f9:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108700:	0f b6 c0             	movzbl %al,%eax
80108703:	83 ec 0c             	sub    $0xc,%esp
80108706:	53                   	push   %ebx
80108707:	51                   	push   %ecx
80108708:	52                   	push   %edx
80108709:	50                   	push   %eax
8010870a:	68 80 c0 10 80       	push   $0x8010c080
8010870f:	e8 e0 7c ff ff       	call   801003f4 <cprintf>
80108714:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108720:	90                   	nop
80108721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108724:	c9                   	leave  
80108725:	c3                   	ret    

80108726 <i8254_init_recv>:

void i8254_init_recv(){
80108726:	55                   	push   %ebp
80108727:	89 e5                	mov    %esp,%ebp
80108729:	57                   	push   %edi
8010872a:	56                   	push   %esi
8010872b:	53                   	push   %ebx
8010872c:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010872f:	83 ec 0c             	sub    $0xc,%esp
80108732:	6a 00                	push   $0x0
80108734:	e8 e8 04 00 00       	call   80108c21 <i8254_read_eeprom>
80108739:	83 c4 10             	add    $0x10,%esp
8010873c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
8010873f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108742:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
80108747:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010874a:	c1 e8 08             	shr    $0x8,%eax
8010874d:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
80108752:	83 ec 0c             	sub    $0xc,%esp
80108755:	6a 01                	push   $0x1
80108757:	e8 c5 04 00 00       	call   80108c21 <i8254_read_eeprom>
8010875c:	83 c4 10             	add    $0x10,%esp
8010875f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108762:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108765:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
8010876a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010876d:	c1 e8 08             	shr    $0x8,%eax
80108770:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
80108775:	83 ec 0c             	sub    $0xc,%esp
80108778:	6a 02                	push   $0x2
8010877a:	e8 a2 04 00 00       	call   80108c21 <i8254_read_eeprom>
8010877f:	83 c4 10             	add    $0x10,%esp
80108782:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108785:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108788:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
8010878d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108790:	c1 e8 08             	shr    $0x8,%eax
80108793:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108798:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010879f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801087a2:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087a9:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801087ac:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087b3:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801087b6:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087bd:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801087c0:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087c7:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801087ca:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087d1:	0f b6 c0             	movzbl %al,%eax
801087d4:	83 ec 04             	sub    $0x4,%esp
801087d7:	57                   	push   %edi
801087d8:	56                   	push   %esi
801087d9:	53                   	push   %ebx
801087da:	51                   	push   %ecx
801087db:	52                   	push   %edx
801087dc:	50                   	push   %eax
801087dd:	68 98 c0 10 80       	push   $0x8010c098
801087e2:	e8 0d 7c ff ff       	call   801003f4 <cprintf>
801087e7:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801087ea:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087ef:	05 00 54 00 00       	add    $0x5400,%eax
801087f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801087f7:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087fc:	05 04 54 00 00       	add    $0x5404,%eax
80108801:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108804:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108807:	c1 e0 10             	shl    $0x10,%eax
8010880a:	0b 45 d8             	or     -0x28(%ebp),%eax
8010880d:	89 c2                	mov    %eax,%edx
8010880f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108812:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108814:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108817:	0d 00 00 00 80       	or     $0x80000000,%eax
8010881c:	89 c2                	mov    %eax,%edx
8010881e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108821:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108823:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108828:	05 00 52 00 00       	add    $0x5200,%eax
8010882d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108830:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108837:	eb 19                	jmp    80108852 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010883c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108843:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108846:	01 d0                	add    %edx,%eax
80108848:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010884e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108852:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108856:	7e e1                	jle    80108839 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108858:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010885d:	05 d0 00 00 00       	add    $0xd0,%eax
80108862:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108865:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108868:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010886e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108873:	05 c8 00 00 00       	add    $0xc8,%eax
80108878:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010887b:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010887e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108884:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108889:	05 28 28 00 00       	add    $0x2828,%eax
8010888e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108891:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108894:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010889a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010889f:	05 00 01 00 00       	add    $0x100,%eax
801088a4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801088a7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088aa:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801088b0:	e8 eb 9e ff ff       	call   801027a0 <kalloc>
801088b5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801088b8:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088bd:	05 00 28 00 00       	add    $0x2800,%eax
801088c2:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801088c5:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088ca:	05 04 28 00 00       	add    $0x2804,%eax
801088cf:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801088d2:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088d7:	05 08 28 00 00       	add    $0x2808,%eax
801088dc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801088df:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088e4:	05 10 28 00 00       	add    $0x2810,%eax
801088e9:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801088ec:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088f1:	05 18 28 00 00       	add    $0x2818,%eax
801088f6:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801088f9:	8b 45 b0             	mov    -0x50(%ebp),%eax
801088fc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108902:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108905:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108907:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010890a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108910:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108913:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108919:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010891c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108922:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108925:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
8010892b:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010892e:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108931:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108938:	eb 73                	jmp    801089ad <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
8010893a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010893d:	c1 e0 04             	shl    $0x4,%eax
80108940:	89 c2                	mov    %eax,%edx
80108942:	8b 45 98             	mov    -0x68(%ebp),%eax
80108945:	01 d0                	add    %edx,%eax
80108947:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010894e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108951:	c1 e0 04             	shl    $0x4,%eax
80108954:	89 c2                	mov    %eax,%edx
80108956:	8b 45 98             	mov    -0x68(%ebp),%eax
80108959:	01 d0                	add    %edx,%eax
8010895b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108961:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108964:	c1 e0 04             	shl    $0x4,%eax
80108967:	89 c2                	mov    %eax,%edx
80108969:	8b 45 98             	mov    -0x68(%ebp),%eax
8010896c:	01 d0                	add    %edx,%eax
8010896e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108974:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108977:	c1 e0 04             	shl    $0x4,%eax
8010897a:	89 c2                	mov    %eax,%edx
8010897c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010897f:	01 d0                	add    %edx,%eax
80108981:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108985:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108988:	c1 e0 04             	shl    $0x4,%eax
8010898b:	89 c2                	mov    %eax,%edx
8010898d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108990:	01 d0                	add    %edx,%eax
80108992:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108996:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108999:	c1 e0 04             	shl    $0x4,%eax
8010899c:	89 c2                	mov    %eax,%edx
8010899e:	8b 45 98             	mov    -0x68(%ebp),%eax
801089a1:	01 d0                	add    %edx,%eax
801089a3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801089a9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801089ad:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801089b4:	7e 84                	jle    8010893a <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801089b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801089bd:	eb 57                	jmp    80108a16 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
801089bf:	e8 dc 9d ff ff       	call   801027a0 <kalloc>
801089c4:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801089c7:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801089cb:	75 12                	jne    801089df <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
801089cd:	83 ec 0c             	sub    $0xc,%esp
801089d0:	68 b8 c0 10 80       	push   $0x8010c0b8
801089d5:	e8 1a 7a ff ff       	call   801003f4 <cprintf>
801089da:	83 c4 10             	add    $0x10,%esp
      break;
801089dd:	eb 3d                	jmp    80108a1c <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801089df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089e2:	c1 e0 04             	shl    $0x4,%eax
801089e5:	89 c2                	mov    %eax,%edx
801089e7:	8b 45 98             	mov    -0x68(%ebp),%eax
801089ea:	01 d0                	add    %edx,%eax
801089ec:	8b 55 94             	mov    -0x6c(%ebp),%edx
801089ef:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801089f5:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801089f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089fa:	83 c0 01             	add    $0x1,%eax
801089fd:	c1 e0 04             	shl    $0x4,%eax
80108a00:	89 c2                	mov    %eax,%edx
80108a02:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a05:	01 d0                	add    %edx,%eax
80108a07:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a0a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a10:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a12:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108a16:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108a1a:	7e a3                	jle    801089bf <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108a1c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a1f:	8b 00                	mov    (%eax),%eax
80108a21:	83 c8 02             	or     $0x2,%eax
80108a24:	89 c2                	mov    %eax,%edx
80108a26:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a29:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108a2b:	83 ec 0c             	sub    $0xc,%esp
80108a2e:	68 d8 c0 10 80       	push   $0x8010c0d8
80108a33:	e8 bc 79 ff ff       	call   801003f4 <cprintf>
80108a38:	83 c4 10             	add    $0x10,%esp
}
80108a3b:	90                   	nop
80108a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108a3f:	5b                   	pop    %ebx
80108a40:	5e                   	pop    %esi
80108a41:	5f                   	pop    %edi
80108a42:	5d                   	pop    %ebp
80108a43:	c3                   	ret    

80108a44 <i8254_init_send>:

void i8254_init_send(){
80108a44:	55                   	push   %ebp
80108a45:	89 e5                	mov    %esp,%ebp
80108a47:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108a4a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a4f:	05 28 38 00 00       	add    $0x3828,%eax
80108a54:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a5a:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108a60:	e8 3b 9d ff ff       	call   801027a0 <kalloc>
80108a65:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108a68:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a6d:	05 00 38 00 00       	add    $0x3800,%eax
80108a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108a75:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a7a:	05 04 38 00 00       	add    $0x3804,%eax
80108a7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108a82:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a87:	05 08 38 00 00       	add    $0x3808,%eax
80108a8c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108a8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a92:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a9b:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108a9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aa0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108aa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108aa9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108aaf:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ab4:	05 10 38 00 00       	add    $0x3810,%eax
80108ab9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108abc:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ac1:	05 18 38 00 00       	add    $0x3818,%eax
80108ac6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108ac9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108acc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ad2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ad5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ade:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ae8:	e9 82 00 00 00       	jmp    80108b6f <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af0:	c1 e0 04             	shl    $0x4,%eax
80108af3:	89 c2                	mov    %eax,%edx
80108af5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108af8:	01 d0                	add    %edx,%eax
80108afa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b04:	c1 e0 04             	shl    $0x4,%eax
80108b07:	89 c2                	mov    %eax,%edx
80108b09:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b0c:	01 d0                	add    %edx,%eax
80108b0e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b17:	c1 e0 04             	shl    $0x4,%eax
80108b1a:	89 c2                	mov    %eax,%edx
80108b1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b1f:	01 d0                	add    %edx,%eax
80108b21:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b28:	c1 e0 04             	shl    $0x4,%eax
80108b2b:	89 c2                	mov    %eax,%edx
80108b2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b30:	01 d0                	add    %edx,%eax
80108b32:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b39:	c1 e0 04             	shl    $0x4,%eax
80108b3c:	89 c2                	mov    %eax,%edx
80108b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b41:	01 d0                	add    %edx,%eax
80108b43:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4a:	c1 e0 04             	shl    $0x4,%eax
80108b4d:	89 c2                	mov    %eax,%edx
80108b4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b52:	01 d0                	add    %edx,%eax
80108b54:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5b:	c1 e0 04             	shl    $0x4,%eax
80108b5e:	89 c2                	mov    %eax,%edx
80108b60:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b63:	01 d0                	add    %edx,%eax
80108b65:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b6f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108b76:	0f 8e 71 ff ff ff    	jle    80108aed <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108b7c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b83:	eb 57                	jmp    80108bdc <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108b85:	e8 16 9c ff ff       	call   801027a0 <kalloc>
80108b8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108b8d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108b91:	75 12                	jne    80108ba5 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108b93:	83 ec 0c             	sub    $0xc,%esp
80108b96:	68 b8 c0 10 80       	push   $0x8010c0b8
80108b9b:	e8 54 78 ff ff       	call   801003f4 <cprintf>
80108ba0:	83 c4 10             	add    $0x10,%esp
      break;
80108ba3:	eb 3d                	jmp    80108be2 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba8:	c1 e0 04             	shl    $0x4,%eax
80108bab:	89 c2                	mov    %eax,%edx
80108bad:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bb0:	01 d0                	add    %edx,%eax
80108bb2:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108bb5:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108bbb:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc0:	83 c0 01             	add    $0x1,%eax
80108bc3:	c1 e0 04             	shl    $0x4,%eax
80108bc6:	89 c2                	mov    %eax,%edx
80108bc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bcb:	01 d0                	add    %edx,%eax
80108bcd:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108bd0:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108bd6:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108bd8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108bdc:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108be0:	7e a3                	jle    80108b85 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108be2:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108be7:	05 00 04 00 00       	add    $0x400,%eax
80108bec:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108bef:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108bf2:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108bf8:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108bfd:	05 10 04 00 00       	add    $0x410,%eax
80108c02:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108c05:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c08:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108c0e:	83 ec 0c             	sub    $0xc,%esp
80108c11:	68 f8 c0 10 80       	push   $0x8010c0f8
80108c16:	e8 d9 77 ff ff       	call   801003f4 <cprintf>
80108c1b:	83 c4 10             	add    $0x10,%esp

}
80108c1e:	90                   	nop
80108c1f:	c9                   	leave  
80108c20:	c3                   	ret    

80108c21 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108c21:	55                   	push   %ebp
80108c22:	89 e5                	mov    %esp,%ebp
80108c24:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108c27:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c2c:	83 c0 14             	add    $0x14,%eax
80108c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108c32:	8b 45 08             	mov    0x8(%ebp),%eax
80108c35:	c1 e0 08             	shl    $0x8,%eax
80108c38:	0f b7 c0             	movzwl %ax,%eax
80108c3b:	83 c8 01             	or     $0x1,%eax
80108c3e:	89 c2                	mov    %eax,%edx
80108c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c43:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108c45:	83 ec 0c             	sub    $0xc,%esp
80108c48:	68 18 c1 10 80       	push   $0x8010c118
80108c4d:	e8 a2 77 ff ff       	call   801003f4 <cprintf>
80108c52:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c58:	8b 00                	mov    (%eax),%eax
80108c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c60:	83 e0 10             	and    $0x10,%eax
80108c63:	85 c0                	test   %eax,%eax
80108c65:	75 02                	jne    80108c69 <i8254_read_eeprom+0x48>
  while(1){
80108c67:	eb dc                	jmp    80108c45 <i8254_read_eeprom+0x24>
      break;
80108c69:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6d:	8b 00                	mov    (%eax),%eax
80108c6f:	c1 e8 10             	shr    $0x10,%eax
}
80108c72:	c9                   	leave  
80108c73:	c3                   	ret    

80108c74 <i8254_recv>:
void i8254_recv(){
80108c74:	55                   	push   %ebp
80108c75:	89 e5                	mov    %esp,%ebp
80108c77:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c7a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c7f:	05 10 28 00 00       	add    $0x2810,%eax
80108c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c87:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c8c:	05 18 28 00 00       	add    $0x2818,%eax
80108c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108c94:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c99:	05 00 28 00 00       	add    $0x2800,%eax
80108c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca4:	8b 00                	mov    (%eax),%eax
80108ca6:	05 00 00 00 80       	add    $0x80000000,%eax
80108cab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb1:	8b 10                	mov    (%eax),%edx
80108cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb6:	8b 08                	mov    (%eax),%ecx
80108cb8:	89 d0                	mov    %edx,%eax
80108cba:	29 c8                	sub    %ecx,%eax
80108cbc:	25 ff 00 00 00       	and    $0xff,%eax
80108cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108cc4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108cc8:	7e 37                	jle    80108d01 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccd:	8b 00                	mov    (%eax),%eax
80108ccf:	c1 e0 04             	shl    $0x4,%eax
80108cd2:	89 c2                	mov    %eax,%edx
80108cd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cd7:	01 d0                	add    %edx,%eax
80108cd9:	8b 00                	mov    (%eax),%eax
80108cdb:	05 00 00 00 80       	add    $0x80000000,%eax
80108ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce6:	8b 00                	mov    (%eax),%eax
80108ce8:	83 c0 01             	add    $0x1,%eax
80108ceb:	0f b6 d0             	movzbl %al,%edx
80108cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf1:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108cf3:	83 ec 0c             	sub    $0xc,%esp
80108cf6:	ff 75 e0             	push   -0x20(%ebp)
80108cf9:	e8 15 09 00 00       	call   80109613 <eth_proc>
80108cfe:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d04:	8b 10                	mov    (%eax),%edx
80108d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d09:	8b 00                	mov    (%eax),%eax
80108d0b:	39 c2                	cmp    %eax,%edx
80108d0d:	75 9f                	jne    80108cae <i8254_recv+0x3a>
      (*rdt)--;
80108d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d12:	8b 00                	mov    (%eax),%eax
80108d14:	8d 50 ff             	lea    -0x1(%eax),%edx
80108d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d1a:	89 10                	mov    %edx,(%eax)
  while(1){
80108d1c:	eb 90                	jmp    80108cae <i8254_recv+0x3a>

80108d1e <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108d1e:	55                   	push   %ebp
80108d1f:	89 e5                	mov    %esp,%ebp
80108d21:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d24:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d29:	05 10 38 00 00       	add    $0x3810,%eax
80108d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d31:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d36:	05 18 38 00 00       	add    $0x3818,%eax
80108d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d3e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d43:	05 00 38 00 00       	add    $0x3800,%eax
80108d48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108d4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d4e:	8b 00                	mov    (%eax),%eax
80108d50:	05 00 00 00 80       	add    $0x80000000,%eax
80108d55:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d5b:	8b 10                	mov    (%eax),%edx
80108d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d60:	8b 08                	mov    (%eax),%ecx
80108d62:	89 d0                	mov    %edx,%eax
80108d64:	29 c8                	sub    %ecx,%eax
80108d66:	0f b6 d0             	movzbl %al,%edx
80108d69:	b8 00 01 00 00       	mov    $0x100,%eax
80108d6e:	29 d0                	sub    %edx,%eax
80108d70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d76:	8b 00                	mov    (%eax),%eax
80108d78:	25 ff 00 00 00       	and    $0xff,%eax
80108d7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108d80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d84:	0f 8e a8 00 00 00    	jle    80108e32 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108d90:	89 d1                	mov    %edx,%ecx
80108d92:	c1 e1 04             	shl    $0x4,%ecx
80108d95:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108d98:	01 ca                	add    %ecx,%edx
80108d9a:	8b 12                	mov    (%edx),%edx
80108d9c:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108da2:	83 ec 04             	sub    $0x4,%esp
80108da5:	ff 75 0c             	push   0xc(%ebp)
80108da8:	50                   	push   %eax
80108da9:	52                   	push   %edx
80108daa:	e8 23 bf ff ff       	call   80104cd2 <memmove>
80108daf:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db5:	c1 e0 04             	shl    $0x4,%eax
80108db8:	89 c2                	mov    %eax,%edx
80108dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dbd:	01 d0                	add    %edx,%eax
80108dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dc2:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dc9:	c1 e0 04             	shl    $0x4,%eax
80108dcc:	89 c2                	mov    %eax,%edx
80108dce:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dd1:	01 d0                	add    %edx,%eax
80108dd3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dda:	c1 e0 04             	shl    $0x4,%eax
80108ddd:	89 c2                	mov    %eax,%edx
80108ddf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de2:	01 d0                	add    %edx,%eax
80108de4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108deb:	c1 e0 04             	shl    $0x4,%eax
80108dee:	89 c2                	mov    %eax,%edx
80108df0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108df3:	01 d0                	add    %edx,%eax
80108df5:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dfc:	c1 e0 04             	shl    $0x4,%eax
80108dff:	89 c2                	mov    %eax,%edx
80108e01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e04:	01 d0                	add    %edx,%eax
80108e06:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e0f:	c1 e0 04             	shl    $0x4,%eax
80108e12:	89 c2                	mov    %eax,%edx
80108e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e17:	01 d0                	add    %edx,%eax
80108e19:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e20:	8b 00                	mov    (%eax),%eax
80108e22:	83 c0 01             	add    $0x1,%eax
80108e25:	0f b6 d0             	movzbl %al,%edx
80108e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e2b:	89 10                	mov    %edx,(%eax)
    return len;
80108e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e30:	eb 05                	jmp    80108e37 <i8254_send+0x119>
  }else{
    return -1;
80108e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108e37:	c9                   	leave  
80108e38:	c3                   	ret    

80108e39 <i8254_intr>:

void i8254_intr(){
80108e39:	55                   	push   %ebp
80108e3a:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108e3c:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108e41:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108e47:	90                   	nop
80108e48:	5d                   	pop    %ebp
80108e49:	c3                   	ret    

80108e4a <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108e4a:	55                   	push   %ebp
80108e4b:	89 e5                	mov    %esp,%ebp
80108e4d:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108e50:	8b 45 08             	mov    0x8(%ebp),%eax
80108e53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e59:	0f b7 00             	movzwl (%eax),%eax
80108e5c:	66 3d 00 01          	cmp    $0x100,%ax
80108e60:	74 0a                	je     80108e6c <arp_proc+0x22>
80108e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e67:	e9 4f 01 00 00       	jmp    80108fbb <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6f:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108e73:	66 83 f8 08          	cmp    $0x8,%ax
80108e77:	74 0a                	je     80108e83 <arp_proc+0x39>
80108e79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e7e:	e9 38 01 00 00       	jmp    80108fbb <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e86:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108e8a:	3c 06                	cmp    $0x6,%al
80108e8c:	74 0a                	je     80108e98 <arp_proc+0x4e>
80108e8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e93:	e9 23 01 00 00       	jmp    80108fbb <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9b:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108e9f:	3c 04                	cmp    $0x4,%al
80108ea1:	74 0a                	je     80108ead <arp_proc+0x63>
80108ea3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ea8:	e9 0e 01 00 00       	jmp    80108fbb <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb0:	83 c0 18             	add    $0x18,%eax
80108eb3:	83 ec 04             	sub    $0x4,%esp
80108eb6:	6a 04                	push   $0x4
80108eb8:	50                   	push   %eax
80108eb9:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ebe:	e8 b7 bd ff ff       	call   80104c7a <memcmp>
80108ec3:	83 c4 10             	add    $0x10,%esp
80108ec6:	85 c0                	test   %eax,%eax
80108ec8:	74 27                	je     80108ef1 <arp_proc+0xa7>
80108eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ecd:	83 c0 0e             	add    $0xe,%eax
80108ed0:	83 ec 04             	sub    $0x4,%esp
80108ed3:	6a 04                	push   $0x4
80108ed5:	50                   	push   %eax
80108ed6:	68 e4 f4 10 80       	push   $0x8010f4e4
80108edb:	e8 9a bd ff ff       	call   80104c7a <memcmp>
80108ee0:	83 c4 10             	add    $0x10,%esp
80108ee3:	85 c0                	test   %eax,%eax
80108ee5:	74 0a                	je     80108ef1 <arp_proc+0xa7>
80108ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eec:	e9 ca 00 00 00       	jmp    80108fbb <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108ef8:	66 3d 00 01          	cmp    $0x100,%ax
80108efc:	75 69                	jne    80108f67 <arp_proc+0x11d>
80108efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f01:	83 c0 18             	add    $0x18,%eax
80108f04:	83 ec 04             	sub    $0x4,%esp
80108f07:	6a 04                	push   $0x4
80108f09:	50                   	push   %eax
80108f0a:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f0f:	e8 66 bd ff ff       	call   80104c7a <memcmp>
80108f14:	83 c4 10             	add    $0x10,%esp
80108f17:	85 c0                	test   %eax,%eax
80108f19:	75 4c                	jne    80108f67 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108f1b:	e8 80 98 ff ff       	call   801027a0 <kalloc>
80108f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108f23:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108f2a:	83 ec 04             	sub    $0x4,%esp
80108f2d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f30:	50                   	push   %eax
80108f31:	ff 75 f0             	push   -0x10(%ebp)
80108f34:	ff 75 f4             	push   -0xc(%ebp)
80108f37:	e8 1f 04 00 00       	call   8010935b <arp_reply_pkt_create>
80108f3c:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108f3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f42:	83 ec 08             	sub    $0x8,%esp
80108f45:	50                   	push   %eax
80108f46:	ff 75 f0             	push   -0x10(%ebp)
80108f49:	e8 d0 fd ff ff       	call   80108d1e <i8254_send>
80108f4e:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f54:	83 ec 0c             	sub    $0xc,%esp
80108f57:	50                   	push   %eax
80108f58:	e8 a9 97 ff ff       	call   80102706 <kfree>
80108f5d:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108f60:	b8 02 00 00 00       	mov    $0x2,%eax
80108f65:	eb 54                	jmp    80108fbb <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f6e:	66 3d 00 02          	cmp    $0x200,%ax
80108f72:	75 42                	jne    80108fb6 <arp_proc+0x16c>
80108f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f77:	83 c0 18             	add    $0x18,%eax
80108f7a:	83 ec 04             	sub    $0x4,%esp
80108f7d:	6a 04                	push   $0x4
80108f7f:	50                   	push   %eax
80108f80:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f85:	e8 f0 bc ff ff       	call   80104c7a <memcmp>
80108f8a:	83 c4 10             	add    $0x10,%esp
80108f8d:	85 c0                	test   %eax,%eax
80108f8f:	75 25                	jne    80108fb6 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108f91:	83 ec 0c             	sub    $0xc,%esp
80108f94:	68 1c c1 10 80       	push   $0x8010c11c
80108f99:	e8 56 74 ff ff       	call   801003f4 <cprintf>
80108f9e:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108fa1:	83 ec 0c             	sub    $0xc,%esp
80108fa4:	ff 75 f4             	push   -0xc(%ebp)
80108fa7:	e8 af 01 00 00       	call   8010915b <arp_table_update>
80108fac:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108faf:	b8 01 00 00 00       	mov    $0x1,%eax
80108fb4:	eb 05                	jmp    80108fbb <arp_proc+0x171>
  }else{
    return -1;
80108fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108fbb:	c9                   	leave  
80108fbc:	c3                   	ret    

80108fbd <arp_scan>:

void arp_scan(){
80108fbd:	55                   	push   %ebp
80108fbe:	89 e5                	mov    %esp,%ebp
80108fc0:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108fca:	eb 6f                	jmp    8010903b <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108fcc:	e8 cf 97 ff ff       	call   801027a0 <kalloc>
80108fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108fd4:	83 ec 04             	sub    $0x4,%esp
80108fd7:	ff 75 f4             	push   -0xc(%ebp)
80108fda:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108fdd:	50                   	push   %eax
80108fde:	ff 75 ec             	push   -0x14(%ebp)
80108fe1:	e8 62 00 00 00       	call   80109048 <arp_broadcast>
80108fe6:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108fe9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fec:	83 ec 08             	sub    $0x8,%esp
80108fef:	50                   	push   %eax
80108ff0:	ff 75 ec             	push   -0x14(%ebp)
80108ff3:	e8 26 fd ff ff       	call   80108d1e <i8254_send>
80108ff8:	83 c4 10             	add    $0x10,%esp
80108ffb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ffe:	eb 22                	jmp    80109022 <arp_scan+0x65>
      microdelay(1);
80109000:	83 ec 0c             	sub    $0xc,%esp
80109003:	6a 01                	push   $0x1
80109005:	e8 2d 9b ff ff       	call   80102b37 <microdelay>
8010900a:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010900d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109010:	83 ec 08             	sub    $0x8,%esp
80109013:	50                   	push   %eax
80109014:	ff 75 ec             	push   -0x14(%ebp)
80109017:	e8 02 fd ff ff       	call   80108d1e <i8254_send>
8010901c:	83 c4 10             	add    $0x10,%esp
8010901f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109022:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109026:	74 d8                	je     80109000 <arp_scan+0x43>
    }
    kfree((char *)send);
80109028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010902b:	83 ec 0c             	sub    $0xc,%esp
8010902e:	50                   	push   %eax
8010902f:	e8 d2 96 ff ff       	call   80102706 <kfree>
80109034:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109037:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010903b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109042:	7e 88                	jle    80108fcc <arp_scan+0xf>
  }
}
80109044:	90                   	nop
80109045:	90                   	nop
80109046:	c9                   	leave  
80109047:	c3                   	ret    

80109048 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109048:	55                   	push   %ebp
80109049:	89 e5                	mov    %esp,%ebp
8010904b:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010904e:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109052:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109056:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010905a:	8b 45 10             	mov    0x10(%ebp),%eax
8010905d:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109060:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109067:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010906d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109074:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010907a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010907d:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109083:	8b 45 08             	mov    0x8(%ebp),%eax
80109086:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109089:	8b 45 08             	mov    0x8(%ebp),%eax
8010908c:	83 c0 0e             	add    $0xe,%eax
8010908f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109095:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010909c:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801090a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a3:	83 ec 04             	sub    $0x4,%esp
801090a6:	6a 06                	push   $0x6
801090a8:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801090ab:	52                   	push   %edx
801090ac:	50                   	push   %eax
801090ad:	e8 20 bc ff ff       	call   80104cd2 <memmove>
801090b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801090b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b8:	83 c0 06             	add    $0x6,%eax
801090bb:	83 ec 04             	sub    $0x4,%esp
801090be:	6a 06                	push   $0x6
801090c0:	68 80 6d 19 80       	push   $0x80196d80
801090c5:	50                   	push   %eax
801090c6:	e8 07 bc ff ff       	call   80104cd2 <memmove>
801090cb:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801090ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d1:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801090d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d9:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801090df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e2:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801090e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e9:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801090ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f0:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801090f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f9:	8d 50 12             	lea    0x12(%eax),%edx
801090fc:	83 ec 04             	sub    $0x4,%esp
801090ff:	6a 06                	push   $0x6
80109101:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109104:	50                   	push   %eax
80109105:	52                   	push   %edx
80109106:	e8 c7 bb ff ff       	call   80104cd2 <memmove>
8010910b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010910e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109111:	8d 50 18             	lea    0x18(%eax),%edx
80109114:	83 ec 04             	sub    $0x4,%esp
80109117:	6a 04                	push   $0x4
80109119:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010911c:	50                   	push   %eax
8010911d:	52                   	push   %edx
8010911e:	e8 af bb ff ff       	call   80104cd2 <memmove>
80109123:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109126:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109129:	83 c0 08             	add    $0x8,%eax
8010912c:	83 ec 04             	sub    $0x4,%esp
8010912f:	6a 06                	push   $0x6
80109131:	68 80 6d 19 80       	push   $0x80196d80
80109136:	50                   	push   %eax
80109137:	e8 96 bb ff ff       	call   80104cd2 <memmove>
8010913c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010913f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109142:	83 c0 0e             	add    $0xe,%eax
80109145:	83 ec 04             	sub    $0x4,%esp
80109148:	6a 04                	push   $0x4
8010914a:	68 e4 f4 10 80       	push   $0x8010f4e4
8010914f:	50                   	push   %eax
80109150:	e8 7d bb ff ff       	call   80104cd2 <memmove>
80109155:	83 c4 10             	add    $0x10,%esp
}
80109158:	90                   	nop
80109159:	c9                   	leave  
8010915a:	c3                   	ret    

8010915b <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010915b:	55                   	push   %ebp
8010915c:	89 e5                	mov    %esp,%ebp
8010915e:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109161:	8b 45 08             	mov    0x8(%ebp),%eax
80109164:	83 c0 0e             	add    $0xe,%eax
80109167:	83 ec 0c             	sub    $0xc,%esp
8010916a:	50                   	push   %eax
8010916b:	e8 bc 00 00 00       	call   8010922c <arp_table_search>
80109170:	83 c4 10             	add    $0x10,%esp
80109173:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109176:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010917a:	78 2d                	js     801091a9 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010917c:	8b 45 08             	mov    0x8(%ebp),%eax
8010917f:	8d 48 08             	lea    0x8(%eax),%ecx
80109182:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109185:	89 d0                	mov    %edx,%eax
80109187:	c1 e0 02             	shl    $0x2,%eax
8010918a:	01 d0                	add    %edx,%eax
8010918c:	01 c0                	add    %eax,%eax
8010918e:	01 d0                	add    %edx,%eax
80109190:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109195:	83 c0 04             	add    $0x4,%eax
80109198:	83 ec 04             	sub    $0x4,%esp
8010919b:	6a 06                	push   $0x6
8010919d:	51                   	push   %ecx
8010919e:	50                   	push   %eax
8010919f:	e8 2e bb ff ff       	call   80104cd2 <memmove>
801091a4:	83 c4 10             	add    $0x10,%esp
801091a7:	eb 70                	jmp    80109219 <arp_table_update+0xbe>
  }else{
    index += 1;
801091a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801091ad:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091b0:	8b 45 08             	mov    0x8(%ebp),%eax
801091b3:	8d 48 08             	lea    0x8(%eax),%ecx
801091b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091b9:	89 d0                	mov    %edx,%eax
801091bb:	c1 e0 02             	shl    $0x2,%eax
801091be:	01 d0                	add    %edx,%eax
801091c0:	01 c0                	add    %eax,%eax
801091c2:	01 d0                	add    %edx,%eax
801091c4:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801091c9:	83 c0 04             	add    $0x4,%eax
801091cc:	83 ec 04             	sub    $0x4,%esp
801091cf:	6a 06                	push   $0x6
801091d1:	51                   	push   %ecx
801091d2:	50                   	push   %eax
801091d3:	e8 fa ba ff ff       	call   80104cd2 <memmove>
801091d8:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801091db:	8b 45 08             	mov    0x8(%ebp),%eax
801091de:	8d 48 0e             	lea    0xe(%eax),%ecx
801091e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091e4:	89 d0                	mov    %edx,%eax
801091e6:	c1 e0 02             	shl    $0x2,%eax
801091e9:	01 d0                	add    %edx,%eax
801091eb:	01 c0                	add    %eax,%eax
801091ed:	01 d0                	add    %edx,%eax
801091ef:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801091f4:	83 ec 04             	sub    $0x4,%esp
801091f7:	6a 04                	push   $0x4
801091f9:	51                   	push   %ecx
801091fa:	50                   	push   %eax
801091fb:	e8 d2 ba ff ff       	call   80104cd2 <memmove>
80109200:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109203:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109206:	89 d0                	mov    %edx,%eax
80109208:	c1 e0 02             	shl    $0x2,%eax
8010920b:	01 d0                	add    %edx,%eax
8010920d:	01 c0                	add    %eax,%eax
8010920f:	01 d0                	add    %edx,%eax
80109211:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80109216:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109219:	83 ec 0c             	sub    $0xc,%esp
8010921c:	68 a0 6d 19 80       	push   $0x80196da0
80109221:	e8 83 00 00 00       	call   801092a9 <print_arp_table>
80109226:	83 c4 10             	add    $0x10,%esp
}
80109229:	90                   	nop
8010922a:	c9                   	leave  
8010922b:	c3                   	ret    

8010922c <arp_table_search>:

int arp_table_search(uchar *ip){
8010922c:	55                   	push   %ebp
8010922d:	89 e5                	mov    %esp,%ebp
8010922f:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109232:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109239:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109240:	eb 59                	jmp    8010929b <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109242:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109245:	89 d0                	mov    %edx,%eax
80109247:	c1 e0 02             	shl    $0x2,%eax
8010924a:	01 d0                	add    %edx,%eax
8010924c:	01 c0                	add    %eax,%eax
8010924e:	01 d0                	add    %edx,%eax
80109250:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109255:	83 ec 04             	sub    $0x4,%esp
80109258:	6a 04                	push   $0x4
8010925a:	ff 75 08             	push   0x8(%ebp)
8010925d:	50                   	push   %eax
8010925e:	e8 17 ba ff ff       	call   80104c7a <memcmp>
80109263:	83 c4 10             	add    $0x10,%esp
80109266:	85 c0                	test   %eax,%eax
80109268:	75 05                	jne    8010926f <arp_table_search+0x43>
      return i;
8010926a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010926d:	eb 38                	jmp    801092a7 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010926f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109272:	89 d0                	mov    %edx,%eax
80109274:	c1 e0 02             	shl    $0x2,%eax
80109277:	01 d0                	add    %edx,%eax
80109279:	01 c0                	add    %eax,%eax
8010927b:	01 d0                	add    %edx,%eax
8010927d:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80109282:	0f b6 00             	movzbl (%eax),%eax
80109285:	84 c0                	test   %al,%al
80109287:	75 0e                	jne    80109297 <arp_table_search+0x6b>
80109289:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010928d:	75 08                	jne    80109297 <arp_table_search+0x6b>
      empty = -i;
8010928f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109292:	f7 d8                	neg    %eax
80109294:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109297:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010929b:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010929f:	7e a1                	jle    80109242 <arp_table_search+0x16>
    }
  }
  return empty-1;
801092a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a4:	83 e8 01             	sub    $0x1,%eax
}
801092a7:	c9                   	leave  
801092a8:	c3                   	ret    

801092a9 <print_arp_table>:

void print_arp_table(){
801092a9:	55                   	push   %ebp
801092aa:	89 e5                	mov    %esp,%ebp
801092ac:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801092af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092b6:	e9 92 00 00 00       	jmp    8010934d <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801092bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092be:	89 d0                	mov    %edx,%eax
801092c0:	c1 e0 02             	shl    $0x2,%eax
801092c3:	01 d0                	add    %edx,%eax
801092c5:	01 c0                	add    %eax,%eax
801092c7:	01 d0                	add    %edx,%eax
801092c9:	05 aa 6d 19 80       	add    $0x80196daa,%eax
801092ce:	0f b6 00             	movzbl (%eax),%eax
801092d1:	84 c0                	test   %al,%al
801092d3:	74 74                	je     80109349 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801092d5:	83 ec 08             	sub    $0x8,%esp
801092d8:	ff 75 f4             	push   -0xc(%ebp)
801092db:	68 2f c1 10 80       	push   $0x8010c12f
801092e0:	e8 0f 71 ff ff       	call   801003f4 <cprintf>
801092e5:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801092e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092eb:	89 d0                	mov    %edx,%eax
801092ed:	c1 e0 02             	shl    $0x2,%eax
801092f0:	01 d0                	add    %edx,%eax
801092f2:	01 c0                	add    %eax,%eax
801092f4:	01 d0                	add    %edx,%eax
801092f6:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801092fb:	83 ec 0c             	sub    $0xc,%esp
801092fe:	50                   	push   %eax
801092ff:	e8 54 02 00 00       	call   80109558 <print_ipv4>
80109304:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109307:	83 ec 0c             	sub    $0xc,%esp
8010930a:	68 3e c1 10 80       	push   $0x8010c13e
8010930f:	e8 e0 70 ff ff       	call   801003f4 <cprintf>
80109314:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109317:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010931a:	89 d0                	mov    %edx,%eax
8010931c:	c1 e0 02             	shl    $0x2,%eax
8010931f:	01 d0                	add    %edx,%eax
80109321:	01 c0                	add    %eax,%eax
80109323:	01 d0                	add    %edx,%eax
80109325:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010932a:	83 c0 04             	add    $0x4,%eax
8010932d:	83 ec 0c             	sub    $0xc,%esp
80109330:	50                   	push   %eax
80109331:	e8 70 02 00 00       	call   801095a6 <print_mac>
80109336:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109339:	83 ec 0c             	sub    $0xc,%esp
8010933c:	68 40 c1 10 80       	push   $0x8010c140
80109341:	e8 ae 70 ff ff       	call   801003f4 <cprintf>
80109346:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109349:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010934d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109351:	0f 8e 64 ff ff ff    	jle    801092bb <print_arp_table+0x12>
    }
  }
}
80109357:	90                   	nop
80109358:	90                   	nop
80109359:	c9                   	leave  
8010935a:	c3                   	ret    

8010935b <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010935b:	55                   	push   %ebp
8010935c:	89 e5                	mov    %esp,%ebp
8010935e:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109361:	8b 45 10             	mov    0x10(%ebp),%eax
80109364:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010936a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010936d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109370:	8b 45 0c             	mov    0xc(%ebp),%eax
80109373:	83 c0 0e             	add    $0xe,%eax
80109376:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109383:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109387:	8b 45 08             	mov    0x8(%ebp),%eax
8010938a:	8d 50 08             	lea    0x8(%eax),%edx
8010938d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109390:	83 ec 04             	sub    $0x4,%esp
80109393:	6a 06                	push   $0x6
80109395:	52                   	push   %edx
80109396:	50                   	push   %eax
80109397:	e8 36 b9 ff ff       	call   80104cd2 <memmove>
8010939c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010939f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a2:	83 c0 06             	add    $0x6,%eax
801093a5:	83 ec 04             	sub    $0x4,%esp
801093a8:	6a 06                	push   $0x6
801093aa:	68 80 6d 19 80       	push   $0x80196d80
801093af:	50                   	push   %eax
801093b0:	e8 1d b9 ff ff       	call   80104cd2 <memmove>
801093b5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bb:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801093c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cc:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801093d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093da:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801093e0:	8b 45 08             	mov    0x8(%ebp),%eax
801093e3:	8d 50 08             	lea    0x8(%eax),%edx
801093e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e9:	83 c0 12             	add    $0x12,%eax
801093ec:	83 ec 04             	sub    $0x4,%esp
801093ef:	6a 06                	push   $0x6
801093f1:	52                   	push   %edx
801093f2:	50                   	push   %eax
801093f3:	e8 da b8 ff ff       	call   80104cd2 <memmove>
801093f8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801093fb:	8b 45 08             	mov    0x8(%ebp),%eax
801093fe:	8d 50 0e             	lea    0xe(%eax),%edx
80109401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109404:	83 c0 18             	add    $0x18,%eax
80109407:	83 ec 04             	sub    $0x4,%esp
8010940a:	6a 04                	push   $0x4
8010940c:	52                   	push   %edx
8010940d:	50                   	push   %eax
8010940e:	e8 bf b8 ff ff       	call   80104cd2 <memmove>
80109413:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109419:	83 c0 08             	add    $0x8,%eax
8010941c:	83 ec 04             	sub    $0x4,%esp
8010941f:	6a 06                	push   $0x6
80109421:	68 80 6d 19 80       	push   $0x80196d80
80109426:	50                   	push   %eax
80109427:	e8 a6 b8 ff ff       	call   80104cd2 <memmove>
8010942c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010942f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109432:	83 c0 0e             	add    $0xe,%eax
80109435:	83 ec 04             	sub    $0x4,%esp
80109438:	6a 04                	push   $0x4
8010943a:	68 e4 f4 10 80       	push   $0x8010f4e4
8010943f:	50                   	push   %eax
80109440:	e8 8d b8 ff ff       	call   80104cd2 <memmove>
80109445:	83 c4 10             	add    $0x10,%esp
}
80109448:	90                   	nop
80109449:	c9                   	leave  
8010944a:	c3                   	ret    

8010944b <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010944b:	55                   	push   %ebp
8010944c:	89 e5                	mov    %esp,%ebp
8010944e:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109451:	83 ec 0c             	sub    $0xc,%esp
80109454:	68 42 c1 10 80       	push   $0x8010c142
80109459:	e8 96 6f ff ff       	call   801003f4 <cprintf>
8010945e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109461:	8b 45 08             	mov    0x8(%ebp),%eax
80109464:	83 c0 0e             	add    $0xe,%eax
80109467:	83 ec 0c             	sub    $0xc,%esp
8010946a:	50                   	push   %eax
8010946b:	e8 e8 00 00 00       	call   80109558 <print_ipv4>
80109470:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109473:	83 ec 0c             	sub    $0xc,%esp
80109476:	68 40 c1 10 80       	push   $0x8010c140
8010947b:	e8 74 6f ff ff       	call   801003f4 <cprintf>
80109480:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109483:	8b 45 08             	mov    0x8(%ebp),%eax
80109486:	83 c0 08             	add    $0x8,%eax
80109489:	83 ec 0c             	sub    $0xc,%esp
8010948c:	50                   	push   %eax
8010948d:	e8 14 01 00 00       	call   801095a6 <print_mac>
80109492:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109495:	83 ec 0c             	sub    $0xc,%esp
80109498:	68 40 c1 10 80       	push   $0x8010c140
8010949d:	e8 52 6f ff ff       	call   801003f4 <cprintf>
801094a2:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801094a5:	83 ec 0c             	sub    $0xc,%esp
801094a8:	68 59 c1 10 80       	push   $0x8010c159
801094ad:	e8 42 6f ff ff       	call   801003f4 <cprintf>
801094b2:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801094b5:	8b 45 08             	mov    0x8(%ebp),%eax
801094b8:	83 c0 18             	add    $0x18,%eax
801094bb:	83 ec 0c             	sub    $0xc,%esp
801094be:	50                   	push   %eax
801094bf:	e8 94 00 00 00       	call   80109558 <print_ipv4>
801094c4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094c7:	83 ec 0c             	sub    $0xc,%esp
801094ca:	68 40 c1 10 80       	push   $0x8010c140
801094cf:	e8 20 6f ff ff       	call   801003f4 <cprintf>
801094d4:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801094d7:	8b 45 08             	mov    0x8(%ebp),%eax
801094da:	83 c0 12             	add    $0x12,%eax
801094dd:	83 ec 0c             	sub    $0xc,%esp
801094e0:	50                   	push   %eax
801094e1:	e8 c0 00 00 00       	call   801095a6 <print_mac>
801094e6:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094e9:	83 ec 0c             	sub    $0xc,%esp
801094ec:	68 40 c1 10 80       	push   $0x8010c140
801094f1:	e8 fe 6e ff ff       	call   801003f4 <cprintf>
801094f6:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801094f9:	83 ec 0c             	sub    $0xc,%esp
801094fc:	68 70 c1 10 80       	push   $0x8010c170
80109501:	e8 ee 6e ff ff       	call   801003f4 <cprintf>
80109506:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109509:	8b 45 08             	mov    0x8(%ebp),%eax
8010950c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109510:	66 3d 00 01          	cmp    $0x100,%ax
80109514:	75 12                	jne    80109528 <print_arp_info+0xdd>
80109516:	83 ec 0c             	sub    $0xc,%esp
80109519:	68 7c c1 10 80       	push   $0x8010c17c
8010951e:	e8 d1 6e ff ff       	call   801003f4 <cprintf>
80109523:	83 c4 10             	add    $0x10,%esp
80109526:	eb 1d                	jmp    80109545 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109528:	8b 45 08             	mov    0x8(%ebp),%eax
8010952b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010952f:	66 3d 00 02          	cmp    $0x200,%ax
80109533:	75 10                	jne    80109545 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109535:	83 ec 0c             	sub    $0xc,%esp
80109538:	68 85 c1 10 80       	push   $0x8010c185
8010953d:	e8 b2 6e ff ff       	call   801003f4 <cprintf>
80109542:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109545:	83 ec 0c             	sub    $0xc,%esp
80109548:	68 40 c1 10 80       	push   $0x8010c140
8010954d:	e8 a2 6e ff ff       	call   801003f4 <cprintf>
80109552:	83 c4 10             	add    $0x10,%esp
}
80109555:	90                   	nop
80109556:	c9                   	leave  
80109557:	c3                   	ret    

80109558 <print_ipv4>:

void print_ipv4(uchar *ip){
80109558:	55                   	push   %ebp
80109559:	89 e5                	mov    %esp,%ebp
8010955b:	53                   	push   %ebx
8010955c:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010955f:	8b 45 08             	mov    0x8(%ebp),%eax
80109562:	83 c0 03             	add    $0x3,%eax
80109565:	0f b6 00             	movzbl (%eax),%eax
80109568:	0f b6 d8             	movzbl %al,%ebx
8010956b:	8b 45 08             	mov    0x8(%ebp),%eax
8010956e:	83 c0 02             	add    $0x2,%eax
80109571:	0f b6 00             	movzbl (%eax),%eax
80109574:	0f b6 c8             	movzbl %al,%ecx
80109577:	8b 45 08             	mov    0x8(%ebp),%eax
8010957a:	83 c0 01             	add    $0x1,%eax
8010957d:	0f b6 00             	movzbl (%eax),%eax
80109580:	0f b6 d0             	movzbl %al,%edx
80109583:	8b 45 08             	mov    0x8(%ebp),%eax
80109586:	0f b6 00             	movzbl (%eax),%eax
80109589:	0f b6 c0             	movzbl %al,%eax
8010958c:	83 ec 0c             	sub    $0xc,%esp
8010958f:	53                   	push   %ebx
80109590:	51                   	push   %ecx
80109591:	52                   	push   %edx
80109592:	50                   	push   %eax
80109593:	68 8c c1 10 80       	push   $0x8010c18c
80109598:	e8 57 6e ff ff       	call   801003f4 <cprintf>
8010959d:	83 c4 20             	add    $0x20,%esp
}
801095a0:	90                   	nop
801095a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801095a4:	c9                   	leave  
801095a5:	c3                   	ret    

801095a6 <print_mac>:

void print_mac(uchar *mac){
801095a6:	55                   	push   %ebp
801095a7:	89 e5                	mov    %esp,%ebp
801095a9:	57                   	push   %edi
801095aa:	56                   	push   %esi
801095ab:	53                   	push   %ebx
801095ac:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801095af:	8b 45 08             	mov    0x8(%ebp),%eax
801095b2:	83 c0 05             	add    $0x5,%eax
801095b5:	0f b6 00             	movzbl (%eax),%eax
801095b8:	0f b6 f8             	movzbl %al,%edi
801095bb:	8b 45 08             	mov    0x8(%ebp),%eax
801095be:	83 c0 04             	add    $0x4,%eax
801095c1:	0f b6 00             	movzbl (%eax),%eax
801095c4:	0f b6 f0             	movzbl %al,%esi
801095c7:	8b 45 08             	mov    0x8(%ebp),%eax
801095ca:	83 c0 03             	add    $0x3,%eax
801095cd:	0f b6 00             	movzbl (%eax),%eax
801095d0:	0f b6 d8             	movzbl %al,%ebx
801095d3:	8b 45 08             	mov    0x8(%ebp),%eax
801095d6:	83 c0 02             	add    $0x2,%eax
801095d9:	0f b6 00             	movzbl (%eax),%eax
801095dc:	0f b6 c8             	movzbl %al,%ecx
801095df:	8b 45 08             	mov    0x8(%ebp),%eax
801095e2:	83 c0 01             	add    $0x1,%eax
801095e5:	0f b6 00             	movzbl (%eax),%eax
801095e8:	0f b6 d0             	movzbl %al,%edx
801095eb:	8b 45 08             	mov    0x8(%ebp),%eax
801095ee:	0f b6 00             	movzbl (%eax),%eax
801095f1:	0f b6 c0             	movzbl %al,%eax
801095f4:	83 ec 04             	sub    $0x4,%esp
801095f7:	57                   	push   %edi
801095f8:	56                   	push   %esi
801095f9:	53                   	push   %ebx
801095fa:	51                   	push   %ecx
801095fb:	52                   	push   %edx
801095fc:	50                   	push   %eax
801095fd:	68 a4 c1 10 80       	push   $0x8010c1a4
80109602:	e8 ed 6d ff ff       	call   801003f4 <cprintf>
80109607:	83 c4 20             	add    $0x20,%esp
}
8010960a:	90                   	nop
8010960b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010960e:	5b                   	pop    %ebx
8010960f:	5e                   	pop    %esi
80109610:	5f                   	pop    %edi
80109611:	5d                   	pop    %ebp
80109612:	c3                   	ret    

80109613 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109613:	55                   	push   %ebp
80109614:	89 e5                	mov    %esp,%ebp
80109616:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109619:	8b 45 08             	mov    0x8(%ebp),%eax
8010961c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010961f:	8b 45 08             	mov    0x8(%ebp),%eax
80109622:	83 c0 0e             	add    $0xe,%eax
80109625:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010962f:	3c 08                	cmp    $0x8,%al
80109631:	75 1b                	jne    8010964e <eth_proc+0x3b>
80109633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109636:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010963a:	3c 06                	cmp    $0x6,%al
8010963c:	75 10                	jne    8010964e <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010963e:	83 ec 0c             	sub    $0xc,%esp
80109641:	ff 75 f0             	push   -0x10(%ebp)
80109644:	e8 01 f8 ff ff       	call   80108e4a <arp_proc>
80109649:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010964c:	eb 24                	jmp    80109672 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010964e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109651:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109655:	3c 08                	cmp    $0x8,%al
80109657:	75 19                	jne    80109672 <eth_proc+0x5f>
80109659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010965c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109660:	84 c0                	test   %al,%al
80109662:	75 0e                	jne    80109672 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109664:	83 ec 0c             	sub    $0xc,%esp
80109667:	ff 75 08             	push   0x8(%ebp)
8010966a:	e8 a3 00 00 00       	call   80109712 <ipv4_proc>
8010966f:	83 c4 10             	add    $0x10,%esp
}
80109672:	90                   	nop
80109673:	c9                   	leave  
80109674:	c3                   	ret    

80109675 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109675:	55                   	push   %ebp
80109676:	89 e5                	mov    %esp,%ebp
80109678:	83 ec 04             	sub    $0x4,%esp
8010967b:	8b 45 08             	mov    0x8(%ebp),%eax
8010967e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109682:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109686:	c1 e0 08             	shl    $0x8,%eax
80109689:	89 c2                	mov    %eax,%edx
8010968b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010968f:	66 c1 e8 08          	shr    $0x8,%ax
80109693:	01 d0                	add    %edx,%eax
}
80109695:	c9                   	leave  
80109696:	c3                   	ret    

80109697 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109697:	55                   	push   %ebp
80109698:	89 e5                	mov    %esp,%ebp
8010969a:	83 ec 04             	sub    $0x4,%esp
8010969d:	8b 45 08             	mov    0x8(%ebp),%eax
801096a0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801096a4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096a8:	c1 e0 08             	shl    $0x8,%eax
801096ab:	89 c2                	mov    %eax,%edx
801096ad:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096b1:	66 c1 e8 08          	shr    $0x8,%ax
801096b5:	01 d0                	add    %edx,%eax
}
801096b7:	c9                   	leave  
801096b8:	c3                   	ret    

801096b9 <H2N_uint>:

uint H2N_uint(uint value){
801096b9:	55                   	push   %ebp
801096ba:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801096bc:	8b 45 08             	mov    0x8(%ebp),%eax
801096bf:	c1 e0 18             	shl    $0x18,%eax
801096c2:	25 00 00 00 0f       	and    $0xf000000,%eax
801096c7:	89 c2                	mov    %eax,%edx
801096c9:	8b 45 08             	mov    0x8(%ebp),%eax
801096cc:	c1 e0 08             	shl    $0x8,%eax
801096cf:	25 00 f0 00 00       	and    $0xf000,%eax
801096d4:	09 c2                	or     %eax,%edx
801096d6:	8b 45 08             	mov    0x8(%ebp),%eax
801096d9:	c1 e8 08             	shr    $0x8,%eax
801096dc:	83 e0 0f             	and    $0xf,%eax
801096df:	01 d0                	add    %edx,%eax
}
801096e1:	5d                   	pop    %ebp
801096e2:	c3                   	ret    

801096e3 <N2H_uint>:

uint N2H_uint(uint value){
801096e3:	55                   	push   %ebp
801096e4:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801096e6:	8b 45 08             	mov    0x8(%ebp),%eax
801096e9:	c1 e0 18             	shl    $0x18,%eax
801096ec:	89 c2                	mov    %eax,%edx
801096ee:	8b 45 08             	mov    0x8(%ebp),%eax
801096f1:	c1 e0 08             	shl    $0x8,%eax
801096f4:	25 00 00 ff 00       	and    $0xff0000,%eax
801096f9:	01 c2                	add    %eax,%edx
801096fb:	8b 45 08             	mov    0x8(%ebp),%eax
801096fe:	c1 e8 08             	shr    $0x8,%eax
80109701:	25 00 ff 00 00       	and    $0xff00,%eax
80109706:	01 c2                	add    %eax,%edx
80109708:	8b 45 08             	mov    0x8(%ebp),%eax
8010970b:	c1 e8 18             	shr    $0x18,%eax
8010970e:	01 d0                	add    %edx,%eax
}
80109710:	5d                   	pop    %ebp
80109711:	c3                   	ret    

80109712 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109712:	55                   	push   %ebp
80109713:	89 e5                	mov    %esp,%ebp
80109715:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109718:	8b 45 08             	mov    0x8(%ebp),%eax
8010971b:	83 c0 0e             	add    $0xe,%eax
8010971e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109724:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109728:	0f b7 d0             	movzwl %ax,%edx
8010972b:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109730:	39 c2                	cmp    %eax,%edx
80109732:	74 60                	je     80109794 <ipv4_proc+0x82>
80109734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109737:	83 c0 0c             	add    $0xc,%eax
8010973a:	83 ec 04             	sub    $0x4,%esp
8010973d:	6a 04                	push   $0x4
8010973f:	50                   	push   %eax
80109740:	68 e4 f4 10 80       	push   $0x8010f4e4
80109745:	e8 30 b5 ff ff       	call   80104c7a <memcmp>
8010974a:	83 c4 10             	add    $0x10,%esp
8010974d:	85 c0                	test   %eax,%eax
8010974f:	74 43                	je     80109794 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109754:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109758:	0f b7 c0             	movzwl %ax,%eax
8010975b:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109763:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109767:	3c 01                	cmp    $0x1,%al
80109769:	75 10                	jne    8010977b <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010976b:	83 ec 0c             	sub    $0xc,%esp
8010976e:	ff 75 08             	push   0x8(%ebp)
80109771:	e8 a3 00 00 00       	call   80109819 <icmp_proc>
80109776:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109779:	eb 19                	jmp    80109794 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010977b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010977e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109782:	3c 06                	cmp    $0x6,%al
80109784:	75 0e                	jne    80109794 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109786:	83 ec 0c             	sub    $0xc,%esp
80109789:	ff 75 08             	push   0x8(%ebp)
8010978c:	e8 b3 03 00 00       	call   80109b44 <tcp_proc>
80109791:	83 c4 10             	add    $0x10,%esp
}
80109794:	90                   	nop
80109795:	c9                   	leave  
80109796:	c3                   	ret    

80109797 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109797:	55                   	push   %ebp
80109798:	89 e5                	mov    %esp,%ebp
8010979a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010979d:	8b 45 08             	mov    0x8(%ebp),%eax
801097a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801097a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a6:	0f b6 00             	movzbl (%eax),%eax
801097a9:	83 e0 0f             	and    $0xf,%eax
801097ac:	01 c0                	add    %eax,%eax
801097ae:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801097b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801097b8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801097bf:	eb 48                	jmp    80109809 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801097c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801097c4:	01 c0                	add    %eax,%eax
801097c6:	89 c2                	mov    %eax,%edx
801097c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cb:	01 d0                	add    %edx,%eax
801097cd:	0f b6 00             	movzbl (%eax),%eax
801097d0:	0f b6 c0             	movzbl %al,%eax
801097d3:	c1 e0 08             	shl    $0x8,%eax
801097d6:	89 c2                	mov    %eax,%edx
801097d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801097db:	01 c0                	add    %eax,%eax
801097dd:	8d 48 01             	lea    0x1(%eax),%ecx
801097e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e3:	01 c8                	add    %ecx,%eax
801097e5:	0f b6 00             	movzbl (%eax),%eax
801097e8:	0f b6 c0             	movzbl %al,%eax
801097eb:	01 d0                	add    %edx,%eax
801097ed:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801097f0:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801097f7:	76 0c                	jbe    80109805 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
801097f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801097fc:	0f b7 c0             	movzwl %ax,%eax
801097ff:	83 c0 01             	add    $0x1,%eax
80109802:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109805:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109809:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010980d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109810:	7c af                	jl     801097c1 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109812:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109815:	f7 d0                	not    %eax
}
80109817:	c9                   	leave  
80109818:	c3                   	ret    

80109819 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109819:	55                   	push   %ebp
8010981a:	89 e5                	mov    %esp,%ebp
8010981c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010981f:	8b 45 08             	mov    0x8(%ebp),%eax
80109822:	83 c0 0e             	add    $0xe,%eax
80109825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982b:	0f b6 00             	movzbl (%eax),%eax
8010982e:	0f b6 c0             	movzbl %al,%eax
80109831:	83 e0 0f             	and    $0xf,%eax
80109834:	c1 e0 02             	shl    $0x2,%eax
80109837:	89 c2                	mov    %eax,%edx
80109839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010983c:	01 d0                	add    %edx,%eax
8010983e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109844:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109848:	84 c0                	test   %al,%al
8010984a:	75 4f                	jne    8010989b <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010984c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010984f:	0f b6 00             	movzbl (%eax),%eax
80109852:	3c 08                	cmp    $0x8,%al
80109854:	75 45                	jne    8010989b <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109856:	e8 45 8f ff ff       	call   801027a0 <kalloc>
8010985b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010985e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109865:	83 ec 04             	sub    $0x4,%esp
80109868:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010986b:	50                   	push   %eax
8010986c:	ff 75 ec             	push   -0x14(%ebp)
8010986f:	ff 75 08             	push   0x8(%ebp)
80109872:	e8 78 00 00 00       	call   801098ef <icmp_reply_pkt_create>
80109877:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010987a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010987d:	83 ec 08             	sub    $0x8,%esp
80109880:	50                   	push   %eax
80109881:	ff 75 ec             	push   -0x14(%ebp)
80109884:	e8 95 f4 ff ff       	call   80108d1e <i8254_send>
80109889:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010988c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010988f:	83 ec 0c             	sub    $0xc,%esp
80109892:	50                   	push   %eax
80109893:	e8 6e 8e ff ff       	call   80102706 <kfree>
80109898:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010989b:	90                   	nop
8010989c:	c9                   	leave  
8010989d:	c3                   	ret    

8010989e <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010989e:	55                   	push   %ebp
8010989f:	89 e5                	mov    %esp,%ebp
801098a1:	53                   	push   %ebx
801098a2:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801098a5:	8b 45 08             	mov    0x8(%ebp),%eax
801098a8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098ac:	0f b7 c0             	movzwl %ax,%eax
801098af:	83 ec 0c             	sub    $0xc,%esp
801098b2:	50                   	push   %eax
801098b3:	e8 bd fd ff ff       	call   80109675 <N2H_ushort>
801098b8:	83 c4 10             	add    $0x10,%esp
801098bb:	0f b7 d8             	movzwl %ax,%ebx
801098be:	8b 45 08             	mov    0x8(%ebp),%eax
801098c1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801098c5:	0f b7 c0             	movzwl %ax,%eax
801098c8:	83 ec 0c             	sub    $0xc,%esp
801098cb:	50                   	push   %eax
801098cc:	e8 a4 fd ff ff       	call   80109675 <N2H_ushort>
801098d1:	83 c4 10             	add    $0x10,%esp
801098d4:	0f b7 c0             	movzwl %ax,%eax
801098d7:	83 ec 04             	sub    $0x4,%esp
801098da:	53                   	push   %ebx
801098db:	50                   	push   %eax
801098dc:	68 c3 c1 10 80       	push   $0x8010c1c3
801098e1:	e8 0e 6b ff ff       	call   801003f4 <cprintf>
801098e6:	83 c4 10             	add    $0x10,%esp
}
801098e9:	90                   	nop
801098ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098ed:	c9                   	leave  
801098ee:	c3                   	ret    

801098ef <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
801098ef:	55                   	push   %ebp
801098f0:	89 e5                	mov    %esp,%ebp
801098f2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
801098f5:	8b 45 08             	mov    0x8(%ebp),%eax
801098f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801098fb:	8b 45 08             	mov    0x8(%ebp),%eax
801098fe:	83 c0 0e             	add    $0xe,%eax
80109901:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109907:	0f b6 00             	movzbl (%eax),%eax
8010990a:	0f b6 c0             	movzbl %al,%eax
8010990d:	83 e0 0f             	and    $0xf,%eax
80109910:	c1 e0 02             	shl    $0x2,%eax
80109913:	89 c2                	mov    %eax,%edx
80109915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109918:	01 d0                	add    %edx,%eax
8010991a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010991d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109920:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109923:	8b 45 0c             	mov    0xc(%ebp),%eax
80109926:	83 c0 0e             	add    $0xe,%eax
80109929:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010992c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010992f:	83 c0 14             	add    $0x14,%eax
80109932:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109935:	8b 45 10             	mov    0x10(%ebp),%eax
80109938:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010993e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109941:	8d 50 06             	lea    0x6(%eax),%edx
80109944:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109947:	83 ec 04             	sub    $0x4,%esp
8010994a:	6a 06                	push   $0x6
8010994c:	52                   	push   %edx
8010994d:	50                   	push   %eax
8010994e:	e8 7f b3 ff ff       	call   80104cd2 <memmove>
80109953:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109956:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109959:	83 c0 06             	add    $0x6,%eax
8010995c:	83 ec 04             	sub    $0x4,%esp
8010995f:	6a 06                	push   $0x6
80109961:	68 80 6d 19 80       	push   $0x80196d80
80109966:	50                   	push   %eax
80109967:	e8 66 b3 ff ff       	call   80104cd2 <memmove>
8010996c:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010996f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109972:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109976:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109979:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010997d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109980:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109986:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010998a:	83 ec 0c             	sub    $0xc,%esp
8010998d:	6a 54                	push   $0x54
8010998f:	e8 03 fd ff ff       	call   80109697 <H2N_ushort>
80109994:	83 c4 10             	add    $0x10,%esp
80109997:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010999a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010999e:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
801099a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099a8:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801099ac:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
801099b3:	83 c0 01             	add    $0x1,%eax
801099b6:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
801099bc:	83 ec 0c             	sub    $0xc,%esp
801099bf:	68 00 40 00 00       	push   $0x4000
801099c4:	e8 ce fc ff ff       	call   80109697 <H2N_ushort>
801099c9:	83 c4 10             	add    $0x10,%esp
801099cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099cf:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
801099d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099d6:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
801099da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099dd:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
801099e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099e4:	83 c0 0c             	add    $0xc,%eax
801099e7:	83 ec 04             	sub    $0x4,%esp
801099ea:	6a 04                	push   $0x4
801099ec:	68 e4 f4 10 80       	push   $0x8010f4e4
801099f1:	50                   	push   %eax
801099f2:	e8 db b2 ff ff       	call   80104cd2 <memmove>
801099f7:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
801099fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099fd:	8d 50 0c             	lea    0xc(%eax),%edx
80109a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a03:	83 c0 10             	add    $0x10,%eax
80109a06:	83 ec 04             	sub    $0x4,%esp
80109a09:	6a 04                	push   $0x4
80109a0b:	52                   	push   %edx
80109a0c:	50                   	push   %eax
80109a0d:	e8 c0 b2 ff ff       	call   80104cd2 <memmove>
80109a12:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109a15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a18:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109a1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a21:	83 ec 0c             	sub    $0xc,%esp
80109a24:	50                   	push   %eax
80109a25:	e8 6d fd ff ff       	call   80109797 <ipv4_chksum>
80109a2a:	83 c4 10             	add    $0x10,%esp
80109a2d:	0f b7 c0             	movzwl %ax,%eax
80109a30:	83 ec 0c             	sub    $0xc,%esp
80109a33:	50                   	push   %eax
80109a34:	e8 5e fc ff ff       	call   80109697 <H2N_ushort>
80109a39:	83 c4 10             	add    $0x10,%esp
80109a3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a3f:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109a43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a46:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109a49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a4c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a53:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109a57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a5a:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109a5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a61:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109a65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a68:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a6f:	8d 50 08             	lea    0x8(%eax),%edx
80109a72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a75:	83 c0 08             	add    $0x8,%eax
80109a78:	83 ec 04             	sub    $0x4,%esp
80109a7b:	6a 08                	push   $0x8
80109a7d:	52                   	push   %edx
80109a7e:	50                   	push   %eax
80109a7f:	e8 4e b2 ff ff       	call   80104cd2 <memmove>
80109a84:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109a87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a8a:	8d 50 10             	lea    0x10(%eax),%edx
80109a8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a90:	83 c0 10             	add    $0x10,%eax
80109a93:	83 ec 04             	sub    $0x4,%esp
80109a96:	6a 30                	push   $0x30
80109a98:	52                   	push   %edx
80109a99:	50                   	push   %eax
80109a9a:	e8 33 b2 ff ff       	call   80104cd2 <memmove>
80109a9f:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aa5:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109aae:	83 ec 0c             	sub    $0xc,%esp
80109ab1:	50                   	push   %eax
80109ab2:	e8 1c 00 00 00       	call   80109ad3 <icmp_chksum>
80109ab7:	83 c4 10             	add    $0x10,%esp
80109aba:	0f b7 c0             	movzwl %ax,%eax
80109abd:	83 ec 0c             	sub    $0xc,%esp
80109ac0:	50                   	push   %eax
80109ac1:	e8 d1 fb ff ff       	call   80109697 <H2N_ushort>
80109ac6:	83 c4 10             	add    $0x10,%esp
80109ac9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109acc:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109ad0:	90                   	nop
80109ad1:	c9                   	leave  
80109ad2:	c3                   	ret    

80109ad3 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109ad3:	55                   	push   %ebp
80109ad4:	89 e5                	mov    %esp,%ebp
80109ad6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80109adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109adf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ae6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109aed:	eb 48                	jmp    80109b37 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109aef:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109af2:	01 c0                	add    %eax,%eax
80109af4:	89 c2                	mov    %eax,%edx
80109af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af9:	01 d0                	add    %edx,%eax
80109afb:	0f b6 00             	movzbl (%eax),%eax
80109afe:	0f b6 c0             	movzbl %al,%eax
80109b01:	c1 e0 08             	shl    $0x8,%eax
80109b04:	89 c2                	mov    %eax,%edx
80109b06:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b09:	01 c0                	add    %eax,%eax
80109b0b:	8d 48 01             	lea    0x1(%eax),%ecx
80109b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b11:	01 c8                	add    %ecx,%eax
80109b13:	0f b6 00             	movzbl (%eax),%eax
80109b16:	0f b6 c0             	movzbl %al,%eax
80109b19:	01 d0                	add    %edx,%eax
80109b1b:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b1e:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b25:	76 0c                	jbe    80109b33 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b2a:	0f b7 c0             	movzwl %ax,%eax
80109b2d:	83 c0 01             	add    $0x1,%eax
80109b30:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b33:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b37:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109b3b:	7e b2                	jle    80109aef <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b40:	f7 d0                	not    %eax
}
80109b42:	c9                   	leave  
80109b43:	c3                   	ret    

80109b44 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109b44:	55                   	push   %ebp
80109b45:	89 e5                	mov    %esp,%ebp
80109b47:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4d:	83 c0 0e             	add    $0xe,%eax
80109b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b56:	0f b6 00             	movzbl (%eax),%eax
80109b59:	0f b6 c0             	movzbl %al,%eax
80109b5c:	83 e0 0f             	and    $0xf,%eax
80109b5f:	c1 e0 02             	shl    $0x2,%eax
80109b62:	89 c2                	mov    %eax,%edx
80109b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b67:	01 d0                	add    %edx,%eax
80109b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b6f:	83 c0 14             	add    $0x14,%eax
80109b72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109b75:	e8 26 8c ff ff       	call   801027a0 <kalloc>
80109b7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109b7d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b87:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b8b:	0f b6 c0             	movzbl %al,%eax
80109b8e:	83 e0 02             	and    $0x2,%eax
80109b91:	85 c0                	test   %eax,%eax
80109b93:	74 3d                	je     80109bd2 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109b95:	83 ec 0c             	sub    $0xc,%esp
80109b98:	6a 00                	push   $0x0
80109b9a:	6a 12                	push   $0x12
80109b9c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b9f:	50                   	push   %eax
80109ba0:	ff 75 e8             	push   -0x18(%ebp)
80109ba3:	ff 75 08             	push   0x8(%ebp)
80109ba6:	e8 a2 01 00 00       	call   80109d4d <tcp_pkt_create>
80109bab:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109bae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bb1:	83 ec 08             	sub    $0x8,%esp
80109bb4:	50                   	push   %eax
80109bb5:	ff 75 e8             	push   -0x18(%ebp)
80109bb8:	e8 61 f1 ff ff       	call   80108d1e <i8254_send>
80109bbd:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109bc0:	a1 64 70 19 80       	mov    0x80197064,%eax
80109bc5:	83 c0 01             	add    $0x1,%eax
80109bc8:	a3 64 70 19 80       	mov    %eax,0x80197064
80109bcd:	e9 69 01 00 00       	jmp    80109d3b <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109bd9:	3c 18                	cmp    $0x18,%al
80109bdb:	0f 85 10 01 00 00    	jne    80109cf1 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109be1:	83 ec 04             	sub    $0x4,%esp
80109be4:	6a 03                	push   $0x3
80109be6:	68 de c1 10 80       	push   $0x8010c1de
80109beb:	ff 75 ec             	push   -0x14(%ebp)
80109bee:	e8 87 b0 ff ff       	call   80104c7a <memcmp>
80109bf3:	83 c4 10             	add    $0x10,%esp
80109bf6:	85 c0                	test   %eax,%eax
80109bf8:	74 74                	je     80109c6e <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109bfa:	83 ec 0c             	sub    $0xc,%esp
80109bfd:	68 e2 c1 10 80       	push   $0x8010c1e2
80109c02:	e8 ed 67 ff ff       	call   801003f4 <cprintf>
80109c07:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c0a:	83 ec 0c             	sub    $0xc,%esp
80109c0d:	6a 00                	push   $0x0
80109c0f:	6a 10                	push   $0x10
80109c11:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c14:	50                   	push   %eax
80109c15:	ff 75 e8             	push   -0x18(%ebp)
80109c18:	ff 75 08             	push   0x8(%ebp)
80109c1b:	e8 2d 01 00 00       	call   80109d4d <tcp_pkt_create>
80109c20:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109c23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c26:	83 ec 08             	sub    $0x8,%esp
80109c29:	50                   	push   %eax
80109c2a:	ff 75 e8             	push   -0x18(%ebp)
80109c2d:	e8 ec f0 ff ff       	call   80108d1e <i8254_send>
80109c32:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109c35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c38:	83 c0 36             	add    $0x36,%eax
80109c3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109c3e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109c41:	50                   	push   %eax
80109c42:	ff 75 e0             	push   -0x20(%ebp)
80109c45:	6a 00                	push   $0x0
80109c47:	6a 00                	push   $0x0
80109c49:	e8 5a 04 00 00       	call   8010a0a8 <http_proc>
80109c4e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109c51:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109c54:	83 ec 0c             	sub    $0xc,%esp
80109c57:	50                   	push   %eax
80109c58:	6a 18                	push   $0x18
80109c5a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c5d:	50                   	push   %eax
80109c5e:	ff 75 e8             	push   -0x18(%ebp)
80109c61:	ff 75 08             	push   0x8(%ebp)
80109c64:	e8 e4 00 00 00       	call   80109d4d <tcp_pkt_create>
80109c69:	83 c4 20             	add    $0x20,%esp
80109c6c:	eb 62                	jmp    80109cd0 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c6e:	83 ec 0c             	sub    $0xc,%esp
80109c71:	6a 00                	push   $0x0
80109c73:	6a 10                	push   $0x10
80109c75:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c78:	50                   	push   %eax
80109c79:	ff 75 e8             	push   -0x18(%ebp)
80109c7c:	ff 75 08             	push   0x8(%ebp)
80109c7f:	e8 c9 00 00 00       	call   80109d4d <tcp_pkt_create>
80109c84:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109c87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c8a:	83 ec 08             	sub    $0x8,%esp
80109c8d:	50                   	push   %eax
80109c8e:	ff 75 e8             	push   -0x18(%ebp)
80109c91:	e8 88 f0 ff ff       	call   80108d1e <i8254_send>
80109c96:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109c99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c9c:	83 c0 36             	add    $0x36,%eax
80109c9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ca2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109ca5:	50                   	push   %eax
80109ca6:	ff 75 e4             	push   -0x1c(%ebp)
80109ca9:	6a 00                	push   $0x0
80109cab:	6a 00                	push   $0x0
80109cad:	e8 f6 03 00 00       	call   8010a0a8 <http_proc>
80109cb2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109cb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109cb8:	83 ec 0c             	sub    $0xc,%esp
80109cbb:	50                   	push   %eax
80109cbc:	6a 18                	push   $0x18
80109cbe:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cc1:	50                   	push   %eax
80109cc2:	ff 75 e8             	push   -0x18(%ebp)
80109cc5:	ff 75 08             	push   0x8(%ebp)
80109cc8:	e8 80 00 00 00       	call   80109d4d <tcp_pkt_create>
80109ccd:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109cd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109cd3:	83 ec 08             	sub    $0x8,%esp
80109cd6:	50                   	push   %eax
80109cd7:	ff 75 e8             	push   -0x18(%ebp)
80109cda:	e8 3f f0 ff ff       	call   80108d1e <i8254_send>
80109cdf:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ce2:	a1 64 70 19 80       	mov    0x80197064,%eax
80109ce7:	83 c0 01             	add    $0x1,%eax
80109cea:	a3 64 70 19 80       	mov    %eax,0x80197064
80109cef:	eb 4a                	jmp    80109d3b <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cf8:	3c 10                	cmp    $0x10,%al
80109cfa:	75 3f                	jne    80109d3b <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109cfc:	a1 68 70 19 80       	mov    0x80197068,%eax
80109d01:	83 f8 01             	cmp    $0x1,%eax
80109d04:	75 35                	jne    80109d3b <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109d06:	83 ec 0c             	sub    $0xc,%esp
80109d09:	6a 00                	push   $0x0
80109d0b:	6a 01                	push   $0x1
80109d0d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d10:	50                   	push   %eax
80109d11:	ff 75 e8             	push   -0x18(%ebp)
80109d14:	ff 75 08             	push   0x8(%ebp)
80109d17:	e8 31 00 00 00       	call   80109d4d <tcp_pkt_create>
80109d1c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d22:	83 ec 08             	sub    $0x8,%esp
80109d25:	50                   	push   %eax
80109d26:	ff 75 e8             	push   -0x18(%ebp)
80109d29:	e8 f0 ef ff ff       	call   80108d1e <i8254_send>
80109d2e:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109d31:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109d38:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d3e:	83 ec 0c             	sub    $0xc,%esp
80109d41:	50                   	push   %eax
80109d42:	e8 bf 89 ff ff       	call   80102706 <kfree>
80109d47:	83 c4 10             	add    $0x10,%esp
}
80109d4a:	90                   	nop
80109d4b:	c9                   	leave  
80109d4c:	c3                   	ret    

80109d4d <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109d4d:	55                   	push   %ebp
80109d4e:	89 e5                	mov    %esp,%ebp
80109d50:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d53:	8b 45 08             	mov    0x8(%ebp),%eax
80109d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d59:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5c:	83 c0 0e             	add    $0xe,%eax
80109d5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d65:	0f b6 00             	movzbl (%eax),%eax
80109d68:	0f b6 c0             	movzbl %al,%eax
80109d6b:	83 e0 0f             	and    $0xf,%eax
80109d6e:	c1 e0 02             	shl    $0x2,%eax
80109d71:	89 c2                	mov    %eax,%edx
80109d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d76:	01 d0                	add    %edx,%eax
80109d78:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d84:	83 c0 0e             	add    $0xe,%eax
80109d87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d8d:	83 c0 14             	add    $0x14,%eax
80109d90:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109d93:	8b 45 18             	mov    0x18(%ebp),%eax
80109d96:	8d 50 36             	lea    0x36(%eax),%edx
80109d99:	8b 45 10             	mov    0x10(%ebp),%eax
80109d9c:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109da1:	8d 50 06             	lea    0x6(%eax),%edx
80109da4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109da7:	83 ec 04             	sub    $0x4,%esp
80109daa:	6a 06                	push   $0x6
80109dac:	52                   	push   %edx
80109dad:	50                   	push   %eax
80109dae:	e8 1f af ff ff       	call   80104cd2 <memmove>
80109db3:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109db6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109db9:	83 c0 06             	add    $0x6,%eax
80109dbc:	83 ec 04             	sub    $0x4,%esp
80109dbf:	6a 06                	push   $0x6
80109dc1:	68 80 6d 19 80       	push   $0x80196d80
80109dc6:	50                   	push   %eax
80109dc7:	e8 06 af ff ff       	call   80104cd2 <memmove>
80109dcc:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109dcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dd2:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dd9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109de0:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109de6:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109dea:	8b 45 18             	mov    0x18(%ebp),%eax
80109ded:	83 c0 28             	add    $0x28,%eax
80109df0:	0f b7 c0             	movzwl %ax,%eax
80109df3:	83 ec 0c             	sub    $0xc,%esp
80109df6:	50                   	push   %eax
80109df7:	e8 9b f8 ff ff       	call   80109697 <H2N_ushort>
80109dfc:	83 c4 10             	add    $0x10,%esp
80109dff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e02:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e06:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e10:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e14:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109e1b:	83 c0 01             	add    $0x1,%eax
80109e1e:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109e24:	83 ec 0c             	sub    $0xc,%esp
80109e27:	6a 00                	push   $0x0
80109e29:	e8 69 f8 ff ff       	call   80109697 <H2N_ushort>
80109e2e:	83 c4 10             	add    $0x10,%esp
80109e31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e34:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e3b:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109e3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e42:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e49:	83 c0 0c             	add    $0xc,%eax
80109e4c:	83 ec 04             	sub    $0x4,%esp
80109e4f:	6a 04                	push   $0x4
80109e51:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e56:	50                   	push   %eax
80109e57:	e8 76 ae ff ff       	call   80104cd2 <memmove>
80109e5c:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e62:	8d 50 0c             	lea    0xc(%eax),%edx
80109e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e68:	83 c0 10             	add    $0x10,%eax
80109e6b:	83 ec 04             	sub    $0x4,%esp
80109e6e:	6a 04                	push   $0x4
80109e70:	52                   	push   %edx
80109e71:	50                   	push   %eax
80109e72:	e8 5b ae ff ff       	call   80104cd2 <memmove>
80109e77:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e7d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e86:	83 ec 0c             	sub    $0xc,%esp
80109e89:	50                   	push   %eax
80109e8a:	e8 08 f9 ff ff       	call   80109797 <ipv4_chksum>
80109e8f:	83 c4 10             	add    $0x10,%esp
80109e92:	0f b7 c0             	movzwl %ax,%eax
80109e95:	83 ec 0c             	sub    $0xc,%esp
80109e98:	50                   	push   %eax
80109e99:	e8 f9 f7 ff ff       	call   80109697 <H2N_ushort>
80109e9e:	83 c4 10             	add    $0x10,%esp
80109ea1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ea4:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eab:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109eaf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb2:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eb8:	0f b7 10             	movzwl (%eax),%edx
80109ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ebe:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109ec2:	a1 64 70 19 80       	mov    0x80197064,%eax
80109ec7:	83 ec 0c             	sub    $0xc,%esp
80109eca:	50                   	push   %eax
80109ecb:	e8 e9 f7 ff ff       	call   801096b9 <H2N_uint>
80109ed0:	83 c4 10             	add    $0x10,%esp
80109ed3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ed6:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109edc:	8b 40 04             	mov    0x4(%eax),%eax
80109edf:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee8:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109eeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eee:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109ef2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ef5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109efc:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109f00:	8b 45 14             	mov    0x14(%ebp),%eax
80109f03:	89 c2                	mov    %eax,%edx
80109f05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f08:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109f0b:	83 ec 0c             	sub    $0xc,%esp
80109f0e:	68 90 38 00 00       	push   $0x3890
80109f13:	e8 7f f7 ff ff       	call   80109697 <H2N_ushort>
80109f18:	83 c4 10             	add    $0x10,%esp
80109f1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f1e:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109f22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f25:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f2e:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f37:	83 ec 0c             	sub    $0xc,%esp
80109f3a:	50                   	push   %eax
80109f3b:	e8 1f 00 00 00       	call   80109f5f <tcp_chksum>
80109f40:	83 c4 10             	add    $0x10,%esp
80109f43:	83 c0 08             	add    $0x8,%eax
80109f46:	0f b7 c0             	movzwl %ax,%eax
80109f49:	83 ec 0c             	sub    $0xc,%esp
80109f4c:	50                   	push   %eax
80109f4d:	e8 45 f7 ff ff       	call   80109697 <H2N_ushort>
80109f52:	83 c4 10             	add    $0x10,%esp
80109f55:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f58:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109f5c:	90                   	nop
80109f5d:	c9                   	leave  
80109f5e:	c3                   	ret    

80109f5f <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109f5f:	55                   	push   %ebp
80109f60:	89 e5                	mov    %esp,%ebp
80109f62:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109f65:	8b 45 08             	mov    0x8(%ebp),%eax
80109f68:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109f6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f6e:	83 c0 14             	add    $0x14,%eax
80109f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109f74:	83 ec 04             	sub    $0x4,%esp
80109f77:	6a 04                	push   $0x4
80109f79:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f7e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f81:	50                   	push   %eax
80109f82:	e8 4b ad ff ff       	call   80104cd2 <memmove>
80109f87:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109f8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f8d:	83 c0 0c             	add    $0xc,%eax
80109f90:	83 ec 04             	sub    $0x4,%esp
80109f93:	6a 04                	push   $0x4
80109f95:	50                   	push   %eax
80109f96:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f99:	83 c0 04             	add    $0x4,%eax
80109f9c:	50                   	push   %eax
80109f9d:	e8 30 ad ff ff       	call   80104cd2 <memmove>
80109fa2:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109fa5:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109fa9:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fb0:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109fb4:	0f b7 c0             	movzwl %ax,%eax
80109fb7:	83 ec 0c             	sub    $0xc,%esp
80109fba:	50                   	push   %eax
80109fbb:	e8 b5 f6 ff ff       	call   80109675 <N2H_ushort>
80109fc0:	83 c4 10             	add    $0x10,%esp
80109fc3:	83 e8 14             	sub    $0x14,%eax
80109fc6:	0f b7 c0             	movzwl %ax,%eax
80109fc9:	83 ec 0c             	sub    $0xc,%esp
80109fcc:	50                   	push   %eax
80109fcd:	e8 c5 f6 ff ff       	call   80109697 <H2N_ushort>
80109fd2:	83 c4 10             	add    $0x10,%esp
80109fd5:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109fd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109fe0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fe3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109fe6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109fed:	eb 33                	jmp    8010a022 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff2:	01 c0                	add    %eax,%eax
80109ff4:	89 c2                	mov    %eax,%edx
80109ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ff9:	01 d0                	add    %edx,%eax
80109ffb:	0f b6 00             	movzbl (%eax),%eax
80109ffe:	0f b6 c0             	movzbl %al,%eax
8010a001:	c1 e0 08             	shl    $0x8,%eax
8010a004:	89 c2                	mov    %eax,%edx
8010a006:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a009:	01 c0                	add    %eax,%eax
8010a00b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a00e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a011:	01 c8                	add    %ecx,%eax
8010a013:	0f b6 00             	movzbl (%eax),%eax
8010a016:	0f b6 c0             	movzbl %al,%eax
8010a019:	01 d0                	add    %edx,%eax
8010a01b:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a01e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a022:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a026:	7e c7                	jle    80109fef <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a028:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a02b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a02e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a035:	eb 33                	jmp    8010a06a <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a037:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a03a:	01 c0                	add    %eax,%eax
8010a03c:	89 c2                	mov    %eax,%edx
8010a03e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a041:	01 d0                	add    %edx,%eax
8010a043:	0f b6 00             	movzbl (%eax),%eax
8010a046:	0f b6 c0             	movzbl %al,%eax
8010a049:	c1 e0 08             	shl    $0x8,%eax
8010a04c:	89 c2                	mov    %eax,%edx
8010a04e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a051:	01 c0                	add    %eax,%eax
8010a053:	8d 48 01             	lea    0x1(%eax),%ecx
8010a056:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a059:	01 c8                	add    %ecx,%eax
8010a05b:	0f b6 00             	movzbl (%eax),%eax
8010a05e:	0f b6 c0             	movzbl %al,%eax
8010a061:	01 d0                	add    %edx,%eax
8010a063:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a066:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a06a:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a06e:	0f b7 c0             	movzwl %ax,%eax
8010a071:	83 ec 0c             	sub    $0xc,%esp
8010a074:	50                   	push   %eax
8010a075:	e8 fb f5 ff ff       	call   80109675 <N2H_ushort>
8010a07a:	83 c4 10             	add    $0x10,%esp
8010a07d:	66 d1 e8             	shr    %ax
8010a080:	0f b7 c0             	movzwl %ax,%eax
8010a083:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a086:	7c af                	jl     8010a037 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a08b:	c1 e8 10             	shr    $0x10,%eax
8010a08e:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a091:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a094:	f7 d0                	not    %eax
}
8010a096:	c9                   	leave  
8010a097:	c3                   	ret    

8010a098 <tcp_fin>:

void tcp_fin(){
8010a098:	55                   	push   %ebp
8010a099:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a09b:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
8010a0a2:	00 00 00 
}
8010a0a5:	90                   	nop
8010a0a6:	5d                   	pop    %ebp
8010a0a7:	c3                   	ret    

8010a0a8 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a0a8:	55                   	push   %ebp
8010a0a9:	89 e5                	mov    %esp,%ebp
8010a0ab:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a0ae:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0b1:	83 ec 04             	sub    $0x4,%esp
8010a0b4:	6a 00                	push   $0x0
8010a0b6:	68 eb c1 10 80       	push   $0x8010c1eb
8010a0bb:	50                   	push   %eax
8010a0bc:	e8 65 00 00 00       	call   8010a126 <http_strcpy>
8010a0c1:	83 c4 10             	add    $0x10,%esp
8010a0c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a0c7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0ca:	83 ec 04             	sub    $0x4,%esp
8010a0cd:	ff 75 f4             	push   -0xc(%ebp)
8010a0d0:	68 fe c1 10 80       	push   $0x8010c1fe
8010a0d5:	50                   	push   %eax
8010a0d6:	e8 4b 00 00 00       	call   8010a126 <http_strcpy>
8010a0db:	83 c4 10             	add    $0x10,%esp
8010a0de:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a0e1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0e4:	83 ec 04             	sub    $0x4,%esp
8010a0e7:	ff 75 f4             	push   -0xc(%ebp)
8010a0ea:	68 19 c2 10 80       	push   $0x8010c219
8010a0ef:	50                   	push   %eax
8010a0f0:	e8 31 00 00 00       	call   8010a126 <http_strcpy>
8010a0f5:	83 c4 10             	add    $0x10,%esp
8010a0f8:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a0fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0fe:	83 e0 01             	and    $0x1,%eax
8010a101:	85 c0                	test   %eax,%eax
8010a103:	74 11                	je     8010a116 <http_proc+0x6e>
    char *payload = (char *)send;
8010a105:	8b 45 10             	mov    0x10(%ebp),%eax
8010a108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a10b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a10e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a111:	01 d0                	add    %edx,%eax
8010a113:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a116:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a119:	8b 45 14             	mov    0x14(%ebp),%eax
8010a11c:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a11e:	e8 75 ff ff ff       	call   8010a098 <tcp_fin>
}
8010a123:	90                   	nop
8010a124:	c9                   	leave  
8010a125:	c3                   	ret    

8010a126 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a126:	55                   	push   %ebp
8010a127:	89 e5                	mov    %esp,%ebp
8010a129:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a12c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a133:	eb 20                	jmp    8010a155 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a135:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a138:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a13b:	01 d0                	add    %edx,%eax
8010a13d:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a140:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a143:	01 ca                	add    %ecx,%edx
8010a145:	89 d1                	mov    %edx,%ecx
8010a147:	8b 55 08             	mov    0x8(%ebp),%edx
8010a14a:	01 ca                	add    %ecx,%edx
8010a14c:	0f b6 00             	movzbl (%eax),%eax
8010a14f:	88 02                	mov    %al,(%edx)
    i++;
8010a151:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a155:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a15b:	01 d0                	add    %edx,%eax
8010a15d:	0f b6 00             	movzbl (%eax),%eax
8010a160:	84 c0                	test   %al,%al
8010a162:	75 d1                	jne    8010a135 <http_strcpy+0xf>
  }
  return i;
8010a164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a167:	c9                   	leave  
8010a168:	c3                   	ret    

8010a169 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a169:	55                   	push   %ebp
8010a16a:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a16c:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
8010a173:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a176:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a17b:	c1 e8 09             	shr    $0x9,%eax
8010a17e:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
8010a183:	90                   	nop
8010a184:	5d                   	pop    %ebp
8010a185:	c3                   	ret    

8010a186 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a186:	55                   	push   %ebp
8010a187:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a189:	90                   	nop
8010a18a:	5d                   	pop    %ebp
8010a18b:	c3                   	ret    

8010a18c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a18c:	55                   	push   %ebp
8010a18d:	89 e5                	mov    %esp,%ebp
8010a18f:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a192:	8b 45 08             	mov    0x8(%ebp),%eax
8010a195:	83 c0 0c             	add    $0xc,%eax
8010a198:	83 ec 0c             	sub    $0xc,%esp
8010a19b:	50                   	push   %eax
8010a19c:	e8 6b a7 ff ff       	call   8010490c <holdingsleep>
8010a1a1:	83 c4 10             	add    $0x10,%esp
8010a1a4:	85 c0                	test   %eax,%eax
8010a1a6:	75 0d                	jne    8010a1b5 <iderw+0x29>
    panic("iderw: buf not locked");
8010a1a8:	83 ec 0c             	sub    $0xc,%esp
8010a1ab:	68 2a c2 10 80       	push   $0x8010c22a
8010a1b0:	e8 f4 63 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a1b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1b8:	8b 00                	mov    (%eax),%eax
8010a1ba:	83 e0 06             	and    $0x6,%eax
8010a1bd:	83 f8 02             	cmp    $0x2,%eax
8010a1c0:	75 0d                	jne    8010a1cf <iderw+0x43>
    panic("iderw: nothing to do");
8010a1c2:	83 ec 0c             	sub    $0xc,%esp
8010a1c5:	68 40 c2 10 80       	push   $0x8010c240
8010a1ca:	e8 da 63 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a1cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1d2:	8b 40 04             	mov    0x4(%eax),%eax
8010a1d5:	83 f8 01             	cmp    $0x1,%eax
8010a1d8:	74 0d                	je     8010a1e7 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a1da:	83 ec 0c             	sub    $0xc,%esp
8010a1dd:	68 55 c2 10 80       	push   $0x8010c255
8010a1e2:	e8 c2 63 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a1e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ea:	8b 40 08             	mov    0x8(%eax),%eax
8010a1ed:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
8010a1f3:	39 d0                	cmp    %edx,%eax
8010a1f5:	72 0d                	jb     8010a204 <iderw+0x78>
    panic("iderw: block out of range");
8010a1f7:	83 ec 0c             	sub    $0xc,%esp
8010a1fa:	68 73 c2 10 80       	push   $0x8010c273
8010a1ff:	e8 a5 63 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a204:	8b 15 70 70 19 80    	mov    0x80197070,%edx
8010a20a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a20d:	8b 40 08             	mov    0x8(%eax),%eax
8010a210:	c1 e0 09             	shl    $0x9,%eax
8010a213:	01 d0                	add    %edx,%eax
8010a215:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a218:	8b 45 08             	mov    0x8(%ebp),%eax
8010a21b:	8b 00                	mov    (%eax),%eax
8010a21d:	83 e0 04             	and    $0x4,%eax
8010a220:	85 c0                	test   %eax,%eax
8010a222:	74 2b                	je     8010a24f <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a224:	8b 45 08             	mov    0x8(%ebp),%eax
8010a227:	8b 00                	mov    (%eax),%eax
8010a229:	83 e0 fb             	and    $0xfffffffb,%eax
8010a22c:	89 c2                	mov    %eax,%edx
8010a22e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a231:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a233:	8b 45 08             	mov    0x8(%ebp),%eax
8010a236:	83 c0 5c             	add    $0x5c,%eax
8010a239:	83 ec 04             	sub    $0x4,%esp
8010a23c:	68 00 02 00 00       	push   $0x200
8010a241:	50                   	push   %eax
8010a242:	ff 75 f4             	push   -0xc(%ebp)
8010a245:	e8 88 aa ff ff       	call   80104cd2 <memmove>
8010a24a:	83 c4 10             	add    $0x10,%esp
8010a24d:	eb 1a                	jmp    8010a269 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a24f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a252:	83 c0 5c             	add    $0x5c,%eax
8010a255:	83 ec 04             	sub    $0x4,%esp
8010a258:	68 00 02 00 00       	push   $0x200
8010a25d:	ff 75 f4             	push   -0xc(%ebp)
8010a260:	50                   	push   %eax
8010a261:	e8 6c aa ff ff       	call   80104cd2 <memmove>
8010a266:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a269:	8b 45 08             	mov    0x8(%ebp),%eax
8010a26c:	8b 00                	mov    (%eax),%eax
8010a26e:	83 c8 02             	or     $0x2,%eax
8010a271:	89 c2                	mov    %eax,%edx
8010a273:	8b 45 08             	mov    0x8(%ebp),%eax
8010a276:	89 10                	mov    %edx,(%eax)
}
8010a278:	90                   	nop
8010a279:	c9                   	leave  
8010a27a:	c3                   	ret    
