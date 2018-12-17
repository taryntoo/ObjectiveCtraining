/* KeystrokeManifesto.m, keystrole rationalization for iOS,   tarynv05/05/2012

!!!: Executive summary:
 Normalize keystroke handling in iOS

!!!: Justification:
Every keystroke blocks main and engine threads. causes thousands of cycles,  hundreds of decisions and forces the entire screen to redraw at some color depths.

This file is marked as a source file so XCode will generate a symbol menu for it. 
It is not included in any build target.
 
 USE_SessionUserActionQueue is now always assumed to be true and has been removed
 
 
 /* ----------------------------------------------------------------------------
 !!!: Top Down, Tasks and Work Units  */

// fully deprecated and removed: 
EngineKbmInterface.h, .mm
EngineKbmInterfaceImpl.h, .mm
// Sadly hilarious, babbling about the command pattern while stuffing
// in some exceptionally silly cpp bits.


// the only kbd code that does anything useful from EngineKbmInterface is in 
EngineKbQueueItem  - (void) execute
{  ...
        if (modifierChar)     PALKbdSendUnicodeKey(myWnd, modifierChar, TRUE, SPECIALKEY);
        if (modifierChar2)    PALKbdSendUnicodeKey(myWnd, modifierChar2, TRUE, SPECIALKEY);
        if (myChar || myScanCode) {
            PALKbd_ProcessKeyDown(myWnd, myChar, myScanCode, myModifiers);
            PALKbd_MatchingKeyUp(myWnd);
        }
        if (modifierChar2)   PALKbdSendUnicodeKey(myWnd, modifierChar2, FALSE, SPECIALKEY);
        if (modifierChar)    PALKbdSendUnicodeKey(myWnd, modifierChar, FALSE, SPECIALKEY);
... } // ends EngineKbQueueItem execute
  
Keystroke Actions currently invoked: 

//We'll dance through this up to four times if there are modifier chars:
  PALKbdSendUnicodeKey() // mumbles about with flags and may call:
    PALEvtUnicodeCode()  // packs up keystroke into a WND_UNICODEINFO, calls 
        WindowDeliver()  // (via pWnd->pfnDeliver) unpacks keystroke, calls one of:

          wdCharCode()   // packs up keystrokes into a CHARCODE, calls WdSetInformation()
       or []ProcessScancodeEvent() // pointless, just calls
            wdScanCode() // packs scancode into a SCANCODE, calls WdSetInformation()

// And this if we have a key:
  PALKbd_ProcessKeyDown()  // immediately calls 
    PALKbd_MatchingKeyUp() // then sets a lot of statics, see sGotKeydown, etc.

    Mac_Threads_ClaimSharedMutex() 
    PALKbd_ProcessKey()    // does nothing unless PALKbdKeyboardIsUnicode(), then
      PALKbdUnicodeKey()   // a stupifying dance with modifiers 
        PALKbdSendUnicodeKey() // as above, for modifiers.
    
 

