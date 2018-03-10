let g:yanktools_stack = [@"]
let s:last_paste_tick = 0
let s:yanktools_types = ['v']

"map <unique> y <Plug>YankToolsYank
"nnoremap <unique> <script> <Plug>YankToolsYank :call <SID>Yank()<cr>
"nmap yy <Plug>YankLine
nmap y <Plug>Yank
nmap yy <Plug>YankLine
nmap <script> <Plug>YankLine :call YankLine()<cr>
nmap <script> <expr> <Plug>Yank Yank()
vmap y <Plug>Yank
vmap <nowait> <script> <Plug>Yank :<C-U>call YankTools(visualmode(), 1)<CR>
nmap q :call SwapPaste(1)<cr>
nmap Q :call SwapPaste(0)<cr>

fun! Yank()
    "let s:yank_count = v:count
    "let s:active_register = v:register
    "let s:pre_yank_pos = getpos('.')
    set opfunc=YankTools
    return 'g@'
endfun


function! s:YankToolsStack(type)
    let stack = g:yanktools_stack
    let types = s:yanktools_types
    let reg = @"
    let ix = index(stack, reg)

    if empty(stack)
        call add(stack, reg) | call add(types, a:type)
    elseif ix == -1
        call insert(stack, reg) | call insert(types, a:type)
    else
        call remove(stack, ix) | call remove(types, ix)
        call insert(stack, reg) | call insert(types, a:type)
    endif
endfunction


function! YankTools(type, ...)
    echom a:type
    if a:0  " Invoked from Visual mode, use gv command.
        silent exe "normal! gvy"
    elseif a:type == 'line'
        silent exe "normal! '[V']y"
    else
        silent exe "normal! `[v`]y"
    endif
    call s:YankToolsStack(a:type)
endfunction

function! YankLine()
    let pos = getpos('.')
    exec 'normal! '. v:count1 . '"'. v:register .'yy'
    call setpos('.', pos)
    call s:YankToolsStack('V')
endfunction

function! WasLastChangePaste()
    return b:changedtick == s:last_paste_tick
endfunction

function! Default_reg()
    let clipboard_flags = split(&clipboard, ',')
    if index(clipboard_flags, 'unnamedplus') >= 0
        return "+"
    elseif index(clipboard_flags, 'unnamed') >= 0
        return "*"
    else
        return "\""
    endif
endfunction

function! SwapPaste(forward)
    if !WasLastChangePaste()
        normal P
        let s:offset = 0
        let s:yanks = len(g:yanktools_stack)
        let s:last_paste_tick = b:changedtick
        return
    endif

    let rg = Default_reg()
    let oldregtype = getregtype(rg)
    let oldreg = getreg(rg)

    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= s:yanks
        let s:offset = 0
    elseif s:offset < 0
        let s:offset = s:yanks-1
    endif

    "let text = g:yanktools_stack()[s:offset]['text']
    let text = g:yanktools_stack[s:offset]
    let type = s:yanktools_types[s:offset]
    call setreg(rg, text, type)

    exec 'normal uP'
    call setreg(rg, oldreg, oldregtype)
    let s:last_paste_tick = b:changedtick
endfunction
