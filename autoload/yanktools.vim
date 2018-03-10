""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:default_reg()
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

function! s:update_stack()
    let stack = g:yanktools_stack
    let types = s:yanktools_types
    let reg = eval("@".s:default_reg())
    let type = getregtype(reg)
    let ix = index(stack, reg)

    if empty(stack)
        call add(stack, reg) | call add(types, type)
    elseif ix == -1
        call insert(stack, reg) | call insert(types, type)
    else

        call remove(stack, ix) | call remove(types, ix)
        call insert(stack, reg) | call insert(types, type)
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:was_last_change_paste()
    return b:changedtick == s:last_paste_tick
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init_vars()
    let g:yanktools_stack = []
    let s:last_paste_tick = 0
    let s:yanktools_types = []
    let s:redirected_reg = 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
    call s:update_stack()
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
    call setreg(s:r[0], s:r[1], s:r[2])
    let s:redirected_reg = 0
    return ''
endfun

function! yanktools#redirect_reg_with_key(key)
    let s:redirected_reg = 1
    let r = s:default_reg()
    let s:r = [r, getreg(r), getregtype(r)]
    return "\"".g:yanktools_redirect_register . a:key
endfunction

function! yanktools#paste_with_key(key)
    if s:redirected_reg
        call yanktools#restore_after_redirect()
    endif
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward)

    if !s:was_last_change_paste()
        call s:update_stack()
        normal P
        let s:offset = 0
        let s:yanks = len(g:yanktools_stack)
        let s:last_paste_tick = b:changedtick
        return
    endif

    let rg = s:default_reg()
    let oldregtype = getregtype(rg)
    let oldreg = getreg(rg)

    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= s:yanks
        let s:offset = 0
    elseif s:offset < 0
        let s:offset = s:yanks-1
    endif

    "let text = g:yanktools_stack()[s:offset]['text']
    let text = g:yanktools_stack[s:offset]
    let type = s:yanktools_types[s:offset]
    call setreg(rg, text, type)

    exec 'normal uP'
    call setreg(rg, oldreg, oldregtype)
    let s:last_paste_tick = b:changedtick
endfunction


