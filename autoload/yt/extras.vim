""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra functions and commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs
let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta
let s:A = g:yanktools.auto

function! yt#extras#show_yanks(type)
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

function! yt#extras#toggle_autoindent()
  if g:yanktools_autoindent
    let g:yanktools_autoindent = 0
    echo "Autoindent is now disabled."
  else
    let g:yanktools_autoindent = 1
    echo "Autoindent is now enabled."
  endif
endfunction

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

fun! yt#extras#set_offset(ix, first)
  if s:Y.is_empty() | return | endif
  if a:first
    call s:Y.set_at_offset(a:ix)
  else
    let ix = ( a:ix * -1 ) - 1
    let ix = range(s:Y.size())[ix]
    call s:Y.set_at_offset(ix)
  endif
  let [ current, size ] = [ s:Y.offset, s:Y.size() - 1 ]
  call s:F.msg("Yank stack set at index " . current . '/' . size, 1)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:yanks(stack)
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
endfunction

function! s:fzf_yank(yank)
  let index = str2nr(matchstr(a:yank, '\d\+')) - 1
  call s:Y.set_at_offset(index)
  if s:F.is_preview_open()
    call yt#preview#update()
  endif
endfunction

function! s:fzf_auto_yanks(yank)
  let index = str2nr(matchstr(a:yank, '\d\+')) - 1
  call s:A.transfer_yank(index)
endfunction

function! s:interactive(stack)
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
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#convert_yank_type()
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
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#auto_yanks()
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
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#select_yank()
  if s:Y.is_empty() | return | endif

  if exists('g:loaded_finder')
    return s:fzf_yank(Finder(s:yanks(s:Y), 'Select yank', {'matchadd':[['NonText', '\%<6c']]}))
  elseif exists('g:loaded_fzf')
    return fzf#run({'source': s:yanks(s:Y),
          \ 'sink': function('s:fzf_yank'), 'down': '30%',
          \ 'options': '--prompt "Select Yank >>>   "'})
  elseif s:F.is_preview_open()
    call s:F.msg('Press p or P to paste current item.', 1)
    return
  else
    let ix = s:interactive(s:Y)
    if ix != -1
    call s:Y.set_at_offset(str2nr(ix))
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#help()
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
        \  ['p',   "Yanks preview" ],
        \  ['0',   "Set yank index: first [ + count]" ],
        \  ['Y',   "Display yanks" ],
        \  ['Z',   "Display zeta yanks\n\n" ],
        \ ]
    echohl Type | echo key.m."\t" | echohl None | echon cmd
  endfor
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#toggle_persistance() abort
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
endfun

