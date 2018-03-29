### Yanktools

----------------------------------------------------------------------------


### Introduction

Yanktools is a plugin inspired by vim-yankstack and vim-easyclip, and it
takes elements from both. You should expect all features from vim-easyclip,
plus some new ones. But why make a new plugin, instead of just using the
others?

The main reason I started writing this plugin were issues while using easyclip.
So I started writing a new plugin with a different approach (more in line with how
vim-yankstack operates).


----------------------------------------------------------------------------


### Installation

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

    Plug 'mg979/vim-yanktools'


Mappings are not automatically set. You must initialize them by calling in
your .vimrc:

    call yanktools#init#maps()

Any option you change, should be put __before__ you call this function.

Only after having initialized the mappings, you should set your own remaps
(such as `nmap Y y$`), so that they will work with the new functions.
See also g:yanktools_convenient_remaps.


----------------------------------------------------------------------------


### Features list

|Feature                               |  yanktools| yankstack |easyclip  |
|--------------------------------------|-----------|-----------|----------|
|Works in insert mode                  |   no      | yes       | ?        |
|Cycle yank stack                      |   yes     | yes       |yes       |
|Black hole redirection                |   yes     | no        |yes       |
|Visual paste redirection              |   yes     | no        | ?        |
|Register redirection                  |   yes     | no        |no        |
|Replace operator                      |   yes     | no        |yes       |
|Zeta mode                             |   yes     | no        |no        |
|Autoformat                            |   yes     | no        |yes       |
|Move cursor to the end                |   yes     | no        |yes       |
|Interactive paste                     |   yes     | no        |yes       |
|Interactive paste with fzf-vim        |   yes     | no        |no        |
|Convert yank type                     |   yes     | no        |no        |
|repeat.vim support                    |   yes     | no        |yes       |

__*Common options:*__

* __Cycle yank stack__: all yanks are stored in a list, that can be cycled at
  cursor position, back and forth, with a specific keybinding. It keeps the
  properties of the last paste commnd.

* __Black hole redirection__: configure motions to redirect to black hole, to
  avoid overwriting of the default register.

* __Replace operator (default 's')__: as substitution operator in easyclip or
  replace operator in similar plugins (ReplaceWithRegister, etc).

* __Autoindent__: you can toggle it, or use a prefix to the normal
  mappings to perform a single indented paste, and this behaviour is inverted
  if autoindent is active (ie. single unindented paste).

* __Move operator__: included, but disabled by default (replaced by redirection).

* __repeat.vim support__: yanktools supports it for most paste operations.

----------------------------------------------------------------------------

__*The new features (compared to easyclip) are:*__

* __Register redirection__: instead of redirecting to the black hole register, you
  can redirect the chosen commands to another register (default 'x'), without
  replacing the unnamed register.

* By default, paste in visual mode won't change the default register.

* Since register redirection is an option, pasting from that register has its
  own mapping. This can also be used in combination with the replace operator.

* Redirected text fills its own stack, so that you can cycle/paste from it too.

* __Zeta-mode__: (by default it uses 'z' as prefix) that fills a parallel yank stack,
  from which items are taken from the back, and pasting them removes them from
  the stack as well. You can populate the stack both by yanking and cutting.

* If you use fzf-vim, there's a command to browse your yank stack and paste
  from it. Otherwise the same interactive paste from easyclip is provided.

* __Convert yank type__: convert selected register between linewise and blockwise.


----------------------------------------------------------------------------


### Basic usage

There are many functions available, but you don't need to use them all or even
know about them. Yank/paste/delete/change commands work as usual, but by
default:

* yank commands add yanked text to the yank stack
* you can cycle the yank stack with the 'swap' commands (default `M-p` / `M-P`)

* delete commands redirect the deleted text to register 'x'
* you can paste from the redirected register with `<leader>p/P`
* you can cycle the redirected stack with the 'swap' commands after `<leader>p/P`

* change and 'x' commands redirect to the black hole register
* you can use the replace operator to replace motions ('s') or lines ('ss')

Have a look at the `convenient remaps` section if you want mappings similar to
`vim-unimpaired`.

----------------------------------------------------------------------------


#### Easyclip mode

