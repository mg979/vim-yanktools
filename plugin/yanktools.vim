let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_yanktools')
    finish
endif

"------------------------------------------------------------------------------

let g:loaded_yanktools = 1
let g:yanktools_autoindent = 0

let g:yanktools = {'vars': {}}
call yt#funcs#init()
call yt#stack#init()



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Persistance and autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au VimEnter * call s:check_persistance()

fun! s:check_persistance()
    "{{{1
    if exists('g:YANKTOOLS_PERSIST') && !get(g:, 'yanktools_persistance', 0)
        unlet g:YANKTOOLS_PERSIST
    elseif exists('g:YANKTOOLS_PERSIST')
        let g:yanktools.yank.stack = deepcopy(g:YANKTOOLS_PERSIST)
        let g:yanktools_persistance = 1
    elseif get(g:, 'yanktools_persistance', 0)
        let g:YANKTOOLS_PERSIST = deepcopy(g:yanktools.yank.stack)
    endif
    if get(g:, 'yanktools_persistance', 0)
        augroup yanktools_persist
            au!
            au BufWrite,VimLeave * let g:YANKTOOLS_PERSIST = deepcopy(g:yanktools.yank.stack)
        augroup END
    endif
endfun "}}}

augroup plugin-yanktools
    "{{{1
    autocmd!
    autocmd TextChanged * call yt#on_text_change()
    autocmd InsertEnter * call yt#on_text_change()
    autocmd CursorMoved * call yt#check_swap()

    if exists("##TextYankPost")
        autocmd TextYankPost * call yt#check_yanks()
    else
        autocmd CursorMoved  * call yt#check_yanks()
        autocmd CursorHold   * call yt#check_yanks()
    endif
