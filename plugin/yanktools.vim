let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_yanktools')
  finish
endif

"------------------------------------------------------------------------------

let g:loaded_yanktools = 1

let g:yanktools = {'vars': {}}
call yt#funcs#init()
call yt#stack#init()

let g:yanktools_move_after = get(g:, 'yanktools_move_after', 0)
let g:yanktools_autoindent         = get(g:, 'yanktools_autoindent', 0)



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands                                                              {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
  autocmd!
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

command! Yanks              call yt#extras#show_yanks('y')
command! ZetaYanks          call yt#extras#show_yanks('z')
command! ClearYankStack     call yt#extras#clear_yanks(0)
command! ClearZetaStack     call yt#extras#clear_yanks(1)
command! ToggleAutoIndent   call yt#extras#toggle_autoformat()
command! ToggleRecordYanks  call yt#extras#toggle_recording()

com! -bang InteractivePaste call yt#extras#select_yank()



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugs                                                                     {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <silent><expr>   <Plug>(Yank)                yt#yank_with_key("y")
xnoremap <silent><expr>   <Plug>(Yank)                yt#yank_with_key("y")

nnoremap <silent><expr>   <Plug>(Cut)                 yt#delete(v:count, v:register, 0)
xnoremap <silent><expr>   <Plug>(Cut)                 yt#delete(v:count, v:register, 1)
nnoremap <silent><expr>   <Plug>(CutLine)             yt#delete_line(v:count, v:register)

nnoremap <silent><expr>   <Plug>(ReplaceOperator)     yt#replace#operator(v:count, v:register)
nnoremap <silent><expr>   <Plug>(ReplaceLineSingle)   yt#replace#line(v:count, v:register, 0)
nnoremap <silent><expr>   <Plug>(ReplaceLineMulti)    yt#replace#line(v:count, v:register, 1)

nnoremap <silent><expr>   <Plug>(Duplicate)           yt#duplicate(v:count)
nnoremap <silent><expr>   <Plug>(DuplicateLines)      yt#duplicate_lines(v:count)
xnoremap <silent><expr>   <Plug>(Duplicate)           yt#duplicate_visual()

nnoremap <silent><expr>   <Plug>(Paste_p)             yt#paste_with_key("p", "(Paste_p)", 0, 0)
xnoremap <silent><expr>   <Plug>(Paste_p)             yt#paste_with_key("p", "(Paste_p)", 1, 0)
nnoremap <silent><expr>   <Plug>(PasteIndent_p)       yt#paste_with_key("p", "(Paste_p)", 0, 1)
nnoremap <silent><expr>   <Plug>(Paste_P)             yt#paste_with_key("P", "(Paste_P)", 0, 0)
xnoremap <silent><expr>   <Plug>(Paste_P)             yt#paste_with_key("P", "(Paste_P)", 1, 0)
nnoremap <silent><expr>   <Plug>(PasteIndent_P)       yt#paste_with_key("P", "(Paste_P)", 0, 1)

nnoremap <silent>         <Plug>(SwapPasteNext)       :call yt#swap_paste(1, "P")<cr>
nnoremap <silent>         <Plug>(SwapPastePrevious)   :call yt#swap_paste(0, "P")<cr>

nnoremap <silent>         <Plug>(ChooseNext)          :call yt#offset(1)<cr>
nnoremap <silent>         <Plug>(ChoosePrevious)      :call yt#offset(0)<cr>

nnoremap <silent><expr>   <Plug>(ZetaYank)            yt#zeta#yank_with_key("y")
nnoremap <silent><expr>   <Plug>(ZetaDelete)          yt#zeta#del_with_key("d")
nnoremap <silent><expr>   <Plug>(ZetaDeleteLine)      yt#zeta#del_with_key("dd")
nnoremap <silent>         <Plug>(ZetaPaste_p)         :call yt#zeta#paste_with_key('p', '(ZetaPaste_p)', 0)<cr>
nnoremap <silent>         <Plug>(ZetaPaste_P)         :call yt#zeta#paste_with_key('P', '(ZetaPaste_P)', 0)<cr>
xnoremap <silent><expr>   <Plug>(ZetaYank)            yt#zeta#yank_with_key("y")
xnoremap <silent><expr>   <Plug>(ZetaDelete)          yt#zeta#del_with_key("d")
xnoremap <silent>         <Plug>(ZetaPaste_p)         :call yt#zeta#paste_with_key('p', '(ZetaPaste_p)', 0)<cr>

nnoremap <silent>         <Plug>(ToggleAutoIndent)    :ToggleAutoIndent<cr>
nnoremap <silent>         <Plug>(FreezeYank)          :call yt#stack#freeze()<cr>
nnoremap <silent>         <Plug>(ClearYankStack)      :call yt#extras#clear_yanks(0)<cr>
nnoremap <silent>         <Plug>(ClearZetaStack)      :call yt#extras#clear_yanks(1)<cr>
nnoremap <silent>         <Plug>(Yanks)               :call yt#extras#show_yanks('y')<cr>
nnoremap <silent>         <Plug>(ZetaYanks)           :call yt#extras#show_yanks('z')<cr>
nnoremap <silent>         <Plug>(ConvertYankType)     :call yt#extras#convert_yank_type()<cr>
nnoremap <silent>         <Plug>(YanktoolsHelp)       :call yt#extras#help()<cr>
nnoremap <silent>         <Plug>(YankSaveCurrent)     :<c-u>call yt#save_current(v:register)<cr>
nnoremap <silent>         <Plug>(InteractivePaste)         :InteractivePaste<cr>
nnoremap <silent>         <Plug>(ToggleRecordYanks)   :ToggleRecordYanks<cr>
nnoremap <silent>         <Plug>(RedirectedYanks)     :call yt#extras#show_yanks('x')<cr>



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings                                                                  {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'yanktools_no_mappings', 0)
  finish
endif

let s:opt = get(g:, 'yanktools_options_key', 'yu')
let s:map = get(g:, 'yanktools_main_key', '')

if empty(s:map)
  echohl ErrorMsg
  echomsg '=================================================================='
  echomsg 'g:yanktools_main_key HAS NOT BEEN SET.'
  echomsg ' '
  echomsg 'Yanktools has been updated and you should read the documentation, '
  echomsg 'because of the extensive changes that have been made.'
  echomsg '=================================================================='
  unlet g:loaded_yanktools
  finish
endif

function! s:nmap(key, plug)
  if !hasmapto(a:plug, 'n')
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
  if !hasmapto(a:plug, 'v')
    exe 'xmap' a:key a:plug
  endif
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Black Hole                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


if get(g:, 'yanktools_black_hole', 1)
  nnoremap <expr> c     yt#redirect('c', v:register)
  nnoremap <expr> C     yt#redirect('C', v:register)
  xnoremap <expr> c     yt#redirect('c', v:register)
  nnoremap <expr> x     yt#redirect('x', v:register)
  nnoremap <expr> X     yt#redirect('X', v:register)
  xnoremap <expr> x     yt#redirect('d', v:register)
  nnoremap <expr> <del> yt#redirect('x', v:register)
  xnoremap <expr> <del> yt#redirect('d', v:register)
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank                                                                      {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nxmap(s:map.'y', '<Plug>(Yank)')
call s:nmap(s:map.'Y',  '<Plug>(Yank)$')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete                                                                    {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nxmap(s:map.'d', '<Plug>(Cut)')
call s:nmap(s:map.'D',  '<Plug>(Cut)$')
call s:nmap(s:map.'dd', '<Plug>(CutLine)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator                                                          {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap(s:map,          '<Plug>(ReplaceOperator)')
call s:nmap(s:map.s:map,    '<Plug>(ReplaceLineSingle)')
call s:nmap(s:map.'rr',     '<Plug>(ReplaceLineMulti)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                 {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap('yd',    '<Plug>(Duplicate)')
call s:nmap('<M-d>', '<Plug>(DuplicateLines)')
call s:xmap('<M-d>', '<Plug>(Duplicate)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Paste keys                                                                {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nxmap('p', '<Plug>(Paste_p)')
call s:nmap('P',  '<Plug>(Paste_P)')
call s:nmap('[p', '<Plug>(PasteIndent_P)')
call s:nmap(']p', '<Plug>(PasteIndent_p)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap pastes                                                               {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap('<M-p>', '<Plug>(SwapPasteNext)')
call s:nmap('<M-P>', '<Plug>(SwapPastePrevious)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset                                                             {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call s:nmap(']y', '<Plug>(ChooseNext)')
call s:nmap('[y', '<Plug>(ChoosePrevious)')



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" z mode                                                                    {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'yanktools_map_zeta', 1)
  call s:nmap('yz', '<Plug>(ZetaYank)')
  call s:xmap('ZY', '<Plug>(ZetaYank)')

  call s:nmap('dz', '<Plug>(ZetaDelete)')
  call s:nmap('dzd', '<Plug>(ZetaDeleteLine)')
  call s:xmap('ZD', '<Plug>(ZetaDelete)')

  call s:nmap('zp', '<Plug>(ZetaPaste_p)')
  call s:nmap('zP', '<Plug>(ZetaPaste_P)')
  call s:xmap('ZP', '<Plug>(ZetaPaste_p)')
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc commands                                                             {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'yanktools_map_commands', 1)
  call s:nmaparg(s:opt.'ai', '<Plug>(ToggleAutoIndent)')
  call s:nmaparg(s:opt.'f', '<Plug>(FreezeYank)')
  call s:nmaparg(s:opt.'xs', '<Plug>(ClearYankStack)')
  call s:nmaparg(s:opt.'xz', '<Plug>(ClearZetaStack)')
  call s:nmaparg(s:opt.'Y',  '<Plug>(Yanks)')
  call s:nmaparg(s:opt.'Z',  '<Plug>(ZetaYanks)')
  call s:nmaparg(s:opt.'i', '<Plug>(InteractivePaste)')
  call s:nmaparg(s:opt.'c', '<Plug>(ConvertYankType)')
  call s:nmaparg(s:opt.'s', '<Plug>(YankSaveCurrent)')
  call s:nmaparg(s:opt.'?', '<Plug>(YanktoolsHelp)')
  call s:nmaparg(s:opt.'r', '<Plug>(ToggleRecordYanks)')
endif


"------------------------------------------------------------------------------

let &cpo = s:save_cpo
unlet s:save_cpo
