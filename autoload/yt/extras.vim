""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra functions and commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs
let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta

function! yt#extras#show_yanks(type)
  let t = a:type == 'x' ? 'Redirected ' : a:type == 'z' ? 'Zeta ' : ''
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
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#clear_yanks(zeta)
  if a:zeta
    call s:Z.clear()
    echo "Zeta stack has been cleared."
  else
    call s:Y.clear()
    echo "Yank stack has been cleared."
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#toggle_autoformat()
  if g:yanktools_autoindent
    let g:yanktools_autoindent = 0
    echo "Autoindent is now disabled."
  else
    let g:yanktools_autoindent = 1
    echo "Autoindent is now enabled."
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#toggle_recording(...)
  let s:v.is_recording = !s:v.is_recording
  if s:v.is_recording
    nmap y  <Plug>(Yank)
    nmap Y  <Plug>(Yank)$
    xmap y  <Plug>(Yank)
    nmap d  <Plug>(Cut)
    nmap D  <Plug>(Cut)$
    nmap dd <Plug>(CutLine)
    xmap d  <Plug>(CutVisual)
    if !a:0 | call s:F.msg("Recording has been enabled", 1) | endif
  else
    silent! nunmap y
    silent! nunmap Y
    silent! xunmap y
    silent! nunmap d
    silent! nunmap D
    silent! nunmap dd
    silent! xunmap d
    if !a:0 | call s:F.msg("Recording has been disabled") | endif
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:show_yank(yank, index)
  let index = printf("%-4s", a:index)
  let line = substitute(a:yank.text, '\V\n', '^M', 'g')

  if len(line) > 80
    let line = line[:80] . '…'
  endif

  echohl Directory | echo  index
  echohl None      | echon line
  echohl None
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#set_offset(ix)
  if s:Y.is_empty() | return | endif
  call s:Y.set_at_offset(a:ix)
  call s:F.msg("Yank stack set at index " . s:Y.offset, 1)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#yanks()
  let yanks = [] | let i = 0
  for yank in s:Y.stack
    let line = substitute(yank.text, '\V\n', '^M', 'g')
    if len(line) > 80 | let line = line[:80] . '…' | endif
    if i < 10 | let spaces = "    " | else | let spaces = "   " | endif
    let line = "[".i."]".spaces.line
    call add(yanks, line)
    let i += 1
  endfor
  return yanks
endfunction

function! yt#extras#select_yank_fzf(yank)
  let index = a:yank[:4]
  let index = substitute(index, "[", "", "")
  let index = substitute(index, "]", "", "")
  let index = substitute(index, " ", "", "g")
  call s:Y.set_at_offset(index)
  if s:F.is_preview_open()
    call yt#preview#update()
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#convert_yank_type()
  let r = v:register | let text = getreg(r) | let type = getregtype(r)

  if type[:0] ==# ""
    call setreg(r, text, "V")
    echo "Register ".r." converted to linewise yank."
    if r ==# s:F.default_reg()
      call remove(s:Y.stack, 0)
      call s:Y.update_stack()
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
  if r ==# s:F.default_reg()
    call remove(s:Y.stack, 0)
    call s:Y.update_stack()
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#select_yank()
  if s:Y.is_empty() | return | endif

  if exists('g:loaded_fzf')
    return fzf#run({'source': yt#extras#yanks(),
          \ 'sink': function('yt#extras#select_yank_fzf'), 'down': '30%',
          \ 'options': '--prompt "Select Yank >>>   "'})
  elseif s:F.is_preview_open()
    call s:F.msg('Press p or P to paste current item.', 1)
    return
  endif

  echohl WarningMsg | echo "--- Interactive Paste ---" | echohl None
  let i = 0
  for yank in s:Y.stack
    call s:show_yank(yank, i)
    let i += 1
  endfor

  let indexStr = input('Index: ')
  if indexStr =~ '\v^\s*$' | return | endif

  if indexStr !~ '\v^\s*\d+\s*'
    echo "\n"
    echoerr "Invalid yank index given"
  else
    let index = str2nr(indexStr)

    if index < 0 || index >= len(s:Y.stack)
      echo "\n" | echoerr "Yank index out of bounds"
    else
      call s:Y.set_at_offset(index)
    endif
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#help()
  let key = get(g:, 'yanktools_options_key', "yu")
  echohl Title | echo "Yanktools commands:\n\n"
  for [ m, cmd ] in [
        \  ['s',   "Save current [register]" ],
        \  ['c',   "Convert Yank Type" ],
        \  ['r',   "Toggle Record Mode" ],
        \  ['ai',  "Toggle Auto Indent" ],
        \  ['xs',  "Clear Yank Stacks" ],
        \  ['xz',  "Clear Zeta Stack" ],
        \  ['i',   "Interactive Paste" ],
        \  ['p',   "Yanks Preview" ],
        \  ['Y',   "Display Yanks" ],
        \  ['Z',   "Display Zeta Yanks\n\n" ],
        \ ]
    echohl Type | echo key.m."\t" | echohl None | echon cmd
  endfor
endfun

