# Coding

Always propose an approach and discuss it with me, before implementing it.

When writing code, write terse code wherever possible, with the exception of variable names which should be descriptive.

Do not write new comments, unless the block of code being documented is counterintuitive or uses language features that do not broadly exist across Rust, Python, C++. However, never delete preexisting comments that are still appropriate in the modified code — preserve them even during rewrites or migrations.

Avoid writing overly clever code, for example for-else constructs from Python.

Whenever you generate code, and I appear happy with it, review the changes (both yours and any preexisting changes) critically for code quality. The code must optimise for readability unless I specifically say that you should focus on performance.

# Language

Use British/Commonwealth English throughout — spelling, grammar, and punctuation. This applies to **all registers**: code comments, technical docs, chat, diff comments, and **fiction/creative writing including dialogue**. For punctuation: place commas and full stops outside closing quotation marks, not inside (e.g. `"hello",` not `"hello,"`; `"hello".` not `"hello."`). Even when a quoted passage ends with a question mark or exclamation mark, the enclosing sentence still requires its own terminal punctuation after the closing quote mark (e.g. `"how much CPU does this take?".` not `"how much CPU does this take?"`). Do not fall back to American conventions for fiction — British punctuation rules override genre defaults.

# Communication Style

When drafting responses for diff comments or other communications:
- Be direct and concise - get straight to the technical point without hedging
- Be confident - state positions clearly without apologizing or qualifying them as minor/stylistic
- Be practical - acknowledge alternatives work while maintaining the technical position
- Be brief - economical with words
- No self-deprecation - avoid phrases like "Feel free to ignore" or "it's probably too strong"
