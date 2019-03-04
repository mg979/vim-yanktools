
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

let g:yanktools.Funcs = yanktools#funcs#init()



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands                                                              {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
  autocmd!
  autocmd VimEnter    * call yanktools#init_vars()
  autocmd TextChanged * call yanktools#on_text_change()
  autocmd InsertEnter * call yanktools#on_text_change()

  if exists("##TextYankPost")
    autocmd TextYankPost * call yanktools#check_yanks()
    autocmd CursorMoved  * call yanktools#check_yanks()
  else
    autocmd CursorMoved  * call yanktools#check_yanks()
    autocmd CursorHold   * call yanktools#check_yanks()
  endif
augroup END




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands                                                                  {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks             call yanktools#extras#show_yanks('y')
command! ZetaYanks         call yanktools#extras#show_yanks('z')
command! ClearYankStacks   call yanktools#extras#clear_yanks(0, 1)
command! ClearZetaStack    call yanktools#extras#clear_yanks(1)
command! ToggleAutoIndent  call yanktools#extras#toggle_autoformat()

if !g:yanktools_manual
  command! RedirectedYanks   call yanktools#extras#show_yanks('x')
  command! ToggleRedirection call yanktools#extras#toggle_redirection()
endif

com! -bang FzfSelectYank call fzf#run({'source': yanktools#extras#yanks(<bang>0),
      \ 'sink': function('yanktools#extras#select_yank_fzf'), 'down': '30%',
      \ 'options': '--prompt "Select Yank >>>   "'})

