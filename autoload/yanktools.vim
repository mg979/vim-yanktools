""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init_vars()
    call yanktools#clear_yanks()
    call yanktools#zeta#init_vars()
    let s:last_paste_tick = -1
    let s:yanktools_redirected_reg = 0
    let g:yanktools_auto_format_this = 0
    let g:yanktools_has_pasted = 0
    let s:has_yanked = 0
    let s:yanks = 1
    let s:yanktools_is_replacing = 0
    let s:last_paste_format_this = 0
endfunction

function! yanktools#clear_yanks()
    let r = yanktools#get_reg()
    let g:yanktools_stack = [{'text': r[1], 'type': r[2]}]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocmd TextChanged call
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:replace_text()
    let s:yanktools_is_replacing = 0
    normal! P
    let &virtualedit = s:oldvmode
endfunction

function! s:is_being_formatted(...)
    let all = g:yanktools_auto_format_all | let this = a:0 ? s:last_paste_format_this : g:yanktools_auto_format_this
    echom all." ".this." ".g:yanktools_auto_format_this
    return (all && !this) || (!all && this)
endfunction

function! yanktools#on_text_change()
    if g:yanktools_has_pasted
        let g:yanktools_has_pasted = 0

        " restore register after redirection
        if s:yanktools_redirected_reg
            call yanktools#restore_after_redirect()
            if s:yanktools_is_replacing | call s:replace_text() | endif
            return
        endif

        " replace operator
        if s:yanktools_is_replacing | call s:replace_text() | return | endif

        " autoformat
        if s:is_being_formatted()
            normal! `[=`]
        endif
        let g:yanktools_auto_format_this = 0

        if g:yanktools_move_cursor_after_paste | execute "normal `]" | endif
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Default register
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#get_reg()

    " get default register
    let clipboard_flags = split(&clipboard, ',')
    if index(clipboard_flags, 'unnamedplus') >= 0
        let r = "+"
    elseif index(clipboard_flags, 'unnamed') >= 0
        let r = "*"
    else
        let r = "\""
    endif

    let s:r = [r, getreg(r), getregtype(r)]
    return s:r
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Update stack
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#update_stack()
    let stack = g:yanktools_stack
    let r = yanktools#get_reg() | let text = r[1] | let type = r[2]
    let ix = index(stack, {'text': text, 'type': type})

    if ix == -1
        call insert(stack, {'text': text, 'type': type})
    else
        call remove(stack, ix)
        call insert(stack, {'text': text, 'type': type})
    endif

    let s:yanks = len(stack)
    let s:has_yanked = 0
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
    call yanktools#update_stack()
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_with_key(key, ...)

    " prepare autoformat
    if a:0 | let g:yanktools_auto_format_this = 1 | endif
    let g:yanktools_has_pasted = 1

    " check if register needs to be restored
    if s:yanktools_redirected_reg | call yanktools#restore_after_redirect() | endif

    " after pasting, b:changedtick will increase, update s:last_paste_key to match it
    let s:last_paste_tick = b:changedtick + 1

    " update stack before pasting, if needed
    if s:has_yanked | call yanktools#update_stack() | endif

    " reset stack offset, so that next swap will start from 0
    let s:offset = 0

    " set last_paste_key and remember format_this option (used by swap)
    let s:last_paste_key = a:key
    let s:last_paste_format_this = g:yanktools_auto_format_this

    return a:key
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#replace(line)
    let g:yanktools_has_pasted = 1
    let s:yanktools_is_replacing = 1
    let reg = g:yanktools_replace_operator_bh ? "\"_" : ""
    let s:oldvmode = &virtualedit | set virtualedit=onemore
    if a:line | return reg.'dd' | else | return reg.'d' | endif
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirect
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
    call setreg(s:r[0], s:r[1], s:r[2])
    let s:yanktools_redirected_reg = 0
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_redirected_with_key(key, register, ...)
    if a:0 | let g:yanktools_auto_format_this = 1 | endif
    let g:yanktools_has_pasted = 1
    return '"'.a:register.a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#redirect_reg_with_key(key, register)
    let s:yanktools_redirected_reg = 1
    let g:yanktools_has_pasted = 1
    call yanktools#get_reg()
    let reg = a:register==s:r[0] ? g:yanktools_redirect_register : a:register
    return "\"" . reg . a:key
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:was_last_change_paste()
    if s:is_being_formatted(1)
        return b:changedtick <= s:last_paste_tick + 1
    else
        return b:changedtick == s:last_paste_tick
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward, key)

    if !s:was_last_change_paste()
        if s:has_yanked | call yanktools#update_stack() | endif
        " recursive mapping to trigger yanktools#paste_with_key()
        execute "normal ".a:key
        return
    endif

    let r = yanktools#get_reg()

    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= s:yanks
        let s:offset = 0
    elseif s:offset < 0
        let s:offset = s:yanks-1
    endif

    let text = g:yanktools_stack[s:offset]['text']
    let type = g:yanktools_stack[s:offset]['type']
    call setreg(r[0], text, type)

    " set flag before actual paste
    let g:yanktools_has_pasted = 1

    if s:last_paste_format_this | let g:yanktools_auto_format_this = 1 | endif
    exec 'normal! u'.s:last_paste_key
    call setreg(r[0], r[1], r[2])
    let s:last_paste_tick = b:changedtick
endfunction