If you used |vim-easyclip| and want to use the same behaviours and mappings:
 
    let g:yanktools_easyclip_mode           = 1

If you then want to enable the replace operator, remove 's' from black hole
redirection and setup operators:

    let g:yanktools_black_hole_keys         = ['d', 'D', 'c', 'C', 'x','X', '<Del>']
    let g:yanktools_replace_operator        = 's'
    let g:yanktools_replace_line            = 'ss'

Any option you change, should be put __before__ you initialize the mappings.


----------------------------------------------------------------------------


### Options

|Option                                        |Default                |
|----------------------------------------------|-----------------------|
|g:yanktools_yank_keys                         | `['y', 'Y']          `|
|g:yanktools_move_key                          | `[]                  `|
|g:yanktools_paste_keys                        | `['p', 'P', 'gp', 'gP']`|
|g:yanktools_black_hole_keys                   | `['c', 'C', 'x', 'X', '<Del>']   `|
|                                              |                       |
|g:yanktools_redirect_register                 | `'x'                 `|
|g:yanktools_redirect_keys                     | `['d', 'D']          `|
|g:yanktools_redir_paste_prefix                | `'<leader>'          `|
|                                              |                       |
|g:yanktools_replace_operator                  | `'s'                 `|
|g:yanktools_replace_line                      | `'ss'                `|
|g:yanktools_replace_operator_bh               | `1                   `|
|                                              |                       |
|g:yanktools_format_prefix                     | `'<'                 `|
|g:yanktools_zeta_prefix                       | `'z'                 `|
|g:yanktools_zeta_kill                         | `'K'                 `|
|                                              |                       |
|g:yanktools_easyclip_mode                     | `0                   `|
|g:yanktools_use_single_stack                  | `0                   `|
|g:yanktools_move_cursor_after_paste           | `0                   `|
|g:yanktools_auto_format_all                   | `0                   `|
|g:yanktools_convenient_remaps                 | `0                   `|

You can change these options to control which keys redirect to which register,
the default register for redirection, the prefixes used for several mapping
types, etc.


----------------------------------------------------------------------------


### Cycle yank stack

Default mappings for cycling the yank stack are `<M-p>`/`<M-P>` (forward/back).

If you press one of these keys before doing a paste, it will paste the last
entry of the stack (the last yanked item), using 'P' (paste before).

If you press another paste key (`p`, `gp`, `<p`, `<P`...), the stack will be cycled
keeping the properties of that paste command (before or after, move cursor at
end, autoindent, etc).

Eg. you press `<P` (formatted paste before), cycling the stack will keep
pasting before, and applying autoformat.

Simply moving the cursor after a swap resets this command.

By default, deleted (redirected) text builds its own stack, so you can cycle
it by using these commands, after having performed a paste from the redirected
register (default `<leader>p`).


----------------------------------------------------------------------------


### Register redirection

By default, `x`, `X` and `<Del>` redirect to the black hole register ("_"),
while `c`, `C`, `d` and `D` redirect to a special register (default "x").
You can paste directly from this register with `<leader>p/P`.

Normally, when you yank to a specific register, you overwrite at the same time
the unnamed register, but this isn't the case with this plugin, since it is
restored to its previous content after each delete/change operation.

Black hole and special register are only the defaults for each key: you can
still specify a register and it will override the default redirection. Eg.:

    dd     will delete the line while redirecting to register "x"
    "_dd   will delete the line while redirecting to black hole register
    cc     will change the line while redirecting to black hole register
    "xcc   will change the line while redirecting to register "x"

Additionally, when you paste in visual mode, the replaced text will not
overwrite the default register.

You can change the `<leader>` prefix by changing this setting:

    let g:yanktools_redir_paste_prefix = '<leader>'

You can define the keys that redirect to the black hole/alternative register:

    let g:yanktools_black_hole_keys = ['c', 'C', 'x', 'X', '<Del>']
    let g:yanktools_redirect_keys   = ['d', 'D']

You can redefine the default register for redirection:

    let g:yanktools_redirect_register = 'x'


----------------------------------------------------------------------------


### Redirected stack

