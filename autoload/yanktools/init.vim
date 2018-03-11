""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    if !exists('g:yanktools_auto_swap')
        let g:yanktools_auto_swap = 0
    endif

    if !exists('g:yanktools_paste_keys')
        let g:yanktools_paste_keys = ['p', 'P', 'gp', 'gP']
    endif

    if !exists('g:yanktools_yank_keys')
        let g:yanktools_yank_keys = ['y', 'Y']
    endif

    if !exists('g:yanktools_redirect_register')
        let g:yanktools_redirect_register = "x"
    endif
    let redirect = g:yanktools_redirect_register

    if !exists('g:yanktools_black_hole_keys')
        let g:yanktools_black_hole_keys = ['x','X','s','S','gr']
    endif

    if !exists('g:yanktools_redirect_keys')
        let g:yanktools_redirect_keys = ['c', 'C', 'd', 'D']
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Yank keys
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_yank_keys
        if !hasmapto('<Plug>Yank_'.key)
            exec 'nmap <unique> '.key.' <Plug>Yank_'.key
            exec 'xmap <unique> '.key.' <Plug>Yank_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>Yank_'.key.' yanktools#yank_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>Yank_'.key.' yanktools#yank_with_key("' . key . '")'
    endfor

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Redirection
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
    endfor

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste redirected
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>PasteRedirectedAfter')
        nmap <unique> zp <Plug>PasteRedirectedAfter
    endif
    if !hasmapto('<Plug>PasteRedirectedBefore')
        nmap <unique> zP <Plug>PasteRedirectedBefore
    endif
    if !hasmapto('<Plug>PasteRedirectedVisual')
        xmap <unique> zp <Plug>PasteRedirectedVisual
    endif
    exec 'nnoremap <silent> <Plug>PasteRedirectedAfter "'.redirect.'p'
    exec 'nnoremap <silent> <Plug>PasteRedirectedBefore "'.redirect.'P'
    exec 'xnoremap <silent> <Plug>PasteRedirectedVisual "'.redirect.'p'

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste keys
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_paste_keys
        if !hasmapto('<Plug>Paste_'.key)
            exec 'nmap <unique> '.key.' <Plug>Paste_'.key
            exec 'xmap <unique> '.key.' <Plug>Paste_'.key
        endif
        if g:yanktools_auto_swap
            exec "nnoremap <silent> <Plug>Paste_".key." :call yanktools#swap_paste(1, '".key."')\<cr>"
            exec "xnoremap <silent> <Plug>Paste_".key." :call yanktools#swap_paste(1, '".key."')\<cr>"
        else
            exec 'nnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
            exec 'xnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
        endif
    endfor

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Swap pastes
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !g:yanktools_auto_swap && (!exists('g:yanktools_map_keys') || g:yanktools_map_keys)
        nmap <unique> <M-p> <Plug>SwapPasteNext
        nmap <unique> <M-P> <Plug>SwapPastePrevious
        nnoremap <silent> <Plug>SwapPasteNext :call yanktools#swap_paste(1, "P")<cr>
        nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0, "P")<cr>
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Clear yanks
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>ClearYanks')
        nmap <unique> <C-K>cy <Plug>ClearYanks
    endif
    nnoremap <silent> <Plug>ClearYanks :call yanktools#clear_yanks()<cr>

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Show yanks
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>ShowYanks')
        nmap <unique> <C-K>sy <Plug>ShowYanks
    endif
    nnoremap <silent> <Plug>ShowYanks :call yanktools#extras#show_yanks()<cr>

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Interactive Paste
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>IPaste')
        nmap <unique> <C-K>p <Plug>IPasteAfter
        nmap <unique> <C-K>P <Plug>IPasteBefore
    endif
    nnoremap <silent> <expr> <Plug>IPasteAfter  g:loaded_fzf ? ":FzfPasteAfter\<cr>"  : ":IPaste\<cr>"
    nnoremap <silent> <expr> <Plug>IPasteBefore g:loaded_fzf ? ":FzfPasteBefore\<cr>" : ":IPasteBefore\<cr>"

endfunction
