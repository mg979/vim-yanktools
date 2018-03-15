""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter * call yanktools#init_vars()
    autocmd TextChanged * silent! call yanktools#on_text_change()
    autocmd InsertEnter * silent! call yanktools#on_text_change()
    autocmd CursorMoved * silent! call yanktools#on_cursor_moved()
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks call yanktools#extras#show_yanks()
command! ClearYanks call yanktools#clear_yanks() | echo "Yanks cleared."
command! ToggleAutoIndent let g:yanktools_auto_format_all = !g:yanktools_auto_format_all

com! FzfPasteAfter call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Paste After >>>   "'})

com! FzfPasteBefore call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf_before'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Paste Before >>>   "'})

com! IPasteAfter call yanktools#extras#select_yank(0)
com! IPasteBefore call yanktools#extras#select_yank(1)