com! -bang ISelectYank call yanktools#extras#select_yank(<bang>0)

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
      \ 'sink': function('yanktools#extras#fzf_menu'), 'down': '30%',
      \ 'options': '--prompt "Yanktools Menu >>>   "'})




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let paste_keys                          = get(g:, 'yanktools_paste_keys', ['p', 'P'])
let format                              = get(g:, 'yanktools_format_prefix', "<")
let leader                              = get(g:, 'mapleader', '\')

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

nnoremap <silent><expr> <Plug>(Yank) yanktools#yank_with_key("y")
xnoremap <silent><expr> <Plug>(Yank) yanktools#yank_with_key("y")

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
  let c = ":\<c-u>call yanktools#redir_opts(v:register)\<cr>"
  let c .= ':set opfunc=yanktools#'.(a:cut ? 'cut' : 'redir')."\<cr>"
  return c.n."g@"
endfun

if !g:yanktools_manual
  call s:nmap('d', '<Plug>(Redirect_d)')
  call s:nmap('D',  '<Plug>(Redirect_D)')
  call s:nmap('dd', '<Plug>(RedirectLine)')
  call s:xmap('d', '<Plug>(RedirectVisual)')

  nnoremap <silent><expr> <Plug>(Redirect_d)     <sid>redirect(v:count, 0)
  nmap     <silent>       <Plug>(Redirect_D)     <Plug>(Redirect_d)$
  nnoremap <silent>       <Plug>(RedirectLine)   :<c-u>call yanktools#delete_line(v:register, v:count, 0)<cr>
  xnoremap <silent><expr> <Plug>(RedirectVisual) yanktools#delete_visual(v:register, 0)
endif




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cut                                                                       {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent><expr> <Plug>(Cut)         <sid>redirect(v:count, 1)
nnoremap <silent>       <Plug>(CutLine)     :<c-u>call yanktools#delete_line(v:register, v:count, 1)<cr>
xnoremap <silent><expr> <Plug>(CutVisual)   yanktools#delete_visual(v:register, 1)

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

nnoremap <silent> <Plug>(ReplaceOperatorS)  :call yanktools#replop#opts(v:register, 0, 0)<cr>:set opfunc=yanktools#replop#replace<cr>g@
nnoremap <silent> <Plug>(ReplaceOperatorR)  :call yanktools#replop#opts(v:register, 0, 1)<cr>:set opfunc=yanktools#replop#replace<cr>g@
nnoremap <silent> <Plug>(ReplaceLineSingle) :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 0, 0)<cr>
nnoremap <silent> <Plug>(ReplaceLineMulti)  :<c-u>call yanktools#replop#replace_line(v:register, v:count1, 1, 0)<cr>

let key = get(g:, 'yanktools_replace_key', '')
if !empty(key)
  call s:nmap(key,            '<Plug>(ReplaceOperatorR)')
  call s:nmap(key.'r',        '<Plug>(ReplaceOperatorS)')
  call s:nmap(key.key,        '<Plug>(ReplaceLineSingle)')
  call s:nmap(leader.key.key, '<Plug>(ReplaceLineMulti)')
else
  call s:nmap('yr',           '<Plug>(ReplaceOperatorR)')
  call s:nmap('yR',           '<Plug>(ReplaceOperatorS)')
  call s:nmap('yrr',          '<Plug>(ReplaceLineSingle)')
  call s:nmap(leader.'yrr',   '<Plug>(ReplaceLineMulti)')
endif





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                 {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent>       <Plug>(DuplicateOperator)   :set opfunc=yanktools#duplicate<cr>g@
nnoremap <silent><expr> <Plug>(DuplicateLines)      yanktools#duplicate_lines()
xnoremap <silent><expr> <Plug>(DuplicateVisual)     yanktools#duplicate_visual()

call s:nmap('yd',    '<Plug>(DuplicateOperator)')
call s:nmap('ydd',   '<Plug>(DuplicateLines)')
call s:xmap('<M-d>', '<Plug>(DuplicateVisual)')





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Paste redirected                                                          {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !g:yanktools_manual

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
endif





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Paste keys                                                                {{{1
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
" Swap pastes                                                               {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap('<M-p>', '<Plug>(SwapPasteNext)')
call s:nmap('<M-P>', '<Plug>(SwapPastePrevious)')
nnoremap <silent> <Plug>(SwapPasteNext)     :call yanktools#swap_paste(1, "P")<cr>
nnoremap <silent> <Plug>(SwapPastePrevious) :call yanktools#swap_paste(0, "P")<cr>





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" z mode                                                                    {{{1
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
endif

nnoremap <silent><expr> <Plug>(ZetaYank)           yanktools#zeta#yank_with_key("y")
xnoremap <silent><expr> <Plug>(ZetaYankVisual)     yanktools#zeta#yank_with_key("y")
nnoremap <silent><expr> <Plug>(ZetaDelete)         yanktools#zeta#del_with_key("d")
nnoremap <silent><expr> <Plug>(ZetaDeleteLine)     yanktools#zeta#del_with_key("dd")
xnoremap <silent><expr> <Plug>(ZetaDeleteVisual)   yanktools#zeta#del_with_key("d")
nnoremap <silent>       <Plug>(ZetaPaste_p)        :call yanktools#zeta#paste_with_key('p', '(ZetaPaste_p)', 0 , 0)<cr>
nnoremap <silent>       <Plug>(ZetaPaste_P)        :call yanktools#zeta#paste_with_key('P', '(ZetaPaste_P)', 0 , 0)<cr>
xnoremap <silent>       <Plug>(ZetaPasteVisual)    :call yanktools#zeta#paste_with_key('p', '(ZetaPaste_p)', 1 , 0)<cr>




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc commands                                                             {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmaparg('cyi', '<Plug>(ToggleAutoIndent)')
call s:nmaparg('cyf', '<Plug>(FreezeYank)')
call s:nmaparg('cys', '<Plug>(ClearYankStack)')
call s:nmaparg('czs', '<Plug>(ClearZetaStack)')
call s:nmaparg('yY',  '<Plug>(Yanks)')
call s:nmaparg('yZ',  '<Plug>(ZetaYanks)')
call s:nmaparg('yiy', '<Plug>(ISelectYank)')
call s:nmaparg('yir', '<Plug>(ISelectYank!)')
call s:nmaparg('cyt', '<Plug>(ConvertYankType)')

nnoremap <silent> <Plug>(ToggleAutoIndent)  :ToggleAutoIndent<cr>
nnoremap <silent> <Plug>(FreezeYank)        :call yanktools#stack#freeze()<cr>
nnoremap <silent> <Plug>(ClearYankStack)    :call yanktools#extras#clear_yanks(0, 1)<cr>
nnoremap <silent> <Plug>(ClearZetaStack)    :call yanktools#extras#clear_yanks(1)<cr>
nnoremap <silent> <Plug>(Yanks)             :call yanktools#extras#show_yanks('y')<cr>
nnoremap <silent> <Plug>(ZetaYanks)         :call yanktools#extras#show_yanks('z')<cr>
nnoremap <silent> <Plug>(ConvertYankType)   :call yanktools#extras#convert_yank_type()<cr>
nnoremap <silent> <expr> <Plug>(ISelectYank) exists('g:loaded_fzf')
      \ ? ":FzfSelectYank\<cr>" : ":ISelectYank\<cr>"
nnoremap <silent> <expr> <Plug>(ISelectYank!) exists('g:loaded_fzf')
      \ ? ":FzfSelectYank!\<cr>" : ":ISelectYank!\<cr>"

if !g:yanktools_manual
  nnoremap <silent> <Plug>(ToggleRedirection) :ToggleRedirection<cr>
  nnoremap <silent> <Plug>(RedirectedYanks)   :call yanktools#extras#show_yanks('x')<cr>
  nnoremap <silent> <Plug>(YanktoolsMenu)     :Yanktools<cr>

  call s:nmaparg('cyr', '<Plug>(ToggleRedirection)')
  call s:nmaparg('yX',  '<Plug>(RedirectedYanks)')
  call s:nmaparg('cym', '<Plug>(YanktoolsMenu)')
endif
