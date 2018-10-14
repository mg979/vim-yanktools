let s:Yank  = {'name': 'Yank', 'offset': 0, 'frozen': 0}
let s:Redir = {'name': 'Redirected', 'offset': 0, 'frozen': 0}
let s:Zeta  = {'name': 'Zeta', 'offset': 0, 'frozen': 0}

let g:yanktools.yank = s:Yank
let g:yanktools.redir = s:Redir
let g:yanktools.zeta = s:Zeta
let g:yanktools.current_stack = s:Yank
let s:current = g:yanktools.current_stack

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yanktools#stack#init()
  """Initialize stacks.
  call g:yanktools.yank.clear()
  call g:yanktools.redir.clear()
  call g:yanktools.zeta.clear()
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Yank.clear() dict
  let r = s:F.get_register()
  let self.stack = [{'text': r[1], 'type': r[2]}]
endfun

fun! s:Yank.update_stack() dict
  call s:update_stack(self)
endfun

fun! s:Yank.toggle_freeze() dict
  call s:toggle_freeze(self, 'Yank')
endfun

fun! s:Yank.move_offset(forward) dict
  return s:move_offset(self, a:forward)
endfun

fun! s:Yank.size() dict
  return len(self.stack)
endfun

fun! s:Yank.update_register() dict
  call s:update_register(self)
endfun

fun! s:Yank.reset_offset() dict
  if !self.frozen | let self.offset = 0 | endif
endfun

fun! s:Yank.set_at_offset(n) dict
  let self.offset = a:n
  call s:update_register(self)
endfun





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



fun! s:Redir.clear() dict
  let r = s:F.get_register(1)
  let self.stack = [{'text': r[1], 'type': r[2]}]
endfun

fun! s:Redir.update_stack() dict
  call s:update_stack(self)
  call s:F.restore_register()
endfun

fun! s:Redir.toggle_freeze() dict
  call s:toggle_freeze(self, 'Redir')
endfun

fun! s:Redir.move_offset(forward) dict
  return s:move_offset(self, a:forward)
endfun

fun! s:Redir.size() dict
  return len(self.stack)
endfun

fun! s:Redir.update_register() dict
  call s:update_register(self)
endfun

fun! s:Redir.reset_offset() dict
  if !self.frozen | let self.offset = 0 | endif
endfun

fun! s:Redir.set_at_offset(n) dict
  let self.offset = a:n
  call s:update_register(self)
endfun





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
" Common functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:update_stack(self)
  " if entry is duplicate, put it upfront removing the previous one
  let r = s:F.get_register()
  let text = r[1]
  let type = r[2]
  if !s:too_big(text)
    let ix = index(a:self.stack, {'text': text, 'type': type})
    call insert(a:self.stack, ix == - 1
          \ ? {'text': text, 'type': type}
          \ : remove(a:self.stack, ix))
  endif
endfun

fun! s:toggle_freeze(self, str)
  let a:self.frozen = !a:self.frozen
  if a:self.frozen
    echo a:str "stack offset won't be reset."
  else
    echo a:str "stack offset will be reset normally."
  endif
endfun

fun! s:move_offset(self, forward)
  let a:self.offset += (a:forward ? 1 : -1)
  if a:self.offset >= a:self.size()
    let a:self.offset = 0
    return 1
  elseif a:self.offset < 0
    let a:self.offset = a:self.size()-1
    return 2
  endif
endfun

fun! s:update_register(self)
  let text = a:self.stack[a:self.offset]['text']
  let type = a:self.stack[a:self.offset]['type']
  call setreg(s:F.default_reg(), text, type)
endfun





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! s:too_big(text)
  " hitting text size limit
  return strchars(a:text) > get(g:, 'yanktools_max_text_size', 1000)
endfun

