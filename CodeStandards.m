/*  CodeStandards.m   Created by taryn on 8/3/11. */

/* This document pertains specifically to work on iOS and OSX platforms,
   describing best practices and requirements for projects targeting them.
   Each rule is preceeded with 'TODO' to force an entry in xCode's file xrefs,
   allowing quick searching for a particular rule.
 */


/* TODO: Languages permitted in Xcode projects:
    a: C99
    b: Objective C
    c: bash shell scripts.
 Do not introduce other variants without explicit permission from project 
 leads and an overwhelming need. (Finding some cpp code that does what 
 you want does NOT constitute an overwhelming need.)
 */


/* TODO: Don't abstract a standard abstraction.
    POSIX is our Platform Abstraction Layer for C code. 
    Cocoa and UIKit are our abstraction layers for ObjC code.
    There is no abstraction layer for cpp code because it is not permitted in our apps.
 
 Do not add abstraction layers over these; remove such layers wherever you find them. 
 DO not create definitions like STATIC static, or INT32 int32_t! Remove them as you find them.
 */

/* TODO: Don't invent malloc abstractions, memory managers, queues, threads, mutexes, lists, or Windows APIs.
  .c files should only use these memory functions:
    malloc(size_t size);
    calloc(size_t count, size_t size);
    realloc(void* original, size_t newsize);
    free(void* mem);
*/


/* TODO: Strip absurd legacy constructs vigorously.
 Thank God that you'll never have to work with another architecture that uses near and 
 far pointers or segmented addresses, and  get that crap out of the code!
 
 Again, DO not create definitions like STATIC static, or INT32 int32_t! Remove them as you find them.
 
 Exception: Code in PlatformIndependent folders should be left as is unless it's obviously not
 "PlatformIndependent", or you're fixing bugs in it, or it's so baroque as to be unmaintainable.
 */


/* TODO: Don't duplicate code.
 When you see two or more functions with almost identical code, you are seeing
 evidence of laziness and plagiarism. When you duplicate a function and make minor
 changes to it without considering how to improve both original and copy, you are
 a cheat, and are abdicating your responsibilities as a designer and programmer.
 
 Identify the common elements in the several functions and either refactor them into
 subroutines, or reconsider the intent of the functions and refactor the functions themselves.
 */ 


/* TODO: Prefer #import over #include 
 While most c headers contain include guards, e.g. */
#ifndef _LOGMAP_H
#define _LOGMAP_H
...
...
#endif	/* _LOGMAP_H */
/* ObjC headers by tradition do not, and you MUST use #import for them.
 Because #import allows the compiler to not reopen and scan the header, there will be a slight
 improvement in build times. There is no downside to using #import for almost all headers, and 
 the include guard cruft isn't needed.
 
 Exception: Some optimally obfuscated work uses stupid code tricks like redefining a macro
 (see STATIC) before opening a header file, in order to change the scope or intent of declarations
 and such. Those header files cannot use include guards, and if they are #imported instead of 
 #included, their fragile behavior will break. This is truly lame, a too-clever-by-half technique
 that should be cleaned away with all possible haste.
 */
 
 
/* TODO: Minimize and normalize #include and #import usage. 
 When a pair (or more) of header files are explicitely codependent, and will always be included 
 together when used properly, either merge them into one file, or include one in the other, as
 appropriate. Then sweep the codebase to remove any redundant includes of the pairs. 
*/ 
 #if MaximiseIncludeObfuscation
   #include "logapi.h"     // requires and includes logflags.h
   #include "logflags.h"   // contains constants required by logapi.h
 #else 
   #import "logapi.h"      //requires and includes logflags.h
 #endif

/* 

/* TODO: Minimize redundant and forward declarations.
 Organize files so that functions and symbols need only be declared where they are defined.
 
 Some claim that this 'bottom up' style is harder to read, but in any tradeoff between simplicity 
 and complexity, the simpler is easier to read and maintain. Your code editor already knows how to 
 dynamically create shortcuts to declarations and definitions, having both in the file simply makes
 it harder to find the actual definition.
 */ 


/* TODO: Prefer clarity over portability.

    Accept that portability is an ideal, but generally a useless fiction. Use
    the platform capabilities to simplify and optimize. Strip away useless indirection.
 */


/* TODO: No boxes of asterisks.
 ******************
 * this is just   *
 * visual clutter *
 ******************
 */


