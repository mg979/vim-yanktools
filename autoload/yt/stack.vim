"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stack Update                                                             {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"----------------------------------------
"   Stack --->  Register
"----------------------------------------

fun! s:update_register(...) dict
  if !self.size()
    return
  endif
  let ix = a:0 ? a:1 : self.offset
  let item = self.get(ix)
  call s:F.set_register(s:F.default_reg(), item.text, item.type)
endfun

"----------------------------------------
"   Register --->  Stack
"----------------------------------------

fun! s:update_stack(...) dict
  " Conditions: to be added to the stack
  "   entry must not be too big
  "   must contain printable characters
  "   if entry is duplicate, put it upfront removing the previous one
  let r = s:F.get_register(a:0 ? a:1 : '"')
  let text = r[1]
  let type = r[2]

  if !s:too_big(text) && text =~ '[[:graph:]]'
    let item = {'text': text, 'type': type, 'ft': &ft}
    let ix = index(self.stack, item)
    call insert(self.stack, ix == - 1 ?
          \     item : remove(self.stack, ix))
  endif
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Other stack functions                                                    {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:clear_stack() dict
  let self.stack = []
endfun

fun! s:move_offset(forward, ...) dict
  " if the stack wasn't synched, use current offset first
  if self.frozen && !self.synched() | return | endif

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

fun! s:is_empty() dict
  " check size and print message if empty
  if !self.size()
    call s:F.msg('Stack is empty')
    return 1
  endif
endfun

fun! s:set_at_offset(n) dict
  " set offset with bounds check, then update register
  let size = self.size()
  if !size | return | endif

  let self.offset = a:n >= size ? size - 1 :
        \           a:n < 0 ? 0 : a:n
  call self.update_register()
endfun

fun! s:synched() dict
  " verify that stack and register are synched
  " that is, the register content must match the current stack offset
  if s:F.get_register()[1] != self.stack[self.offset].text
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

fun! s:get(...) dict
  return self.size() ? self.stack[a:0 ? a:1 : self.offset] : {}
endfun




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize stacks                                                        {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Yank  = {
      \ 'name': 'Yank', 'offset': 0, 'frozen': 1,
      \ 'clear': function('s:clear_stack'),
      \ 'update_stack': function('s:update_stack'),
      \ 'move_offset': function('s:move_offset'),
      \ 'size': function('s:size'),
      \ 'update_register': function('s:update_register'),
      \ 'set_at_offset': function('s:set_at_offset'),
      \ 'is_empty': function('s:is_empty'),
      \ 'get': function('s:get'),
      \ 'show_current': function('s:show_current'),
      \ 'synched': function('s:synched'),
      \}


let s:Zeta  = {'name': 'Zeta', 'offset': 0, 'frozen': 0,
      \ 'clear': function('s:clear_stack'),
      \ 'is_empty': function('s:is_empty'),
      \ 'size': function('s:size'),
      \ 'get': function('s:get'),
      \ 'update_register': function('s:update_register'),
      \}

fun! s:Zeta.update_stack() dict
  " duplicate yanks will be added to this stack nonetheless
  let r = s:F.get_register()
  call add(self.stack, {'text': r[1], 'type': r[2]})
  if s:v.restoring
    call s:F.restore_register()
  endif
endfun

fun! s:Zeta.pop_stack() abort
    " set register and remove index from stack
    call self.update_register()
    call remove(self.stack, self.offset)
endfun





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize variables                                                     {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:yanktools.yank = s:Yank
let g:yanktools.zeta = s:Zeta
let g:yanktools.current_stack = s:Yank

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yt#stack#init()
  """Initialize stacks.
  call s:Yank.clear()
  call s:Zeta.clear()
endfun

fun! yt#stack#freeze()
  if s:Yank.frozen
    let s:Yank.frozen = 0
    let s:Yank.offset = 0
    echo "Stack offset will be reset."
  else
    let s:Yank.frozen = 1
    echo "Stack offset won't be reset."
  endif
  call s:Yank.update_register()
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers                                                                  {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! s:too_big(text)
  " hitting text size limit
  return strchars(a:text) > get(g:, 'yanktools_max_text_size', 1000)
endfun

fun s:preview(...)
  augroup yanktools_preview
    au!
    au CursorMoved * if line('.') != s:v.pwline
          \        |   call yt#extras#pclose() | endif
  augroup END
endfun

