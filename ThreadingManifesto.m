/* ThreadingManifesto.m, the Libdispatch port for iOS client,   tarynv 28/02/2012

!!!: Executive summary:
All threads, muteness, timers, interlocks, etc. are being normalized under the 
umbrella of libdispatch, aka Grand Central Dispatch, which provides a highly 
efficient and unix-portable multitasking model.

!!!: Justification:
The iOS client simultaneously uses three generations of Mac threading and 
locking and a bizarre port of Windows' critical sections and events.
      
This file is marked as a source file so XCode will generate a symbol menu for it. 
It is not included in any build target.
 
 /* ----------------------------------------------------------------------------
 !!!: --- Top Down, Tasks and Work Units --- */
 
/*
 !!!: Protecting screenGDC->theBitMap in ga_macapi.c and [session] redrawScreen()
(finished)
  ScreenGCD_dispatch_queue_name = "com.[].ScreenGCD_dispatch_queue";
  dispatch_queue_t ScreenGCD_dispatch_queue = NULL;   
 */
  // This queue is appropriate for any dubious access to screenGCD. replacing 
  // and extending GA_MacAPI_Lock()
  //OTOH, it looks like there are many other GDCs created, they probably
  // need not be manipulated through blocks passed to ScreenGCD_dispatch_queue

/*
 !!!: Queuing Keystrokes 
  (finished)
See SessionUserActionQueue.h,m, a dispatch queue for user input
that needs to be sent to the host and (possibly) acted on locally.
Since we may need to use this functionality from the engine,
All SessionUserActionQueue APIs are plain C.
*/

/*
 !!!: Queuing Engine actions versus queueing main thread actions:
  (finished)
The existing code seems to have these two snarled up, 

See EngineMessageQueue.h,m which implements a dispatch queue for those 
tasks that were once guarded by Mac_Threads_ClaimSharedMutex
All EngineMessageQueue APIs are plain C, for use by both engine and UI.

For Mac_TWIRestoreAndSetFocus() and similar we might want to queue:
    TWIAddPacket()
*/


/*
 !!!: Queuing  on EngineMessageQueue:
 */

#import "EngineMessageQueue.h"


// Boilerplate for first passes:
// The typo in dispatch_a_sync() is to force me to select the right call

#if USE_EngineMessageQueue
dispatch_a_sync(GetEngineMessage_dispatch_queue(), ^{
    []
    // closure block needed
}); // ends dispatch block

#else // !USE_EngineMessageQueue

#warning This is deprecated code, remove the test and else clause soon after July 2012
#endif //USE_EngineMessageQueue

#warning Dangling memory management TODO task.

#warning this message and any like it should be sent by the session manager

#warning this function should be void, should make a dispatch_async call, and the session manager should be sending new state to the host on change.

#warning Misuse of what should probably be a singleton instance.

#warning Functions named Get<something> should not be void.
#warning Functions named Get<something> should return what they get.
#warning C callable engine-to-class functions like this belong in the class's .m file(s)
#warning This method is sending messages that probably belong on main queue 
#warning This function violates naming conventions and overlaps a method name.

// macro to emit function name and useful trivia: 
SHOWqueueAndThread


/*
 !!!: Queuing selectors on main thread:
 Replacing performSelectorOnMainThread:...waitUntilDone:...)
 */

/*
 !!!: Tossing dictionary complexity by replacing performSelectorOnMainThread
 A lot of methods receive dictionary parameters simply because they need to run on main thread
 the creating, packing, and unpacking of these dictionaries can often be replaced with
 dispatch_sync(dispatch_get_main_queue) (or dispatch_async) to a simplified method.
 */


// Boilerplate for first passes:
// The typo in dispatch_a_sync() is to force me to select the right call

#if USE_MainThreadQueue
dispatch_a_sync(dispatch_get_main_queue(),^{ 
    // TODO: Replace the dictionary argument with a simplified method implementation
    [];
});

#else // !USE_MainThreadQueue
#warning This is deprecated code, remove the test and else clause soon after July 2012

#endif // !USE_MainThreadQueue



 /* ----------------------------------------------------------------------------
 !!!: --- Bottom Up, focusing on existing functions and data: --- */