/* TODO: No magic numbers or strings.
    Never use values directly in code. If possible enumerate them with meaningful 
    names or it they cannot be enumerated (e.g. fractions) define them.
 */


/* TODO: Prefer inlined code over macros.
    Macros break type checking, are error prone, and simply ugly.
 */
   
/* TODO: ObjC and XCode use 1TBS, use it yourself and don't try to "fix" it.
    All templates that XCode generates, and almost all existing Objective C code uses
    the vertically compact "One True Brace Style" (K&R). The fact that you grew fond of some
    other style while coding in Java or C++ is irrelevant, this is a different language.
    See: "Cocoa Programming for Mac", Aaron Hillegass 
         "OBJECT-ORIENTED PROGRAMMING AND THE OBJECTIVE-C LANGUAGE", Don Larkin and Greg Wilson. NeXT
         "Cocoa Fundamentals Guide", Apple
         "Cocoa and Objective-C: Up and Running", Scott Stevenson
         "The Objective-C 2.0 Programming Language", Apple
         http://www.lysator.liu.se/c/ten-commandments.html#henry 
         

    Alternatives: 
        Those found trying to slip in any Whitesmiths, GNU, Banner, Horstmann, et al,
        will be flogged, placed in the corner, and we will all point and laugh.
        Lisp style users will be forced to parse code that has been stripped of newlines.

 */

/* TODO: Source code is not a collection of powerpoint slides, it is a technical document.
    a: No Bullets! 
    b: Put parameter comments directly in function declarations 
    c: avoid pointless comments like 'allocate memory' before a call to allocate memory.
    d: do not comment on other functions, e.g. BST_Insert() while commenting on BST_CreateNullNode()
    e: make the function declaration document itself.
    f: use only enough vertical space to separate logical blocks
    g: only closing braces and start-of-function braces belong on separate lines.
    h: if possible, comments belong on the line they are describing.

   Here we have a 20 line comment and a 43 line function replaced with 
   a 2 line comment and an 18 line function. The former is unforgivable.
   The latter can be seen is in its entirety in a small window and is far more readable.
*/
#if LardUpCodeWithWasteComments

/********************************************************************************
 * BST_CreateNullNode                                                           *
 *                                                                              *
 * Creates a BST node with a given ID and NULL child pointers.  The node can be *
 * added to a BST by calling the BST_Insert function, this is the only way that *
 * nodes should be allocated for insertion into the BST.  The function will add *
 * a BST_NODE structure to the start of the allocated memory, so the node will  *
 * be managable by the BST                                                      *
 *                                                                              *
 * Parameters                                                                   *
 *                                                                              *
 * id: Id of the node to create                                                 *
 *                                                                              *
 * sizeIncludingNodeHeader: Size required for the node.  This must be at least  *
 * sizeof(BST_NODE)                                                             *
 *                                                                              *
 * Returns                                                                      *
 *                                                                              *
 * Pointer to new node if successfuly, NULL if the function failed              *
 *******************************************************************************/
PBST_NODE
BST_CreateNullNode(
                   UINT32 id,
                   UINT32 sizeIncludingNodeHeader)
{
    UINT32      status;     /*Return status*/
    PBST_NODE   pNewNode;   /*Receives pointer to new node*/
    
    /*Check that the size is valid*/
    
    ASSERT(sizeof(BST_NODE) <= sizeIncludingNodeHeader,sizeIncludingNodeHeader);
    
    if(sizeof(BST_NODE) > sizeIncludingNodeHeader)
    {
        return NULL;
    }
    
    /*Size is good, allocate memory*/
    
    status = Mem_alloc(
                       MEM_GLOBAL_POOL,
                       sizeIncludingNodeHeader,
                       (PVOID*)&pNewNode);
    
    ASSERT(MEM_SUCCESS == status,status);
    
    if(MEM_SUCCESS != status)
    {
        /*Memory allocation error*/
        
        return NULL;
    }
    
    /*Setup the new node*/
    
    pNewNode->Id     = id;
    pNewNode->pLeft  = NULL;
    pNewNode->pRight = NULL;
    
    /*Return pointer to new node*/
    
    return pNewNode;
}

#else   // don't LardUpCodeWithWasteComments  

