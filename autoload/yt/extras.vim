""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra functions and commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs
let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta
let s:A = g:yanktools.auto

""
" Commands: Yanks, ZetaYanks
" Mappings: yuY, yuZ
" Show yanks in a stack, input for item deletion.
""
function! yt#extras#show_yanks(type)
    "{{{1
    let t = a:type == 'z' ? 'Zeta ' : ''
    let i = 0
    let stack  = a:type == 'z' ? s:Z.stack : s:Y.stack
    let offset = a:type == 'z' ? s:Z.offset : s:Y.offset
    if empty(stack)
        return s:F.msg("Stack is empty")
    endif
    echohl WarningMsg | echo "--- ".t."Yanks ---" | echohl None
    for yank in stack
        call s:show_yank(yank, i==str2nr(offset)? (string(i) . '<') : i)
        let i += 1
    endfor
    echo 'Press a valid index to delete it, or another key to continue'
    let c = getchar() - 48
    if c >= 0 && c < len(stack)
        call remove(stack, c)
    endif
    redraw
endfunction "}}}

""
" Commands: ClearYankStack, ClearZetaStack
" Mappings: yuxy, yuxz
" Clear items in a stack.
""
function! yt#extras#clear_yanks(zeta)
    "{{{1
    if a:zeta
        call s:Z.clear()
        echo "Zeta stack has been cleared."
    else
        call s:Y.clear()
        echo "Yank stack has been cleared."
    endif
endfunction "}}}

""
" Command: ToggleAutoIndent
" Mapping: yu=
""
function! yt#extras#toggle_autoindent()
    "{{{1
    if g:yanktools_autoindent
        let g:yanktools_autoindent = 0
        echo "Autoindent is now disabled."
    else
        let g:yanktools_autoindent = 1
        echo "Autoindent is now enabled."
    endif
endfunction "}}}

