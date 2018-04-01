""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#replop#init()
    let s:replace_count = 0
endfunction

function! yanktools#replop#replace_get_reg()
    " prevent black hole register bug
    let s:repl_reg = v:register == "_" ? yanktools#default_reg() : v:register
endfunction

function! yanktools#replop#paste_replacement()
    let g:yanktools_is_replacing = 0
    execute "normal! \"".s:repl_reg."P`]"
    let &virtualedit = s:oldvmode
endfunction

function! yanktools#replop#replace(type)
    let reg = g:yanktools_replace_operator_bh ? "_" : g:yanktools_redirect_register
    let g:yanktools_has_changed = 1
    let g:yanktools_is_replacing = 1
    let s:oldvmode = &virtualedit | set virtualedit=onemore
    if a:type == 'line'
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

function! yanktools#replop#replace_line(r, c, multi, format)

    " only run in first iteration
    if !s:replace_count
        let reg = g:yanktools_replace_operator_bh ? "_" : g:yanktools_redirect_register
        let s:repl_reg = a:r
        let s:oldvmode = &virtualedit | set virtualedit=onemore

        " last line needs 'paste after'
        let paste_type = (line(".") == line("$")) ? "p" : "P"

        " store count in the first iteration (it will be 0 afterwards)
        if a:c | let s:replace_count = a:c | endif
    endif

    " no count, single line replacement
    if !a:c && !s:replace_count
        call s:d_before_replace(a:r, reg)
        let g:yanktools_auto_format_this = a:format
        execute "normal \"".a:r.paste_type
        call s:reset_vars_after_replace()
        return
    endif

    if s:replace_count

        " delete lines to replace first
        " using v:count, so that it will run in 1st iteration only
        for i in range(a:c)
            call s:d_before_replace(a:r, reg)
        endfor

        if a:multi          " multiple replacements
            for i in range(a:c)
                let g:yanktools_auto_format_this = a:format
                execute "normal \"".a:r.paste_type
            endfor

        elseif a:c      " single replacement (à la ReplaceWithRegister)
            let g:yanktools_auto_format_this = a:format
            execute "normal \"".a:r.paste_type
        endif

        " will reset vars when this reaches 0
        let s:replace_count -= 1
        if !s:replace_count | call s:reset_vars_after_replace() | endif
    endif
endfunction