/** brief Create a BST node with a given ID and NULL child pointers.
    Returns pointer to new node if success or NULL if bad parm or no mem 
*/
PBST_NODE BST_CreateNullNode(UINT32 id,                         // Id to assign to the new node    
                             UINT32 sizeIncludingNodeHeader)    // This must be at least sizeof(BST_NODE) 
{
    if(sizeof(BST_NODE) <= sizeIncludingNodeHeader) {           // size parameter valid?
        PBST_NODE pNewNode = host_calloc(1,sizeIncludingNodeHeader);
        if(pNewNode) {                          // alloc worked?
            pNewNode->Id = id;                  // yes, and 
                                                // the rest of the node was correctly set NULL by calloc
            return pNewNode;                    // only good exit
        } else {
            ASSERT(pNewNode,MEM_NO_MEMORY);     // alloc failed
        }
    } else {
        ASSERT(0,sizeIncludingNodeHeader);      // called with bad param
    }
    return NULL;                                // all failures exit here
}   // ends BST_CreateNullNode(...

#endif // don't LardUpCodeWithWasteComments


/*  TODO: No gotos.

   It's hard to imagine how a function that only makes one decision 
   can end up with a jump and a label, Nevertheless this was live
   code in the existing client. Cleaning out the waste locals and 
   labels shrank this by 60%, and made its task obvious. 
 */
#if LardUpCodeWithNeedlessComplexity

VPSTATUS _VPAPI 
SubLst_create( PHND phSubLst )
{
    VPSTATUS status = SUBLST_STATUS_SUCCESS;
    PSUBLST  pSubLst;
    
    status = Mem_alloc( MEM_GLOBAL_POOL, 
                       sizeof( *pSubLst ), 
                       (PPVOID)&pSubLst );
    if ( status ) { status = SUBLST_STATUS_NOMEMORY; goto function_exit; }
    
    *pSubLst  = NULL;
    *phSubLst = pSubLst;
    
function_exit:
    return status;
}

#else // don't LardUpCodeWithNeedlessComplexity

/** brief allocate a pointer sized object, set it NULL, then return the pointer in phSubLst 
 Yes, this is a bizarrely complex way to do this, since the head pointer could just as well
 be kept in phSubLst, I've no clue why we do the extra indirection.  */
VPSTATUS _VPAPI  SubLst_create( PHND phSubLst )
{
    if(( *phSubLst = host_calloc(1, sizeof(PSUBLST)) )) { // test and assign intended 
        return SUBLST_STATUS_SUCCESS;
    }
    return SUBLST_STATUS_NOMEMORY;
}   // ends SubLst_create(...

#endif // not LardUpCodeWithNeedlessComplexity


/* TODO: Prefer Positive logic. 

   Humans do not do well with double and triple negation. 
   Instead of testing for failure or NULL, test for success.
   invariably this leads to more readable code, since there's no need
   for the the '!=' or the peculiar 'NULL ==' which is a double negative in itself.
*/
#if DoEverythingBackwards

    if (Mem_alloc(MEM_GLOBAL_POOL, cbPkt, (PVOID)&alignedPtr) != MEM_SUCCESS) {
        return CLIENT_ERROR_NO_MEMORY;
    } else {
        Mem_cpy(alignedPtr, pPkt, cbPkt);
        pPkt = alignedPtr;
    }

#else // don't DoEverythingBackwards

    if(( alignedPtr = host_malloc(cbPkt) )) {	// assign intended
        memcpy(alignedPtr, pPkt, cbPkt);
        pPkt = alignedPtr;
    } else {
        return CLIENT_ERROR_NO_MEMORY;
    }

#endif // don't DoEverythingBackwards



/* TODO: Use meaningful names. 

   Why is something called 'Validate...' returning a pointer, and why are we using that pointer?
   How did we know FileId was NULL when ValidateContext() failed? (We didn't, the TRACE message is probably a lie.)
*/
#if HideBehaviorBehindMisleadingName

void ContextSetDateTime( USHORT FileId, USHORT usDate, USHORT usTime)
{
	POPENCONTEXT pFileContext = ValidateContext( FileId);
    
    if (pFileContext)  {
		pFileContext->x.pFileEnt->fDateValid = TRUE;
		pFileContext->x.pFileEnt->FileDate = usDate;
		pFileContext->x.pFileEnt->FileTime = usTime;
	} else {
        TRACE(( TC_CDM, TT_ERROR, "SetDateTime: FileId is NULL"));
    } 
}

