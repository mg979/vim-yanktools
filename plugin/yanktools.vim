""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter * call yanktools#init_vars()
    autocmd TextChanged * silent! call yanktools#on_text_change()
    autocmd InsertEnter * silent! call yanktools#on_text_change()
    autocmd CursorMoved * silent! call yanktools#check_yanks()
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks call yanktools#extras#show_yanks()
command! ClearYanks call yanktools#extras#clear_yanks() | echo "Yanks cleared."
command! ToggleAutoIndent call yanktools#extras#toggle_autoformat()

com! FzfPasteAfter call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf'), 'down': '30%',
            \ 'options': '--prompt "Paste After >>>   "'})

com! FzfPasteBefore call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf_before'), 'down': '30%',
            \ 'options': '--prompt "Paste Before >>>   "'})

com! FzfSelectYank call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf_select_only'), 'down': '30%',
            \ 'options': '--prompt "Select Yank >>>   "'})

com! IPasteAfter call yanktools#extras#select_yank(0)
com! IPasteBefore call yanktools#extras#select_yank(1)
com! IPasteSelect call yanktools#extras#select_yank(-1)

com! Yanktools call fzf#run({'source': [
            \ 'Toggle Freeze Offset',
            \ 'Convert Yank Type',
            \ 'Toggle Auto Indent',
            \ 'Clear Yanks',
            \ 'Display Yanks',
            \ 'Select Yank',
            \ ],
            \ 'sink': function('yanktools#extras#fzf_menu'), 'down': '30%',
            \ 'options': '--prompt "Yanktools Menu >>>   "'})