""
" Plug: YankSaveCurrent
" Mapping: yus
" Save register in the yank stack.
""
function! yt#extras#save_current(reg) abort
    "{{{1
    if empty(getreg(a:reg))
        return s:F.msg('Register '.a:reg.' is empty!')
    endif
    call s:Y.update_stack(a:reg)
    call s:F.msg('Register '''.a:reg.''' saved', 1)
endfunction "}}}

""
" Plug: SetYank
" Mapping: yu0
""
function! yt#extras#set_offset(ix)
    "{{{1
    if s:Y.is_empty() | return | endif
    call s:Y.set_at_offset(a:ix)
    let [ current, size ] = [ s:Y.offset, s:Y.size() - 1 ]
    call s:F.msg("Yank stack set at index " . current . '/' . size, 1)
endfunction "}}}

""
" Plug: ConvertYankType
" Mapping: yuc
" Convert a register type between linewise and blockwise.
""
function! yt#extras#convert_yank_type()
    "{{{1
    let r = v:register | let text = getreg(r) | let type = getregtype(r)

    if type[:0] ==# "\<C-V>"
        call setreg(r, text, "V")
        echo "Register ".r." converted to linewise yank."
        return
    endif

    let lines = split(text, '\n') | let maxl = 0
    for line in lines
        let l = [maxl, len(line)]
        let maxl = max(l)
    endfor

    call setreg(r, text, "\<C-V>".maxl)
    echo "Register ".r." converted to blockwise yank."
endfunction "}}}

""
" Command: AutoYanks
" Mapping: yua
" Select an item from the auto stack with a fuzzy finder or in the cmdline.
""
function! yt#extras#auto_yanks()
    "{{{1
    if s:A.is_empty() | return | endif

    if exists('g:loaded_finder')
        return s:fzf_auto_yanks(Finder(s:yanks(s:A), 'Auto yanks', {'matchadd':[['NonText', '\%<6c']]}))
    elseif exists('g:loaded_fzf')
        return fzf#run({'source': s:yanks(s:A),
                    \ 'sink': function('s:fzf_auto_yanks'), 'down': '30%',
                    \ 'options': '--prompt "Auto Yanks >>>   "'})
    else
        let ix = s:interactive(s:A)
        if ix != -1
            call s:A.transfer_yank(str2nr(ix))
        endif
    endif
endfunction "}}}

""
" Command: InteractivePaste
" Mapping: yui
" Select an item from the yank stack with a fuzzy finder or in the cmdline.
""
function! yt#extras#select_yank()
    "{{{1
    if s:Y.is_empty() | return | endif

    if exists('g:loaded_finder')
        return s:fzf_yank(Finder(s:yanks(s:Y), 'Select yank', {'matchadd':[['NonText', '\%<6c']]}))
    elseif exists('g:loaded_fzf')
        return fzf#run({'source': s:yanks(s:Y),
                    \ 'sink': function('s:fzf_yank'), 'down': '30%',
                    \ 'options': '--prompt "Select Yank >>>   "'})
    else
        let ix = s:interactive(s:Y)
        if ix != -1
            call s:Y.set_at_offset(str2nr(ix))
        endif
    endif
endfunction "}}}

""
" Plug: YanktoolsHelp
" Mapping: yu?
" Print the 'yu' mappings in the command line.
""
function! yt#extras#help()
    "{{{1
    let key = get(g:, 'yanktools_options_key', "yu")
    echohl Title | echo "Yanktools commands:\n\n"
    for [ m, cmd ] in [
                \  ['s',   "Save current [register]" ],
                \  ['a',   "Select an item from the automatic stack" ],
                \  ['c',   "Convert yank type" ],
                \  ['=',   "Toggle auto indent" ],
                \  ['xy',  "Clear yank stack" ],
                \  ['xz',  "Clear zeta stack" ],
                \  ['i',   "Interactive paste" ],
                \  ['0',   "Set yank index: first [ + count]" ],
                \  ['Y',   "Display yanks" ],
                \  ['Z',   "Display zeta yanks\n\n" ],
                \ ]
        echohl Type | echo key.m."\t" | echohl None | echon cmd
    endfor
endfunction "}}}

""
" Command: YanksPersistance
""
function! yt#extras#toggle_persistance() abort
    "{{{1
    let g:yanktools_persistance = !get(g:, 'yanktools_persistance', 0)
    if g:yanktools_persistance
        let g:YANKTOOLS_PERSIST = deepcopy(g:yanktools.yank.stack)
        augroup yanktools_persist
            au!
            au BufWrite,VimLeave * let g:YANKTOOLS_PERSIST = deepcopy(g:yanktools.yank.stack)
        augroup END
    else
        autocmd! yanktools_persist
        augroup! yanktools_persist
        unlet g:YANKTOOLS_PERSIST
    endif
endfunction "}}}




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:interactive(stack)
    "{{{1
    echohl WarningMsg | echo "--- Select Yank ---" | echohl None
    let i = 0
    for yank in a:stack.stack
        call s:show_yank(yank, i)
        let i += 1
    endfor

    let ix = input('Index: ')
    if empty(ix) || ix < 0 || ix >= len(a:stack.stack)
        echoerr "\nInvalid yank index given"
        return -1
    else
        return ix
    endif
endfunction "}}}

function! s:show_yank(yank, index)
    "{{{1
    let index = printf("%-4s", a:index)
    let line = substitute(a:yank.text, '\V\n', '^M', 'g')

    if len(line) > 80
        let line = line[:80] . '…'
    endif

    echohl Directory | echo  index
    echohl None      | echon line
    echohl None
endfunction "}}}

function! s:yanks(stack)
    "{{{1
    let yanks = [] | let i = 1
    for yank in a:stack.stack
        let line = substitute(yank.text, '\V\n', '^M', 'g')
        if len(line) > 80 | let line = line[:80] . '…' | endif
        if i < 10 | let spaces = "    " | else | let spaces = "   " | endif
        let line = "[".i."]".spaces.line
        call add(yanks, line)
        let i += 1
    endfor
    return yanks
endfunction "}}}

function! s:fzf_yank(yank)
    "{{{1
    let index = str2nr(matchstr(a:yank, '\d\+')) - 1
    if index >= 0
        call s:Y.set_at_offset(index)
    endif
endfunction "}}}

function! s:fzf_auto_yanks(yank)
    "{{{1
    let index = str2nr(matchstr(a:yank, '\d\+')) - 1
    if index >= 0
        call s:A.transfer_yank(index)
    endif
endfunction "}}}

" vim: ft=vim et sw=4 ts=4 sts=4 fdm=marker
