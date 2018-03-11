""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter * call yanktools#init_vars()
    autocmd TextChanged * if g:yanktools#redirected_reg | call yanktools#restore_after_redirect() | endif
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Yanks call yanktools#extras#show_yanks()
command! ClearYanks call yanktools#clear_yanks() | echo "Yanks cleared."

com! FzfPasteAfter call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Paste After >>>   "'})

com! FzfPasteBefore call fzf#run({'source': yanktools#extras#yanks(),
            \ 'sink': function('yanktools#extras#fzf_before'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Paste Before >>>   "'})

com! IPasteAfter call yanktools#extras#select_yank(0)
com! IPasteBefore call yanktools#extras#select_yank(1)
