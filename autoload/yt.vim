"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Variables {{{1
let s:post_paste_pos = []
let s:has_pasted = 0
let s:last_paste_format_this = 0
let s:last_paste_key = 0
let s:last_paste_tick = -1

let s:F = g:yanktools.Funcs

let s:v = g:yanktools.vars
let s:v.replacing    = 0
let s:v.restoring    = 0
let s:v.has_yanked   = 0
let s:v.has_changed  = 0
let s:v.move_this    = 0
let s:v.format_this  = 0
let s:v.zeta         = 0
let s:v.updatetime   = &updatetime

let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta
let s:A = g:yanktools.auto
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommand calls
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" called on TextYankPost or after &updatetime
""
function! yt#check_yanks()
    "{{{1
    if s:VM() && !s:v.zeta | return
    elseif s:v.has_yanked  | call s:update_yanks()
    else                   | call s:A.update_stack()
    endif
endfunction "}}}

""
" update stacks after a yank/deletion
""
function! s:update_yanks()
    "{{{1
    if s:v.zeta            | call s:Z.update_stack()
    else                   | call s:Y.update_stack()
    endif
    let s:v.has_yanked = 0
endfunction "}}}

""
" Reset swap state if cursor moved after finishing swap.
" s:v.has_changed must be 0 because this must run after on_text_change()
""
function! yt#check_swap()
    "{{{1
    if s:has_pasted && !s:v.has_changed && getpos('.') != s:post_paste_pos
        let s:has_pasted = 0
        let s:post_paste_pos = getpos('.')
        let s:last_paste_tick = b:changedtick
    endif
endfunction "}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" called on TextChanged event
""
function! yt#on_text_change()
    "{{{1
    if s:v.has_yanked   | call s:update_yanks() | endif
    if !s:v.has_changed | return                | endif
    if s:VM()           | return s:reset_vars() | endif

    " restore register if necessary
    if s:v.restoring | call s:F.restore_register() | endif

    " autoformat / move cursor, and ensure CursorMoved is triggered
    if s:is_being_formatted()   | execute "keepjumps normal! `[=`]" | endif
    if s:is_moving_at_end()     | execute "keepjumps normal! `]"    | endif
    call s:F.ensure_cursor_moved()

    " record position and tick (used by swap)
    let s:last_paste_tick = b:changedtick
    let s:post_paste_pos = getpos('.')
    call s:reset_vars()
endfunction "}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Function: yt#yank_with_key
" Prepare to add the yanked text into the stack.
" @param key: the key used to yank
" Returns: the key itself
""
function! yt#yank_with_key(key)
    "{{{1
    if s:VM() | return a:key | endif
    let s:v.has_yanked = 1
    call s:F.updatetime(0)
    return a:key
endfunction "}}}


""
" Function: yt#paste_with_key
" Paste and set variables used by swap paste.
" @param key:    the key used to paste
" @param visual: called from visual mode
" @param indent: reindent after paste
" Returns: the key itself
""
function! yt#paste_with_key(key, visual, indent)
    "{{{1
    if a:visual | call s:F.store_register() | endif
    " set paste variables
    let s:v.has_changed = 1 | let s:has_pasted = 1
    " set last_paste_key and remember format_this option (used by swap)
    let s:last_paste_key = a:key
    let s:last_paste_format_this = a:indent

    if a:indent && getregtype(v:register) == 'V'
        let s:paste_pre = printf('%s"%s', v:count, v:register)
        let &operatorfunc = 'yt#paste_' . (a:key ==# 'P' ? 'above' : 'below')
        return 'g@^'
    else
        return a:key
    endif
endfunction

function! yt#paste_above(type)
    exe 'normal!' s:paste_pre . 'P`[=`]`['
endfunction

function! yt#paste_below(type)
    exe 'normal!' s:paste_pre . 'p`[=`]`]'
endfunction "}}}





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Delete operator
""
function! yt#delete(count, register, visual)
    "{{{1
    if a:visual
        call s:deleting()
        return "\"" . a:register . 'd'
    endif

    let n = a:count > 1 ? string(a:count) : ''
    let s:register = a:register
    set opfunc=yt#del_opfunc
    return ":\<c-u>\<cr>".n.'g@'
endfunction

function! yt#del_opfunc(type)
    call s:deleting()
    if a:type == 'line' | keepjumps normal! `[V`]
    else                | keepjumps normal! `[v`]
    endif
    execute "normal! \"".s:register."d"
