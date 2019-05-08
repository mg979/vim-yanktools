""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#zeta#yank_with_key(key)
    let s:v.zeta = 1
    let s:v.has_yanked = 1
    call s:F.updatetime(0)
    return a:key
endfunction

function! yt#zeta#del_with_key(key)
    let s:v.zeta = 1
    let s:v.has_changed = 1
    let s:v.has_yanked = 1
    call s:F.store_register()
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#zeta#paste_with_key(key, plug, format)
    let Z = g:yanktools.zeta
    if Z.is_empty() | return | endif

    " set vars
    let s:v.format_this = a:format
    let s:v.plug = [a:plug, v:count, s:F.default_reg()]

    if a:key ==# 'p'
      let s:v.move_this = 1
      let post = ''
    else
      let s:v.move_this = 0
      let post = '`['
    endif

    " backup register
    let r = s:F.store_register()

    " pop an item from the stack and perform paste
    call Z.pop_stack()
    exec 'normal!' a:key.post

    call s:F.restore_register()
    call s:F.msg("There are " . len(Z.stack) . " entries left in the zeta stack.")
endfunction

