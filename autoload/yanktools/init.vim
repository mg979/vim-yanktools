""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    call yanktools#init_vars()

    if !exists('g:yanktools_paste_keys ')
        let g:yanktools_paste_keys  = ['p', 'P', 'gp', 'gP']
    endif

    if !exists('g:yanktools_yank_keys')
        let g:yanktools_yank_keys = ['y', 'Y']
    endif

    if !exists('g:yanktools_redirect_register')
        let g:yanktools_redirect_register = "x"
    endif
    let redirect = g:yanktools_redirect_register

    if !exists('g:yanktools_black_hole_keys')
        let g:yanktools_black_hole_keys = ['x','X','s','S']
    endif

    if !exists('g:yanktools_redirect_keys')
        let g:yanktools_redirect_keys = ['c', 'C', 'd', 'D']
    endif

    for key in g:yanktools_yank_keys
        if !hasmapto('<Plug>Yank_'.key)
            exec 'nmap <unique> '.key.' <Plug>Yank_'.key
            exec 'xmap <unique> '.key.' <Plug>Yank_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>Yank_'.key.' yanktools#yank_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>Yank_'.key.' yanktools#yank_with_key("' . key . '")'
    endfor

    for key in g:yanktools_black_hole_keys
        if !hasmapto('<Plug>Black_Hole_'.key)
            exec 'nmap <unique> '.key.' <Plug>Black_Hole_'.key
            exec 'xmap <unique> '.key.' <Plug>Black_Hole_'.key
        endif
        exec 'nnoremap <silent> <Plug>Black_Hole_'.key.' "_'.key
        exec 'xnoremap <silent> <Plug>Black_Hole_'.key.' "_'.key
    endfor

    for key in g:yanktools_redirect_keys
        if !hasmapto('<Plug>RegRedirect_'.key)
            exec 'nmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
            exec 'xmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
        exec 'xnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
        "exec 'nnoremap <silent> <Plug>RegRedirect_"'.redirect.'_'.key.' "'.redirect.key
        "exec 'xnoremap <silent> <Plug>RegRedirect_"'.redirect.'_'.key.' "'.redirect.key
    endfor

    if !hasmapto('<Plug>PasteRedirected')
        nmap <unique> zp <Plug>PasteRedirectedAfter
        vmap <unique> zp <Plug>PasteRedirectedAfter
    endif
    if !hasmapto('<Plug>PasteRedirectedBefore')
        nmap <unique> zP <Plug>PasteRedirectedBefore
    endif
    exec 'nnoremap <silent> <Plug>PasteRedirectedAfter "'.redirect.'p'
    exec 'xnoremap <silent> <Plug>PasteRedirectedAfter "'.redirect.'p'
    exec 'nnoremap <silent> <Plug>PasteRedirectedBefore "'.redirect.'P'

    for key in g:yanktools_paste_keys
        if !hasmapto('<Plug>Paste_'.key)
            exec 'nmap <unique> '.key.' <Plug>Paste_'.key
            exec 'xmap <unique> '.key.' <Plug>Paste_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
    endfor

    if !exists('g:yanktools_map_keys') || g:yanktools_map_keys
        nmap <unique> <M-p> <Plug>SwapPasteNext
        nmap <unique> <M-P> <Plug>SwapPastePrevious
        nnoremap <silent> <Plug>SwapPasteNext :call yanktools#swap_paste(1)<cr>
        nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0)<cr>
    endif
endfunction