/* ----------------------------------------------------------------------------
!!!: Organization:
These are working notes, so they tend to be messy, but generally they are organized 
into either call stacks or simple dependency graphs like this:

a_headerfile:       // counterpart or associated file to service_file
service_file:       // a file that we expect to discard, replace, or rewrite.
// state of the file, e.g. finished work, stubbed, under repair, etc.
struct_in_service_file // defs or declarations of interest
func_in_service_file() // note on function's usage, intent, etc.
using_file           // file(s) that are dependent on func_in_service_file()
using_func()       // function(s) in using_file dependent on func_in_service_file()
...
...
...
Other working notes for service_file      

 main queue 
 
private queue -> run loop ->  
 
 queue priorities 
 
 serial queues will be assigned thread by gcd
 
 
 /* ----------------------------------------------------------------------------
 !!!: Threads created or extant in the client */

-------------------------
_Ae_Trace_FlushMonitor();


---------------------
CGPReconnectThread();


--------------------------
Thrd_givePrimaryControl(); (EngMessageLoop) "EngMessageLoopThread"

Constantly computes time deltas for counting down pending events.
Then loops through pending events and fires any that have timed out or triggered.

Task: Identify all subscribers to this loop mechanism and resubscribe them to something less baroque.
The only direct subscriber for these events (via Thrd_addObject()) is 
Tmr_create(), but it has a fair number of subscribers itself. 
The only real problem with these "PAL"s is that they are so abstracted 
that they do not fit well in any platform but Windows. and have accreted many layers.

On iOS, all one should have to do in Tmr_create() is 
dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,...) 
dispatch_source_set_timer() 
dispatch_resume() // timers are created suspended.
and possibly add events to some of the many internal lists. 

Having fixed up the timers, Thrd_givePrimaryControl() need do nothing. 


// TVW: Fully deprecated May 2012, replaced with blocks using engine and/or main queues
// Mac_Threads_ClaimSharedMutex()



srvICAEngMessageLoop(); 
  only called by EngMessageLoop(),
    only called by fnNCSPollThread()
      created as: gTIDNCSPollThread = Mac_Threads_NewThread() in NCSPollInit() 
        only called by NCSbind_finish()
          only called by NCS_Load()



---------------------
ReceiverMainThread(); (main)


-------------------
beginTransaction(); (SmartCardThread)  


-----------------
_Td_recvThread(); (RecvSocketThread)

 
 
 
/* ----------------------------------------------------------------------------
 !!!: Relevant constants */

SUPPORTTHREADS  // undefined, used in these few files to disable CriticalSections:
  ctxlist.h
  list.c
  // Deleted socklist.h (no users, no includers 

#define TD_USE_RECEIVE_THREAD 1   // Use a thread for TD receive, true on iOS

#define USE_LIBDISPATCH  0  // 0 = use our current disparate collection of thread intersections, mutexes, etc.
// 1 = replace mutexes, threads, locks, etc with Grand Central Dispatch

MAC_CONNECT_THREADED // undefined, used in winsock.c to disable NCS_EventLoopWithTask() 
  Set only on OSX builds, not in iOS. 
 
#define CGP_UNIX  // from CgpPlatform.h, true for iOS via macintosh define

SHARED_SESSION_VIDEO_BUFFER  // always undefined in iOS

 
/* ----------------------------------------------------------------------------
 !!!: Client locking structures, cases: */

cdmserv: 
  _LockRequest;    // A red herring? Only relevant to host file locking?

cgp.c: 
  InterlockedExchange();   // Used to invalidate a socket?
    // uses OSAtomicCompareAndSwap32();

engtypes.h: 
  WFEENGINFO.cbMutexName  // never used
  
Api_Util.h
  MINILOCKENTER(pLock);
  MINILOCKLEAVE(pLock);   // __sync_fetch_and_and((pLock), 0)
  
-----------
ga_macapi.c                  // macintosh specific graphics APIs
  // removed   static pthread_mutex_t m_gdcMutex = PTHREAD_MUTEX_INITIALIZER;
  // removed   GA_MacAPI_Lock(void);
  // removed    GA_MacAPI_LockWindowContentsUsingTimer
  // removed   GA_MacAPI_Unlock(void);
  // deleted, no users: GA_MacAPI_LockWindowContentsForReason()
  GA_MacAPI_InitialiseGDC();
  Users:
    // switched to dispatch ICASessionInputView redrawScreen()
  

/* ----------------------------------------------------------------------------
!!!: Direct users of pthreads: */

---------
AeTrace.c          
  struct _CRITICAL_SECTION;   // wraps a pthread_mutex along with a few flags
                             // Yep, just like ctxsync, God forbid anyone
                             // ever fixes or cleans out existing code! 

    // leaving AETRACE 'till last since its pthreads are entirely self-contained.

------
cgp.c (CGP_UNIX),  CGPReconnectThread(); "CGPReconnectThread"



