""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup plugin-yanktools
    autocmd!
    autocmd VimEnter * call yanktools#init_vars()
    autocmd TextChanged * if g:yanktools#redirected_reg | call yanktools#restore_after_redirect() | endif
augroup END

command! Yanks call yanktools#extras#show_yanks()
