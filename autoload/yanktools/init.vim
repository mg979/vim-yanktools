""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    let g:yanktools_paste_keys              = get(g:, 'yanktools_paste_keys', ['p', 'P', 'gp', 'gP'])
    let g:yanktools_yank_keys               = get(g:, 'yanktools_yank_keys', ['y', 'Y'])
    let g:yanktools_black_hole_keys         = get(g:, 'yanktools_black_hole_keys', ['x','X', '<Del>'])
    let g:yanktools_redirect_keys           = get(g:, 'yanktools_redirect_keys', ['c', 'C', 'd', 'D'])
    let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
    let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)

    let g:yanktools_replace_operator        = get(g:, 'yanktools_replace_operator', 's')
    let g:yanktools_replace_operator_line   = get(g:, 'yanktools_replace_operator_line', 'ss')
    let g:yanktools_replace_operator_bh     = get(g:, 'yanktools_replace_operator_bh', 1)

    let g:yanktools_format_operator         = get(g:, 'yanktools_format_operator', "<")
    let g:yanktools_zeta_operator           = get(g:, 'yanktools_zeta_operator', "z")
    let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")
    let redirect                            = g:yanktools_redirect_register
    let zeta                                = g:yanktools_zeta_operator
    let format                              = g:yanktools_format_operator
    let lead                                = g:mapleader

    let g:yanktools_zeta_inverted           = get(g:, 'yanktools_zeta_inverted', 1)
    let g:yanktools_convenient_remaps       = get(g:, 'yanktools_convenient_remaps', 1)

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Yank keys
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_yank_keys
        if mapcheck(key) == '' && !hasmapto('<Plug>Yank_'.key)
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
        if mapcheck(key) == '' && !hasmapto('<Plug>Black_Hole_'.key)
            exec 'nmap <unique> '.key.' <Plug>Black_Hole_'.key
            exec 'xmap <unique> '.key.' <Plug>Black_Hole_'.key
        endif
        exec 'nnoremap <silent> <Plug>Black_Hole_'.key.' "_'.key
        exec 'xnoremap <silent> <Plug>Black_Hole_'.key.' "_'.key
    endfor

    for key in g:yanktools_redirect_keys
        if mapcheck(key) == '' && !hasmapto('<Plug>RegRedirect_'.key)
            exec 'nmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
            exec 'xmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
        exec 'xnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
    endfor

    " fix issue that C doesn't update stack (it doesn't trigger TextChanged?)
    if g:yanktools_convenient_remaps
        if index(g:yanktools_black_hole_keys, 'C') >= 0
            nnoremap C "_Da
        elseif index(g:yanktools_black_hole_keys, 'D') == -1
            nmap C Da
        endif
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace operator
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_operator

    " only replace s operator if option is set
    if !g:yanktools_convenient_remaps && key == 's'
    else
        if !hasmapto('<Plug>ReplaceOperator')
            exec 'nmap <unique> '.key.' <Plug>ReplaceOperator'
            exec 'xmap <unique> '.key.' <Plug>ReplaceOperator'
        endif
        nmap <silent> <expr> <Plug>ReplaceOperator yanktools#replace(0)
        xmap <silent> <expr> <Plug>ReplaceOperator yanktools#replace(0)

        let key = g:yanktools_replace_operator_line
        if !hasmapto('<Plug>ReplaceOperatorLine')
            exec 'nmap <unique> '.key.' <Plug>ReplaceOperatorLine'
        endif
        nmap <silent> <expr> <Plug>ReplaceOperatorLine yanktools#replace(1)

        " remap normal substitution operator to S
        nnoremap S s
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste redirected
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_paste_keys
        if mapcheck(lead.key) == '' && !hasmapto('<Plug>PasteRedirected_'.key)
            exec 'nmap <unique> '.lead.key.' <Plug>PasteRedirected_'.key
            exec 'xmap <unique> '.lead.key.' <Plug>PasteRedirected_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>PasteRedirected_'.key.' yanktools#paste_redirected_with_key("' . key . '", "' . redirect . '")'
        exec 'xnoremap <silent> <expr> <Plug>PasteRedirected_'.key.' yanktools#paste_redirected_with_key("' . key . '", "' . redirect . '")'


        if mapcheck(format.lead.key) == '' && !hasmapto('<Plug>PasteRedirectedIndent_'.key)
            exec 'nmap <unique> '.format.lead.key.' <Plug>PasteRedirectedIndent_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>PasteRedirectedIndent_'.key.' yanktools#paste_redirected_with_key("' . key . '", "' . redirect . '", 1)'
    endfor

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste keys
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_paste_keys
        if mapcheck(key) == '' && !hasmapto('<Plug>Paste_'.key)
            exec 'nmap <unique> '.key.' <Plug>Paste_'.key
            exec 'xmap <unique> '.key.' <Plug>Paste_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>Paste_'.key.' yanktools#paste_with_key("' . key . '")'

        if mapcheck(format.key) == '' && !hasmapto('<Plug>PasteIndent_'.key)
            exec 'nmap <unique> '.format.key.' <Plug>PasteIndent_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>PasteIndent_'.key.' yanktools#paste_with_key("' . key . '", 1)'
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
        if mapcheck(zeta.key) == '' && !hasmapto('<Plug>ZetaYank_'.key)
            exec 'nmap <unique> '.zeta.key.' <Plug>ZetaYank_'.key
            exec 'xmap <unique> '.zeta.key.' <Plug>ZetaYank_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>ZetaYank_'.key.' yanktools#zeta#yank_with_key("' . key . '")'
        exec 'xnoremap <silent> <expr> <Plug>ZetaYank_'.key.' yanktools#zeta#yank_with_key("' . key . '")'
    endfor

    for key in ['p', 'P']
        if mapcheck(zeta.key) == '' && !hasmapto('<Plug>ZetaPaste_'.key)
            exec 'nmap <unique> '.zeta.key.' <Plug>ZetaPaste_'.key
            exec 'xmap <unique> '.zeta.key.' <Plug>ZetaPaste_'.key
        endif
        exec "nnoremap <silent> <Plug>ZetaPaste_".key." :call yanktools#zeta#paste_with_key('" . key . "')\<cr>"
        exec "xnoremap <silent> <Plug>ZetaPaste_".key." :call yanktools#zeta#paste_with_key('" . key . "')\<cr>"

        if mapcheck(format.zeta.key) == '' && !hasmapto('<Plug>ZetaPasteIndent_'.key)
            exec 'nmap <unique> '.format.zeta.key.' <Plug>ZetaPasteIndent_'.key
        endif
        exec "nnoremap <silent> <Plug>ZetaPasteIndent_".key." :call yanktools#zeta#paste_with_key('" . key . "', 1)\<cr>"
    endfor

    if g:yanktools_convenient_remaps
        nmap zY zy$
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Toggle Autoindent
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>ToggleAutoIndent')
        nmap <unique> <C-K>tai <Plug>ToggleAutoIndent
    endif
    nnoremap <silent> <Plug>ToggleAutoIndent :ToggleAutoIndent<cr>
                \:echo "Autoindent is now ".(g:yanktools_auto_format_all ? 'enabled.' : 'disabled.')<cr>

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