#else // don't HideBehaviorBehindMisleadingName

void ContextSetDateTime( USHORT FileId, USHORT usDate, USHORT usTime)
{
	POPENCONTEXT pFileContext = GetFileContextForID(FileId);
    
    if (pFileContext)  {
		pFileContext->x.pFileEnt->fDateValid = TRUE;
		pFileContext->x.pFileEnt->FileDate = usDate;
		pFileContext->x.pFileEnt->FileTime = usTime;
	} else {
        TRACE(( TC_CDM, TT_ERROR, "%s: GetFileContextForID() returned NULL for FileId: %i", __func__, FileId));
    } 
}

#endif // don't HideBehaviorBehindMisleadingName

/* TODO: Prefer meaningful names over comments
 If your functions, arguments, and locals are named well enough, many comments become redundant.
*/


/* TODO: Every task that requires one comment and several lines deserves refactoring
 When a function becomes too long, it's usually doing more than one thing.
 Each of the separate things it does deserves to be a well-named function, possibly local and 
 inlined, but nevertheless, get that task out of the function, and name it so well it needs no comments.
 */


/* TODO: C is not a V2 (Verb second, germanic) language, don't write code like that. 

   When was the last time you read, or said:
   “If listening to wrongheaded speakers am I, soon talking funny will I be.”

   Contrast “if stupid idea think you this doing it stop”
   with “if you think it’s stupid stop doing it”
   What makes these seem so weird is that the subject of the sentence (you) falls at 
   the end of the clause, after the verb (think). 

   When we test a value against a constant, the value is the subject and the test is the 
   verb. In this example, we are interested in the existence of pFileContext; we are
   NOT interested in whether it is NULL, we are interested in whether it IS.
   So the question to ask is: if(pFileContext) { do something with it }

   Don't even think of using the excuse that you're not a native english speaker.
   C's (and cpp's and ObjC's and Java's) native language is english, and it's
   not like americans speak better english than most who have it as a second language.
 
   ContextSetDateTime() was so special that it rated two rules. 
*/
#if GreatIdeaThinkYouThis

void ContextSetDateTime( USHORT FileId, USHORT usDate, USHORT usTime)
{
	POPENCONTEXT	pFileContext = NULL;
	pFileContext = GetFileContextForID( FileId);
    
    if (NULL == pFileContext)  {
        TRACE(( TC_CDM, TT_ERROR, "SetDateTime: FileId is NULL"));
    } else {
		pFileContext->x.pFileEnt->fDateValid = TRUE;
		pFileContext->x.pFileEnt->FileDate = usDate;
		pFileContext->x.pFileEnt->FileTime = usTime;
	}
}

#else // GreatIdeaThinkYouThis NOT!

void ContextSetDateTime( USHORT FileId, USHORT usDate, USHORT usTime)
{
	POPENCONTEXT pFileContext = GetFileContextForID( FileId); // returns null if no matching context.
    
    if (pFileContext)  {                                  // got a matching context, fill out time fields.
		pFileContext->x.pFileEnt->fDateValid = TRUE;
		pFileContext->x.pFileEnt->FileDate = usDate;
		pFileContext->x.pFileEnt->FileTime = usTime;
	}  else {       
        TRACE(( TC_CDM, TT_ERROR, "SetDateTime: GetFileContextForID() found no match "));
    }
}

#endif //  GreatIdeaThinkYouThis NOT!



/* TODO: Declare and initialize locals with their terminal values in the tightest scope possible. 

   Ok so ContextSetDateTime() rates even more rules.
   There's NO reason to set pFileContext to NULL before setting it with GetFileContextForID()
   Doing so misleads the reader, is simply silly, and implies a poor understanding of 
   assignment through function calls.
*/
#if PointlessInitializationBeforeAssignment
    POPENCONTEXT pFileContext = NULL;
    pFileContext = GetFileContextForID(FileId);
#else
    POPENCONTEXT pFileContext = GetFileContextForID(FileId);
#endif


/* TODO: Define macros with explicit values. Prefer #if over #ifdef or #ifndef
 The problems with #ifdef are manifold:
    #ifdef is ambiguous, defining SOMETHING as false (0) causes #ifdef SOMETHING to return true.
    Compound tests are made unnecessarily complex.
    It is harder to reverse the state of a macro.
 */
