""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mapping functions                                                         {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:nmap(key, plug)
  if !hasmapto(a:plug)
    exe 'nmap' a:key a:plug
  endif
endfunction

function! s:nmapf(key, plug)
    if !empty(get(g:, 'yanktools_format_prefix', "<")) && !hasmapto(a:plug)
    exe 'nmap' a:key a:plug
  endif
endfunction

function! s:nmaparg(key, plug)
  if !hasmapto(a:plug) && empty(maparg(a:key))
    exe 'nmap' a:key a:plug
  endif
endfunction

function! s:nxmap(key, plug)
  if !hasmapto(a:plug)
    exe 'nmap' a:key a:plug
    exe 'xmap' a:key a:plug
  endif
endfunction

function! s:xmap(key, plug)
  if !hasmapto(a:plug)
    exe 'xmap' a:key a:plug
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize                                                                {{{1
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


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Yank {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  if !hasmapto('<Plug>(Yank)')
    nmap y <Plug>(Yank)
    nmap Y <Plug>(Yank)$
    xmap y <Plug>(Yank)
  endif
  nnoremap <silent><expr> <Plug>(Yank) yanktools#yank_with_key("y")
  xnoremap <silent><expr> <Plug>(Yank) yanktools#yank_with_key("y")


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Black Hole {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent> <Plug>(Black_Hole_c)   "_c
  nnoremap <silent> <Plug>(Black_Hole_C)   "_C
  xnoremap <silent> <Plug>(Black_Hole_c)   "_c
  nnoremap <silent> <Plug>(Black_Hole_x)   "_x
  nnoremap <silent> <Plug>(Black_Hole_X)   "_X
  nnoremap <silent> <Plug>(Black_Hole_del) "_x
  xnoremap <silent> <Plug>(Black_Hole_del) "_x

  if get(g:, 'yanktools_black_hole_c', 1)
    call s:nxmap('c', '<Plug>(Black_Hole_c)')
    call s:nmap('C',  '<Plug>(Black_Hole_C)')
  endif

  if get(g:, 'yanktools_black_hole_x', 1)
    call s:nmap('x', '<Plug>(Black_Hole_x)')
    call s:nmap('X', '<Plug>(Black_Hole_X)')
  endif

  if get(g:, 'yanktools_black_hole_del', 1)
    call s:nxmap('<del>', '<Plug>(Black_Hole_del)')
  endif

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Redirection {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent><expr> <Plug>(Redirect_d) yanktools#redirect_with_key("d", v:register)
  xnoremap <silent><expr> <Plug>(Redirect_d) yanktools#redirect_with_key("d", v:register)
  nnoremap <silent><expr> <Plug>(Redirect_D) yanktools#redirect_with_key("D", v:register)

  call s:nxmap('d', '<Plug>(Redirect_d)')
  call s:nmap('D',  '<Plug>(Redirect_D)')


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Cut {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent><expr> <Plug>(Cut)         yanktools#cut_with_key("d", v:register)
  nnoremap <silent><expr> <Plug>(CutLine)     yanktools#cut_with_key("dd", v:register)
  xnoremap <silent><expr> <Plug>(CutVisual)   yanktools#cut_with_key("d", v:register)

  call s:nmap('yx',  '<Plug>(Cut)')
  call s:nmap('yxx', '<Plug>(CutLine)')
  call s:xmap('x',   '<Plug>(CutVisual)')


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Replace operator {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent> <Plug>(ReplaceOperatorS)        :call yanktools#replop#opts(v:register, 0, 0)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceOperatorR)        :call yanktools#replop#opts(v:register, 0, 1)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceFormatOperator)   :call yanktools#replop#opts(v:register, 1, 0)<cr>:set opfunc=yanktools#replop#replace<cr>g@
  nnoremap <silent> <Plug>(ReplaceLineSingle)       :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 0, 0)<cr>
  nnoremap <silent> <Plug>(ReplaceLineFormatSingle) :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 0, 1)<cr>
  nnoremap <silent> <Plug>(ReplaceLineMulti)        :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 1, 0)<cr>
  nnoremap <silent> <Plug>(ReplaceLineFormatMulti)  :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 1, 1)<cr>

  let key = get(g:, 'yanktools_replace_key', '')
  if !empty(key)
    call s:nmap(key,                    '<Plug>(ReplaceOperatorR)')
    call s:nmap(key.'r',                '<Plug>(ReplaceOperatorS)')
    call s:nmapf(format.key,            '<Plug>(ReplaceFormatOperator)')
    call s:nmap(key.key,                '<Plug>(ReplaceLineSingle)')
    call s:nmapf(format.key.key,        '<Plug>(ReplaceLineFormatSingle)')
    call s:nmap(leader.key.key,         '<Plug>(ReplaceLineMulti)')
    call s:nmapf(leader.format.key.key, '<Plug>(ReplaceLineFormatMulti)')
  else
    call s:nmap('yr',                   '<Plug>(ReplaceOperatorR)')
    call s:nmap('yR',                   '<Plug>(ReplaceOperatorS)')
    call s:nmapf(format.'yr',           '<Plug>(ReplaceFormatOperator)')
    call s:nmap('yrr',                  '<Plug>(ReplaceLineSingle)')
    call s:nmapf(format.'yrr',          '<Plug>(ReplaceLineFormatSingle)')
    call s:nmap(leader.'yrr',           '<Plug>(ReplaceLineMulti)')
    call s:nmapf(leader.format.'yrr',   '<Plug>(ReplaceLineFormatMulti)')
  endif


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Duplicate {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  nnoremap <silent>       <Plug>(DuplicateOperator)   :set opfunc=yanktools#duplicate<cr>g@
  nnoremap <silent><expr> <Plug>(DuplicateLines)      yanktools#duplicate_lines()
  xnoremap <silent><expr> <Plug>(DuplicateVisual)     yanktools#duplicate_visual()

  call s:nmap('yd',  '<Plug>(DuplicateOperator)')
  call s:nmap('ydd', '<Plug>(DuplicateLines)')
  call s:xmap('D',   '<Plug>(DuplicateVisual)')


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Paste redirected {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let cmd = ' yanktools#paste_redirected_with_key'
  let prefix = get(g:, 'yanktools_redir_paste_prefix', '<leader>')

  for key in paste_keys
    let plug = '(PasteRedirected_'.key.')'

    if !empty(prefix)
      call s:nxmap(prefix.key, '<Plug>'.plug)
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

    let plug = '(PasteRedirectedIndent_'.key.')'

    if !empty(prefix)
      call s:nmapf(format.prefix.key, '<Plug>'.plug)
    endif
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
  endfor


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Paste keys {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let cmd = ' yanktools#paste_with_key'

  for key in paste_keys
    let plug = '(Paste_'.key.')'
    call s:nxmap(key, '<Plug>'.plug)
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

    let plug = '(PasteIndent_'.key.')'
    call s:nmapf(format.key, '<Plug>'.plug)
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
  endfor


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Swap pastes {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  call s:nmap('<M-p>', '<Plug>(SwapPasteNext)')
  call s:nmap('<M-P>', '<Plug>(SwapPastePrevious)')
  nnoremap <silent> <Plug>(SwapPasteNext)     :call yanktools#swap_paste(1, "P")<cr>
  nnoremap <silent> <Plug>(SwapPastePrevious) :call yanktools#swap_paste(0, "P")<cr>


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " z mode {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  if get(g:, 'yanktools_zeta', 1)
    call s:nmap('yz', '<Plug>(ZetaYank)')
    call s:xmap('Zy', '<Plug>(ZetaYankVisual)')

    call s:nmap('dz', '<Plug>(ZetaDelete)')
    call s:nmap('dzd', '<Plug>(ZetaDeleteLine)')
    call s:xmap('Zd', '<Plug>(ZetaDeleteVisual)')

    call s:nmap('zp', '<Plug>(ZetaPaste_p)')
    call s:nmap('zP', '<Plug>(ZetaPaste_P)')
    call s:xmap('Zp', '<Plug>(ZetaPasteVisual)')

    call s:nmapf(format.'zp', '<Plug>(ZetaPasteIndent_p)')
    call s:nmapf(format.'zP', '<Plug>(ZetaPasteIndent_P)')
  endif

  nnoremap <silent><expr> <Plug>(ZetaYank)           yanktools#zeta#yank_with_key("y")
  xnoremap <silent><expr> <Plug>(ZetaYankVisual)     yanktools#zeta#yank_with_key("y")
  nnoremap <silent><expr> <Plug>(ZetaDelete)         yanktools#zeta#del_with_key("d")
  nnoremap <silent><expr> <Plug>(ZetaDeleteLine)     yanktools#zeta#del_with_key("dd")
  xnoremap <silent><expr> <Plug>(ZetaDeleteVisual)   yanktools#zeta#del_with_key("d")
  nnoremap <silent>       <Plug>(ZetaPaste_p)        :call yanktools#zeta#paste_with_key('p', '(ZetaPaste_p)', 0 , 0)<cr>
  nnoremap <silent>       <Plug>(ZetaPaste_P)        :call yanktools#zeta#paste_with_key('P', '(ZetaPaste_P)', 0 , 0)<cr>
  xnoremap <silent>       <Plug>(ZetaPasteVisual)    :call yanktools#zeta#paste_with_key('p', '(ZetaPaste_p)', 1 , 0)<cr>
  nnoremap <silent>       <Plug>(ZetaPasteIndent_p)  :call yanktools#zeta#paste_with_key('p', '(ZetaPasteIndent_p)', 0, 1)\<cr>
  nnoremap <silent>       <Plug>(ZetaPasteIndent_P)  :call yanktools#zeta#paste_with_key('P', '(ZetaPasteIndent_P)', 0, 1)\<cr>

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Misc commands                                                             {{{1
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  nnoremap <silent> <Plug>(ToggleAutoIndent)  :ToggleAutoIndent<cr>
  nnoremap <silent> <Plug>(ToggleRedirection) :ToggleRedirection<cr>
  nnoremap <silent> <Plug>(FreezeYank)        :call yanktools#stack#freeze()<cr>
  nnoremap <silent> <Plug>(ClearYankStack)    :call yanktools#extras#clear_yanks(0, 1)<cr>
  nnoremap <silent> <Plug>(ClearZetaStack)    :call yanktools#extras#clear_yanks(1)<cr>
  nnoremap <silent> <Plug>(Yanks)             :call yanktools#extras#show_yanks('y')<cr>
  nnoremap <silent> <Plug>(RedirectedYanks)   :call yanktools#extras#show_yanks('x')<cr>
  nnoremap <silent> <Plug>(ZetaYanks)         :call yanktools#extras#show_yanks('z')<cr>
  nnoremap <silent> <Plug>(ConvertYankType)   :call yanktools#extras#change_yank_type()<cr>
  nnoremap <silent> <Plug>(YanktoolsMenu)     :Yanktools<cr>
  nnoremap <silent> <expr> <Plug>(ISelectYank) exists('g:loaded_fzf')
        \ ? ":FzfSelectYank\<cr>" : ":ISelectYank\<cr>"
  nnoremap <silent> <expr> <Plug>(ISelectYank!) exists('g:loaded_fzf')
        \ ? ":FzfSelectYank!\<cr>" : ":ISelectYank!\<cr>"

  call s:nmaparg('cyi', '<Plug>(ToggleAutoIndent)')
  call s:nmaparg('cyr', '<Plug>(ToggleRedirection)')
  call s:nmaparg('cyf', '<Plug>(FreezeYank)')
  call s:nmaparg('cys', '<Plug>(ClearYankStack)')
  call s:nmaparg('czs', '<Plug>(ClearZetaStack)')
  call s:nmaparg('yY',  '<Plug>(Yanks)')
  call s:nmaparg('yX',  '<Plug>(RedirectedYanks)')
  call s:nmaparg('yZ',  '<Plug>(ZetaYanks)')
  call s:nmaparg('yiy', '<Plug>(ISelectYank)')
  call s:nmaparg('yir', '<Plug>(ISelectYank!)')
  call s:nmaparg('cyt', '<Plug>(ConvertYankType)')
  call s:nmaparg('cym', '<Plug>(YanktoolsMenu)')
endfunction
