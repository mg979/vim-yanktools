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

let s:to_map = [
    \ ['y',  '<Plug>(Yank)',    'n'],
    \ ['Y',  '<Plug>(Yank)$',   'n'],
    \ ['y',  '<Plug>(Yank)',    'x'],
    \ ['d',  '<Plug>(Cut)',     'n'],
    \ ['D',  '<Plug>(Cut)$',    'n'],
    \ ['dd', '<Plug>(CutLine)', 'n'],
    \ ['d',  '<Plug>(Cut)',     'x'],
    \ ]

" if recording is turned on, map plugs, but don't overwrite existing mappings
" in the case of Y = y$, remap it anyway, and restore the old mappings
" afterwards

fun! yt#extras#toggle_recording(msg)
  let s:v.is_recording = !s:v.is_recording
  if s:v.is_recording
    let [ s:mapped, s:map_failed ] = [ [], [] ]
    for k in s:to_map
      if empty(maparg(k[0], k[2]))
        exe k[2]."map" k[0] k[1]
        call add(s:mapped, k)
      elseif k[0] ==# 'Y' && maparg(k[0], k[2]) ==# 'y$'
        " make an exception for nmap Y y$
        let s:had_Y = maparg(k[0], k[2], 0, 1).noremap + 1
        exe k[2]."map" k[0] k[1]
      else
        call add(s:map_failed, k)
      endif
    endfor
    for k in s:map_failed
      echom "[yanktools] failed because of existing mapping:" k[2]."map" k[0] k[1]
    endfor
    if a:msg | call s:F.msg("Recording has been enabled", 1) | endif
  else
    for k in s:mapped
      exe "silent!" k[2]."unmap" k[0]
    endfor
    if exists('s:had_Y')
      if s:had_Y == 1 | nmap Y y$
      else            | nnoremap Y y$
      endif
      unlet s:had_Y
    endif
    if a:msg | call s:F.msg("Recording has been disabled") | endif
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

function! yt#extras#yanks()
  let yanks = [] | let i = 1
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
  let index = str2nr(matchstr(a:yank, '\d\+')) - 1
  call s:Y.set_at_offset(index)
  if s:F.is_preview_open()
    call yt#preview#update()
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
        \  ['c',   "Convert yank type" ],
        \  ['r',   "Toggle recording mode" ],
        \  ['ai',  "Toggle auto indent" ],
        \  ['xy',  "Clear yank stack" ],
        \  ['xz',  "Clear zeta stack" ],
        \  ['i',   "Interactive paste" ],
        \  ['p',   "Yanks preview" ],
        \  ['0',   "Set yank index: first [ + count]" ],
        \  ['l',   "Set yank index: last [ - count]" ],
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