#if MaximizeMacroObfuscation

    #define EXISTS
    #undef DOESNTEXIST

    #ifdef EXISTS
        #ifndef DOESNTEXIST
            printf("Oh, I get it");
        #else
            printf("Something's wrong here");
        #endif
    #else
        printf("Darn, I think my logic is flawed!");
    #endif

#else   // Don't MaximizeMacroObfuscation

    #define EXISTS 1
    #define DOESNTEXIST 0

    #if(EXISTS && !DOESNTEXIST)
        printf("The world is a logical place");
    #else
        printf("This world is a fallacy");
    #endif

#endif   // Don't MaximizeMacroObfuscation



/* TODO: Define out code. Don't comment out code. 
 
 The only reasons to comment out code are because it's being staged for removal, 
 or because it's in support of some not-yet-implemented capability. In either 
 case, use a macro that specifically documents the reason the code is disabled. 
*/
#if USE_CALL_TABLES // These fake DLLs are all deprecated in iOS/OSX clients 

    /** brief Instantiate global pointers to jump tables.
     These misleadingly named macros all declare, and initialize to NULL,
     pointers to the various fake DLLs we're so fond of */
    CTXOS_GLOBAL_INIT;
    THRD_GLOBAL_INIT;
    TMR_GLOBAL_INIT;
    GRAPH_GLOBAL_INIT;
    FILE_GLOBAL_INIT;
    PATH_GLOBAL_INIT;
    EVT_GLOBAL_INIT;
    SCA_GLOBAL_INIT;
#endif  // USE_CALL_TABLES


/* TODO: Don't DeclareFName(). Don't reinvent the wheel.
    If there exists a built-in or standardized way to do something,
    resist the urge to show off your cleverness by doing it in 
    your own unique way. __func__ is part of C99, there's no excuse
    to reinvent it.
    The fact that your clever hack predates the adoption of the standard,
    or that Windows' compilers were non-standard, does not excuse the continued
    use of the hack; Put away your ego and clean up your mess.
*/

#if ObfuscateCodeWithTooCleverByHalfConstructs

    #define DeclareFName(func) const char fName[] = func;

    UCE_STATUS UCE_InternalGetTargetLayoutPointer(PCTX_KBDTABLES * ppTable)
    {
        DeclareFName("UCE_InternalGetTargetLayoutPointer");
        TRACE((TC_FONT,TT_API1,"%s : Entry",fName));
        ...
    }

#else // Don't ObfuscateCodeWithTooCleverByHalfConstructs

    UCE_STATUS UCE_InternalGetTargetLayoutPointer(PCTX_KBDTABLES * ppTable)
    {
        TRACE((TC_FONT,TT_API1,"%s : Entry",__func__));
        ...
    }

#endif // ObfuscateCodeWithTooCleverByHalfConstructs

/* TODO: Notes on usage
 String literals are already null terminated by the compiler. This is redundant: */
   static char* mainThreadName = "ReceiverMainThread\0"; /* TVW: I forget this all the time :( 
                                                          
 Class instances are always calloced, only non-zero members require further initialization

                                                          
 */


/* TODO: Capitalize and CamelCase function names and don't give a function the same name as a method.
 In particular, if you've created a method like [phoneAndTextManager makePhoneCall:] which
 requires an engine bridge function so that it may be called from c, name the corresponding
 function MakePhoneCall().
 */


/* TODO: Naming Rules for ObjC objects, methods, members, etc, always conform to Apple's published rules
 as elucidated here:
 https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 
 This isn't just desirable for esthetic purposes, it is necessary in order that the compiler and 
 optimization tools fully understand your code, and that you not create conflicts in namespaces.
 
 Brief reminders follow, but do read the linked document, especially "Code Naming Basics" to 
 understand the reasoning and pitfalls.
 */


/* TODO:  Method names and object properties start with a lowercase letter, subsequent words are CamelCased. 
 
 Don’t use prefixes.
 
 For methods that represent actions an object takes, start the name with a verb
 - (void)invokeWithTarget:(id)target;
 - (void)selectTabViewItem:(NSTabViewItem *)tabViewItem
 
 If the method returns an attribute of the receiver, name the method after the attribute. 
 The use of “get” is unnecessary, unless one or more values are returned indirectly.
 
 Use keywords before all arguments.
 Make the word before the argument describe the argument.
 
 Also see property attributes, below.
 
 */