Text that is deleted (redirected), even if it doesn't overwrite the unnamed
register, can still be added to the normal yank stack, so that deleted text
will appear when cycling the stack. Otherwise, you can use a dedicated
stack for deleted items.

    let g:yanktools_use_single_stack = 0

|-|-|
|true| deleted text is added to the yank stack|
|false (default)| deleted text is added to its own stack|

In the latter case, the kind of stack you'll be using when cycling, will
depend on the key you used for pasting:

|-|-|
|normal paste                  |will use normal stack when cycling|
|paste from redirected register|will use redirected stack|



----------------------------------------------------------------------------

### Move operator

You can setup a _move operator_ as in vim-easyclip, if you prefer. Eg:

    let g:yanktools_move_key = 'm'

Moving text will then overwrite the default register, while all others will be
redirected to black hole. Moved text will also be pushed in the yank stack, as
a normal yank.

If you keep the default yanktools behaviour of 'd' key (redirect register), 
then you can have a 'history' of deleted items that you can still access
(through the redirected stack). Otherwise add the 'd' key to the 'black hole'
redirection keys, to mimic vim-easyclip behavoiur in toto.

    let g:yanktools_black_hole_keys = ['d', 'D', 'c', 'C', 'x', 'X', '<Del>']


----------------------------------------------------------------------------


### Replace operator

Default mapping is `s` for the operator, `ss` to replace whole lines.

By default the replaced content is redirected to the black hole, but you can
have it redirected to the `x` register (or your redirection register) by
setting:

    let g:yanktools_replace_operator_bh = 0

Both `s` and `ss` accept a register from which to paste. You can therefore
create a mapping such as:

    map sx "xs
    map sxx "xss

That is, a mapping for an operator that replaces from the redirected register,
to complement the normal replacement mode.

The 'replace line' command can have two different behaviours:

- `ss` will replace __*[count]*__ lines with a single instance of the register
  (this behaviour is the same as in ReplaceWithRegister plugin).

- `<leader>ss` will instead replace each line ine __*[count]*__ with the register
  content, while keeping the order of multiline entries (improved behaviour
  from easyclip).


----------------------------------------------------------------------------


### Zeta mode

By using the `z` prefix, you can create a disposable yank stack, from which
elements are taken from the bottom when pasting, and immediately removed.

Eg:  
    `text 1`    (zyy)  
    `text 2`    (zyy)  
    `text 3`    (zyy)  

The key sequence `zpzpzp` would then recreate the same sequence and consume the
stack.

Zeta-killing uses its own mapping (`K` by default), without `z` prefix.

You can add elements both with `zy` (zeta-yanking) and `K` (zeta-killing,
that is cutting). They behave just like `y` and `d` operators.
You could add these mappings to make usage easier:

    map zY zy$
    map zl zyy
    map zK zk$

See also g:yanktools_convenient_remaps.


----------------------------------------------------------------------------


#### Repeat.vim

This plugin supporrs `repeat-vim` for most paste operations. This means that
you can press `dot` to repeat the last paste command while keeping the same
formatting options of the last command.

`zeta-mode` is also supported: press `dot` to continue pasting from the zeta
stack, until the stack is consumed.

The `replace-operator` is also repeatable, though it doesn't need `repeat-vim`.




----------------------------------------------------------------------------


#### Autoformat

`g:yanktools_format_prefix` controls autoformat for single pastes, while
`g:yanktools_auto_format_all` controls the global behaviour. If the latter is
false, the former will autoindent the current paste. And viceversa.

The command `ToggleAutoIndent` (`<C-K>yi`) will toggle `yanktools_auto_format_all`
on and off.

------------------------------------------------------------------------------


As in vim-easyclip, you can configure an option to always move the cursor at
the end of the pasted content:

    let g:yanktools_move_cursor_after_paste = 1

Some commands (replace operator, zeta paste) use this method by default.


----------------------------------------------------------------------------


#### Interactive paste

This function is taken as-is from vim-easyclip, but if you use fzf-vim,
you'll be able to use it to fuzzy-select the entry.

Commands are:

    <C-K>p    choose and paste after
    <C-K>P    choose and paste before
    <C-K>Y    select yank without pasting


----------------------------------------------------------------------------


