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
  let r = s:F.get_register(a:0 ? a:1 : '"')
  let text = r[1]
  let type = r[2]

  " text must contain printable characters
  if text =~ (self is s:Auto ? '[[:graph:]]' : '[[:print:]]')
    let item = {'text': text, 'type': type, 'ft': &ft}
    " if entry is duplicate, put it upfront removing the previous one
    let ix = index(self.stack, item)
    if ix >= 0
      call remove(self.stack, ix)
    endif
    call insert(self.stack, item)
  endif
  " if auto-stack size exceeds limit, remove entries from the tail
  if self is s:Auto
    while self.size() > get(g:, 'yanktools_auto_stack_size', 10)
      unlet self.stack[-1]
    endwhile
  endif
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Other stack functions                                                    {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:clear_stack() dict
  let self.stack = []
endfun

fun! s:move_offset(count) dict
  " take overflow in account if going out of bounds
  let start = self.offset
  let max = self.size()
  let n = ( abs(a:count) % max ) * ( a:count > 0 ? 1 : -1 )
  let self.offset += n

  if self.offset >= max
    let self.offset = start + n - max
    return 1

  elseif self.offset < 0
    let self.offset = start + n + max
    return 2

  endif
  call self.update_register()
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

fun! s:get(...) dict
  return self.size() ? self.stack[a:0 ? a:1 : self.offset] : {}
endfun




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize stacks                                                        {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:Yank  = {
      \ 'name': 'Yank', 'offset': 0,
      \ 'clear': function('s:clear_stack'),
      \ 'update_stack': function('s:update_stack'),
      \ 'move_offset': function('s:move_offset'),
      \ 'size': function('s:size'),
      \ 'update_register': function('s:update_register'),
      \ 'set_at_offset': function('s:set_at_offset'),
      \ 'is_empty': function('s:is_empty'),
      \ 'get': function('s:get'),
      \ 'synched': function('s:synched'),
      \}


let s:Auto  = {
      \ 'name': 'Auto', 'offset': 0,
      \ 'size': function('s:size'),
      \ 'is_empty': function('s:is_empty'),
      \ 'clear': function('s:clear_stack'),
      \ 'get': function('s:get'),
      \ 'update_stack': function('s:update_stack'),
      \ 'update_register': function('s:update_register'),
      \}


let s:Zeta  = {'name': 'Zeta', 'offset': 0,
      \ 'clear': function('s:clear_stack'),
      \ 'is_empty': function('s:is_empty'),
      \ 'size': function('s:size'),
      \ 'get': function('s:get'),
      \ 'update_register': function('s:update_register'),
      \}

fun! s:Zeta.update_stack() dict
  " duplicate yanks will be added to this stack nonetheless
  let r = s:F.get_register()
  call add(self.stack, {'text': r[1], 'type': r[2], 'ft': &ft})
  if s:v.restoring
    call s:F.restore_register()
  endif
endfun

fun! s:Zeta.pop_stack() abort
    " set register and remove index from stack
    call self.update_register()
    call remove(self.stack, self.offset)
endfun

fun! s:Auto.transfer_yank(ix) abort
  call self.update_register(a:ix)
  call s:Yank.update_stack()
  call remove(self.stack, a:ix)
endfun





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize variables                                                     {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:yanktools.yank = s:Yank
let g:yanktools.zeta = s:Zeta
let g:yanktools.auto = s:Auto

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yt#stack#init()
  """Initialize stacks.
  call s:Yank.clear()
  call s:Zeta.clear()
  call s:Auto.clear()
endfun

