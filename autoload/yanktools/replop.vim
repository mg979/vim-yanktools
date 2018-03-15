""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#replop#init()
    let s:replace_count = 0
endfunction

function! yanktools#replop#replace_get_reg()
    let s:repl_reg = v:register
endfunction

function! yanktools#replop#paste_replacement()
    let g:yanktools_is_replacing = 0
    execute "normal! \"".s:repl_reg."P`]"
    let &virtualedit = s:oldvmode
endfunction

function! yanktools#replop#replace(type, ...)
    let reg = g:yanktools_replace_operator_bh ? "_" : g:yanktools_redirect_register
    let g:yanktools_has_pasted = 1
    let g:yanktools_is_replacing = 1
    let s:oldvmode = &virtualedit | set virtualedit=onemore
    if a:0
        exe "keepjump normal! `[V`]"
        execute "normal! \"".reg."d"
    else
        exe "keepjump normal! `[v`]"
        execute "normal! \"".reg."d"
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:d_before_replace(r1, r2)
    if getreg(a:r1) !~ '\n'
        execute "normal 0\"".a:r2."d$"
    else
        execute "normal \"".a:r2."dd"
    endif
endfunction

function! s:reset_vars_after_replace()
    let s:replace_count = 0
    let &virtualedit = s:oldvmode
    let g:yanktools_plug = ["ReplaceOperatorLine", 1, v:register]
    call yanktools#set_repeat()
endfunction

function! yanktools#replop#replace_line(r, c, ...)
    let reg = g:yanktools_replace_operator_bh ? "_" : g:yanktools_redirect_register
    let s:repl_reg = a:r
    let s:oldvmode = &virtualedit | set virtualedit=onemore

    " last line needs 'paste after'
    let paste_type = (line(".") == line("$")) ? "p" : "P"

    if a:c | let s:replace_count = a:c | endif

    if !a:c && !s:replace_count
        call s:d_before_replace(a:r, reg)
        execute "normal \"".a:r.paste_type
        call s:reset_vars_after_replace()
        return
    endif

    if s:replace_count

        " delete lines to replace first
        for i in range(a:c)
            call s:d_before_replace(a:r, reg)
        endfor

        if a:0          " multiple replacements

            for i in range(a:c)
                execute "normal \"".a:r.paste_type
            endfor

        elseif a:c      " single replacement (à la ReplaceWithRegister)

            execute "normal \"".a:r.paste_type
        endif

        let s:replace_count -= 1

    else
        call s:reset_vars_after_replace()
    endif

endfunction



