""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

    let g:yanktools_loaded = 1

    let g:yanktools_paste_keys              = get(g:, 'yanktools_paste_keys', ['p', 'P', 'gp', 'gP'])
    let g:yanktools_redir_paste_prefix      = get(g:, 'yanktools_redir_paste_prefix', '<leader>')
    let g:yanktools_duplicate_key           = get(g:, 'yanktools_duplicate_key', '<M-d>')
    let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
    let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)

    let g:yanktools_use_single_stack        = get(g:, 'yanktools_use_single_stack', 0)
    let g:yanktools_replace_operator_bh     = get(g:, 'yanktools_replace_operator_bh', 1)

    let g:yanktools_format_prefix           = get(g:, 'yanktools_format_prefix', "<")
    let g:yanktools_zeta                    = get(g:, 'yanktools_zeta', "z")
    let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")

    let redirect                            = g:yanktools_redirect_register
    let format                              = g:yanktools_format_prefix

    let g:yanktools_replace_operator        = get(g:, 'yanktools_replace_operator', 's')
    let g:yanktools_replace_line            = get(g:, 'yanktools_replace_line', 'ss')
    let g:yanktools_black_hole_keys         = get(g:, 'yanktools_black_hole_keys', ['c', 'C', 'x','X', '<Del>'])
    let g:yanktools_redirect_keys           = get(g:, 'yanktools_redirect_keys', ['d', 'D'])

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Yank {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>Yank_y')
        nmap <unique> y <Plug>Yank_y
        xmap <unique> y <Plug>Yank_y
    endif
    nnoremap <silent> <expr> <Plug>Yank_y yanktools#yank_with_key("y")
    xnoremap <silent> <expr> <Plug>Yank_y yanktools#yank_with_key("y")


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Redirection {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    for key in g:yanktools_black_hole_keys
        if key ==? '<del>' | let map = 'x' | else | let map = key | endif

        if !hasmapto('<Plug>Black_Hole_'.key)
            silent! exec 'nmap <unique> '.key.' <Plug>Black_Hole_'.key
            silent! exec 'xmap <unique> '.key.' <Plug>Black_Hole_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>Black_Hole_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register, 1)'
        exec 'xnoremap <silent> <expr> <Plug>Black_Hole_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register, 1)'
    endfor

    for key in g:yanktools_redirect_keys
        if !hasmapto('<Plug>RegRedirect_'.key)
            silent! exec 'nmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
            silent! exec 'xmap <unique> '.key.' <Plug>RegRedirect_"'.redirect.'_'.key
        endif
        exec 'nnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
        exec 'xnoremap <silent> <expr> <Plug>RegRedirect_"'.redirect.'_'.key.' yanktools#redirect_reg_with_key("' . key . '", v:register)'
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace operator {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_operator

    if !empty(key) && !hasmapto('<Plug>ReplaceOperator')
        silent! exec 'nmap <unique> '.key.' <Plug>ReplaceOperator'
    endif
    nmap <silent> <Plug>ReplaceOperator :call yanktools#replop#replace_get_reg()<cr>:set opfunc=yanktools#replop#replace<cr>g@


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Replace line {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_replace_line

    if !empty(key) && !hasmapto('<Plug>ReplaceLineSingle')
        silent! exec 'nmap <unique> '.key.' <Plug>ReplaceLineSingle'
        silent! exec 'nmap <unique> '.format.key.' <Plug>ReplaceLineFormatSingle'
    endif
    nmap <silent> <Plug>ReplaceLineSingle :call yanktools#replop#replace_line(v:register, v:count, 0, 0)<cr>
    nmap <silent> <Plug>ReplaceLineFormatSingle :call yanktools#replop#replace_line(v:register, v:count, 0, 1)<cr>

    if !empty(key) && !hasmapto('<Plug>ReplaceLineMulti')
        silent! exec 'nmap <unique> '.g:mapleader.key.' <Plug>ReplaceLineMulti'
        silent! exec 'nmap <unique> '.format.g:mapleader.key.' <Plug>ReplaceLineFormatMulti'
    endif
    nmap <silent> <Plug>ReplaceLineMulti :call yanktools#replop#replace_line(v:register, v:count, 1, 0)<cr>
    nmap <silent> <Plug>ReplaceLineFormatMulti :call yanktools#replop#replace_line(v:register, v:count, 1, 1)<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Duplicate {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let key = g:yanktools_duplicate_key
    let plug = 'DuplicateNormal'

    if !empty(key) && !hasmapto('<Plug>DuplicateNormal')
        silent! exec 'nmap <unique> '.key.' <Plug>DuplicateNormal'
    endif
    exe 'nnoremap <silent> <expr> <Plug>DuplicateNormal yanktools#duplicate("'.plug.'", 0)'

    if !empty(key) && !hasmapto('<Plug>DuplicateVisual')
        silent! exec 'xmap <unique> '.key.' <Plug>DuplicateVisual'
    endif
    exe 'xnoremap <silent> <expr> <Plug>DuplicateVisual yanktools#duplicate("", 1)'


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste redirected {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let cmd = ' yanktools#paste_redirected_with_key'
    let prefix = g:yanktools_redir_paste_prefix

    for key in g:yanktools_paste_keys
        let plug = 'PasteRedirected_'.key

        if !empty(prefix) && !hasmapto('<Plug>'.plug)
            silent! exec 'nmap <unique> '.prefix.key.' <Plug>'.plug
            silent! exec 'xmap <unique> '.prefix.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

        let plug = 'PasteRedirectedIndent_'.key

        if !empty(prefix) && !empty(format) && !hasmapto('<Plug>'.plug)
            silent! exec 'nmap <unique> '.format.prefix.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Paste keys {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    let cmd = ' yanktools#paste_with_key'

    for key in g:yanktools_paste_keys
        let plug = "Paste_".key

        if !hasmapto('<Plug>'.plug)
            silent! exec 'nmap <unique> '.key.' <Plug>'.plug
            silent! exec 'xmap <unique> '.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

        let plug = "PasteIndent_".key
        if !empty(format) && !hasmapto('<Plug>'.plug)
            silent! exec 'nmap <unique> '.format.key.' <Plug>'.plug
        endif
        exec 'nnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
        exec 'xnoremap <silent> <expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
    endfor


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Swap pastes {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !hasmapto('<Plug>SwapPasteNext')
        silent! nmap <unique> <M-p> <Plug>SwapPasteNext
        silent! xmap <unique> <M-p> <Plug>SwapPasteNext
    endif
    if !hasmapto('<Plug>SwapPastePrevious')
        silent! nmap <unique> <M-P> <Plug>SwapPastePrevious
        silent! xmap <unique> <M-P> <Plug>SwapPastePrevious
    endif
    nnoremap <silent> <Plug>SwapPasteNext     :call yanktools#swap_paste(1, "P", 0)<cr>
    nnoremap <silent> <Plug>SwapPastePrevious :call yanktools#swap_paste(0, "P", 0)<cr>

    "black hole delete and break undo history
    xnoremap <silent> <Plug>SwapPasteNext     "_da<C-g>u<esc>:call yanktools#swap_paste(1, "P", 1)<cr>
    xnoremap <silent> <Plug>SwapPastePrevious "_da<C-g>u<esc>:call yanktools#swap_paste(0, "P", 1)<cr>


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " z mode {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    if !empty(g:yanktools_zeta)
        let zeta = g:yanktools_zeta
            if !hasmapto('<Plug>ZetaYank')
                silent! exec 'nmap <unique> y'.zeta.' <Plug>ZetaYank'
                silent! exec 'xmap <unique> '.zeta.'y <Plug>ZetaYank'
            endif
            exec 'nnoremap <silent> <expr> <Plug>ZetaYank yanktools#zeta#yank_with_key("y")'
            exec 'xnoremap <silent> <expr> <Plug>ZetaYank yanktools#zeta#yank_with_key("y")'

        if !hasmapto('<Plug>ZetaDeleteMotion')
            nmap <unique> dz <Plug>ZetaDeleteMotion
        endif
        if !hasmapto('<Plug>ZetaDeleteLine')
            nmap <unique> dzd <Plug>ZetaDeleteLine
        endif
        if !hasmapto('<Plug>ZetaDeleteVisual')
            xmap <unique> zd <Plug>ZetaDeleteVisual
        endif
        nnoremap <silent> <expr> <Plug>ZetaDeleteMotion yanktools#zeta#kill_with_key("d")
        nnoremap <silent> <expr> <Plug>ZetaDeleteVisual yanktools#zeta#kill_with_key("dd")
        xnoremap <silent> <expr> <Plug>ZetaDeleteLine yanktools#zeta#kill_with_key("d")

        let cmd = ' :call yanktools#zeta#paste_with_key'

        for key in ['p', 'P']
            let plug = "ZetaPaste_".key

            if !hasmapto('<Plug>'.plug)
                silent! exec 'nmap <unique> '.zeta.key.' <Plug>'.plug
                silent! exec 'xmap <unique> '.zeta.key.' <Plug>'.plug
            endif
            exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'."\<cr>"
            exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'."\<cr>"

            let plug = "ZetaPasteIndent_".key
            if !hasmapto('<Plug>'.plug)
                silent! exec 'nmap <unique> '.format.zeta.key.' <Plug>'.plug
            endif
            exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'."\<cr>"
            exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'."\<cr>"
        endfor
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Misc commands                                                             {{{1
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " Toggle Autoindent                                                         {{{2
    if !hasmapto('<Plug>ToggleAutoIndent')
        silent! nmap <unique> cyi <Plug>ToggleAutoIndent
    endif
    nnoremap <silent> <Plug>ToggleAutoIndent :ToggleAutoIndent<cr>
                \:echo "Autoindent is now " .
                \(g:yanktools_auto_format_all ? 'enabled.' : 'disabled.')<cr>

    " Freeze yank offset                                                        {{{2
    if !hasmapto('<Plug>FreezeYank') && empty(maparg('cyf'))
        silent! nmap <unique> cyf <Plug>FreezeYank
    endif
    nnoremap <silent> <Plug>FreezeYank :call yanktools#freeze_offset()<cr>

    " Clear yanks                                                               {{{2
    if !hasmapto('<Plug>ClearYankStack') && empty(maparg('cys'))
        silent! nmap <unique> cys <Plug>ClearYankStack
    endif
    nnoremap <silent> <Plug>ClearYankStack
          \ :call yanktools#extras#clear_yanks(0, 1)<cr>

    " Clear zeta stack
    if !hasmapto('<Plug>ClearZetaStack') && empty(maparg('czs'))
        silent! nmap <unique> czs <Plug>ClearZetaStack
    endif
    nnoremap <silent> <Plug>ClearZetaStack
          \ :call yanktools#extras#clear_yanks(1)<cr>

    " Show yanks                                                                {{{2
    if !hasmapto('<Plug>AllYanks') && empty(maparg('yA'))
        silent! nmap <unique> yA <Plug>AllYanks
    endif
    nnoremap <silent> <Plug>AllYanks :call yanktools#extras#show_yanks()<cr>

    " Interactive Paste                                                         {{{2
    if !hasmapto('<Plug>ISelectYank') && empty(maparg('yI'))
        silent! nmap <unique> yI <Plug>ISelectYank
    endif
    noremap <silent> <expr> <Plug>ISelectYank exists('g:loaded_fzf')
          \ ? ":FzfSelectYank\<cr>" : ":ISelectYank\<cr>"

    " Change yank type                                                          {{{2
    if !hasmapto('<Plug>ConvertYankType') && empty(maparg('cyt'))
        silent! nmap <unique> cyt <Plug>ConvertYankType
    endif
    nnoremap <silent> <Plug>ConvertYankType :call yanktools#extras#change_yank_type()<cr>

    " Menu                                                                      {{{2
    if !hasmapto('<Plug>YanktoolsMenu') && empty(maparg('cym'))
        silent! nmap <unique> cym <Plug>YanktoolsMenu
    endif
    nnoremap <silent> <Plug>YanktoolsMenu :Yanktools<cr>

endfunction
