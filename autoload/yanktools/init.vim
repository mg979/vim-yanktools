""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    call yanktools#init_vars()
    "let paste_keys = ['p', 'P', 'gp', 'gP']
    let paste_keys = []

    if !exists('g:yanktools_yank_keys')
        let g:yanktools_yank_keys = ['y', 'Y']
    endif

    if !exists('g:yanktools_redirect_register')
        let g:yanktools_redirect_register = "x"
    endif
    let rr = g:yanktools_redirect_register

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
            exec 'nmap <unique> '.key.' <Plug>RegRedirect_"'.rr.'_'.key
            exec 'xmap <unique> '.key.' <Plug>RegRedirect_"'.rr.'_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>RegRedirect_"'.rr.'_'.key.' yanktools#redirect_reg_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>RegRedirect_"'.rr.'_'.key.' yanktools#redirect_reg_with_key("' . key . '")'
    endfor

    if !hasmapto('<Plug>PasteRedirected'.key)
        nmap <unique> zP <Plug>PasteRedirectedBefore
        nmap <unique> zp <Plug>PasteRedirected
        xmap <unique> zp <Plug>PasteRedirected
    endif
    exec 'nnoremap <silent> <Plug>PasteRedirected       "'.g:yanktools_redirect_register.'p'
    exec 'nnoremap <silent> <Plug>PasteRedirectedBefore "'.g:yanktools_redirect_register.'P'
    exec 'xnoremap <silent> <Plug>PasteRedirected       "'.g:yanktools_redirect_register.'p'

    for key in paste_keys
        if !hasmapto('<Plug>Paste_'.key)
            exec 'nmap <unique> '.key.' <Plug>Paste_'.key
            exec 'xmap <unique> '.key.' <Plug>Paste_'.key
        endif
        exec 'nnoremap <silent> <Plug>Paste :<C-u>call <SID>paste_with_key("' . key . '", "n", v:register, v:count1)<CR>'
        exec 'xnoremap <silent> <Plug>Paste :<C-u>call <SID>paste_with_key("' . key . '", "v", v:register, v:count1)<CR>'
    endfor

    if !exists('g:yanktools_map_keys') || g:yanktools_map_keys
        nmap <unique> <M-p> <Plug>SwapPasteNext
        nmap <unique> <M-P> <Plug>SwapPastePrevious
        nnoremap <silent> <Plug>SwapPasteNext :call yanktools#swap_paste(1)<cr>
        nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0)<cr>
    endif
"1
"2
"3
"4
"5
endfunction

