""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init_vars()
    call yanktools#clear_yanks()
    let s:last_paste_tick = -1
    let g:yanktools#redirected_reg = 0
    let s:has_yanked = 0
endfunction

function! yanktools#clear_yanks()
    let r = yanktools#default_reg()
    let g:yanktools_stack = [{'text': eval("@".r), 'type': getregtype(r)}]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#default_reg()
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

function! yanktools#update_stack()
    let stack = g:yanktools_stack
    let r = yanktools#default_reg() | let text = eval("@".r) | let type = getregtype(r)
    let ix = index(stack, {'text': text, 'type': type})

    if ix == -1
        call insert(stack, {'text': text, 'type': type})
    else
        call remove(stack, ix)
        call insert(stack, {'text': text, 'type': type})
    endif

    let s:yanks = len(stack)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:was_last_change_paste()
    return b:changedtick == s:last_paste_tick
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
    call yanktools#update_stack()
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
    call setreg(s:r[0], s:r[1], s:r[2])
    let g:yanktools#redirected_reg = 0
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#redirect_reg_with_key(key, register)
    let g:yanktools#redirected_reg = 1
    let r = yanktools#default_reg()
    let s:r = [r, getreg(r), getregtype(r)]
    let reg = a:register==r ? g:yanktools_redirect_register : a:register
    return "\"" . reg . a:key
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_with_key(key)
    let s:last_paste_tick = b:changedtick + 1
    if s:has_yanked | call yanktools#update_stack() | endif
    let s:offset = 0 | let s:last_paste_key = a:key
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward, key)

    if !s:was_last_change_paste()
        if s:has_yanked | call yanktools#update_stack() | endif
        " recursive mapping to trigger yanktools#paste_with_key()
        execute "normal ".a:key
        "let s:offset = 0 | let s:last_paste_key = a:key
        return
    endif

    let rg = yanktools#default_reg()
    let oldregtype = getregtype(rg)
    let oldreg = getreg(rg)

    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= s:yanks
        let s:offset = 0
    elseif s:offset < 0
        let s:offset = s:yanks-1
    endif

    let text = g:yanktools_stack[s:offset]['text']
    let type = g:yanktools_stack[s:offset]['type']
    call setreg(rg, text, type)

    exec 'normal! u'.s:last_paste_key
    call setreg(rg, oldreg, oldregtype)
    let s:last_paste_tick = b:changedtick
endfunction


