# ObjectiveC training, Managing Technical Debt.

Presentation slides, programming guidelines, and other training materials for C and ObjectiveC. While quite raw, these are published here as examples of technical writing style, examples of managing technical debt, and  reminders of the true cost of accumulating technical debt. These were all written in 2011 through 2013 and represent state of the art for the time. 

Codestandards.m is released under the Apache licence. Please attribute and link back.
All other materials are copyright (C) Taryn VanWagner, redistribution is expressly forbidden.

Working for an enterprise, I found myself training teams of programmers who had only Windows experience, but had been recently tasked with iOS programming.  A lot of my original presentation materials have been lost to time, or were entirely proprietary. In other cases they morphed into the manifestos. The original presentations were never as snarky, the coding standards and manifestos were often published or revised in response to a team attempting to re-introduce a bad behavior we'd just removed.

The existing codebase, from the late 80s, had been ported from Classic Windows, through Unix, through Classic MacOs, through Win95 and NT, through Mac OSX, adding ObjectiveC, and finally to early versions of iOS. Though the earliest 'plain C' code was quite good, and written in a fairly portable fashion. that was not the case for much of the subsequent work. Needless to say, there was significant technical debt. The code was full of dead and redundant code, used a great deal of hand-rolled runtime-binding, via multiple tables of function pointers, and copied the Classic Windows style of overloaded structures for function argument passing. This was an excruciating environment for identifying dead code and obsolete functionality, so well obfuscated that automated optimization and analysis tools were helpless against it. 

The largest single problem was the existence of multiple redundant utility and wrapper modules providing similar, but not identical features. The manifestos and standards herein document my efforts to retain the portable C base code where possible, identify, deprecate, and strip those redundant libraries, prevent their reintroduction to the iOS and Mac codebases, and utilize modern ObjectiveC and Cocoa techniques for concurrency, timing, communications, runtime binding, and memory management. The manifestos have been significantly redacted, (shown as ...[redacted]... or merely [], to remove attack vectors, proprietary materials, and protect the guilty, while still providing examples of how to approach technical debt reduction.

For much of those years my 'Lines of code / week' metric was negative, often hitting 4 digit values. A great source of amusement during quarterly reviews.

"My best code is written with the delete key"
--- Prelude, Code Goddess ---
