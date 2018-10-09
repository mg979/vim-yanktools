""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#init_vars()
    let g:yanktools_zeta_stack = []
    let s:has_yanked = 0
    let s:has_killed = 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#update_stack(redirected)

    " duplicate yanks will be added to this stack nonetheless
    if a:redirected
        let r = yanktools#get_reg(a:redirected)
    else
        let r = yanktools#get_reg(0)
    endif
    call add(g:yanktools_zeta_stack, {'text': r[1], 'type': r[2]})
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#yank_with_key(key)
    let s:has_yanked = 1
    call yanktools#zeta_call()
    return a:key
endfunction

function! yanktools#zeta#kill_with_key(key)
    let s:has_killed = 1
    call yanktools#zeta_call()
    return "\"".g:yanktools_redirect_register.a:key
endfunction

function! yanktools#zeta#check_stack()
    if s:has_yanked | let s:has_yanked = 0 | call yanktools#zeta#update_stack(0) | endif
    if s:has_killed | let s:has_killed = 0 | call yanktools#zeta#update_stack(1) | endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#paste_with_key(key, plug, visual, format)
    call yanktools#zeta#check_stack()
    if !len(g:yanktools_zeta_stack) | return yanktools#msg("Empty zeta stack.") | endif

    " set vars
    let g:yanktools_has_changed = 1
    let g:yanktools_move_this = 1
    if a:format | let g:yanktools_auto_format_this = 1 | endif
    let g:yanktools_plug = [a:plug, v:count, yanktools#default_reg()]

    " backup register
    let r = yanktools#get_reg(0)

    " set register
    let text = g:yanktools_zeta_stack[0]['text']
    let type = g:yanktools_zeta_stack[0]['type']
    call setreg(r[0], text, type)

    " remove index from zeta stack
    call remove(g:yanktools_zeta_stack, 0)

    " perform paste
    exec 'normal! '.a:key

    " restore register
    call setreg(r[0], r[1], r[2])
    call yanktools#msg("There are ".len(g:yanktools_zeta_stack)." entries left in the zeta stack.")
endfunction

