### Yanktools

----------------------------------------------------------------------------


### Introduction

Yanktools is a plugin inspired by vim-yankstack and vim-easyclip.

----------------------------------------------------------------------------


### Installation

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

    Plug 'mg979/vim-yanktools'



----------------------------------------------------------------------------


### Features list

* __Stacks__: yanks and deletions are stored in a list, that can be cycled at
  cursor position, back and forth, with a specific keybinding, swapping
  elements of the stack, and keeping properties of the last paste command
  (autoformat, paste before, etc).

* __Manual and Recording modes__: stacks will be filled with specific mappings,
  or automatically at every yank/delete operation, respectively. Can be
  toggled.

* __Black hole redirection__: c, C, x, X, Del

* __Swap-&-paste__: also in preview window (with syntax highlighting)

* __Visual mode__: paste in visual mode won't change the default register.

* __Replace operator__: replace text objects with register. Repeatable.

* __Duplicate operator__: lines, text objects or from visual mode. Repeatable.

* __Zeta stack__: a disposable yank stack, from which items are taken from the
  back, and pasting them removes them from the stack as well. You can populate
  the stack both by yanking and deleting.

* __Autoindent__: you can toggle it, or use mappings to perform a single
  indented paste.

* __Interactive paste__: with preview window or fzf-vim

* __Convert yank type__: convert selected register to/from blockwise.



----------------------------------------------------------------------------


The main concept is to have a dedicated stack, where yanks and deletions can
be stored and later accessed, so to have a "clipboard history" in vim.

The main difference between this and other plugins of this kind, is that
saving yanks and deletions in the stack isn't an automatic process, at least by
default.

Adding a new item (yank or deletion) to the yank stack is the result of
either:

* a yank/deletion performed with a specific mapping
* saving a register directly in the stack
* enabling the `recording mode`, that allows automatic addition to the stack

A main key should be defined, and this key will used for both saving into the
stack, and for the replace operator. I recommend the 's' key.

Full documentation with `:help yanktools.txt`

----------------------------------------------------------------------------

### Pictures

Swapping:

![Imgur](https://i.imgur.com/FP2goLu.gif)

Interactive paste with fzf:

![Imgur](https://i.imgur.com/SE0TDg4.png)

Choose stack item:

![Imgur](https://i.imgur.com/NAIVBRp.gif)

Interactive paste with preview:

![Imgur](https://i.imgur.com/QmmQXHb.gif)

----------------------------------------------------------------------------


### Credits

Bram Moolenaar for Vim  
Steve Vermeulen for vim-easyclip  
Max Brunsfeld for vim-yankstack  


----------------------------------------------------------------------------


### License

License: same terms as Vim itself
