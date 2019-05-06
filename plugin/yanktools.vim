
let g:loaded_yanktools = 1

let g:yanktools = {'vars': {}}
let g:yanktools.vars.redirecting = 0
let g:yanktools.vars.format_this = 0
let g:yanktools.vars.has_changed = 0
let g:yanktools.vars.is_replacing = 0
let g:yanktools.vars.plug = []
let g:yanktools.vars.move_this = 0
let g:yanktools.vars.zeta = 0
let g:yanktools.vars.has_yanked = 0

let g:yanktools_manual                  = get(g:, 'yanktools_manual', 1)
let g:yanktools_move_cursor_after_paste = get(g:, 'yanktools_move_cursor_after_paste', 0)
let g:yanktools_auto_format_all         = get(g:, 'yanktools_auto_format_all', 0)
let g:yanktools_redirect_register       = get(g:, 'yanktools_redirect_register', "x")
let g:yanktools_use_redirection         = get(g:, 'yanktools_use_redirection', !empty(g:yanktools_redirect_register))

let g:yanktools.Funcs = yt#funcs#init()



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands                                                              {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
  autocmd!
  autocmd VimEnter    * call yt#init_vars()
  autocmd TextChanged * call yt#on_text_change()
  autocmd InsertEnter * call yt#on_text_change()

  if exists("##TextYankPost")
    autocmd TextYankPost * call yt#check_yanks()
    autocmd CursorMoved  * call yt#check_yanks()
  else
    autocmd CursorMoved  * call yt#check_yanks()
    autocmd CursorHold   * call yt#check_yanks()
  endif
augroup END




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands                                                                  {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks             call yt#extras#show_yanks('y')
command! ZetaYanks         call yt#extras#show_yanks('z')
command! ClearYankStacks   call yt#extras#clear_yanks(0, 1)
command! ClearZetaStack    call yt#extras#clear_yanks(1)
command! ToggleAutoIndent  call yt#extras#toggle_autoformat()

if !g:yanktools_manual
  command! RedirectedYanks   call yt#extras#show_yanks('x')
  command! ToggleRedirection call yt#extras#toggle_redirection()
endif

com! -bang FzfSelectYank call fzf#run({'source': yt#extras#yanks(<bang>0),
      \ 'sink': function('yt#extras#select_yank_fzf'), 'down': '30%',
      \ 'options': '--prompt "Select Yank >>>   "'})

com! -bang ISelectYank call yt#extras#select_yank(<bang>0)

com! Yanktools call fzf#run({'source': [
      \ 'Toggle Freeze Offset',
      \ 'Convert Yank Type',
      \ 'Toggle Auto Indent',
      \ 'Toggle Single Stack',
      \ 'Clear Yank Stacks',
      \ 'Clear Zeta Stack',
      \ 'Display Yanks',
      \ 'Select Yank',
      \ 'Select Redirected Yank',
      \ ],
      \ 'sink': function('yt#extras#fzf_menu'), 'down': '30%',
      \ 'options': '--prompt "Yanktools Menu >>>   "'})




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:paste_keys = get(g:, 'yanktools_paste_keys', ['p', 'P'])
let s:format     = get(g:, 'yanktools_format_prefix', "<")

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
" Black Hole                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


if get(g:, 'yanktools_black_hole_c', 1)
  nnoremap c   "_c
  nnoremap C   "_C
  xnoremap c   "_c
endif

if get(g:, 'yanktools_black_hole_x', 1)
  nnoremap x   "_x
  nnoremap X   "_X
  xnoremap x   "_d
endif

if get(g:, 'yanktools_black_hole_del', 1)
  nnoremap <del> "_x
  xnoremap <del> "_d