endfunction "}}}




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Preserve unnamed register
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Function: yt#redirect
" If a register is specified, no change from vim, otherwise unnamed register
" is restored after change.
" @param key:      the key used (c,x,X)
" @param register: the register used
" @param save:     if the deleted text must be saved in the yank stack
" Returns: the key itself
""
function! yt#redirect(key, register, save)
    "{{{1
    if a:register == s:F.default_reg()
        call s:F.store_register()
        let s:v.has_yanked = a:save
    endif
    return a:key
endfunction "}}}



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Swap previous paste with the next (or previous) element in the yank stack.
" If called without pasting anything, perform a P paste with the current
" element in the yank stack.
""
function! yt#swap_paste(forward, auto_stack)
    "{{{1
    let stack = a:auto_stack ? s:A : s:Y
    if stack.is_empty() | return | endif

    " ensure register and stack are synched
    let was_synched = stack.synched()

    if !s:has_pasted || ( b:changedtick != s:last_paste_tick )
        execute "normal P"
        return
    endif

    "---------------------------------------------------------------------------

    " enable lazyredraw for better statusline message
    let s:v.lz = &lazyredraw | set lz

    " move stack offset and get return message code
    " if stack wasn't synched, it has been moved already (to the current offset)
    let result = was_synched ? stack.move_offset(a:forward ? 1 : -1) : 0

    " set register to offset
    call stack.update_register()

    " set flag before actual paste, so that autocmd call will run
    let s:has_pasted = 1 | let s:v.has_changed = 1

    " perform a non-recursive paste, but reuse last options and key
    let s:v.format_this = s:last_paste_format_this
    exec 'normal! u'.s:last_paste_key

    " update position, because using non recursive paste
    let s:post_paste_pos = getpos('.')

    call s:msg(stack, result)
endfunction "}}}



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""
" Mappings: ]y, [y
" Switch to the next/previous element in the yank stack.
" Echo the selected element in a popup, or in the command line.
""
function! yt#offset(count, visual)
    "{{{1
    if s:Y.is_empty() | return | endif

    " move stack offset and set register
    if s:Y.synched()
        call s:Y.move_offset(a:count)
    endif
    call s:Y.update_register()

    " show register in popup or command line
    if !s:F.popup(s:Y)
        echohl Label
        echo printf('[%d/%d] ', s:Y.offset+1, s:Y.size())
        echohl None
        echon split(s:Y.get().text, '\n')[0][:(&columns-10)]
    endif

    if a:visual
        normal! gv
    endif
endfunction "}}}



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:is_being_formatted()
    "{{{1
    let all = g:yanktools_autoindent
    let this = s:v.format_this
    return (all && !this) || (!all && this)
endfunction "}}}

function! s:is_moving_at_end()
    "{{{1
    return s:v.move_this
endfunction "}}}

function! s:msg(stack, n)
    "{{{1
    redraw
    echo "Yank stack position: " . (a:stack.offset + 1) . "/" . a:stack.size()
    if a:n
        echohl WarningMsg
        if a:n == 1 | echon " restarting from the beginning"
        else        | echon " restarting from the end"
        endif
        echohl None
    endif
    let &lazyredraw = s:v.lz
endfunction "}}}

function! s:reset_vars()
    " "{{{1
    " reset vars
    let s:v.has_changed = 0
    let s:v.replacing = 0
    let s:v.format_this = 0
    let s:v.move_this = 0
    let s:v.restoring = 0
    let s:v.zeta = 0
    let s:v.has_yanked = 0
    call s:F.updatetime(1)
endfunction "}}}

function! s:deleting()
    "{{{1
    let s:v.has_changed = 1
    let s:v.has_yanked = 1
endfunction "}}}

function! s:VM() abort
    "{{{1
    return exists('b:visual_multi')
endfunction "}}}

" vim: ft=vim et sw=4 ts=4 sts=4 fdm=marker
