""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#yank_with_key(key)
    if get(s:, 'has_yanked', 0) | call yanktools#zeta#update_stack() | endif
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#paste_with_key(key)
    if s:has_yanked | call yanktools#zeta#update_stack() | endif
    if !len(g:yanktools_zeta_stack) | echo "Empty zeta stack." | return | endif

    " backup register
    let dr = yanktools#default_reg()
    let r = [dr, getreg(dr), getregtype(dr)]

    " set register
    let text = g:yanktools_zeta_stack[0]['text']
    let type = g:yanktools_zeta_stack[0]['type']
    call setreg(dr, text, type)

    " remove index from zeta stack
    call remove(g:yanktools_zeta_stack, 0)

    " preform paste
    exec 'normal! '.a:key

    " restore register
    call setreg(r[0], r[1], r[2])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#update_stack()

    " duplicate yanks will be added to this stack nonetheless
    let stack = g:yanktools_zeta_stack
    let r = yanktools#default_reg() | let text = eval("@".r) | let type = getregtype(r)
    call add(stack, {'text': text, 'type': type})
    let s:has_yanked = 0
endfunction