Here's the notes from void PALKbd_MatchingKeyUp (PWND pWnd) {
if (sGotKeydown) {
// A keydown has been previously sent without a matching keyup: Call PALKbd_ProcessKey to
// send the keyup, with the same unicode, scancode and modifiers that were sent in the keyup
// event. There is one problem: If the set of modifiers has changed since the keydown event
// has been sent, we have to send the modifiers as they were at the time of the keydown, 
// but we also need to restore the modifiers afterwards to match reality. 

I'm still wrapping my head around this, but I think the whole foolishness of the 
up/down stuff can be cleared out with a block and userActionQueue 
    
    

The only mouse code that does anything useful from the EngineKbm mess is in 
EngineMouseQueueItem  - (void) execute
{
    if (myWnd) {
        switch (myOperation) {
            case MouseDown:
                PAL_HandleMouseDownEvent(myWnd, myCursorPosition, myTime, 0, myButton);
                break;
            case MouseUp:
                PAL_HandleMouseUpEvent(myWnd, myCursorPosition, myTime, myButton);
                break;
            case MouseMoved:
                PAL_HandleMouseMovedEvent(myWnd, myCursorPosition);
                break;
            case MouseWheel:
                PAL_HandleMouseWheelEvent(myWnd, myCursorPosition, myWheelData);
                break;
            case MouseUnknown:
            default:
                DebugLog(@"%s unknown mouse operation. %d\n", __FUNCTION__, myOperation);
                NSAssert(FALSE, @"unknown mouse operation");
                break;
        }
    }  else  {
        DebugLog(@"%s cannot send mouse. Have no engine.\n", __FUNCTION__);        
    }
}

[EngineMouseQueueItem execute] calls PAL_HandleMouse<something> // GlobalPoint_To_WindowPoint() does nothing on UIKit
  Mac_Threads_ClaimSharedMutex() then:
    PALMouseButton()  // tracks doubleclicks and adds state details to mouse struct.
      PALEvtMouse() // converts from global coordinates to window
        WindowDeliver() (through pWnd->pfnDeliver )
          wdMouseData() // 



While these can be put on a dispatch queue, there's a problem deeper,
Mac_Threads_ClaimSharedMutex() is called in all these,
mac_palkeyboard.c  //  
PALKbd_ProcessKeyDown();
mac_palmouse.c    //  
PAL_HandleMouseWheelEvent(); PAL_HandleMouseDownEvent();
PAL_HandleMouseUpEvent(); PALMouseButton();

So we need to to serialize dispatch from those functions 



/* ----------------------------------------------------------------------------
 !!!: Functions being added, to vector all this stuff through */


dispatch_queue_t GetSessionUserAction_dispatch_queue(void);

DispatchUserKeyBoardActionLumpToHost(kbOperation);

void DispatchUserKeyBoardActionToHost(UniChar keyChar,   ///< to send
                                      int    scanCode,   ///< for modifier keypresses.
                                      UInt32 modifiers,  ///<  flag.
                                      uint16_t modifierChar, ///< The modifier key.
                                      uint16_t modifierChar2); ///< The second modifier key.

void DispatchUserMouseActionToHost(TBD);


// Boilerplate

#if ! USE_SessionUserActionQueue
#endif // ! USE_SessionUserActionQueue


#if USE_SessionUserActionQueue
  #import "SessionUserActionQueue.h"
#else  // ! USE_SessionUserActionQueue
#endif // USE_SessionUserActionQueue


#if USE_SessionUserActionQueue
dispatch_queue_t userActionQueue = GetSessionUserAction_dispatch_queue();
assert(0); // TODO: put an action on the queue



#pragma error ObfuscatedCodeIsPermittedToRemain
#if ObfuscatedCodeIsPermittedToRemain
#endif // ObfuscatedCodeIsPermittedToRemain


    
 /* ----------------------------------------------------------------------------
 !!!: Bottom Up, focusing on existing functions and data: */

[kbmInterface issueRequestToPal]

ICASessionInputView sendMouseEvent:

// Fix the weirdness that is KeyboardActions.h
// Later, chase down and discard all instances of:
EngineKbQueueItem
EngineKbmQueueItem
EngineMouseQueueItem 

Mac_Threads_ClaimSharedMutex
mac_palkeyboard.c  //  
PALKbd_ProcessKeyDown();
mac_palmouse.c    //  
PAL_HandleMouseWheelEvent(); PAL_HandleMouseDownEvent();
PAL_HandleMouseUpEvent(); PALMouseButton();



On ReceiverMainThread: Queue : com.apple.main-thread

  [[]SessionInputView sendMouseEvent:]
    [EngineKbmInterfaceImpl issueRequestToPal:] // does a weird dance with myKeepThreadGoing && myLock 
      calls myItemQueue.push_back(copiedItem); // yes, pointless use of STL
      ...
and finally
   [[]SessionInputView redrawScreen]
then goes on its way.


On EngineKbmInterfaceImplThread:
  [EngineKbmInterfaceImpl threadFunction] pulls item from deque, then calls item execute

    [EngineMouseQueueItem execute] calls PAL_HandleMouse<something> // GlobalPoint_To_WindowPoint() does nothing on UIKit
      which calls Mac_Threads_ClaimSharedMutex() then:
        calls PALMouseButton()  // tracks doubleclicks and adds state details to mouse struct.
          calls PALEvtMouse() // converts from global coordinates to window
            calls WindowDeliver() (through pWnd->pfnDeliver )
              calls wdMouseData() // 


or a similar mess with

   [EngineKbQueueItem execute] calls PALKbdSendUnicodeKey 

Surprisingly this propagates all the way down to the socket in EngineKbmInterfaceImplThread:

...[redacted stack trace]...




@interface EngineMouseQueueItem : EngineKbmQueueItem <NSCopying>
{
    MouseOperation myOperation;     // What is being done.
    Point myCursorPosition;         // Where
    double myTime;                  // How long.
    int myButton;                   // Which button.
    int myWheelData;                // Wheel information.
}


* EngineKbmInterfaceImpl.h
* This is the implementation class to the PAL for keyboard and mouse events.
* It provides a queue and issues events to the PAL in a separate thread, so
* that the on screen keyboard won't lag.
*/
#import <Foundation/Foundation.h>
#import <deque>
extern "C"
{
#import <Mac_Threads.h>
}


@class EngineKbmQueueItem;
typedef std::deque<EngineKbmQueueItem *> ItemQueue;
@interface EngineKbmInterfaceImpl : NSObject





* EngineKbmInterface.h
* This is the interface to the PAL for keyboard and mouse events.
* It provides a queue and issues events to the PAL in a separate thread, so
* that the on screen keyboard won't lag.


* insert a new keystroke or mouse operation into the queue to  send to the PAL.
* Once the item has been added, the request is sent asynchronously.
- (bool) issueRequestToPal:(EngineKbmQueueItem *) item;


EngineKbQueueItem(s) are used/created by 
SessionKeyboardManager imeDoneButtonAction



     [EngineKbQueueItem execute] calls PALKbdSendUnicodeKey 



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
*/
 
       
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

    Mac_Threads_ClaimSharedMutex(); // to write data for main thread?
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
      
    Mac_Threads_ReleaseSharedMutex();
      Generally to match Mac_Threads_ClaimSharedMutex();
      NOTE! mac_appinterface.m does them all 'backwards': Release, performSelectorOnMainThread, Claim.




