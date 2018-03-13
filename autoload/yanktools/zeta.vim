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

function! yanktools#zeta#paste_with_key(key, ...)
    if s:has_yanked | call yanktools#zeta#update_stack() | endif
    if !len(g:yanktools_zeta_stack) | echo "Empty zeta stack." | return | endif

    " backup register
    let r = yanktools#get_reg()

    " set register
    let text = g:yanktools_zeta_stack[0]['text']
    let type = g:yanktools_zeta_stack[0]['type']
    call setreg(r[0], text, type)

    " invert paste behaviour if paste is linewise
    if g:yanktools_zeta_inverted && type ==# 'V'
        if a:key ==# 'p' | let key = 'P' | else | let key = 'p' | endif
    else
        let key = a:key
    endif

    " remove index from zeta stack
    call remove(g:yanktools_zeta_stack, 0)

    let g:yanktools_has_pasted = 1
    " perform paste and move cursor at end, autoformat if arg is given
    if a:0
        exec 'normal! '.key.'`[=`]`]'
    else
        exec 'normal! '.key.'`]'
    endif

    " move to line below if paste was linewise
    if type ==# 'V'
        normal j
    endif

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

