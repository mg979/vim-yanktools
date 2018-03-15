""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#init_vars()
    let g:yanktools_zeta_stack = []
    let s:has_yanked = 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#yank_with_key(key)
    if s:has_yanked | call yanktools#zeta#update_stack() | endif
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#paste_with_key(key, plug, ...)
    if s:has_yanked | call yanktools#zeta#update_stack() | endif
    if !len(g:yanktools_zeta_stack) | echo "Empty zeta stack." | return | endif

    " set vars
    let g:yanktools_has_pasted = 1
    let g:yanktools_move_this = 1
    if a:0 | let g:yanktools_auto_format_this = 1 | endif
    let g:yanktools_plug = [a:plug, v:count, yanktools#default_reg()]

    " backup register
    let r = yanktools#get_reg()

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

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#update_stack()

    " duplicate yanks will be added to this stack nonetheless
    let stack = g:yanktools_zeta_stack
    let r = yanktools#get_reg()
    call add(stack, {'text': r[1], 'type': r[2]})
    let s:has_yanked = 0
endfunction