endif




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank                                                                      {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent><expr> <Plug>(Yank) yt#yank_with_key("y")
xnoremap <silent><expr> <Plug>(Yank) yt#yank_with_key("y")

if !g:yanktools_manual
  call s:nmap('y',  '<Plug>(Yank)')
  call s:nmap('Y',  '<Plug>(Yank)$')
  call s:xmap('y',  '<Plug>(Yank)')
else
  call s:nmap('ys',  '<Plug>(Yank)')
  call s:nmap('yS',  '<Plug>(Yank)$')
  call s:xmap('sy',  '<Plug>(Yank)')
endif




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirection                                                               {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:redirect(count, cut)
  let n = a:count ? string(a:count) : ''
  let c = ":\<c-u>call yt#redir_opts(v:register)\<cr>"
  let c .= ':set opfunc=yt#'.(a:cut ? 'cut' : 'redir')."\<cr>"
  return c.n."g@"
endfun

if !g:yanktools_manual
  call s:nmap('d', '<Plug>(Redirect_d)')
  call s:nmap('D',  '<Plug>(Redirect_D)')
  call s:nmap('dd', '<Plug>(RedirectLine)')
  call s:xmap('d', '<Plug>(RedirectVisual)')

  nnoremap <silent><expr> <Plug>(Redirect_d)     <sid>redirect(v:count, 0)
  nmap     <silent>       <Plug>(Redirect_D)     <Plug>(Redirect_d)$
  nnoremap <silent>       <Plug>(RedirectLine)   :<c-u>call yt#delete_line(v:register, v:count, 0)<cr>
  xnoremap <silent><expr> <Plug>(RedirectVisual) yt#delete_visual(v:register, 0)
endif




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cut                                                                       {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent><expr> <Plug>(Cut)         <sid>redirect(v:count, 1)
nnoremap <silent>       <Plug>(CutLine)     :<c-u>call yt#delete_line(v:register, v:count, 1)<cr>
xnoremap <silent><expr> <Plug>(CutVisual)   yt#delete_visual(v:register, 1)

if !g:yanktools_manual
  call s:nmap('yx',  '<Plug>(Cut)')
  call s:nmap('yxx', '<Plug>(CutLine)')
  call s:xmap('x',   '<Plug>(CutVisual)')
else
  call s:nmap('ds',  '<Plug>(Cut)')
  call s:nmap('dS',  '<Plug>(Cut)$')
  call s:nmap('dsd', '<Plug>(CutLine)')
  call s:xmap('sd',  '<Plug>(CutVisual)')
endif





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator                                                          {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent> <Plug>(ReplaceOperatorS)  :call yt#replop#opts(v:register, 0, 0)<cr>:set opfunc=yt#replop#replace<cr>g@
nnoremap <silent> <Plug>(ReplaceOperatorR)  :call yt#replop#opts(v:register, 0, 1)<cr>:set opfunc=yt#replop#replace<cr>g@
nnoremap <silent> <Plug>(ReplaceLineSingle) :<c-u>call yt#replop#replace_line(v:register, v:count1, 0)<cr>
nnoremap <silent> <Plug>(ReplaceLineMulti)  :<c-u>call yt#replop#replace_multi_line(v:register, v:count1, 0)<cr>

fun! s:map_repl()
  let key = get(g:, 'yanktools_replace_key', '')
  if !empty(key)
    call s:nmap(key,            '<Plug>(ReplaceOperatorR)')
    call s:nmap(key.'r',        '<Plug>(ReplaceOperatorS)')
    call s:nmap(key.key,        '<Plug>(ReplaceLineSingle)')
    call s:nmap(key.'rr',       '<Plug>(ReplaceLineMulti)')
  else
    call s:nmap('yr',           '<Plug>(ReplaceOperatorR)')
    call s:nmap('yR',           '<Plug>(ReplaceOperatorS)')
    call s:nmap('yrr',          '<Plug>(ReplaceLineSingle)')
    call s:nmap('yrm',          '<Plug>(ReplaceLineMulti)')
  endif
endfun

call s:map_repl()





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                 {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent>       <Plug>(DuplicateOperator)   :set opfunc=yt#duplicate<cr>g@
nnoremap <silent><expr> <Plug>(DuplicateLines)      yt#duplicate_lines()
xnoremap <silent><expr> <Plug>(DuplicateVisual)     yt#duplicate_visual()

call s:nmap('yd',    '<Plug>(DuplicateOperator)')
call s:nmap('ydd',   '<Plug>(DuplicateLines)')
call s:xmap('<M-d>', '<Plug>(DuplicateVisual)')





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Paste redirected                                                          {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:map_rpaste()
  if !g:yanktools_manual

    let cmd = ' yt#paste_redirected_with_key'
    let prefix = get(g:, 'yanktools_redir_paste_prefix', '<leader>')

    for key in s:paste_keys
      let plug = '(PasteRedirected_'.key.')'

      if !empty(prefix)
        call s:nxmap(prefix.key, '<Plug>'.plug)
      endif
      exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
      exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

      let plug = '(PasteRedirectedIndent_'.key.')'

      if !empty(prefix)
        call s:nmapf(s:format.prefix.key, '<Plug>'.plug)
      endif
      exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
    endfor
  endif
endfun

call s:map_rpaste()





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Paste keys                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:map_paste()
  let cmd = ' yt#paste_with_key'

  for key in s:paste_keys
    let plug = '(Paste_'.key.')'
    call s:nxmap(key, '<Plug>'.plug)
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 0)'
    exec 'xnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 1, 0)'

    let plug = '(PasteIndent_'.key.')'
    call s:nmapf(s:format.key, '<Plug>'.plug)
    exec 'nnoremap <silent><expr> <Plug>'.plug.cmd.'("' . key . '", "'.plug.'", 0, 1)'
  endfor
endfun

call s:map_paste()





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap pastes                                                               {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap('<M-p>', '<Plug>(SwapPasteNext)')
call s:nmap('<M-P>', '<Plug>(SwapPastePrevious)')
nnoremap <silent> <Plug>(SwapPasteNext)     :call yt#swap_paste(1, "P")<cr>
nnoremap <silent> <Plug>(SwapPastePrevious) :call yt#swap_paste(0, "P")<cr>





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset                                                             {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap(']y', '<Plug>(YankNext)')
call s:nmap('[y', '<Plug>(YankPrevious)')
nnoremap <silent> <Plug>(YankNext)     :call yt#offset(1)<cr>
nnoremap <silent> <Plug>(YankPrevious) :call yt#offset(0)<cr>



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" z mode                                                                    {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'yanktools_zeta', 1)
  call s:nmap('yz', '<Plug>(ZetaYank)')
  call s:xmap('ZY', '<Plug>(ZetaYankVisual)')

  call s:nmap('dz', '<Plug>(ZetaDelete)')
  call s:nmap('dzd', '<Plug>(ZetaDeleteLine)')
  call s:xmap('ZD', '<Plug>(ZetaDeleteVisual)')

  call s:nmap('zp', '<Plug>(ZetaPaste_p)')
  call s:nmap('zP', '<Plug>(ZetaPaste_P)')
  call s:xmap('ZP', '<Plug>(ZetaPasteVisual)')
endif

nnoremap <silent><expr> <Plug>(ZetaYank)           yt#zeta#yank_with_key("y")
xnoremap <silent><expr> <Plug>(ZetaYankVisual)     yt#zeta#yank_with_key("y")
nnoremap <silent><expr> <Plug>(ZetaDelete)         yt#zeta#del_with_key("d")
nnoremap <silent><expr> <Plug>(ZetaDeleteLine)     yt#zeta#del_with_key("dd")
xnoremap <silent><expr> <Plug>(ZetaDeleteVisual)   yt#zeta#del_with_key("d")
nnoremap <silent>       <Plug>(ZetaPaste_p)        :call yt#zeta#paste_with_key('p', '(ZetaPaste_p)', 0 , 0)<cr>
nnoremap <silent>       <Plug>(ZetaPaste_P)        :call yt#zeta#paste_with_key('P', '(ZetaPaste_P)', 0 , 0)<cr>
xnoremap <silent>       <Plug>(ZetaPasteVisual)    :call yt#zeta#paste_with_key('p', '(ZetaPaste_p)', 1 , 0)<cr>




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc commands                                                             {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmaparg('yui', '<Plug>(ToggleAutoIndent)')
call s:nmaparg('yuf', '<Plug>(FreezeYank)')
call s:nmaparg('yuxs', '<Plug>(ClearYankStack)')
call s:nmaparg('yuxz', '<Plug>(ClearZetaStack)')
call s:nmaparg('yY',  '<Plug>(Yanks)')
call s:nmaparg('yZ',  '<Plug>(ZetaYanks)')
call s:nmaparg('yiy', '<Plug>(ISelectYank)')
call s:nmaparg('yuc', '<Plug>(ConvertYankType)')
call s:nmaparg('yus', '<Plug>(YankSaveCurrent)')
call s:nmaparg('yum', '<Plug>(YanktoolsMenu)')

nnoremap <silent> <Plug>(ToggleAutoIndent)  :ToggleAutoIndent<cr>
nnoremap <silent> <Plug>(FreezeYank)        :call yt#stack#freeze()<cr>
nnoremap <silent> <Plug>(ClearYankStack)    :call yt#extras#clear_yanks(0, 1)<cr>
nnoremap <silent> <Plug>(ClearZetaStack)    :call yt#extras#clear_yanks(1)<cr>
nnoremap <silent> <Plug>(Yanks)             :call yt#extras#show_yanks('y')<cr>
nnoremap <silent> <Plug>(ZetaYanks)         :call yt#extras#show_yanks('z')<cr>
nnoremap <silent> <Plug>(ConvertYankType)   :call yt#extras#convert_yank_type()<cr>
nnoremap <silent> <Plug>(YanktoolsMenu)     :Yanktools<cr>
nnoremap <silent> <Plug>(YankSaveCurrent)   :<c-u>call yt#save_current(v:register)<cr>
nnoremap <silent> <expr> <Plug>(ISelectYank) exists('g:loaded_fzf')
      \ ? ":FzfSelectYank\<cr>" : ":ISelectYank\<cr>"

if !g:yanktools_manual
  nnoremap <silent> <Plug>(ToggleRedirection) :ToggleRedirection<cr>
  nnoremap <silent> <Plug>(RedirectedYanks)   :call yt#extras#show_yanks('x')<cr>
  nnoremap <silent> <expr> <Plug>(ISelectYank!) exists('g:loaded_fzf')
        \ ? ":FzfSelectYank!\<cr>" : ":ISelectYank!\<cr>"

  call s:nmaparg('yur', '<Plug>(ToggleRedirection)')
  call s:nmaparg('yX',  '<Plug>(RedirectedYanks)')
  call s:nmaparg('yir', '<Plug>(ISelectYank!)')
endif
