""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#yank_with_key(key)
    let s:v.zeta = 1
    let s:v.has_yanked = 1
    call s:F.updatetime(0)
    return a:key
endfunction

function! yanktools#zeta#del_with_key(key)
    if !g:yanktools_use_redirection
      return yanktools#zeta#yank_with_key(a:key)
    endif

    call yanktools#redirecting()
    let s:v.zeta = 1
    let s:v.has_yanked = 1
    return "\"".g:yanktools_redirect_register.a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#zeta#paste_with_key(key, plug, visual, format)
    if !len(g:yanktools.zeta.stack) | return s:F.msg("Empty zeta stack.") | endif

    " set vars
    let s:v.has_changed = 1
    let s:v.move_this = 1
    let s:v.format_this = a:format
    let s:v.plug = [a:plug, v:count, s:F.default_reg()]

    " backup register
    let r = s:F.get_register()

    " set register
    let text = g:yanktools.zeta.stack[0]['text']
    let type = g:yanktools.zeta.stack[0]['type']
    call setreg(r[0], text, type)

    " remove index from zeta stack
    call remove(g:yanktools.zeta.stack, 0)

    " perform paste
    exec 'normal! '.a:key

    call s:F.restore_register()
    call s:F.msg("There are ".len(g:yanktools.zeta.stack)." entries left in the zeta stack.")
endfunction

