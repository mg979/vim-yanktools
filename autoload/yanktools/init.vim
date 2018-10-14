""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init#maps()

  let g:yanktools_loaded = 1

  let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
  let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)
  let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")
  let g:yanktools_use_redirection         = get(g:, 'yanktools_use_redirection', !empty(g:yanktools_redirect_register))

  let paste_keys                          = get(g:, 'yanktools_paste_keys', ['p', 'P'])
  let format                              = get(g:, 'yanktools_format_prefix', "<")
  let leader                              = get(g:, 'mapleader', '\')
  let zeta                                = get(g:, 'yanktools_zeta', "z")


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Yank {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  if !hasmapto('<Plug>(YankOperator)')
    nmap y <Plug>(YankOperator)
    nmap Y <Plug>(YankOperator)$
    xmap y <Plug>(YankOperator)
  endif
  nnoremap <silent><expr> <Plug>(YankOperator) yanktools#yank_with_key("y")
  xnoremap <silent><expr> <Plug>(YankOperator) yanktools#yank_with_key("y")

  if !hasmapto('<Plug>(CutOperator)')
    nmap yx  <Plug>(CutOperator)
    nmap yxx <Plug>(CutOperator)d
    xmap x   <Plug>(CutOperator)
  endif
  nnoremap <silent><expr> <Plug>(CutOperator) yanktools#yank_with_key("d")
  xnoremap <silent><expr> <Plug>(CutOperator) yanktools#yank_with_key("d")


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Black Hole {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent><expr> <Plug>(Black_Hole_c) yanktools#redirect_with_key("c", v:register, 1)
  nnoremap <silent><expr> <Plug>(Black_Hole_C) yanktools#redirect_with_key("C", v:register, 1)
  xnoremap <silent><expr> <Plug>(Black_Hole_c) yanktools#redirect_with_key("c", v:register, 1)
  nnoremap <silent><expr> <Plug>(Black_Hole_x) yanktools#redirect_with_key("x", v:register, 1)
  nnoremap <silent><expr> <Plug>(Black_Hole_X) yanktools#redirect_with_key("X", v:register, 1)
  nnoremap <silent><expr> <Plug>(Black_Hole_del) yanktools#redirect_with_key("x", v:register, 1)

  if get(g:, 'yanktools_black_hole_c', 1)
    if !hasmapto('<Plug>(Black_Hole_c)')
      nmap c <Plug>(Black_Hole_c)
      nmap C <Plug>(Black_Hole_C)
      xmap c <Plug>(Black_Hole_c)
    endif
  endif

  if get(g:, 'yanktools_black_hole_x', 1)
    if !hasmapto('<Plug>(Black_Hole_x)')
      nmap x <Plug>(Black_Hole_x)
      nmap X <Plug>(Black_Hole_X)
    endif
  endif

  if get(g:, 'yanktools_black_hole_del', 1)
    if !hasmapto('<Plug>(Black_Hole_del)')
      nmap <del> <Plug>(Black_Hole_del)
    endif
  endif

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Redirection {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent><expr> <Plug>(RegRedirect_d) yanktools#redirect_with_key("d", v:register, 0)
  xnoremap <silent><expr> <Plug>(RegRedirect_d) yanktools#redirect_with_key("d", v:register, 0)
  nnoremap <silent><expr> <Plug>(RegRedirect_D) yanktools#redirect_with_key("D", v:register, 0)

  if !hasmapto('<Plug>(RegRedirect_d)')
    nmap d <Plug>(RegRedirect_d)
    xmap d <Plug>(RegRedirect_d)
  endif
  if !hasmapto('<Plug>(RegRedirect_D)')
    nmap D <Plug>(RegRedirect_D)
  endif


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Replace operator {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent> <Plug>(ReplaceOperator)         :call yanktools#replop#opts(v:register, 0, 0)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceOperatorR)        :call yanktools#replop#opts(v:register, 0, 1)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceFormatOperator)   :call yanktools#replop#opts(v:register, 1, 0)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceLineSingle)       :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 0, 0)<cr>
  nnoremap <silent> <Plug>(ReplaceLineFormatSingle) :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 0, 1)<cr>
  nnoremap <silent> <Plug>(ReplaceLineMulti)        :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 1, 0)<cr>
  nnoremap <silent> <Plug>(ReplaceLineFormatMulti)  :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 1, 1)<cr>

  let key = get(g:, 'yanktools_replace_operator', '')
  if !empty(key)
    if !hasmapto('<Plug>(ReplaceOperator)')
      exec 'nmap' key        '<Plug>(ReplaceOperatorR)'
      exec 'nmap' key.     'r <Plug>(ReplaceOperator)'
      exec 'nmap' format.key '<Plug>(ReplaceFormatOperator)'
    endif

    if !hasmapto('<Plug>(ReplaceLineSingle)')
      exec 'nmap' key.key        '<Plug>(ReplaceLineSingle)'
      exec 'nmap' format.key.key '<Plug>(ReplaceLineFormatSingle)'
    endif

    if !hasmapto('<Plug>(ReplaceLineMulti)')
      exec 'nmap' leader.key.key        '<Plug>(ReplaceLineMulti)'
      exec 'nmap' leader.format.key.key '<Plug>(ReplaceLineFormatMulti)'
    endif
  else
    if !hasmapto('<Plug>(ReplaceOperator)')
      nmap yR <Plug>(ReplaceOperator)
      nmap yr <Plug>(ReplaceOperatorR)
      exec 'nmap' format.'yr <Plug>(ReplaceFormatOperator)'
    endif

    if !hasmapto('<Plug>(ReplaceLineSingle)')
      nmap yrr <Plug>(ReplaceLineSingle)
      exec 'nmap' format.'yrr <Plug>(ReplaceLineFormatSingle)'
    endif

    if !hasmapto('<Plug>(ReplaceLineMulti)')
      nmap <Plug>(ReplaceLineMulti)
      exec 'nmap' leader.format.'yrr <Plug>(ReplaceLineFormatMulti)'
    endif
  endif


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Duplicate {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent> <Plug>(DuplicateOperator)         :set opfunc=yanktools#duplicate<cr>g@
  nnoremap <silent><expr> <Plug>(DuplicateLines)      yanktools#duplicate_lines()
  xnoremap <silent><expr> <Plug>(DuplicateVisual)     yanktools#duplicate_visual()

  if !hasmapto('<Plug>(DuplicateOperator)')
    nmap yd <Plug>(DuplicateOperator)
  endif

  if !hasmapto('<Plug>(DuplicateLines)')
    nmap ydd   <Plug>(DuplicateLines)
  endif

  if !hasmapto('<Plug>(DuplicateVisual)')
    xmap D     <Plug>(DuplicateVisual)
  endif


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Paste redirected {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let cmd = ' yanktools#paste_redirected_with_key'
  let prefix = get(g:, 'yanktools_redir_paste_prefix', '<leader>')

  for key in paste_keys
    let plug = '(PasteRedirected_'.key.')'

    if !empty(prefix) && !hasmapto('<Plug>'.plug)
      exec 'nmap' prefix.key '<Plug>'.plug
      exec 'xmap' prefix.key '<Plug>'.plug
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

    let plug = '(PasteRedirectedIndent_'.key.')'

    if !empty(prefix) && !empty(format) && !hasmapto('<Plug>'.plug)
      exec 'nmap' format.prefix.key '<Plug>'.plug
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
  endfor


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Paste keys {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let cmd = ' yanktools#paste_with_key'

  for key in paste_keys
    let plug = '(Paste_'.key.')'

    if !hasmapto('<Plug>'.plug)
      exec 'nmap' key '<Plug>'.plug
      exec 'xmap' key '<Plug>'.plug
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

    let plug = '(PasteIndent_'.key.')'
    if !empty(format) && !hasmapto('<Plug>'.plug)
      exec 'nmap' format.key '<Plug>'.plug
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'
  endfor


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Swap pastes {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  if !hasmapto('<Plug>(SwapPasteNext)')
    nmap <M-p> <Plug>(SwapPasteNext)
    xmap <M-p> <Plug>(SwapPasteNext)
  endif
  if !hasmapto('<Plug>(SwapPastePrevious)')
    nmap <M-P> <Plug>(SwapPastePrevious)
    xmap <M-P> <Plug>(SwapPastePrevious)
  endif
  nnoremap <silent> <Plug>(SwapPasteNext)     :call yanktools#swap_paste(1, "P", 0)<cr>
  nnoremap <silent> <Plug>(SwapPastePrevious) :call yanktools#swap_paste(0, "P", 0)<cr>

  "black hole delete and break undo history
  xnoremap <silent> <Plug>(SwapPasteNext)     "_da<C-g>u<esc>:call yanktools#swap_paste(1, "P", 1)<cr>
  xnoremap <silent> <Plug>(SwapPastePrevious) "_da<C-g>u<esc>:call yanktools#swap_paste(0, "P", 1)<cr>


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " z mode {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  if !empty(zeta)
    if !hasmapto('<Plug>(ZetaYankOperator)')
      exec 'nmap y'.zeta '<Plug>(ZetaYankOperator)'
      exec 'xmap' zeta.'y <Plug>(ZetaYankOperator)'
    endif
    nnoremap <silent><expr> <Plug>(ZetaYankOperator) yanktools#zeta#yank_with_key("y")
    xnoremap <silent><expr> <Plug>(ZetaYankOperator) yanktools#zeta#yank_with_key("y")

    if !hasmapto('<Plug>(ZetaDeleteOperator)')
      nmap dz <Plug>(ZetaDeleteOperator)
    endif
    if !hasmapto('<Plug>(ZetaDeleteLine)')
      nmap dzd <Plug>(ZetaDeleteLine)
    endif
    if !hasmapto('<Plug>(ZetaDeleteVisual)')
      xmap zd <Plug>(ZetaDeleteVisual)
    endif
    nnoremap <silent><expr> <Plug>(ZetaDeleteOperator) yanktools#zeta#kill_with_key("d")
    nnoremap <silent><expr> <Plug>(ZetaDeleteLine)     yanktools#zeta#kill_with_key("dd")
    xnoremap <silent><expr> <Plug>(ZetaDeleteVisual)   yanktools#zeta#kill_with_key("d")

    let cmd = ' :call yanktools#zeta#paste_with_key'

    for key in ['p', 'P']
      let plug = '(ZetaPaste_'.key.')'

      if !hasmapto('<Plug>'.plug)
        exec 'nmap' zeta.key '<Plug>'.plug
        exec 'xmap' zeta.key '<Plug>'.plug
      endif
      exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'."\<cr>"
      exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'."\<cr>"

      let plug = '(ZetaPasteIndent_'.key.')'
      if !hasmapto('<Plug>'.plug)
        exec 'nmap' format.zeta.key '<Plug>'.plug
      endif
      exec 'nnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'."\<cr>"
      exec 'xnoremap <silent> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 1)'."\<cr>"
    endfor
  endif

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Misc commands                                                             {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  " Toggle Autoindent                                                         {{{2
  if !hasmapto('<Plug>(ToggleAutoIndent)')
    nmap cyi <Plug>(ToggleAutoIndent)
  endif
  nnoremap <silent> <Plug>(ToggleAutoIndent) :ToggleAutoIndent<cr>

  " Toggle Single Stack
  if !hasmapto('<Plug>(ToggleRedirection)')
    nmap cur <Plug>(ToggleRedirection)
  endif
  nnoremap <silent> <Plug>(ToggleRedirection) :ToggleRedirection<cr>

  " Freeze yank offset                                                        {{{2
  if !hasmapto('<Plug>(FreezeYank)') && empty(maparg('cyf'))
    nmap cyf <Plug>(FreezeYank)
  endif
  nnoremap <silent> <Plug>(FreezeYank) :call yanktools#stack#freeze()<cr>

  " Clear yanks                                                               {{{2
  if !hasmapto('<Plug>(ClearYankStack)') && empty(maparg('cys'))
    nmap cys <Plug>(ClearYankStack)
  endif
  nnoremap <silent> <Plug>(ClearYankStack)
        \ :call yanktools#extras#clear_yanks(0, 1)<cr>

  " Clear zeta stack
  if !hasmapto('<Plug>(ClearZetaStack)') && empty(maparg('czs'))
    nmap czs <Plug>(ClearZetaStack)
  endif
  nnoremap <silent> <Plug>(ClearZetaStack)
        \ :call yanktools#extras#clear_yanks(1)<cr>

  " Show yanks                                                                {{{2
  if !hasmapto('<Plug>(Yanks)') && empty(maparg('yY'))
    nmap yY <Plug>(Yanks)
  endif
  nnoremap <silent> <Plug>(Yanks) :call yanktools#extras#show_yanks('y')<cr>

  " Redirected yanks                                                          {{{2
  if !hasmapto('<Plug>(RedirectedYanks)') && empty(maparg('yX'))
    nmap yX <Plug>(RedirectedYanks)
  endif
  nnoremap <silent> <Plug>(RedirectedYanks) :call yanktools#extras#show_yanks('x')<cr>

  " Zeta yanks                                                                {{{2
  if !hasmapto('<Plug>(ZetaYanks)') && empty(maparg('yZ'))
    nmap yZ <Plug>(ZetaYanks)
  endif
  nnoremap <silent> <Plug>(ZetaYanks) :call yanktools#extras#show_yanks('z')<cr>

  " Interactive Paste                                                         {{{2
  if !hasmapto('<Plug>(ISelectYank)') && empty(maparg('yI'))
    nmap yiy <Plug>(ISelectYank)
  endif
  noremap <silent> <expr> <Plug>(ISelectYank) exists('g:loaded_fzf')
        \ ? ":FzfSelectYank\<cr>" : ":ISelectYank\<cr>"

  if !hasmapto('<Plug>(ISelectYankR)') && empty(maparg('yI'))
    nmap yir <Plug>(ISelectYank!)
  endif
  noremap <silent> <expr> <Plug>(ISelectYank!) exists('g:loaded_fzf')
        \ ? ":FzfSelectYank!\<cr>" : ":ISelectYank!\<cr>"

  " Change yank type                                                          {{{2
  if !hasmapto('<Plug>(ConvertYankType)') && empty(maparg('cyt'))
    nmap cyt <Plug>(ConvertYankType)
  endif
  nnoremap <silent> <Plug>(ConvertYankType) :call yanktools#extras#change_yank_type()<cr>

  " Menu                                                                      {{{2
  if !hasmapto('<Plug>(YanktoolsMenu)') && empty(maparg('cym'))
    nmap cym <Plug>(YanktoolsMenu)
  endif
  nnoremap <silent> <Plug>(YanktoolsMenu) :Yanktools<cr>

endfunction
