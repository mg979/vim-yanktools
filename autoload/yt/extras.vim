""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra functions and commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs
let s:Y = g:yanktools.yank
let s:R = g:yanktools.redir

function! yt#extras#show_yanks(type)
  if !g:yanktools_manual
    s:Y.update_stack()
  endif
  let t = a:type == 'x' ? 'Redirected ' : a:type == 'z' ? 'Zeta ' : ''
  let i = 0
  let stack  = a:type == 'x' ? g:yanktools.redir.stack
        \ :    a:type == 'z' ? g:yanktools.zeta.stack : g:yanktools.yank.stack
  let offset = a:type == 'x' ? g:yanktools.redir.offset
        \ :    a:type == 'z' ? g:yanktools.zeta.offset : g:yanktools.yank.offset
  redraw!
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

function! yt#extras#clear_yanks(zeta, ...)
  if a:zeta
    call g:yanktools.zeta.clear()
    echo "Zeta stack has been cleared."
  else
    call g:yanktools.yank.clear()
    call g:yanktools.redir.clear()
    call g:yanktools.zeta.clear()
    echo "Yank stacks have been cleared."
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#toggle_autoformat()
  if g:yanktools_auto_format_all
    let g:yanktools_auto_format_all = 0
    echo "Autoindent is now disabled."
  else
    let g:yanktools_auto_format_all = 1
    echo "Autoindent is now enabled."
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#toggle_redirection()
  let g:yanktools_use_redirection = !g:yanktools_use_redirection
  if g:yanktools_use_redirection
    call s:F.msg("Redirection has been enabled, using two stacks", 1)
  else
    call s:F.msg("Redirection has been disabled, using a single stack")
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

function! yt#extras#yanks(redirected)
  let s:fzf_stack = a:redirected ? g:yanktools.redir : g:yanktools.yank
  let yanks = [] | let i = 0
  for yank in s:fzf_stack.stack
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
  call s:fzf_stack.set_at_offset(index)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#fzf_menu(choice)
  if a:choice == 'Toggle Freeze Offset'
    call yt#stack#freeze()
  elseif a:choice == 'Toggle Single Stack'
    call yt#extras#toggle_redirection()
  elseif a:choice == 'Clear Yank Stacks'
    call yt#extras#clear_yanks(0, 1)
  elseif a:choice == 'Clear Zeta Stack'
    call yt#extras#clear_yanks(1)
  elseif a:choice == 'Display Yanks'
    call yt#extras#show_yanks('y')
  elseif a:choice == 'Select Yank'
    FzfSelectYank
  elseif a:choice == 'Select Redirected Yank'
    FzfSelectYank!
  elseif a:choice == 'Convert Yank Type'
    call yt#extras#convert_yank_type()
  elseif a:choice == 'Toggle Auto Indent'
    call yt#extras#toggle_autoformat()
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#convert_yank_type()
  let r = v:register | let text = getreg(r) | let type = getregtype(r)

  if type[:0] ==# ""
    call setreg(r, text, "V")
    echo "Register ".r." converted to linewise yank."
    if r ==# s:F.default_reg()
      call remove(g:yanktools.yank.stack, 0)
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
    call remove(g:yanktools.yank.stack, 0)
    call s:Y.update_stack()
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#select_yank(redirected)
  let stack = a:redirected ? g:yanktools.redir : g:yanktools.yank
  if stack.empty() | return | endif

  if exists('g:loaded_fzf')
    return fzf#run({'source': yt#extras#yanks(a:redirected),
          \ 'sink': function('yt#extras#select_yank_fzf'), 'down': '30%',
          \ 'options': '--prompt "Select Yank >>>   "'})
  endif

  echohl WarningMsg | echo "--- Interactive Paste ---" | echohl None
  let i = 0
  for yank in stack.stack
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

    if index < 0 || index > len(stack)
      echo "\n" | echoerr "Yank index out of bounds"
    else
      call stack.set_at_offset(index)
    endif
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#extras#pclose()
  if s:v.pwline
    pclose!
    autocmd! yanktools_preview
    augroup! yanktools_preview
    let s:v.pwline = 0
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#extras#menu()
  if !exists('g:loaded_fzf')
    return s:F.msg('[yanktools] fzf is needed for this command')
  endif
  call fzf#run({'source': [
        \ 'Toggle Freeze Offset',
        \ 'Convert Yank Type',
        \ 'Toggle Auto Indent',
        \ 'Toggle Single Stack',
        \ 'Clear Yank Stacks',
        \ 'Clear Zeta Stack',
        \ 'Display Yanks',
        \ 'Select Yank',
        \ 'Select Redirected Yank',
        \ ],
        \ 'sink': function('yt#extras#fzf_menu'), 'down': '30%',
        \ 'options': '--prompt "Yanktools Menu >>>   "'})
endfun

