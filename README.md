### Yanktools

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Features list](#features-list)
* [Introduction](#introduction)
* [Usage](#usage)
* [Pictures](#pictures)
* [Credits](#credits)
* [License](#license)

<!-- vim-markdown-toc -->

----------------------------------------------------------------------------


### Installation

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other plugin
manager.

With vim-plug:

    Plug 'mg979/vim-yanktools'



----------------------------------------------------------------------------


### Features list

* __Yank Stack__: yanks and deletions are stored in a list, that can be cycled
  at cursor position, back and forth, with a specific keybinding, swapping
  elements of the stack, and keeping properties of the last paste command
  (autoformat, paste before, etc).

* __Manual and Recording modes__: stacks will be filled with specific mappings,
  or automatically at every yank/delete operation, respectively. Can be
  toggled.

* __Preservation of unnamed register__: c, C, x, X, Del, visual paste

* __Swap-&-paste__: cycle among stack elements, or show them in popup/preview
  window.

* __Replace operator__: replace text objects with register. Repeatable.

* __Duplicate operator__: without altering registers. Repeatable.

* __Zeta stack__: a disposable yank stack, from which items are taken from the
  back, and pasting them removes them from the stack as well. You can populate
  the stack both by yanking and deleting.

* __Autoindent__: you can toggle it, or use mappings to perform a single
  indented paste.

* __Interactive paste__: with preview window or fzf-vim

* __Convert yank type__: convert selected register to/from blockwise.

* __Optional persistance__



----------------------------------------------------------------------------

### Introduction

Yanktools is a plugin inspired by vim-yankstack and vim-easyclip.

The main concept is to have a dedicated stack, where yanks and deletions can
be stored and later accessed, so to have a "clipboard history" in vim.

The main difference between this and other plugins of this kind, is that
saving yanks and deletions in the stack isn't an automatic process, at least by
default.

Adding a new item (yank or deletion) to the yank stack is the result of
either:

* a yank/deletion performed with a specific mapping
* saving a register directly in the stack
* enabling the _recording mode_, that allows automatic addition to the stack


----------------------------------------------------------------------------


### Usage

A main key should be defined, and this key will used for both saving into the
stack, and for the replace operator. I use the 's' key.

      let g:yanktools_main_key = 's'   " or '<c-s>', 'S', 'Z'...

Read the documentation for more details.

Defined operators and their default behaviour (assuming 's' as main key):

| mapping       | name          | function                            |
|---------------|---------------|-------------------------------------|
| <kbd>sy</kbd> | yank & save   | add yanked text to the yank stack   |
| <kbd>sd</kbd> | delete & save | add deleted text to the yank stack  |
| <kbd>s</kbd>  | replace       | replace text object with register   |
| <kbd>yd</kbd> | duplicate     | duplicate text object               |

Visual mode mappings:

| mapping        | name                       |
|----------------|----------------------------|
|<kbd>sy</kbd>   | yank & save                |
|<kbd>sd</kbd>   | delete & save              |
|<kbd>Del</kbd>  | preserve unnamed register  |
|<kbd>M-d</kbd>  | duplicate                  |

Other normal mode mappings:

| mapping        | name                                       |
|----------------|--------------------------------------------|
|<kbd>]p</kbd>   |  paste after the cursor and autoindent     |
|<kbd>[p</kbd>   |  paste before the cursor and autoindent    |
|<kbd>M-p</kbd>  |  cycle the stack (+1) and paste            |
|<kbd>M-P</kbd>  |  cycle the stack (-1) and paste            |
|<kbd>]y</kbd>   |  cycle the stack (+1) and preview in popup |
|<kbd>[y</kbd>   |  cycle the stack (-1) and preview in popup |

Zeta mode:

|Normal                |              | Visual        |
|----------------------|--------------|---------------|
| <kbd>yz</kbd>        | yank         | <kbd>ZY</kbd> |
| <kbd>dz</kbd>        | delete       | <kbd>ZD</kbd> |
| <kbd>zp</kbd>        | paste        | <kbd>ZP</kbd> |

Example settings:

    " make 'S' replace until the end of the line
    let g:yanktools_main_key = 's'
    nmap      S s$
    nnoremap  Y y$


Full documentation with `:help yanktools.txt`

----------------------------------------------------------------------------

### Pictures

Swapping:

![Imgur](https://i.imgur.com/FP2goLu.gif)

Interactive paste with fzf:

![Imgur](https://i.imgur.com/SE0TDg4.png)

Choose stack item:

![Imgur](https://i.imgur.com/NAIVBRp.gif)

Preview with popup (vim 8.1 or neovim 0.4)

![Imgur](https://i.imgur.com/mcYEnhF.gif)

----------------------------------------------------------------------------


### Credits

Bram Moolenaar for Vim  
Steve Vermeulen for vim-easyclip  
Max Brunsfeld for vim-yankstack  


----------------------------------------------------------------------------


### License

License: same terms as Vim itself
