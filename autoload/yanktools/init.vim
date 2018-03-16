""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    let g:yanktools_paste_keys              = get(g:, 'yanktools_paste_keys', ['p', 'P', 'gp', 'gP'])
    let g:yanktools_redir_paste_prefix      = get(g:, 'yanktools_redir_paste_prefix', '<leader>')
    let g:yanktools_yank_keys               = get(g:, 'yanktools_yank_keys', ['y', 'Y'])
    let g:yanktools_black_hole_keys         = get(g:, 'yanktools_black_hole_keys', ['x','X', '<Del>'])
    let g:yanktools_redirect_keys           = get(g:, 'yanktools_redirect_keys', ['c', 'C', 'd', 'D'])
    let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
    let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)

    let g:yanktools_replace_operator        = get(g:, 'yanktools_replace_operator', 's')
    let g:yanktools_replace_line            = get(g:, 'yanktools_replace_line', 'ss')
    let g:yanktools_replace_operator_bh     = get(g:, 'yanktools_replace_operator_bh', 1)

    let g:yanktools_format_prefix           = get(g:, 'yanktools_format_prefix', "<")
    let g:yanktools_zeta_prefix             = get(g:, 'yanktools_zeta_prefix', "z")
    let g:yanktools_zeta_kill               = get(g:, 'yanktools_zeta_kill', "k")
    let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")

    let redirect                            = g:yanktools_redirect_register
    let zeta                                = g:yanktools_zeta_prefix
    let kill                                = g:yanktools_zeta_kill
    let format                              = g:yanktools_format_prefix


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


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace operator
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_operator

    if !hasmapto('<Plug>ReplaceOperator')
        exec 'nmap <unique> '.key.' <Plug>ReplaceOperator'
        exec 'xmap <unique> '.key.' <Plug>ReplaceOperator'
    endif
    nmap <silent> <Plug>ReplaceOperator :call yanktools#replop#replace_get_reg()<cr>:set opfunc=yanktools#replop#replace<cr>g@
    xmap <silent> <Plug>ReplaceOperator :call yanktools#replop#replace_get_reg()<cr>:set opfunc=yanktools#replop#replace<cr>g@


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace line
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_line

    if !hasmapto('<Plug>ReplaceOperatorLine')
        exec 'nmap <unique> '.key.' <Plug>ReplaceOperatorLine'
    endif
    nmap <silent> <Plug>ReplaceOperatorLine :call yanktools#replop#replace_line(v:register, v:count)<cr>

    if !hasmapto('<Plug>ReplaceOperatorLineMulti')
        exec 'nmap <unique> '.g:mapleader.key.' <Plug>ReplaceOperatorLineMulti'
    endif
    nmap <silent> <Plug>ReplaceOperatorLineMulti :call yanktools#replop#replace_line(v:register, v:count, 1)<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste redirected
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let cmd = ' yanktools#paste_redirected_with_key'
    let prefix = g:yanktools_redir_paste_prefix

    for key in g:yanktools_paste_keys
        let plug = 'PasteRedirected_'.key

        if mapcheck(prefix.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.prefix.key.' <Plug>'.plug
            exec 'xmap <unique> '.prefix.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", "' . redirect . '")'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", "' . redirect . '")'

        let plug = 'PasteRedirectedIndent_'.key

        if mapcheck(format.prefix.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.prefix.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", "' . redirect . '", 1)'
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste keys
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let cmd = ' yanktools#paste_with_key'

    for key in g:yanktools_paste_keys
        let plug = "Paste_".key

        if mapcheck(key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.key.' <Plug>'.plug
            exec 'xmap <unique> '.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'")'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'")'

        let plug = "PasteIndent_".key
        if mapcheck(format.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1)'
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

    if mapcheck(zeta.kill) == '' && !hasmapto('<Plug>ZetaKill')
        exec 'nmap <unique> '.zeta.kill.' <Plug>ZetaKill'
        exec 'nmap <unique> '.zeta.kill.kill.' <Plug>ZetaKillLine'
        exec 'xmap <unique> '.zeta.kill.' <Plug>ZetaKill'
    endif
    nnoremap <silent> <expr> <Plug>ZetaKill yanktools#zeta#kill_with_key("d")
    nnoremap <silent> <expr> <Plug>ZetaKillLine yanktools#zeta#kill_with_key("dd")
    xnoremap <silent> <expr> <Plug>ZetaKill yanktools#zeta#kill_with_key("d")

    let cmd = ' :call yanktools#zeta#paste_with_key'

    for key in ['p', 'P']
        let plug = "ZetaPaste_".key

        if mapcheck(zeta.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.zeta.key.' <Plug>'.plug
            exec 'xmap <unique> '.zeta.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'")'."\<cr>"
        exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'")'."\<cr>"

        let plug = "ZetaPasteIndent_".key
        if mapcheck(format.zeta.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.zeta.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1)'."\<cr>"
    endfor


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
        xmap <unique> <C-K>p <Plug>IPasteAfter
        xmap <unique> <C-K>P <Plug>IPasteBefore
    endif
    nnoremap <silent> <expr> <Plug>IPasteAfter  g:loaded_fzf ? ":FzfPasteAfter\<cr>"  : ":IPaste\<cr>"
    nnoremap <silent> <expr> <Plug>IPasteBefore g:loaded_fzf ? ":FzfPasteBefore\<cr>" : ":IPasteBefore\<cr>"
    xnoremap <silent> <expr> <Plug>IPasteAfter  g:loaded_fzf ? ":FzfPasteAfter\<cr>"  : ":IPaste\<cr>"
    xnoremap <silent> <expr> <Plug>IPasteBefore g:loaded_fzf ? ":FzfPasteBefore\<cr>" : ":IPasteBefore\<cr>"


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Change yank type
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>YankType')
        nmap <unique> <C-K>yt <Plug>YankType
    endif
    nnoremap <silent> <Plug>YankType :call yanktools#extras#change_yank_type()<cr>

endfunction
