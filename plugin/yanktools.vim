
let g:yanktools = {'vars': {}}
let g:yanktools.vars.redirecting = 0
let g:yanktools.vars.format_this = 0
let g:yanktools.vars.has_changed = 0
let g:yanktools.vars.is_replacing = 0
let g:yanktools.vars.plug = []
let g:yanktools.vars.move_this = 0
let g:yanktools.vars.zeta = 0
let g:yanktools.vars.has_yanked = 0

let g:yanktools.Funcs = yanktools#funcs#init()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter    * call yanktools#init_vars()
    autocmd TextChanged * call yanktools#on_text_change()
    autocmd InsertEnter * call yanktools#on_text_change()

    if exists("#TextYankPost") || has('patch-8.0.1394')
        autocmd TextYankPost * call yanktools#check_yanks()
        autocmd CursorMoved  * call yanktools#check_yanks()
    else
        autocmd CursorMoved  * call yanktools#check_yanks()
        autocmd CursorHold   * call yanktools#check_yanks()
    endif
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks             call yanktools#extras#show_yanks('y')
command! RedirectedYanks   call yanktools#extras#show_yanks('x')
command! ZetaYanks         call yanktools#extras#show_yanks('z')
command! ClearYankStacks   call yanktools#extras#clear_yanks(0, 1)
command! ClearZetaStack    call yanktools#extras#clear_yanks(1)
command! ToggleAutoIndent  call yanktools#extras#toggle_autoformat()
command! ToggleRedirection call yanktools#extras#toggle_redirection()

com! FzfSelectYank call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#select_yank_fzf'), 'down': '30%',
            \ 'options': '--prompt "Select Yank >>>   "'})

com! ISelectYank call yanktools#extras#select_yank()

com! Yanktools call fzf#run({'source': [
            \ 'Toggle Freeze Offset',
            \ 'Convert Yank Type',
            \ 'Toggle Auto Indent',
            \ 'Toggle Single Stack',
            \ 'Clear Yank Stacks',
            \ 'Clear Zeta Stack',
            \ 'Display Yanks',
            \ 'Select Yank',
            \ ],
            \ 'sink': function('yanktools#extras#fzf_menu'), 'down': '30%',
            \ 'options': '--prompt "Yanktools Menu >>>   "'})