-------------------------
EngineKbmInterfaceImpl.mm, threadFunction(); "EngineKbmInterfaceImplThread"



----------
proxwrap.c
  static pthread_mutex_t g_SocketListMutex = PTHREAD_MUTEX_INITIALIZER;
  ProxySocketAdd();  lock and unlock g_SocketListMutex
  ProxySocketFind()  '' ''
  ProxySocketRemove()  '' ''
 
----------   
scacdcom.c      // smartcards 
  SCA_BeginTransaction();
    pthread_t	btThrd;
    
------
sens.c           // sensors?  
  static pthread_mutex_t sens_mutex = PTHREAD_MUTEX_INITIALIZER;
  SensSendPacket();
    pthread_mutex_lock(&sens_mutex);
    pthread_mutex_unlock(&sens_mutex);
  // Kind of suspect, since sens_mutex is only used by the one function 
  // and is of normal type. Is this a potential deadlock?

---------
tdwsock.h            // Circular receive queue of incoming packets with timestamps
  struct _PDWS       // if TDICA_USE_RECEIVE_THREAD  
    ...
    pthread_t recvThread;                /**< Handle to receive thread */
    pthread_mutex_t recvThreadMutex;
    pthread_cond_t recvThreadCondVar;
    BOOL bTerminateRecvThread;
    TD_RECVQUEUE RecvQueue;
      All only used by tdthread.c, except that tdwinsock.c passes a ref to RecvQueue

----------
tdthread.c        // Misnamed, provides Transport Driver threaded queue services. 
  // Pretty clean implementation, we can probably leave this alone unless
  // we actually rewrite Transport Drivers to couple closely with iOS. 
  // thread name: "RecvSocketThread" 
  // thread loop: _Td_recvThread()
  void _Td_destroyRecvThread(PPDWS pPdWS);
  BOOL _Td_initRecvThread(PPDWS pPdWS);
  int  _Td_getRecvPacket(PTD_RECVQUEUE pQ, BYTE **ppBuf, int *pError);
  void _Td_releaseRecvBuffer(PPDWS pPdWS);
  UINT32 _Td_getRecvPacketTime(PTD_RECVQUEUE pQ);
    users tdwinsock, tdwsock, wdinput, tdrwdef

    


/* ----------------------------------------------------------------------------
!!!: Providers of thread, mutex and timer abstractions using pthreads directly: */

---------
ctxsync.h      
mac_ctxsync.c:            // Cobbled together critical section handler 
  struct _CriticalSection // wraps a pthread_mutex along with a few flags 
  
  Sync_create();           // creates and inits a CriticalSection instance
  Sync_destroy();          //  discards         '' ''  ''
    audhal.c
      HALaudHWModuleOpen(); // gDevice.hAQCriticalSection & gDevice.hSDCCriticalSection
      HALaudHWModuleClose();
    cgp.c 
      CGPConfigure();      // g_CloseLock created, but never destroyed, maybe ok.
    ctxtmr.c 
      Tmr_create();        // g_hTmrThrdListSync, _TMRTOBJECT(s).hTmrSync
      Tmr_destroy();
      
  Sync_enterCriticalSection(); 
  Sync_leaveCriticalSection();
    audhal.c
      _LockRelayQueue();     // gDevice.hAQCriticalSection
      _UnlockRelayQueue();
      _LockConverter();      // gDevice.hSDCCriticalSection
      _UnlockConverter();
      
    cgp.c                   // only to avoid a race that will never occur with libdispatch
      CGPclosesocket()      // g_CloseLock 
 
    ctxtmr.c
      The stuff is everywhere in ctxtmr, way too baroque!

----------
syncload.c      // Deleted
  Sync_load(); Sync_unload(); // Deleted
    vpapi.c    // no longer calls



