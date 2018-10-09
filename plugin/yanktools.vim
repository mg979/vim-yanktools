""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter    * call yanktools#init_vars()
    autocmd TextChanged * silent! call yanktools#on_text_change()
    autocmd InsertEnter * silent! call yanktools#on_text_change()

    if has('nvim') || has('patch1394')
        autocmd TextYankPost * silent! call yanktools#check_yanks()
    else
        autocmd CursorMoved  * silent! call yanktools#check_yanks()
        autocmd CursorHold   * silent! call yanktools#check_yanks()
    endif
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks call yanktools#extras#show_yanks()
command! ClearYankStacks call yanktools#extras#clear_yanks(0, 1)
command! ClearZetaStack  call yanktools#extras#clear_yanks(1)
command! ToggleAutoIndent call yanktools#extras#toggle_autoformat()

com! FzfSelectYank call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#select_yank_fzf'), 'down': '30%',
            \ 'options': '--prompt "Select Yank >>>   "'})

com! ISelectYank call yanktools#extras#select_yank()

com! Yanktools call fzf#run({'source': [
            \ 'Toggle Freeze Offset',
            \ 'Convert Yank Type',
            \ 'Toggle Auto Indent',
            \ 'Clear Yank Stacks',
            \ 'Clear Zeta Stack',
            \ 'Display Yanks',
            \ 'Select Yank',
            \ ],
            \ 'sink': function('yanktools#extras#fzf_menu'), 'down': '30%',
            \ 'options': '--prompt "Yanktools Menu >>>   "'})

