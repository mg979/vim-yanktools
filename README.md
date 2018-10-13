### Yanktools

----------------------------------------------------------------------------


### Introduction

Yanktools is a plugin inspired by vim-yankstack and vim-easyclip, and it
takes elements from both. You should expect all features from vim-easyclip,
plus some new ones.
others?

----------------------------------------------------------------------------


### Installation

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

    Plug 'mg979/vim-yanktools'



----------------------------------------------------------------------------


### Features list

* __Cycle yank stack__: all yanks are stored in a list, that can be cycled at
  cursor position, back and forth, with a specific keybinding. It keeps the
  properties of the last paste command (autoformat, paste before, etc).

* __Black hole redirection__: `c`, `C`, `x`, `X`, <del>

* __Register redirection__: `d` and `D` are redirected to another register
  (default 'x'), without replacing the unnamed register.

* __Replace operator__: replace text objects with register.

* __Zeta mode__ (by default it uses `z` as key) that fills a disposable yank stack,
  from which items are taken from the back, and pasting them removes them from
  the stack as well. You can populate the stack both by yanking and cutting.

* __Autoindent__: you can toggle it, or use a prefix to the normal
  mappings to perform a single indented paste.

* __Interactive paste__ (also with fzf-vim)

* __Convert yank type__: convert selected register between linewise and blockwise.

* __repeat-vim support__: yanktools supports it for most paste operations.

* Paste in visual mode won't change the default register.

* Since register redirection is an option, pasting from that register has its
  own mapping. This can also be used in combination with the replace operator.

* Redirected text fills its own stack, so that you can cycle/paste from it too.

* and some more...


----------------------------------------------------------------------------


### Basic usage

There are many functions available, but you don't need to use them all or even
know about them. Yank/paste/delete/change commands work as usual, but by
default:

* `yank` commands add yanked text to the yank stack
* you can cycle the yank stack with the 'swap' commands (default `M-p` / `M-P`)

* delete commands redirect the deleted text to register 'x'
* you can paste from the redirected register with `<leader>p/P`
* you can cycle the redirected stack with the 'swap' commands after `<leader>p/P`

* change and `x` commands redirect to the black hole register

* you can use the replace operator to replace motions or lines.

* duplicate lines/selected text with <M-d> (not overwriting default register)



----------------------------------------------------------------------------

### Basic options


The most important options, with their defaults:

	let g:yanktools_use_single_stack = 0

Set to 1 if you want a single stack for both yank and delete operations, so
that you can cycle among all of them, instead of having separate stacks.

	let g:yanktools_replace_operator = ''

Set to `s` or another character if you want to use the replace operator.


Full documentation with `:help yanktools.txt`

----------------------------------------------------------------------------


### Credits

Braam Moolenaar for Vim  
Steve Vermeulen for vim-easyclip  
Max Brunsfeld for vim-yankstack  


----------------------------------------------------------------------------


### License

MIT