-------------    
mac_threads.h
mac_threads.c
//  All code dependent on MAC_POSIX_THREADING_DISABLED has been removed, 4/2012

  For whatever reason, MAC_POSIX_THREADING_DISABLED was enabled (more double negation!),
  so sCooperativeMutex in these files wasn't used, but there are still these two:
  static pthread_mutex_t sPollingThreadMutex;
  static pthread_t sPollingThreadMutexOwner;
  On iOS, this is mostly useless, since it assumes a yielding model from the Mac of 80's.

  Mac_Threads_Init_PollingThreadMutex();  // readies sPollingThreadMutex
  Mac_ThreadsSaveMainThreadID();          // loads sMainThreadRef
    main.m
      MainEnterMultithreadingMode() // 

  // Deleted   Mac_Threads_Initialise();  // mostly pointless
  // Deleted   Mac_Threads_Shutdown();    // Completely unused
  // Deleted   Mac_Threads_GetCurrentThread(); // replaced with pthread_self()
  // Deleted   Mac_Threads_RunInMainThread();  // Completely unused in iOS client


    Mac_Threads_GetMainThread(void); // returns sMainThreadRef
      mac_ctxthrd.c  // may be entirely pointless, always using main thread.
      wengine.c      // For starting and stopping polling.
    
       
    sCooperativeThreadFunction();
      // passed as a callback pointer argument to Mac_Threads_NewThread()  
        
    Mac_Threads_NewThread();   // even with MAC_POSIX_THREADING_DISABLED, creates pthreads!
      mac_ctxthrd.c            // pointless? creates a context, but always using main thread.
      mac_NCS_Events.c         // NCSPollInit() sets up thread for server communication 
      
    Mac_Threads_Yield();
      mac_NCS_Clipboard.c       // 
        WaitForClipboardData();
      mac_NCS_init.c            // 
        myIdleEventTimerProc() & PlatAppMainRun()
      mac_osdelay.c             // 
        Os_Delay();
      mac_pal.c                 // 
        PALYield(); 
      wdbuffer.c                //
        SendSomeData(); (twice)
      wengine.c                 // 
        RequestStopPolling(); & AllowStopPolling();

// TVW: Fully deprecated May 2012: Mac_Threads_ClaimSharedMutex(); // to write data for main thread?
      ICAEngineBridge.m     // 
        Mac_TWIRestoreAndSetFocus();

        see P4 193742 changes re deadlock 


      mac_appinterface.m   
        // many suspect calls release, performSelectorOnMainThread, then claim again.
      mac_ctxthrd.c       // 
        Thrd_givePrimaryControl();
      mac_palkeyboard.c  //  
        PALKbd_ProcessKeyDown();
      mac_palmouse.c    //  
        PAL_HandleMouseWheelEvent(); PAL_HandleMouseDownEvent();
        PAL_HandleMouseUpEvent(); PALMouseButton();
      SessionSharing.c // 
        ConsiderSessionSharing(); 
        SharingRequestHandler();
      
// TVW: Fully deprecated May 2012:  Mac_Threads_ReleaseSharedMutex();
      Generally to match Mac_Threads_ClaimSharedMutex();
      NOTE! mac_appinterface.m does them all 'backwards': Release, performSelectorOnMainThread, Claim.


/* -----------------------------------------------------------
!!!: Doubly abstracted, a thread abstractions which uses Mac_Threads! */

-------------
ctxthrd.h
mac_ctxthrd.c
  void* g_hPrimaryThread;   // pointless? holds a list of 'thread objects'
  g_sThrdCallTable      

  Thrd_load();                   // usual call table foolishness
  Thrd_unload();                 //  ''        ''     ''  '' VpAppUnload()
    icaload.c 
      VpAppLoad();
      VpAppUnload();
 
  Thrd_create(UINT32,PHND);     // only called by Thrd_load()!
    // now local to ctxthrd.c 
  Thrd_destroy(HND);            //  ''    ''   '' Thrd_unload()
    // now local to ctxthrd.c 

  Thrd_givePrimaryControl(void); 
  Thrd_killPrimaryControl(void);              
    vpflow.c  
      Vp_begin()
      Vp_end()

  Thrd_signal(HND);
    ctxtmr.c:   
      Tmr_setEnabled(); 
      Tmr_setPeriod(); 
      Tmr_destroy();

  Thrd_addObject(HND,HTOBJECT);
    ctxtmr.c:   
      Tmr_create();

  Thrd_removeObject(HND,HTOBJECT);
    ctxtmr.c:   
      Tmr_destroy();






/* ----------------------------------------------------------------------------
 !!!: Providers of timer and event abstractions */

------------
mac_timers.h
mac_timers.m  // abstraction for main thread called timers 

  Tmr_unload();

  Tmr_create();
  Tmr_setEnabled();
  Tmr_setPeriod();
  Tmr_setUserData();
  Tmr_getUserData();
  Tmr_destroy();


--------
// Deleted ctxevt.h
// Deleted ctxevt.c
  // deleted, never used: Evt_create();
  // deleted, never used: Evt_destroy();
  // deleted, never used: Evt_signal();

// Deleted evtload.c // all of these <mumble>load.c files are to be tossed   
  // deleted Evt_Load();    
  // deleted Evt_Unload();








  
   
    

 