#### Other commands

    <C-K><C-P>   yanktools menu
    <C-K>yi      toggle autoindent
    <C-K>yd      delete yanks       (reset yank stack)
    <C-K>ys      show yanks         (same as in vim-easyclip)
    <C-K>yc      convert yank       (turns a blockwise yank to linewise, and vv.)


----------------------------------------------------------------------------


#### Mappings

A full list of the mappings is impossible to make, because the <Plug> names
change if you change the default yank/paste/redirect keys.

This is a partial list of the default mappings, should you want to change them.
Remember that you can just change the prefix for sets of commands, rather than
changing them individually.


    let g:yanktools_paste_keys              = ['p', 'P', 'gp', 'gP']
    let g:yanktools_yank_keys               = ['y', 'Y']
    let g:yanktools_black_hole_keys         = ['c', 'C', 'x', 'X', '<Del>']
    let g:yanktools_redirect_keys           = ['d', 'D']
    let g:yanktools_redir_paste_prefix      = '<leader>'

    let g:yanktools_replace_operator        = 's'
    let g:yanktools_replace_line            = 'ss'
    let g:yanktools_replace_operator_bh     = 1
    let g:yanktools_use_single_stack        = 0

    let g:yanktools_format_prefix           = '<'
    let g:yanktools_zeta_prefix             = 'z'
    let g:yanktools_zeta_kill               = 'K'
    let g:yanktools_redirect_register       = 'x'
    let g:yanktools_move_cursor_after_paste = 0
    let g:yanktools_auto_format_all         = 0

|Plug                    |            | Default   |
|------------------------|------------|-----------|
|Paste_                  |(key)   | key     |
|PasteIndent_            |(key)   | `<` key    |
|PasteRedirected_        |(key)   | key     |
|PasteRedirectedIndent_  |(key)   | `<` key    |
|                        |        |          |
|ReplaceOperator         |        |`s`        |
|ReplaceLine             |        |`ss`        |
|ReplaceLineMulti        |        |`<leader>ss`|
|                        |        |          |
|ZetaYank_               |(key)   | z key   |
|ZetaKillMotion          |        | K        |
|ZetaKillLine            |        | KK       |
|ZetaPaste_              |(key)   | z key   |
|ZetaPasteIndent_        |(key)   | `<`z key  |
|                        |        |          |
|SwapPasteNext           |        |`<M-p>`     |
|SwapPastePrevious       |        |`<M-P>`     |
|                        |        |         |
|ToggleAutoIndent        |        |`<C-K>yi` |
|DeleteYanks             |        |`<C-K>yd` |
|ShowYanks               |        |`<C-K>ys` |
|ConvertYank             |        |`<C-K>yc` |
|FreezeYank              |        |`<C-K>yf` |
|IPasteAfter             |        |`<C-K>p` |
|IPasteBefore            |        |`<C-K>P` |
|IPasteSelect            |        |`<C-K>Y` |

----------------------------------------------------------------------------


#### Convenient remaps

By setting this option, you can enable these keymappings, inspired by
vim-unimpaired. They are optimal for a US keyboard, so you may need to
change them anyway (like I did). Either set the option, or paste this into
your .vimrc and change them according to your needs.

```
  { other options here }
  let g:yanktools_convenient_remaps = 1
  call yanktools#init#maps()
```

Or add:

```
  { other options here }
  call yanktools#init#maps()

  nmap Y y$
  nmap S s$
  nmap sx "xs
  nmap sxx "xss
  nmap sX "xs$
  nmap zY zy$
  nmap zK zk$

  xmap Y $hy
  xmap D $hd
  xmap X $hp
  xmap sx "xp
  xmap sX $h"xp
  xmap zY $zy
  xmap zK $zk

  map [p <Plug>PasteIndent_P
  map ]p <Plug>PasteIndent_p
  map =p <Plug>PasteRedirectedIndent_p
  map -p <Plug>PasteRedirectedIndent_P
```


----------------------------------------------------------------------------


### Credits

Braam Moolenaar for Vim  
Steve Vermeulen for vim-easyclip  
Max Brunsfeld for vim-yankstack  



----------------------------------------------------------------------------


### License

MIT



