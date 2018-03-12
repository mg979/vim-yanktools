""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    let g:yanktools_paste_keys              = get(g:, 'yanktools_paste_keys', ['p', 'P', 'gp', 'gP'])
    let g:yanktools_yank_keys               = get(g:, 'yanktools_yank_keys', ['y', 'Y'])
    let g:yanktools_black_hole_keys         = get(g:, 'yanktools_black_hole_keys', ['x','X','s','S','gr'])
    let g:yanktools_redirect_keys           = get(g:, 'yanktools_redirect_keys', ['c', 'C', 'd', 'D'])
    let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
    let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)

    let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")
    let redirect                            = g:yanktools_redirect_register

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
        nmap <unique> <leader>p <Plug>PasteRedirectedAfter
    endif
    if !hasmapto('<Plug>PasteRedirectedBefore')
        nmap <unique> <leader>P <Plug>PasteRedirectedBefore
    endif
    if !hasmapto('<Plug>PasteRedirectedVisual')
        xmap <unique> <leader>p <Plug>PasteRedirectedVisual
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
        exec 'nnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'

        if !hasmapto('<Plug>FormatPaste_'.key)
            exec 'nmap <unique> <'.key.' <Plug>FormatPaste_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>FormatPaste_'.key.' yanktools#paste_with_key("' . key . '", 1)'
    endfor

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Swap pastes
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>SwapPasteNext')
        nmap <unique> <M-p> <Plug>SwapPasteNext
    endif
    if !hasmapto('<Plug>SwapPastePrevious')
        nmap <unique> <M-P> <Plug>SwapPastePrevious
    endif
    nnoremap <silent> <Plug>SwapPasteNext :call yanktools#swap_paste(1, "P")<cr>
    nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0, "P")<cr>

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " "z" mode
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_yank_keys
        if !hasmapto('<Plug>ZetaYank_'.key)
            exec 'nmap <unique> z'.key.' <Plug>ZetaYank_z'.key
            exec 'xmap <unique> z'.key.' <Plug>ZetaYank_z'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>ZetaYank_z'.key.' yanktools#zeta#yank_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>ZetaYank_z'.key.' yanktools#zeta#yank_with_key("' . key . '")'
    endfor

    for key in g:yanktools_paste_keys
        if !hasmapto('<Plug>ZetaPaste_'.key)
            exec 'nmap <unique> z'.key.' <Plug>ZetaPaste_z'.key
            exec 'xmap <unique> z'.key.' <Plug>ZetaPaste_z'.key
        endif
        exec "nnoremap <silent> <Plug>ZetaPaste_z".key." :call yanktools#zeta#paste_with_key('" . key . "')\<cr>"
        exec "xnoremap <silent> <Plug>ZetaPaste_z".key." :call yanktools#zeta#paste_with_key('" . key . "')\<cr>"
    endfor

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
