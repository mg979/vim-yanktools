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

function! yanktools#extras#clear_yanks(...)
    let r = yanktools#get_reg()
    let g:yanktools_stack = [{'text': r[1], 'type': r[2]}]
    if a:0 | echo "All yanks in the stack, except the last, have been cleared." | endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#toggle_autoformat()
    if g:yanktools_auto_format_all
        let g:yanktools_auto_format_all = 0
        echo "Autoindent disabled."
    else
        let g:yanktools_auto_format_all = 1
        echo "Autoindent enabled."
    endif
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

function! yanktools#extras#fzf_menu(choice)
    if a:choice == 'Toggle Freeze Offset'
        call yanktools#freeze_offset()
    elseif a:choice == 'Clear Yanks'
        call yanktools#extras#clear_yanks(1)
    elseif a:choice == 'Show Yanks'
        call yanktools#extras#show_yanks()
    elseif a:choice == 'Convert Yank Type'
        call yanktools#extras#change_yank_type()
    elseif a:choice == 'Toggle Auto Indent'
        call yanktools#extras#toggle_autoformat()
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#extras#change_yank_type()
    let r = v:register | let text = getreg(r) | let type = getregtype(r)
    if type ==# 'v' | echo "Not a multiline yank." | return | endif

    if type[:0] ==# ""
        call setreg(r, text, "V")
        echo "Register ".r." converted to linewise yank."
        if r ==# yanktools#default_reg()
            call remove(g:yanktools_stack, 0)
            call yanktools#update_stack()
        endif
        return
    endif

    let lines = split(text, '\n') | let maxl = 0
    for line in lines
        let l = [maxl, len(line)]
        let maxl = max(l)
    endfor

    call setreg(r, text, "".maxl)
    echo "Register ".r." converted to blockwise yank."
    if r ==# yanktools#default_reg()
        call remove(g:yanktools_stack, 0)
        call yanktools#update_stack()
    endif
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

