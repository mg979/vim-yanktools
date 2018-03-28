""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init_vars()
    call yanktools#extras#clear_yanks()
    call yanktools#zeta#init_vars()
    call yanktools#replop#init()
    let s:yanktools_redirected_reg = 0
    let g:yanktools_auto_format_this = 0
    let g:yanktools_has_changed = 0
    let s:has_yanked = 0
    let s:has_pasted = 0
    let s:using_redir_stack = 0
    let g:yanktools_is_replacing = 0
    let s:last_paste_format_this = 0
    let g:yanktools_plug = []
    let g:yanktools_move_this = 0
    let s:freeze_offset = 0
    let s:replace_count = 0
    let s:zeta = 0
    let s:offset = 0
    let s:last_paste_key = 0
    let s:last_paste_tick = -1
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#set_repeat()
    let p = g:yanktools_plug
    silent! call repeat#setreg("\<Plug>".p[0], p[2])
    silent! call repeat#set("\<Plug>".p[0], p[1])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta_call()
    let s:zeta = 1 | let s:has_yanked = 1
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#default_reg()
    " get default register

    let clipboard_flags = split(&clipboard, ',')
    if index(clipboard_flags, 'unnamedplus') >= 0
        return "+"
    elseif index(clipboard_flags, 'unnamed') >= 0
        return "*"
    else
        return "\""
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#get_reg(redir)
    let r = a:redir ? g:yanktools_redirect_register : yanktools#default_reg()

    " asking for redirected register, don't store s:var
    if a:redir | return [r, getreg(r), getregtype(r)] | endif

    " store current register as s:var for later restoring, then return it
    let s:r = [r, getreg(r), getregtype(r)]
    return s:r
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#update_stack(...)
    """Update the yank or redirected stack."""

    if a:0 && !g:yanktools_use_single_stack
        let stack = g:yanktools_redir_stack
    else
        let stack = g:yanktools_stack
    endif

    let r = yanktools#get_reg(a:0) | let text = r[1] | let type = r[2]
    let ix = index(stack, {'text': text, 'type': type})

    " if yank is duplicate, put it upfront removing the previous one
    if ix == -1
        call insert(stack, {'text': text, 'type': type})
    else
        call remove(stack, ix)
        call insert(stack, {'text': text, 'type': type})
    endif
endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommand calls {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:is_being_formatted()
    let all = g:yanktools_auto_format_all
    let this = g:yanktools_auto_format_this
    return (all && !this) || (!all && this)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#check_yanks()
    """This function is called on cursor moved, but also sparsely to update stacks."""

    if s:has_yanked
        if s:zeta  | call yanktools#zeta#check_stack() | endif
        let s:zeta = 0 | let s:has_yanked = 0
        call yanktools#update_stack()
    endif

    if s:has_pasted && !g:yanktools_has_changed
        " reset swap state if cursor moved after finishing swap
        " g:yanktools_has_changed must be 0 because this must run after on_text_change()
        if getpos('.') != s:post_paste_pos
            call yanktools#offset(0)
            let s:has_pasted = 0
            let s:post_paste_pos = getpos('.')
            let s:last_paste_tick = b:changedtick
        endif
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#on_text_change()
    """This function is called on TextChanged event."""

    if s:has_yanked | call yanktools#check_yanks() | endif
    if !g:yanktools_has_changed | return | endif
    let g:yanktools_has_changed = 0

    " restore register after redirection
    if s:yanktools_redirected_reg | call yanktools#restore_after_redirect() | endif

    " replace operator: complete replacement and return
    if g:yanktools_is_replacing | call yanktools#replop#paste_replacement() | return | endif

    " autoformat / move cursor
    if s:is_being_formatted() | execute "keepjump normal! `[=`]" | endif
    if (g:yanktools_move_cursor_after_paste || g:yanktools_move_this) | execute "keepjump normal `]" | endif

    " update repeat.vim
    if !s:yanktools_redirected_reg && !empty(g:yanktools_plug) | call yanktools#set_repeat() | endif

    " record position and tick
    let s:last_paste_tick = b:changedtick | let s:post_paste_pos = getpos('.')

    " reset vars
    let g:yanktools_auto_format_this = 0
    let g:yanktools_move_this = 0
    let s:yanktools_redirected_reg = 0
endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
    if s:has_yanked | call yanktools#check_yanks() | endif
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_with_key(key, plug, visual, format)
    if a:visual | call yanktools#redirecting() | endif
    if a:format | let g:yanktools_auto_format_this = 1 | endif

    " set paste variables
    let g:yanktools_has_changed = 1 | let s:has_pasted = 1

    " set repeat.vim plug
    let g:yanktools_plug = [a:plug, v:count, v:register]

    " set last_paste_key and remember format_this option (used by swap)
    let s:last_paste_key = a:key
    let s:last_paste_format_this = g:yanktools_auto_format_this

    return a:key
endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirect {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
    " don't store empty lines
    if getreg(yanktools#default_reg()) =~ '\w'
        call yanktools#update_stack(1)
    endif
    call setreg(s:r[0], s:r[1], s:r[2])
endfun

fun! yanktools#redirecting()
    let s:yanktools_redirected_reg = 1
    call yanktools#get_reg(0)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_redirected_with_key(key, plug, visual, format)
    if a:format | let g:yanktools_auto_format_this = 1 | endif
    let register = g:yanktools_redirect_register
    let g:yanktools_plug = [a:plug, v:count, register]
    let g:yanktools_has_changed = 1
    let s:has_pasted = 1

    " set last_paste_key and remember format_this option (used by swap)
    let s:last_paste_key = a:key
    let s:last_paste_format_this = g:yanktools_auto_format_this

    " reset stack offset (unless frozen)
    call yanktools#offset(1)

    return '"'.register.a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#redirect_reg_with_key(key, register, ...)

    call yanktools#redirecting()
    let g:yanktools_has_changed = 1

    " key uses black hole or register redirection?
    let redir = a:0 ? "_" : g:yanktools_redirect_register
    " really redirect or a register has been specified?
    let reg = a:register==s:r[0] ? redir : a:register

    return "\"" . reg . a:key
endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move operator {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#move(plug, line)

    if s:has_yanked | call yanktools#check_yanks() | endif
    let s:has_yanked = 1
    let g:yanktools_has_changed = 1

    " set repeat.vim plug
    let g:yanktools_plug = [a:plug, v:count, v:register]

    return a:line ? 'dd' : 'd'
endfunction
"}}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#offset(redir, ...)
    if a:0 | let s:offset = a:1
    elseif !s:freeze_offset | let s:offset = 0 | endif
    let s:using_redir_stack = g:yanktools_use_single_stack ? 0 : a:redir
endfunction

function! s:update_reg(stack)
    let r = yanktools#get_reg(0)
    let text = a:stack[s:offset]['text']
    let type = a:stack[s:offset]['type']
    call setreg(r[0], text, type)
endfunction

function! s:msg(...)
    echohl WarningMsg
    let t = s:using_redir_stack ? 'redirected' : 'yank'
    if a:1 == 3     | echo a:2
    elseif a:1 == 1 | echo "Reached the end of the ".t." stack, restarting from the beginning."
    else            | echo "Reached the beginning of the ".t." stack, restarting from the end."
    endif
    echohl None
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#freeze_offset()
    """Stop resetting the offset, if toggled on. When toggled off, restore the last register."""

    if s:freeze_offset
        let s:freeze_offset = 0
        let r = s:frozenreg
        call setreg(r[0], r[1], r[2])
        call s:msg(3, "Yank offset will be reset normally.")
    else
        let s:frozenreg = yanktools#get_reg(0)
        let s:freeze_offset = 1
        call s:msg(3, "Yank offset won't be reset.")
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward, key, visual)
    let msg = 0

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !s:has_pasted || ( b:changedtick != s:last_paste_tick )

        if s:has_yanked | call yanktools#check_yanks() | endif

        "fetch item to paste directly from the stack
        call s:update_reg(g:yanktools_stack)

        " recursive mapping to trigger yanktools#paste_with_key()
        " if pasting from visual mode, force paste after if last column
        if a:visual && col('.') == col('$')-1
            execute "normal p"
        else
            execute "normal ".a:key
        endif

        "pasted text is taken from the stack, that could contain redirected
        "items, restore previous register in any case
        call setreg(s:r[0], s:r[1], s:r[2])
        return
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if s:using_redir_stack
        let stack = g:yanktools_redir_stack
        let yanks = len(stack)
    else
        let stack = g:yanktools_stack
        let yanks = len(stack)
    endif

    " move offset
    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= yanks
        let s:offset = 0 | let msg = 1
    elseif s:offset < 0
        let s:offset = yanks-1 | let msg = 2
    endif

    " set register to offset
     call s:update_reg(stack)

    " set flag before actual paste, so that autocmd call will run
    let s:has_pasted = 1 | let g:yanktools_has_changed = 1

    " perform a non-recursive paste, but reuse last options and key
    if s:last_paste_format_this | let g:yanktools_auto_format_this = 1 | endif
    exec 'normal! u'.s:last_paste_key

    " update position, because using non recursive paste
    let s:post_paste_pos = getpos('.')

    " restore register (unless frozen)
    if !s:freeze_offset | call setreg(s:r[0], s:r[1], s:r[2]) | endif
    if msg | call s:msg(msg) | endif
endfunction
"}}}