/* TODO: Function names are prefixed like classes and constants, then CamelCased
 Most function names start with verbs that describe the effect the function has
 */


/* TODO: Create thread-safe Singletons
 */

/** @brief Get, creating if needed, the EngineMessage dispatch queue.
 Usable from both C and ObjC, scope rules guarantee that this 
 function provides the ONLY access to this queue.
 */
dispatch_queue_t GetEngineMessage_dispatch_queue(void)
{
    static const char* EngineMessage_queue_name = "com.citrix.receiver.EngineMessage_dispatch_queue";

    static dispatch_queue_t EngineMessage_dispatch_queue = nil; // Set nil by compiler once.
    static dispatch_once_t tolkien;                                 // A magic one-shot mutex

    dispatch_once(& tolkien, ^{        // Make sure this happens only once for the entire app run.
        EngineMessage_dispatch_queue = dispatch_queue_create(EngineMessage_queue_name, DISPATCH_QUEUE_SERIAL);
        if(!EngineMessage_dispatch_queue) {
            // Some failure to create queue, whole app is hosed
            SHOW("%s, could not create queue\n", __func__);
            assert(EngineMessage_dispatch_queue);
            NSException *ex = [NSException exceptionWithName:NSInternalInconsistencyException
                                                      reason:@"Engine Message queue creation failed"
                                                    userInfo:nil];
            [ex raise];
        }
    } );
    return EngineMessage_dispatch_queue;
}   // ends GetEngineMessage_dispatch_queue()


/* TODO: Use reverse reverse-DNS naming to avoid namespace issues in iOS and ObjC

 Apple system guidelines (and objC's flat namespace) require that things like 
 bundle IDs, queue names, thread names, libraries, and device drivers have unique names.
 
 Always use names like "com.citrix.<lib-or-app-name>.thingname"; define those names
 in approriate scope, and NEVER use string literals to refer to them.
 Also see "No Magic Numbers or Strings", above"
*/


/* TODO: Don't initialize instance variables to 0, ObjC did it for you already.
 
"The alloc ... methods initialize a new object’s isa instance variable so that it 
 points to the object’s class (the class object). All other instance variables are 
 set to 0. Usually, an object needs to be more specifically initialized before 
 it can be safely used."
--- From "OBJECT-ORIENTED PROGRAMMING AND THE OBJECTIVE-C LANGUAGE" ---
 */


/* TODO: Additional ObjC and Foundation best practices belong around here 
 
 */ 

/* TODO: write notes consider ivars vs properties, public vs private
 
 class extensions.
 brackets not dots.
 
 */ 


/* TODO: Put out the trash before you go.  

   When you make a change in a file, take a look for dead code and toss it out.
   Be brave, consider if(0) and #if(0) opportunities to make the world a better place.
   Think of future readers, and save them from the horrors of DeclareFName().
*/

/* TODO: Turn these scraps and notes into something useful:
 
 create try catch finally macros for c 
 
 how to write a method bertrand meyer
 
 design by contract! class invariance is part of the contract.
 
 Engine-UI contracts. 
 
 Apple:
 either 
 NSException for program errors
 UIkit return bools and or NSError
 
 distinguish between runtime failure return and 'reasonable failure' like file not found.
 
 nsblockassertions
 
 in engine fit in a better assertion and try catch finally macros.
 
 in instruments add uncaught exception handler 

 
 @interface ClassName : ItsSuperclass < protocol list >
 Categories adopt protocols in much the same way:
 
 @interface ClassName ( CategoryName ) < protocol list >
 A class can adopt more than one protocol; names in the protocol list are separated by commas.
 
 @interface Formatter : NSObject < Formatting, Prettifying >
 A class or category that adopts a protocol must implement all the required methods the 
 protocol declares, otherwise the compiler issues a warning. The Formatter class above 
 would define all the required methods declared in the two protocols it adopts, 
 in addition to any it might have declared itself.
 
 A class or category that adopts a protocol must import the header file where the protocol 
 is declared. The methods declared in the adopted protocol are not declared elsewhere in 
 the class or category interface.
 
 It’s possible for a class to simply adopt protocols and declare no other methods. 
 For example, the following class declaration adopts the Formatting and Prettifying 
 protocols, but declares no instance variables or methods of its own:

 */

