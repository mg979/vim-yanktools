"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Common functions                                     {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:clear_stack() dict
  let self.offset = -1
  let self.stack = []
endfun

fun! s:update_stack() dict
  " if entry is duplicate, put it upfront removing the previous one
  let r = s:F.get_register()
  let text = r[1]
  let type = r[2]
  if !s:too_big(text)
    let item = {'text': text, 'type': type, 'ft': &ft}
    let ix = index(self.stack, item)
    call insert(self.stack, ix == - 1 ?
          \     item : remove(self.stack, ix))
    if self.offset < 0
      let self.offset = 0
    endif
  endif
  if self.name == 'Redirected'
    call s:F.restore_register()
  endif
endfun

fun! s:move_offset(forward, ...) dict
  if !self.synched()
    return
  endif
  let self.offset += (a:forward ? 1 : -1)
  if self.offset >= self.size()
    let self.offset = 0
    return 1
  elseif self.offset < 0
    let self.offset = self.size()-1
    return 2
  endif
endfun

fun! s:size() dict
  return len(self.stack)
endfun

fun! s:empty() dict
  if !self.size()
    let self.offset = -1
    call s:F.msg('Stack is empty')
    return 1
  endif
endfun

fun! s:update_register() dict
  if !self.size()
    let self.offset = -1
    return
  endif
  let item = self.get()
  call setreg(s:F.default_reg(), item.text, item.type)
endfun

fun! s:reset_offset() dict
  if !self.frozen | let self.offset = 0 | endif
endfun

fun! s:set_at_offset(n) dict
  let self.offset = a:n
  call self.update_register()
endfun

fun! s:synched() dict
  " when accessing the stack, ensure current register belongs to it
  if getreg('"') != self.stack[self.offset].text
    call self.update_register()
    return 0
  endif
  return 1
endfun

fun! s:show_current() dict
  let item = self.get()
  let text = split(item.text, '\n')
  let ft = &ft
  let nl = len(text) < 15 ? len(text) : 15
  pclose!
  exe "botright" nl."new"
  setlocal bt=nofile bh=wipe noswf nobl
  setlocal previewwindow
  let pos = (self.offset+1).'/'.self.size()
  let &l:statusline = '%#Visual# Pos. '.pos.'  %#Tabline# ft '.item.ft
  put =text
  1d _
  1
  exe 'setf' item.ft
  wincmd p
  let s:v.pwline = line('.')
  call s:preview()
endfun

fun! s:get() dict
  return self.size() ? self.stack[self.offset] : {}
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize stacks                                    {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Yank  = {
      \ 'name': 'Yank', 'offset': -1, 'frozen': 1,
      \ 'clear': function('s:clear_stack'),
      \ 'update_stack': function('s:update_stack'),
      \ 'move_offset': function('s:move_offset'),
      \ 'size': function('s:size'),
      \ 'update_register': function('s:update_register'),
      \ 'reset_offset': function('s:reset_offset'),
      \ 'set_at_offset': function('s:set_at_offset'),
      \ 'empty': function('s:empty'),
      \ 'get': function('s:get'),
      \ 'show_current': function('s:show_current'),
      \ 'synched': function('s:synched'),
      \}

let s:Redir = {
      \ 'name': 'Redirected', 'offset': -1, 'frozen': 1,
      \ 'clear': function('s:clear_stack'),
      \ 'update_stack': function('s:update_stack'),
      \ 'move_offset': function('s:move_offset'),
      \ 'size': function('s:size'),
      \ 'update_register': function('s:update_register'),
      \ 'reset_offset': function('s:reset_offset'),
      \ 'set_at_offset': function('s:set_at_offset'),
      \ 'empty': function('s:empty'),
      \ 'get': function('s:get'),
      \ 'show_current': function('s:show_current'),
      \ 'synched': function('s:synched'),
      \}

let s:Zeta  = {'name': 'Zeta', 'offset': 0, 'frozen': 0}

let g:yanktools.yank = s:Yank
let g:yanktools.redir = s:Redir
let g:yanktools.zeta = s:Zeta
let g:yanktools.current_stack = s:Yank
let s:current = g:yanktools.current_stack
let s:frozen = 1

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yanktools#stack#init()
  """Initialize stacks.
  call g:yanktools.yank.clear()
  call g:yanktools.redir.clear()
  call g:yanktools.zeta.clear()
endfun

fun! yanktools#stack#freeze()
  if s:frozen
    let g:yanktools.yank.frozen = 0
    let g:yanktools.redir.frozen = 0
    let g:yanktools.yank.offset = 0
    let g:yanktools.redir.offset = 0
    echo "Stacks offset will be reset normally."
  else
    let g:yanktools.yank.frozen = 1
    let g:yanktools.redir.frozen = 1
    echo "Stacks offset won't be reset."
  endif
  call g:yanktools.yank.update_register()
  let s:frozen = !s:frozen
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Zeta stack                                           {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Zeta.clear() dict
  let self.stack = []
endfun

fun! s:Zeta.update_stack() dict
  " duplicate yanks will be added to this stack nonetheless
  let r = s:F.get_register()
  call add(self.stack, {'text': r[1], 'type': r[2]})
  if s:v.redirecting
    call s:F.restore_register()
  endif
endfun


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers                                              {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! s:too_big(text)
  " hitting text size limit
  return strchars(a:text) > get(g:, 'yanktools_max_text_size', 1000)
endfun

fun s:preview(...)
  augroup yanktools_preview
    au!
    au CursorMoved * if line('.') != s:v.pwline
          \        |   call yanktools#stack#pclose() | endif
  augroup END
endfun

fun! yanktools#stack#pclose()
  if s:v.pwline
    pclose!
    autocmd! yanktools_preview
    augroup! yanktools_preview
    let s:v.pwline = 0
  endif
endfun
