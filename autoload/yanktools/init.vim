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

    let g:yanktools_format_prefix           = get(g:, 'yanktools_format_prefix', "\\")
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
        if key ==? '<del>' | let map = 'x' | else | let map = key | endif

        if mapcheck(key) == '' && !hasmapto('<Plug>Black_Hole_'.key)
            exec 'nmap <unique> '.key.' <Plug>Black_Hole_'.key
            exec 'xmap <unique> '.key.' <Plug>Black_Hole_'.key
        endif
        exec 'nnoremap <silent> <Plug>Black_Hole_'.key.' "_'.map
        exec 'xnoremap <silent> <Plug>Black_Hole_'.key.' "_'.map
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
        "exec 'xmap <unique> '.key.' <Plug>ReplaceOperator'
    endif
    nmap <silent> <Plug>ReplaceOperator :call yanktools#replop#replace_get_reg()<cr>:set opfunc=yanktools#replop#replace<cr>g@
    "xmap <silent> <Plug>ReplaceOperator :call yanktools#replop#replace_get_reg()<cr>:set opfunc=yanktools#replop#replace<cr>g@


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace line
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_line

    if !hasmapto('<Plug>ReplaceOperatorLineSingle')
        exec 'nmap <unique> '.key.' <Plug>ReplaceOperatorLineSingle'
    endif
    nmap <silent> <Plug>ReplaceOperatorLineSingle :call yanktools#replop#replace_line(v:register, v:count)<cr>

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
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

        let plug = 'PasteRedirectedIndent_'.key

        if mapcheck(format.prefix.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.prefix.key.' <Plug>'.plug
            exec 'xmap <unique> '.format.prefix.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
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
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

        let plug = "PasteIndent_".key
        if mapcheck(format.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.key.' <Plug>'.plug
            exec 'xmap <unique> '.format.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Swap pastes
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>SwapPasteNext')
        nmap <unique> <M-p> <Plug>SwapPasteNext
        xmap <unique> <M-p> <Plug>SwapPasteNext
    endif
    if !hasmapto('<Plug>SwapPastePrevious')
        nmap <unique> <M-P> <Plug>SwapPastePrevious
        xmap <unique> <M-P> <Plug>SwapPastePrevious
    endif
    nnoremap <silent> <Plug>SwapPasteNext     :call yanktools#swap_paste(1, "P", 0)<cr>
    nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0, "P", 0)<cr>

    "black hole delete and break undo history
    xnoremap <silent> <Plug>SwapPasteNext     "_da<C-g>u<esc>:call yanktools#swap_paste(1, "P", 1)<cr>
    xnoremap <silent> <Plug>SwapPastePrevious "_da<C-g>u<esc>:call yanktools#swap_paste(0, "P", 1)<cr>


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

    if mapcheck(zeta.kill) == '' && !hasmapto('<Plug>ZetaKillMotion')
        exec 'nmap <unique> '.zeta.kill.' <Plug>ZetaKillMotion'
        exec 'xmap <unique> '.zeta.kill.' <Plug>ZetaKillMotion'
        exec 'nmap <unique> '.zeta.kill.kill.' <Plug>ZetaKillLine'
    endif
    nnoremap <silent> <expr> <Plug>ZetaKillMotion yanktools#zeta#kill_with_key("d")
    nnoremap <silent> <expr> <Plug>ZetaKillLine yanktools#zeta#kill_with_key("dd")
    xnoremap <silent> <expr> <Plug>ZetaKillMotion yanktools#zeta#kill_with_key("d")

    let cmd = ' :call yanktools#zeta#paste_with_key'

    for key in ['p', 'P']
        let plug = "ZetaPaste_".key

        if mapcheck(zeta.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.zeta.key.' <Plug>'.plug
            exec 'xmap <unique> '.zeta.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'."\<cr>"
        exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'."\<cr>"

        let plug = "ZetaPasteIndent_".key
        if mapcheck(format.zeta.key) == '' && !hasmapto('<Plug>'.plug)
            exec 'nmap <unique> '.format.zeta.key.' <Plug>'.plug
            exec 'xmap <unique> '.format.zeta.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'."\<cr>"
        exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'."\<cr>"
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Convenient remaps
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if get(g:, 'yanktools_convenient_remaps', 0)
        nmap Y y$
        xmap Y $hy
        xmap D $hd
        nmap zY zy$
        xmap zY $zy
        nmap zK zk$
        xmap zK $zk
        nmap S s$
        xmap <C-s> $hp
        nmap sx "xs
        xmap sx "xp
        nmap sxx "xss
        nmap sX "xs$
        xmap sX $h"xp
        nmap zl zyy
        xmap zl $zy

        if get(g:, 'yanktools_auto_format_all', 0)
            map [p <Plug>Paste_P
            map ]p <Plug>Paste_p
            map =p <Plug>PasteRedirected_p
            map -p <Plug>PasteRedirected_P
            execute "map ".format."[p <Plug>PasteIndent_P"
            execute "map ".format."]p <Plug>PasteIndent_p"
            execute "map ".format."=p <Plug>PasteRedirectedIndent_p"
            execute "map ".format."-p <Plug>PasteRedirectedIndent_P"
        else
            map [p <Plug>PasteIndent_P
            map ]p <Plug>PasteIndent_p
            map =p <Plug>PasteRedirectedIndent_p
            map -p <Plug>PasteRedirectedIndent_P
            execute "map ".format."[p <Plug>Paste_P"
            execute "map ".format."]p <Plug>Paste_p"
            execute "map ".format."=p <Plug>PasteRedirected_p"
            execute "map ".format."-p <Plug>PasteRedirected_P"
        endif
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Toggle Autoindent
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>ToggleAutoIndent')
        nmap <unique> <C-K>yi <Plug>ToggleAutoIndent
    endif
    nnoremap <silent> <Plug>ToggleAutoIndent :ToggleAutoIndent<cr>
                \:echo "Autoindent is now ".(g:yanktools_auto_format_all ? 'enabled.' : 'disabled.')<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Freeze yank offset
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>FreezeYank')
        nmap <unique> <C-K>yf <Plug>FreezeYank
    endif
    nnoremap <silent> <Plug>FreezeYank :call yanktools#freeze_offset()<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Clear yanks
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>DeleteYanks')
        nmap <unique> <C-K>yd <Plug>DeleteYanks
    endif
    nnoremap <silent> <Plug>DeleteYanks :call yanktools#clear_yanks()<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Show yanks
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>ShowYanks')
        nmap <unique> <C-K>ys <Plug>ShowYanks
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

    if !hasmapto('<Plug>ConvertYank')
        nmap <unique> <C-K>yc <Plug>ConvertYank
    endif
    nnoremap <silent> <Plug>ConvertYank :call yanktools#extras#change_yank_type()<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Menu
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>YanktoolsMenu')
        nmap <unique> <C-K><C-P> <Plug>YanktoolsMenu
    endif
    nnoremap <silent> <Plug>YanktoolsMenu :Yanktools<cr>

endfunction
