
function! yanktools#extras#show_yanks()
    echohl WarningMsg | echo "--- Yanks ---" | echohl None
    let i = 0
    for yank in g:yanktools_stack
        call yanktools#extras#show_yank(yank, i)
        let i += 1
    endfor
endfunction

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