/* -----------------------------------------------------------------------
!!!: Indirect Users of threads and mutexes, that depend upon the files above */
  

vpflow.c
    Vp_begin() // alias for Thrd_givePrimaryControl()
      wengine.c:   srvICAEngMessageLoop()
    
    Vp_yield(); // a no-op
    Vp_end();  // alias for Thrd_killPrimaryControl()

      
    

/* ----------------------------------------------------------------------
!!!: A few files include pthread.h, or reference pthreads, 
 but only use them in other clients: */
winsock.c (MAC_CONNECT_THREADED)


//!!!: Existing threads:
  UIKit's main thread
    .c: dispatch_get_main_queue()
    .m 



INT32 PlatAppMainStart (HND hVp)
{
/* Startup virtual platform */
SDK_mainstart ();
InstallIdleEventTimer (kIdleEventTime);
InstallScreenRedrawTimer (kScreenRedrawTime);
}


---------------------
ApplicationDelegate.m           // We've some work to do on background tasks see:
  applicationWillResignActive();  
  applicationDidEnterBackground();
  sendLocalNotificationForSessionTermination(); 
  
    

...[redacted a bunch of stack traces]...


// Boilerplate

#define DUMPQUEUEandTHREADtrivia 1 // 0 to turn off chatter
#if DUMPQUEUEandTHREADtrivia
#define SHOWqueueAndThread { char tn[40] = "unknown"; pthread_getname_np(pthread_self,tn,40); fprintf(stderr, "%s, thread:%s, queue:%s\n",__FUNCTION__,tn,dispatch_queue_get_label(dispatch_get_current_queue())); }
#else
#define SHOWqueueAndThread {}
#endif
SHOWqueueAndThread;

#if iOShasMenusAndWindowsPigsWillFly
#endif // iOShasMenusAndWindowsPigsWillFly

#if AnyClientCodeActuallyUsesInterlocks
// TVW, revisit to remove
SHOW("%s is deprecated; put a breakpoint in it to identify and update callers\n", __func__);
#endif

#if USING_LIBDISPATCH
#else  // not USING_LIBDISPATCH
#endif // USING_LIBDISPATCH


SHOW("%s is deprecated; put a breakpoint in it to identify and update callers\n", __func__);

CAUTION! this source file is included in other files. // throw compilation error.

#if SUPPORT_CALL_TABLES  // Never true on iOS client
#endif // SUPPORT_CALL_TABLES


#if PointlesslyObfuscateCode

#if CobbledUpLateBindingHacksInApp
#endif // #if CobbledUpLateBindingHacksInApp

#if CompileUnusedFunctions
#endif // CompileUnusedFunctions

// Testing for thread correctness:
NSAssert([NSThread isMainThread], @"UI update not running on main thread");
assert([NSThread isMainThread]); // call on main


// !!!: References and hints:


int		pthread_getname_np(pthread_t,char*,size_t) __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_2);
pthread_t pthread_self(void);

const char * dispatch_queue_get_label(dispatch_queue_t queue);
const char * dispatch_get_current_queue(void)


Migration guide:
http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/ThreadMigration/ThreadMigration.html#//apple_ref/doc/uid/TP40008091-CH105-SW1

Dispatch queues:
http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1 

// !!!: dispatch and callback.
dispatch_async(queue, ^{
    NSArray *results = ComputeBigKnarlyThingThatWouldBlockForAWhile();
    
    // tell the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        ProcessResults(results);
    });
});

// !!!: Run loop modes:
http://stackoverflow.com/questions/7222449/nsdefaultrunloopmode-vs-nsrunloopcommonmodes
"Usually all run loop are set to the "default mode" which establishes a default way to manage input events. As soon as some mouse-dragging (Mac OS) or touch (on iOS) event happens then the mode for this run loop is set to event tracking: this means that the thread will not be woke up on new network events but these events will be delivered later when the user input event terminates and the run loop set to default mode again: obviously this is a choice made by the OS architects to give priority to user events instead of background events."

http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html


xcode4:
http://www.scribd.com/doc/64267908/Xcode-4

Useful note on rendering thread safe:
http://www.cocoanetics.com/2010/07/drawing-on-uiimages/

properties:
http://www.iphonedevsdk.com/forum/iphone-sdk-tutorials/26587-slicks-definitive-guide-properties.html

Maps Designpatterns to Cocoa/NextStep (which came before the book, but had most already :)
http://cocoadev.com/wiki/DesignPattern


