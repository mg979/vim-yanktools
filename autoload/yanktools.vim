""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#init_vars()
    call yanktools#clear_yanks()
    call yanktools#zeta#init_vars()
    let s:last_paste_tick = -1
    let g:yanktools#redirected_reg = 0
    let g:yanktools_auto_format_this = 0
    let s:has_yanked = 0
    let s:yanks = 1
endfunction

function! yanktools#clear_yanks()
    let r = yanktools#get_reg()
    let g:yanktools_stack = [{'text': r[1], 'type': r[2]}]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#get_reg()

    " get default register
    let clipboard_flags = split(&clipboard, ',')
    if index(clipboard_flags, 'unnamedplus') >= 0
        let r = "+"
    elseif index(clipboard_flags, 'unnamed') >= 0
        let r = "*"
    else
        let r = "\""
    endif

    let s:r = [r, getreg(r), getregtype(r)]
    return s:r
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#update_stack()
    let stack = g:yanktools_stack
    let r = yanktools#get_reg() | let text = r[1] | let type = r[2]
    let ix = index(stack, {'text': text, 'type': type})

    if ix == -1
        call insert(stack, {'text': text, 'type': type})
    else
        call remove(stack, ix)
        call insert(stack, {'text': text, 'type': type})
    endif

    let s:yanks = len(stack)
    let s:has_yanked = 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:was_last_change_paste()
    return b:changedtick == s:last_paste_tick
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
    call yanktools#update_stack()
    let s:has_yanked = 1
    return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_with_key(key, ...)

    " prepare autoformat
    if a:0 | let g:yanktools_auto_format_this = 1 | endif

    " check if register needs to be restored
    if g:yanktools#redirected_reg | call yanktools#restore_after_redirect() | endif

    " set tick to the value it will be set to, after paste has happened
    let s:last_paste_tick = b:changedtick + 1

    " update stack before pasting, if needed
    if s:has_yanked | call yanktools#update_stack() | endif

    " reset stack offset, so that next swap will start from 0
    let s:offset = 0 | let s:last_paste_key = a:key

    return a:key
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirect
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
    call setreg(s:r[0], s:r[1], s:r[2])
    let g:yanktools#redirected_reg = 0
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#redirect_reg_with_key(key, register)
    let g:yanktools#redirected_reg = 1
    call yanktools#get_reg()
    let reg = a:register==s:r[0] ? g:yanktools_redirect_register : a:register
    return "\"" . reg . a:key
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward, key)

    if !s:was_last_change_paste()
        if s:has_yanked | call yanktools#update_stack() | endif
        " recursive mapping to trigger yanktools#paste_with_key()
        execute "normal ".a:key
        "let s:offset = 0 | let s:last_paste_key = a:key
        return
    endif

    let r = yanktools#get_reg()

    let s:offset += (a:forward ? 1 : -1)
    if s:offset >= s:yanks
        let s:offset = 0
    elseif s:offset < 0
        let s:offset = s:yanks-1
    endif

    let text = g:yanktools_stack[s:offset]['text']
    let type = g:yanktools_stack[s:offset]['type']
    call setreg(r[0], text, type)

    exec 'normal! u'.s:last_paste_key
    call setreg(r[0], r[1], r[2])
    let s:last_paste_tick = b:changedtick
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autoformat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#format()

    " reset this in any case
    let g:yanktools_auto_format_this = 0

    " Only auto-format if it's multiline or pasting into an empty line
    if (isMultiLine || isEmptyLine)
        if exists('s:ForceAutoFormat')
            let shouldAutoFormat = s:ForceAutoFormat
        else
            let shouldAutoFormat = a:format && g:EasyClipAutoFormat && get(b:, 'EasyClipAutoFormat', 1)
        endif
    endif

    if (shouldAutoFormat)
        let s:lastPasteWasAutoFormatted = 1
        keepjumps normal! `]
        let startPos = getpos('.')
        normal! ^
        let numFromStart = startPos[2] - col('.')

        " Suppress 'x lines indented' message
        silent exec "keepjumps normal! `[=`]"
        call setpos('.', startPos)
        normal! ^

        if numFromStart > 0
            " Preserve cursor position so that it is placed at the last pasted character
            exec 'normal! ' . numFromStart . 'l'
        endif

        normal! m]
    else
        let s:lastPasteWasAutoFormatted = 0
    endif
endfunction

