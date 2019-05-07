### Yanktools

----------------------------------------------------------------------------


### Introduction

Yanktools is a plugin inspired by vim-yankstack and vim-easyclip, and it
takes elements from both. You should expect all features from vim-easyclip,
plus some new ones.

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

* __Black hole redirection__: `c`, `C`, `x`, `X`, `<del>`

* __Replace operator__: replace text objects with register. Works with cycling too.

* __Duplicate operator__: lines, text objects or from visual mode.

* __Zeta mode__: a disposable yank stack, from which items are taken from the
  back, and pasting them removes them from the stack as well. You can populate
  the stack both by yanking and cutting.

* __Autoindent__: you can toggle it, or use a prefix to the normal
  mappings to perform a single indented paste.

* __Interactive paste__ (also with fzf-vim)

* __Convert yank type__: convert selected register between linewise and blockwise.

* __repeat-vim support__: yanktools supports it for most paste operations.

* Paste in visual mode won't change the default register.

* and some more...


----------------------------------------------------------------------------


### Basic usage

Defined operators and their default behaviour:

----------------------------------------------------------------------------

### Basic options


	let g:yanktools_format_prefix = '<'

Perform an autoindented paste/replacement by preponing this prefix.


Full documentation with `:help yanktools.txt`

----------------------------------------------------------------------------


### Credits

Bram Moolenaar for Vim  
Steve Vermeulen for vim-easyclip  
Max Brunsfeld for vim-yankstack  


----------------------------------------------------------------------------


### License

MIT
