""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra functions and commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#show_yanks()
    call yanktools#update_stack()
    echohl WarningMsg | echo "--- Yanks ---" | echohl None
    let i = 0
    for yank in g:yanktools_stack
        call yanktools#extras#show_yank(yank, i)
        let i += 1
    endfor
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#show_yank(yank, index)
    let index = printf("%-4d", a:index)
    let line = substitute(a:yank.text, '\V\n', '^M', 'g')

    if len(line) > 80
        let line = line[:80] . '…'
    endif

    echohl Directory | echo  index
    echohl None      | echon line
    echohl None
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#yanks()
    call yanktools#update_stack()
    let yanks = [] | let i = 0
    for yank in g:yanktools_stack
        let line = substitute(yank.text, '\V\n', '^M', 'g')
        if len(line) > 80 | let line = line[:80] . '…' | endif
        if i < 10 | let spaces = "    " | else | let spaces = "   " | endif
        let line = "[".i."]".spaces.line
        call add(yanks, line)
        let i += 1
    endfor
    return yanks
endfunction

function! yanktools#extras#select_yank_fzf(yank, before)
    let index = a:yank[:4]
    let index = substitute(index, "[", "", "")
    let index = substitute(index, "]", "", "")
    let index = substitute(index, " ", "", "g")
    let r = yanktools#get_reg()
    call setreg(r[0], g:yanktools_stack[index]['text'], r[2])
    if a:before | execute "normal P" | else | execute "normal p" | endif
endfunction

function! yanktools#extras#fzf(yank)
    call yanktools#extras#select_yank_fzf(a:yank, 0)
endfunction

function! yanktools#extras#fzf_before(yank)
    call yanktools#extras#select_yank_fzf(a:yank, 1)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#select_yank(before)
    call yanktools#update_stack()
    echohl WarningMsg | echo "--- Interactive Paste ---" | echohl None
    let i = 0
    for yank in g:yanktools_stack
        call yanktools#extras#show_yank(yank, i)
        let i += 1
    endfor

    let indexStr = input('Index: ')
    if indexStr =~ '\v^\s*$' | return | endif

    if indexStr !~ '\v^\s*\d+\s*'
        echo "\n"
        echoerr "Invalid yank index given"
    else
        let index = str2nr(indexStr)

        if index < 0 || index > len(g:yanktools_stack)
            echo "\n" | echoerr "Yank index out of bounds"
        else
            let r = yanktools#get_reg()
            call setreg(r[0], g:yanktools_stack[index]['text'], r[2])
            if a:before | execute "normal P" | else | execute "normal p" | endif
        endif
    endif
endfunction