augroup END
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands and plugs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Commands {{{1
command! Yanks              call yt#extras#show_yanks('y')
command! ZetaYanks          call yt#extras#show_yanks('z')
command! ClearYankStack     call yt#extras#clear_yanks(0)
command! ClearZetaStack     call yt#extras#clear_yanks(1)
command! ToggleAutoIndent   call yt#extras#toggle_autoindent()
command! InteractivePaste   call yt#extras#select_yank()
command! AutoYanks          call yt#extras#auto_yanks()
command! YanksPersistance   call yt#extras#toggle_persistance()
"}}}
" Plugs {{{1
nnoremap <silent><expr>   <Plug>(Yank)                yt#yank_with_key("y")
xnoremap <silent><expr>   <Plug>(Yank)                yt#yank_with_key("y")

nnoremap <silent><expr>   <Plug>(Cut)                 yt#delete(v:count, v:register, 0)
xnoremap <silent><expr>   <Plug>(Cut)                 yt#delete(v:count, v:register, 1)
nnoremap <silent><expr>   <Plug>(Change)              yt#redirect('c', v:register, 1)
xnoremap <silent><expr>   <Plug>(Change)              yt#redirect('c', v:register, 1)

nnoremap <silent><expr>   <Plug>(Replace)             yt#replace#operator(v:count, v:register, 0)
nnoremap <silent><expr>   <Plug>(ReplaceLines)        yt#replace#line(v:count, v:register, 0)
nnoremap <silent><expr>   <Plug>(Replace=)            yt#replace#operator(v:count, v:register, 1)

nnoremap <silent><expr>   <Plug>(Duplicate)           yt#duplicate#operator(v:count)
nnoremap <silent><expr>   <Plug>(DuplicateLines)      yt#duplicate#lines(v:count)
xnoremap <silent><expr>   <Plug>(Duplicate)           yt#duplicate#visual()

nnoremap <silent><expr>   <Plug>(Paste_p)             yt#paste_with_key("p", 0, 0)
xnoremap <silent><expr>   <Plug>(Paste_p)             yt#paste_with_key("p", 1, 0)
nnoremap <silent><expr>   <Plug>(Paste_P)             yt#paste_with_key("P", 0, 0)
nnoremap <silent><expr>   <Plug>(Paste_gp)            yt#paste_with_key("gp", 0, 0)
xnoremap <silent><expr>   <Plug>(Paste_gp)            yt#paste_with_key("gp", 1, 0)
nnoremap <silent><expr>   <Plug>(Paste_gP)            yt#paste_with_key("gP", 0, 0)
nnoremap <silent><expr>   <Plug>(PasteIndent_p)       yt#paste_with_key("p", 0, 1)
nnoremap <silent><expr>   <Plug>(PasteIndent_P)       yt#paste_with_key("P", 0, 1)

nnoremap <silent>         <Plug>(SwapPasteNext)       :<c-u>call yt#swap_paste(1, 0)<cr>
nnoremap <silent>         <Plug>(SwapPastePrevious)   :<c-u>call yt#swap_paste(0, 0)<cr>
nnoremap <silent>         <Plug>(SwapAutoNext)        :<c-u>call yt#swap_paste(1, 1)<cr>
nnoremap <silent>         <Plug>(SwapAutoPrevious)    :<c-u>call yt#swap_paste(0, 1)<cr>

nnoremap <silent>         <Plug>(YankNext)            :<c-u>call yt#offset(v:count1)<cr>
nnoremap <silent>         <Plug>(YankPrevious)        :<c-u>call yt#offset(v:count1 * -1)<cr>

nnoremap <silent><expr>   <Plug>(ZetaYank)            yt#zeta#yank("y")
nnoremap <silent><expr>   <Plug>(ZetaDelete)          yt#zeta#delete(v:count, v:register, 0)
xnoremap <silent><expr>   <Plug>(ZetaDelete)          yt#zeta#delete(v:count, v:register, 1)
nnoremap <silent>         <Plug>(ZetaPaste_p)         :call yt#zeta#paste('p', '(ZetaPaste_p)')<cr>
nnoremap <silent>         <Plug>(ZetaPaste_P)         :call yt#zeta#paste('P', '(ZetaPaste_P)')<cr>
xnoremap <silent><expr>   <Plug>(ZetaYank)            yt#zeta#yank("y")
xnoremap <silent><expr>   <Plug>(ZetaPaste)           yt#zeta#visual_paste()

nnoremap <silent>         <Plug>(SetYank)             :<c-u>call yt#extras#set_offset(v:count)<cr>
nnoremap <silent>         <Plug>(Yanks)               :<c-u>call yt#extras#show_yanks('y')<cr>
nnoremap <silent>         <Plug>(ZetaYanks)           :<c-u>call yt#extras#show_yanks('z')<cr>
nnoremap <silent>         <Plug>(ConvertYankType)     :<c-u>call yt#extras#convert_yank_type()<cr>
nnoremap <silent>         <Plug>(YanktoolsHelp)       :<c-u>call yt#extras#help()<cr>
nnoremap <silent>         <Plug>(YankSaveCurrent)     :<c-u>call yt#extras#save_current(v:register)<cr>

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'yanktools_no_mappings', 0)
    let &cpo = s:save_cpo
    unlet s:save_cpo
    finish
endif

let s:map = get(g:, 'yanktools_main_key', '')
let s:opt = get(g:, 'yanktools_options_key', 'yu')


" Helpers {{{1
function! s:nmap(key, plug)
    if empty(maparg(a:key, 'n'))
        exe 'nmap' a:key a:plug
    endif
endfunction

function! s:nmapcmd(key, cmd)
    if empty(maparg(a:key, 'n'))
        exe 'nnoremap <silent>' a:key printf(':<c-u>%s<cr>', a:cmd)
    endif
endfunction

function! s:xmap(key, plug)
    if empty(maparg(a:key, 'x'))
        exe 'xmap' a:key a:plug
    endif
endfunction
"}}}
" Register preservation {{{1
if get(g:, 'yanktools_preserve_unnamed', 1)
    nnoremap <expr> c     yt#redirect('c', v:register, 0)
    nnoremap <expr> C     yt#redirect('C', v:register, 0)
    xnoremap <expr> c     yt#redirect('c', v:register, 0)
    nnoremap <expr> x     yt#redirect('x', v:register, 0)
    nnoremap <expr> X     yt#redirect('X', v:register, 0)
    nnoremap <expr> <del> yt#redirect('x', v:register, 0)
    xnoremap <expr> <del> yt#redirect('d', v:register, 0)
endif
"}}}
" Yank, delete, change, replace {{{1
if !empty(s:map)
    call s:nmap(s:map.'y',   '<Plug>(Yank)')
    call s:xmap(s:map.'y',   '<Plug>(Yank)')
    call s:nmap(s:map.'Y',   '<Plug>(Yank)$')

    call s:nmap(s:map.'d',   '<Plug>(Cut)')
    call s:xmap(s:map.'d',   '<Plug>(Cut)')
    call s:nmap(s:map.'D',   '<Plug>(Cut)$')
    call s:nmap(s:map.'dd',  '<Plug>(Cut)_')

    call s:nmap(s:map.'c',   '<Plug>(Change)')
    call s:xmap(s:map.'c',   '<Plug>(Change)')
    call s:nmap(s:map.'C',   '<Plug>(Change)$')
    call s:nmap(s:map.'cc',  '<Plug>(Change)_')

    call s:nmap(s:map,       '<Plug>(Replace)')
    call s:nmap(s:map.s:map[-1:], '<Plug>(Replace)_')
    call s:nmap(s:map.'rr',  '<Plug>(ReplaceLines)')
    call s:nmap(s:map.'q',   '<Plug>(Replace=)')
    call s:nmap(s:map.'qq',  '<Plug>(Replace=)_')
endif
"}}}
" Duplicate {{{1
call s:nmap('yd',    '<Plug>(Duplicate)')
call s:nmap('ydd',   '<Plug>(DuplicateLines)')
call s:nmap('<M-d>', '<Plug>(Duplicate)_')
call s:xmap('<M-d>', '<Plug>(Duplicate)')
"}}}
" Paste {{{1
call s:nmap('p',   '<Plug>(Paste_p)')
call s:xmap('p',   '<Plug>(Paste_p)')
call s:nmap('P',   '<Plug>(Paste_P)')
call s:nmap('gp',  '<Plug>(Paste_gp)')
call s:xmap('gp',  '<Plug>(Paste_gp)')
call s:nmap('gP',  '<Plug>(Paste_gP)')
call s:nmap('[p',  '<Plug>(PasteIndent_P)')
call s:nmap(']p',  '<Plug>(PasteIndent_p)')
"}}}
" Swap paste {{{1
call s:nmap('<M-p>', '<Plug>(SwapPasteNext)')
call s:nmap('<M-P>', '<Plug>(SwapPastePrevious)')
call s:nmap('<M-a>', '<Plug>(SwapAutoNext)')
call s:nmap('<M-A>', '<Plug>(SwapAutoPrevious)')
"}}}
" Choose offset {{{1
call s:nmap(']y', '<Plug>(YankNext)')
call s:nmap('[y', '<Plug>(YankPrevious)')
"}}}
" z mode {{{1
if get(g:, 'yanktools_map_zeta', 1)
    call s:nmap('yz', '<Plug>(ZetaYank)')
    call s:xmap('ZY', '<Plug>(ZetaYank)')

    call s:nmap('dz', '<Plug>(ZetaDelete)')
    call s:nmap('dzd', '<Plug>(ZetaDelete)_')
    call s:xmap('ZD', '<Plug>(ZetaDelete)')

    call s:nmap('zp', '<Plug>(ZetaPaste_p)')
    call s:nmap('zP', '<Plug>(ZetaPaste_P)')
    call s:xmap('ZP', '<Plug>(ZetaPaste)')
endif
"}}}
" Misc commands {{{1
if !empty(s:opt)
    call s:nmapcmd(s:opt.'=',  'ToggleAutoIndent')
    call s:nmapcmd(s:opt.'xy', 'ClearYankStack')
    call s:nmapcmd(s:opt.'xz', 'ClearZetaStack')
    call s:nmapcmd(s:opt.'i',  'InteractivePaste')
    call s:nmapcmd(s:opt.'a',  'AutoYanks')
    call s:nmap(s:opt.'Y',  '<Plug>(Yanks)')
    call s:nmap(s:opt.'Z',  '<Plug>(ZetaYanks)')
    call s:nmap(s:opt.'0',  '<Plug>(SetYank)')
    call s:nmap(s:opt.'c',  '<Plug>(ConvertYankType)')
    call s:nmap(s:opt.'s',  '<Plug>(YankSaveCurrent)')
    call s:nmap(s:opt.'?',  '<Plug>(YanktoolsHelp)')
    call s:nmap(s:opt.'p',  '<Plug>(YankViewNext)')
endif
"}}}


"------------------------------------------------------------------------------

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ft=vim et sw=4 ts=4 sts=4 fdm=marker
